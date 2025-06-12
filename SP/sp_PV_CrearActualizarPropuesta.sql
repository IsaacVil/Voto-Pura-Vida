CREATE OR ALTER PROCEDURE [dbo].[crearActualizarPropuesta]

--Parametros de proposal
    @proposalid INT, --NULL para crear la propuesta, valor para actualizarla
    @title NVARCHAR(200),
    @description NVARCHAR(MAX),
    @proposalcontent NVARCHAR(MAX),
    @budget DECIMAL(18, 2),
    @createdby INT,
    @createdon DATETIME, 
    @proposaltypeid INT,
    @organizationid INT,
    @version INT,

--Parametro de mediafiles
    @mediapath NVARCHAR(MAX),
    @mediatypeid NVARCHAR(MAX),
    @sizeMB NVARCHAR(MAX),
    @encoding NVARCHAR(50),
    @samplerate INT,
    @languagecode NVARCHAR(10) = NULL,

--Parametro de cambio de versión
    @changecomments NVARCHAR(500),

--Parametros de los segmentos objetivo
    @targetSegments NVARCHAR(300) = NULL,      
    @segmentWeights NVARCHAR(300) = NULL,      

--Parametros de votos
    @startdate DATETIME,
    @enddate DATETIME,
    @votingtypeid INT,
    @allowweightedvotes BIT,
    @requiresallvoters BIT,
    @notificationmethod NVARCHAR,
    @publishdate DATETIME,
    @finalizedate DATETIME,
    @publicvoting BIT,
    

    
--Parametro de salida
    @mensaje NVARCHAR(100) OUTPUT

AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @checksumData VARBINARY(256);
    DECLARE @currentDateTime DATETIME = GETDATE();
    DECLARE @newProposalId INT
    DECLARE @statusid INT = 1;
    DECLARE @documentCount INT=0;

    BEGIN TRY
        BEGIN TRANSACTION;

-------------------Validar que el usuario tenga permisos de creación/edición sobre la propuesta---------------------------
        IF NOT EXISTS (
            SELECT 1    
            FROM PV_UserRoles
            WHERE userid = @createdby AND roleid=1 AND enabled = 1)
        BEGIN
            SET @mensaje = 'El usuario no tiene permisos para crear y actualizar propuestas';
            ROLLBACK TRANSACTION;
            RETURN;    
        END

-------------------Insertar o actualizar información en las tablas/colecciones correspondientes---------------------------
        SET @checksumData = HASHBYTES('SHA2_256', @title + CAST(@budget AS VARCHAR));

        --Insertar propuesta
        IF @proposalid IS NULL
        BEGIN
            INSERT INTO PV_Proposals (
                title,
                description,
                proposalcontent,
                budget,
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
                @createdby,
                @currentDateTime,
                @currentDateTime,
                @proposaltypeid,
                @statusid,
                @organizationid,
                @checksumData,
                1
            );

            SET @newProposalId = SCOPE_IDENTITY();
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
            
            SET @mensaje = 'Propuesta creada exitosamente';
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
                @currentVersionNumber + 1,
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

                DECLARE @Total INT = (SELECT COUNT(*) FROM #Paths);
                DECLARE @i INT = 1;

                WHILE @i <= @Total
                BEGIN
                    DECLARE @path NVARCHAR(300);
                    DECLARE @type INT;
                    DECLARE @size INT;
                    DECLARE @encodingValue NVARCHAR(50) = NULL;
                    DECLARE @sampleRateValue INT = NULL;
                    DECLARE @languageCodeValue NVARCHAR(10) = NULL;
                    DECLARE @mediaId INT;
                    DECLARE @docId INT;
                    DECLARE @hash VARBINARY(256);

                    SELECT @path = Path FROM #Paths WHERE RowNum = @i;
                    SELECT @type = TypeID FROM #Types WHERE RowNum = @i;
                    SELECT @size = SizeMB FROM #Sizes WHERE RowNum = @i;

                    SELECT @encodingValue = Encoding FROM #Encodings WHERE RowNum = @i;
                    SELECT @sampleRateValue = SampleRate FROM #SampleRates WHERE RowNum = @i;
                    SELECT @languageCodeValue = LanguageCode FROM #LanguageCodes WHERE RowNum = @i;

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
                        documenthash, aivalidationstatus, humanvalidationrequired, 
                        mediafileId, documentTypeId, version)
                    VALUES (@hash, 'Pending', 1, @mediaId, @type, 1);

                    SET @docId = SCOPE_IDENTITY();
                    INSERT INTO PV_ProposalDocuments (proposalid, documentId, documenthash)
                    VALUES (@newProposalId, @docId, @hash);

                    SET @i = @i + 1;
                END

                DROP TABLE #Paths; DROP TABLE #Types; DROP TABLE #Sizes;
                DROP TABLE #Encodings; DROP TABLE #SampleRates; DROP TABLE #LanguageCodes;

                SET @mensaje ='Documentos insertados con exito';
            END
            ELSE
            BEGIN
                CREATE TABLE #UpdatePaths (RowNum INT IDENTITY(1,1), Path NVARCHAR(300));
                CREATE TABLE #UpdateTypes (RowNum INT IDENTITY(1,1), TypeID INT);
                CREATE TABLE #UpdateSizes (RowNum INT IDENTITY(1,1), SizeMB INT);
                CREATE TABLE #UpdateEncodings (RowNum INT IDENTITY(1,1), Encoding NVARCHAR(50));
                CREATE TABLE #UpdateSampleRates (RowNum INT IDENTITY(1,1), SampleRate INT);
                CREATE TABLE #UpdateLanguageCodes (RowNum INT IDENTITY(1,1), LanguageCode NVARCHAR(10));
                CREATE TABLE #UpdateDocumentIds (RowNum INT IDENTITY(1,1), DocumentId INT);

                INSERT INTO #UpdatePaths (Path)
                SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@mediapath, ',') WHERE value <> '';

                INSERT INTO #UpdateTypes (TypeID)
                SELECT CAST(LTRIM(RTRIM(value)) AS INT) FROM STRING_SPLIT(@mediatypeid, ',') WHERE value <> '';

                INSERT INTO #UpdateSizes (SizeMB)
                SELECT CAST(LTRIM(RTRIM(value)) AS INT) FROM STRING_SPLIT(@sizeMB, ',') WHERE value <> '';

                INSERT INTO #UpdateDocumentIds (DocumentId)
                SELECT CAST(LTRIM(RTRIM(value)) AS INT) FROM STRING_SPLIT(@documentids, ',') WHERE value <> '' AND value <> '0';

                INSERT INTO #UpdateEncodings (Encoding)
                SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@encoding, ',') WHERE value <> '';

                INSERT INTO #UpdateSampleRates (SampleRate)
                SELECT CAST(LTRIM(RTRIM(value)) AS INT) FROM STRING_SPLIT(@samplerate, ',') WHERE value <> '';

                INSERT INTO #UpdateLanguageCodes (LanguageCode)
                SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@languagecode, ',') WHERE value <> '';

                DECLARE @TotalUpdate INT = (SELECT COUNT(*) FROM #UpdatePaths);
                DECLARE @j INT = 1;

                WHILE @j <= @TotalUpdate
                BEGIN
                    DECLARE @updatePath NVARCHAR(300);
                    DECLARE @updateType INT;
                    DECLARE @updateSize INT;
                    DECLARE @updateEncodingValue NVARCHAR(50) = NULL;
                    DECLARE @updateSampleRateValue INT = NULL;
                    DECLARE @updateLanguageCodeValue NVARCHAR(10) = NULL;
                    DECLARE @updateDocumentId INT;
                    DECLARE @updateMediaId INT;
                    DECLARE @updateHash VARBINARY(256);

                    SELECT @updatePath = Path FROM #UpdatePaths WHERE RowNum = @j;
                    SELECT @updateType = TypeID FROM #UpdateTypes WHERE RowNum = @j;
                    SELECT @updateSize = SizeMB FROM #UpdateSizes WHERE RowNum = @j;
                    SELECT @updateDocumentId = DocumentId FROM #UpdateDocumentIds WHERE RowNum = @j;

                    SELECT @updateEncodingValue = Encoding FROM #UpdateEncodings WHERE RowNum = @j;
                    SELECT @updateSampleRateValue = SampleRate FROM #UpdateSampleRates WHERE RowNum = @j;
                    SELECT @updateLanguageCodeValue = LanguageCode FROM #UpdateLanguageCodes WHERE RowNum = @j;

                    SELECT @updateMediaId = mediafileId FROM PV_Documents WHERE documentId = @updateDocumentId;

                    INSERT INTO PV_mediafiles (
                        mediapath, 
                        deleted, 
                        lastupdate, 
                        userid, 
                        mediatypeid, 
                        sizeMB,
                        encoding,
                        samplerate,
                        languagecode)
                    VALUES (
                        @updatePath, 
                        0, 
                        @currentDateTime, 
                        @createdby, 
                        @updateType, 
                        @updateSize,
                        @updateEncodingValue, 
                        @updateSampleRateValue, 
                        @updateLanguageCodeValue
                    );

                    SET @updateMediaId = SCOPE_IDENTITY();
                    SET @updateHash = HASHBYTES('SHA2_256', CONCAT(@updatePath, @updateType, @updateSize, @newProposalId, @j));

                    UPDATE PV_Documents 
                    SET documenthash = @updateHash,
                        aivalidationstatus = 'Pending',
                        humanvalidationrequired = 1,
                        documentTypeId = @updateType,
                        mediafileId = @updateMediaId,
                        version = version + 1
                    WHERE documentId = @updateDocumentId;

                    SET @j = @j + 1;
                END

                DROP TABLE #UpdatePaths; DROP TABLE #UpdateTypes; DROP TABLE #UpdateSizes;
                DROP TABLE #UpdateEncodings; DROP TABLE #UpdateSampleRates; DROP TABLE #UpdateLanguageCodes; DROP TABLE #UpdateDocumentIds;

                SET @mensaje ='Documentos actualizados con éxito';
            END
        END
        ELSE
        BEGIN
            SET @mensaje = ' Sin documentos adjuntos';
        END

--------------------Asociar la propuesta a su población meta: criterios como edad, grupo, región, etc.---------------------------

        IF @targetSegments IS NOT NULL
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
                checksum,
                createdDate,
                updatedDate
            )
            VALUES (
                @newProposalId,
                @startdate,                
                @enddate,                  
                ISNULL(@votingtypeid, 1),      
                @allowweightedvotes,
                @requiresallvoters,
                @notificationmethodid,
                @createdby,
                @currentDateTime,
                1,                             
                @publisheddate,
                @finalizeddate,
                @publicVoting,
                @votingChecksum,
                @currentDateTime,
                @currentDateTime
            );
            
            SET @votingConfigId = SCOPE_IDENTITY();

            DECLARE @k INT = 1;
            WHILE @k <= @TotalSegments
            BEGIN
                DECLARE @segmentName NVARCHAR(60);
                DECLARE @segmentWeight DECIMAL(5,2);
                DECLARE @segmentId INT;

                SELECT @segmentName = SegmentName FROM #SegmentNames WHERE RowNum = @k;
                SELECT @segmentWeight = Weight FROM #SegmentWeights WHERE RowNum = @k;

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

        IF @statusid = 1 
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
                'Propuesta enviada automáticamente al workflow de análisis AI',
                'crearActualizarPropuesta_WorkflowAI',
                @currentDateTime,
                HOST_NAME(),
                'WorkflowID: 1 | ProposalID: Enviado para análisis',
                @newProposalId,    
                1,                  
                HASHBYTES('SHA2_256', CONCAT('WorkflowAI:1|Proposal:', @newProposalId)),
                1,                  
                1,                  
                1                  
            );
            
            SET @mensaje =' Datos enviado para análisis AI (Workflow ID: 1)';
        END

        -- Confirmar transacción
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @ErrorMessage = ERROR_MESSAGE();
            
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
            'Error en crearActualizarPropuesta: ' + @ErrorMessage,
            'crearActualizarPropuesta_ERROR',
            GETDATE(),
            HOST_NAME(),
            ERROR_PROCEDURE(),
            ISNULL(@proposalid, 0),
            ISNULL(@createdby, 0),
            HASHBYTES('SHA2_256', @ErrorMessage),
            3,      
            1,        
            3       
        );
    END CATCH
END