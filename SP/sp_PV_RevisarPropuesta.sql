CREATE OR ALTER PROCEDURE [dbo].[revisarPropuesta]
    @proposalid INT,
    @mensaje NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @currentDateTime DATETIME = GETDATE();
    DECLARE @proposalTypeId INT;
    DECLARE @validationResult BIT = 0;
    DECLARE @aiValidationScore DECIMAL(5,2) = 0.0;
    DECLARE @validatorUserId INT = 1;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM PV_Proposals WHERE proposalid = @proposalid)
        BEGIN
            SET @mensaje = 'La propuesta no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Consultar su tipo y extraer sus criterios de validación
        SELECT @proposalTypeId = proposaltypeid
        FROM PV_Proposals 
        WHERE proposalid = @proposalid;

        --Preparar payloads
        DECLARE @aiPayload NVARCHAR(MAX) = CONCAT(
            '{"proposalId":', @proposalid, 
            ',"validationType":"AI_AUTOMATED"',
            ',"timestamp":"', @currentDateTime, '"}');

        -- PASO 3: Procesar documentos con workflows
        DECLARE @docCursor CURSOR;
        DECLARE @currentDocId INT, @currentDocType INT, @workflowId INT;

        SET @docCursor = CURSOR FOR
        SELECT d.documentId, d.documentTypeId
        FROM PV_ProposalDocuments pd
        INNER JOIN PV_Documents d ON pd.documentId = d.documentId
        WHERE pd.proposalid = @proposalid;

        OPEN @docCursor;
        FETCH NEXT FROM @docCursor INTO @currentDocId, @currentDocType;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @workflowId = workflowid 
            FROM PV_Workflows 
            WHERE documenttypeid = @currentDocType AND enabled = 1;

            IF @workflowId IS NULL
                SELECT @workflowId = workflowid FROM PV_Workflows WHERE workflowtype = 'GENERIC' AND enabled = 1;

            -- Simular resultado de AI directamente
            DECLARE @docResult BIT = 1;
            DECLARE @docScore DECIMAL(5,4) = 0.8500;
            DECLARE @docFindings NVARCHAR(MAX) = 'Documento validado correctamente';

            -- Insertar directamente en AI Document Analysis
            INSERT INTO PV_AIDocumentAnalysis (
                documentid, analysisDocTypeId, confidence, result, findings, 
                humanreviewrequired, analysisdate, workflowId, AIConnectionId
            )
            VALUES (
                @currentDocId, @currentDocType, @docScore, 'APPROVED', @docFindings,
                0, @currentDateTime, @workflowId, 1
            );

            -- Actualizar estado del documento
            UPDATE PV_Documents
            SET aivalidationstatus = 'Approved',
                humanvalidationrequired = 0,
                lastvalidated = @currentDateTime
            WHERE documentId = @currentDocId;

            FETCH NEXT FROM @docCursor INTO @currentDocId, @currentDocType;
        END

        CLOSE @docCursor;
        DEALLOCATE @docCursor;

        -- PASO 4: Calcular resultado final
        DECLARE @totalDocs INT, @approvedDocs INT;
        
        SELECT 
            @totalDocs = COUNT(*),
            @approvedDocs = SUM(CASE WHEN result = 'APPROVED' THEN 1 ELSE 0 END),
            @aiValidationScore = AVG(confidence * 100)
        FROM PV_AIDocumentAnalysis ada
        INNER JOIN PV_ProposalDocuments pd ON ada.documentid = pd.documentId
        WHERE pd.proposalid = @proposalid
        AND ada.analysisdate >= DATEADD(MINUTE, -5, @currentDateTime);

        IF @approvedDocs = @totalDocs AND @aiValidationScore >= 75
        BEGIN
            SET @validationResult = 1;
            UPDATE PV_Proposals SET statusid = 2, lastmodified = @currentDateTime WHERE proposalid = @proposalid;
            SET @mensaje = 'Propuesta aprobada y publicada';
        END
        ELSE
        BEGIN
            SET @validationResult = 0;
            UPDATE PV_Proposals SET statusid = 3, lastmodified = @currentDateTime WHERE proposalid = @proposalid;
            SET @mensaje = 'Propuesta requiere revisión';
        END

        INSERT INTO PV_AIProposalAnalysis (
            proposalid, analysistype, confidence, findings, 
            humanreviewrequired, analysisdate, workflowId, AIConnectionId
        )
        VALUES (
            @proposalid, 1, @aiValidationScore/100, 
            CONCAT('Documentos procesados: ', @totalDocs, '. Aprobados: ', @approvedDocs),
            CASE WHEN @validationResult = 0 THEN 1 ELSE 0 END,
            @currentDateTime, @workflowId, 1
        );

        INSERT INTO PV_ProposalValidations (
            proposalid, validatedby, validateddate, validationresult, 
            validationscore, validationmethod, aipayload
        )
        VALUES (
            @proposalid, @validatorUserId, @currentDateTime, @validationResult,
            @aiValidationScore, 'AI_WORKFLOW', @aiPayload
        );

        -- Log simple
        INSERT INTO PV_Logs (description, name, posttime, referenceid1, logtypeid, logsourceid, logseverityid)
        VALUES (
            CONCAT('Propuesta ', @proposalid, ' - Resultado: ', CASE WHEN @validationResult = 1 THEN 'APROBADA' ELSE 'RECHAZADA' END),
            'revisarPropuesta', @currentDateTime, @proposalid, 1, 1, 1
        );

        -- Mostrar resultado
        SELECT 
            @proposalid AS ProposalId,
            @validationResult AS Aprobada,
            @aiValidationScore AS ScoreIA,
            @totalDocs AS TotalDocumentos,
            @approvedDocs AS DocumentosAprobados;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @mensaje = 'ERROR: ' + ERROR_MESSAGE();
    END CATCH
END
