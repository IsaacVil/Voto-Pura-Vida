INSERT INTO dbo.PV_mediaTypes (name, playerimpl) 
VALUES 
('PDF', 'PDFReader'),
('MP3', 'AudioPlayer'),
('MP4', 'VideoPlayer'),
('JPEG', 'ImageViewer'),
('PDF', 'PDFReader'),
('JPEG', 'ImageViewer');


-- 1. Asegura que existan al menos dos géneros y un método MFA
IF NOT EXISTS (SELECT 1 FROM PV_Genders WHERE name = 'Masculino')
    INSERT INTO PV_Genders (name) VALUES ('Masculino');
IF NOT EXISTS (SELECT 1 FROM PV_Genders WHERE name = 'Femenino')
    INSERT INTO PV_Genders (name) VALUES ('Femenino');
IF NOT EXISTS (SELECT 1 FROM PV_MFAMethods WHERE name = 'TOTP')
    INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('TOTP', 'Test MFA', 1);

-- 2. Inserta 10 status (autoincremental)
DECLARE @statusId INT, @genderId INT, @mfaMethodId INT, @validationid INT, @i INT = 1;

-- Obtén los IDs de género y método MFA
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

    -- Alterna género
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

    -- Validación de identidad solo para los primeros 7
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
