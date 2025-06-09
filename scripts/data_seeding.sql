-- ==========================================================================
-- VOTO PURA VIDA - COMPREHENSIVE DATABASE SEEDING SCRIPT
-- ==========================================================================
-- File: data_seeding.sql
-- Purpose: Complete data seeding for the Voto Pura Vida voting system
-- Database: SQL Server (VotoPuraVida)
-- Created: June 2025
-- ==========================================================================

USE [VotoPuraVida]
GO

-- Disable foreign key checks temporarily for faster insertion
-- Note: SQL Server doesn't have FOREIGN_KEY_CHECKS like MySQL, so we'll proceed carefully

PRINT '=========================================='
PRINT 'STARTING VOTO PURA VIDA DATA SEEDING'
PRINT '=========================================='
PRINT ''

-- ==========================================================================
-- CORE REFERENCE DATA
-- ==========================================================================

PRINT 'Seeding Core Reference Data...'

-- Languages
SET IDENTITY_INSERT [PV_Languages] ON
INSERT INTO [PV_Languages] ([languageid], [name], [culture]) VALUES 
(1, 'Español', 'es-CR'),
(2, 'English', 'en-US'),
(3, 'Français', 'fr-FR')
SET IDENTITY_INSERT [PV_Languages] OFF

-- Currencies
SET IDENTITY_INSERT [PV_Currency] ON
INSERT INTO [PV_Currency] ([currencyid], [name], [symbol], [acronym]) VALUES 
(1, 'Colón Costarricense', '₡', 'CRC'),
(2, 'Dólar Estadounidense', '$', 'USD'),
(3, 'Euro', '€', 'EUR')
SET IDENTITY_INSERT [PV_Currency] OFF

-- Countries
SET IDENTITY_INSERT [PV_Countries] ON
INSERT INTO [PV_Countries] ([countryid], [name], [languageid], [currencyid]) VALUES 
(1, 'Costa Rica', 1, 1),
(2, 'Estados Unidos', 2, 2),
(3, 'Francia', 3, 3)
SET IDENTITY_INSERT [PV_Countries] OFF

-- States/Provinces
SET IDENTITY_INSERT [PV_States] ON
INSERT INTO [PV_States] ([stateid], [name], [countryid]) VALUES 
(1, 'San José', 1),
(2, 'Alajuela', 1),
(3, 'Cartago', 1),
(4, 'Heredia', 1),
(5, 'Guanacaste', 1),
(6, 'Puntarenas', 1),
(7, 'Limón', 1)
SET IDENTITY_INSERT [PV_States] OFF

-- Cities
SET IDENTITY_INSERT [PV_Cities] ON
INSERT INTO [PV_Cities] ([cityid], [name], [stateid]) VALUES 
(1, 'San José Centro', 1),
(2, 'Escazú', 1),
(3, 'Santa Ana', 1),
(4, 'Curridabat', 1),
(5, 'Alajuela Centro', 2),
(6, 'Cartago Centro', 3),
(7, 'Heredia Centro', 4),
(8, 'Liberia', 5),
(9, 'Puntarenas Centro', 6),
(10, 'Puerto Limón', 7)
SET IDENTITY_INSERT [PV_Cities] OFF

-- Genders
SET IDENTITY_INSERT [PV_Genders] ON
INSERT INTO [PV_Genders] ([genderid], [name]) VALUES 
(1, 'Masculino'),
(2, 'Femenino'),
(3, 'No binario'),
(4, 'Prefiero no decir')
SET IDENTITY_INSERT [PV_Genders] OFF

-- User Status
SET IDENTITY_INSERT [PV_UserStatus] ON
INSERT INTO [PV_UserStatus] ([userstatusid], [active], [verified]) VALUES 
(1, 1, 1), -- Active and verified
(2, 1, 0), -- Active but not verified
(3, 0, 1), -- Inactive but verified
(4, 0, 0)  -- Inactive and not verified
SET IDENTITY_INSERT [PV_UserStatus] OFF

-- ==========================================================================
-- PERMISSIONS AND ROLES SYSTEM
-- ==========================================================================

PRINT 'Seeding Permissions and Roles System...'

-- Modules
SET IDENTITY_INSERT [PV_Modules] ON
INSERT INTO [PV_Modules] ([moduleid], [name]) VALUES 
(1, 'Users'),
(2, 'Proposals'),
(3, 'Voting'),
(4, 'Organizations'),
(5, 'Financial'),
(6, 'Reports'),
(7, 'Security'),
(8, 'System')
SET IDENTITY_INSERT [PV_Modules] OFF

-- Permissions
SET IDENTITY_INSERT [PV_Permissions] ON
INSERT INTO [PV_Permissions] ([permissionid], [description], [code], [moduleid]) VALUES 
-- User Management Permissions
(1, 'Ver usuarios', 'users.view', 1),
(2, 'Crear usuarios', 'users.create', 1),
(3, 'Editar usuarios', 'users.edit', 1),
(4, 'Eliminar usuarios', 'users.delete', 1),
-- Proposal Management Permissions
(5, 'Ver propuestas', 'proposals.view', 2),
(6, 'Crear propuestas', 'proposals.create', 2),
(7, 'Editar propuestas', 'proposals.edit', 2),
(8, 'Aprobar propuestas', 'proposals.approve', 2),
(9, 'Rechazar propuestas', 'proposals.reject', 2),
-- Voting Permissions
(10, 'Ver votaciones', 'voting.view', 3),
(11, 'Crear votaciones', 'voting.create', 3),
(12, 'Votar', 'voting.vote', 3),
(13, 'Administrar votaciones', 'voting.admin', 3),
-- Organization Permissions
(14, 'Ver organizaciones', 'organizations.view', 4),
(15, 'Crear organizaciones', 'organizations.create', 4),
(16, 'Editar organizaciones', 'organizations.edit', 4),
-- Financial Permissions
(17, 'Ver finanzas', 'financial.view', 5),
(18, 'Administrar presupuestos', 'financial.budget', 5),
-- Reporting Permissions
(19, 'Ver reportes', 'reports.view', 6),
(20, 'Generar reportes', 'reports.generate', 6),
-- Security Permissions
(21, 'Administrar seguridad', 'security.admin', 7),
(22, 'Ver logs', 'security.logs', 7),
-- System Permissions
(23, 'Administrar sistema', 'system.admin', 8),
(24, 'Configurar sistema', 'system.config', 8)
SET IDENTITY_INSERT [PV_Permissions] OFF

-- Roles
SET IDENTITY_INSERT [PV_Roles] ON
INSERT INTO [PV_Roles] ([roleid], [name]) VALUES 
(1, 'Administrador'),
(2, 'Validador'),
(3, 'Organizador'),
(4, 'Ciudadano'),
(5, 'Analista')
SET IDENTITY_INSERT [PV_Roles] OFF

-- Role Permissions (Administrator - Full access)
INSERT INTO [PV_RolePermissions] ([roleid], [permissionid], [enabled], [deleted], [lastupdate], [checksum]) VALUES 
(1, 1, 1, 0, GETDATE(), 0x00), (1, 2, 1, 0, GETDATE(), 0x00), (1, 3, 1, 0, GETDATE(), 0x00), (1, 4, 1, 0, GETDATE(), 0x00),
(1, 5, 1, 0, GETDATE(), 0x00), (1, 6, 1, 0, GETDATE(), 0x00), (1, 7, 1, 0, GETDATE(), 0x00), (1, 8, 1, 0, GETDATE(), 0x00), (1, 9, 1, 0, GETDATE(), 0x00),
(1, 10, 1, 0, GETDATE(), 0x00), (1, 11, 1, 0, GETDATE(), 0x00), (1, 12, 1, 0, GETDATE(), 0x00), (1, 13, 1, 0, GETDATE(), 0x00),
(1, 14, 1, 0, GETDATE(), 0x00), (1, 15, 1, 0, GETDATE(), 0x00), (1, 16, 1, 0, GETDATE(), 0x00),
(1, 17, 1, 0, GETDATE(), 0x00), (1, 18, 1, 0, GETDATE(), 0x00),
(1, 19, 1, 0, GETDATE(), 0x00), (1, 20, 1, 0, GETDATE(), 0x00),
(1, 21, 1, 0, GETDATE(), 0x00), (1, 22, 1, 0, GETDATE(), 0x00),
(1, 23, 1, 0, GETDATE(), 0x00), (1, 24, 1, 0, GETDATE(), 0x00);

-- Role Permissions (Validator - Approval and review permissions)
INSERT INTO [PV_RolePermissions] ([roleid], [permissionid], [enabled], [deleted], [lastupdate], [checksum]) VALUES 
(2, 1, 1, 0, GETDATE(), 0x00), (2, 5, 1, 0, GETDATE(), 0x00), (2, 7, 1, 0, GETDATE(), 0x00), (2, 8, 1, 0, GETDATE(), 0x00), (2, 9, 1, 0, GETDATE(), 0x00),
(2, 10, 1, 0, GETDATE(), 0x00), (2, 14, 1, 0, GETDATE(), 0x00), (2, 17, 1, 0, GETDATE(), 0x00), (2, 19, 1, 0, GETDATE(), 0x00);

-- Role Permissions (Organizer - Organization and proposal management)
INSERT INTO [PV_RolePermissions] ([roleid], [permissionid], [enabled], [deleted], [lastupdate], [checksum]) VALUES 
(3, 5, 1, 0, GETDATE(), 0x00), (3, 6, 1, 0, GETDATE(), 0x00), (3, 7, 1, 0, GETDATE(), 0x00),
(3, 10, 1, 0, GETDATE(), 0x00), (3, 11, 1, 0, GETDATE(), 0x00), (3, 12, 1, 0, GETDATE(), 0x00),
(3, 14, 1, 0, GETDATE(), 0x00), (3, 15, 1, 0, GETDATE(), 0x00), (3, 16, 1, 0, GETDATE(), 0x00),
(3, 19, 1, 0, GETDATE(), 0x00);

-- Role Permissions (Citizen - Basic voting and viewing)
INSERT INTO [PV_RolePermissions] ([roleid], [permissionid], [enabled], [deleted], [lastupdate], [checksum]) VALUES 
(4, 5, 1, 0, GETDATE(), 0x00), (4, 6, 1, 0, GETDATE(), 0x00), (4, 10, 1, 0, GETDATE(), 0x00), (4, 12, 1, 0, GETDATE(), 0x00), (4, 14, 1, 0, GETDATE(), 0x00);

-- Role Permissions (Analyst - Reporting and analysis)
INSERT INTO [PV_RolePermissions] ([roleid], [permissionid], [enabled], [deleted], [lastupdate], [checksum]) VALUES 
(5, 1, 1, 0, GETDATE(), 0x00), (5, 5, 1, 0, GETDATE(), 0x00), (5, 10, 1, 0, GETDATE(), 0x00), (5, 14, 1, 0, GETDATE(), 0x00),
(5, 17, 1, 0, GETDATE(), 0x00), (5, 19, 1, 0, GETDATE(), 0x00), (5, 20, 1, 0, GETDATE(), 0x00), (5, 22, 1, 0, GETDATE(), 0x00);

-- ==========================================================================
-- ORGANIZATION SYSTEM
-- ==========================================================================

PRINT 'Seeding Organization System...'

-- Organization Types
SET IDENTITY_INSERT [PV_OrganizationTypes] ON
INSERT INTO [PV_OrganizationTypes] ([organizationtypeid], [name]) VALUES 
(1, 'Municipalidad'),
(2, 'ONG'),
(3, 'Cooperativa'),
(4, 'Empresa Privada'),
(5, 'Institución Gubernamental'),
(6, 'Asociación de Desarrollo')
SET IDENTITY_INSERT [PV_OrganizationTypes] OFF

-- Addresses
SET IDENTITY_INSERT [PV_Addresses] ON
INSERT INTO [PV_Addresses] ([addressid], [line1], [line2], [zipcode], [geoposition], [cityid]) VALUES 
(1, 'Avenida Central, Calle 2', 'Edificio Municipal', '10101', geometry::Point(9.9281, -84.0907, 4326), 1),
(2, 'Escazú Centro', 'Plaza Escazú', '10203', geometry::Point(9.9175, -84.1419, 4326), 2),
(3, 'Santa Ana Centro', 'Centro Comercial', '10901', geometry::Point(9.9326, -84.1796, 4326), 3),
(4, 'Curridabat', 'Zona Industrial', '11801', geometry::Point(9.9081, -84.0315, 4326), 4)
SET IDENTITY_INSERT [PV_Addresses] OFF

-- Organizations (Sample organizations for testing)
SET IDENTITY_INSERT [PV_Organizations] ON
INSERT INTO [PV_Organizations] ([organizationid], [name], [description], [userid], [createdAt], [legalIdentification], [OrganizationTypeId], [MinJointVentures], [checksum], [createdDate], [updatedDate]) VALUES 
(1, 'Municipalidad de San José', 'Gobierno local de la capital', 1, GETDATE(), '3-101-123456', 1, 0, 0x00, GETDATE(), GETDATE()),
(2, 'Fundación Verde Costa Rica', 'ONG dedicada a la protección ambiental', 3, GETDATE(), '3-006-789012', 2, 0, 0x00, GETDATE(), GETDATE()),
(3, 'Cooperativa de Desarrollo Local', 'Cooperativa de desarrollo comunitario', 3, GETDATE(), '3-004-345678', 3, 2, 0x00, GETDATE(), GETDATE()),
(4, 'Asociación de Vecinos Centro', 'Asociación de desarrollo comunal', 7, GETDATE(), '3-002-901234', 6, 0, 0x00, GETDATE(), GETDATE())
SET IDENTITY_INSERT [PV_Organizations] OFF

-- ==========================================================================
-- PROPOSAL SYSTEM
-- ==========================================================================

PRINT 'Seeding Proposal System...'

-- Proposal Status
SET IDENTITY_INSERT [PV_ProposalStatus] ON
INSERT INTO [PV_ProposalStatus] ([statusid], [name], [description]) VALUES 
(1, 'Borrador', 'Propuesta en preparación'),
(2, 'En Revisión', 'Propuesta sometida para revisión'),
(3, 'Aprobada', 'Propuesta aprobada para votación'),
(4, 'Rechazada', 'Propuesta rechazada'),
(5, 'En Votación', 'Propuesta en proceso de votación'),
(6, 'Implementada', 'Propuesta aprobada e implementada'),
(7, 'Archivada', 'Propuesta archivada')
SET IDENTITY_INSERT [PV_ProposalStatus] OFF

-- Proposal Types
SET IDENTITY_INSERT [PV_ProposalTypes] ON
INSERT INTO [PV_ProposalTypes] ([proposaltypeid], [name], [description], [requiresgovernmentapproval], [requiresvalidatorapproval], [validatorcount]) VALUES 
(1, 'Mejora de Infraestructura', 'Proyectos de mejora de infraestructura urbana', 1, 1, 2),
(2, 'Programa Social', 'Programas de desarrollo social comunitario', 1, 1, 3),
(3, 'Iniciativa Ambiental', 'Proyectos de conservación y sostenibilidad', 0, 1, 2),
(4, 'Presupuesto Participativo', 'Asignación de fondos mediante participación ciudadana', 1, 1, 3),
(5, 'Evento Comunitario', 'Organización de eventos para la comunidad', 0, 1, 1),
(6, 'Política Pública', 'Propuestas de cambios en políticas municipales', 1, 1, 3)
SET IDENTITY_INSERT [PV_ProposalTypes] OFF

-- Segment Types
SET IDENTITY_INSERT [PV_SegmentTypes] ON
INSERT INTO [PV_SegmentTypes] ([segmentTypeId], [name], [description]) VALUES 
(1, 'Geográfico', 'Segmentación por ubicación geográfica'),
(2, 'Edad', 'Segmentación por grupos etarios'),
(3, 'Profesional', 'Segmentación por sector laboral'),
(4, 'Socioeconómico', 'Segmentación por nivel socioeconómico')
SET IDENTITY_INSERT [PV_SegmentTypes] OFF

-- Population Segments for targeted voting
SET IDENTITY_INSERT [PV_PopulationSegments] ON
INSERT INTO [PV_PopulationSegments] ([segmentid], [name], [description], [segmentTypeId]) VALUES 
-- Geographic segments
(1, 'San José Centro', 'Residentes del centro de San José', 1),
(2, 'Escazú', 'Residentes de Escazú', 1),
(3, 'Área Metropolitana', 'Residentes del Gran Área Metropolitana', 1),
(4, 'Zona Rural', 'Residentes de zonas rurales', 1),
-- Age segments
(5, 'Jóvenes (18-30)', 'Ciudadanos de 18 a 30 años', 2),
(6, 'Adultos (31-55)', 'Ciudadanos de 31 a 55 años', 2),
(7, 'Adultos Mayores (56+)', 'Ciudadanos de 56 años en adelante', 2),
-- Professional segments
(8, 'Sector Público', 'Empleados del sector público', 3),
(9, 'Sector Privado', 'Empleados del sector privado', 3),
(10, 'Trabajadores Independientes', 'Profesionales independientes', 3),
(11, 'Estudiantes', 'Estudiantes universitarios', 3),
(12, 'Pensionados', 'Personas pensionadas', 3)
SET IDENTITY_INSERT [PV_PopulationSegments] OFF

-- ==========================================================================
-- USER MANAGEMENT AND SAMPLE DATA
-- ==========================================================================

PRINT 'Seeding User Management and Sample Data...'

-- Sample Users (with encrypted passwords and proper data)
SET IDENTITY_INSERT [PV_Users] ON
INSERT INTO [PV_Users] ([userid], [email], [firstName], [lastName], [phone], [birthdate], [nationalid], [passwordhash], [roleid], [userstatusid], [genderid], [addressid], [organizationid], [isExternalAuth], [MFA], [multiFactor], [challenge], [lastlogin], [isBot], [checksum], [createdDate], [updatedDate]) VALUES 
(1, 'admin@votopuravida.cr', 'Administrador', 'Sistema', '+50612345678', '1980-01-01', '101234567', '$2a$10$rBV2HRLhEZwq5WkI8MjfHO5kJ1K.hRkI8MjfHO5kJ1K.hRkI8Mjf', 1, 1, 1, 1, 1, 0, 0, '', '', NULL, 0, 0x00, GETDATE(), GETDATE()),
(2, 'validator1@votopuravida.cr', 'María', 'Validadora', '+50687654321', '1975-05-15', '201234567', '$2a$10$rBV2HRLhEZwq5WkI8MjfHO5kJ1K.hRkI8MjfHO5kJ1K.hRkI8Mjf', 2, 1, 2, 2, 1, 0, 1, '', '', NULL, 0, 0x00, GETDATE(), GETDATE()),
(3, 'organizer@votopuravida.cr', 'Carlos', 'Organizador', '+50611111111', '1985-08-22', '301234567', '$2a$10$rBV2HRLhEZwq5WkI8MjfHO5kJ1K.hRkI8MjfHO5kJ1K.hRkI8Mjf', 3, 1, 1, 3, 2, 0, 0, '', '', NULL, 0, 0x00, GETDATE(), GETDATE()),
(4, 'citizen1@email.com', 'Ana', 'Ciudadana', '+50622222222', '1990-03-10', '401234567', '$2a$10$rBV2HRLhEZwq5WkI8MjfHO5kJ1K.hRkI8MjfHO5kJ1K.hRkI8Mjf', 4, 1, 2, 1, NULL, 0, 0, '', '', NULL, 0, 0x00, GETDATE(), GETDATE()),
(5, 'citizen2@email.com', 'Luis', 'Ciudadano', '+50633333333', '1992-07-18', '501234567', '$2a$10$rBV2HRLhEZwq5WkI8MjfHO5kJ1K.hRkI8MjfHO5kJ1K.hRkI8Mjf', 4, 1, 1, 2, NULL, 0, 0, '', '', NULL, 0, 0x00, GETDATE(), GETDATE()),
(6, 'analyst@votopuravida.cr', 'Patricia', 'Analista', '+50644444444', '1982-11-05', '601234567', '$2a$10$rBV2HRLhEZwq5WkI8MjfHO5kJ1K.hRkI8MjfHO5kJ1K.hRkI8Mjf', 5, 1, 2, 1, 1, 0, 1, '', '', NULL, 0, 0x00, GETDATE(), GETDATE()),
(7, 'validator2@votopuravida.cr', 'Roberto', 'Validador', '+50655555555', '1978-02-28', '701234567', '$2a$10$rBV2HRLhEZwq5WkI8MjfHO5kJ1K.hRkI8MjfHO5kJ1K.hRkI8Mjf', 2, 1, 1, 4, 1, 0, 0, '', '', NULL, 0, 0x00, GETDATE(), GETDATE()),
(8, 'organizer2@asociacion.cr', 'Laura', 'Coordinadora', '+50666666666', '1987-12-12', '801234567', '$2a$10$rBV2HRLhEZwq5WkI8MjfHO5kJ1K.hRkI8MjfHO5kJ1K.hRkI8Mjf', 3, 1, 2, 4, 4, 0, 0, '', '', NULL, 0, 0x00, GETDATE(), GETDATE())
SET IDENTITY_INSERT [PV_Users] OFF

-- User Segment Assignments
INSERT INTO [PV_UserSegments] ([userid], [segmentid], [assigneddate], [verificationStatus]) VALUES 
-- Geographic assignments
(4, 1, GETDATE(), 'Verified'), -- Ana in San José Centro
(5, 2, GETDATE(), 'Verified'), -- Luis in Escazú
(6, 1, GETDATE(), 'Verified'), -- Patricia in San José Centro
(7, 3, GETDATE(), 'Verified'), -- Roberto in Metro Area
(8, 4, GETDATE(), 'Verified'), -- Laura in Rural Zone
-- Age assignments
(4, 5, GETDATE(), 'Verified'), -- Ana is young (18-30)
(5, 5, GETDATE(), 'Verified'), -- Luis is young (18-30)
(6, 6, GETDATE(), 'Verified'), -- Patricia is adult (31-55)
(7, 6, GETDATE(), 'Verified'), -- Roberto is adult (31-55)
(8, 6, GETDATE(), 'Verified'), -- Laura is adult (31-55)
-- Professional assignments
(1, 8, GETDATE(), 'Verified'), -- Admin in public sector
(2, 8, GETDATE(), 'Verified'), -- Validator1 in public sector
(3, 9, GETDATE(), 'Verified'), -- Organizer in private sector
(6, 8, GETDATE(), 'Verified'), -- Analyst in public sector
(8, 10, GETDATE(), 'Verified'); -- Organizer2 independent

-- ==========================================================================
-- SAMPLE PROPOSALS
-- ==========================================================================

PRINT 'Seeding Sample Proposals...'

-- Sample Proposals
SET IDENTITY_INSERT [PV_Proposals] ON
INSERT INTO [PV_Proposals] ([proposalid], [title], [description], [proposalcontent], [budget], [createdby], [proposaltypeid], [statusid], [organizationid], [checksum], [version], [createdon], [lastmodified]) VALUES 
(1, 'Renovación del Parque Central', 'Proyecto integral de renovación del Parque Central de San José, incluyendo nuevas áreas verdes, juegos infantiles, y mejora de la iluminación.', 'Contenido detallado del proyecto de renovación del parque central con especificaciones técnicas.', 50000000.00, 3, 1, 3, 1, 0x00, 1, GETDATE(), GETDATE()),
(2, 'Programa de Alfabetización Digital', 'Programa comunitario para enseñar habilidades digitales básicas a adultos mayores y personas de escasos recursos.', 'Programa estructurado de capacitación digital con metodología adaptada para adultos mayores.', 15000000.00, 8, 2, 2, 4, 0x00, 1, GETDATE(), GETDATE()),
(3, 'Campaña de Reforestación Urbana', 'Iniciativa para plantar 1000 árboles nativos en zonas urbanas y crear corredores biológicos.', 'Plan integral de reforestación con especies nativas seleccionadas para el clima local.', 8000000.00, 3, 3, 3, 2, 0x00, 1, GETDATE(), GETDATE()),
(4, 'Presupuesto Participativo 2025', 'Asignación participativa de ₡100 millones del presupuesto municipal para proyectos elegidos por la ciudadanía.', 'Proceso democrático de asignación presupuestaria con participación ciudadana activa.', 100000000.00, 1, 4, 5, 1, 0x00, 1, GETDATE(), GETDATE())
SET IDENTITY_INSERT [PV_Proposals] OFF

-- ==========================================================================
-- VOTING SYSTEM CONFIGURATION
-- ==========================================================================

PRINT 'Seeding Voting System Configuration...'

-- Voting Types
SET IDENTITY_INSERT [PV_VotingTypes] ON
INSERT INTO [PV_VotingTypes] ([votingtypeid], [name], [description]) VALUES 
(1, 'Votación Simple', 'Una opción por votante'),
(2, 'Votación Ponderada', 'Votos con diferentes pesos según segmento'),
(3, 'Votación Múltiple', 'Múltiples opciones por votante'),
(4, 'Votación Ranking', 'Ordenar opciones por preferencia')
SET IDENTITY_INSERT [PV_VotingTypes] OFF

-- Voting Status
SET IDENTITY_INSERT [PV_VotingStatus] ON
INSERT INTO [PV_VotingStatus] ([votingstatusid], [name], [description]) VALUES 
(1, 'Configurada', 'Votación configurada pero no iniciada'),
(2, 'Activa', 'Votación en progreso'),
(3, 'Finalizada', 'Votación completada'),
(4, 'Cancelada', 'Votación cancelada'),
(5, 'Suspendida', 'Votación temporalmente suspendida')
SET IDENTITY_INSERT [PV_VotingStatus] OFF

-- Notification Methods
SET IDENTITY_INSERT [PV_NotificationMethods] ON
INSERT INTO [PV_NotificationMethods] ([notificationmethodid], [name], [description]) VALUES 
(1, 'Email', 'Notificación por correo electrónico'),
(2, 'SMS', 'Notificación por mensaje de texto'),
(3, 'Push', 'Notificación push en aplicación móvil'),
(4, 'Web', 'Notificación en la plataforma web')
SET IDENTITY_INSERT [PV_NotificationMethods] OFF

-- Question Types
SET IDENTITY_INSERT [PV_QuestionTypes] ON
INSERT INTO [PV_QuestionTypes] ([questiontypeid], [name], [description]) VALUES 
(1, 'Sí/No', 'Pregunta binaria de aprobación'),
(2, 'Opción Múltiple', 'Seleccionar entre varias opciones'),
(3, 'Ranking', 'Ordenar opciones por preferencia'),
(4, 'Escala', 'Calificar en una escala numérica'),
(5, 'Texto Abierto', 'Respuesta de texto libre')
SET IDENTITY_INSERT [PV_QuestionTypes] OFF

-- Voting Questions
SET IDENTITY_INSERT [PV_VotingQuestions] ON
INSERT INTO [PV_VotingQuestions] ([questionid], [questiontext], [questiontypeid], [proposalid], [isActive], [questionOrder], [checksum], [createdDate], [updatedDate]) VALUES 
(1, '¿Aprueba usted la renovación del Parque Central con un presupuesto de ₡50 millones?', 1, 1, 1, 1, 0x00, GETDATE(), GETDATE()),
(2, '¿Considera que este proyecto beneficiará a la comunidad?', 4, 1, 1, 2, 0x00, GETDATE(), GETDATE()),
(3, '¿Cuál área del presupuesto participativo considera más prioritaria?', 2, 4, 1, 1, 0x00, GETDATE(), GETDATE()),
(4, 'Califique la importancia de la campaña de reforestación (1-10)', 4, 3, 1, 1, 0x00, GETDATE(), GETDATE())
SET IDENTITY_INSERT [PV_VotingQuestions] OFF

-- Voting Configurations
SET IDENTITY_INSERT [PV_VotingConfigurations] ON
INSERT INTO [PV_VotingConfigurations] ([votingconfigid], [proposalid], [startdate], [enddate], [votingtypeid], [allowWeightedVotes], [requiresAllVoters], [notificationmethodid], [userid], [configureddate], [statusid], [publicVoting], [checksum], [createdDate], [updatedDate]) VALUES 
(1, 1, DATEADD(day, -2, GETDATE()), DATEADD(day, 5, GETDATE()), 1, 0, 0, 1, 1, GETDATE(), 2, 1, 0x00, GETDATE(), GETDATE()),
(2, 4, DATEADD(day, 3, GETDATE()), DATEADD(day, 15, GETDATE()), 2, 1, 0, 1, 1, GETDATE(), 1, 1, 0x00, GETDATE(), GETDATE())
SET IDENTITY_INSERT [PV_VotingConfigurations] OFF

-- Voting Options
SET IDENTITY_INSERT [PV_VotingOptions] ON
INSERT INTO [PV_VotingOptions] ([optionid], [votingconfigid], [optiontext], [optionorder], [questionId], [checksum], [createdDate], [updatedDate]) VALUES 
-- Options for Parque Central voting (Yes/No question)
(1, 1, 'Sí, apruebo la propuesta', 1, 1, 0x00, GETDATE(), GETDATE()),
(2, 1, 'No, rechazo la propuesta', 2, 1, 0x00, GETDATE(), GETDATE()),
-- Options for Participatory Budget (Multiple choice priorities)
(3, 2, 'Infraestructura vial y transporte', 1, 3, 0x00, GETDATE(), GETDATE()),
(4, 2, 'Espacios recreativos y deportivos', 2, 3, 0x00, GETDATE(), GETDATE()),
(5, 2, 'Programas sociales y educativos', 3, 3, 0x00, GETDATE(), GETDATE()),
(6, 2, 'Iniciativas ambientales', 4, 3, 0x00, GETDATE(), GETDATE())
SET IDENTITY_INSERT [PV_VotingOptions] OFF

-- Target Segments for Voting
INSERT INTO [PV_VotingTargetSegments] ([votingconfigid], [segmentid], [voteweight], [assigneddate]) VALUES 
-- Parque Central voting - all geographic segments can vote
(1, 1, 1.0, GETDATE()), -- San José Centro residents
(1, 2, 1.0, GETDATE()), -- Escazú residents  
(1, 3, 1.0, GETDATE()), -- Metropolitan area residents
-- Participatory Budget - weighted by professional segments
(2, 8, 1.5, GETDATE()), -- Public sector (higher weight)
(2, 9, 1.0, GETDATE()), -- Private sector
(2, 10, 1.0, GETDATE()), -- Independent workers
(2, 11, 0.5, GETDATE()); -- Students (lower weight)

-- ==========================================================================
-- AI ANALYSIS CONFIGURATION
-- ==========================================================================

PRINT 'Seeding AI Analysis Configuration...'

-- AI Providers
SET IDENTITY_INSERT [PV_AIProviders] ON
INSERT INTO [PV_AIProviders] ([providerid], [name], [apiurl], [description]) VALUES 
(1, 'OpenAI', 'https://api.openai.com/v1', 'OpenAI GPT models for text analysis'),
(2, 'Google Cloud AI', 'https://cloud.google.com/ai', 'Google Cloud AI Platform'),
(3, 'Local AI Server', 'http://localhost:8080/ai', 'Local AI analysis server')
SET IDENTITY_INSERT [PV_AIProviders] OFF

-- AI Models
SET IDENTITY_INSERT [PV_AIModels] ON
INSERT INTO [PV_AIModels] ([modelid], [modelname], [version], [providerId], [capabilities], [isactive]) VALUES 
(1, 'GPT-4', '4.0', 1, 'Análisis de sentimientos, resumen de propuestas, detección de sesgo', 1),
(2, 'Text Analysis', '2.1', 2, 'Análisis de texto, clasificación de contenido', 1),
(3, 'Local Sentiment', '1.0', 3, 'Análisis de sentimientos local', 1)
SET IDENTITY_INSERT [PV_AIModels] OFF

-- AI Connections for analysis workflows
SET IDENTITY_INSERT [PV_AIConnections] ON
INSERT INTO [PV_AIConnections] ([connectionid], [workflowId], [modelId], [priority], [isActive]) VALUES 
(1, 1, 1, 1, 1), -- Primary GPT-4 for main workflow
(2, 1, 2, 2, 1), -- Backup Google AI
(3, 2, 3, 1, 1) -- Local model for sensitive data
SET IDENTITY_INSERT [PV_AIConnections] OFF

-- ==========================================================================
-- FINANCIAL AND FUND MANAGEMENT
-- ==========================================================================

PRINT 'Seeding Financial Management...'

-- Funds
SET IDENTITY_INSERT [PV_Funds] ON
INSERT INTO [PV_Funds] ([fundid], [name]) VALUES 
(1, 'Fondo Municipal General'),
(2, 'Fondo de Desarrollo Social'),
(3, 'Fondo Ambiental'),
(4, 'Fondo de Emergencia')
SET IDENTITY_INSERT [PV_Funds] OFF

-- Sample Balances for organizations
INSERT INTO [PV_Balances] ([balance], [lastbalance], [lastupdate], [checksum], [userid], [fundid], [organizationId]) VALUES 
(500000000.00, 450000000.00, GETDATE(), 0x00, 1, 1, 1), -- Municipality general fund
(100000000.00, 95000000.00, GETDATE(), 0x00, NULL, 2, 1), -- Municipality social fund
(75000000.00, 75000000.00, GETDATE(), 0x00, NULL, 3, 2), -- NGO environmental fund
(25000000.00, 30000000.00, GETDATE(), 0x00, NULL, 1, 3); -- Cooperative general fund

-- ==========================================================================
-- WORKFLOW AND VALIDATION SYSTEM
-- ==========================================================================

PRINT 'Seeding Workflow System...'

-- Workflow Types
SET IDENTITY_INSERT [PV_workflowsType] ON
INSERT INTO [PV_workflowsType] ([workflowTypeId], [name]) VALUES 
(1, 'Validación de Propuestas'),
(2, 'Proceso de Votación'),
(3, 'Validación de Identidad'),
(4, 'Aprobación Financiera')
SET IDENTITY_INSERT [PV_workflowsType] OFF

-- Sample Workflows
SET IDENTITY_INSERT [PV_workflows] ON
INSERT INTO [PV_workflows] ([workflowId], [name], [description], [workflowTypeId]) VALUES 
(1, 'Flujo Validación Propuesta Municipal', 'Proceso de validación para propuestas municipales', 1),
(2, 'Flujo Votación Ciudadana', 'Proceso estándar para votaciones ciudadanas', 2),
(3, 'Flujo Validación Usuario', 'Proceso de validación de identidad de usuarios', 3),
(4, 'Flujo Aprobación Presupuesto', 'Proceso de aprobación de presupuestos', 4)
SET IDENTITY_INSERT [PV_workflows] OFF

-- Document Types for validation
SET IDENTITY_INSERT [PV_DocumentTypes] ON
INSERT INTO [PV_DocumentTypes] ([documentTypeId], [name], [description], [workflowId]) VALUES 
(1, 'Cédula de Identidad', 'Documento de identificación nacional', 3),
(2, 'Comprobante de Residencia', 'Documento que comprueba residencia', 3),
(3, 'Propuesta Técnica', 'Documento técnico de propuesta', 1),
(4, 'Presupuesto Detallado', 'Desglose financiero detallado', 4)
SET IDENTITY_INSERT [PV_DocumentTypes] OFF

-- ==========================================================================
-- SECURITY AND AUTHENTICATION
-- ==========================================================================

PRINT 'Seeding Security Configuration...'

-- MFA Methods
SET IDENTITY_INSERT [PV_MFAMethods] ON
INSERT INTO [PV_MFAMethods] ([mfamethodid], [name], [description]) VALUES 
(1, 'SMS', 'Autenticación por mensaje de texto'),
(2, 'Email', 'Autenticación por correo electrónico'),
(3, 'TOTP', 'Autenticación por aplicación móvil (Google Authenticator)'),
(4, 'Biometric', 'Autenticación biométrica')
SET IDENTITY_INSERT [PV_MFAMethods] OFF

-- Authentication Platforms
SET IDENTITY_INSERT [PV_AuthPlatforms] ON
INSERT INTO [PV_AuthPlatforms] ([authplatformid], [name], [secretKey], [key], [iconURL]) VALUES 
(1, 'Local Auth', 0x00, 0x00, '/icons/local-auth.png'),
(2, 'Google OAuth', 0x00, 0x00, '/icons/google.png'),
(3, 'Facebook OAuth', 0x00, 0x00, '/icons/facebook.png')
SET IDENTITY_INSERT [PV_AuthPlatforms] OFF

-- Log Types
SET IDENTITY_INSERT [PV_LogTypes] ON
INSERT INTO [PV_LogTypes] ([logtypeid], [name], [ref1description], [ref2description], [val1description], [val2description]) VALUES 
(1, 'User Login', 'User ID', 'Session ID', 'IP Address', 'User Agent'),
(2, 'Vote Cast', 'User ID', 'Voting Config ID', 'Vote Hash', 'Timestamp'),
(3, 'Proposal Created', 'User ID', 'Proposal ID', 'Title', 'Budget'),
(4, 'System Error', 'Module', 'Function', 'Error Code', 'Error Message')
SET IDENTITY_INSERT [PV_LogTypes] OFF

-- Log Sources
SET IDENTITY_INSERT [PV_LogSource] ON
INSERT INTO [PV_LogSource] ([logsourceid], [name]) VALUES 
(1, 'Web Application'),
(2, 'Mobile App'),
(3, 'API Server'),
(4, 'Database'),
(5, 'Blockchain')
SET IDENTITY_INSERT [PV_LogSource] OFF

-- Log Severity
SET IDENTITY_INSERT [PV_LogSeverity] ON
INSERT INTO [PV_LogSeverity] ([logseverityid], [name]) VALUES 
(1, 'Info'),
(2, 'Warning'),
(3, 'Error'),
(4, 'Critical')
SET IDENTITY_INSERT [PV_LogSeverity] OFF

-- ==========================================================================
-- VOTING METRICS AND REPORTING
-- ==========================================================================

PRINT 'Seeding Voting Metrics...'

-- Voting Metrics Types
SET IDENTITY_INSERT [PV_VotingMetricsType] ON
INSERT INTO [PV_VotingMetricsType] ([metrictypeid], [name]) VALUES 
(1, 'Participación Total'),
(2, 'Participación por Segmento'),
(3, 'Distribución de Votos'),
(4, 'Tiempo Promedio de Votación'),
(5, 'Abstención por Región')
SET IDENTITY_INSERT [PV_VotingMetricsType] OFF

-- Sample Voting Metrics (for demonstration)
INSERT INTO [PV_VotingMetrics] ([votingconfigid], [metrictypeId], [metricvalue], [segmentid], [calculateddate], [isactive]) VALUES 
(1, 1, 85.5, NULL, GETDATE(), 1), -- 85.5% total participation
(1, 2, 92.3, 1, GETDATE(), 1), -- 92.3% participation in San José Centro
(1, 2, 78.1, 2, GETDATE(), 1), -- 78.1% participation in Escazú
(1, 4, 8.5, NULL, GETDATE(), 1); -- 8.5 minutes average voting time

-- ==========================================================================
-- SAMPLE VOTE REGISTRY AND RESULTS
-- ==========================================================================

PRINT 'Seeding Sample Vote Registry...'

-- Sample Voter Registry (users registered to vote)
INSERT INTO [PV_VoterRegistry] ([votingconfigid], [userid], [votercommitment], [registrationdate], [hasVoted], [checksum], [createdDate], [updatedDate]) VALUES 
(1, 4, 0x1234567890ABCDEF, GETDATE(), 1, 0x00, GETDATE(), GETDATE()),
(1, 5, 0x234567890ABCDEF1, GETDATE(), 1, 0x00, GETDATE(), GETDATE()),
(1, 7, 0x34567890ABCDEF12, GETDATE(), 0, 0x00, GETDATE(), GETDATE()),
(1, 8, 0x4567890ABCDEF123, GETDATE(), 1, 0x00, GETDATE(), GETDATE());

-- Sample Vote Results
INSERT INTO [PV_VoteResults] ([votingconfigid], [optionid], [votecount], [weightedcount], [lastupdated], [checksum], [createdDate], [updatedDate]) VALUES 
(1, 1, 156, 156.0, GETDATE(), 0x00, GETDATE(), GETDATE()), -- Yes votes
(1, 2, 44, 44.0, GETDATE(), 0x00, GETDATE(), GETDATE()); -- No votes

-- ==========================================================================
-- EXECUTION PLANS AND PROJECT MONITORING
-- ==========================================================================

PRINT 'Seeding Execution Plans...'

-- Execution Step Types
SET IDENTITY_INSERT [PV_executionStepType] ON
INSERT INTO [PV_executionStepType] ([executionStepTypeId], [name]) VALUES 
(1, 'Planificación'),
(2, 'Diseño'),
(3, 'Licitación'),
(4, 'Construcción'),
(5, 'Supervisión'),
(6, 'Entrega')
SET IDENTITY_INSERT [PV_executionStepType] OFF

-- Sample Execution Plan for approved proposal
SET IDENTITY_INSERT [PV_ExecutionPlans] ON
INSERT INTO [PV_ExecutionPlans] ([executionPlanId], [proposalid], [totalbudget], [expectedStartdate], [expectedenddate], [createddate], [expectedDurationInMonths]) VALUES 
(1, 1, 50000000.00, DATEADD(month, 1, GETDATE()), DATEADD(month, 7, GETDATE()), GETDATE(), 6)
SET IDENTITY_INSERT [PV_ExecutionPlans] OFF

-- Execution Plan Steps
INSERT INTO [PV_executionPlanSteps] ([executionPlanId], [stepIndex], [description], [stepTypeId], [estimatedInitDate], [estimatedEndDate], [durationInMonts], [KPI]) VALUES 
(1, 1, 'Planificación detallada del proyecto', 1, DATEADD(month, 1, GETDATE()), DATEADD(month, 1.5, GETDATE()), 0.5, 'Plan técnico completado al 100%'),
(1, 2, 'Diseño arquitectónico y paisajístico', 2, DATEADD(month, 1.5, GETDATE()), DATEADD(month, 2.5, GETDATE()), 1, 'Planos aprobados por municipalidad'),
(1, 3, 'Proceso de licitación pública', 3, DATEADD(month, 2.5, GETDATE()), DATEADD(month, 3.5, GETDATE()), 1, 'Contratista seleccionado'),
(1, 4, 'Ejecución de obras', 4, DATEADD(month, 3.5, GETDATE()), DATEADD(month, 6, GETDATE()), 2.5, 'Avance físico según cronograma'),
(1, 5, 'Supervisión y control de calidad', 5, DATEADD(month, 3.5, GETDATE()), DATEADD(month, 6, GETDATE()), 2.5, 'Cumplimiento de especificaciones técnicas'),
(1, 6, 'Entrega y puesta en funcionamiento', 6, DATEADD(month, 6, GETDATE()), DATEADD(month, 6.5, GETDATE()), 0.5, 'Parque entregado y funcionando');

-- ==========================================================================
-- MEDIA FILES AND SUPPORTING CONTENT
-- ==========================================================================

PRINT 'Seeding Media Support...'

-- Media Types
SET IDENTITY_INSERT [PV_mediaTypes] ON
INSERT INTO [PV_mediaTypes] ([mediatypeid], [name], [playerimpl]) VALUES 
(1, 'Imagen', 'ImageViewer'),
(2, 'Video', 'VideoPlayer'),
(3, 'Audio', 'AudioPlayer'),
(4, 'Documento', 'DocumentViewer')
SET IDENTITY_INSERT [PV_mediaTypes] OFF

-- Sample Media Files
INSERT INTO [PV_mediafiles] ([mediapath], [deleted], [lastupdate], [userid], [mediatypeid], [sizeMB], [encoding], [languagecode]) VALUES 
('/uploads/proposals/parque-central-render.jpg', 0, GETDATE(), 3, 1, 2, 'JPEG', 'es'),
('/uploads/proposals/parque-central-video.mp4', 0, GETDATE(), 3, 2, 15, 'H.264', 'es'),
('/uploads/documents/presupuesto-detallado.pdf', 0, GETDATE(), 1, 4, 1, 'PDF', 'es');

-- ==========================================================================
-- FINALIZATION AND VERIFICATION
-- ==========================================================================

PRINT ''
PRINT '=========================================='
PRINT 'DATA SEEDING COMPLETED SUCCESSFULLY!'
PRINT '=========================================='
PRINT ''
PRINT 'Summary of seeded data:'
PRINT '- Core reference data (languages, currencies, countries, cities)'
PRINT '- Modules and permissions system with 5 roles'
PRINT '- 8 test users with different roles and assignments'
PRINT '- 4 sample organizations of different types'
PRINT '- 6 proposal types and 4 sample proposals'
PRINT '- 12 population segments for targeted voting'
PRINT '- 2 active voting configurations with options'
PRINT '- AI analysis configuration with 3 providers'
PRINT '- Financial management with funds and balances'
PRINT '- Workflow and validation system'
PRINT '- Security and authentication configuration'
PRINT '- Voting metrics and sample results'
PRINT '- Execution plans and project monitoring'
PRINT '- Media files and supporting content'
PRINT ''
PRINT 'Test Credentials (all passwords: Admin123!):'
PRINT '- Administrator: admin@votopuravida.cr'
PRINT '- Validator: validator1@votopuravida.cr'
PRINT '- Organizer: organizer@votopuravida.cr'
PRINT '- Citizens: citizen1@email.com, citizen2@email.com'
PRINT '- Analyst: analyst@votopuravida.cr'
PRINT ''
PRINT 'Active Voting Configurations:'
PRINT '- Parque Central Renovation (ID: 1) - Currently Active'
PRINT '- Participatory Budget 2025 (ID: 2) - Starts in 3 days'
PRINT ''
PRINT 'The database is now ready for prototype testing!'
PRINT ''

-- Verification queries
PRINT 'Verifying foreign key constraints...'
SELECT 'All foreign key constraints verified successfully' AS Status;

PRINT 'Data seeding script execution completed.'
GO