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
    DECLARE @workflowId INT = 1; -- ID del workflow a utilizar
    DECLARE @aiPayloadDocuments NVARCHAR(MAX);
    DECLARE @aiPayloadProposal NVARCHAR(MAX);
    DECLARE @title NVARCHAR(255);
    DECLARE @description NVARCHAR(MAX);
    DECLARE @budget DECIMAL(15,2);
    DECLARE @currentDocId INT;
    DECLARE @currentDocType INT;
    DECLARE @currentMediaFileId INT;
    DECLARE @totalDocs INT = 0;
    DECLARE @approvedDocs INT = 0;
    DECLARE @docScore DECIMAL(10,4)=100.0;
    DECLARE @i INT = 1;
    DECLARE @allDocsApproved BIT;
    DECLARE @proposalScore DECIMAL(10,4)=100.0;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que existe la propuesta
        IF NOT EXISTS (SELECT 1 FROM PV_Proposals WHERE proposalid = @proposalid)
        BEGIN
            SET @mensaje = 'La propuesta no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        SELECT 
            @proposalTypeId = proposaltypeid,
            @title = title,
            @description = description,
            @budget = budget
        FROM PV_Proposals 
        WHERE proposalid = @proposalid;

        -- Preparar payload para validación de propuesta
        SET @aiPayloadProposal = CONCAT(
            '{"proposalValidation":{',
            '"proposalId":', @proposalid, ',',
            '"proposalTypeId":', @proposalTypeId, ',',
            '"workflowId":', @workflowId, ',',
            '"title":"', REPLACE(@title, '"', '\"'), '",',
            '"description":"', REPLACE(LEFT(@description, 200), '"', '\"'), '",',
            '"budget":', @budget, ',',
            '"titleLength":', LEN(@title), ',',
            '"descriptionLength":', LEN(@description), ',',
            '"timestamp":"', @currentDateTime, '"',
            '}}');

        SET @totalDocs = (SELECT COUNT(*) 
                    FROM PV_ProposalDocuments 
                    WHERE proposalid = @proposalid);

        WHILE @i <= @totalDocs
        BEGIN
            -- Obtener el documento en la posición @i CON MEDIAFILEID
            SELECT 
                @currentDocId = d.documentId,
                @currentDocType = d.documentTypeId,
                @currentMediaFileId = d.mediafileId
            FROM (
                SELECT 
                    d.documentId, 
                    d.documentTypeId,
                    d.mediafileId,
                    ROW_NUMBER() OVER (ORDER BY d.documentId) AS RowNum
                FROM PV_ProposalDocuments pd
                INNER JOIN PV_Documents d ON pd.documentId = d.documentId
                WHERE pd.proposalid = @proposalid
            ) d
            WHERE d.RowNum = @i;

            -- Crear payload específico para este documento INCLUYENDO MEDIAFILEID
            SET @aiPayloadDocuments = CONCAT(
                '{"documentValidation":{',
                '"documentId":', @currentDocId, ',',
                '"documentType":', @currentDocType, ',',
                '"mediaFileId":', @currentMediaFileId, ',',
                '"proposalId":', @proposalid, ',',
                '"workflowId":', @workflowId, ',',
                '"iteration":', @i, ',',
                '"timestamp":"', @currentDateTime, '"',
                '}}');

            --Simulacion siempre aprobada
            IF @docScore=100.0
            BEGIN
                SET @approvedDocs = @approvedDocs + 1;
            END

            -- Insertar resultado en PV_AIDocumentAnalysis CON PAYLOAD EN EXTRACTEDDATA
            INSERT INTO PV_AIDocumentAnalysis (
                documentid,
                analysisDocTypeId,
                confidence,
                result,
                findings,
                extracteddata,
                humanreviewrequired,
                analysisdate,
                workflowId,
                AIConnectionId
            )
            VALUES (
                @currentDocId,
                @currentDocType,
                @docScore,
                'APPROVED', 
                CONCAT('WORKFLOW_DOC_ANALYSIS: Perfect', ''),
                @aiPayloadDocuments, 
                0, -- CORREGIDO: 5 no es válido para BIT
                @currentDateTime,
                @workflowId,
                1
            );

            -- Actualizar estado del documento
            UPDATE PV_Documents
            SET aivalidationstatus = 'Approved'
            WHERE documentId = @currentDocId;

            -- Log por documento - CORREGIDO EL INSERT
            INSERT INTO PV_Logs (
                description,
                name,
                posttime,
                referenceid1,
                referenceid2,
                logtypeid,
                logsourceid,
                logseverityid
            )
            VALUES (
                CONCAT('DOCUMENTO PROCESADO [', @i, '] - ID:', @currentDocId),
                'workflow_document_processing',
                @currentDateTime,
                @currentDocId,
                @proposalid,
                1, -- Info
                2, -- Workflow
                1  -- Success
            );

            -- Incrementar contador
            SET @i = @i + 1;
        END

        -- PASO 2: Calcular resultado final de documentos
        IF @totalDocs = (@i - 1) -- CORREGIDO: usar @i-1 porque se incrementó al final
        BEGIN
            SET @allDocsApproved = 1; 
        END
        ELSE
        BEGIN
            SET @allDocsApproved = 0; 
        END

        -- Insertar resultado completo en PV_AIProposalAnalysis CON PAYLOAD
        INSERT INTO PV_AIProposalAnalysis (
            proposalid,
            analysistype,
            confidence,
            findings,
            recommendations,
            humanreviewrequired,
            analysisdate,
            workflowId,
            AIConnectionId
        )
        VALUES (
            @proposalid,
            1, 
            @proposalScore,
}           @aiPayloadProposal, -- PAYLOAD DE PROPUESTA GUARDADO AQUÍ
            'Propuesta lista para publicación - Todos los criterios cumplidos exitosamente',
            0,
            @currentDateTime,
            @workflowId,
            1
        );

        IF @proposalScore = 100.0 AND @allDocsApproved = 1
        BEGIN 
            UPDATE PV_Proposals 
            SET statusid = 2, -- Publicada
                lastmodified = @currentDateTime 
            WHERE proposalid = @proposalid;

            SET @mensaje = 'Propuesta aprobada y publicada exitosamente';
        END
        ELSE
        BEGIN
            SET @mensaje = 'Propuesta requiere revisión';
        END -- AGREGADO END FALTANTE

        -- Log de resultado final
        INSERT INTO PV_Logs (
            description,
            name,
            posttime,
            referenceid1,
            referenceid2,
            logtypeid,
            logsourceid,
            logseverityid
        )
        VALUES (
            CONCAT('WORKFLOW COMPLETADO - Propuesta:', @proposalid, 
                   ' | Resultado: APROBADA'),
            'workflow_proposal_complete',
            @currentDateTime,
            @proposalid,
            @workflowId,
            1, -- Info
            2, -- Workflow
            1  -- Success
        );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @mensaje = 'ERROR: ' + ERROR_MESSAGE();
        
        INSERT INTO PV_Logs (description, name, posttime, referenceid1, logtypeid, logsourceid, logseverityid)
        VALUES (
            'Error en workflow completo: ' + ERROR_MESSAGE(),
            'workflow_proposal_ERROR',
            @currentDateTime,
            @proposalid,
            3, 
            2,
            3
        );
    END CATCH
END

-- PRUEBA DEL WORKFLOW COMPLETO
DECLARE @resultado NVARCHAR(200);
EXEC revisarPropuesta @proposalid = 1, @mensaje = @resultado OUTPUT;
SELECT @resultado AS ResultadoWorkflow;