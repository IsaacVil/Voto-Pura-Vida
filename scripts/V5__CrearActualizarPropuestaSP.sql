CREATE OR ALTER PROCEDURE [dbo].[crearActualizarPropuesta]

--Parametros de proposal
    @proposalid INT, --NULL para crear la propuesta
    @title NVARCHAR(200),
    @description NVARCHAR(MAX),
    @proposalcontent NVARCHAR(MAX),
    @budget DECIMAL(18, 2),
    @percentageRequested DECIMAL(12, 8) = NULL,
    @createdby INT,
    @proposaltypeid INT,
    @organizationid INT,
    @version INT,

--Parametro de mediafiles
    @documentids NVARCHAR(200),
    @mediapath NVARCHAR(MAX),
    @mediatypeid NVARCHAR(MAX),
    @sizeMB NVARCHAR(MAX),
    @encoding NVARCHAR(50),
    @samplerate  NVARCHAR(MAX),
    @languagecode NVARCHAR(10),

    @documenttypeid NVARCHAR(200),

--Parametro de cambio de versión
    @changecomments NVARCHAR(500),

--Parametros de los segmentos objetivo
    @targetSegments NVARCHAR(300) = NULL,      
    @segmentWeights NVARCHAR(300) = NULL,      

--Parametros de votos
    @startdate DATETIME = NULL,
    @enddate DATETIME = NULL,
    @votingtypeid INT = NULL,
    @allowweightedvotes BIT = NULL,
    @requiresallvoters BIT = NULL,
    @notificationmethodid INT = NULL,
    @publisheddate DATETIME = NULL,
    @finalizeddate DATETIME = NULL,
    @publicvoting BIT = NULL,
    
    
--Parametros de salida
    @mensaje NVARCHAR(100) OUTPUT,
    @proposalIdCreated INT OUTPUT

AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @checksumData VARBINARY(256);
    DECLARE @currentDateTime DATETIME = GETDATE();
    DECLARE @newProposalId INT;
    DECLARE @statusid INT = 2;
    DECLARE @documentCount INT=0;
    
    -- Variables para IDs de log (obtener dinámicamente)
    DECLARE @logSeverityInfo INT = (SELECT TOP 1 logseverityid FROM PV_LogSeverity WHERE name = 'Info');
    DECLARE @logTypeSystem INT = (SELECT TOP 1 logtypeid FROM PV_LogTypes WHERE name = 'System');
    DECLARE @logSourceSP INT = (SELECT TOP 1 logsourceid FROM PV_LogSource WHERE name = 'StoredProcedure');

    DECLARE @path NVARCHAR(300);
    DECLARE @type INT;
    DECLARE @size INT;
    DECLARE @encodingValue NVARCHAR(50);
    DECLARE @sampleRateValue INT;
    DECLARE @languageCodeValue NVARCHAR(10);
    DECLARE @mediaId INT;
    DECLARE @docId INT;
    DECLARE @hash VARBINARY(256);
    DECLARE @Total INT;
    DECLARE @i INT;
    
    -- 📊 Variable para cálculo automático de porcentaje
    DECLARE @calculatedPercentage DECIMAL(12, 8);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- 🧮 CALCULAR PORCENTAJE AUTOMÁTICAMENTE SI NO SE PROPORCIONA
        IF @percentageRequested IS NULL AND @budget IS NOT NULL AND @budget > 0
        BEGIN
            -- Lógica de cálculo automático basada en el presupuesto
            IF @budget <= 100000
                SET @calculatedPercentage = 5.00;     -- 5% para budgets bajos
            ELSE IF @budget <= 500000
                SET @calculatedPercentage = 10.00;    -- 10% para budgets medios
            ELSE
                SET @calculatedPercentage = 15.00;    -- 15% para budgets altos
        END
        ELSE
        BEGIN
            -- Usar el porcentaje proporcionado o 0 si el budget es 0
            SET @calculatedPercentage = ISNULL(@percentageRequested, 0.00);
        END

-------------------Validar que el usuario tenga permisos de creación/edición sobre la propuesta---------------------------
        IF NOT EXISTS (
            SELECT 1    
            FROM PV_UserPermissions
            WHERE userid = @createdby AND permissionid = 11 AND enabled = 1 AND deleted = 0)
        BEGIN
            SET @mensaje = 'El usuario no tiene permisos para crear y actualizar propuestas';
            ROLLBACK TRANSACTION;
            RETURN;    
        END

-------------------Insertar o actualizar información en las tablas/colecciones correspondientes---------------------------
        SET @checksumData = HASHBYTES('SHA2_256', @title + CAST(@budget AS VARCHAR));

        -- 📊 LÓGICA AUTOMÁTICA: Calcular percentageRequested si no se proporciona
        IF @calculatedPercentage IS NULL AND @budget IS NOT NULL AND @budget > 0
        BEGIN
            -- Calcular porcentaje basado en el budget
            -- Ejemplo: para budgets hasta $100K = 5%, hasta $500K = 10%, más de $500K = 15%
            SET @calculatedPercentage = CASE 
                WHEN @budget <= 100000 THEN 5.0
                WHEN @budget <= 500000 THEN 10.0
                ELSE 15.0
            END;
        END
        ELSE
        BEGIN
            -- Si se proporciona percentageRequested, usarlo directamente
            SET @calculatedPercentage = ISNULL(@percentageRequested, 0.00);
        END

        --Insertar propuesta
        IF @proposalid IS NULL
        BEGIN
            INSERT INTO PV_Proposals (
                title,
                description,
                proposalcontent,
                budget,
                percentageRequested,
                createdby,
                createdon,
                lastmodified,
                proposaltypeid,
                statusid,
                organizationid,
                checksum,
                version
            )
            VALUES (
                @title,
                @description,
                @proposalcontent,
                @budget,
                @calculatedPercentage,
                @createdby,
                @currentDateTime,
                @currentDateTime,
                @proposaltypeid,
                3,
                @organizationid,
                @checksumData,
                1
            );

            SET @newProposalId = SCOPE_IDENTITY();
            
            -- Crear versión inicial
            INSERT INTO PV_ProposalVersions (
                proposalid,
                versionnumber,
                title,
                description,
                proposalcontent,
                budget,
                createdby,
                createdon,
                isactive,
                changecomments,
                checksum
            )
            VALUES (
                @newProposalId,  
                1,                 
                @title,
                @description,
                @proposalcontent,
                @budget,
                @createdby,
                @currentDateTime,
                1,                 
                @changecomments,   
                @checksumData
            );
            
            -- 📋 EFECTO SECUNDARIO: Crear valores de requerimientos automáticamente
            -- Insertar valores por defecto para requerimientos del tipo de propuesta
            INSERT INTO PV_ProposalRequirementValues (
                proposalid,
                requirementid,
                textvalue,
                numbervalue,
                datevalue
            )
            SELECT 
                @newProposalId,
                pr.requirementid,
                CASE 
                    WHEN pr.fieldname = 'title' THEN @title
                    WHEN pr.fieldname = 'description' THEN @description
                    WHEN pr.fieldname = 'proposalcontent' THEN @proposalcontent
                    WHEN pr.datatype = 'text' THEN 'Valor pendiente de completar'
                    ELSE NULL
                END,
                CASE 
                    WHEN pr.fieldname = 'budget' THEN @budget
                    WHEN pr.datatype = 'number' THEN 0
                    ELSE NULL
                END,
                CASE 
                    WHEN pr.datatype = 'datetime' THEN @currentDateTime
                    ELSE NULL
                END
            FROM PV_ProposalRequirements pr
            WHERE pr.proposaltypeid = @proposaltypeid
            AND pr.isrequired = 1; -- Solo requerimientos obligatorios
            
            -- Log de creación de requerimientos
            DECLARE @requirementsCount INT = @@ROWCOUNT;
            IF @requirementsCount > 0
            BEGIN
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
                    CONCAT('Creados automáticamente ', @requirementsCount, ' valores de requerimientos para la propuesta'),
                    'crearActualizarPropuesta_RequerimientosCreados',
                    @currentDateTime,
                    HOST_NAME(),
                    CONCAT('ProposalID: ', @newProposalId, ' | ProposalTypeID: ', @proposaltypeid, ' | Count: ', @requirementsCount),
                    @newProposalId,    
                    @proposaltypeid,                  
                    HASHBYTES('SHA2_256', CONCAT('Requirements:', @newProposalId, '|Type:', @proposaltypeid)),
                    ISNULL(@logTypeSystem, 1),                  
                    ISNULL(@logSourceSP, 1),                  
                    ISNULL(@logSeverityInfo, 1)                  
                );
            END
            
            SET @mensaje = 'Propuesta creada exitosamente con requerimientos';
        END

        --Actualizar propuesta
        ELSE
        BEGIN
            IF NOT EXISTS (
                SELECT 1 
                FROM PV_Proposals 
                WHERE proposalid = @proposalid)
            BEGIN
                SET @mensaje = 'La propuesta especificada no existe';
                ROLLBACK TRANSACTION;
                RETURN; 
            END

            UPDATE PV_ProposalVersions
            SET isactive = 0
            WHERE proposalid = @proposalid AND isactive = 1;

            INSERT INTO PV_ProposalVersions (
                proposalid,
                versionnumber,
                title,
                description,
                proposalcontent,
                budget,
                createdby,
                createdon,
                isactive,
                changecomments,
                checksum)
            VALUES (
                @proposalid,
                @version + 1,
                @title,
                @description,
                @proposalcontent,
                @budget,
                @createdby,
                @currentDateTime,
                1,                      
                @changecomments,                  
                @checksumData);

            UPDATE PV_Proposals
            SET 
                title = @title,
                description = @description,
                proposalcontent = @proposalcontent,
                budget = @budget,
                percentageRequested = @calculatedPercentage,
                lastmodified = @currentDateTime,
                proposaltypeid = @proposaltypeid,
                statusid = @statusid,
                organizationid = @organizationid,
                checksum = @checksumData,
                version = @version + 1
            WHERE proposalid = @proposalid;

            SET @newProposalId = @proposalid;
            SET @mensaje = 'Propuesta actualizada exitosamente';
        END

        --Insertar mediafiles
        IF @mediapath IS NOT NULL 
        BEGIN
            IF @documentids IS NULL
            BEGIN
                -- Tablas temporales para manejar los datos 
                CREATE TABLE #Paths (RowNum INT IDENTITY(1,1), Path NVARCHAR(300));
                CREATE TABLE #Types (RowNum INT IDENTITY(1,1), TypeID INT);
                CREATE TABLE #Sizes (RowNum INT IDENTITY(1,1), SizeMB INT);
                CREATE TABLE #Encodings (RowNum INT IDENTITY(1,1), Encoding NVARCHAR(50));
                CREATE TABLE #SampleRates (RowNum INT IDENTITY(1,1), SampleRate INT);
                CREATE TABLE #LanguageCodes (RowNum INT IDENTITY(1,1), LanguageCode NVARCHAR(10));
                CREATE TABLE #DocumentTypeId (RowNum INT IDENTITY(1,1), DocumentTypeId INT);

                INSERT INTO #Paths (Path)
                SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@mediapath, ',') WHERE value <> '';

                INSERT INTO #Types (TypeID)
                SELECT CAST(LTRIM(RTRIM(value)) AS INT) FROM STRING_SPLIT(@mediatypeid, ',') WHERE value <> '';

                INSERT INTO #Sizes (SizeMB)
                SELECT CAST(LTRIM(RTRIM(value)) AS INT) FROM STRING_SPLIT(@sizeMB, ',') WHERE value <> '';

                INSERT INTO #Encodings (Encoding)
                SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@encoding, ',') WHERE value <> '';

                INSERT INTO #SampleRates (SampleRate)
                SELECT CAST(LTRIM(RTRIM(value)) AS INT) FROM STRING_SPLIT(@samplerate, ',') WHERE value <> '';

                INSERT INTO #LanguageCodes (LanguageCode)
                SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@languagecode, ',') WHERE value <> '';
                    
                INSERT INTO #DocumentTypeId (DocumentTypeId)
                SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@documenttypeid, ',') WHERE value <> '';

                SET @Total = (SELECT COUNT(*) FROM #Paths);
                SET @i = 1;

                WHILE @i <= @Total
                BEGIN
                    SELECT @path = Path FROM #Paths WHERE RowNum = @i;
                    SELECT @type = TypeID FROM #Types WHERE RowNum = @i;
                    SELECT @size = SizeMB FROM #Sizes WHERE RowNum = @i;
                    SELECT @encodingValue = Encoding FROM #Encodings WHERE RowNum = @i;
                    SELECT @sampleRateValue = SampleRate FROM #SampleRates WHERE RowNum = @i;
                    SELECT @languageCodeValue = LanguageCode FROM #LanguageCodes WHERE RowNum = @i;
                    SELECT @documenttypeid = DocumentTypeId FROM #DocumentTypeId WHERE RowNum = @i;

                    -- Insertar en mediafiles
                    INSERT INTO PV_mediafiles (
                        mediapath, deleted, lastupdate, userid, mediatypeid, sizeMB,
                        encoding, samplerate, languagecode
                    )
                    VALUES (
                        @path, 0, @currentDateTime, @createdby, @type, @size,
                        @encodingValue, @sampleRateValue, @languageCodeValue
                    );

                    SET @mediaId = SCOPE_IDENTITY();

                    SET @hash = HASHBYTES('SHA2_256', CONCAT(@path,@type,@size, @newProposalId, @i));

                    INSERT INTO PV_Documents (
                        documenthash, aivalidationstatus, aivalidationresult, 
                        humanvalidationrequired, mediafileId, documentTypeId, version)
                    VALUES (@hash, 'Pendiente a revision','No tiene por el momento',1, @mediaId, @documenttypeid, 1);

                    SET @docId = SCOPE_IDENTITY();
                    INSERT INTO PV_ProposalDocuments (proposalid, documenthash ,documentId,createdDate )
                    VALUES (@newProposalId,@hash, @docId, @currentDateTime);

                    SET @i = @i + 1;
                END

                DROP TABLE #Paths; 
                DROP TABLE #Types; 
                DROP TABLE #Sizes;
                DROP TABLE #Encodings; 
                DROP TABLE #SampleRates; 
                DROP TABLE #LanguageCodes;
                DROP TABLE #DocumentTypeId;

                SET @mensaje ='Documentos insertados con exito';
            END

            --Si se especifican documentids, actualizar los documentos existentes
            ELSE
            BEGIN
                -- Usar nombres únicos para las tablas temporales
                CREATE TABLE #PathsUpdate (RowNum INT IDENTITY(1,1), Path NVARCHAR(300));
                CREATE TABLE #TypesUpdate (RowNum INT IDENTITY(1,1), TypeID INT);
                CREATE TABLE #SizesUpdate (RowNum INT IDENTITY(1,1), SizeMB INT);
                CREATE TABLE #EncodingsUpdate (RowNum INT IDENTITY(1,1), Encoding NVARCHAR(50));
                CREATE TABLE #SampleRatesUpdate (RowNum INT IDENTITY(1,1), SampleRate INT);
                CREATE TABLE #LanguageCodesUpdate (RowNum INT IDENTITY(1,1), LanguageCode NVARCHAR(10));
                CREATE TABLE #DocumentTypeIdUpdate (RowNum INT IDENTITY(1,1), DocumentTypeId INT);
                CREATE TABLE #DocumentIdUpdate (RowNum INT IDENTITY(1,1), DocumentId INT);

                INSERT INTO #PathsUpdate (Path)
                SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@mediapath, ',') WHERE value <> '';

                INSERT INTO #TypesUpdate (TypeID)
                SELECT CAST(LTRIM(RTRIM(value)) AS INT) FROM STRING_SPLIT(@mediatypeid, ',') WHERE value <> '';

                INSERT INTO #SizesUpdate (SizeMB)
                SELECT CAST(LTRIM(RTRIM(value)) AS INT) FROM STRING_SPLIT(@sizeMB, ',') WHERE value <> '';

                INSERT INTO #EncodingsUpdate (Encoding)
                SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@encoding, ',') WHERE value <> '';

                INSERT INTO #SampleRatesUpdate (SampleRate)
                SELECT CAST(LTRIM(RTRIM(value)) AS INT) FROM STRING_SPLIT(@samplerate, ',') WHERE value <> '';

                INSERT INTO #LanguageCodesUpdate (LanguageCode)
                SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@languagecode, ',') WHERE value <> '';
                    
                INSERT INTO #DocumentTypeIdUpdate (DocumentTypeId)
                SELECT CAST(LTRIM(RTRIM(value)) AS INT) FROM STRING_SPLIT(@documenttypeid, ',') WHERE value <> '';

                INSERT INTO #DocumentIdUpdate (DocumentId)
                SELECT CAST(LTRIM(RTRIM(value)) AS INT) FROM STRING_SPLIT(@documentids, ',') WHERE value <> '';

                DECLARE @TotalUpdate INT = (SELECT COUNT(*) FROM #PathsUpdate);
                DECLARE @j INT = 1;

                DECLARE @currentDocumentId INT;
                DECLARE @currentDocumentTypeId INT;

                WHILE @j <= @TotalUpdate
                BEGIN
                    SELECT @path = Path FROM #PathsUpdate WHERE RowNum = @j;
                    SELECT @type = TypeID FROM #TypesUpdate WHERE RowNum = @j;
                    SELECT @size = SizeMB FROM #SizesUpdate WHERE RowNum = @j;
                    SELECT @encodingValue = Encoding FROM #EncodingsUpdate WHERE RowNum = @j;
                    SELECT @sampleRateValue = SampleRate FROM #SampleRatesUpdate WHERE RowNum = @j;
                    SELECT @languageCodeValue = LanguageCode FROM #LanguageCodesUpdate WHERE RowNum = @j;
                    SELECT @currentDocumentTypeId = DocumentTypeId FROM #DocumentTypeIdUpdate WHERE RowNum = @j;
                    SELECT @currentDocumentId = DocumentId FROM #DocumentIdUpdate WHERE RowNum = @j;

                    INSERT INTO PV_mediafiles (
                        mediapath, deleted, lastupdate, userid, mediatypeid, sizeMB,
                        encoding, samplerate, languagecode
                    )
                    VALUES (
                        @path, 0, @currentDateTime, @createdby, @type, @size,
                        @encodingValue, @sampleRateValue, @languageCodeValue
                    );

                    SET @mediaId = SCOPE_IDENTITY();
                    SET @hash = HASHBYTES('SHA2_256', CONCAT(@path,@type,@size, @newProposalId, @j));

                    UPDATE PV_Documents 
                    SET documenthash = @hash,
                        aivalidationstatus ='Pendiente a revision',
                        aivalidationresult='No tiene por el momento',
                        humanvalidationrequired = 1,
                        mediafileId = @mediaId,
                        documentTypeId = @currentDocumentTypeId,
                        version = version + 1
                    WHERE documentId = @currentDocumentId;

                    SET @j = @j + 1;
                END

                DROP TABLE #PathsUpdate; 
                DROP TABLE #TypesUpdate; 
                DROP TABLE #SizesUpdate;
                DROP TABLE #EncodingsUpdate; 
                DROP TABLE #SampleRatesUpdate; 
                DROP TABLE #LanguageCodesUpdate;
                DROP TABLE #DocumentTypeIdUpdate;
                DROP TABLE #DocumentIdUpdate;

                SET @mensaje ='Documentos actualizados con éxito';
            END
        END
        ELSE
        BEGIN
            SET @mensaje = ' Sin documentos adjuntos';
        END

--------------------Asociar la propuesta a su población meta: criterios como edad, grupo, región, etc.---------------------------

        IF @targetSegments IS NOT NULL AND @startdate IS NOT NULL AND @enddate IS NOT NULL AND @votingtypeid IS NOT NULL
        BEGIN
            CREATE TABLE #SegmentNames (RowNum INT IDENTITY(1,1), SegmentName NVARCHAR(60));
            CREATE TABLE #SegmentWeights (RowNum INT IDENTITY(1,1), Weight DECIMAL(5,2));

            INSERT INTO #SegmentNames (SegmentName)
            SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@targetSegments, ',') WHERE LTRIM(RTRIM(value)) <> '';

            INSERT INTO #SegmentWeights (Weight)
            SELECT CAST(LTRIM(RTRIM(value)) AS DECIMAL(5,2)) FROM STRING_SPLIT(@segmentWeights, ',') WHERE LTRIM(RTRIM(value)) <> '';

            DECLARE @SegmentCount INT = (SELECT COUNT(*) FROM #SegmentNames);
            DECLARE @WeightCount INT = (SELECT COUNT(*) FROM #SegmentWeights);
            
            IF @SegmentCount!= @WeightCount
            BEGIN
                SET @mensaje = 'Número de segmentos y pesos no coinciden';
                DROP TABLE #SegmentNames;
                DROP TABLE #SegmentWeights;
                ROLLBACK TRANSACTION;
                RETURN;
            END

            DECLARE @TotalSegments INT = @SegmentCount;
            IF @TotalSegments = 0
            BEGIN
                SET @mensaje = 'No se encontraron segmentos válidos para procesar';
                DROP TABLE #SegmentNames;
                DROP TABLE #SegmentWeights;
                ROLLBACK TRANSACTION;
                RETURN;
            END

            DECLARE @votingConfigId INT;
            DECLARE @votingChecksum VARBINARY(256) = HASHBYTES('SHA2_256', CONCAT(@newProposalId, @currentDateTime));

            INSERT INTO PV_VotingConfigurations (
                proposalid,
                startdate,
                enddate,
                votingtypeId,
                allowweightedvotes,
                requiresallvoters,
                notificationmethodid,
                userid,
                configureddate,
                statusid,
                publisheddate,
                finalizeddate,
                publicVoting,
                checksum            
            )
            VALUES (
                @newProposalId,
                @startdate,                
                @enddate,                  
                1,      
                @allowweightedvotes,
                @requiresallvoters,
                @notificationmethodid,
                @createdby,
                @currentDateTime,
                1,                             
                @publisheddate,
                @finalizeddate,
                @publicVoting,
                @votingChecksum
            );

            SET @votingConfigId = SCOPE_IDENTITY();

            DECLARE @segmentName NVARCHAR(60);
            DECLARE @segmentWeight DECIMAL(5,2);
            DECLARE @segmentId INT;
            DECLARE @k INT = 1;

            WHILE @k <= @TotalSegments
            BEGIN
                SET @segmentName = NULL;
                SET @segmentWeight = NULL;
                SET @segmentId = NULL;

                SELECT @segmentName = SegmentName FROM #SegmentNames WHERE RowNum = @k;
                SELECT @segmentWeight = Weight FROM #SegmentWeights WHERE RowNum = @k;

                -- Buscar si el segmento ya existe
                SELECT @segmentId = segmentid 
                FROM PV_PopulationSegments 
                WHERE name = @segmentName;

                IF @segmentId IS NULL
                BEGIN
                    INSERT INTO PV_PopulationSegments (name, description, segmenttypeid)
                    VALUES (@segmentName, 'Segmento creado automáticamente', 1); 
                    
                    SET @segmentId = SCOPE_IDENTITY();
                END

                INSERT INTO PV_VotingTargetSegments (
                    votingconfigid,
                    segmentid,
                    voteweight,
                    assigneddate
                )
                VALUES (
                    @votingConfigId,
                    @segmentId,
                    @segmentWeight,
                    @currentDateTime
                );

                SET @k = @k + 1;
            END

            DROP TABLE #SegmentNames;
            DROP TABLE #SegmentWeights;
            SET @mensaje =' Población meta configurada con éxito para la propuesta';
        END
        
---------------Enviar los datos a revisión interna (estado: pendiente de validación)-----------------------------

        IF @statusid = 2
        BEGIN
            -- 🤖 EFECTO SECUNDARIO: Iniciar workflow de revisión AI automáticamente
            DECLARE @workflowId INT = (SELECT TOP 1 workflowId FROM PV_workflows WHERE name = 'Análisis AI Propuesta' OR workflowId = 1);
            
            IF @workflowId IS NOT NULL
            BEGIN
                -- Crear registro en tabla de workflow instances (si existe)
                -- Por ahora, solo registramos en logs pero se puede expandir
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
                    'Workflow de análisis AI iniciado automáticamente para nueva propuesta',
                    'crearActualizarPropuesta_WorkflowIniciado',
                    @currentDateTime,
                    HOST_NAME(),
                    CONCAT('WorkflowID: ', @workflowId, ' | ProposalID: ', @newProposalId, ' | Status: Iniciado'),
                    @newProposalId,    
                    @workflowId,                  
                    HASHBYTES('SHA2_256', CONCAT('WorkflowStart:', @workflowId, '|Proposal:', @newProposalId)),
                    ISNULL(@logTypeSystem, 1),                  
                    ISNULL(@logSourceSP, 1),                  
                    ISNULL(@logSeverityInfo, 1)                  
                );
            END
            
            --workflow para propuesta
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
                'Propuesta enviada automáticamente al workflow de análisis AI',
                'crearActualizarPropuesta_WorkflowAI',
                @currentDateTime,
                HOST_NAME(),
                'WorkflowID: 1 | ProposalID: Enviado para análisis',
                @newProposalId,    
                1,                  
                HASHBYTES('SHA2_256', CONCAT('WorkflowAI:1|Proposal:', @newProposalId)),
                ISNULL(@logTypeSystem, 1),                  
                ISNULL(@logSourceSP, 1),                  
                ISNULL(@logSeverityInfo, 1)                  
            );
    
            --workflow para documentos
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
                'Documentos enviados automáticamente al workflow de análisis AI',
                'crearActualizarDocumento_WorkflowAI',
                @currentDateTime,
                HOST_NAME(),
                'WorkflowID: 1 | ProposalID: Enviado para análisis',
                @newProposalId,    
                1,                  
                HASHBYTES('SHA2_256', CONCAT('WorkflowAI:1|Proposal:', @docId)),
                ISNULL(@logTypeSystem, 1),                  
                ISNULL(@logSourceSP, 1),                  
                ISNULL(@logSeverityInfo, 1)                  
            );
            SET @mensaje =' Datos enviados para análisis AI (Workflow ID: 1)';
        END

            -- 📌 CREAR PLAN DE EJECUCIÓN AUTOMÁTICO CON AL MENOS UN PASO (ajustado a columnas reales)
            DECLARE @executionPlanId INT;
            DECLARE @expectedStartdate DATETIME = @currentDateTime;
            DECLARE @expectedenddate DATETIME = DATEADD(MONTH, 6, @currentDateTime); -- 6 meses por defecto
            DECLARE @expectedDurationInMonths DECIMAL(18,0) = 6;
            INSERT INTO PV_ExecutionPlans (proposalid, totalbudget, expectedStartdate, expectedenddate, createddate, expectedDurationInMonths)
            VALUES (@newProposalId, @budget, @expectedStartdate, @expectedenddate, @currentDateTime, @expectedDurationInMonths);
            SET @executionPlanId = SCOPE_IDENTITY();

            -- Insertar al menos un paso ("Creación de propuesta") en PV_executionPlanSteps
            INSERT INTO PV_executionPlanSteps (
                executionPlanId, stepIndex, description, stepTypeId, estimatedInitDate, estimatedEndDate, durationInMonts, KPI, votingId
            )
            VALUES (
                @executionPlanId, 1, 'Creación de propuesta', 1, @expectedStartdate, @expectedenddate, @expectedDurationInMonths, 'Propuesta creada', NULL
            );

            -- 📌 CREAR ACUERDO DE INVERSIÓN AUTOMÁTICO CON TRAMO POR DEFECTO (ajustado a modelo Prisma)
            DECLARE @investmentAgreementId INT;
            INSERT INTO PV_InvestmentAgreements (
                name, description, signatureDate, porcentageInvested, investmentId, documentId, organizationId, userId, checksum, proposalid
            )
            VALUES (
                'Adelanto',
                'Acuerdo generado automáticamente al crear la propuesta',
                @currentDateTime,
                100,
                NULL,
                NULL,
                NULL,
                @createdby,
                0x00,
                @newProposalId
            );
            SET @investmentAgreementId = SCOPE_IDENTITY();




            -- 📌 CREAR MÉTODO DE PAGO Y MÉTODO DISPONIBLE SI NO EXISTEN PARA EL USUARIO (ajustado a columnas reales)
            IF NOT EXISTS (SELECT 1 FROM PV_PaymentMethods WHERE name = 'Transferencia bancaria')
            BEGIN
                INSERT INTO PV_PaymentMethods (name, APIURL, secretkey, [key], logoiconurl, enabled)
                VALUES ('Transferencia bancaria', 'https://banco.example.com/api', 0x00, 0x00, NULL, 1);
            END
            DECLARE @paymentmethodid INT = (SELECT TOP 1 paymentmethodid FROM PV_PaymentMethods WHERE name = 'Transferencia bancaria');
            IF NOT EXISTS (SELECT 1 FROM PV_AvailableMethods WHERE userid = @createdby AND name = 'Transferencia bancaria')
            BEGIN
                INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid)
                VALUES ('Transferencia bancaria', 0x00, DATEADD(YEAR, 1, @currentDateTime), '****1234', @createdby, @paymentmethodid);
            END

        -- Confirmar transacción
        COMMIT TRANSACTION;
        
        -- Devolver el ID de la propuesta creada/actualizada
        SET @proposalIdCreated = @newProposalId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SET @mensaje = ERROR_MESSAGE();
        SET @proposalIdCreated = NULL; -- Asegurar que sea NULL en caso de error
            
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
            'Error en crearActualizarPropuesta: ' ,
            'crearActualizarPropuesta_ERROR',
            GETDATE(),
            HOST_NAME(),
            ERROR_PROCEDURE(),
            ISNULL(@proposalid, 0),
            ISNULL(@createdby, 0),
            HASHBYTES('SHA2_256', @mensaje),
            ISNULL(@logTypeSystem, 1),      
            ISNULL(@logSourceSP, 1),        
            4       -- Error severity (hardcoded for error logs)
        );
    END CATCH
END
GO

PRINT 'Procedimiento crearActualizarPropuesta creado exitosamente.';
