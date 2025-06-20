-- V7__comprehensive_testing_data.sql
-- Datos comprehensivos para testing de todos los endpoints del API

-- ===========================================
-- DATOS ADICIONALES PARA TESTING COMPLETO
-- ===========================================

-- Usuarios adicionales para testing MFA
INSERT INTO PV_UserStatus(active, verified) VALUES (1, 1);
INSERT INTO PV_UserStatus(active, verified) VALUES (1, 1);
INSERT INTO PV_UserStatus(active, verified) VALUES (1, 1);

SET IDENTITY_INSERT PV_Users ON;
INSERT INTO PV_Users (userid, email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) 
VALUES (10, 'test.mfa@votopuravida.cr', 'Usuario', 'TestMFA', '1990-01-01', GETDATE(), 1, GETDATE(), 118880001, 3);
INSERT INTO PV_Users (userid, email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) 
VALUES (11, 'test.sms@votopuravida.cr', 'Usuario', 'TestSMS', '1985-05-15', GETDATE(), 2, GETDATE(), 118880002, 4);
INSERT INTO PV_Users (userid, email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) 
VALUES (12, 'test.email@votopuravida.cr', 'Usuario', 'TestEmail', '1992-12-25', GETDATE(), 1, GETDATE(), 118880003, 5);
SET IDENTITY_INSERT PV_Users OFF;

-- Métodos MFA adicionales para garantizar compatibilidad
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

-- Propuestas adicionales para testing
INSERT INTO PV_Proposals (title, description, proposalcontent, budget, createdby, createdon, lastmodified, proposaltypeid, statusid, organizationid, checksum, version) 
VALUES ('Centro de Innovación Tecnológica', 'Desarrollo de un hub tecnológico para startups locales', 'Proyecto integral que incluye espacios de coworking, laboratorios y mentorías', 15000000.00, 1, GETDATE(), GETDATE(), 1, 3, 1, 0x00, 1);
INSERT INTO PV_Proposals (title, description, proposalcontent, budget, createdby, createdon, lastmodified, proposaltypeid, statusid, organizationid, checksum, version) 
VALUES ('Programa de Educación Digital', 'Capacitación en tecnologías digitales para adultos mayores', 'Cursos gratuitos de alfabetización digital con certificación oficial', 8000000.00, 2, GETDATE(), GETDATE(), 2, 3, 1, 0x00, 1);
INSERT INTO PV_Proposals (title, description, proposalcontent, budget, createdby, createdon, lastmodified, proposaltypeid, statusid, organizationid, checksum, version) 
VALUES ('Red de Ciclovías Metropolitanas', 'Expansión de la red de ciclovías en el área metropolitana', 'Construcción de 50km adicionales de ciclovías conectadas y seguras', 25000000.00, 1, GETDATE(), GETDATE(), 1, 1, 1, 0x00, 1);

-- Configuraciones de votación para las nuevas propuestas
INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeId, allowweightedvotes, requiresallvoters, notificationmethodid, userid, configureddate, statusid, publisheddate, finalizeddate, publicVoting, checksum) 
VALUES (3, DATEADD(day, 1, GETDATE()), DATEADD(day, 15, GETDATE()), 1, 0, 0, 1, 1, GETDATE(), 1, GETDATE(), NULL, 1, 0x00);
INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeId, allowweightedvotes, requiresallvoters, notificationmethodid, userid, configureddate, statusid, publisheddate, finalizeddate, publicVoting, checksum) 
VALUES (4, DATEADD(day, 3, GETDATE()), DATEADD(day, 17, GETDATE()), 2, 1, 0, 2, 2, GETDATE(), 1, GETDATE(), NULL, 1, 0x00);
INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeId, allowweightedvotes, requiresallvoters, notificationmethodid, userid, configureddate, statusid, publisheddate, finalizeddate, publicVoting, checksum) 
VALUES (5, DATEADD(day, 5, GETDATE()), DATEADD(day, 20, GETDATE()), 1, 0, 1, 1, 1, GETDATE(), 1, GETDATE(), NULL, 0, 0x00);

-- Preguntas de votación adicionales
SET IDENTITY_INSERT PV_VotingQuestions ON;
INSERT INTO PV_VotingQuestions (questionId, question, questionTypeId, createdDate, checksum) 
VALUES (3, '¿Considera que este proyecto beneficiará a la comunidad?', 1, GETDATE(), 0x00);
INSERT INTO PV_VotingQuestions (questionId, question, questionTypeId, createdDate, checksum) 
VALUES (4, '¿Cuál es su nivel de apoyo para esta iniciativa?', 2, GETDATE(), 0x00);
INSERT INTO PV_VotingQuestions (questionId, question, questionTypeId, createdDate, checksum) 
VALUES (5, '¿Está de acuerdo con la asignación presupuestaria?', 1, GETDATE(), 0x00);
SET IDENTITY_INSERT PV_VotingQuestions OFF;

-- Opciones de votación para las nuevas configuraciones
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) 
VALUES (3, 'Sí, lo apoyo completamente', 1, 3, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) 
VALUES (3, 'No, no lo considero necesario', 2, 3, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) 
VALUES (4, 'Apoyo total', 1, 4, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) 
VALUES (4, 'Apoyo parcial', 2, 4, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) 
VALUES (4, 'No apoyo', 3, 4, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) 
VALUES (5, 'Apruebo el presupuesto', 1, 5, 0x00);
INSERT INTO PV_VotingOptions (votingconfigid, optiontext, optionorder, questionId, checksum) 
VALUES (5, 'Rechazo el presupuesto', 2, 5, 0x00);

-- Segmentos de población adicionales para testing
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Profesionales Test', 'Trabajadores profesionales de prueba', 1);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Adultos Mayores Test', 'Población mayor de 65 años de prueba', 1);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Estudiantes Test', 'Estudiantes universitarios de prueba', 1);

-- Asignación de usuarios a segmentos
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive) VALUES (10, 1, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive) VALUES (11, 2, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive) VALUES (12, 1, GETDATE(), 1);

-- Segmentos objetivo para las votaciones
INSERT INTO PV_VotingTargetSegments (votingconfigid, segmentid, voteweight) VALUES (3, 1, 1.0);
INSERT INTO PV_VotingTargetSegments (votingconfigid, segmentid, voteweight) VALUES (3, 2, 1.2);
INSERT INTO PV_VotingTargetSegments (votingconfigid, segmentid, voteweight) VALUES (4, 1, 1.0);
INSERT INTO PV_VotingTargetSegments (votingconfigid, segmentid, voteweight) VALUES (4, 2, 1.1);
INSERT INTO PV_VotingTargetSegments (votingconfigid, segmentid, voteweight) VALUES (5, 1, 1.0);
INSERT INTO PV_VotingTargetSegments (votingconfigid, segmentid, voteweight) VALUES (5, 2, 1.2);

-- Métodos de pago adicionales para testing
INSERT INTO PV_PaymentMethods (name, APIURL, secretkey, [key], logoiconurl, enabled) 
VALUES ('SINPE Móvil', 'https://api.sinpe.cr', 0x01, 0x01, 'https://sinpe.cr/logo.png', 1);
INSERT INTO PV_PaymentMethods (name, APIURL, secretkey, [key], logoiconurl, enabled) 
VALUES ('PayPal CR', 'https://api.paypal.com/cr', 0x02, 0x02, 'https://paypal.com/logo.png', 1);
INSERT INTO PV_PaymentMethods (name, APIURL, secretkey, [key], logoiconurl, enabled) 
VALUES ('Tarjeta Débito', 'https://api.bancobcr.com/debit', 0x03, 0x03, 'https://bcr.fi.cr/logo.png', 1);

-- Métodos disponibles para usuarios
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) 
VALUES ('SINPE +506 8888-9999', 0x01, DATEADD(year,2,GETDATE()), '+506****9999', 10, 2);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) 
VALUES ('PayPal usuario@test.com', 0x02, DATEADD(year,1,GETDATE()), 'test****@test.com', 11, 3);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) 
VALUES ('Débito BCR *1111', 0x03, DATEADD(year,3,GETDATE()), '****1111', 12, 4);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) 
VALUES ('Crédito BAC *2222', 0x04, DATEADD(year,2,GETDATE()), '****2222', 1, 1);

-- Tipos de cambio para testing
INSERT INTO PV_ExchangeRate(startDate, endDate, exchangeRate, enabled, currentExchangeRate, sourceCurrencyid, destinyCurrencyid) 
VALUES (GETDATE(), GETDATE(), 525.50, 1, 525.50, 2, 1);

INSERT INTO PV_ExchangeRate(startDate, endDate, exchangeRate, enabled, currentExchangeRate, sourceCurrencyid, destinyCurrencyid) 
VALUES (GETDATE(), GETDATE(), 525.50, 1, 525.50, 3, 2);

INSERT INTO PV_ExchangeRate(startDate, endDate, exchangeRate, enabled, currentExchangeRate, sourceCurrencyid, destinyCurrencyid) 
VALUES (GETDATE(), GETDATE(), 525.50, 1, 525.50, 1, 3);


-- Planes de ejecución para las nuevas propuestas
INSERT INTO PV_ExecutionPlans (proposalid, totalbudget, expectedStartdate, expectedenddate, createddate, expectedDurationInMonths) 
VALUES (3, 15000000.00, DATEADD(month, 1, GETDATE()), DATEADD(month, 12, GETDATE()), GETDATE(), 11);
INSERT INTO PV_ExecutionPlans (proposalid, totalbudget, expectedStartdate, expectedenddate, createddate, expectedDurationInMonths) 
VALUES (4, 8000000.00, DATEADD(month, 2, GETDATE()), DATEADD(month, 8, GETDATE()), GETDATE(), 6);
INSERT INTO PV_ExecutionPlans (proposalid, totalbudget, expectedStartdate, expectedenddate, createddate, expectedDurationInMonths) 
VALUES (5, 25000000.00, DATEADD(month, 3, GETDATE()), DATEADD(month, 18, GETDATE()), GETDATE(), 15);

-- Inversiones iniciales para testing
INSERT INTO PV_Investments (proposalid, amount, equitypercentage, investmentdate, investmenthash, checksum) 
VALUES (3, 500000.00, 1.5, GETDATE(), 0x01, 0x01);
INSERT INTO PV_Investments (proposalid, amount, equitypercentage, investmentdate, investmenthash, checksum) 
VALUES (4, 300000.00, 1.0, GETDATE(), 0x02, 0x02);
INSERT INTO PV_Investments (proposalid, amount, equitypercentage, investmentdate, investmenthash, checksum) 
VALUES (5, 750000.00, 2.0, GETDATE(), 0x03, 0x03);
INSERT INTO PV_Investments (proposalid, amount, equitypercentage, investmentdate, investmenthash, checksum) 
VALUES (3, 1000000.00, 3.0, GETDATE(), 0x04, 0x04);

-- Reportes financieros para testing de dividendos
INSERT INTO PV_FinancialReports (proposalid, reportperiod, totalrevenue, totalexpenses, netprofit, availablefordividends, submitteddate) 
VALUES (3, '2025-Q1', 2000000.00, 1200000.00, 800000.00, 400000.00, GETDATE());
INSERT INTO PV_FinancialReports (proposalid, reportperiod, totalrevenue, totalexpenses, netprofit, availablefordividends, submitteddate) 
VALUES (4, '2025-Q1', 1500000.00, 900000.00, 600000.00, 300000.00, GETDATE());
INSERT INTO PV_FinancialReports (proposalid, reportperiod, totalrevenue, totalexpenses, netprofit, availablefordividends, submitteddate) 
VALUES (5, '2025-Q1', 3000000.00, 2000000.00, 1000000.00, 500000.00, GETDATE());

-- Permisos adicionales para usuarios que procesan dividendos
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Procesar dividendos', 'dividend', 5);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver inversiones', 'invest', 5);
INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Gestionar pagos', 'payment', 5);

-- Asignar permisos a usuarios para testing
INSERT INTO PV_UserPermissions (enabled, deleted, lastupdate, checksum, userid, permissionid) 
VALUES (1, 0, GETDATE(), 0x00, 1, 17);
INSERT INTO PV_UserPermissions (enabled, deleted, lastupdate, checksum, userid, permissionid) 
VALUES (1, 0, GETDATE(), 0x00, 2, 18);
INSERT INTO PV_UserPermissions (enabled, deleted, lastupdate, checksum, userid, permissionid) 
VALUES (1, 0, GETDATE(), 0x00, 1, 19);

-- Logs de ejemplo para auditoría
INSERT INTO PV_Logs (description, name, posttime, computer, trace, referenceid1, referenceid2, checksum, logtypeid, logsourceid, logseverityid, value1, value2)
VALUES ('Usuario autenticado con MFA TOTP', 'LOGIN', GETDATE(), '127.0.0.1', 'PostmanTesting', NULL, NULL, 0x00, 1, 1, 1, 'MFA_TOTP', 'SUCCESS');
INSERT INTO PV_Logs (description, name, posttime, computer, trace, referenceid1, referenceid2, checksum, logtypeid, logsourceid, logseverityid, value1, value2)
VALUES ('Usuario autenticado con MFA SMS', 'LOGIN', GETDATE(), '127.0.0.1', 'PostmanTesting', NULL, NULL, 0x00, 1, 1, 1, 'MFA_SMS', 'SUCCESS');
INSERT INTO PV_Logs (description, name, posttime, computer, trace, referenceid1, referenceid2, checksum, logtypeid, logsourceid, logseverityid, value1, value2)
VALUES ('Intento de voto con validación biométrica', 'VOTE_ATTEMPT', GETDATE(), '127.0.0.1', 'PostmanTesting', NULL, NULL, 0x00, 1, 1, 1, 'PROPOSAL_3', 'BIOMETRIC_OK');

-- Métricas de votación iniciales
INSERT INTO PV_VotingMetrics (votingconfigid, metrictypeId, metricvalue, segmentid, calculateddate, isactive) 
VALUES (3, 1, 65.0, 1, GETDATE(), 1);
INSERT INTO PV_VotingMetrics (votingconfigid, metrictypeId, metricvalue, segmentid, calculateddate, isactive) 
VALUES (4, 2, 78.5, 2, GETDATE(), 1);
INSERT INTO PV_VotingMetrics (votingconfigid, metrictypeId, metricvalue, segmentid, calculateddate, isactive) 
VALUES (5, 1, 72.3, 1, GETDATE(), 1);

-- Resultados de votación correspondientes
INSERT INTO PV_VoteResults (votingconfigid, optionid, votecount, weightedcount, lastupdated, creationDate, checksum) 
VALUES (3, 7, 1, 1.0, GETDATE(), GETDATE(), 0x07);
INSERT INTO PV_VoteResults (votingconfigid, optionid, votecount, weightedcount, lastupdated, creationDate, checksum) 
VALUES (4, 9, 1, 1.2, GETDATE(), GETDATE(), 0x09);

-- Comentarios en propuestas para testing
INSERT INTO PV_ProposalComments (proposalid, userid, comment, commentdate, statusid) 
VALUES (3, 10, 'Excelente iniciativa para el desarrollo tecnológico local.', GETDATE(), 1);
INSERT INTO PV_ProposalComments (proposalid, userid, comment, commentdate, statusid) 
VALUES (4, 11, 'Es importante incluir capacitación en seguridad digital.', GETDATE(), 1);
INSERT INTO PV_ProposalComments (proposalid, userid, comment, commentdate, statusid) 
VALUES (5, 12, 'Las ciclovías deben conectar con transporte público.', GETDATE(), 1);

-- ===========================================
-- DATOS PARA TESTING DE ENDPOINTS ESPECÍFICOS
-- ===========================================

PRINT 'V7: Datos comprehensivos de testing insertados exitosamente';
PRINT 'Usuarios con MFA: 10 (TOTP), 11 (SMS), 12 (Email)';
PRINT 'Propuestas disponibles: 3, 4, 5 con configuraciones de votación activas';
PRINT 'Métodos de pago configurados para stored procedures de inversión';
PRINT 'Reportes financieros disponibles para testing de dividendos';
PRINT 'Usuarios con permisos para procesar dividendos: 1 (admin)';
PRINT '¡Listo para testing completo de todos los endpoints!';

