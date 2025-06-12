-- ===============================================
-- SP: revisarPropuesta - PASOS 2, 3, 4 y 5
-- Payload IA → Procesar resultados → Actualizar estado → Registrar validación
-- ===============================================

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
    DECLARE @validatorUserId INT = 1; -- Usuario del sistema que ejecuta validación
    DECLARE @validationDetails NVARCHAR(MAX) = '';
    
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM PV_Proposals WHERE proposalid = @proposalid)
        BEGIN
            SET @mensaje = 'La propuesta especificada no existe';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Obtener el tipo de propuesta
        SELECT @proposalTypeId = proposaltypeid 
        FROM PV_Proposals 
        WHERE proposalid = @proposalid;

        -- Consultar tipo de propuesta con sus configuraciones
        SELECT 
            pt.proposaltypeid,
            pt.name,
            pt.description,
            pt.requiresgovernmentapproval,
            pt.requiresvalidatorapproval,
            pt.validatorcount
        FROM PV_ProposalTypes pt
        WHERE pt.proposaltypeid = @proposalTypeId;

        -- Extraer reglas de validación para este tipo
        SELECT 
            vr.validationruleid,
            vr.proposaltypeid,
            vr.fieldname,
            vr.ruletype,
            vr.rulevalue,
            vr.errormessage
        FROM PV_ValidationRules vr
        WHERE vr.proposaltypeid = @proposalTypeId
        ORDER BY vr.fieldname, vr.validationruleid;

        -- PASO 2: Preparar payload para IA/LLM
        DECLARE @aiPayload NVARCHAR(MAX);
        SELECT @aiPayload = CONCAT(
            '{"proposalId":', @proposalid, ',',
            '"title":"', REPLACE(p.title, '"', '\"'), '",',
            '"description":"', REPLACE(LEFT(p.description, 500), '"', '\"'), '",',
            '"budget":', p.budget, ',',
            '"proposalType":"', REPLACE(pt.name, '"', '\"'), '",',
            '"validationRules":[',
            STUFF((
                SELECT ',' + CONCAT('{"field":"', vr.fieldname, '","rule":"', vr.ruletype, '","value":"', vr.rulevalue, '"}')
                FROM PV_ValidationRules vr 
                WHERE vr.proposaltypeid = @proposalTypeId
                FOR XML PATH('')
            ), 1, 1, ''),
            '],',
            '"documentsCount":', COUNT(DISTINCT pd.documentId), ',',
            '"requestTimestamp":"', @currentDateTime, '"}')
        FROM PV_Proposals p
        INNER JOIN PV_ProposalTypes pt ON p.proposaltypeid = pt.proposaltypeid
        LEFT JOIN PV_ProposalDocuments pd ON p.proposalid = pd.proposalid
        WHERE p.proposalid = @proposalid
        GROUP BY p.proposalid, p.title, p.description, p.budget, pt.name;

        SELECT @aiPayload AS PayloadParaIA;

        -- PASO 3: Simular procesamiento de resultados de IA/LLM
        -- (En producción aquí se haría la llamada real a la API de IA)
        DECLARE @aiResponse NVARCHAR(MAX) = '{"validationScore":85.5,"passed":true,"details":"Propuesta cumple criterios básicos","confidence":0.85}';
        
        -- Procesar respuesta simulada de IA
        IF CHARINDEX('"passed":true', @aiResponse) > 0
        BEGIN
            SET @validationResult = 1;
            SET @aiValidationScore = 85.5; -- Extraído del JSON simulado
            SET @validationDetails = 'Validación IA exitosa: Propuesta cumple criterios básicos';
        END
        ELSE
        BEGIN
            SET @validationResult = 0;
            SET @validationDetails = 'Validación IA fallida: Propuesta no cumple criterios';
        END

        SELECT 
            @validationResult AS ValidationPassed,
            @aiValidationScore AS AIScore,
            @validationDetails AS ValidationDetails,
            @aiResponse AS AIResponse;

        -- PASO 4: Si cumple requisitos, actualizar estado a publicada
        IF @validationResult = 1 AND @aiValidationScore >= 75.0
        BEGIN
            UPDATE PV_Proposals
            SET statusid = 2, -- 2 = Publicada/Aprobada
                lastmodified = @currentDateTime
            WHERE proposalid = @proposalid;

            -- Actualizar documentos a validados
            UPDATE d
            SET aivalidationstatus = 'Approved',
                humanvalidationrequired = 0
            FROM PV_Documents d
            INNER JOIN PV_ProposalDocuments pd ON d.documentId = pd.documentId
            WHERE pd.proposalid = @proposalid;

            SET @mensaje = 'Propuesta validada y publicada exitosamente';
        END
        ELSE
        BEGIN
            UPDATE PV_Proposals
            SET statusid = 3 -- 3 = Rechazada/Requiere revisión
            WHERE proposalid = @proposalid;

            SET @mensaje = 'Propuesta requiere revisión adicional';
        END

        -- PASO 5: Registrar validación completa
        INSERT INTO PV_ProposalValidations (
            proposalid,
            validatedby,
            validateddate,
            validationresult,
            validationscore,
            validationdetails,
            validationmethod,
            aipayload,
            airesponse
        )
        VALUES (
            @proposalid,
            @validatorUserId,
            @currentDateTime,
            @validationResult,
            @aiValidationScore,
            @validationDetails,
            'AI_LLM_Validation',
            @aiPayload,
            @aiResponse
        );

        -- Registrar en logs del sistema
        INSERT INTO PV_Logs (
            description,
            name,
            posttime,
            computer,
            trace,
            referenceid1,
            referenceid2,
            checksum,
            logtypeid,
            logsourceid,
            logseverityid
        )
        VALUES (
            CONCAT('Validación AI completada. Resultado: ', 
                   CASE WHEN @validationResult = 1 THEN 'APROBADA' ELSE 'RECHAZADA' END,
                   '. Score: ', @aiValidationScore),
            'revisarPropuesta_AIValidation',
            @currentDateTime,
            HOST_NAME(),
            CONCAT('ProposalID:', @proposalid, '|Validator:', @validatorUserId, '|Score:', @aiValidationScore),
            @proposalid,
            @validatorUserId,
            HASHBYTES('SHA2_256', CONCAT(@proposalid, @validationResult, @currentDateTime)),
            1, -- Info
            1, -- Sistema
            CASE WHEN @validationResult = 1 THEN 1 ELSE 2 END -- Success/Warning
        );

        -- Mostrar resumen final
        SELECT 
            p.proposalid,
            p.title,
            p.statusid AS EstadoActual,
            @validationResult AS ValidacionExitosa,
            @aiValidationScore AS PuntajeIA,
            @validationDetails AS DetallesValidacion,
            @currentDateTime AS FechaValidacion,
            @validatorUserId AS ValidadoPor
        FROM PV_Proposals p
        WHERE p.proposalid = @proposalid;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @mensaje = 'ERROR: ' + ERROR_MESSAGE();
        
        -- Log del error
        INSERT INTO PV_Logs (
            description, 
            name, 
            posttime, 
            computer, 
            trace, 
            referenceid1, 
            referenceid2,
            checksum, 
            logtypeid, 
            logsourceid, 
            logseverityid
        )
        VALUES (
            'Error en revisarPropuesta: ' + ERROR_MESSAGE(),
            'revisarPropuesta_ERROR',
            @currentDateTime,
            HOST_NAME(),
            ERROR_PROCEDURE(),
            @proposalid,
            0,
            HASHBYTES('SHA2_256', ERROR_MESSAGE()),
            3,      
            1,        
            3       
        );
    END CATCH
END