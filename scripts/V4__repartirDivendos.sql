CREATE PROCEDURE sp_PV_RepartirDividendos
    @proposalid INT,
    @processedby INT,
    @paymentmethodName NVARCHAR(100),
    @availablemethodName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    -- Buscar IDs/valores a partir de los nombres
    DECLARE @paymentmethodid INT;
    DECLARE @availablePaymentMethods NVARCHAR(MAX);
    SELECT TOP 1 @paymentmethodid = paymentmethodid FROM PV_PaymentMethods WHERE name = @paymentmethodName;
    SELECT @availablePaymentMethods = STRING_AGG(name, ', ') FROM PV_PaymentMethods;
    IF @paymentmethodid IS NULL
    BEGIN
        RAISERROR('Método de pago no encontrado: %s. Métodos disponibles: %s', 16, 1, @paymentmethodName, @availablePaymentMethods);
        RETURN;
    END

    -- Eliminado: la búsqueda de método disponible se hará por inversionista dentro del ciclo

    DECLARE @currencyid INT;
    SET @currencyid = 2;

    DECLARE @exchangerateid INT;
    SET @exchangerateid = 1;

    -- validar que el proyecto esté en estado ejecutando y con fiscalizaciones aprobadas
    DECLARE @approvedStatusId INT, @draftStatusId INT;
    SELECT TOP 1 @approvedStatusId = statusid FROM PV_ProposalStatus WHERE name = 'Aprobada' ORDER BY statusid;
    SELECT TOP 1 @draftStatusId = statusid FROM PV_ProposalStatus WHERE name = 'Borrador' ORDER BY statusid;
    IF NOT EXISTS (
        SELECT 1 FROM PV_Proposals p
        WHERE p.proposalid = @proposalid AND p.statusid = @approvedStatusId
    )
    BEGIN
        RAISERROR('El proyecto no está en estado ejecutando.', 16, 1)
        RETURN
    END
    IF NOT EXISTS (
        SELECT 1 FROM PV_ProjectMonitoring pm
        WHERE pm.proposalid = @proposalid AND pm.statusid = @approvedStatusId
    )
    BEGIN
        RAISERROR('No hay fiscalizaciones aprobadas para este proyecto.', 16, 1)
        RETURN
    END
    -- verificar reporte financiero aprobado y disponibilidad de fondos
    DECLARE @reportid INT, @availablefordividends DECIMAL(18,2)
    SELECT TOP 1 @reportid = reportid, @availablefordividends = availablefordividends
    FROM PV_FinancialReports
    WHERE proposalid = @proposalid AND availablefordividends > 0
    ORDER BY submitteddate DESC
    IF @reportid IS NULL OR @availablefordividends <= 0
    BEGIN
        RAISERROR('No hay reporte financiero aprobado o fondos disponibles para repartir.', 16, 1)
        RETURN
    END

    -- consultar inversionistas y sus porcentajes de participación
    DECLARE @totalEquity DECIMAL(18,4)
    SELECT @totalEquity = SUM(equitypercentage) FROM PV_Investments WHERE proposalid = @proposalid
    IF @totalEquity IS NULL OR @totalEquity = 0
    BEGIN
        RAISERROR('No hay inversionistas registrados para este proyecto.', 16, 1)
        RETURN
    END    -- calcular monto a distribuir a cada inversionista
    DECLARE investor_cursor CURSOR FOR
        SELECT i.investmentid, i.userId, i.equitypercentage
        FROM PV_Investments i
        INNER JOIN PV_InvestmentAgreements ia ON i.proposalid = ia.proposalid
        WHERE i.proposalid = @proposalid
        GROUP BY i.investmentid, i.userId, i.equitypercentage
    DECLARE @investmentid INT, @userid INT, @equity DECIMAL(18,4), @monto DECIMAL(18,2)

    -- verificar medios de depósito válidos y generar transacciones de pago
    OPEN investor_cursor
    FETCH NEXT FROM investor_cursor INTO @investmentid, @userid, @equity
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @availablemethodid INT;
        DECLARE @availableAvailableMethods NVARCHAR(MAX);
        -- DEBUG: Mostrar métodos disponibles para el usuario y nombre
        SELECT * FROM PV_AvailableMethods WHERE name = @availablemethodName AND userid = @userid;
        SELECT TOP 1 @availablemethodid = availablemethodid FROM PV_AvailableMethods WHERE name = @availablemethodName AND userid = @userid;
        SELECT @availableAvailableMethods = STRING_AGG(name, ', ') FROM PV_AvailableMethods WHERE userid = @userid;
        IF @availablemethodid IS NULL
        BEGIN
            RAISERROR('El inversionista %d no tiene un medio de depósito válido para "%s". Métodos disponibles: %s', 16, 1, @userid, @availablemethodName, @availableAvailableMethods);
            CLOSE investor_cursor
            DEALLOCATE investor_cursor
            RETURN
        END
        -- calcular monto
        SET @monto = ROUND(@availablefordividends * (@equity / @totalEquity), 2)

        -- hacer pago
        INSERT INTO PV_Payment (
            amount, actualamount, result, reference, auth, chargetoken, description, date, checksum, moduleid, paymentmethodid, availablemethodid, userid
        ) VALUES (
            @monto, @monto, 1, 'INV-REF', 'AUTH-OK', 0x00, 'Pago inversión', GETDATE(), HASHBYTES('SHA2_256', CONCAT(@proposalid, '-', @monto, '-')), 1, @paymentmethodid, @availablemethodid, @userid
        );
        DECLARE @paymentid INT = SCOPE_IDENTITY();

        --  transacción de pago 
        INSERT INTO PV_Transactions (amount, description, date, posttime, reference1, reference2, value1, value2, processmanagerid, convertedamount, checksum, transtypeid, transsubtypeid, paymentid, currencyid, exchangerateid, scheduleid, balanceid, fundid)
        VALUES (@monto, 'Reparto de dividendos', GETDATE(), GETDATE(), @proposalid, @userid, 'Dividendos', '', @processedby, @monto, HASHBYTES('SHA2_256', CONCAT(@proposalid, '-', @monto, '-')), 1, 1, @paymentid, @currencyid, @exchangerateid, null, null, null)
       
        DECLARE @transactionid INT = SCOPE_IDENTITY()

        -- Logs de cada paguito
        INSERT INTO PV_Logs (description, name, posttime, computer, trace, checksum, logseverityid, logtypeid, logsourceid)
        VALUES (
            CONCAT('Pago de dividendos a usuario ', @userid, ' por propuesta ', @proposalid, '. Monto: ', @monto, '. Transacción: ', @transactionid),
            'PagoDividendo',
            GETDATE(),
            'system',
            'T01',
            HASHBYTES('SHA2_256', CONCAT(@proposalid, '-', @userid, '-')),
            (SELECT TOP 1 logseverityid FROM PV_LogSeverity WHERE name = 'Info' ORDER BY logseverityid),
            (SELECT TOP 1 logtypeid FROM PV_LogTypes WHERE name = 'Inversión' ORDER BY logtypeid),
            (SELECT TOP 1 logsourceid FROM PV_LogSource WHERE name = 'Batch' ORDER BY logsourceid)
        )
        
        FETCH NEXT FROM investor_cursor INTO @investmentid, @userid, @equity
    END
    CLOSE investor_cursor
    DEALLOCATE investor_cursor

    -- Log total
    INSERT INTO PV_Logs (description, name, posttime, computer, trace, checksum, logseverityid, logtypeid, logsourceid)
    VALUES (
        CONCAT('Reparto de dividendos realizado para propuesta ', @proposalid, '. Monto total: ', @availablefordividends),
        'RepartoDividendos',
        GETDATE(),
        'system',
        'T01',
        HASHBYTES('SHA2_256', CONCAT(@proposalid, '-', @availablefordividends, '-')),
        (SELECT TOP 1 logseverityid FROM PV_LogSeverity WHERE name = 'Info' ORDER BY logseverityid),
        (SELECT TOP 1 logtypeid FROM PV_LogTypes WHERE name = 'Inversión' ORDER BY logtypeid),
        (SELECT TOP 1 logsourceid FROM PV_LogSource WHERE name = 'Batch' ORDER BY logsourceid)
    )
END