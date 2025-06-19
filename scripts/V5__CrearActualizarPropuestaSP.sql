
CREATE OR ALTER PROCEDURE [dbo].[crearActualizarPropuesta]

--Parametros de proposal
    @proposalid INT, --NULL para crear la propuesta
    @title NVARCHAR(200),
    @description NVARCHAR(MAX),
    @proposalcontent NVARCHAR(MAX),
    @budget DECIMAL(18, 2),
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
    @startdate DATETIME,
    @enddate DATETIME,
    @votingtypeid INT,
    @allowweightedvotes BIT,
    @requiresallvoters BIT,
    @notificationmethodid INT,
    @publisheddate DATETIME,
    @finalizeddate DATETIME,
    @publicvoting BIT,
    
    
--Parametro de salida
    @mensaje NVARCHAR(100) OUTPUT

AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @checksumData VARBINARY(256);
    DECLARE @currentDateTime DATETIME = GETDATE();
    DECLARE @newProposalId INT;
    DECLARE @statusid INT = 2;
    DECLARE @documentCount INT=0;

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
                1,                  
                1,                  
                1                  
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
                1,                  
                1,                  
                1                  
            );
            SET @mensaje =' Datos enviados para análisis AI (Workflow ID: 1)';
        END

        -- Confirmar transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SET @mensaje = ERROR_MESSAGE();
            
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
            3,      
            1,        
            3       
        );
    END CATCH
END
GO

PRINT 'Procedimiento crearActualizarPropuesta creado exitosamente.';
