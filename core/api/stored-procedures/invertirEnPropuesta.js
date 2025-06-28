/**
 * Endpoint: /api/stored-procedures/invertirEnPropuesta
 * Permite a un inversor realizar una inversión en una propuesta utilizando el SP PV_InvertirEnPropuesta

 */

const sql = require('mssql');

// Importar configuración de base de datos del proyecto
const { getDbConfig } = require('../../src/config/database');
const config = getDbConfig();

module.exports = async (req, res) => {
  try {
    const { method } = req;

    if (method === 'POST') {
      // POST: Realizar inversión usando el SP
      return await procesarInversion(req, res);
    
    } else if (method === 'GET') {
      // GET: Obtener información de inversiones existentes para una propuesta
      const { proposalid, userid } = req.query;
      return await obtenerInformacionInversiones(req, res, proposalid, userid);
    
    } else {
      res.setHeader('Allow', ['GET', 'POST']);
      return res.status(405).json({
        error: `Método ${method} no permitido`,
        allowedMethods: ['GET', 'POST'],
        timestamp: new Date().toISOString()
      });
    }

  } catch (error) {
    console.error('Error en endpoint invertirEnPropuesta:', error);
    return res.status(500).json({
      error: 'Error interno del servidor',
      details: error.message,
      timestamp: new Date().toISOString()
    });
  }
};


//Procesa una inversión llamando al SP PV_InvertirEnPropuesta

async function procesarInversion(req, res) {
  // Obtener userid del token JWT (ya verificado por middleware)

  const userid = req.user.userId;
  const {
    proposalid,
    amount,
    investmentdate,
    paymentmethodName,
    availablemethodName
  } = req.body;

  // Validaciones básicas de campos requeridos (userid ya no es necesario del body)
  const camposRequeridos = {
    proposalid: 'ID de propuesta',
    amount: 'Monto de inversión',
    investmentdate: 'Fecha de inversión',
    paymentmethodName: 'Nombre de método de pago',
    availablemethodName: 'Nombre de método disponible'
  };

  const errores = [];
  Object.entries(camposRequeridos).forEach(([campo, descripcion]) => {
    if (!req.body[campo]) {
      errores.push(`${descripcion} es requerido`);
    }
  });

  // Validaciones específicas
  if (amount && (isNaN(amount) || parseFloat(amount) <= 0)) {
    errores.push('El monto debe ser un número positivo');
  }

  if (investmentdate && isNaN(Date.parse(investmentdate))) {
    errores.push('Fecha de inversión inválida');
  }

  if (errores.length > 0) {
    return res.status(400).json({
      error: 'Datos de inversión inválidos',
      details: errores,
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    console.log(`Iniciando inversión - Usuario: ${userid}, Propuesta: ${proposalid}, Monto: ${amount}`);

    // Conectar a SQL Server
    pool = await sql.connect(config);


    // Preparar la llamada al stored procedure SOLO con los parámetros que espera
    const request = pool.request();
    request.input('proposalid', sql.Int, parseInt(proposalid));
    request.input('userid', sql.Int, parseInt(userid));
    request.input('amountInDollars', sql.Decimal(28, 2), parseFloat(amount));
    request.input('investmentdate', sql.DateTime, new Date(investmentdate));
    request.input('paymentmethodName', sql.NVarChar(100), paymentmethodName);
    request.input('availablemethodName', sql.NVarChar(100), availablemethodName);

    // Ejecutar el stored procedure
    console.log('Ejecutando SP PV_InvertirEnPropuesta...');
    const result = await request.execute('PV_InvertirEnPropuesta');

    console.log('Inversión procesada exitosamente');

    // Respuesta exitosa
    return res.status(201).json({
      success: true,
      message: 'Inversión registrada exitosamente',
      data: {
        proposalId: parseInt(proposalid),
        userId: parseInt(userid),
        amount: parseFloat(amount),
        investmentDate: new Date(investmentdate),
        status: 'processed',
        details: {
          adelantoInicial: (parseFloat(amount) * 0.20).toFixed(2),
          porcentajeAccionario: 'Calculado automáticamente',
          tramosCreados: 4,
          votacionesFiscalizacion: 4
        }
      },
      recordsets: result.recordsets, // Incluir cualquier resultado del SP
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error ejecutando SP PV_InvertirEnPropuesta:', error);

    // Manejar errores específicos del SP
    let statusCode = 500;
    let errorMessage = 'Error al procesar la inversión';
    
    if (error.message) {
      if (error.message.includes('propuesta no está aprobada')) {
        statusCode = 403;
        errorMessage = 'La propuesta no está aprobada para inversión';
      } else if (error.message.includes('usuario no está activo')) {
        statusCode = 403;
        errorMessage = 'Usuario no está activo o verificado';
      } else if (error.message.includes('monto debe ser mayor a cero')) {
        statusCode = 400;
        errorMessage = 'El monto debe ser mayor a cero';
      } else if (error.message.includes('inversión excede el monto')) {
        statusCode = 400;
        errorMessage = 'La inversión excede el monto permitido para el proyecto';
      } else if (error.message.includes('valor total del proyecto no es válido')) {
        statusCode = 400;
        errorMessage = 'El valor total del proyecto no es válido';
      }
    }

    return res.status(statusCode).json({
      success: false,
      error: errorMessage,
      details: error.message,
      errorCode: 'SP_INVERSION_ERROR',
      timestamp: new Date().toISOString()
    });

  } finally {
    // Cerrar conexión
    if (pool) {
      try {
        await pool.close();
      } catch (closeError) {
        console.error('Error cerrando conexión:', closeError);
      }
    }
  }
}


//Obtiene información de inversiones existentes

async function obtenerInformacionInversiones(req, res, proposalid, userid) {
  if (!proposalid) {
    return res.status(400).json({
      error: 'ID de propuesta requerido',
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    pool = await sql.connect(config);
    const request = pool.request();

    // Query base para obtener inversiones
    let query = `
      SELECT 
        i.investmentid,
        i.proposalid,
        i.amount,
        i.equitypercentage,
        i.investmentdate,
        i.userid,
        u.firstname + ' ' + u.lastname as investorName,
        p.title as proposalTitle,
        p.budget as proposalBudget,
        -- Información de agreements
        (SELECT COUNT(*) FROM PV_InvestmentAgreements ia WHERE ia.investmentId = i.investmentid) as totalAgreements,
        -- Información de pasos de inversión
        (SELECT COUNT(*) FROM PV_InvestmentSteps ist WHERE ist.transactionId IN 
          (SELECT t.transactionid FROM PV_Transactions t 
           JOIN PV_Payment pay ON t.paymentid = pay.paymentid 
           WHERE pay.userid = i.userid)) as totalSteps,
        -- Monto total invertido en la propuesta
        (SELECT ISNULL(SUM(amount), 0) FROM PV_Investments WHERE proposalid = i.proposalid) as totalInvested
      FROM PV_Investments i
      JOIN PV_Users u ON i.userid = u.userid
      JOIN PV_Proposals p ON i.proposalid = p.proposalid
      WHERE i.proposalid = @proposalid
    `;

    request.input('proposalid', sql.Int, parseInt(proposalid));

    // Filtrar por usuario si se especifica
    if (userid) {
      query += ' AND i.userid = @userid';
      request.input('userid', sql.Int, parseInt(userid));
    }

    query += ' ORDER BY i.investmentdate DESC';

    const result = await request.query(query);

    // Obtener resumen del proyecto
    const summaryRequest = pool.request();
    summaryRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const summaryResult = await summaryRequest.query(`
      SELECT 
        p.title,
        p.budget,
        p.statusid,
        ps.name as statusName,
        ISNULL(SUM(i.amount), 0) as totalInvested,
        ISNULL(SUM(i.equitypercentage), 0) as totalEquityAllocated,
        COUNT(DISTINCT i.userid) as totalInvestors
      FROM PV_Proposals p
      LEFT JOIN PV_Investments i ON p.proposalid = i.proposalid
      LEFT JOIN PV_ProposalStatus ps ON p.statusid = ps.statusid
      WHERE p.proposalid = @proposalid
      GROUP BY p.proposalid, p.title, p.budget, p.statusid, ps.name
    `);

    return res.status(200).json({
      success: true,
      data: {
        proposal: summaryResult.recordset[0] || null,
        investments: result.recordset || [],
        summary: {
          totalInvestments: result.recordset.length,
          availableForInvestment: summaryResult.recordset[0] ? 
            (summaryResult.recordset[0].budget - summaryResult.recordset[0].totalInvested) : 0
        }
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error obteniendo información de inversiones:', error);
    return res.status(500).json({
      error: 'Error al obtener información de inversiones',
      details: error.message,
      timestamp: new Date().toISOString()
    });

  } finally {
    if (pool) {
      try {
        await pool.close();
      } catch (closeError) {
        console.error('Error cerrando conexión:', closeError);
      }
    }
  }
}
