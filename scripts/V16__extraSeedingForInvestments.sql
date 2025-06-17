-- Más datos de prueba para la base de datos
-- se usan para invertir y repartir dividendos!

-- Available methods para los inversionistas 
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 3, 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 4, 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 5, 1);

-- Exchange rate
INSERT INTO PV_ExchangeRate(startDate, endDate, exchangeRate, enabled, currentExchangeRate, sourceCurrencyid, destinyCurrencyId) VALUES (GETDATE(), DATEADD(DAY, 300, GETDATE()), 0.5, 1,1,1,2)

-- Payment type
INSERT INTO PV_TransType(name) VALUES ('Interna')

-- Payment subtype
INSERT INTO PV_TransSubTypes(name) VALUES ('Inversion')
INSERT INTO PV_TransSubTypes(name) VALUES ('Dividendos')

-- Propuestas aprobadas
INSERT INTO PV_Proposals (title, description, proposalcontent, budget, createdby, createdon, lastmodified, proposaltypeid, statusid, organizationid, checksum, version) VALUES ('Renovación del Museo', 'Proyecto de renovación del Museo de San José.', 'Contenido detallado del proyecto.', 50000000.00, 1, GETDATE(), GETDATE(), 1, 3, 1, 0x00, 1)

-- Project monitoring
INSERT INTO PV_ProjectMonitoring (proposalid, reportedby, reportdate, reporttypeId, description, evidence, statusid) VALUES (7, 2, GETDATE(), 1, 'Todo bien', 'Aprobado', 3);

-- Financial reports
INSERT INTO PV_FinancialReports (proposalid, reportperiod, totalrevenue, totalexpenses, netprofit, availablefordividends, submitteddate) VALUES (7, '2025-Q1', 1000000, 500000, 500000, 200000, GETDATE());

-- Para esa propuesta debe tener su execution plan
DECLARE @proposalid INT
DECLARE @valorTotal DECIMAL(18,2)
DECLARE @userid INT

SET @proposalid = (SELECT proposalid FROM PV_Proposals WHERE title = 'Renovación del Museo')
SET @valorTotal = (SELECT budget FROM PV_Proposals WHERE proposalid = @proposalid)
SET @userid = 1

DECLARE @executionplanid INT
SELECT @executionplanid = executionplanid FROM PV_ExecutionPlans WHERE proposalid = @proposalid
IF @executionplanid IS NULL
BEGIN
    INSERT INTO PV_ExecutionPlans (proposalid, totalbudget, expectedStartdate, expectedenddate, createddate, expectedDurationInMonths)
    VALUES (
        @proposalid,
        @valorTotal,
        GETDATE(),
        DATEADD(MONTH, 4, GETDATE()),
        GETDATE(),
        4
    )
    SET @executionplanid = SCOPE_IDENTITY()
END

-- Crear steptype de nombre fiscalización de propuesta
DECLARE @steptypeid INT
SELECT @steptypeid = executionStepTypeId FROM PV_executionStepType WHERE name = CONCAT('Fiscalización de propuesta ', @proposalid)
IF @steptypeid IS NULL
BEGIN
    INSERT INTO PV_executionStepType (name)
    VALUES (CONCAT('Fiscalización de propuesta ', @proposalid))
    SET @steptypeid = SCOPE_IDENTITY()
END

-- Crear voting status 'Pending' si no existe
DECLARE @pendingstatusid INT
SELECT @pendingstatusid = statusid FROM PV_VotingStatus WHERE name = 'Pending'
IF @pendingstatusid IS NULL
BEGIN
    INSERT INTO PV_VotingStatus (name, description)
    VALUES ('Pending', 'Pendiente de revisión')
    SET @pendingstatusid = SCOPE_IDENTITY()
END

-- Crear 4 votaciones y execution plan steps para los 4 tramos
DECLARE @j INT = 1
WHILE @j <= 4
BEGIN
    -- Crear votación
    DECLARE @vote_checksum VARBINARY(256)
    SET @vote_checksum = HASHBYTES('SHA2_256', CONCAT('voto', '-', @j))

    INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeid, allowWeightedVotes, requiresAllVoters, notificationmethodid, userid, configureddate, statusid, publicVoting, checksum)
    VALUES (
        @proposalid,
        DATEADD(MONTH, @j, GETDATE()),
        DATEADD(MONTH, @j, GETDATE()),
        1, -- votingtypeid 
        0, 0, null, @userid, GETDATE(), @pendingstatusid, 0, @vote_checksum
    )
    DECLARE @votingconfigid INT = SCOPE_IDENTITY()

    -- Crear execution plan step
    INSERT INTO PV_executionPlanSteps (executionPlanId, stepIndex, description, stepTypeId, estimatedInitDate, estimatedEndDate, durationInMonts, KPI, votingId)
    VALUES (
        @executionplanid,
        @j,
        CONCAT('Fiscalización tramo ', @j, ' de la inversión'),
        @steptypeid,
        DATEADD(MONTH, @j, GETDATE()),
        DATEADD(MONTH, @j + 1, GETDATE()),
        1,
        'Tiempo de finalización ≤ 30 días; Costo ≤ $10,000; Satisfacción ≥ 90%', 
        @votingconfigid
    )
    SET @j = @j + 1
END

-- Crear los investment agreements para la propuesta
DECLARE @agreement_checksum VARBINARY(256)
SET @agreement_checksum = HASHBYTES('SHA2_256', 'Desembolso inicial de la propuesta')
INSERT INTO PV_InvestmentAgreements (
        name, description, signatureDate, porcentageInvested, userId, checksum, proposalid
    ) VALUES (
        'Adelanto',
        'Desembolso del 20% como adelanto',
        GETDATE(),
        20,
        @userid,
        @agreement_checksum,
        @proposalid
    )

-- Insertar los 4 investment agreements para los pagos pendientes del 20%
DECLARE @i INT = 1
WHILE @i <= 4
BEGIN
    DECLARE @tramo_checksum VARBINARY(256)
    SET @tramo_checksum = HASHBYTES('SHA2_256', CONCAT('Tramo', @i))
    INSERT INTO PV_InvestmentAgreements (
        name, description, signatureDate, porcentageInvested, userId, checksum, proposalid
    ) VALUES (
        CONCAT('Tramo ', @i),
        'Desembolso del 20% correspondiente al tramo ' + CAST(@i AS VARCHAR),
        GETDATE(),
        20,
        @userid,
        @tramo_checksum,
        @proposalid
    )
    SET @i = @i + 1
END