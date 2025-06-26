insert into PV_workflowstype(name) values ('Revision de documentos');
insert into PV_workflows(name, description, endpoint, workflowTypeId, params)
values (
    'Validacion de documentos requeridos',
    'Se validara de forma automatica que se cumplan con los archivos necesarios para un comment (documentos requeridos) y su estructura',
    '/api/validate/comment-document',
    1,
    N'{
        "requiredFields": ["mediafileId", "commentid"],
        "validationLevel": "strict",
        "notifyOnFail": true
    }'
);
insert into PV_workflows(name, description, endpoint, workflowTypeId, params)
values (
    'Validacion de archivos',
    'Se validara de forma automatica cualquier archivo necesario para un comment (documentos requeridos)',
    '/api/validate/comment-document',
    1,
    N'{
        "requiredFields": ["mediafileId", "commentid"],
        "validationLevel": "strict",
        "notifyOnFail": true
    }'
);
insert into PV_DocumentTypes (name, description, workflowId) 
values ('Documentos de Comentarios de Propuestas', 'Aca irian todos los documentos que ayudarian a validar los comentarios correspondientes', 1);
GO

CREATE OR ALTER PROCEDURE dbo.SP_CrearDocumentosPorUsuario
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @documentTypeId INT = (SELECT TOP 1 documentTypeId FROM PV_DocumentTypes WHERE name = 'Documentos de Comentarios de Propuestas');
    DECLARE @userId INT;
    DECLARE @aivalidationstatus VARCHAR(20);
    DECLARE @aivalidationresult VARCHAR(50);
    DECLARE @documentid INT;

    DECLARE @Resultados TABLE (
        userid INT,
        documentid INT,
        aivalidationstatus VARCHAR(20),
        aivalidationresult VARCHAR(50)
    );

    DECLARE user_cursor CURSOR FOR
        SELECT userid FROM PV_Users;

    OPEN user_cursor;
    FETCH NEXT FROM user_cursor INTO @userId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (ABS(CHECKSUM(NEWID())) % 10) < 9
        BEGIN
            SET @aivalidationstatus = 'Completado';
            SET @aivalidationresult = 'Validado';
        END
        ELSE
        BEGIN
            SET @aivalidationstatus = 'Completado';
            SET @aivalidationresult = 'No Validado';
        END

        INSERT INTO PV_Documents (
            documenthash,
            aivalidationstatus,
            aivalidationresult,
            humanvalidationrequired,
            mediafileId,
            periodicVerificationId,
            documentTypeId,
            version
        )
        VALUES (
            CAST(NEWID() AS VARBINARY(256)),
            @aivalidationstatus,
            @aivalidationresult,
            0,
            NULL,
            NULL,
            @documentTypeId,
            1
        );

        SET @documentid = SCOPE_IDENTITY();

        INSERT INTO @Resultados VALUES (@userId, @documentid, @aivalidationstatus, @aivalidationresult);

        FETCH NEXT FROM user_cursor INTO @userId;
    END

    CLOSE user_cursor;
    DEALLOCATE user_cursor;

    SELECT * FROM @Resultados;
END
GO

-- Para ejecutar y ver los resultados:
EXEC dbo.SP_CrearDocumentosPorUsuario;
select * from PV_Documents;
select * from PV_Documenttypes;


INSERT INTO dbo.PV_mediaTypes (name, playerimpl) 
VALUES 
('PDF', 'PDFReader'),
('MP3', 'AudioPlayer'),
('MP4', 'VideoPlayer'),
('JPEG', 'ImageViewer'),
('PDF', 'PDFReader'),
('JPEG', 'ImageViewer');


-- 1. Asegura que existan al menos dos g�neros y un m�todo MFA
IF NOT EXISTS (SELECT 1 FROM PV_Genders WHERE name = 'Masculino')
    INSERT INTO PV_Genders (name) VALUES ('Masculino');
IF NOT EXISTS (SELECT 1 FROM PV_Genders WHERE name = 'Femenino')
    INSERT INTO PV_Genders (name) VALUES ('Femenino');
IF NOT EXISTS (SELECT 1 FROM PV_MFAMethods WHERE name = 'TOTP')
    INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('TOTP', 'Test MFA', 1);

-- 2. Inserta 10 status (autoincremental)
DECLARE @statusId INT, @genderId INT, @mfaMethodId INT, @validationid INT, @i INT = 1;

-- Obt�n los IDs de g�nero y m�todo MFA
SELECT TOP 1 @genderId = genderId FROM PV_Genders WHERE name = 'Masculino';
SELECT TOP 1 @mfaMethodId = MFAmethodid FROM PV_MFAMethods WHERE name = 'TOTP';

WHILE @i <= 10
BEGIN
    -- Inserta status (activos/verificados solo los primeros 7)
    INSERT INTO PV_UserStatus (active, verified)
    VALUES (
        CASE WHEN @i <= 7 THEN 1 ELSE 0 END,
        CASE WHEN @i <= 7 THEN 1 ELSE 0 END
    );
    SET @statusId = SCOPE_IDENTITY();

    -- Alterna g�nero
    IF @i % 2 = 0
        SELECT TOP 1 @genderId = genderId FROM PV_Genders WHERE name = 'Femenino';
    ELSE
        SELECT TOP 1 @genderId = genderId FROM PV_Genders WHERE name = 'Masculino';

    -- Inserta usuario
    INSERT INTO PV_Users (email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId)
    VALUES (
        CONCAT('user', @i, '_', NEWID(), '@mail.com'),
        CONCAT('Nombre', @i),
        CONCAT('Apellido', @i),
        '1990-01-01',
        GETDATE(),
        @genderId,
        GETDATE(),
        10000000 + @i,
        @statusId
    );
    DECLARE @userid INT = SCOPE_IDENTITY();

    -- MFA solo para los primeros 7
    IF @i <= 7
        INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, userid)
        VALUES (
            @mfaMethodId,
            0x01,
            GETDATE(),
            1,
            @userid
        );
    ELSE
        INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, userid)
        VALUES (
            @mfaMethodId,
            0x01,
            GETDATE(),
            0,
            @userid
        );

    -- Validaci�n de identidad solo para los primeros 7
    INSERT INTO PV_IdentityValidations (validationdate, validationtype, validationresult, aivalidationresult, validationhash, verified)
    VALUES (
        GETDATE(),
        'Tipo',
        'Aprobado',
        NULL,
        0x01,
        CASE WHEN @i <= 7 THEN 1 ELSE 0 END
    );
    SET @validationid = SCOPE_IDENTITY();

    INSERT INTO PV_IdentityUserValidation (userid, validationid)
    VALUES (@userid, @validationid);

    SET @i = @i + 1;
END
insert into PV_LogTypes (name, ref1description, ref2description, val1description, val2description)
values ('Run Workflow Media', 'mediafileid', 'commentid', 'Hora de inicio','workflowParams')
insert into PV_LogTypes (name, ref1description, ref2description, val1description, val2description)
values ('End Workflow Media', 'mediafileid', 'commentid', 'Hora de finalizacion','Resultado del workflow')
insert into PV_LogTypes (name, ref1description, ref2description, val1description, val2description)
values ('Run Workflow Validez', 'mediafileid', 'commentid', 'Hora de inicio','workflowParams')
insert into PV_LogTypes (name, ref1description, ref2description, val1description, val2description)
values ('End Workflow Validez', 'mediafileid', 'commentid', 'Hora de finalizacion','Resultado del mediafile')
insert into PV_LogTypes (name, ref1description, ref2description, val1description, val2description)
values ('Failed Comment Reason', 'proposalid', 'commentid', 'Hora de Rechazo','Razon del rechazo')
insert into PV_LogSource (name) values ('Workflow');

insert into PV_workflowsType (name) values ('Encriptar documentos');
INSERT INTO PV_workflows (name, description, endpoint, workflowTypeId, params)
VALUES (
  'Encriptar Mediafile',
  'Encripta el archivo f�sico de un mediafile usando la clave proporcionada',
  '/api/workflow/encrypt-mediafile',
  1,
  N'{
    "requiredFields": ["mediafileid", "cryptokeyid", "passwordhash"]
  }'
);
INSERT INTO PV_LogTypes(name, ref1description,  ref2description, val1description, val2description) 
values ('Run Workflow Encryp', 'mediafileid', 'cryptokeyid', 'Hora de inicio', 'mediafileid: ,cryptokeyid:');
INSERT INTO PV_LogTypes(name, ref1description,  ref2description, val1description, val2description) 
values ('End Workflow Encryp', 'mediafileid', 'cryptokeyid', 'Hora de finalizacion', 'Workflow Result');



SET IDENTITY_INSERT PV_UserStatus ON;
INSERT INTO PV_UserStatus (userStatusId, active, verified)
VALUES (99999999, 1, 1);
SET IDENTITY_INSERT PV_UserStatus OFF;

SET IDENTITY_INSERT PV_Users ON;
INSERT INTO PV_Users(userid, email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) 
VALUES (110100100, 'IsaacVillalobosB@gmail.com', 'Isaac', 'Villalobos', '1999-04-20', GETDATE(), 1, GETDATE(), 110100100, 99999999);
SET IDENTITY_INSERT PV_Users OFF;

INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid) 
VALUES (1, CAST('JBSWY3DPEHPK3PXP' AS varbinary(256)), GETDATE(), 1, NULL, 110100100);

INSERT INTO PV_IdentityValidations (
    validationdate, validationtype, validationresult, aivalidationresult, validationhash, workflowId, verified
) VALUES (
    GETDATE(), 'email', 'success', NULL, 0x123456, NULL, 1
);

DECLARE @validation1id INT = SCOPE_IDENTITY();

INSERT INTO PV_IdentityUserValidation (userid, validationid)
VALUES (110100100, @validation1id);

INSERT INTO PV_workflowsType(name)
VALUES( 'Revisi�n de propuesta');

INSERT INTO PV_workflows (name,description,endpoint,workflowTypeId,params)
VALUES ('Validar Propuesta','Workflow para validaci�n autom�tica y manual de propuestas','/api/workflows/validar-propuesta',3,  N'{"ai":{"enabled":true,"threshold":0.8},"review":{"required":true,"roleId":2,"days":7},"autoApprove":false}'
);

insert into PV_LOGTYPES (name, ref1description, ref2description, val1description, val2description)
values ('Lectura Votos', 'userid', 'proposalid', 'voto', 'fecha del voto');


ALTER TABLE PV_Logs ALTER COLUMN value1 NVARCHAR(500);
ALTER TABLE PV_Logs ALTER COLUMN value2 NVARCHAR(500);

ALTER TABLE [dbo].[PV_authSession]
ALTER COLUMN token VARCHAR(MAX) NULL;

ALTER TABLE [dbo].[PV_authSession]
ALTER COLUMN refreshToken VARCHAR(MAX) NULL;

INSERT INTO PV_AuthPlatforms (name, secretKey, [key], iconURL)
VALUES ('google', 123, 123, 'google.com/url');

INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) VALUES ('Mejora de Infraestructura', 'Proyectos de mejora de infraestructura urbana', 1, 1, 2);
INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) VALUES ('Programa Social', 'Programas de desarrollo social comunitario', 1, 1, 3);

-- Estados de propuesta
INSERT INTO PV_ProposalStatus (name, description) VALUES ('Borrador', 'Propuesta en preparaci�n');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('En Revisi�n', 'Propuesta sometida para revisi�n');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('Aprobada', 'Propuesta aprobada para votaci�n');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('Rechazada', 'Propuesta rechazada');

-- Obtener el primer usuario para usarlo como createdby
DECLARE @firstUserId INT = (SELECT TOP 1 userid FROM PV_Users ORDER BY userid);

INSERT INTO PV_Proposals (title, description, proposalcontent, budget, createdby, createdon, lastmodified, proposaltypeid, statusid, organizationid, checksum, version)
VALUES ('Renovación del Parque Central', 'Proyecto de renovación del Parque Central de San José.', 'Contenido detallado del proyecto.', 50000000.00, @firstUserId, GETDATE(), GETDATE(), 1, 1, NULL, 0x00, 1);
INSERT INTO PV_Proposals (title, description, proposalcontent, budget, createdby, createdon, lastmodified, proposaltypeid, statusid, organizationid, checksum, version)
VALUES ('Plataforma de Telemedicina', 'Proyecto de salud digital para zonas rurales.', 'Contenido detallado.', 20000000.00, @firstUserId, GETDATE(), GETDATE(), 2, 1, NULL, 0x00, 1);

INSERT INTO PV_VotingQuestions (question, questionTypeId, createdDate, checksum) VALUES ('�Est� de acuerdo con la propuesta?', 1, GETDATE(), 0x00);
INSERT INTO PV_VotingQuestions (question, questionTypeId, createdDate, checksum) VALUES ('�Est� usted a favor?', 2, GETDATE(), 0x00);

INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeId, allowweightedvotes, requiresallvoters, notificationmethodid, userid, configureddate, statusid, publisheddate, finalizeddate, publicVoting, checksum) VALUES (1, DATEADD(day, 1, GETDATE()), DATEADD(day, 10, GETDATE()), 1, 0, 0, 1, @firstUserId, GETDATE(), 1, NULL, NULL, 1, 0x00);
INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeId, allowweightedvotes, requiresallvoters, notificationmethodid, userid, configureddate, statusid, publisheddate, finalizeddate, publicVoting, checksum) VALUES (2, DATEADD(day, 2, GETDATE()), DATEADD(day, 12, GETDATE()), 2, 1, 1, 2, @firstUserId, GETDATE(), 1, NULL, NULL, 1, 0x00);

INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (1, 'S�', 1, 1, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (1, 'No', 2, 1, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (2, 'A favor', 1, 2, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (2, 'En contra', 2, 2, 0x00);

INSERT INTO PV_LogSource (name) values ('API');
INSERT INTO PV_LogSeverity (name) values ('INFO');
INSERT INTO PV_LogSeverity (name) values ('Warning');

INSERT INTO pV_ProposasalCommentStatus (status) values ('Aprobado');
INSERT INTO pV_ProposasalCommentStatus (status) values ('pendiente');
INSERT INTO pV_ProposasalCommentStatus (status) values ('Rechazado');