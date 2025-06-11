CREATE PROCEDURE sp_PV_RepartirDividendos
    @proposalid INT,
    @processedby INT,
    @paymentmethodid INT,
    @availablemethodid INT,
    @currencyid INT,
    @exchangerateid INT
AS
BEGIN
    SET NOCOUNT ON;
    -- validar que el proyecto esté en estado ejecutando y con fiscalizaciones aprobadas
    IF NOT EXISTS (
        SELECT 1 FROM PV_Proposals p
        WHERE p.proposalid = @proposalid AND p.statusid = (SELECT statusid FROM PV_ProposalStatus WHERE name = 'Aprobada')
    )
    BEGIN
        RAISERROR('El proyecto no está en estado ejecutando.', 16, 1)
        RETURN
    END
    IF NOT EXISTS (
        SELECT 1 FROM PV_ProjectMonitoring pm
        WHERE pm.proposalid = @proposalid AND pm.statusid = (SELECT statusid FROM PV_ProposalStatus WHERE name = 'Aprobada') 
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
    END

    -- calcular monto a distribuir a cada inversionista
    DECLARE investor_cursor CURSOR FOR
        SELECT investmentid, userid, equitypercentage
        FROM PV_Investments WHERE proposalid = @proposalid
    DECLARE @investmentid INT, @userid INT, @equity DECIMAL(18,4), @monto DECIMAL(18,2)

    -- verificar medios de depósito válidos y generar transacciones de pago
    OPEN investor_cursor
    FETCH NEXT FROM investor_cursor INTO @investmentid, @userid, @equity
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar medio de depósito válido
        IF NOT EXISTS (SELECT 1 FROM PV_AvailableMethods WHERE userid = @userid)
        BEGIN
            RAISERROR('El inversionista %d no tiene un medio de depósito válido.', 16, 1, @userid)
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
        VALUES (@monto, 'Reparto de dividendos', GETDATE(), GETDATE(), @proposalid, @userid, 'Dividendos', '', @processedby, @monto, HASHBYTES('SHA2_256', CONCAT(@proposalid, '-', @monto, '-')), 1, 1, @paymentid, 1, 1, null, null, null)
       
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
            (SELECT logseverityid FROM PV_LogSeverity WHERE name = 'Info'),
            (SELECT logtypeid FROM PV_LogTypes WHERE name = 'Inversión'),
            (SELECT logsourceid FROM PV_LogSource WHERE name = 'Batch')
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
        (SELECT logseverityid FROM PV_LogSeverity WHERE name = 'Info'),
        (SELECT logtypeid FROM PV_LogTypes WHERE name = 'Inversión'),
        (SELECT logsourceid FROM PV_LogSource WHERE name = 'Batch')
    )
END