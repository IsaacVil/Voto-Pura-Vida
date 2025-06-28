/**
 * Endpoint: /api/stored-procedures/repartirDividendos
 * Permite repartir dividendos a inversores de una propuesta utilizando el SP sp_PV_RepartirDividendos
 * 
 * Funcionalidades implementadas:
 * - Validación de permisos de administrador/gestor de propuesta
 * - Llamada directa al stored procedure sp_PV_RepartirDividendos
 * - Control transaccional automático en el SP
 * - Validaciones de negocio implementadas en el SP:
 *   - Proyecto en estado ejecutando con fiscalizaciones aprobadas
 *   - Reporte financiero aprobado con fondos disponibles
 *   - Inversionistas registrados con porcentajes válidos
 *   - Medios de depósito válidos para cada inversor
 *   - Cálculo proporcional de dividendos por equity
 * - Generación automática de pagos y transacciones
 * - Logs de auditoría por cada pago procesado
 * - Manejo de errores del SP con códigos específicos
 */

const sql = require('mssql');

// Importar configuración de base de datos del proyecto
const { getDbConfig } = require('../../src/config/database');
const config = getDbConfig();

module.exports = async (req, res) => {
  try {
    const { method } = req;

    if (method === 'POST') {
      // POST: Ejecutar reparto de dividendos usando el SP
      return await procesarRepartoDividendos(req, res);
    
    } else if (method === 'GET') {
      // GET: Obtener información de dividendos disponibles y repartos previos
      const { proposalid, reportid } = req.query;
      return await obtenerInformacionDividendos(req, res, proposalid, reportid);
    
    } else {
      res.setHeader('Allow', ['GET', 'POST']);
      return res.status(405).json({
        error: `Método ${method} no permitido`,
        allowedMethods: ['GET', 'POST'],
        timestamp: new Date().toISOString()
      });
    }

  } catch (error) {
    console.error('Error en endpoint repartirDividendos:', error);
    return res.status(500).json({
      error: 'Error interno del servidor',
      details: error.message,
      timestamp: new Date().toISOString()
    });
  }
};

/**
 * Procesa el reparto de dividendos llamando al SP sp_PV_RepartirDividendos
 */

const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || 'supersecreto_para_firmar_tokens';

async function procesarRepartoDividendos(req, res) {
  // Extraer userid del JWT
  let userid;
  try {
    const authHeader = req.headers['authorization'] || req.headers['Authorization'];
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No se encontró el token de autenticación en los headers.' });
    }
    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, JWT_SECRET);
    userid = decoded.sub || decoded.userid || decoded.userId || decoded.id;
    if (!userid) {
      return res.status(401).json({ error: 'El token no contiene userid.' });
    }
  } catch (err) {
    return res.status(401).json({ error: 'Token inválido o expirado.', details: err.message });
  }

  // Validación extra: nunca llamar al SP si userid no está definido
  if (!userid) {
    return res.status(400).json({ error: 'processedby (userid) no está definido. No se puede procesar el reparto.' });
  }

  // Recibir los campos como texto (nombres)
  const { proposalid, paymentMethod, availableMethod, currency, exchangeRate } = req.body;

  // Validaciones básicas de campos requeridos
  const camposRequeridos = {
    proposalid: 'ID de propuesta',
    paymentMethod: 'Método de pago',
    availableMethod: 'Método disponible',
    currency: 'Moneda',
    exchangeRate: 'Tasa de cambio'
  };
  const errores = [];
  Object.entries(camposRequeridos).forEach(([campo, descripcion]) => {
    if (!req.body[campo]) {
      errores.push(`${descripcion} es requerido`);
    }
  });
  if (errores.length > 0) {
    return res.status(400).json({
      error: 'Datos de reparto de dividendos inválidos',
      details: errores,
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {

    // Buscar los IDs igual que en inversión
    pool = await sql.connect(config);

    // Buscar paymentmethodid por nombre (sin userid, solo por name)
    const paymentMethodResult = await pool.request()
      .input('name', sql.NVarChar(100), paymentMethod)
      .query('SELECT paymentmethodid, name FROM PV_PaymentMethods WHERE name = @name');
    const paymentmethodid = paymentMethodResult.recordset[0]?.paymentmethodid;
    if (!paymentmethodid) {
      // Si no se encuentra, mapear y devolver los métodos de pago posibles
      const allMethodsResult = await pool.request()
        .query('SELECT paymentmethodid, name FROM PV_PaymentMethods');
      const posiblesMetodos = allMethodsResult.recordset.map(m => ({
        paymentmethodid: m.paymentmethodid,
        name: m.name
      }));
      return res.status(400).json({
        error: 'Método de pago no encontrado.',
        posiblesMetodos,
        mensaje: 'Métodos de pago disponibles para seleccionar.'
      });
    }

    // Buscar availablemethodid por nombre
    const availableMethodResult = await pool.request()
      .input('userid', sql.Int, parseInt(userid))
      .input('name', sql.NVarChar(100), availableMethod)
      .query('SELECT TOP 1 availablemethodid FROM PV_AvailableMethods WHERE userid = @userid AND name = @name');
    const availablemethodid = availableMethodResult.recordset[0]?.availablemethodid;
    if (!availablemethodid) {
      return res.status(400).json({ error: 'Método disponible no encontrado para el usuario.' });
    }

    // Buscar currencyid por nombre
    const currencyResult = await pool.request()
      .input('name', sql.NVarChar(100), currency)
      .query('SELECT currencyid, name FROM PV_Currency WHERE name = @name');
    const currencyid = currencyResult.recordset[0]?.currencyid;
    if (!currencyid) {
      // Si no se encuentra, mapear y devolver las monedas posibles
      const allCurrenciesResult = await pool.request().query('SELECT currencyid, name FROM PV_Currency');
      const posiblesMonedas = allCurrenciesResult.recordset.map(m => ({
        currencyid: m.currencyid,
        name: m.name
      }));
      return res.status(400).json({
        error: 'Moneda no encontrada.',
        posiblesMonedas,
        mensaje: 'Monedas disponibles para seleccionar.'
      });
    }

    // Buscar exchangerateid por nombre en la tabla correcta (PV_ExchangeRate)
    // NOTA: La tabla PV_ExchangeRate NO tiene columna 'name'. Usaremos un identificador alternativo.
    // Aquí se asume que el campo 'exchangeRate' (decimal) o combinación de sourceCurrencyid/destinyCurrencyId puede ser usado como identificador.
    // Intentaremos buscar por el valor numérico de exchangeRate.
    let exchangerateid;
    let exchangeRateNumeric = parseFloat(exchangeRate);
    if (!isNaN(exchangeRateNumeric)) {
      const exchangeRateResult = await pool.request()
        .input('rate', sql.Decimal(15,8), exchangeRateNumeric)
        .query('SELECT TOP 1 exchangeRateid FROM PV_ExchangeRate WHERE exchangeRate = @rate');
      exchangerateid = exchangeRateResult.recordset[0]?.exchangeRateid;
    }
    if (!exchangerateid) {
      // Si no se encuentra, mapear y devolver las tasas posibles (solo id y valor)
      const allRatesResult = await pool.request().query('SELECT exchangeRateid, exchangeRate, sourceCurrencyid, destinyCurrencyId FROM PV_ExchangeRate');
      const posiblesTasas = allRatesResult.recordset.map(m => ({
        exchangeRateid: m.exchangeRateid,
        exchangeRate: m.exchangeRate,
        sourceCurrencyid: m.sourceCurrencyid,
        destinyCurrencyId: m.destinyCurrencyId
      }));
      return res.status(400).json({
        error: 'Tasa de cambio no encontrada.',
        posiblesTasas,
        mensaje: 'Tasas de cambio disponibles para seleccionar (por valor, origen y destino).'
      });
    }


    // Verificar permisos del usuario antes de procesar
    const permisoValido = await verificarPermisosReparto(pool, parseInt(userid), parseInt(proposalid));
    if (!permisoValido.permitido) {
      return res.status(403).json({
        error: 'Permisos insuficientes',
        details: permisoValido.razon,
        timestamp: new Date().toISOString()
      });
    }


    // Preparar la llamada al stored procedure SOLO con los parámetros requeridos por el SP
    const request = pool.request();
    request.input('proposalid', sql.Int, parseInt(proposalid));
    request.input('processedby', sql.Int, parseInt(userid));
    request.input('paymentmethodName', sql.NVarChar(100), paymentMethod);
    request.input('availablemethodName', sql.NVarChar(100), availableMethod);

    // Ejecutar el stored procedure
    console.log('Ejecutando SP sp_PV_RepartirDividendos...');
    const result = await request.execute('sp_PV_RepartirDividendos');

    console.log('Reparto de dividendos procesado exitosamente');

    // Obtener información del reparto realizado
    const infoReparto = await obtenerDetallesReparto(pool, parseInt(proposalid));

    // Respuesta exitosa
    return res.status(201).json({
      success: true,
      message: 'Reparto de dividendos procesado exitosamente',
      data: {
        proposalId: parseInt(proposalid),
        processedBy: parseInt(userid),
        processedAt: new Date(),
        status: 'completed',
        details: infoReparto
      },
      recordsets: result.recordsets, // Incluir cualquier resultado del SP
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error ejecutando SP sp_PV_RepartirDividendos:', error);

    // Manejar errores específicos del SP
    let statusCode = 500;
    let errorMessage = 'Error al procesar el reparto de dividendos';
    
    if (error.message) {
      if (error.message.includes('proyecto no está en estado ejecutando')) {
        statusCode = 403;
        errorMessage = 'El proyecto no está en estado ejecutando';
      } else if (error.message.includes('No hay fiscalizaciones aprobadas')) {
        statusCode = 400;
        errorMessage = 'No hay fiscalizaciones aprobadas para este proyecto';
      } else if (error.message.includes('No hay reporte financiero aprobado')) {
        statusCode = 400;
        errorMessage = 'No hay reporte financiero aprobado o fondos disponibles para repartir';
      } else if (error.message.includes('No hay inversionistas registrados')) {
        statusCode = 400;
        errorMessage = 'No hay inversionistas registrados para este proyecto';
      } else if (error.message.includes('no tiene un medio de depósito válido')) {
        statusCode = 400;
        errorMessage = 'Algunos inversionistas no tienen medios de depósito válidos';
      }
    }

    return res.status(statusCode).json({
      success: false,
      error: errorMessage,
      details: error.message,
      errorCode: 'SP_DIVIDENDOS_ERROR',
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

/**
 * Obtiene información de dividendos disponibles y repartos previos
 */
async function obtenerInformacionDividendos(req, res, proposalid, reportid) {
  if (!proposalid) {
    return res.status(400).json({
      error: 'ID de propuesta requerido',
      timestamp: new Date().toISOString()
    });
  }

  let pool;
  try {
    pool = await sql.connect(config);

    // Obtener información de reportes financieros con fondos disponibles
    const reportesRequest = pool.request();
    reportesRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const reportesResult = await reportesRequest.query(`
      SELECT 
        reportid,
        proposalid,
        availablefordividends,
        submitteddate,
        approveddate,
        reportperiod,
        totalrevenue,
        totalexpenses,
        netprofit
      FROM PV_FinancialReports
      WHERE proposalid = @proposalid 
        AND availablefordividends > 0
      ORDER BY submitteddate DESC
    `);

    // Obtener información de inversionistas
    const inversoresRequest = pool.request();
    inversoresRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const inversoresResult = await inversoresRequest.query(`
      SELECT 
        i.investmentid,
        i.userid,
        u.firstname + ' ' + u.lastname as investorName,
        i.amount as investmentAmount,
        i.equitypercentage,
        i.investmentdate,
        -- Verificar si tiene método de depósito válido
        CASE WHEN EXISTS(SELECT 1 FROM PV_AvailableMethods am WHERE am.userid = i.userid) 
             THEN 1 ELSE 0 END as hasValidPaymentMethod,
        -- Calcular dividendos potenciales del último reporte
        CASE WHEN @proposalid IS NOT NULL THEN
          (SELECT TOP 1 
            ROUND(fr.availablefordividends * (i.equitypercentage / 
              (SELECT SUM(equitypercentage) FROM PV_Investments WHERE proposalid = @proposalid)), 2)
           FROM PV_FinancialReports fr 
           WHERE fr.proposalid = @proposalid AND fr.availablefordividends > 0
           ORDER BY fr.submitteddate DESC)
        ELSE 0 END as potentialDividend
      FROM PV_Investments i
      JOIN PV_Users u ON i.userid = u.userid
      WHERE i.proposalid = @proposalid
      ORDER BY i.equitypercentage DESC
    `);

    // Obtener historial de repartos previos
    const historialRequest = pool.request();
    historialRequest.input('proposalid', sql.Int, parseInt(proposalid));
    
    const historialResult = await historialRequest.query(`
      SELECT 
        t.transactionid,
        t.amount,
        t.date as paymentDate,
        t.description,
        p.userid as investorId,
        u.firstname + ' ' + u.lastname as investorName,
        t.reference1 as proposalReference
      FROM PV_Transactions t
      JOIN PV_Payment p ON t.paymentid = p.paymentid
      JOIN PV_Users u ON p.userid = u.userid
      WHERE t.reference1 = @proposalid 
        AND t.description LIKE '%dividendos%'
      ORDER BY t.date DESC
    `);

    // Calcular resumen
    const totalDividendosDisponibles = reportesResult.recordset.reduce(
      (sum, reporte) => sum + (reporte.availablefordividends || 0), 0
    );

    const totalEquity = inversoresResult.recordset.reduce(
      (sum, inv) => sum + (inv.equitypercentage || 0), 0
    );

    const inversoresSinMedioPago = inversoresResult.recordset.filter(
      inv => !inv.hasValidPaymentMethod
    ).length;

    return res.status(200).json({
      success: true,
      data: {
        proposal: {
          proposalId: parseInt(proposalid),
          totalDividendosDisponibles,
          reportesConFondos: reportesResult.recordset.length
        },
        reportesFinancieros: reportesResult.recordset || [],
        inversionistas: inversoresResult.recordset || [],
        historialRepartos: historialResult.recordset || [],
        resumen: {
          totalInversionistas: inversoresResult.recordset.length,
          totalEquityAllocated: totalEquity,
          inversoresSinMedioPago,
          repartosRealizados: historialResult.recordset.length,
          disponibleParaReparto: totalDividendosDisponibles > 0 && inversoresSinMedioPago === 0
        }
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error obteniendo información de dividendos:', error);
    return res.status(500).json({
      error: 'Error al obtener información de dividendos',
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


//Verifica permisos del usuario para procesar reparto de dividendos
 
async function verificarPermisosReparto(pool, userid, proposalid) {
  try {
    const request = pool.request();
    request.input('userid', sql.Int, userid);
    request.input('proposalid', sql.Int, proposalid);

    // Verificar si es admin, gestor de propuesta o creador
    const result = await request.query(`
      SELECT 
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM PV_UserRoles ur
            JOIN PV_Roles r ON ur.roleid = r.roleid
            WHERE ur.userid = @userid AND r.name IN ('Admin', 'ProjectManager') 
              AND ur.enabled = 1 AND ur.deleted = 0
          ) THEN 1
          WHEN EXISTS (
            SELECT 1 FROM PV_Proposals p
            WHERE p.proposalid = @proposalid AND p.createdby = @userid
          ) THEN 1
          ELSE 0
        END as hasPermission
    `);

    const hasPermission = result.recordset[0]?.hasPermission === 1;

    return {
      permitido: hasPermission,
      razon: hasPermission ? null : 'Usuario no tiene permisos para procesar reparto de dividendos'
    };

  } catch (error) {
    console.error('Error verificando permisos:', error);
    return {
      permitido: false,
      razon: 'Error al verificar permisos'
    };
  }
}


//Obtiene detalles del reparto realizado

async function obtenerDetallesReparto(pool, proposalid) {
  try {
    const request = pool.request();
    request.input('proposalid', sql.Int, proposalid);

    // Obtener transacciones de dividendos más recientes
    const result = await request.query(`
      SELECT TOP 10
        t.amount,
        u.firstname + ' ' + u.lastname as investorName,
        t.date as paymentDate,
        i.equitypercentage
      FROM PV_Transactions t
      JOIN PV_Payment p ON t.paymentid = p.paymentid
      JOIN PV_Users u ON p.userid = u.userid
      LEFT JOIN PV_Investments i ON i.userid = p.userid AND i.proposalid = @proposalid
      WHERE t.reference1 = @proposalid 
        AND t.description LIKE '%dividendos%'
        AND t.date >= DATEADD(MINUTE, -10, GETDATE()) -- Últimos 10 minutos
      ORDER BY t.date DESC
    `);

    const totalRepartido = result.recordset.reduce((sum, pago) => sum + pago.amount, 0);

    return {
      pagosRealizados: result.recordset.length,
      totalRepartido,
      detallesPagos: result.recordset
    };

  } catch (error) {
    console.error('Error obteniendo detalles del reparto:', error);
    return {
      pagosRealizados: 0,
      totalRepartido: 0,
      detallesPagos: []
    };
  }
}
