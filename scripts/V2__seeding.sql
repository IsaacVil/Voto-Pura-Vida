-- Idiomas
INSERT INTO PV_Languages (name, culture) VALUES ('Español', 'es-CR');
INSERT INTO PV_Languages (name, culture) VALUES ('Inglés', 'en-US');
INSERT INTO PV_Languages (name, culture) VALUES ('Francés', 'fr-FR');

-- Monedas
INSERT INTO PV_Currency (name, symbol, acronym) VALUES ('Colón Costarricense', '₡', 'CRC');
INSERT INTO PV_Currency (name, symbol, acronym) VALUES ('Dólar Estadounidense', '$', 'USD');
INSERT INTO PV_Currency (name, symbol, acronym) VALUES ('Euro', '€', 'EUR');

-- Países
INSERT INTO PV_Countries (name, languageid, currencyid) VALUES ('Costa Rica', 1, 1);
INSERT INTO PV_Countries (name, languageid, currencyid) VALUES ('Estados Unidos', 2, 2);
INSERT INTO PV_Countries (name, languageid, currencyid) VALUES ('Francia', 3, 3);

-- Estados
INSERT INTO PV_States (name, countryid) VALUES ('San José', 1);
INSERT INTO PV_States (name, countryid) VALUES ('Alajuela', 1);
INSERT INTO PV_States (name, countryid) VALUES ('California', 2);
INSERT INTO PV_States (name, countryid) VALUES ('Île-de-France', 3);

-- Ciudades
INSERT INTO PV_Cities (name, stateid) VALUES ('San José Centro', 1);
INSERT INTO PV_Cities (name, stateid) VALUES ('Escazú', 1);
INSERT INTO PV_Cities (name, stateid) VALUES ('Los Angeles', 3);
INSERT INTO PV_Cities (name, stateid) VALUES ('Paris', 4);

-- Géneros
INSERT INTO PV_Genders (name) VALUES ('Masculino');
INSERT INTO PV_Genders (name) VALUES ('Femenino');
INSERT INTO PV_Genders (name) VALUES ('No binario');

-- Roles
INSERT INTO PV_Roles (name) VALUES ('Administrador');
INSERT INTO PV_Roles (name) VALUES ('Validador');
INSERT INTO PV_Roles (name) VALUES ('Organizador');
INSERT INTO PV_Roles (name) VALUES ('Ciudadano');
INSERT INTO PV_Roles (name) VALUES ('Analista');

-- Módulos
INSERT INTO PV_Modules (name) VALUES ('Usuarios');
INSERT INTO PV_Modules (name) VALUES ('Propuestas');
INSERT INTO PV_Modules (name) VALUES ('Votaciones');
INSERT INTO PV_Modules (name) VALUES ('Organizaciones');
INSERT INTO PV_Modules (name) VALUES ('Finanzas');
INSERT INTO PV_Modules (name) VALUES ('Reportes');
INSERT INTO PV_Modules (name) VALUES ('Seguridad');
INSERT INTO PV_Modules (name) VALUES ('Sistema');

-- Permisos
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver usuarios', 'usrs.view', 1);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Crear usuarios', 'usrs.crear', 1);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Editar usuarios', 'usrs.edit', 1);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Eliminar usuarios', 'usrs.del', 1);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver propuestas', 'props.view', 2);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Crear propuestas', 'props.crea', 2);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Editar propuestas', 'props.edit', 2);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Aprobar propuestas', 'props.aprv', 2);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver votaciones', 'vot.view', 3);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Crear votaciones', 'vot.crea', 3);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Votar', 'vot.votar', 3);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver organizaciones', 'orgs.view', 4);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver finanzas', 'fin.view', 5);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver reportes', 'rep.view', 6);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Admin seg', 'seg.adm', 7);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Admin sist', 'sys.adm', 8);

-- Tipos de pregunta 
INSERT INTO PV_questionType ([type]) VALUES ('Sí/No');
INSERT INTO PV_questionType ([type]) VALUES ('Múltiple Opción');
INSERT INTO PV_questionType ([type]) VALUES ('Abierta');

-- Preguntas de votación 
SET IDENTITY_INSERT PV_VotingQuestions ON;
INSERT INTO PV_VotingQuestions (questionId, question, questionTypeId, createdDate, checksum) VALUES (1, '¿Está de acuerdo con la propuesta?', 1, GETDATE(), 0x00);
INSERT INTO PV_VotingQuestions (questionId, question, questionTypeId, createdDate, checksum) VALUES (2, '¿Está usted a favor?', 2, GETDATE(), 0x00);
SET IDENTITY_INSERT PV_VotingQuestions OFF;

-- Estados de votación 
INSERT INTO PV_VotingStatus (name, description) VALUES ('Configurada', 'Configuración creada');
INSERT INTO PV_VotingStatus (name, description) VALUES ('En curso', 'Votación activa');
INSERT INTO PV_VotingStatus (name, description) VALUES ('Finalizada', 'Votación finalizada');
INSERT INTO PV_VotingStatus (name, description) VALUES ('Cancelada', 'Votación cancelada');

-- Tipos de propuesta
INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) VALUES ('Mejora de Infraestructura', 'Proyectos de mejora de infraestructura urbana', 1, 1, 2);
INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) VALUES ('Programa Social', 'Programas de desarrollo social comunitario', 1, 1, 3);

-- Estados de propuesta
INSERT INTO PV_ProposalStatus (name, description) VALUES ('Borrador', 'Propuesta en preparación');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('En Revisión', 'Propuesta sometida para revisión');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('Aprobada', 'Propuesta aprobada para votación');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('Rechazada', 'Propuesta rechazada');

-- Tipos de votación
INSERT INTO PV_VotingTypes (name) VALUES ('Votación Simple');
INSERT INTO PV_VotingTypes (name) VALUES ('Votación Ponderada');

-- Métodos de notificación
INSERT INTO PV_NotificationMethods (name, description) VALUES ('Email', 'Notificación por correo electrónico');
INSERT INTO PV_NotificationMethods (name, description) VALUES ('SMS', 'Notificación por mensaje de texto');

-- Estado de usuario 
INSERT INTO PV_UserStatus (active, verified) VALUES (1, 1);
INSERT INTO PV_UserStatus (active, verified) VALUES (1, 0);
INSERT INTO PV_UserStatus (active, verified) VALUES (0, 0);

-- Tipos de documento 
INSERT INTO PV_DocumentTypes (name, description) VALUES ('Cédula', 'Documento nacional de identidad');
INSERT INTO PV_DocumentTypes (name, description) VALUES ('Pasaporte', 'Documento internacional');

-- Usuarios 
INSERT INTO PV_Users (email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) VALUES ('admin@votopuravida.cr', 'Administrador', 'Sistema', '1980-01-01', GETDATE(), 1, GETDATE(), 101234567, 1);
INSERT INTO PV_Users (email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) VALUES ('validator@votopuravida.cr', 'María', 'Validadora', '1975-05-15', GETDATE(), 2, GETDATE(), 201234567, 2);
INSERT INTO PV_Users (email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) VALUES ('john.doe@us.com', 'John', 'Doe', '1990-07-20', GETDATE(), 1, GETDATE(), 301234567, 1);
INSERT INTO PV_Users (email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) VALUES ('jeanne.dupont@fr.fr', 'Jeanne', 'Dupont', '1985-03-12', GETDATE(), 2, GETDATE(), 401234567, 1);
INSERT INTO PV_Users (email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) VALUES ('sofia.garcia@votopuravida.cr', 'Sofía', 'García', '2002-11-05', GETDATE(), 3, GETDATE(), 501234567, 1);

-- Organizaciones 
INSERT INTO PV_Organizations (name, description, userid, createdAt, legalIdentification, OrganizationTypeId, MinJointVentures) VALUES ('Municipalidad de San José', 'Gobierno local de la capital', 1, GETDATE(), '3-101-123456', 1, 0);
INSERT INTO PV_Organizations (name, description, userid, createdAt, legalIdentification, OrganizationTypeId, MinJointVentures) VALUES ('ONG Esperanza', 'Organización sin fines de lucro', 3, GETDATE(), '3-202-987654', 2, 0);
INSERT INTO PV_Organizations (name, description, userid, createdAt, legalIdentification, OrganizationTypeId, MinJointVentures) VALUES ('Tech4Good', 'Empresa de tecnología social', 4, GETDATE(), '3-303-456789', 3, 0);

-- Roles a usuarios
INSERT INTO PV_UserRoles (userid, roleid, lastupdate, enabled, deleted) VALUES (1, 1, GETDATE(), 1, 0);
INSERT INTO PV_UserRoles (userid, roleid, lastupdate, enabled, deleted) VALUES (2, 2, GETDATE(), 1, 0);

-- Propuestas (referencian organización ya insertada)
INSERT INTO PV_Proposals (title, description, proposalcontent, budget, createdby, createdon, lastmodified, proposaltypeid, statusid, organizationid, checksum, version) VALUES ('Renovación del Parque Central', 'Proyecto de renovación del Parque Central de San José.', 'Contenido detallado del proyecto.', 50000000.00, 1, GETDATE(), GETDATE(), 1, 1, 1, 0x00, 1);
INSERT INTO PV_Proposals (title, description, proposalcontent, budget, createdby, createdon, lastmodified, proposaltypeid, statusid, organizationid, checksum, version) VALUES ('Plataforma de Telemedicina', 'Proyecto de salud digital para zonas rurales.', 'Contenido detallado.', 20000000.00, 2, GETDATE(), GETDATE(), 2, 1, 1, 0x00, 1);

-- Configuración de votación y opciones
INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeId, allowweightedvotes, requiresallvoters, notificationmethodid, userid, configureddate, statusid, publisheddate, finalizeddate, publicVoting, checksum) VALUES (1, DATEADD(day, 1, GETDATE()), DATEADD(day, 10, GETDATE()), 1, 0, 0, 1, 1, GETDATE(), 1, NULL, NULL, 1, 0x00);
INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeId, allowweightedvotes, requiresallvoters, notificationmethodid, userid, configureddate, statusid, publisheddate, finalizeddate, publicVoting, checksum) VALUES (2, DATEADD(day, 2, GETDATE()), DATEADD(day, 12, GETDATE()), 2, 1, 1, 2, 2, GETDATE(), 1, NULL, NULL, 1, 0x00);

INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (1, 'Sí', 1, 1, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (1, 'No', 2, 1, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (2, 'A favor', 1, 2, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (2, 'En contra', 2, 2, 0x00);

-- Segmentos de población
INSERT INTO PV_SegmentTypes (name, description) VALUES ('Geográfico', 'Segmentación por ubicación geográfica');
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('San José Centro', 'Residentes del centro de San José', 1);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Jóvenes 18-25', 'Ciudadanos entre 18 y 25 años', 1);

-- Asignación de segmentos a usuarios 
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive) VALUES (1, 1, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive) VALUES (2, 2, GETDATE(), 1);

-- Fondos
INSERT INTO PV_Funds (name) VALUES ('Fondo Municipal General');

-- Balances 
INSERT INTO PV_Balances (balance, lastbalance, lastupdate, checksum, userid, fundid, organizationId) VALUES (1000000, 900000, GETDATE(), 0x00, 1, 1, 1);

-- Reporte financiero 
INSERT INTO PV_FinancialReports (proposalid, reportperiod, totalrevenue, totalexpenses, netprofit, availablefordividends, submitteddate) VALUES (1, '2025-Q1', 1000000, 500000, 500000, 200000, GETDATE());
INSERT INTO PV_FinancialReports (proposalid, reportperiod, totalrevenue, totalexpenses, netprofit, availablefordividends, submitteddate) VALUES (2, '2025-Q2', 2000000, 1000000, 1000000, 500000, GETDATE());

-- Ejemplo de ejecución de plan
INSERT INTO PV_ExecutionPlans (proposalid, totalbudget, expectedStartdate, expectedenddate, createddate, expectedDurationInMonths) VALUES (1, 50000000.00, GETDATE(), DATEADD(month, 6, GETDATE()), GETDATE(), 6);

-- Seguridad y MFA
INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('TOTP', 'Time-based One-Time Password', 1);
INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('SMS', 'SMS Code', 1);
INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('Email', 'Email Code', 1);

-- Insert MFA records 
INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid) VALUES (1, CAST('JBSWY3DPEHPK3PXP' AS varbinary(256)), GETDATE(), 1, NULL, 1); 
INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid) VALUES (2, CAST('+50688888888' AS varbinary(256)), GETDATE(), 1, NULL, 2);     
INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid) VALUES (3, CAST('ana.mendez@coopverde.cr' AS varbinary(256)), GETDATE(), 1, NULL, 1);
INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid) VALUES (1, CAST('LUISOTPSECRET' AS varbinary(256)), GETDATE(), 1, NULL, 2);     

-- Validaciones de identidad 
INSERT INTO PV_IdentityValidations (validationdate, validationtype, validationresult, aivalidationresult, validationhash, verified) VALUES (GETDATE(), 'Prueba de vida', 'Aprobado', 'Validación facial exitosa', 0x01, 1);
INSERT INTO PV_IdentityValidations (validationdate, validationtype, validationresult, aivalidationresult, validationhash, verified) VALUES (GETDATE(), 'Documento', 'Aprobado', 'Cédula verificada por IA', 0x02, 1);

-- Documentos y verificación periódica
SET IDENTITY_INSERT PV_Documents ON;
INSERT INTO PV_Documents (documentid, documenthash, aivalidationstatus, aivalidationresult, humanvalidationrequired, mediafileId, periodicVerificationId, documentTypeId, version) VALUES (1, 0x01, 'Pending', NULL, 0, NULL, NULL, 1, 1);
INSERT INTO PV_Documents (documentid, documenthash, aivalidationstatus, aivalidationresult, humanvalidationrequired, mediafileId, periodicVerificationId, documentTypeId, version) VALUES (2, 0x02, 'Pending', NULL, 0, NULL, NULL, 2, 1);
SET IDENTITY_INSERT PV_Documents OFF;

-- Propuestas y crowdfunding
INSERT INTO PV_Proposals (title, description, proposalcontent, budget, createdby, createdon, lastmodified, proposaltypeid, statusid, organizationid, checksum, version) VALUES ('Plataforma de Telemedicina', 'Proyecto de salud digital para zonas rurales.', 'Contenido detallado.', 20000000.00, 2, GETDATE(), GETDATE(), 2, 1, 1, 0x00, 1);
INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeId, allowweightedvotes, requiresallvoters, notificationmethodid, userid, configureddate, statusid, publisheddate, finalizeddate, publicVoting, checksum) VALUES (2, DATEADD(day, 2, GETDATE()), DATEADD(day, 12, GETDATE()), 2, 1, 1, 2, 2, GETDATE(), 1, NULL, NULL, 1, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (2, 'A favor', 1, 2, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (2, 'En contra', 2, 2, 0x00);

-- Configuración avanzada de votación y segmentación
INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeId, allowweightedvotes, requiresallvoters, notificationmethodid, userid, configureddate, statusid, publisheddate, finalizeddate, publicVoting, checksum) VALUES (2, DATEADD(day, 2, GETDATE()), DATEADD(day, 12, GETDATE()), 2, 1, 1, 2, 2, GETDATE(), 1, NULL, NULL, 1, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (2, 'A favor', 1, 2, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (2, 'En contra', 2, 2, 0x00);

-- Inversión y desembolsos
INSERT INTO PV_Investments (proposalid, amount, equitypercentage, investmentdate, investmenthash, checksum) VALUES (2, 1000000, 2.0, GETDATE(), 0x00, 0x00);
INSERT INTO PV_Investments (proposalid, amount, equitypercentage, investmentdate, investmenthash, checksum) VALUES (2, 500000, 1.0, GETDATE(), 0x00, 0x00);

-- Permisos y roles de usuario
INSERT INTO PV_UserPermissions (enabled, deleted, lastupdate, checksum, userid, permissionid) VALUES (1, 0, GETDATE(), 0x00, 1, 1);
INSERT INTO PV_UserPermissions (enabled, deleted, lastupdate, checksum, userid, permissionid) VALUES (1, 0, GETDATE(), 0x00, 2, 2);

-- Votaciones y votos
INSERT INTO PV_Votes (votingconfigid, votercommitment, encryptedvote, votehash, nullifierhash, votedate, blockhash, merkleproof, blockchainId, checksum, userId, publicResult) VALUES (1, 0x01, 0xA1, 0xB1, 0xC1, GETDATE(), 0xD1, NULL, NULL, 0x00, 1, NULL);
INSERT INTO PV_Votes (votingconfigid, votercommitment, encryptedvote, votehash, nullifierhash, votedate, blockhash, merkleproof, blockchainId, checksum, userId, publicResult) VALUES (2, 0x02, 0xA2, 0xB2, 0xC2, GETDATE(), 0xD2, NULL, NULL, 0x00, 2, NULL);

INSERT INTO PV_AIAnalysisType (name) VALUES ('Análisis de Propuesta');
INSERT INTO PV_AIAnalysisType (name) VALUES ('Análisis de Inversión');

INSERT INTO PV_AIProviders (name, baseurl, description, isactive, createdate) VALUES ('Google Document AI', 'https://docai.googleapis.com', 'Validación de documentos', 1, GETDATE());
INSERT INTO PV_AIModelTypes (name) VALUES ('OCR');
INSERT INTO PV_AIModelTypes (name) VALUES ('Clasificación');
INSERT INTO PV_AIModels (providerid, modelname, displayname, modeltypeId, maxinputtokens, maxoutputtokens, costperinputtoken, costperoutputtoken, isactive, capabilities, createdate) VALUES (1, 'ocr-v1', 'OCR Básico', 1, 4096, 1024, 0.0001, 0.0002, 1, NULL, GETDATE());

INSERT INTO PV_AIConnections (providerid, connectionname, publicKey, privateKey, organizationid, environment, isactive, createdby, createdate, usagecount, modelId) VALUES (1, 'Conexión DocAI', 0x01, 0x02, 1, 'production', 1, 1, GETDATE(), 0, 1);

INSERT INTO PV_AIDocumentAnalysis (documentid, analysisDocTypeId, confidence, result, findings, extracteddata, flags, humanreviewrequired, reviewerid, analysisdate, AIConnectionId) VALUES (1, 1, 0.98, 'Aprobado', 'Documento legible', 'Nombre: Admin', NULL, 0, 2, GETDATE(), 1);

INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('TOTP', 'Autenticación por app de código temporal', 1);
INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('SMS', 'Código enviado por SMS', 0);
INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('Email', 'Código enviado por correo', 0);

INSERT INTO PV_OrganizationTypes (name) VALUES ('Municipalidad');
INSERT INTO PV_OrganizationTypes (name) VALUES ('ONG');
INSERT INTO PV_OrganizationTypes (name) VALUES ('Empresa Privada');

INSERT INTO PV_LogSeverity (name) VALUES ('Info');
INSERT INTO PV_LogSeverity (name) VALUES ('Warning');
INSERT INTO PV_LogSeverity (name) VALUES ('Error');
INSERT INTO PV_LogSeverity (name) VALUES ('Critical');

INSERT INTO PV_LogSource (name) VALUES ('Web');
INSERT INTO PV_LogSource (name) VALUES ('API');
INSERT INTO PV_LogSource (name) VALUES ('Mobile');
INSERT INTO PV_LogSource (name) VALUES ('Batch');

INSERT INTO PV_LogTypes (name, ref1description, ref2description, val1description, val2description) VALUES ('Acceso', 'Usuario', 'IP', 'Resultado', 'Método');
INSERT INTO PV_LogTypes (name, ref1description, ref2description, val1description, val2description) VALUES ('Votación', 'Votación', 'Usuario', 'Opción', 'Hash');
INSERT INTO PV_LogTypes (name, ref1description, ref2description, val1description, val2description) VALUES ('Inversión', 'Usuario', 'Propuesta', 'Monto', 'Estado');

INSERT INTO PV_ReportTypes (reportTypeId, name) VALUES (1, 'Denuncia');
INSERT INTO PV_ReportTypes (reportTypeId, name) VALUES (2, 'Error de Proceso');
INSERT INTO PV_ReportTypes (reportTypeId, name) VALUES (3, 'Auditoría');

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

-- Ejemplo de métricas y resultados de votación
INSERT INTO PV_VotingMetricsType (name) VALUES ('Participación');
INSERT INTO PV_VotingMetricsType (name) VALUES ('Aprobación');
INSERT INTO PV_VotingMetrics (votingconfigid, metrictypeId, metricvalue, segmentid, calculateddate, isactive) VALUES (1, 1, 80.5, 1, GETDATE(), 1);
INSERT INTO PV_VoteResults (votingconfigid, optionid, votecount, weightedcount, lastupdated, creationDate, checksum) VALUES (1, 1, 100, 100.0, GETDATE(), GETDATE(), 0x00);

-- Ejemplo de traducciones
INSERT INTO PV_Translation (code, caption, enabled, languageid, moduleid) VALUES ('welcome', 'Bienvenido', 1, 1, 1);
INSERT INTO PV_Translation (code, caption, enabled, languageid, moduleid) VALUES ('welcome', 'Welcome', 1, 2, 1);

-- Ejemplo de asignación de usuario a organización
INSERT INTO PV_OrganizationPerUser  (userId, organizationId) VALUES (2, 1);

-- Ejemplo de permisos y roles a organización
INSERT INTO PV_OrganizationPermissions (organizationid, permissionid, enabled, deleted, assigneddate, lastupdate, checksum) VALUES (1, 1, 1, 0, GETDATE(), GETDATE(), 0x00);
INSERT INTO PV_OrganizationRoles (organizationid, roleid, enabled, deleted, assigneddate, lastupdate, checksum) VALUES (1, 1, 1, 0, GETDATE(), GETDATE(), 0x00);

-- Ejemplo de comentarios de propuesta y documentos asociados
INSERT INTO PV_ProposasalCommentStatus (status) VALUES ('Aprobado');
INSERT INTO PV_ProposasalCommentStatus (status) VALUES ('Pendiente');
INSERT INTO PV_ProposasalCommentStatus (status) VALUES ('Rechazado');
INSERT INTO PV_ProposalComments (proposalid, userid, comment, commentdate, statusid) VALUES (2, 2, 'Comentario de fiscalización.', GETDATE(), 1);
INSERT INTO PV_proposalCommentDocuments (documentId, commentId) VALUES (1, 1);

-- Ejemplo de opciones de votación
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (1, 'Sí', 1, 1, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (1, 'No', 2, 1, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (2, 'A favor', 1, 2, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) VALUES (2, 'En contra', 2, 2, 0x00);

-- Más países
INSERT INTO PV_Languages (name, culture) VALUES ('Francés', 'fr-FR');
INSERT INTO PV_Currency (name, symbol, acronym) VALUES ('Euro', '€', 'EUR');
INSERT INTO PV_Countries (name, languageid, currencyid) VALUES ('Estados Unidos', 2, 2);
INSERT INTO PV_Countries (name, languageid, currencyid) VALUES ('Francia', 3, 3);
INSERT INTO PV_States (name, countryid) VALUES ('California', 2);
INSERT INTO PV_States (name, countryid) VALUES ('Île-de-France', 3);
INSERT INTO PV_Cities (name, stateid) VALUES ('Los Angeles', 3);
INSERT INTO PV_Cities (name, stateid) VALUES ('Paris', 4);

-- Más direcciones
INSERT INTO PV_Addresses (line1, line2, zipcode, geoposition, cityid) VALUES ('123 Main St', 'Apt 4', '90001', geometry::Point(34.0522, -118.2437, 4326), 3);
INSERT INTO PV_Addresses (line1, line2, zipcode, geoposition, cityid) VALUES ('10 Rue de Rivoli', '2ème étage', '75001', geometry::Point(48.8566, 2.3522, 4326), 4);
INSERT INTO PV_Addresses (line1, line2, zipcode, geoposition, cityid) VALUES ('Barrio Escalante', 'Casa azul', '10102', geometry::Point(9.935, -84.05, 4326), 2);

-- Asignar direcciones a usuarios
INSERT INTO PV_UserAddresses (userid, addressid, addresstype, isactive, assigneddate) VALUES (3, 1, 'Residencial', 1, GETDATE());
INSERT INTO PV_UserAddresses (userid, addressid, addresstype, isactive, assigneddate) VALUES (4, 2, 'Residencial', 1, GETDATE());
INSERT INTO PV_UserAddresses (userid, addressid, addresstype, isactive, assigneddate) VALUES (5, 3, 'Residencial', 1, GETDATE());

-- Ejemplo de allowed countries/IPs
INSERT INTO PV_AllowedCountries (countryid, isallowed, createddate, lastmodified) VALUES (1, 1, GETDATE(), GETDATE());
INSERT INTO PV_AllowedIPs (ipaddress, ipmask, addressid, isallowed, description, createddate, lastmodified, checksum) VALUES ('190.10.10.1', NULL, 1, 1, 'IP admin', GETDATE(), GETDATE(), 0x00);