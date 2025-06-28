CREATE PROCEDURE [dbo].[PV_InvertirEnPropuesta]
    @proposalid INT,
    @userid INT,
    @amountInDollars DECIMAL(28,2),
    @investmentdate DATETIME,
    @paymentmethodName NVARCHAR(100),
    @availablemethodName NVARCHAR(100)

AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Buscar IDs/valores a partir de los nombres
        DECLARE @paymentmethodid INT;
        DECLARE @availablePaymentMethods NVARCHAR(MAX);
        SELECT @paymentmethodid = paymentmethodid FROM PV_PaymentMethods WHERE name = @paymentmethodName;
        SELECT @availablePaymentMethods = STRING_AGG(name, ', ') FROM PV_PaymentMethods;
        IF @paymentmethodid IS NULL
        BEGIN
            RAISERROR('Método de pago no encontrado: %s. Métodos disponibles: %s', 16, 1, @paymentmethodName, @availablePaymentMethods);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @availablemethodid INT;
        DECLARE @availableAvailableMethods NVARCHAR(MAX);
        SELECT @availablemethodid = availablemethodid FROM PV_AvailableMethods WHERE name = @availablemethodName AND userid = @userid;
        SELECT @availableAvailableMethods = STRING_AGG(name, ', ') FROM PV_AvailableMethods WHERE userid = @userid;
        IF @availablemethodid IS NULL
        BEGIN
            RAISERROR('Método disponible no encontrado: %s. Métodos disponibles: %s', 16, 1, @availablemethodName, @availableAvailableMethods);
            ROLLBACK TRANSACTION;
            RETURN;
        END


        -- Declarar variables antes de usarlas
        DECLARE @currencyid INT;
        DECLARE @exchangerateid INT;

        -- Siempre asume USD como moneda del inversor
        SELECT TOP 1 @currencyid = currencyid FROM PV_Currency WHERE acronym = 'USD';

        -- Siempre asume CRC como moneda de la propuesta
        DECLARE @proposal_currencyid INT;
        SELECT TOP 1 @proposal_currencyid = currencyid FROM PV_Currency WHERE acronym = 'CRC';

        -- Buscar tasa de cambio de USD a CRC
        SELECT TOP 1 @exchangerateid = exchangeRateid
        FROM PV_ExchangeRate
        WHERE sourceCurrencyid = @currencyid AND destinyCurrencyId = @proposal_currencyid
        ORDER BY startDate DESC;

        -- Si no existe tasa de cambio, error explícito
        IF @exchangerateid IS NULL
        BEGIN
            RAISERROR('No existe tasa de cambio válida entre USD y CRC.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- validar que el proyecto esté aprobado para inversión
        IF NOT EXISTS (
            SELECT 1
            FROM PV_Proposals p
            JOIN PV_ProposalStatus s ON p.statusid = s.statusid
            WHERE p.proposalid = @proposalid AND s.name = 'Aprobada'
        )
        BEGIN
            RAISERROR('La propuesta no está aprobada para inversión.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- verificar identidad del usuario y confirmar su registro en el sistema
        IF NOT EXISTS (
            SELECT 1 FROM PV_Users u
            JOIN PV_UserStatus us ON u.userStatusId = us.userStatusId
            WHERE u.userid = @userid AND us.active = 1 AND us.verified = 1
        )
        BEGIN
            RAISERROR('El usuario no está activo o verificado en el sistema.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- validar el monto transferido, calcular overflow antes de insertar
        IF @amountInDollars <= 0
        BEGIN
            RAISERROR('El monto debe ser mayor a cero.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @valorTotal DECIMAL(28,2);
        SELECT @valorTotal = budget FROM PV_Proposals WHERE proposalid = @proposalid;
        IF @valorTotal IS NULL OR @valorTotal = 0
        BEGIN
            RAISERROR('El valor total del proyecto no es válido.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @totalInvertido DECIMAL(28,2);
        SELECT @totalInvertido = ISNULL(SUM(amount),0) FROM PV_Investments WHERE proposalid = @proposalid;
        IF (@totalInvertido + @amountInDollars) > @valorTotal
        BEGIN
            RAISERROR('La inversión excede el monto permitido.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- calcular el porcentaje accionario a entregar basado en monto y valor total
        DECLARE @porcentajeAccionario DECIMAL(12,8);
        SET @porcentajeAccionario = (@amountInDollars / @valorTotal) * (SELECT percentageRequested FROM PV_Proposals WHERE proposalid = @proposalid);
       

        -- Insertar la inversión
        
        DECLARE @investmenthash VARBINARY(256);
        SET @investmenthash = HASHBYTES('SHA2_256', CONCAT(@proposalid, '-', @userid, '-', @amountInDollars, '-', CONVERT(VARCHAR(30), @investmentdate, 126)));

        
        DECLARE @investment_checksum VARBINARY(256);
        SET @investment_checksum = HASHBYTES('SHA2_256', CONCAT(@proposalid, '-', @userid, '-', @amountInDollars, '-', @investmenthash));

      
        INSERT INTO PV_Investments (proposalid, amount, equitypercentage, investmentdate, investmenthash, checksum, userid)
        VALUES (@proposalid, @amountInDollars, @porcentajeAccionario, @investmentdate, @investmenthash, @investment_checksum, @userid);
        DECLARE @investmentid INT = SCOPE_IDENTITY();

        
        -- Insertar el pago usando los IDs obtenidos
        DECLARE @firstPayment INT;
        DECLARE @firstAgreementId INT;
        DECLARE @porcentageToInvest INT;
        SELECT @porcentageToInvest = porcentageInvested FROM PV_InvestmentAgreements WHERE proposalid = @proposalid AND name = 'Adelanto';
        SELECT @firstAgreementId = agreementId FROM PV_InvestmentAgreements WHERE proposalid = @proposalid AND name = 'Adelanto';
        SET @firstPayment = @porcentageToInvest * @amountInDollars / 100
        DECLARE @restante DECIMAL(28,2) = @amountInDollars - @firstPayment;
        DECLARE @payment_checksum VARBINARY(256);
        SET @payment_checksum = HASHBYTES('SHA2_256', CONCAT(@firstPayment, '-', @userid, '-', @investmentid, '-', @investmentdate));
        INSERT INTO PV_Payment (
            amount, actualamount, result, reference, auth, chargetoken, description, date, checksum, moduleid, paymentmethodid, availablemethodid, userid
        ) VALUES (
            @firstPayment, @firstPayment, 1, 'INV-REF', 'AUTH-OK', 0x00, 'Pago inversión', @investmentdate, @payment_checksum, 1, @paymentmethodid, @availablemethodid, @userid
        );
        DECLARE @paymentid INT = SCOPE_IDENTITY();

        -- Insertar la transacción usando los IDs obtenidos
        DECLARE @transaction_checksum VARBINARY(256);
        SET @transaction_checksum = HASHBYTES('SHA2_256', CONCAT(@firstPayment, '-', @userid, '-', @proposalid, '-', @paymentid, '-', @investmentdate));
        INSERT INTO PV_Transactions (
            amount, description, date, posttime, reference1, reference2, value1, value2, processmanagerid, convertedamount, checksum, transtypeid, transsubtypeid, paymentid, currencyid, exchangerateid
        ) VALUES (
            @firstPayment, 'Transacción inversión', @investmentdate, GETDATE(), @userid, @proposalid, 'inversor', 'propuesta', 1, @firstPayment, @transaction_checksum, 1, 1, @paymentid, @currencyid, @exchangerateid
        );
        DECLARE @transactionid INT = SCOPE_IDENTITY();


        -- busco el primer agreement de la inversión y lo pago como adelanto asumo que el index es 0 ojooo


        INSERT INTO PV_InvestmentSteps (
            transactionId, stepIndex, description, amount, remainingAmount, estimatedDate, investmentAgreementId
        ) VALUES (
            @transactionid, 0, 'Pago inicial', @firstPayment, @restante, @investmentdate, @firstAgreementId
        );

        DECLARE @executionplanid INT;
        SELECT @executionplanid = executionPlanId FROM PV_ExecutionPlans WHERE proposalid = @proposalid;

        -- me fijo que hayan execution plan steps para la propuesta
        DECLARE @executionPlanStepsCount INT;
        SELECT @executionPlanStepsCount = COUNT(*) FROM PV_executionPlanSteps WHERE executionPlanId = @executionplanid;
        IF @executionPlanStepsCount = 0 RAISERROR('No hay execution plan steps para la propuesta.', 16, 1);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO



