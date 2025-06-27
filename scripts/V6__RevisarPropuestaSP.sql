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
    DECLARE @docScore DECIMAL(10,4) = 1.0;
    DECLARE @i INT = 1;
    DECLARE @allDocsApproved BIT;
    DECLARE @proposalScore DECIMAL(10,4) = 1.0;
    
    -- Variables para IDs de log (obtener dinámicamente)
    DECLARE @logtypeid INT = (SELECT TOP 1 logtypeid FROM PV_LogTypes WHERE name = 'System'); 
    DECLARE @logsourceid INT = (SELECT TOP 1 logsourceid FROM PV_LogSource WHERE name = 'StoredProcedure'); 
    DECLARE @logseverityid INT = (SELECT TOP 1 logseverityid FROM PV_LogSeverity WHERE name = 'Info');
    
    -- Fallbacks en caso de que no existan los datos
    SET @logtypeid = ISNULL(@logtypeid, 1);
    SET @logsourceid = ISNULL(@logsourceid, 1);
    SET @logseverityid = ISNULL(@logseverityid, 1);
    
    DECLARE @AIConnectionId INT = 1; 

    DECLARE @reviewerId INT;
    DECLARE @validationFields NVARCHAR(MAX);

    DECLARE @workflowParamsProp NVARCHAR(MAX);
    DECLARE @workflowParamsDoc NVARCHAR(MAX);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que existe la propuesta
        IF NOT EXISTS (SELECT 1 FROM PV_Proposals WHERE proposalid = @proposalid)
        BEGIN
            SET @mensaje = 'La propuesta no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- BUSCAR UN REVIEWER CON ROLE ID 2
        SELECT TOP 1 @reviewerId = ur.userid
        FROM PV_UserRoles ur
        INNER JOIN PV_Users u ON ur.userid = u.userid
        WHERE ur.roleid = 2 
            AND ur.enabled = 1 
            AND ur.deleted = 0
        ORDER BY ur.userid;

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

            -- OBTENER Y LLENAR DINÁMICAMENTE LOS PARAMS DEL WORKFLOW DE DOCUMENTOS
            SELECT @workflowParamsDoc = params FROM PV_Workflows WHERE workflowId = @workflowIdDocuments;
            
            SET @aiPayloadDocuments = @workflowParamsDoc;
            SET @aiPayloadDocuments = REPLACE(@aiPayloadDocuments, '{{documentId}}', CAST(@currentDocId AS NVARCHAR));
            SET @aiPayloadDocuments = REPLACE(@aiPayloadDocuments, '{{documentType}}', CAST(@currentDocType AS NVARCHAR));
            SET @aiPayloadDocuments = REPLACE(@aiPayloadDocuments, '{{mediaFileId}}', CAST(@currentMediaFileId AS NVARCHAR));
            SET @aiPayloadDocuments = REPLACE(@aiPayloadDocuments, '{{proposalId}}', CAST(@proposalid AS NVARCHAR));
            SET @aiPayloadDocuments = REPLACE(@aiPayloadDocuments, '{{timestamp}}', @currentDateTime);

            SET @proposalTypeId = (SELECT proposaltypeid FROM PV_Proposals WHERE proposalid = @proposalid);

			SELECT @validationFields = STRING_AGG(CONCAT('"', fieldname, '"'), ',')
			FROM PV_ValidationRules 
			WHERE proposaltypeid = @proposalTypeId;
            
            INSERT INTO PV_Logs (
                description,
                name,
                posttime,
                computer,
                trace,
                referenceid1,
                referenceid2,
                value1,                  
                value2,
                checksum,
                logtypeid,
                logsourceid,
                logseverityid
            )
            VALUES (
                CONCAT('EJECUTANDO WORKFLOW - WorkflowID:', @workflowIdDocuments, 
                    ' | DocumentID:', @currentDocId),
                'workflow_execution_document',
                @currentDateTime,
                @@SERVERNAME,                   
                'revisarPropuesta',              
                @workflowIdDocuments,            
                @currentDocId,                   
                @aiPayloadDocuments,                         
                null,                            
                CHECKSUM(@currentDocId, @workflowIdDocuments), 
                @logtypeid,
                @logsourceid,
                @logseverityid
            );

            -- Simulación siempre aprobada
            IF @docScore = 1.0
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
                extracteddata,
                flags,
                humanreviewrequired,
                reviewerid,
                reviewdate,
                reviewcomments,
                finalresult,
                analysisdate,
                workflowId,
                AIConnectionId
            )
            VALUES (
                @currentDocId,
                1,
                @docScore,
                'APPROVED', 
                CONCAT('WORKFLOW EJECUTADO - WorkflowID:', @workflowIdDocuments, ' - Documento aprobado automáticamente'),
                CONCAT('{"mediaFileId":', @currentMediaFileId, ',"Documento procesado exitosamente","metadata":{"size":"valid","format":"approved"}}'), 
                'AUTO_APPROVED,WORKFLOW_PROCESSED,AI_VALIDATED',  
                1, 
                @reviewerId,                
                @currentDateTime,                      
                'Everything looks good',                 
                'APPROVED',                 
                @currentDateTime,
                @workflowIdDocuments,
                @AIConnectionId
            );

            -- Actualizar estado del documento
            UPDATE PV_Documents
            SET aivalidationstatus = 'Approved',
                aivalidationresult = 'Everything looks good'
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
        WHERE workflowTypeId = 3

        -- OBTENER Y LLENAR DINÁMICAMENTE LOS PARAMS DEL WORKFLOW DE PROPUESTA
        SELECT @workflowParamsProp = params FROM PV_Workflows WHERE workflowId = @workflowIdProposal;
        
        SET @aiPayloadProposal = @workflowParamsProp;
        SET @aiPayloadProposal = REPLACE(@aiPayloadProposal, '{{proposalId}}', CAST(@proposalid AS NVARCHAR));
        SET @aiPayloadProposal = REPLACE(@aiPayloadProposal, '{{proposalTypeId}}', CAST(@proposalTypeId AS NVARCHAR));
        SET @aiPayloadProposal = REPLACE(@aiPayloadProposal, '{{title}}', @title);
        SET @aiPayloadProposal = REPLACE(@aiPayloadProposal, '{{description}}', @description);
        SET @aiPayloadProposal = REPLACE(@aiPayloadProposal, '{{budget}}', CAST(@budget AS NVARCHAR));
        SET @aiPayloadProposal = REPLACE(@aiPayloadProposal, '{{timestamp}}', @currentDateTime);

        INSERT INTO PV_Logs (
            description,
            name,
            posttime,
            computer,
            trace,
            referenceid1,
            referenceid2,
            value1,                 
            value2,
            checksum,
            logtypeid,
            logsourceid,
            logseverityid
        )
        VALUES (
            CONCAT('EJECUTANDO WORKFLOW PROPUESTA - WorkflowID:', @workflowIdProposal,
                ' | ProposalID:', @proposalid),
            'workflow_execution_proposal',
            @currentDateTime,
            @@SERVERNAME,                    
            'revisarPropuesta',              
            @workflowIdProposal,             
            @proposalid,                     
            @workflowParamsProp,                   
            @validationFields,                         
            CHECKSUM(@proposalid, @workflowIdProposal), 
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
            reviewerid,
            reviewdate,
            reviewcomments,
            analysisdate,
            workflowId,
            AIConnectionId
        )
        VALUES (
            @proposalid,
            1, 
            @proposalScore,
            CONCAT('WORKFLOW EJECUTADO - WorkflowID:', @workflowIdProposal),
            'Propuesta lista para publicación - Todos los criterios cumplidos exitosamente',
            'Sin factores de riesgo identificados',
            'Cumple con todos los requisitos de compliance',
            CONCAT('Presupuesto: $', @budget, ' - Aprobado'),
            'Análisis de mercado: Propuesta viable',
            1,
            @reviewerId,
            @currentDateTime,
            'Revisión completa - Todo en orden',
            @currentDateTime,
            @workflowIdProposal,
            @AIConnectionId
        );

        IF @proposalScore = 1.0 AND @allDocsApproved = 1
        BEGIN 
            UPDATE PV_Proposals 
            SET statusid = 3, 
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
            computer,
            trace,
            referenceid1,
            referenceid2,
            value1,                  
            value2,    
            checksum,              
            logtypeid,
            logsourceid,
            logseverityid
        )
        VALUES (
            CONCAT('WORKFLOW COMPLETADO - PropuestaID:', @proposalid, 
                ' | WorkflowPropuesta:', @workflowIdProposal),  
            'workflow_proposal_complete',                              
            @currentDateTime,                                            
            @@SERVERNAME,                                                
            'revisarPropuesta',                                               
            @workflowIdProposal,                                       
            @proposalid,                                                 
            @totalDocs,                                                       
            @approvedDocs,                                               
            CHECKSUM(@proposalid, @totalDocs, @approvedDocs),          
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
            computer,
            trace,
            referenceid1, 
            referenceid2,
            value1,                  
            value2, 
            checksum,                 
            logtypeid, 
            logsourceid, 
            logseverityid
        )
        VALUES (
            'Error en workflow completo ',
            'workflow_proposal_ERROR',
            @currentDateTime,
            @@SERVERNAME,                  
            ERROR_PROCEDURE(),  
            @proposalid,
            NULL,
            ERROR_NUMBER(),         
            ERROR_LINE(),    
            CHECKSUM(ERROR_NUMBER(), ERROR_LINE()),        
            3, 
            2,
            3
        );
    END CATCH
END
GO

PRINT 'Procedimiento revisarPropuesta creado exitosamente.';
