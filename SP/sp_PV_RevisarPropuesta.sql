CREATE OR ALTER PROCEDURE [dbo].[revisarPropuesta]
    @proposalid INT,
    @mensaje NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @currentDateTime DATETIME = GETDATE();
    DECLARE @proposalTypeId INT;
    DECLARE @title NVARCHAR(255);
    DECLARE @description NVARCHAR(MAX);
    DECLARE @budget DECIMAL(15,2);
    DECLARE @workflowIdDocuments INT; 
    DECLARE @workflowIdProposal INT; 
    DECLARE @aiPayloadDocuments NVARCHAR(MAX);
    DECLARE @aiPayloadProposal NVARCHAR(MAX);
    DECLARE @currentDocId INT;
    DECLARE @currentDocType INT;
    DECLARE @currentMediaFileId INT;
    DECLARE @totalDocs INT = 0;
    DECLARE @approvedDocs INT = 0;
    DECLARE @docScore DECIMAL(10,4) = 100.0;
    DECLARE @i INT = 1;
    DECLARE @allDocsApproved BIT;
    DECLARE @proposalScore DECIMAL(10,4) = 100.0;
    DECLARE @logtypeid INT = 1; 
    DECLARE @logsourceid INT = 1; 
    DECLARE @logseverityid INT = 1;
    DECLARE @AIConnectionId INT = 1; 

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que existe la propuesta
        IF NOT EXISTS (SELECT 1 FROM PV_Proposals WHERE proposalid = @proposalid)
        BEGIN
            SET @mensaje = 'La propuesta no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        SET @totalDocs = (SELECT COUNT(*) 
                    FROM PV_ProposalDocuments 
                    WHERE proposalid = @proposalid);

        WHILE @i <= @totalDocs
        BEGIN
            -- Obtenemos los documentos de la propuesta
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

            -- BUSCAR EL WORKFLOW EXISTENTE PARA ESTE TIPO DE DOCUMENTO
            SELECT @workflowIdDocuments = workflowId
            FROM PV_DocumentTypes
            WHERE documentTypeId = @currentDocType 



            SET @aiPayloadDocuments = CONCAT(
                '{"documentValidation":{',
                '"documentId":', @currentDocId, ',',
                '"documentType":', @currentDocType, ',',
                '"mediaFileId":', @currentMediaFileId, ',',
                '"proposalId":', @proposalid, ',',
                '"timestamp":"', @currentDateTime, '"',
                '}}'
            );

            INSERT INTO PV_Logs (
                description,
                name,
                posttime,
                referenceid1,
                referenceid2,
                value1,                  
                value2,                  
                logtypeid,
                logsourceid,
                logseverityid
            )
            VALUES (
                CONCAT('EJECUTANDO WORKFLOW - WorkflowID:', @workflowIdDocuments, 
                       ' | DocumentID:', @currentDocId),
                'workflow_execution_document',
                @currentDateTime,
                @workflowIdDocuments,
                @currentDocId,
                @aiPayloadDocuments,            
                null,
                @logtypeid,
                @logsourceid,
                @logseverityid
            );

            -- Simulación siempre aprobada
            IF @docScore = 100.0
            BEGIN
                SET @approvedDocs = @approvedDocs + 1;
            END

            -- Insertar resultado del análisis
            INSERT INTO PV_AIDocumentAnalysis (
                documentid,
                analysisDocTypeId,
                confidence,
                result,
                findings,
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
                CONCAT('WORKFLOW EJECUTADO - WorkflowID:', @workflowIdDocuments, ' - Documento aprobado automáticamente'),
                0, 
                @currentDateTime,
                @workflowIdDocuments,
                @AIConnectionId
            );

            -- Actualizar estado del documento
            UPDATE PV_Documents
            SET aivalidationstatus = 'Approved'
            WHERE documentId = @currentDocId;

            SET @i = @i + 1;
        END

        SET @allDocsApproved = 1; 

        -- Obtener datos de la propuesta
        SELECT 
            @proposalTypeId = proposaltypeid,
            @title = title,
            @description = description,
            @budget = budget
        FROM PV_Proposals 
        WHERE proposalid = @proposalid;

        -- BUSCAR EL WORKFLOW EXISTENTE PARA PROPUESTAS
        SELECT @workflowIdProposal = workflowId
        FROM PV_Workflows 
        WHERE workflowTypeId = 2 



        -- Preparar payload para validación de propuesta
        SET @aiPayloadProposal = CONCAT(
            '{"proposalValidation":{',
            '"proposalId":', @proposalid, ',',
            '"proposalTypeId":', @proposalTypeId, ',',
            '"title":',@title, ',',
            '"description":"', @description, ',',
            '"budget":', @budget, ',',
            '"timestamp":"', @currentDateTime, '"',
            '}}');


        -- REGISTRAR LA EJECUCIÓN DEL WORKFLOW DE PROPUESTA CON VALUE1 Y VALUE2
        INSERT INTO PV_Logs (
            description,
            name,
            posttime,
            referenceid1,
            referenceid2,
            value1,                 
            value2,                 
            logtypeid,
            logsourceid,
            logseverityid
        )
        VALUES (
            CONCAT('EJECUTANDO WORKFLOW PROPUESTA - WorkflowID:', @workflowIdProposal,
                   ' | ProposalID:', @proposalid),
            'workflow_execution_proposal',
            @currentDateTime,
            @workflowIdProposal,
            @proposalid,
            @aiPayloadProposal,     
            @budget,           
            @logtypeid,
            @logsourceid,
            @logseverityid
        );

        -- Insertar resultado completo en PV_AIProposalAnalysis
        INSERT INTO PV_AIProposalAnalysis (
            proposalid,
            analysistype,
            confidence,
            findings,
            recommendations,
            riskfactors,
            complianceissues,
            budgetanalysis,
            marketanalysis,
            humanreviewrequired,
            analysisdate,
            workflowId,
            AIConnectionId
        )
        VALUES (
            @proposalid,
            1, 
            @proposalScore, -- Convertir a decimal 0-1
            CONCAT('WORKFLOW EJECUTADO - WorkflowID:', @workflowIdProposal),
            'Propuesta lista para publicación - Todos los criterios cumplidos exitosamente',
            'Sin factores de riesgo identificados',
            'Cumple con todos los requisitos de compliance',
            CONCAT('Presupuesto: $', @budget, ' - Aprobado'),
            'Análisis de mercado: Propuesta viable',
            0,
            @currentDateTime,
            @workflowIdProposal,
            @AIConnectionId
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
        END 

        -- Log de resultado final CON VALUE1 Y VALUE2
        INSERT INTO PV_Logs (
            description,
            name,
            posttime,
            referenceid1,
            referenceid2,
            value1,                  
            value2,                  
            logtypeid,
            logsourceid,
            logseverityid
        )
        VALUES (
            CONCAT('WORKFLOW COMPLETADO - PropuestaID:', @proposalid, 
                   ' | WorkflowPropuesta:', @workflowIdProposal), 
            @currentDateTime,
            @workflowIdProposal,
            @proposalid,
            @totalDocs,              
            @approvedDocs, 
            @logtypeid,
            @logsourceid,
            @logseverityid       
        );

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @mensaje = 'ERROR: ' + ERROR_MESSAGE();
        
        -- Log de error CON VALUE1 Y VALUE2
        INSERT INTO PV_Logs (
            description, 
            name, 
            posttime, 
            referenceid1, 
            value1,                  
            value2,                  
            logtypeid, 
            logsourceid, 
            logseverityid
        )
        VALUES (
            'Error en workflow completo ',
            'workflow_proposal_ERROR',
            @currentDateTime,
            @proposalid,
            ERROR_NUMBER(),         
            ERROR_LINE(),            
            3, 
            2,
            3
        );
    END CATCH
END

-- PRUEBA 
DECLARE @resultado NVARCHAR(200);
EXEC revisarPropuesta @proposalid = 1, @mensaje = @resultado OUTPUT;
SELECT @resultado AS ResultadoWorkflow;