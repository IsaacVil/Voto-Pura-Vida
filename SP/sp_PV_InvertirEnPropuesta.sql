CREATE PROCEDURE [dbo].[PV_InvertirEnPropuesta]
    @proposalid INT,
    @userid INT,
    @amount DECIMAL(18,2),
    @investmentdate DATETIME,
    @paymentmethodid INT,
    @availablemethodid INT,
    @currencyid INT,
    @exchangerateid INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

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
        IF @amount <= 0
        BEGIN
            RAISERROR('El monto debe ser mayor a cero.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @valorTotal DECIMAL(18,2);
        SELECT @valorTotal = budget FROM PV_Proposals WHERE proposalid = @proposalid;
        IF @valorTotal IS NULL OR @valorTotal = 0
        BEGIN
            RAISERROR('El valor total del proyecto no es válido.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @totalInvertido DECIMAL(18,2);
        SELECT @totalInvertido = ISNULL(SUM(amount),0) FROM PV_Investments WHERE proposalid = @proposalid;
        IF (@totalInvertido + @amount) > @valorTotal
        BEGIN
            RAISERROR('La inversión excede el monto permitido.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- calcular el porcentaje accionario a entregar basado en monto y valor total
        DECLARE @porcentajeAccionario DECIMAL(10,4);
        SET @porcentajeAccionario = (@amount / @valorTotal) * 100;
       

        -- Insertar la inversión
        
        DECLARE @investmenthash VARBINARY(256);
        SET @investmenthash = HASHBYTES('SHA2_256', CONCAT(@proposalid, '-', @userid, '-', @amount, '-', CONVERT(VARCHAR(30), @investmentdate, 126)));

        
        DECLARE @investment_checksum VARBINARY(256);
        SET @investment_checksum = HASHBYTES('SHA2_256', CONCAT(@proposalid, '-', @userid, '-', @amount, '-', @investmenthash));

      
        INSERT INTO PV_Investments (proposalid, amount, equitypercentage, investmentdate, investmenthash, checksum, userid, organizationid)
        VALUES (@proposalid, @amount, @porcentajeAccionario, @investmentdate, @investmenthash, @investment_checksum, @userid, null);
        DECLARE @investmentid INT = SCOPE_IDENTITY();

        -- Vamos a dar el 20% del monto como adelanto
        DECLARE @adelanto DECIMAL(18,2) = @amount * 0.20;

       
        DECLARE @payment_checksum VARBINARY(256);
        SET @payment_checksum = HASHBYTES('SHA2_256', CONCAT(@adelanto, '-', @userid, '-', @investmentid, '-', @investmentdate));

        
        INSERT INTO PV_Payment (
            amount, actualamount, result, reference, auth, chargetoken, description, date, checksum, moduleid, paymentmethodid, availablemethodid, userid
        ) VALUES (
            @adelanto, @adelanto, 1, 'INV-REF', 'AUTH-OK', 0x00, 'Pago inversión', @investmentdate, @payment_checksum, 1, @paymentmethodid, @availablemethodid, @userid
        );
        DECLARE @paymentid INT = SCOPE_IDENTITY();

    
        DECLARE @transaction_checksum VARBINARY(256);
        SET @transaction_checksum = HASHBYTES('SHA2_256', CONCAT(@adelanto, '-', @userid, '-', @proposalid, '-', @paymentid, '-', @investmentdate));

        
        INSERT INTO PV_Transactions (
            amount, description, date, posttime, reference1, reference2, value1, value2, processmanagerid, convertedamount, checksum, transtypeid, transsubtypeid, paymentid, currencyid, exchangerateid
        ) VALUES (
            @adelanto, 'Transacción inversión', @investmentdate, GETDATE(), @userid, @proposalid, 'inversor', 'propuesta', 1, @adelanto, @transaction_checksum, 1, 1, @paymentid, @currencyid, @exchangerateid
        );
        DECLARE @transactionid INT = SCOPE_IDENTITY();

        -- Plan de entrega de fondos
        -- el adelanto que es el step 0
        DECLARE @agreement_checksum VARBINARY(256);
        SET @agreement_checksum = HASHBYTES('SHA2_256', CONCAT('Desembolso inicial', '-', @investmentid, '-', @userid, '-', @adelanto));
        INSERT INTO PV_InvestmentAgreements (
                name, description, signatureDate, porcentageInvested, investmentId, userId, checksum
            ) VALUES (
                'Desembolso inicial',
                'Desembolso del 20% como adelanto',
                GETDATE(),
                20,
                @investmentid,
                @userid,
                @agreement_checksum
            );
        DECLARE @firstAgreement INT = SCOPE_IDENTITY();

        -- Insertar los 4 investment agreements para los pagos pendientes del 20%
        DECLARE @i INT = 1;
        WHILE @i <= 4
        BEGIN
            DECLARE @tramo_checksum VARBINARY(256);
            SET @tramo_checksum = HASHBYTES('SHA2_256', CONCAT('Tramo', @i, '-', @investmentid, '-', @userid, '-', @adelanto));
            INSERT INTO PV_InvestmentAgreements (
                name, description, signatureDate, porcentageInvested, investmentId, userId, checksum
            ) VALUES (
                CONCAT('Tramo ', @i),
                'Desembolso del 20% correspondiente al tramo ' + CAST(@i AS VARCHAR),
                GETDATE(),
                20,
                @investmentid,
                @userid,
                @tramo_checksum
            );
            SET @i = @i + 1;
        END

        -- Poner que el primero se paga inmediatamente
        DECLARE @restante DECIMAL(18,2) = @amount - @adelanto;

        INSERT INTO PV_InvestmentSteps (
            transactionId, stepIndex, description, amount, remainingAmount, estimatedDate, investmentAgreementId
        ) VALUES (
            @transactionid, 0, 'Pago inmediato del 20% inicial', @adelanto, @restante, @investmentdate, @firstAgreement
        );

        -- Crear Execution Plan para la propuesta si no existe
        DECLARE @executionplanid INT;
        SELECT @executionplanid = executionplanid FROM PV_ExecutionPlans WHERE proposalid = @proposalid;
        IF @executionplanid IS NULL
        BEGIN
            INSERT INTO PV_ExecutionPlans (proposalid, totalbudget, expectedStartdate, expectedenddate, createddate, expectedDurationInMonths)
            VALUES (
                @proposalid,
                @valorTotal,
                @investmentdate,
                DATEADD(MONTH, 4, @investmentdate),
                GETDATE(),
                4
            );
            SET @executionplanid = SCOPE_IDENTITY();
        END

        -- Crear steptype de nombre fiscalización de propuesta
        DECLARE @steptypeid INT;
        SELECT @steptypeid = executionStepTypeId FROM PV_executionStepType WHERE name = CONCAT('Fiscalización de propuesta ', @proposalid);
        IF @steptypeid IS NULL
        BEGIN
            INSERT INTO PV_executionStepType (name)
            VALUES (CONCAT('Fiscalización de propuesta ', @proposalid));
            SET @steptypeid = SCOPE_IDENTITY();
        END

        -- Crear voting status 'Pending' si no existe
        DECLARE @pendingstatusid INT;
        SELECT @pendingstatusid = statusid FROM PV_VotingStatus WHERE name = 'Pending';
        IF @pendingstatusid IS NULL
        BEGIN
            INSERT INTO PV_VotingStatus (name, description)
            VALUES ('Pending', 'Pendiente de revisión');
            SET @pendingstatusid = SCOPE_IDENTITY();
        END

        -- Crear 4 votaciones y execution plan steps para los 4 tramos
        DECLARE @j INT = 1;
        WHILE @j <= 4
        BEGIN
            -- Crear votación

            DECLARE @vote_checksum VARBINARY(256);
            SET @vote_checksum = HASHBYTES('SHA2_256', CONCAT(@investmentId, '-', @j));

            INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeid, allowWeightedVotes, requiresAllVoters, notificationmethodid, userid, configureddate, statusid, publicVoting, checksum)
            VALUES (
                @proposalid,
                DATEADD(MONTH, @j, @investmentdate),
                DATEADD(MONTH, @j, @investmentdate),
                1, -- votingtypeid 
                0, 0, null, @userid, GETDATE(), @pendingstatusid, 0, @vote_checksum
            );
            DECLARE @votingconfigid INT = SCOPE_IDENTITY();

            -- Crear execution plan step
            INSERT INTO PV_executionPlanSteps (executionPlanId, stepIndex, description, stepTypeId, estimatedInitDate, estimatedEndDate, durationInMonts, KPI, votingId)
            VALUES (
                @executionplanid,
                @j,
                CONCAT('Fiscalización tramo ', @j, ' de la inversión'),
                @steptypeid,
                DATEADD(MONTH, @j, @investmentdate),
                DATEADD(MONTH, @j + 1, @investmentdate),
                1,
                'Tiempo de finalización ≤ 30 días; Costo ≤ $10,000; Satisfacción ≥ 90%', 
                @votingconfigid
            );
            SET @j = @j + 1;
        END

        

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO


BEGIN
    DECLARE @CurrentDate DATETIME = GETDATE();
    
    EXEC [dbo].[PV_InvertirEnPropuesta] 
        @proposalid = 1,
        @userid = 1,
        @amount = 10000.00,
        @investmentdate = @CurrentDate,
        @paymentmethodid = 1,
        @availablemethodid = 1,
        @currencyid = 1,
        @exchangerateid = 1
END

IF OBJECT_ID('dbo.PV_InvertirEnPropuesta', 'P') IS NOT NULL
    DROP PROCEDURE dbo.PV_InvertirEnPropuesta;
GO


select * from PV_InvestmentAgreements
select * from PV_investmentSteps
select * from PV_executionPlanSteps

use VotoPuraVida
go

