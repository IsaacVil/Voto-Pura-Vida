-- V7__simple_testing_data.sql
-- Datos simples para testing de endpoints

-- Insertar usuarios para testing usando UserStatus existentes
SET IDENTITY_INSERT PV_Users ON;

INSERT INTO PV_Users (userid, email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) 
VALUES (10, 'test.mfa@votopuravida.cr', 'Usuario', 'TestMFA', '1990-01-01', GETDATE(), 1, GETDATE(), 118880001, 1);

INSERT INTO PV_Users (userid, email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) 
VALUES (11, 'test.sms@votopuravida.cr', 'Usuario', 'TestSMS', '1985-05-15', GETDATE(), 2, GETDATE(), 118880002, 1);

INSERT INTO PV_Users (userid, email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) 
VALUES (12, 'test.email@votopuravida.cr', 'Usuario', 'TestEmail', '1992-12-25', GETDATE(), 1, GETDATE(), 118880003, 1);

SET IDENTITY_INSERT PV_Users OFF;

-- Métodos MFA adicionales
INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('TOTP', 'Autenticación por app de código temporal', 1);
INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('SMS', 'Código enviado por SMS', 1);
INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('Email', 'Código enviado por correo', 1);

-- Configuraciones MFA para usuarios de prueba
INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid) 
VALUES (1, CAST('JBSWY3DPEHPK3PXP' AS varbinary(256)), GETDATE(), 1, 1, 10);

INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid) 
VALUES (2, CAST('+50688887777' AS varbinary(256)), GETDATE(), 1, 1, 11);

INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid) 
VALUES (3, CAST('test.email@votopuravida.cr' AS varbinary(256)), GETDATE(), 1, 1, 12);

-- Asignación de usuarios a segmentos existentes
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive) VALUES (10, 1, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive) VALUES (11, 2, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive) VALUES (12, 1, GETDATE(), 1);

PRINT 'V7: Datos básicos de testing insertados exitosamente';
PRINT 'Usuarios con MFA: 10 (TOTP), 11 (SMS), 12 (Email)';
PRINT '¡Listo para testing de MFA y endpoints básicos!';
