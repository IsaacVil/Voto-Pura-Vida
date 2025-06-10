use [VotoPuraVida]
-- data_seeding.sql generado automáticamente para poblar la base de datos VotoPuraVida
-- Catálogos principales

-- Idiomas
INSERT INTO PV_Languages (name, culture) VALUES ('Español', 'es-CR'), ('Inglés', 'en-US');

-- Monedas
INSERT INTO PV_Currency (name, symbol, acronym) VALUES ('Colón Costarricense', '₡', 'CRC'), ('Dólar Estadounidense', '$', 'USD');

-- Países
INSERT INTO PV_Countries (name, languageid, currencyid) VALUES ('Costa Rica', 1, 1);

-- Estados
INSERT INTO PV_States (name, countryid) VALUES ('San José', 1), ('Alajuela', 1);

-- Ciudades
INSERT INTO PV_Cities (name, stateid) VALUES ('San José Centro', 1), ('Escazú', 1);

-- Géneros
INSERT INTO PV_Genders (name) VALUES ('Masculino'), ('Femenino'), ('No binario');

-- Roles
INSERT INTO PV_Roles (name) VALUES ('Administrador'), ('Validador'), ('Organizador'), ('Ciudadano'), ('Analista');

-- Módulos
INSERT INTO PV_Modules (name) VALUES ('Usuarios'), ('Propuestas'), ('Votaciones'), ('Organizaciones'), ('Finanzas'), ('Reportes'), ('Seguridad'), ('Sistema');

-- Permisos
INSERT INTO PV_Permissions (description, code, moduleid) VALUES
('Ver usuarios', 'usrs.view', 1),
('Crear usuarios', 'usrs.crear', 1),
('Editar usuarios', 'usrs.edit', 1),
('Eliminar usuarios', 'usrs.del', 1),
('Ver propuestas', 'props.view', 2),
('Crear propuestas', 'props.crea', 2),
('Editar propuestas', 'props.edit', 2),
('Aprobar propuestas', 'props.aprv', 2),
('Ver votaciones', 'vot.view', 3),
('Crear votaciones', 'vot.crea', 3),
('Votar', 'vot.votar', 3),
('Ver organizaciones', 'orgs.view', 4),
('Ver finanzas', 'fin.view', 5),
('Ver reportes', 'rep.view', 6),
('Admin seg', 'seg.adm', 7),
('Admin sist', 'sys.adm', 8);

-- Tipos de pregunta 
INSERT INTO PV_questionType ([type]) VALUES ('Sí/No'), ('Múltiple Opción'), ('Abierta');

-- Preguntas de votación 
SET IDENTITY_INSERT PV_VotingQuestions ON;
INSERT INTO PV_VotingQuestions (questionId, question, questionTypeId, createdDate, checksum) VALUES
(1, '¿Está de acuerdo con la propuesta?', 1, GETDATE(), 0x00),
(2, '¿Está usted a favor?', 2, GETDATE(), 0x00);
SET IDENTITY_INSERT PV_VotingQuestions OFF;

-- Estados de votación 
INSERT INTO PV_VotingStatus (name, description) VALUES
('Configurada', 'Configuración creada'),
('En curso', 'Votación activa'),
('Finalizada', 'Votación finalizada'),
('Cancelada', 'Votación cancelada');

-- Tipos de propuesta
INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) VALUES
('Mejora de Infraestructura', 'Proyectos de mejora de infraestructura urbana', 1, 1, 2),
('Programa Social', 'Programas de desarrollo social comunitario', 1, 1, 3);

-- Estados de propuesta
INSERT INTO PV_ProposalStatus (name, description) VALUES
('Borrador', 'Propuesta en preparación'),
('En Revisión', 'Propuesta sometida para revisión'),
('Aprobada', 'Propuesta aprobada para votación'),
('Rechazada', 'Propuesta rechazada');

-- Tipos de votación
INSERT INTO PV_VotingTypes (name) VALUES ('Votación Simple'), ('Votación Ponderada');

-- Métodos de notificación
INSERT INTO PV_NotificationMethods (name, description) VALUES ('Email', 'Notificación por correo electrónico'), ('SMS', 'Notificación por mensaje de texto');

-- Estado de usuario 
INSERT INTO PV_UserStatus (active, verified) VALUES (1, 1), (1, 0), (0, 0);


-- Tipos de documento 
INSERT INTO PV_DocumentTypes (name, description) VALUES ('Cédula', 'Documento nacional de identidad'), ('Pasaporte', 'Documento internacional');

-- Usuarios 
INSERT INTO PV_Users (email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) VALUES
('admin@votopuravida.cr', 'Administrador', 'Sistema', '1980-01-01', GETDATE(), 1, GETDATE(), 101234567, 1),
('validator@votopuravida.cr', 'María', 'Validadora', '1975-05-15', GETDATE(), 2, GETDATE(), 201234567, 2);

-- Organizaciones 
INSERT INTO PV_Organizations (name, description, userid, createdAt, legalIdentification, OrganizationTypeId, MinJointVentures) VALUES
('Municipalidad de San José', 'Gobierno local de la capital', 1, GETDATE(), '3-101-123456', 1, 0);

-- Roles a usuarios
INSERT INTO PV_UserRoles (userid, roleid, lastupdate, enabled, deleted) VALUES (1, 1, GETDATE(), 1, 0), (2, 2, GETDATE(), 1, 0);

-- Propuestas (referencian organización ya insertada)
INSERT INTO PV_Proposals (title, description, proposalcontent, budget, createdby, createdon, lastmodified, proposaltypeid, statusid, organizationid, checksum, version) VALUES
('Renovación del Parque Central', 'Proyecto de renovación del Parque Central de San José.', 'Contenido detallado del proyecto.', 50000000.00, 1, GETDATE(), GETDATE(), 1, 3, 1, 0x00, 1);


-- Configuración de votación y opciones
INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeId, allowweightedvotes, requiresallvoters, notificationmethodid, userid, configureddate, statusid, publicVoting, checksum) VALUES
(1, DATEADD(day, 1, GETDATE()), DATEADD(day, 10, GETDATE()), 1, 0, 0, 1, 1, GETDATE(), 1, 1, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (1, 'Sí', 1, 1, 0x00), (1, 'No', 2, 1, 0x00);

-- Segmentos de población
INSERT INTO PV_SegmentTypes (name, description) VALUES ('Geográfico', 'Segmentación por ubicación geográfica');
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('San José Centro', 'Residentes del centro de San José', 1);

-- Asignación de segmentos a usuarios 
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive) VALUES (1, 1, GETDATE(), 1);

-- Fondos
INSERT INTO PV_Funds (name) VALUES ('Fondo Municipal General');

-- Balances 
INSERT INTO PV_Balances (balance, lastbalance, lastupdate, checksum, userid, fundid, organizationId) VALUES (1000000, 900000, GETDATE(), 0x00, 1, 1, 1);

-- Reporte financiero 
INSERT INTO PV_FinancialReports (proposalid, reportperiod, totalrevenue, totalexpenses, netprofit, availablefordividends, submitteddate) VALUES (1, '2025-Q1', 1000000, 500000, 500000, 200000, GETDATE());

-- Ejemplo de ejecución de plan
INSERT INTO PV_ExecutionPlans (proposalid, totalbudget, expectedStartdate, expectedenddate, createddate, expectedDurationInMonths) VALUES (1, 50000000.00, GETDATE(), DATEADD(month, 6, GETDATE()), GETDATE(), 6);

-- Seguridad y MFA
INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES
('TOTP', 'Time-based One-Time Password', 1),
('SMS', 'SMS Code', 1),
('Email', 'Email Code', 1);

-- Insert MFA records 
INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid,userid) VALUES
(1, CAST('JBSWY3DPEHPK3PXP' AS varbinary(256)), GETDATE(), 1, NULL, 1), 
(2, CAST('+50688888888' AS varbinary(256)), GETDATE(), 1, NULL, 2),     
(3, CAST('ana.mendez@coopverde.cr' AS varbinary(256)), GETDATE(), 1, NULL, 1),
(1, CAST('LUISOTPSECRET' AS varbinary(256)), GETDATE(), 1, NULL, 2);     

-- Validaciones de identidad 
INSERT INTO PV_IdentityValidations (validationdate, validationtype, validationresult, aivalidationresult, validationhash, verified) VALUES
(GETDATE(), 'Prueba de vida', 'Aprobado', 'Validación facial exitosa', 0x01, 1),
(GETDATE(), 'Documento', 'Aprobado', 'Cédula verificada por IA', 0x02, 1),
(GETDATE(), 'Prueba de vida', 'Desaprobado', 'Validación facial Error', 0x01, 0),
(GETDATE(), 'Documento', 'Desaprobado', 'Cédula no verificada por el humano', 0x02, 0),
(GETDATE(), 'Prueba de vida', 'Desaprobado', 'Se encontro que esta muerta la persona', 0x01, 0),
(GETDATE(), 'Documento', 'Aprobado', 'Cédula Juridica verificada por IA', 0x02, 1);

-- Documentos y verificación periódica
SET IDENTITY_INSERT PV_Documents ON;
INSERT INTO PV_Documents (documenthash, aivalidationstatus, aivalidationresult, humanvalidationrequired, mediafileId, periodicVerificationId, documentTypeId, version)
VALUES (1, 0x01, 'Pending', NULL, 0, NULL, NULL, 1),
       (2, 0x02, 'Pending', NULL, 0, NULL, NULL, 2);
SET IDENTITY_INSERT PV_Documents OFF;

-- Propuestas y crowdfunding
INSERT INTO PV_Proposals (title, description, proposalcontent, budget, createdby, createdon, lastmodified, proposaltypeid, statusid, organizationid, checksum, version) VALUES
('Plataforma de Telemedicina', 'Proyecto de salud digital para zonas rurales.', 'Contenido detallado.', 20000000.00, 2, GETDATE(), GETDATE(), 2, 1, 1, 0x00, 1);
INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeId, allowweightedvotes, requiresallvoters, notificationmethodid, userid, configureddate, statusid, publicVoting, checksum) VALUES
(2, DATEADD(day, 2, GETDATE()), DATEADD(day, 12, GETDATE()), 2, 1, 1, 2, 2, GETDATE(), 1, 1, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (2, 'A favor', 1, 2, 0x00), (2, 'En contra', 2, 2, 0x00);



-- Configuración avanzada de votación y segmentación
INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeId, allowweightedvotes, requiresallvoters, notificationmethodid, userid, configureddate, statusid, publicVoting, checksum) VALUES
(2, DATEADD(day, 2, GETDATE()), DATEADD(day, 12, GETDATE()), 2, 1, 1, 2, 2, GETDATE(), 1, 1, 0x00);

INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (2, 'A favor', 1, 2, 0x00), (2, 'En contra', 2, 2, 0x00);

INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Jóvenes 18-25', 'Ciudadanos entre 18 y 25 años', 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive) VALUES (2, 2, GETDATE(), 1);

-- Inversión y desembolsos
INSERT INTO PV_Investments (proposalid, amount, equitypercentage, investmentdate, investmenthash, checksum) VALUES
(2, 1000000, 2.0, GETDATE(), 0x00, 0x00),
(2, 500000, 1.0, GETDATE(), 0x00, 0x00);

-- Reportes financieros
INSERT INTO PV_FinancialReports (proposalid, reportperiod, totalrevenue, totalexpenses, netprofit, availablefordividends, submitteddate) VALUES (2, '2025-Q2', 2000000, 1000000, 1000000, 500000, GETDATE());

-- Permisos y roles de usuario
INSERT INTO PV_UserPermissions (enabled, deleted, lastupdate, checksum, userid, permissionid) VALUES
(1, 0, GETDATE(), 0x00, 1, 1),
(1, 0, GETDATE(), 0x00, 2, 2);

-- Votaciones y votos
INSERT INTO PV_Votes (votingconfigid, votercommitment, encryptedvote, votehash, nullifierhash, votedate, blockhash, merkleproof, blockchainId, checksum, userid, publicResult) VALUES
(1, 0x01, 0xA1, 0xB1, 0xC1, GETDATE(), 0xD1, NULL, NULL, 0x00, 1, NULL),
(2, 0x02, 0xA2, 0xB2, 0xC2, GETDATE(), 0xD2, NULL, NULL, 0x00, 2, NULL);

INSERT INTO PV_AIAnalysisType (name) VALUES ('Análisis de Propuesta'), ('Análisis de Inversión');

INSERT INTO PV_AIProviders (name, baseurl, description, isactive, createdate) VALUES ('Google Document AI', 'https://docai.googleapis.com', 'Validación de documentos', 1, GETDATE());
INSERT INTO PV_AIModelTypes (name) VALUES ('OCR'), ('Clasificación');
INSERT INTO PV_AIModels (providerid, modelname, displayname, modeltypeId, maxinputtokens, maxoutputtokens, costperinputtoken, costperoutputtoken, isactive, createdate) VALUES (1, 'ocr-v1', 'OCR Básico', 1, 4096, 1024, 0.0001, 0.0002, 1, GETDATE());

INSERT INTO PV_AIConnections (providerid, connectionname, publicKey, privateKey, organizationid, environment, isactive, createdby, createdate, usagecount, modelId) VALUES (1, 'Conexión DocAI', 0x01, 0x02, 1, 'production', 1, 1, GETDATE(), 0, 1);

INSERT INTO PV_AIDocumentAnalysis (documentid, analysisDocTypeId, confidence, result, findings, extracteddata, flags, humanreviewrequired, reviewerid, analysisdate, AIConnectionId) VALUES (1, 1, 0.98, 'Aprobado', 'Documento legible', 'Nombre: Admin', NULL, 0, 2, GETDATE(), 1);

INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES
('TOTP', 'Autenticación por app de código temporal', 1),
('SMS', 'Código enviado por SMS', 0),
('Email', 'Código enviado por correo', 0);

INSERT INTO PV_OrganizationTypes (name) VALUES ('Municipalidad'), ('ONG'), ('Empresa Privada');

INSERT INTO PV_LogSeverity (name) VALUES ('Info'), ('Warning'), ('Error'), ('Critical');
INSERT INTO PV_LogSource (name) VALUES ('Web'), ('API'), ('Mobile'), ('Batch');
INSERT INTO PV_LogTypes (name, ref1description, ref2description, val1description, val2description) VALUES
('Acceso', 'Usuario', 'IP', 'Resultado', 'Método'),
('Votación', 'Votación', 'Usuario', 'Opción', 'Hash'),
('Inversión', 'Usuario', 'Propuesta', 'Monto', 'Estado');

INSERT INTO PV_ReportTypes (reportTypeId, name) VALUES (1, 'Denuncia'), (2, 'Error de Proceso'), (3, 'Auditoría');

-- Ejemplo de blockchain y wallets
INSERT INTO PV_BlockchainParams (wallet_address, wallet_private_key_encrypted, wallet_public, blockchain_network, blockchain_rpc_url, blockchain_chain_id, blockchain_explorer_url, gas_price_default, gas_limit_default, gas_currency) VALUES ('0x1234', 0x00, '0xPUB', 'Ethereum', 'https://rpc.ethereum.org', 1, 'https://etherscan.io', 0.000021, 21000, 'ETH');
INSERT INTO PV_blockchain (blockchainParamsId, createdDate, updateDate) VALUES (1, GETDATE(), GETDATE());

-- Ejemplo de llaves criptográficas
INSERT INTO PV_CryptoKeys (encryptedpublickey, encryptedprivatekey, createdAt, userid, organizationid, expirationdate, status) VALUES (0x01, 0x02, GETDATE(), 1, 1, DATEADD(year,1,GETDATE()), 'Activo');

-- Ejemplo de métodos de pago y pagos
INSERT INTO PV_PaymentMethods (name, APIURL, secretkey, [key], logoiconurl, enabled) VALUES ('Banco CR', 'https://api.bancocr.com', 0x00, 0x00, 'https://bancocr.com/logo.png', 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 1, 1);
INSERT INTO PV_Payment (amount, actualamount, result, reference, auth, chargetoken, description, date, checksum, moduleid, paymentmethodid, availablemethodid, userid) VALUES (10000, 10000, 1, 'INV-001', 'AUTH1', 0x00, 'Pago de inversión', GETDATE(), 0x00, 5, 1, 1, 1);

-- Ejemplo de schedules y verificación periódica
INSERT INTO PV_RecurrencyType (name) VALUES ('Mensual');
INSERT INTO PV_EndType (name) VALUES ('Por Fecha');
INSERT INTO PV_Schedules (name, repetitions, enddate, recurrencytypeid, endtypeid) VALUES ('Verificación Mensual', 12, DATEADD(year,1,GETDATE()), 1, 1);
INSERT INTO PV_periodicVerification (scheduleId, lastupdated, enabled) VALUES (1, GETDATE(), 1);

-- Ejemplo de monitoreo y reportes
INSERT INTO PV_ProjectMonitoring (proposalid, reportedby, reportdate, reporttypeId, description, evidence, statusid) VALUES (2, 2, GETDATE(), 1, 'Denuncia de irregularidad', 'Evidencia adjunta', 1);
INSERT INTO PV_ProjectMonitoring (proposalid, reportedby, reportdate, reporttypeId, description, evidence, statusid) VALUES (1, 2, GETDATE(), 1, 'Monitoreo de rutina', 'Todo en orden', 3);

-- Ejemplo de métricas y resultados de votación
INSERT INTO PV_VotingMetricsType (name) VALUES ('Participación'), ('Aprobación');
INSERT INTO PV_VotingMetrics (votingconfigid, metrictypeId, metricvalue, segmentid, calculateddate, isactive) VALUES (1, 1, 80.5, 1, GETDATE(), 1);
INSERT INTO PV_VoteResults (votingconfigid, optionid, votecount, weightedcount, lastupdated, creationDate, checksum) VALUES (1, 1, 100, 100.0, GETDATE(), GETDATE(), 0x00);

-- Ejemplo de traducciones
INSERT INTO PV_Translation (code, caption, enabled, languageid, moduleid) VALUES ('welcome', 'Bienvenido', 1, 1, 1), ('welcome', 'Welcome', 1, 2, 1);

-- Ejemplo de asignación de usuario a organización
INSERT INTO PV_OrganizationPerUser (userId, organizationId) VALUES (2, 1);

-- Ejemplo de permisos y roles a organización
INSERT INTO PV_OrganizationPermissions (organizationid, permissionid, enabled, deleted, assigneddate, lastupdate, checksum) VALUES (1, 1, 1, 0, GETDATE(), GETDATE(), 0x00);
INSERT INTO PV_OrganizationRoles (organizationid, roleid, enabled, deleted, assigneddate, lastupdate, checksum) VALUES (1, 1, 1, 0, GETDATE(), GETDATE(), 0x00);

-- Ejemplo de comentarios de propuesta y documentos asociados
INSERT INTO PV_ProposasalCommentStatus (status) VALUES ('Aprobado'), ('Pendiente'), ('Rechazado');
INSERT INTO PV_ProposalComments (proposalid, userid, comment, commentdate, statusid) VALUES (2, 2, 'Comentario de fiscalización.', GETDATE(), 1);
INSERT INTO PV_proposalCommentDocuments (documentId, commentId) VALUES (1, 1);


-- Ejemplo de opciones de votación
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES
(1, 'Sí', 1, 1, 0x00), (1, 'No', 2, 1, 0x00),
(2, 'A favor', 1, 2, 0x00), (2, 'En contra', 2, 2, 0x00);

-- Más países
INSERT INTO PV_Languages (name, culture) VALUES ('Francés', 'fr-FR');
INSERT INTO PV_Currency (name, symbol, acronym) VALUES ('Euro', '€', 'EUR');
INSERT INTO PV_Countries (name, languageid, currencyid) VALUES ('Estados Unidos', 2, 2), ('Francia', 3, 3);
INSERT INTO PV_States (name, countryid) VALUES ('California', 2), ('Île-de-France', 3);
INSERT INTO PV_Cities (name, stateid) VALUES ('Los Angeles', 3), ('Paris', 4);

-- Más usuarios
INSERT INTO PV_Users (email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) VALUES
('john.doe@us.com', 'John', 'Doe', '1990-07-20', GETDATE(), 1, GETDATE(), 301234567, 1),
('jeanne.dupont@fr.fr', 'Jeanne', 'Dupont', '1985-03-12', GETDATE(), 2, GETDATE(), 401234567, 1),
('sofia.garcia@votopuravida.cr', 'Sofía', 'García', '2002-11-05', GETDATE(), 3, GETDATE(), 501234567, 1);


-- Más direcciones
INSERT INTO PV_Addresses (line1, line2, zipcode, geoposition, cityid) VALUES
('123 Main St', 'Apt 4', '90001', geometry::Point(34.0522, -118.2437, 4326), 3),
('10 Rue de Rivoli', '2ème étage', '75001', geometry::Point(48.8566, 2.3522, 4326), 4),
('Barrio Escalante', 'Casa azul', '10102', geometry::Point(9.935, -84.05, 4326), 2);

-- Asignar direcciones a usuarios
INSERT INTO PV_UserAddresses (userid, addressid, addresstype, isactive, assigneddate) VALUES
(3, 1, 'Residencial', 1, GETDATE()),
(4, 2, 'Residencial', 1, GETDATE()),
(5, 3, 'Residencial', 1, GETDATE());

-- Más organizaciones
INSERT INTO PV_Organizations (name, description, userid, createdAt, legalIdentification, OrganizationTypeId, MinJointVentures) VALUES
('ONG Esperanza', 'Organización sin fines de lucro', 3, GETDATE(), '3-202-987654', 2, 0),
('Tech4Good', 'Empresa de tecnología social', 4, GETDATE(), '3-303-456789', 3, 0);

-- Ejemplo de allowed countries/IPs
INSERT INTO PV_AllowedCountries (countryid, isallowed, createddate, lastmodified) VALUES (1, 1, GETDATE(), GETDATE());
INSERT INTO PV_AllowedIPs (ipaddress, ipmask, addressid, isallowed, description, createddate, lastmodified, checksum) VALUES ('190.10.10.1', NULL, 1, 1, 'IP admin', GETDATE(), GETDATE(), 0x00);




------------------------------- PARTE CON MAS COSAS QUE EJECUTAR

-- Insertar géneros (ya existen, pero por claridad)
INSERT INTO dbo.PV_Genders (name)
VALUES ('Hombre'), ('Mujer'), ('Otro');

-- Insertar un user status (solo uno, ambos usuarios usan el mismo)
INSERT INTO dbo.PV_UserStatus (active, verified)
VALUES (1,1);

DECLARE @genderId1 INT, @genderId2 INT, @userStatusId INT;
DECLARE @userId1 INT, @userId2 INT;
DECLARE @mfaMethodId INT, @mfaId1 INT, @mfaId2 INT;
DECLARE @workflowTypeId INT, @workflowId INT;
DECLARE @validationId1 INT, @validationId2 INT;

-- Obtener los IDs de género y status
SELECT TOP 1 @genderId1 = genderId FROM dbo.PV_Genders WHERE name = 'Hombre' ORDER BY genderId DESC;
SELECT TOP 1 @genderId2 = genderId FROM dbo.PV_Genders WHERE name = 'Mujer' ORDER BY genderId DESC;
SELECT TOP 1 @userStatusId = userStatusId FROM dbo.PV_UserStatus ORDER BY userStatusId DESC;

-- Insertar primer usuario
INSERT INTO dbo.PV_Users (email, firstname, lastname, birthdate, createdAt,
    genderId, lastupdate, userStatusId, dni
)
VALUES (
    'Villalobos12@example.com',
    'Isaac',
    'Villalobos',
    '1995-05-15',
    GETDATE(),
    @genderId1,
    GETDATE(),
    @userStatusId,
    209876543
);

-- Insertar segundo usuario
INSERT INTO dbo.PV_Users (
    email, firstname, lastname, birthdate, createdAt,
    genderId, lastupdate, userStatusId, dni
)
VALUES (
    'Maria.Garcia@example.com',
    'Maria',
    'Garcia',
    '1992-08-22',
    GETDATE(),
    @genderId2,
    GETDATE(),
    @userStatusId,
    309876544
);

-- Obtener los userId
SELECT TOP 1 @userId1 = userid FROM dbo.PV_Users WHERE email = 'Villalobos12@example.com' ORDER BY userid DESC;
SELECT TOP 1 @userId2 = userid FROM dbo.PV_Users WHERE email = 'Maria.Garcia@example.com' ORDER BY userid DESC;

-- Insertar claves para ambos usuarios
INSERT INTO dbo.PV_CryptoKeys (
    encryptedpublickey, encryptedprivatekey, createdAt, userid, organizationid, expirationdate, status
) VALUES (
    0x0123456789ABCDEF, 0xFEDCBA9876543210, GETDATE(), @userId1, NULL, DATEADD(YEAR, 1, GETDATE()), 'active'
), (
    0x2233445566778899, 0x9988776655443322, GETDATE(), @userId2, NULL, DATEADD(YEAR, 1, GETDATE()), 'active'
);

-- Insertar método MFA (solo uno, ambos usuarios lo usan)
INSERT INTO dbo.PV_MFAMethods (name, description, requiressecret)
VALUES ('TOTP', 'Autenticación por código temporal (Google Authenticator, Authy, etc.)', 1);

SELECT TOP 1 @mfaMethodId = MFAmethodid FROM dbo.PV_MFAMethods WHERE name = 'TOTP' ORDER BY MFAmethodid DESC;

-- Insertar MFA para ambos usuarios
INSERT INTO dbo.PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid)
VALUES
(@mfaMethodId, 0xAABBCCDDEEFF00112233445566778899, GETDATE(), 1, NULL, 1),
(@mfaMethodId, 0x112233445566778899AABBCCDDEEFF00, GETDATE(), 1, NULL, 1);

-- Crear workflow type (solo uno)
INSERT INTO dbo.PV_workflowsType ([name])
VALUES ('Prueba de Vida');

SELECT TOP 1 @workflowTypeId = workflowTypeId FROM dbo.PV_workflowsType WHERE [name] = 'Prueba de Vida' ORDER BY workflowTypeId DESC;

-- Crear workflow (solo uno)
INSERT INTO dbo.PV_workflows ([name], [description], [endpoint], [workflowTypeId], [params])
VALUES (
    'Prueba de Vida Workflow','Workflow para validación de prueba de vida','/api/liveness/check',@workflowTypeId,NULL
);

SELECT TOP 1 @workflowId = workflowId FROM dbo.PV_workflows WHERE [name] = 'Prueba de Vida Workflow' ORDER BY workflowId DESC;

-- Crear una validación de identidad para cada usuario
INSERT INTO dbo.PV_IdentityValidations (
    validationdate, validationtype, validationresult, aivalidationresult, validationhash, workflowId, verified
)
VALUES
(GETDATE(), 'liveness', 'success', 'El usuario pasó la prueba de vida', HASHBYTES('SHA2_256', CAST(@userId1 AS NVARCHAR(20)) + CAST(GETDATE() AS NVARCHAR(30))), @workflowId, 1),
(GETDATE(), 'liveness', 'success', 'La usuaria pasó la prueba de vida', HASHBYTES('SHA2_256', CAST(@userId2 AS NVARCHAR(20)) + CAST(GETDATE() AS NVARCHAR(30))), @workflowId, 1);

SELECT TOP 1 @validationId1 = validationid FROM dbo.PV_IdentityValidations ORDER BY validationid DESC;

-- Relacionar usuarios con sus validaciones
INSERT INTO dbo.PV_IdentityUserValidation (userid, validationid)
VALUES (@userId1, @validationId1), (@userId2, @validationId1);

-- Asumiendo que ya existe el usuario Maria.Garcia@example.com

DECLARE @userIdMaria INT;
SELECT TOP 1 @userIdMaria = userid FROM dbo.PV_Users WHERE email = 'Maria.Garcia@example.com';

-- Crear un proposal status y type si no existen
IF NOT EXISTS (SELECT 1 FROM dbo.PV_ProposalStatus WHERE name = 'Abierto')
    INSERT INTO dbo.PV_ProposalStatus (name, description) VALUES ('Abierto', 'Propuesta abierta');

IF NOT EXISTS (SELECT 1 FROM dbo.PV_ProposalTypes WHERE name = 'General')
    INSERT INTO dbo.PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount)
    VALUES ('General', 'Propuesta general', 0, 0, 1);

DECLARE @proposalStatusId INT, @proposalTypeId INT;
SELECT TOP 1 @proposalStatusId = statusid FROM dbo.PV_ProposalStatus WHERE name = 'Abierto' ORDER BY statusid DESC;
SELECT TOP 1 @proposalTypeId = proposaltypeid FROM dbo.PV_ProposalTypes WHERE name = 'General' ORDER BY proposaltypeid DESC;

-- Crear la propuesta
INSERT INTO dbo.PV_Proposals (
    title, description, proposalcontent, budget, createdby, createdon, lastmodified, proposaltypeid, statusid, organizationid, checksum, version
)
VALUES (
    'Propuesta de Maria',
    'Descripción de la propuesta de Maria',
    'Contenido detallado de la propuesta de Maria',
    10000.00,
    @userIdMaria,
    GETDATE(),
    GETDATE(),
    @proposalTypeId,
    @proposalStatusId,
    NULL,
    HASHBYTES('SHA2_256', CAST(@userIdMaria AS NVARCHAR(20)) + CAST(GETDATE() AS NVARCHAR(30))),
    1
);

DECLARE @proposalId INT;
SELECT TOP 1 @proposalId = proposalid FROM dbo.PV_Proposals WHERE createdby = @userIdMaria ORDER BY proposalid DESC;

-- Crear una configuración de votación para la propuesta
IF NOT EXISTS (SELECT 1 FROM dbo.PV_VotingTypes WHERE name = 'Simple')
    INSERT INTO dbo.PV_VotingTypes (name) VALUES ('Simple');

IF NOT EXISTS (SELECT 1 FROM dbo.PV_VotingStatus WHERE name = 'Activo')
    INSERT INTO dbo.PV_VotingStatus (name, description) VALUES ('Activo', 'Votación activa');

DECLARE @votingTypeId INT, @votingStatusId INT;
SELECT TOP 1 @votingTypeId = votingTypeId FROM dbo.PV_VotingTypes WHERE name = 'Simple' ORDER BY votingTypeId DESC;
SELECT TOP 1 @votingStatusId = statusid FROM dbo.PV_VotingStatus WHERE name = 'Activo' ORDER BY statusid DESC;

INSERT INTO dbo.PV_VotingConfigurations (
    proposalid, startdate, enddate, votingtypeId, allowweightedvotes, requiresallvoters, notificationmethodid, userid, configureddate, statusid, publisheddate, finalizeddate, publicVoting, checksum
)
VALUES (
    @proposalId,
    DATEADD(DAY, 1, GETDATE()),         -- Empieza mañana
    DATEADD(DAY, 8, GETDATE()),         -- Termina en una semana
    @votingTypeId,
    0,
    0,
    NULL,
    @userIdMaria,
    GETDATE(),
    @votingStatusId,
    GETDATE(),
    NULL,
    1,
    HASHBYTES('SHA2_256', CAST(@proposalId AS NVARCHAR(20)) + CAST(GETDATE() AS NVARCHAR(30)))
);

-- Obtener el userId de Isaac
DECLARE @userIdIsaac INT;
SELECT TOP 1 @userIdIsaac = userid FROM dbo.PV_Users WHERE email = 'Villalobos12@example.com';

-- Obtener el último votingconfigid creado por Maria (o el que corresponda a la propuesta)
DECLARE @votingConfigId INT;
SELECT TOP 1 @votingConfigId = votingconfigid FROM dbo.PV_VotingConfigurations ORDER BY votingconfigid DESC;

-- Crear un votercommitment (ejemplo, normalmente sería generado por la app)
DECLARE @voterCommitment VARBINARY(256) = 0xDEADBEEF00112233445566778899AABBCCDDEEFF;

-- Registrar a Isaac como votante en el registro de votantes
INSERT INTO dbo.PV_VoterRegistry (
    votingconfigid,
    userid,
    votercommitment,
    registrationdate,
    hasVoted
)
VALUES (
    @votingConfigId,
    @userIdIsaac,
    @voterCommitment,
    GETDATE(),
    1
);

-- Obtener el questionId y optionId para el voto (usamos el primer option de la config)
DECLARE @optionId INT;
SELECT TOP 1 @optionId = optionid FROM dbo.PV_VotingOptions WHERE votingconfigid = @votingConfigId ORDER BY optionorder ASC;

DECLARE @blockId INT;
SELECT TOP 1 @blockId = blockchainId FROM dbo.PV_blockchain ORDER BY blockchainId DESC;


-- Crear un voto para Isaac (valores de ejemplo para encryptedvote, votehash, nullifierhash, blockhash)
INSERT INTO dbo.PV_Votes (
    votingconfigid,
    votercommitment,
    encryptedvote,
    votehash,
    nullifierhash,
    votedate,
    blockhash,
	merkleproof,
	blockchainId,
	checksum,
	userid,
	publicResult
)
VALUES (
    @votingConfigId,
    @voterCommitment,
    0x0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20, -- encryptedvote (ejemplo)
    0x1112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F30, -- votehash (ejemplo)
    0x2122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F40, -- nullifierhash (ejemplo)
    GETDATE(), -- Fecha de voto
    0x3132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F50, -- blockhash (ejemplo)
    NULL, -- merkleproof (puedes poner NULL o un valor binario)
    @blockId,
    0x1234567890ABCDEF, -- checksum (ejemplo)
    @userIdIsaac,
    'A favor'
);













-- Crear 10 usuarios adicionales
DECLARE @nuevoGenderId1 INT, @nuevoGenderId2 INT, @nuevoGenderIdOtro INT, @nuevoUserStatusId INT;
SELECT TOP 1 @nuevoUserStatusId = userStatusId FROM dbo.PV_UserStatus ORDER BY userStatusId DESC;
SELECT TOP 1 @nuevoGenderId1 = genderId FROM dbo.PV_Genders WHERE name = 'Hombre' ORDER BY genderId DESC;
SELECT TOP 1 @nuevoGenderId2 = genderId FROM dbo.PV_Genders WHERE name = 'Mujer' ORDER BY genderId DESC;
SELECT TOP 1 @nuevoGenderIdOtro = genderId FROM dbo.PV_Genders WHERE name = 'Otro' ORDER BY genderId DESC;

DECLARE @nuevoI INT = 1;
WHILE @nuevoI <= 10
BEGIN
    INSERT INTO dbo.PV_Users (email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, userStatusId, dni)
    VALUES (
        CONCAT('user', @nuevoI, '@example.com'),
        CONCAT('Nombre', @nuevoI),
        CONCAT('Apellido', @nuevoI),
        DATEADD(YEAR, -20-@nuevoI, GETDATE()),
        GETDATE(),
        CASE WHEN @nuevoI % 3 = 1 THEN @nuevoGenderId1 WHEN @nuevoI % 3 = 2 THEN @nuevoGenderId2 ELSE @nuevoGenderIdOtro END,
        GETDATE(),
        @nuevoUserStatusId,
        100000000 + @nuevoI
    );
    SET @nuevoI = @nuevoI + 1;
END

-- Crear 10 propuestas y 10 configuraciones de votación
DECLARE @nuevoProposalStatusId INT, @nuevoProposalTypeId INT, @nuevoVotingTypeId INT, @nuevoVotingStatusId INT;
SELECT TOP 1 @nuevoProposalStatusId = statusid FROM dbo.PV_ProposalStatus WHERE name = 'Abierto' ORDER BY statusid DESC;
SELECT TOP 1 @nuevoProposalTypeId = proposaltypeid FROM dbo.PV_ProposalTypes WHERE name = 'General' ORDER BY proposaltypeid DESC;
SELECT TOP 1 @nuevoVotingTypeId = votingTypeId FROM dbo.PV_VotingTypes WHERE name = 'Simple' ORDER BY votingTypeId DESC;
SELECT TOP 1 @nuevoVotingStatusId = statusid FROM dbo.PV_VotingStatus WHERE name = 'Activo' ORDER BY statusid DESC;

DECLARE @nuevoUserId INT, @nuevoProposalId INT, @nuevoVotingConfigId INT, @nuevoBlockId INT;
SELECT TOP 1 @nuevoBlockId = blockchainId FROM dbo.PV_blockchain ORDER BY blockchainId DESC;

SET @nuevoI = 1;
WHILE @nuevoI <= 10
BEGIN
    -- Seleccionar un usuario aleatorio para crear la propuesta
    SELECT TOP 1 @nuevoUserId = userid FROM dbo.PV_Users ORDER BY NEWID();

    INSERT INTO dbo.PV_Proposals (
        title, description, proposalcontent, budget, createdby, createdon, lastmodified, proposaltypeid, statusid, organizationid, checksum, version
    ) VALUES (
        CONCAT('Propuesta ', @nuevoI),
        CONCAT('Descripción de la propuesta ', @nuevoI),
        CONCAT('Contenido detallado de la propuesta ', @nuevoI),
        10000.00 + @nuevoI * 1000,
        @nuevoUserId,
        GETDATE(),
        GETDATE(),
        @nuevoProposalTypeId,
        @nuevoProposalStatusId,
        NULL,
        HASHBYTES('SHA2_256', CAST(@nuevoUserId AS NVARCHAR(20)) + CAST(GETDATE() AS NVARCHAR(30))),
        1
    );

    SELECT TOP 1 @nuevoProposalId = proposalid FROM dbo.PV_Proposals ORDER BY proposalid DESC;

    INSERT INTO dbo.PV_VotingConfigurations (
        proposalid, startdate, enddate, votingtypeId, allowweightedvotes, requiresallvoters, notificationmethodid, userid, configureddate, statusid, publisheddate, finalizeddate, publicVoting, checksum
    ) VALUES (
        @nuevoProposalId,
        DATEADD(DAY, @nuevoI, GETDATE()),
        DATEADD(DAY, @nuevoI+7, GETDATE()),
        @nuevoVotingTypeId,
        0,
        0,
        NULL,
        @nuevoUserId,
        GETDATE(),
        @nuevoVotingStatusId,
        GETDATE(),
        NULL,
        1,
        HASHBYTES('SHA2_256', CAST(@nuevoProposalId AS NVARCHAR(20)) + CAST(GETDATE() AS NVARCHAR(30)))
    );

    SET @nuevoI = @nuevoI + 1;
END

-- Crear opciones de votación para cada configuración (4 opciones por config: a favor, en contra, nulo, se abstiene)
DECLARE @nuevoOptionId INT, @nuevoQuestionId INT;
SET @nuevoI = 1;
WHILE @nuevoI <= 10
BEGIN
    SELECT TOP 1 @nuevoVotingConfigId = votingconfigid FROM dbo.PV_VotingConfigurations WHERE proposalid = @nuevoI ORDER BY votingconfigid DESC;

    -- Crear pregunta
    INSERT INTO dbo.PV_VotingQuestions (question, questionTypeId, createdDate, checksum)
    VALUES (CONCAT('¿Está de acuerdo con la propuesta ', @nuevoI, '?'), 1, GETDATE(), HASHBYTES('SHA2_256', CAST(@nuevoI AS NVARCHAR(20)) + CAST(GETDATE() AS NVARCHAR(30))));

    SELECT TOP 1 @nuevoQuestionId = questionId FROM dbo.PV_VotingQuestions ORDER BY questionId DESC;

    -- Opciones
    INSERT INTO dbo.PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, mediafileId, checksum)
    VALUES 
        (@nuevoVotingConfigId, 'A favor', 1, @nuevoQuestionId, NULL, HASHBYTES('SHA2_256', 'A favor' + CAST(@nuevoI AS NVARCHAR(20)))),
        (@nuevoVotingConfigId, 'En contra', 2, @nuevoQuestionId, NULL, HASHBYTES('SHA2_256', 'En contra' + CAST(@nuevoI AS NVARCHAR(20)))),
        (@nuevoVotingConfigId, 'Se abstiene', 4, @nuevoQuestionId, NULL, HASHBYTES('SHA2_256', 'Se abstiene' + CAST(@nuevoI AS NVARCHAR(20))));
    SET @nuevoI = @nuevoI + 1;
END


-- Registrar a todos los usuarios como votantes en todas las configuraciones (solo una vez por usuario por config)
DECLARE @nuevoUserTable TABLE(userid INT);
INSERT INTO @nuevoUserTable(userid) SELECT userid FROM dbo.PV_Users;

DECLARE @nuevoVotingTable TABLE(votingconfigid INT);
INSERT INTO @nuevoVotingTable(votingconfigid) SELECT votingconfigid FROM dbo.PV_VotingConfigurations;

DECLARE @nuevoVoterCommitment VARBINARY(256);

DECLARE @nuevoU INT, @nuevoV INT;
SET @nuevoU = 1;
WHILE @nuevoU <= (SELECT COUNT(*) FROM @nuevoUserTable)
BEGIN
    SET @nuevoV = 1;
    WHILE @nuevoV <= (SELECT COUNT(*) FROM @nuevoVotingTable)
    BEGIN
        DECLARE @nuevoCurrUserId INT, @nuevoCurrVotingConfigId INT;
        SELECT @nuevoCurrUserId = userid FROM (SELECT ROW_NUMBER() OVER (ORDER BY userid) AS rn, userid FROM @nuevoUserTable) AS t WHERE rn = @nuevoU;
        SELECT @nuevoCurrVotingConfigId = votingconfigid FROM (SELECT ROW_NUMBER() OVER (ORDER BY votingconfigid) AS rn, votingconfigid FROM @nuevoVotingTable) AS t WHERE rn = @nuevoV;

        -- Solo registrar si no existe
        IF NOT EXISTS (SELECT 1 FROM dbo.PV_VoterRegistry WHERE userid = @nuevoCurrUserId AND votingconfigid = @nuevoCurrVotingConfigId)
        BEGIN
            SET @nuevoVoterCommitment = CAST(NEWID() AS VARBINARY(16));
            INSERT INTO dbo.PV_VoterRegistry (votingconfigid, userid, votercommitment, registrationdate, hasVoted)
            VALUES (@nuevoCurrVotingConfigId, @nuevoCurrUserId, @nuevoVoterCommitment, GETDATE(), 0);
        END
        SET @nuevoV = @nuevoV + 1;
    END
    SET @nuevoU = @nuevoU + 1;
END


DECLARE @randomValue INT;
DECLARE @nuevoTotalVotes INT;
-- Insertar más de 20 votos aleatorios, asegurando que cada usuario solo vote una vez por configuración
SET @nuevoTotalVotes = 0;
WHILE @nuevoTotalVotes < 70
BEGIN
    -- Usuario y configuración aleatorios
    SELECT TOP 1 @nuevoUserId = userid FROM dbo.PV_Users ORDER BY NEWID();
    SELECT TOP 1 @nuevoVotingConfigId = votingconfigid FROM dbo.PV_VotingConfigurations ORDER BY NEWID();

    -- Solo si no ha votado ya en esa config
    IF NOT EXISTS (SELECT 1 FROM dbo.PV_Votes WHERE userid = @nuevoUserId AND votingconfigid = @nuevoVotingConfigId)
    BEGIN
        -- Obtener commitment del registro
        SELECT TOP 1 @nuevoVoterCommitment = votercommitment FROM dbo.PV_VoterRegistry WHERE userid = @nuevoUserId AND votingconfigid = @nuevoVotingConfigId;

        -- Elegir opción según probabilidad
        SET @randomValue = CAST(RAND(CHECKSUM(NEWID())) * 100 AS INT);
        IF @randomValue < 40
            SELECT TOP 1 @nuevoOptionId = optionid FROM dbo.PV_VotingOptions WHERE votingconfigid = @nuevoVotingConfigId AND optiontext = 'A favor';
        ELSE IF @randomValue < 70
            SELECT TOP 1 @nuevoOptionId = optionid FROM dbo.PV_VotingOptions WHERE votingconfigid = @nuevoVotingConfigId AND optiontext = 'En contra';
        ELSE IF @randomValue < 85
            SELECT TOP 1 @nuevoOptionId = NULL FROM dbo.PV_VotingOptions WHERE votingconfigid = @nuevoVotingConfigId;
        ELSE
            SELECT TOP 1 @nuevoOptionId = optionid FROM dbo.PV_VotingOptions WHERE votingconfigid = @nuevoVotingConfigId AND optiontext = 'Se abstiene';

        INSERT INTO dbo.PV_Votes (
            votingconfigid,
            votercommitment,
            encryptedvote,
            votehash,
            nullifierhash,
            votedate,
            blockhash,
            merkleproof,
            blockchainId,
            checksum,
            userid,
            publicResult
        )
        VALUES (
            @nuevoVotingConfigId,
            @nuevoVoterCommitment,
            CAST(NEWID() AS VARBINARY(16)),
            CAST(NEWID() AS VARBINARY(16)),
            CAST(NEWID() AS VARBINARY(16)),
            GETDATE(),
            CAST(NEWID() AS VARBINARY(16)),
            NULL,
            @nuevoBlockId,
            CAST(NEWID() AS VARBINARY(16)),
            @nuevoUserId,
            (SELECT optiontext FROM dbo.PV_VotingOptions WHERE optionid = @nuevoOptionId)
        );

        -- Marcar como votado en el registro
        UPDATE dbo.PV_VoterRegistry SET hasVoted = 1 WHERE userid = @nuevoUserId AND votingconfigid = @nuevoVotingConfigId;

        SET @nuevoTotalVotes = @nuevoTotalVotes + 1;
    END
END

-- Asignar 1 o 2 MFA a cada usuario nuevo, enabled aleatorio (75% 1, 25% 0)
DECLARE @mfaMethodCount INT;
SELECT @mfaMethodCount = COUNT(*) FROM dbo.PV_MFAMethods;

DECLARE @mfaMethodId1 INT, @mfaMethodId2 INT;
SELECT TOP 1 @mfaMethodId1 = MFAmethodid FROM dbo.PV_MFAMethods ORDER BY MFAmethodid ASC;
SELECT TOP 1 @mfaMethodId2 = MFAmethodid FROM dbo.PV_MFAMethods ORDER BY MFAmethodid DESC;

DECLARE @mfaUserId INT, @mfaI INT = 1, @mfaTotalUsers INT;
SELECT @mfaTotalUsers = COUNT(*) FROM dbo.PV_Users WHERE email LIKE 'user%@example.com';

WHILE @mfaI <= @mfaTotalUsers
BEGIN
    SELECT @mfaUserId = userid FROM (
        SELECT ROW_NUMBER() OVER (ORDER BY userid) AS rn, userid
        FROM dbo.PV_Users WHERE email LIKE 'user%@example.com'
    ) t WHERE rn = @mfaI;

    -- Asignar siempre el primer método
    INSERT INTO dbo.PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid)
    VALUES (
        @mfaMethodId1,
        CAST(NEWID() AS VARBINARY(16)),
        GETDATE(),
        CASE WHEN ABS(CHECKSUM(NEWID())) % 100 < 75 THEN 1 ELSE 0 END,
        NULL,
        @mfaUserId
    );

    -- 50% de probabilidad de asignar un segundo método (si hay más de uno)
    IF @mfaMethodCount > 1 AND ABS(CHECKSUM(NEWID())) % 2 = 0
    BEGIN
        INSERT INTO dbo.PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid)
        VALUES (
            @mfaMethodId2,
            CAST(NEWID() AS VARBINARY(16)),
            GETDATE(),
            CASE WHEN ABS(CHECKSUM(NEWID())) % 100 < 75 THEN 1 ELSE 0 END,
            NULL,
            @mfaUserId
        );
    END

    SET @mfaI = @mfaI + 1;
END

-- Asignar entre 1 y 2 validaciones de identidad aleatorias a cada usuario existente

DECLARE @totalUsers INT, @totalValidations INT, @userIdx INT = 1, @validationIdx INT, @userId INT, @validationId INT, @assignedCount INT;

SELECT @totalUsers = COUNT(*) FROM dbo.PV_Users;
SELECT @totalValidations = COUNT(*) FROM dbo.PV_IdentityValidations;

WHILE @userIdx <= @totalUsers
BEGIN
    -- Obtener el userId correspondiente
    SELECT @userId = userid FROM (
        SELECT ROW_NUMBER() OVER (ORDER BY userid) AS rn, userid FROM dbo.PV_Users
    ) t WHERE rn = @userIdx;

    -- Elegir cuántas validaciones asignar (1 o 2)
    SET @assignedCount = 1 + (ABS(CHECKSUM(NEWID())) % 2);

    SET @validationIdx = 1;
    WHILE @validationIdx <= @assignedCount
    BEGIN
        -- Elegir una validationid aleatoria
        SELECT TOP 1 @validationId = validationid FROM dbo.PV_IdentityValidations ORDER BY NEWID();

        -- Solo insertar si no existe ya la relación
        IF NOT EXISTS (
            SELECT 1 FROM dbo.PV_IdentityUserValidation WHERE userid = @userId AND validationid = @validationId
        )
        BEGIN
            INSERT INTO dbo.PV_IdentityUserValidation (userid, validationid)
            VALUES (@userId, @validationId);
        END

        SET @validationIdx = @validationIdx + 1;
    END

    SET @userIdx = @userIdx + 1;
END

select * from pv_users;
select * from PV_UserStatus;
select * from PV_MFA;

-- Exchange rate
INSERT INTO PV_ExchangeRate(startDate, endDate, exchangeRate, enabled, currentExchangeRate, sourceCurrencyid, destinyCurrencyId) VALUES 
(GETDATE(), GETDATE()+300, 0.5, 1,1,1,2);

--Payment type
INSERT INTO PV_TransType(name) VALUES ('Interna');

--Payment subtype
INSERT INTO PV_TransSubTypes(name) VALUES ('Inversion');
INSERT INTO PV_TransSubTypes(name) VALUES ('Dividendos');

