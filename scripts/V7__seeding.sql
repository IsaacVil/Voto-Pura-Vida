-- V7__seeding.sql - Datos básicos de referencia para el sistema
-- Solo incluye datos fundamentales que no se crean por la aplicación

-- =============================================================================
-- 1. DATOS GEOGRÁFICOS Y LOCALIZACIÓN
-- =============================================================================

-- Idiomas básicos
IF NOT EXISTS (SELECT 1 FROM PV_Languages WHERE culture = 'es-CR')
    INSERT INTO PV_Languages (name, culture) VALUES ('Español', 'es-CR');

IF NOT EXISTS (SELECT 1 FROM PV_Languages WHERE culture = 'en-US')
    INSERT INTO PV_Languages (name, culture) VALUES ('Inglés', 'en-US');

-- Monedas básicas  
IF NOT EXISTS (SELECT 1 FROM PV_Currency WHERE acronym = 'CRC')
    INSERT INTO PV_Currency (name, symbol, acronym) VALUES ('Colón Costarricense', '₡', 'CRC');

IF NOT EXISTS (SELECT 1 FROM PV_Currency WHERE acronym = 'USD')
    INSERT INTO PV_Currency (name, symbol, acronym) VALUES ('Dólar Estadounidense', '$', 'USD');

-- Países principales usando SELECT para obtener IDs dinámicamente
IF NOT EXISTS (SELECT 1 FROM PV_Countries WHERE name = 'Costa Rica')
    INSERT INTO PV_Countries (name, languageid, currencyid) 
    SELECT 'Costa Rica', 
           (SELECT languageid FROM PV_Languages WHERE culture = 'es-CR'),
           (SELECT currencyid FROM PV_Currency WHERE acronym = 'CRC');

IF NOT EXISTS (SELECT 1 FROM PV_Countries WHERE name = 'Estados Unidos')
    INSERT INTO PV_Countries (name, languageid, currencyid) 
    SELECT 'Estados Unidos', 
           (SELECT languageid FROM PV_Languages WHERE culture = 'en-US'),
           (SELECT currencyid FROM PV_Currency WHERE acronym = 'USD');

-- Estados/Provincias de Costa Rica usando SELECT dinámico
DECLARE @CostaRicaId INT = (SELECT countryid FROM PV_Countries WHERE name = 'Costa Rica');

IF @CostaRicaId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PV_States WHERE name = 'San José' AND countryid = @CostaRicaId)
        INSERT INTO PV_States (name, countryid) VALUES ('San José', @CostaRicaId);
    
    IF NOT EXISTS (SELECT 1 FROM PV_States WHERE name = 'Alajuela' AND countryid = @CostaRicaId)
        INSERT INTO PV_States (name, countryid) VALUES ('Alajuela', @CostaRicaId);
    
    IF NOT EXISTS (SELECT 1 FROM PV_States WHERE name = 'Cartago' AND countryid = @CostaRicaId)
        INSERT INTO PV_States (name, countryid) VALUES ('Cartago', @CostaRicaId);
    
    IF NOT EXISTS (SELECT 1 FROM PV_States WHERE name = 'Heredia' AND countryid = @CostaRicaId)
        INSERT INTO PV_States (name, countryid) VALUES ('Heredia', @CostaRicaId);
    
    IF NOT EXISTS (SELECT 1 FROM PV_States WHERE name = 'Guanacaste' AND countryid = @CostaRicaId)
        INSERT INTO PV_States (name, countryid) VALUES ('Guanacaste', @CostaRicaId);
    
    IF NOT EXISTS (SELECT 1 FROM PV_States WHERE name = 'Puntarenas' AND countryid = @CostaRicaId)
        INSERT INTO PV_States (name, countryid) VALUES ('Puntarenas', @CostaRicaId);
    
    IF NOT EXISTS (SELECT 1 FROM PV_States WHERE name = 'Limón' AND countryid = @CostaRicaId)
        INSERT INTO PV_States (name, countryid) VALUES ('Limón', @CostaRicaId);
END;

-- =============================================================================
-- 2. SISTEMA DE PERMISOS Y ROLES
-- =============================================================================

-- Módulos del sistema
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Usuarios')
    INSERT INTO PV_Modules (name) VALUES ('Usuarios');
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Propuestas')
    INSERT INTO PV_Modules (name) VALUES ('Propuestas');
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Votaciones')
    INSERT INTO PV_Modules (name) VALUES ('Votaciones');
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Inversiones')
    INSERT INTO PV_Modules (name) VALUES ('Inversiones');
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Reportes')
    INSERT INTO PV_Modules (name) VALUES ('Reportes');

-- Permisos básicos
DECLARE @ModUsuarios INT = (SELECT moduleid FROM PV_Modules WHERE name = 'Usuarios');
DECLARE @ModPropuestas INT = (SELECT moduleid FROM PV_Modules WHERE name = 'Propuestas');
DECLARE @ModVotaciones INT = (SELECT moduleid FROM PV_Modules WHERE name = 'Votaciones');
DECLARE @ModInversiones INT = (SELECT moduleid FROM PV_Modules WHERE name = 'Inversiones');
DECLARE @ModReportes INT = (SELECT moduleid FROM PV_Modules WHERE name = 'Reportes');

IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'USR_VIEW')
    INSERT INTO PV_Permissions (code, description, moduleid) VALUES ('USR_VIEW', 'Ver usuarios', @ModUsuarios);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'PROP_VIEW')
    INSERT INTO PV_Permissions (code, description, moduleid) VALUES ('PROP_VIEW', 'Ver propuestas', @ModPropuestas);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'VOTE_VIEW')
    INSERT INTO PV_Permissions (code, description, moduleid) VALUES ('VOTE_VIEW', 'Ver votaciones', @ModVotaciones);

-- Roles básicos
IF NOT EXISTS (SELECT 1 FROM PV_Roles WHERE name = 'Ciudadano')
    INSERT INTO PV_Roles (name) VALUES ('Ciudadano');
IF NOT EXISTS (SELECT 1 FROM PV_Roles WHERE name = 'Administrador')
    INSERT INTO PV_Roles (name) VALUES ('Administrador');

-- =============================================================================
-- 3. TIPOS Y CONFIGURACIONES DEL SISTEMA
-- =============================================================================

-- Tipos de propuestas básicos
IF NOT EXISTS (SELECT 1 FROM PV_ProposalTypes WHERE name = 'Infraestructura')
    INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) 
    VALUES ('Infraestructura', 'Propuestas de infraestructura pública', 1, 1, 3);

IF NOT EXISTS (SELECT 1 FROM PV_ProposalTypes WHERE name = 'Educación')
    INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) 
    VALUES ('Educación', 'Propuestas educativas', 1, 1, 2);

-- Estados de propuestas básicos
IF NOT EXISTS (SELECT 1 FROM PV_ProposalStatus WHERE name = 'Borrador')
    INSERT INTO PV_ProposalStatus (name, description) VALUES ('Borrador', 'Propuesta en preparación');

IF NOT EXISTS (SELECT 1 FROM PV_ProposalStatus WHERE name = 'En Revisión')
    INSERT INTO PV_ProposalStatus (name, description) VALUES ('En Revisión', 'Propuesta en evaluación');

IF NOT EXISTS (SELECT 1 FROM PV_ProposalStatus WHERE name = 'Aprobada')
    INSERT INTO PV_ProposalStatus (name, description) VALUES ('Aprobada', 'Propuesta aprobada');

-- Tipos de documentos básicos
IF NOT EXISTS (SELECT 1 FROM PV_DocumentTypes WHERE name = 'Propuesta Técnica')
    INSERT INTO PV_DocumentTypes (name, description, workflowId) 
    VALUES ('Propuesta Técnica', 'Documento técnico de la propuesta', NULL);

-- Tipos de medios básicos
IF NOT EXISTS (SELECT 1 FROM PV_mediaTypes WHERE name = 'PDF')
    INSERT INTO PV_mediaTypes (name, playerimpl) VALUES ('PDF', 'application/pdf');

-- Tipos de log básicos
IF NOT EXISTS (SELECT 1 FROM PV_LogTypes WHERE name = 'Sistema')
    INSERT INTO PV_LogTypes (name, ref1description, ref2description, val1description, val2description) 
    VALUES ('Sistema', 'Componente', 'Operación', 'Código resultado', 'Tiempo ejecución');
-- =============================================================================

-- IPs permitidas básicas (localhost y redes locales)
INSERT INTO PV_AllowedIPs (ipaddress, ipmask, addressid, isallowed, description, createddate, lastmodified, checksum) VALUES ('127.0.0.1', '255.255.255.255', NULL, 1, 'Localhost', GETDATE(), GETDATE(), HASHBYTES('SHA2_256', '127.0.0.1-LOCAL'));
INSERT INTO PV_AllowedIPs (ipaddress, ipmask, addressid, isallowed, description, createddate, lastmodified, checksum) VALUES ('192.168.1.0', '255.255.255.0', NULL, 1, 'Red local administrativa', GETDATE(), GETDATE(), HASHBYTES('SHA2_256', '192.168.1.0-ADMIN'));

-- Países permitidos (solo Costa Rica por defecto)
DECLARE @CostaRicaCountryId INT = (SELECT countryid FROM PV_Countries WHERE name = 'Costa Rica');
DECLARE @EstadosUnidosCountryId INT = (SELECT countryid FROM PV_Countries WHERE name = 'Estados Unidos');

IF @CostaRicaCountryId IS NOT NULL
    INSERT INTO PV_AllowedCountries (countryid, isallowed, createddate, lastmodified) 
    VALUES (@CostaRicaCountryId, 1, GETDATE(), GETDATE());

IF @EstadosUnidosCountryId IS NOT NULL
    INSERT INTO PV_AllowedCountries (countryid, isallowed, createddate, lastmodified) 
    VALUES (@EstadosUnidosCountryId, 0, GETDATE(), GETDATE());

-- Nota: Los estados ya se crearon anteriormente con IF NOT EXISTS
-- Estados adicionales para Estados Unidos usando IDs dinámicos
IF @EstadosUnidosCountryId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PV_States WHERE name = 'California' AND countryid = @EstadosUnidosCountryId)
        INSERT INTO PV_States (name, countryid) VALUES ('California', @EstadosUnidosCountryId);
    IF NOT EXISTS (SELECT 1 FROM PV_States WHERE name = 'Texas' AND countryid = @EstadosUnidosCountryId)
        INSERT INTO PV_States (name, countryid) VALUES ('Texas', @EstadosUnidosCountryId);
END

-- Ciudades principales usando IDs dinámicos
DECLARE @SanJoseStateId INT = (SELECT stateid FROM PV_States WHERE name = 'San José' AND countryid = @CostaRicaCountryId);
DECLARE @AlajuelaStateId INT = (SELECT stateid FROM PV_States WHERE name = 'Alajuela' AND countryid = @CostaRicaCountryId);
DECLARE @CartagoStateId INT = (SELECT stateid FROM PV_States WHERE name = 'Cartago' AND countryid = @CostaRicaCountryId);
DECLARE @HerediaStateId INT = (SELECT stateid FROM PV_States WHERE name = 'Heredia' AND countryid = @CostaRicaCountryId);
DECLARE @GuanacasteStateId INT = (SELECT stateid FROM PV_States WHERE name = 'Guanacaste' AND countryid = @CostaRicaCountryId);

IF @SanJoseStateId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PV_Cities WHERE name = 'San José Centro' AND stateid = @SanJoseStateId)
        INSERT INTO PV_Cities (name, stateid) VALUES ('San José Centro', @SanJoseStateId);
    IF NOT EXISTS (SELECT 1 FROM PV_Cities WHERE name = 'Escazú' AND stateid = @SanJoseStateId)
        INSERT INTO PV_Cities (name, stateid) VALUES ('Escazú', @SanJoseStateId);
    IF NOT EXISTS (SELECT 1 FROM PV_Cities WHERE name = 'Santa Ana' AND stateid = @SanJoseStateId)
        INSERT INTO PV_Cities (name, stateid) VALUES ('Santa Ana', @SanJoseStateId);
    IF NOT EXISTS (SELECT 1 FROM PV_Cities WHERE name = 'Curridabat' AND stateid = @SanJoseStateId)
        INSERT INTO PV_Cities (name, stateid) VALUES ('Curridabat', @SanJoseStateId);
END

IF @AlajuelaStateId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PV_Cities WHERE name = 'Alajuela Centro' AND stateid = @AlajuelaStateId)
        INSERT INTO PV_Cities (name, stateid) VALUES ('Alajuela Centro', @AlajuelaStateId);
    IF NOT EXISTS (SELECT 1 FROM PV_Cities WHERE name = 'San Ramón' AND stateid = @AlajuelaStateId)
        INSERT INTO PV_Cities (name, stateid) VALUES ('San Ramón', @AlajuelaStateId);
END

IF @CartagoStateId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PV_Cities WHERE name = 'Cartago Centro' AND stateid = @CartagoStateId)
        INSERT INTO PV_Cities (name, stateid) VALUES ('Cartago Centro', @CartagoStateId);
END

IF @HerediaStateId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PV_Cities WHERE name = 'Heredia Centro' AND stateid = @HerediaStateId)
        INSERT INTO PV_Cities (name, stateid) VALUES ('Heredia Centro', @HerediaStateId);
    IF NOT EXISTS (SELECT 1 FROM PV_Cities WHERE name = 'Santo Domingo' AND stateid = @HerediaStateId)
        INSERT INTO PV_Cities (name, stateid) VALUES ('Santo Domingo', @HerediaStateId);
END

IF @GuanacasteStateId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PV_Cities WHERE name = 'Liberia' AND stateid = @GuanacasteStateId)
        INSERT INTO PV_Cities (name, stateid) VALUES ('Liberia', @GuanacasteStateId);
END

-- Estados Unidos cities
DECLARE @CaliforniaStateId INT = (SELECT stateid FROM PV_States WHERE name = 'California' AND countryid = @EstadosUnidosCountryId);
IF @CaliforniaStateId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PV_Cities WHERE name = 'Los Angeles' AND stateid = @CaliforniaStateId)
        INSERT INTO PV_Cities (name, stateid) VALUES ('Los Angeles', @CaliforniaStateId);
END

-- Géneros
INSERT INTO PV_Genders (name) VALUES ('Masculino');
INSERT INTO PV_Genders (name) VALUES ('Femenino');
INSERT INTO PV_Genders (name) VALUES ('No binario');
INSERT INTO PV_Genders (name) VALUES ('Prefiero no decir');

-- Roles del sistema
IF NOT EXISTS (SELECT 1 FROM PV_Roles WHERE name = 'Super Administrador')
    INSERT INTO PV_Roles (name) VALUES ('Super Administrador');
IF NOT EXISTS (SELECT 1 FROM PV_Roles WHERE name = 'Validador Senior')
    INSERT INTO PV_Roles (name) VALUES ('Validador Senior');
IF NOT EXISTS (SELECT 1 FROM PV_Roles WHERE name = 'Validador')
    INSERT INTO PV_Roles (name) VALUES ('Validador');
IF NOT EXISTS (SELECT 1 FROM PV_Roles WHERE name = 'Organizador')
    INSERT INTO PV_Roles (name) VALUES ('Organizador');
IF NOT EXISTS (SELECT 1 FROM PV_Roles WHERE name = 'Analista')
    INSERT INTO PV_Roles (name) VALUES ('Analista');
IF NOT EXISTS (SELECT 1 FROM PV_Roles WHERE name = 'Ciudadano Activo')
    INSERT INTO PV_Roles (name) VALUES ('Ciudadano Activo');
IF NOT EXISTS (SELECT 1 FROM PV_Roles WHERE name = 'Inversionista')
    INSERT INTO PV_Roles (name) VALUES ('Inversionista');
IF NOT EXISTS (SELECT 1 FROM PV_Roles WHERE name = 'Auditor')
    INSERT INTO PV_Roles (name) VALUES ('Auditor');

-- Módulos del sistema adicionales
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Gestión de Usuarios')
    INSERT INTO PV_Modules (name) VALUES ('Gestión de Usuarios');
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Gestión de Propuestas')
    INSERT INTO PV_Modules (name) VALUES ('Gestión de Propuestas');
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Sistema de Votaciones')
    INSERT INTO PV_Modules (name) VALUES ('Sistema de Votaciones');
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Gestión de Organizaciones')
    INSERT INTO PV_Modules (name) VALUES ('Gestión de Organizaciones');
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Sistema Financiero')
    INSERT INTO PV_Modules (name) VALUES ('Sistema Financiero');
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Reportes y Analytics')
    INSERT INTO PV_Modules (name) VALUES ('Reportes y Analytics');
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Seguridad y Auditoría')
    INSERT INTO PV_Modules (name) VALUES ('Seguridad y Auditoría');
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Administración del Sistema')
    INSERT INTO PV_Modules (name) VALUES ('Administración del Sistema');
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Inteligencia Artificial')
    INSERT INTO PV_Modules (name) VALUES ('Inteligencia Artificial');
IF NOT EXISTS (SELECT 1 FROM PV_Modules WHERE name = 'Gestión de Inversiones')
    INSERT INTO PV_Modules (name) VALUES ('Gestión de Inversiones');

-- Permisos detallados usando IDs dinámicos
-- Obtener IDs de módulos después de todas las inserciones
DECLARE @ModGestionUsuarios INT = (SELECT moduleid FROM PV_Modules WHERE name = 'Gestión de Usuarios');
DECLARE @ModGestionPropuestas INT = (SELECT moduleid FROM PV_Modules WHERE name = 'Gestión de Propuestas');
DECLARE @ModSistemaVotaciones INT = (SELECT moduleid FROM PV_Modules WHERE name = 'Sistema de Votaciones');
DECLARE @ModSistemaFinanciero INT = (SELECT moduleid FROM PV_Modules WHERE name = 'Sistema Financiero');
DECLARE @ModReportesAnalytics INT = (SELECT moduleid FROM PV_Modules WHERE name = 'Reportes y Analytics');
DECLARE @ModSeguridadAuditoria INT = (SELECT moduleid FROM PV_Modules WHERE name = 'Seguridad y Auditoría');
DECLARE @ModInteligenciaArtificial INT = (SELECT moduleid FROM PV_Modules WHERE name = 'Inteligencia Artificial');

-- Permisos de Gestión de Usuarios
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'USR_VIEW')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver usuarios', 'USR_VIEW', @ModGestionUsuarios);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'USR_CREATE')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Crear usuarios', 'USR_CREATE', @ModGestionUsuarios);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'USR_EDIT')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Editar usuarios', 'USR_EDIT', @ModGestionUsuarios);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'USR_DELETE')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Eliminar usuarios', 'USR_DELETE', @ModGestionUsuarios);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'USR_ROLES')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Gestionar roles', 'USR_ROLES', @ModGestionUsuarios);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'USR_PROF')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver perfil completo', 'USR_PROF', @ModGestionUsuarios);

-- Permisos de Gestión de Propuestas
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'PROP_PUB')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver propuestas públicas', 'PROP_PUB', @ModGestionPropuestas);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'PROP_ALL')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver todas las propuestas', 'PROP_ALL', @ModGestionPropuestas);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'PROP_CRT')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Crear propuestas', 'PROP_CRT', @ModGestionPropuestas);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'PROP_EDIT')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Editar propuestas', 'PROP_EDIT', @ModGestionPropuestas);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'PROP_DEL')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Eliminar propuestas', 'PROP_DEL', @ModGestionPropuestas);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'PROP_APP')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Aprobar propuestas', 'PROP_APP', @ModGestionPropuestas);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'PROP_REJ')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Rechazar propuestas', 'PROP_REJ', @ModGestionPropuestas);

-- Permisos de Sistema de Votaciones
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'VOTE_PUB')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver votaciones públicas', 'VOTE_PUB', @ModSistemaVotaciones);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'VOTE_ALL')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver todas las votaciones', 'VOTE_ALL', @ModSistemaVotaciones);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'VOTE_PART')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Participar en votaciones', 'VOTE_PART', @ModSistemaVotaciones);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'VOTE_CFG')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Configurar votaciones', 'VOTE_CFG', @ModSistemaVotaciones);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'VOTE_ADM')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Administrar votaciones', 'VOTE_ADM', @ModSistemaVotaciones);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'VOTE_RES')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver resultados', 'VOTE_RES', @ModSistemaVotaciones);

-- Permisos de Sistema Financiero
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'INV_VIEW')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver inversiones públicas', 'INV_VIEW', @ModSistemaFinanciero);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'INV_CRT')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Realizar inversiones', 'INV_CRT', @ModSistemaFinanciero);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'INV_MGT')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Gestionar inversiones', 'INV_MGT', @ModSistemaFinanciero);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'DIV_PROC')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Procesar dividendos', 'DIV_PROC', @ModSistemaFinanciero);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'FIN_REP')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver reportes financieros', 'FIN_REP', @ModSistemaFinanciero);

-- Permisos de Inteligencia Artificial
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'AI_VIEW')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver análisis AI', 'AI_VIEW', @ModInteligenciaArtificial);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'AI_CFG')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Configurar AI', 'AI_CFG', @ModInteligenciaArtificial);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'AI_DOC')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Procesar documentos', 'AI_DOC', @ModInteligenciaArtificial);

-- Permisos de Seguridad y Auditoría
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'LOG_VIEW')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Ver logs del sistema', 'LOG_VIEW', @ModSeguridadAuditoria);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'AUD_EXP')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Exportar auditoría', 'AUD_EXP', @ModSeguridadAuditoria);
IF NOT EXISTS (SELECT 1 FROM PV_Permissions WHERE code = 'SEC_ADM')
    INSERT INTO PV_Permissions (description, code, moduleid) VALUES ('Administrar seguridad', 'SEC_ADM', @ModSeguridadAuditoria);

-- Tipos de organización
INSERT INTO PV_OrganizationTypes (name) VALUES ('Gobierno Central');
INSERT INTO PV_OrganizationTypes (name) VALUES ('Gobierno Local');
INSERT INTO PV_OrganizationTypes (name) VALUES ('Universidad Pública');
INSERT INTO PV_OrganizationTypes (name) VALUES ('Universidad Privada');
INSERT INTO PV_OrganizationTypes (name) VALUES ('ONG');
INSERT INTO PV_OrganizationTypes (name) VALUES ('Empresa Privada');
INSERT INTO PV_OrganizationTypes (name) VALUES ('Cámara Empresarial');
INSERT INTO PV_OrganizationTypes (name) VALUES ('Asociación Civil');
INSERT INTO PV_OrganizationTypes (name) VALUES ('Cooperativa');
INSERT INTO PV_OrganizationTypes (name) VALUES ('Organismo Internacional');

-- Direcciones para organizaciones usando IDs dinámicos de ciudades
DECLARE @SanJoseCentroCityId INT = (SELECT cityid FROM PV_Cities WHERE name = 'San José Centro');
DECLARE @EscazuCityId INT = (SELECT cityid FROM PV_Cities WHERE name = 'Escazú');
DECLARE @LiberiaCityId INT = (SELECT cityid FROM PV_Cities WHERE name = 'Liberia');

IF @SanJoseCentroCityId IS NOT NULL
BEGIN
    INSERT INTO PV_Addresses (line1, line2, zipcode, geoposition, cityid) VALUES ('Avenida Central, Edificio Gobierno #100', 'Piso 5', '10101', geometry::Point(9.9281, -84.0907, 4326), @SanJoseCentroCityId);
    INSERT INTO PV_Addresses (line1, line2, zipcode, geoposition, cityid) VALUES ('Boulevard Los Yoses, Torre Tecnológica', 'Oficina 301', '11801', geometry::Point(9.9193, -84.0745, 4326), @SanJoseCentroCityId);
    INSERT INTO PV_Addresses (line1, line2, zipcode, geoposition, cityid) VALUES ('Ciudad Universitaria Rodrigo Facio', 'Rectoría', '11501', geometry::Point(9.9370, -84.0525, 4326), @SanJoseCentroCityId);
    INSERT INTO PV_Addresses (line1, line2, zipcode, geoposition, cityid) VALUES ('Centro de San José', 'Edificio Cooperativo', '10102', geometry::Point(9.9326, -84.0787, 4326), @SanJoseCentroCityId);
    INSERT INTO PV_Addresses (line1, line2, zipcode, geoposition, cityid) VALUES ('Barrio Escalante', 'Casa Verde', '10103', geometry::Point(9.9254, -84.0765, 4326), @SanJoseCentroCityId);
END

IF @EscazuCityId IS NOT NULL
BEGIN
    INSERT INTO PV_Addresses (line1, line2, zipcode, geoposition, cityid) VALUES ('Escazú Corporate Center', 'Torre A, Piso 12', '10201', geometry::Point(9.9178, -84.1378, 4326), @EscazuCityId);
END

IF @LiberiaCityId IS NOT NULL
BEGIN
    INSERT INTO PV_Addresses (line1, line2, zipcode, geoposition, cityid) VALUES ('Parque Empresarial Forum', 'Edificio 3', '40301', geometry::Point(10.0932, -84.2105, 4326), @LiberiaCityId);
END



-- Métodos MFA
INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('TOTP', 'Autenticación por aplicación de código temporal', 1);
INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('SMS', 'Código de verificación enviado por mensaje de texto', 1);
INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('Email', 'Código de verificación enviado por correo electrónico', 1);
INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('Hardware Token', 'Token físico de seguridad (YubiKey, etc.)', 1);
INSERT INTO PV_MFAMethods (name, description, requiressecret) VALUES ('Biométrico', 'Autenticación por huella dactilar o facial', 0);

-- Estados de usuario (distintas combinaciones)
INSERT INTO PV_UserStatus(active, verified) VALUES (1, 1); -- Activo y verificado
INSERT INTO PV_UserStatus(active, verified) VALUES (1, 0); -- Activo pero no verificado
INSERT INTO PV_UserStatus(active, verified) VALUES (0, 1); -- Inactivo pero verificado
INSERT INTO PV_UserStatus(active, verified) VALUES (0, 0); -- Inactivo y no verificado

-- Usuarios del sistema con identities realistas
-- Obtener IDs de géneros y estados de usuario dinámicamente
DECLARE @GenderMasculino INT = (SELECT genderId FROM PV_Genders WHERE name = 'Masculino');
DECLARE @GenderFemenino INT = (SELECT genderId FROM PV_Genders WHERE name = 'Femenino');
DECLARE @UserStatusActiveVerified INT = (SELECT userStatusId FROM PV_UserStatus WHERE active = 1 AND verified = 1);
DECLARE @UserStatusActiveNotVerified INT = (SELECT userStatusId FROM PV_UserStatus WHERE active = 1 AND verified = 0);
DECLARE @UserStatusInactiveVerified INT = (SELECT userStatusId FROM PV_UserStatus WHERE active = 0 AND verified = 1);
DECLARE @UserStatusInactiveNotVerified INT = (SELECT userStatusId FROM PV_UserStatus WHERE active = 0 AND verified = 0);

SET IDENTITY_INSERT PV_Users ON;
-- SUPER ADMINISTRADORES (userid 1000-1099)
INSERT INTO PV_Users (userid, email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) VALUES (1001, 'superadmin@votopuravida.cr', 'María Isabel', 'Rodríguez Sánchez', '1980-03-15', GETDATE(), @GenderFemenino, GETDATE(), 101234567, @UserStatusActiveVerified);
INSERT INTO PV_Users (userid, email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) VALUES (1002, 'tech.lead@votopuravida.cr', 'Carlos Eduardo', 'Méndez Vargas', '1982-07-22', GETDATE(), @GenderMasculino, GETDATE(), 102345678, @UserStatusActiveVerified);

-- ADMINISTRADORES (userid 1100-1199)
INSERT INTO PV_Users (userid, email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) VALUES (1101, 'admin.sistemas@micitt.go.cr', 'Ana Lucía', 'González Herrera', '1985-11-10', GETDATE(), @GenderFemenino, GETDATE(), 111234567, @UserStatusActiveVerified);
INSERT INTO PV_Users (userid, email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) VALUES (1102, 'admin.general@votopuravida.cr', 'José Miguel', 'Vargas Solís', '1983-05-18', GETDATE(), @GenderMasculino, GETDATE(), 112345678, @UserStatusActiveVerified);

SET IDENTITY_INSERT PV_Users OFF;

-- Organizaciones principales (deben crearse después de los usuarios)
INSERT INTO PV_Organizations (name, description, userid, createdAt, legalIdentification, OrganizationTypeId, MinJointVentures) VALUES ('MICITT', 'MICITT - Entidad rectora en ciencia y tecnología', 1001, GETDATE(), '3-101-123456', 1, 1);
INSERT INTO PV_Organizations (name, description, userid, createdAt, legalIdentification, OrganizationTypeId, MinJointVentures) VALUES ('Universidad de Costa Rica', 'UCR - Principal universidad pública del país', 1002, GETDATE(), '4-000-042156', 3, 2);
INSERT INTO PV_Organizations (name, description, userid, createdAt, legalIdentification, OrganizationTypeId, MinJointVentures) VALUES ('CAMTIC', 'CAMTIC - Organización empresarial del sector TI', 1101, GETDATE(), '3-102-654321', 7, 3);
INSERT INTO PV_Organizations (name, description, userid, createdAt, legalIdentification, OrganizationTypeId, MinJointVentures) VALUES ('Cooperativa Servicios Múltiples', 'COOPEMULTIPLE - Servicios cooperativos integrales', 1102, GETDATE(), '3-004-987654', 9, 5);
INSERT INTO PV_Organizations (name, description, userid, createdAt, legalIdentification, OrganizationTypeId, MinJointVentures) VALUES ('FUNDATEC', 'FUNDATEC - Investigación y desarrollo tecnológico', 1001, GETDATE(), '3-006-456789', 8, 2);
INSERT INTO PV_Organizations (name, description, userid, createdAt, legalIdentification, OrganizationTypeId, MinJointVentures) VALUES ('Municipalidad de San José', 'Gobierno local de la capital', 1002, GETDATE(), '3-014-554768', 2, 1);
INSERT INTO PV_Organizations (name, description, userid, createdAt, legalIdentification, OrganizationTypeId, MinJointVentures) VALUES ('ONG Desarrollo Sostenible CR', 'Organización para el desarrollo sostenible', 1101, GETDATE(), '3-002-135792', 5, 4);


-- Get role IDs for user role assignments
DECLARE @RoleCiudadano int = (SELECT roleid FROM PV_Roles WHERE name = 'Ciudadano');
DECLARE @RoleAdministrador int = (SELECT roleid FROM PV_Roles WHERE name = 'Administrador');
DECLARE @RoleSuperAdmin int = (SELECT roleid FROM PV_Roles WHERE name = 'Super Administrador');
DECLARE @RoleValidador int = (SELECT roleid FROM PV_Roles WHERE name = 'Validador');

-- Asignación de roles a usuarios
-- Super Administradores
INSERT INTO PV_UserRoles (userid, roleid, lastupdate, enabled, deleted) VALUES (1001, @RoleSuperAdmin, GETDATE(), 1, 0);
INSERT INTO PV_UserRoles (userid, roleid, lastupdate, enabled, deleted) VALUES (1002, @RoleSuperAdmin, GETDATE(), 1, 0);

-- Administradores
INSERT INTO PV_UserRoles (userid, roleid, lastupdate, enabled, deleted) VALUES (1101, @RoleAdministrador, GETDATE(), 1, 0);
INSERT INTO PV_UserRoles (userid, roleid, lastupdate, enabled, deleted) VALUES (1102, @RoleAdministrador, GETDATE(), 1, 0);

-- Configuración MFA para usuarios críticos
-- Get MFA method IDs dynamically
DECLARE @MfaTotp INT = (SELECT MFAmethodid FROM PV_MFAMethods WHERE name = 'TOTP');
DECLARE @MfaSms INT = (SELECT MFAmethodid FROM PV_MFAMethods WHERE name = 'SMS');
DECLARE @MfaEmail INT = (SELECT MFAmethodid FROM PV_MFAMethods WHERE name = 'Email');

-- Super Administradores con TOTP (using dynamic organization IDs)
DECLARE @Org1 INT = (SELECT TOP 1 organizationid FROM PV_Organizations ORDER BY organizationid);
DECLARE @Org2 INT = (SELECT organizationid FROM PV_Organizations WHERE organizationid = (SELECT MIN(organizationid) + 1 FROM PV_Organizations));

INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid) VALUES (@MfaTotp, CAST('JBSWY3DPEHPK3PXP' AS varbinary(256)), GETDATE(), 1, @Org1, 1001);
INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid) VALUES (@MfaTotp, CAST('JBSWY3DPEHPK3PXQ' AS varbinary(256)), GETDATE(), 1, @Org1, 1002);

-- Administradores con TOTP  
INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid) VALUES (@MfaTotp, CAST('JBSWY3DPEHPK3PXR' AS varbinary(256)), GETDATE(), 1, @Org1, 1101);
INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid) VALUES (@MfaTotp, CAST('JBSWY3DPEHPK3PXS' AS varbinary(256)), GETDATE(), 1, NULL, 1102);

-- Proveedores de IA
INSERT INTO PV_AIProviders (name, baseurl, description, isactive, ratelimitrpm, ratelimittpm, supportedmodels, createdate) VALUES ('OpenAI', 'https://api.openai.com/v1', 'Proveedor líder en modelos GPT para análisis de texto y documentos', 1, 3500, 90000, 'gpt-4,gpt-4-turbo,gpt-3.5-turbo,text-embedding-ada-002', GETDATE());
INSERT INTO PV_AIProviders (name, baseurl, description, isactive, ratelimitrpm, ratelimittpm, supportedmodels, createdate) VALUES ('Anthropic', 'https://api.anthropic.com', 'Proveedor de modelos Claude especializados en análisis ético', 1, 2000, 50000, 'claude-3-opus,claude-3-sonnet,claude-3-haiku', GETDATE());
INSERT INTO PV_AIProviders (name, baseurl, description, isactive, ratelimitrpm, ratelimittpm, supportedmodels, createdate) VALUES ('Google AI', 'https://aiplatform.googleapis.com', 'Servicios de IA de Google Cloud Platform', 1, 1000, 100000, 'gemini-pro,text-bison,chat-bison', GETDATE());
INSERT INTO PV_AIProviders (name, baseurl, description, isactive, ratelimitrpm, ratelimittpm, supportedmodels, createdate) VALUES ('Azure OpenAI', 'https://azure-openai.openai.azure.com', 'OpenAI a través de Microsoft Azure', 1, 4000, 120000, 'gpt-4,gpt-35-turbo,text-embedding-ada-002', GETDATE());
INSERT INTO PV_AIProviders (name, baseurl, description, isactive, ratelimitrpm, ratelimittpm, supportedmodels, createdate) VALUES ('Cohere', 'https://api.cohere.ai', 'Modelos especializados en comprensión de texto', 1, 1500, 75000, 'command,embed-multilingual', GETDATE());

-- Tipos de modelos de IA
INSERT INTO PV_AIModelTypes (name) VALUES ('Análisis de Texto');
INSERT INTO PV_AIModelTypes (name) VALUES ('Generación de Contenido');
INSERT INTO PV_AIModelTypes (name) VALUES ('Clasificación de Documentos');
INSERT INTO PV_AIModelTypes (name) VALUES ('Embeddings y Similitud');
INSERT INTO PV_AIModelTypes (name) VALUES ('Análisis de Sentimientos');
INSERT INTO PV_AIModelTypes (name) VALUES ('Detección de Fraude');
INSERT INTO PV_AIModelTypes (name) VALUES ('Visión Computacional');

-- Modelos específicos configurados usando IDs dinámicos
-- Obtener IDs de tipos de modelos de IA
DECLARE @ModelTypeAnalisisTexto INT = (SELECT AIModelId FROM PV_AIModelTypes WHERE name = 'Análisis de Texto');
DECLARE @ModelTypeEmbeddings INT = (SELECT AIModelId FROM PV_AIModelTypes WHERE name = 'Embeddings y Similitud');

-- Obtener IDs de proveedores de IA dinámicamente 
DECLARE @ProviderOpenAI INT = (SELECT providerid FROM PV_AIProviders WHERE name = 'OpenAI');
DECLARE @ProviderAnthropic INT = (SELECT providerid FROM PV_AIProviders WHERE name = 'Anthropic');
DECLARE @ProviderGoogleAI INT = (SELECT providerid FROM PV_AIProviders WHERE name = 'Google AI');
DECLARE @ProviderAzureOpenAI INT = (SELECT providerid FROM PV_AIProviders WHERE name = 'Azure OpenAI');

-- OpenAI Models
INSERT INTO PV_AIModels (providerid, modelname, displayname, modeltypeId, maxinputtokens, maxoutputtokens, costperinputtoken, costperoutputtoken, isactive, capabilities, createdate) VALUES (@ProviderOpenAI, 'gpt-4-turbo', 'GPT-4 Turbo', @ModelTypeAnalisisTexto, 128000, 4096, 0.00001000, 0.00003000, 1, 'Análisis profundo de propuestas, revisión de documentos complejos', GETDATE());
INSERT INTO PV_AIModels (providerid, modelname, displayname, modeltypeId, maxinputtokens, maxoutputtokens, costperinputtoken, costperoutputtoken, isactive, capabilities, createdate) VALUES (@ProviderOpenAI, 'gpt-3.5-turbo', 'GPT-3.5 Turbo', @ModelTypeAnalisisTexto, 16385, 4096, 0.00000050, 0.00000150, 1, 'Análisis rápido de texto, clasificación básica', GETDATE());
INSERT INTO PV_AIModels (providerid, modelname, displayname, modeltypeId, maxinputtokens, maxoutputtokens, costperinputtoken, costperoutputtoken, isactive, capabilities, createdate) VALUES (@ProviderOpenAI, 'text-embedding-ada-002', 'Ada Embeddings', @ModelTypeEmbeddings, 8191, 1536, 0.00000010, 0.00000000, 1, 'Similitud de documentos, búsqueda semántica', GETDATE());

-- Anthropic Models
INSERT INTO PV_AIModels (providerid, modelname, displayname, modeltypeId, maxinputtokens, maxoutputtokens, costperinputtoken, costperoutputtoken, isactive, capabilities, createdate) VALUES (@ProviderAnthropic, 'claude-3-opus', 'Claude 3 Opus', @ModelTypeAnalisisTexto, 200000, 4096, 0.00001500, 0.00007500, 1, 'Análisis ético de propuestas, revisión legal', GETDATE());
INSERT INTO PV_AIModels (providerid, modelname, displayname, modeltypeId, maxinputtokens, maxoutputtokens, costperinputtoken, costperoutputtoken, isactive, capabilities, createdate) VALUES (@ProviderAnthropic, 'claude-3-sonnet', 'Claude 3 Sonnet', @ModelTypeAnalisisTexto, 200000, 4096, 0.00000300, 0.00001500, 1, 'Análisis balanceado de contenido', GETDATE());

-- Google AI Models
INSERT INTO PV_AIModels (providerid, modelname, displayname, modeltypeId, maxinputtokens, maxoutputtokens, costperinputtoken, costperoutputtoken, isactive, capabilities, createdate) VALUES (@ProviderGoogleAI, 'gemini-pro', 'Gemini Pro', @ModelTypeAnalisisTexto, 30720, 2048, 0.00000050, 0.00000150, 1, 'Análisis multimodal, procesamiento de imágenes', GETDATE());

-- Azure OpenAI Models
INSERT INTO PV_AIModels (providerid, modelname, displayname, modeltypeId, maxinputtokens, maxoutputtokens, costperinputtoken, costperoutputtoken, isactive, capabilities, createdate) VALUES (@ProviderAzureOpenAI, 'gpt-4-azure', 'GPT-4 Azure', @ModelTypeAnalisisTexto, 8192, 4096, 0.00003000, 0.00006000, 1, 'Análisis empresarial seguro', GETDATE());

-- Obtener IDs de modelos AI dinámicamente para las conexiones
DECLARE @ModelGPT4Turbo INT = (SELECT modelid FROM PV_AIModels WHERE modelname = 'gpt-4-turbo' AND providerid = @ProviderOpenAI);
DECLARE @ModelGPT35Turbo INT = (SELECT modelid FROM PV_AIModels WHERE modelname = 'gpt-3.5-turbo' AND providerid = @ProviderOpenAI);
DECLARE @ModelClaude3Opus INT = (SELECT modelid FROM PV_AIModels WHERE modelname = 'claude-3-opus' AND providerid = @ProviderAnthropic);
DECLARE @ModelGPT4Azure INT = (SELECT modelid FROM PV_AIModels WHERE modelname = 'gpt-4-azure' AND providerid = @ProviderAzureOpenAI);

-- Conexiones configuradas
INSERT INTO PV_AIConnections (providerid, connectionname, publicKey, privateKey, organizationid, projectid, region, environment, isactive, createdby, createdate, lastused, usagecount, modelId) VALUES (@ProviderOpenAI, 'OpenAI-Production', 0x0123456789ABCDEF0123456789ABCDEF, 0x0123456789ABCDEF, @Org1, 'voto-pura-vida-prod', 'us-east-1', 'production', 1, 1001, GETDATE(), GETDATE(), 125, @ModelGPT4Turbo);
INSERT INTO PV_AIConnections (providerid, connectionname, publicKey, privateKey, organizationid, projectid, region, environment, isactive, createdby, createdate, lastused, usagecount, modelId) VALUES (@ProviderOpenAI, 'OpenAI-Development', 0x123456789ABCDEF0123456789ABCDEF0, 0x123456789ABCDEF0, @Org1, 'voto-pura-vida-dev', 'us-east-1', 'development', 1, 1002, GETDATE(), DATEADD(hour, -2, GETDATE()), 45, @ModelGPT35Turbo);
INSERT INTO PV_AIConnections (providerid, connectionname, publicKey, privateKey, organizationid, projectid, region, environment, isactive, createdby, createdate, lastused, usagecount, modelId) VALUES (@ProviderAnthropic, 'Anthropic-Ethics', 0x23456789ABCDEF0123456789ABCDEF01, 0x23456789ABCDEF01, @Org1, 'ethics-analysis', 'us-west-2', 'production', 1, 1001, GETDATE(), DATEADD(day, -1, GETDATE()), 78, @ModelClaude3Opus);
INSERT INTO PV_AIConnections (providerid, connectionname, publicKey, privateKey, organizationid, projectid, region, environment, isactive, createdby, createdate, lastused, usagecount, modelId) VALUES (@ProviderAzureOpenAI, 'Azure-Enterprise', 0x3456789ABCDEF0123456789ABCDEF012, 0x3456789ABCDEF012, @Org1, 'enterprise-ai', 'eastus', 'production', 1, 1101, GETDATE(), GETDATE(), 203, @ModelGPT4Azure);

-- Tipos de análisis disponibles
INSERT INTO PV_AIAnalysisType (name) VALUES ('Análisis de Viabilidad');
INSERT INTO PV_AIAnalysisType (name) VALUES ('Detección de Riesgos');
INSERT INTO PV_AIAnalysisType (name) VALUES ('Evaluación de Impacto Social');
INSERT INTO PV_AIAnalysisType (name) VALUES ('Análisis Presupuestario');
INSERT INTO PV_AIAnalysisType (name) VALUES ('Revisión de Cumplimiento');
INSERT INTO PV_AIAnalysisType (name) VALUES ('Análisis de Sentimientos Ciudadanos');
INSERT INTO PV_AIAnalysisType (name) VALUES ('Detección de Conflictos de Interés');
INSERT INTO PV_AIAnalysisType (name) VALUES ('Evaluación de Sostenibilidad');
INSERT INTO PV_AIAnalysisType (name) VALUES ('Análisis de Factibilidad Técnica');
INSERT INTO PV_AIAnalysisType (name) VALUES ('Revisión de Documentación');

-- Tipos de pregunta de votación
INSERT INTO PV_questionType ([type]) VALUES ('Sí/No');
INSERT INTO PV_questionType ([type]) VALUES ('Múltiple Opción');
INSERT INTO PV_questionType ([type]) VALUES ('Escala de Likert');
INSERT INTO PV_questionType ([type]) VALUES ('Ranking');
INSERT INTO PV_questionType ([type]) VALUES ('Abierta');
INSERT INTO PV_questionType ([type]) VALUES ('Presupuesto Participativo');

-- Estados de votación
INSERT INTO PV_VotingStatus (name, description) VALUES ('Configurada', 'Votación creada y configurada');
INSERT INTO PV_VotingStatus (name, description) VALUES ('Publicada', 'Votación publicada y visible');
INSERT INTO PV_VotingStatus (name, description) VALUES ('En Curso', 'Votación activa, recibiendo votos');
INSERT INTO PV_VotingStatus (name, description) VALUES ('Pausada', 'Votación temporalmente pausada');
INSERT INTO PV_VotingStatus (name, description) VALUES ('Finalizada', 'Votación cerrada, conteo completado');
INSERT INTO PV_VotingStatus (name, description) VALUES ('Cancelada', 'Votación cancelada antes de finalizar');
INSERT INTO PV_VotingStatus (name, description) VALUES ('En Revisión', 'Resultados en proceso de verificación');

-- Tipos de votación
INSERT INTO PV_VotingTypes (name) VALUES ('Votación Simple');
INSERT INTO PV_VotingTypes (name) VALUES ('Votación Ponderada');
INSERT INTO PV_VotingTypes (name) VALUES ('Votación por Rangos');
INSERT INTO PV_VotingTypes (name) VALUES ('Consulta Ciudadana');
INSERT INTO PV_VotingTypes (name) VALUES ('Presupuesto Participativo');
INSERT INTO PV_VotingTypes (name) VALUES ('Referéndum');

-- Métodos de notificación
INSERT INTO PV_NotificationMethods (name, description) VALUES ('Email', 'Notificación por correo electrónico');
INSERT INTO PV_NotificationMethods (name, description) VALUES ('SMS', 'Notificación por mensaje de texto');
INSERT INTO PV_NotificationMethods (name, description) VALUES ('Push App', 'Notificación push en aplicación móvil');
INSERT INTO PV_NotificationMethods (name, description) VALUES ('WhatsApp', 'Notificación por WhatsApp Business');
INSERT INTO PV_NotificationMethods (name, description) VALUES ('Telegram', 'Notificación por bot de Telegram');

-- Tipos de propuesta
INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) VALUES ('Infraestructura Tecnológica', 'Proyectos de desarrollo e implementación tecnológica', 1, 1, 3);
INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) VALUES ('Desarrollo Social', 'Programas y proyectos de impacto social comunitario', 1, 1, 2);
INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) VALUES ('Sostenibilidad Ambiental', 'Iniciativas de protección y mejora ambiental', 1, 1, 3);
INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) VALUES ('Educación y Capacitación', 'Programas educativos y de desarrollo de capacidades', 0, 1, 2);
INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) VALUES ('Salud Pública', 'Proyectos de mejora en servicios de salud', 1, 1, 3);
INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) VALUES ('Transporte e Infraestructura', 'Proyectos de movilidad y obras públicas', 1, 1, 4);
INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) VALUES ('Innovación Empresarial', 'Apoyo a emprendimiento e innovación', 0, 1, 2);
INSERT INTO PV_ProposalTypes (name, description, requiresgovernmentapproval, requiresvalidatorapproval, validatorcount) VALUES ('Cultura y Recreación', 'Proyectos culturales, deportivos y recreativos', 0, 1, 2);

-- Estados de propuesta
INSERT INTO PV_ProposalStatus (name, description) VALUES ('Borrador', 'Propuesta en preparación, no visible públicamente');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('En Revisión Técnica', 'Propuesta en evaluación técnica inicial');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('En Validación', 'Propuesta siendo validada por expertos');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('En Revisión Ciudadana', 'Propuesta abierta a comentarios ciudadanos');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('Aprobada para Votación', 'Propuesta lista para proceso de votación');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('En Votación', 'Propuesta en proceso de votación activa');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('Aprobada', 'Propuesta aprobada por votación ciudadana');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('Rechazada', 'Propuesta rechazada en votación');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('En Implementación', 'Propuesta aprobada en proceso de ejecución');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('Implementada', 'Propuesta ejecutada exitosamente');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('Cancelada', 'Propuesta cancelada antes de implementación');
INSERT INTO PV_ProposalStatus (name, description) VALUES ('Suspendida', 'Propuesta temporalmente suspendida');

-- Métodos de pago disponibles
INSERT INTO PV_PaymentMethods (name, APIURL, secretkey, [key], logoiconurl, enabled) VALUES ('SINPE Móvil', 'https://api.sinpe.fi.cr/v1', 0x53494E50454D4F56494C534543524554, 0x53494E50454D4F56494C4B4559, 'https://assets.votopuravida.cr/payment-icons/sinpe.png', 1);

INSERT INTO PV_PaymentMethods (name, APIURL, secretkey, [key], logoiconurl, enabled) VALUES ('Tarjetas BAC', 'https://api.baccredomatic.com/v2', 0x4241434352454449544553454352, 0x4241434352454449544B4559, 'https://assets.votopuravida.cr/payment-icons/bac.png', 1);

INSERT INTO PV_PaymentMethods (name, APIURL, secretkey, [key], logoiconurl, enabled) VALUES ('PayPal Costa Rica', 'https://api.paypal.com/v1', 0x50415950414C434F535441524943, 0x50415950414C4B4559434F535441, 'https://assets.votopuravida.cr/payment-icons/paypal.png', 1);

INSERT INTO PV_PaymentMethods (name, APIURL, secretkey, [key], logoiconurl, enabled) VALUES ('Stripe CR', 'https://api.stripe.com/v1', 0x535452495045434F535441524943, 0x53545249504B4559434F535441, 'https://assets.votopuravida.cr/payment-icons/stripe.png', 1);

INSERT INTO PV_PaymentMethods (name, APIURL, secretkey, [key], logoiconurl, enabled) VALUES ('Banco Nacional Online', 'https://api.bncr.fi.cr/v1', 0x424E4352434F535441524943415049, 0x424E43524B4559434F535441, 'https://assets.votopuravida.cr/payment-icons/bn.png', 1);

INSERT INTO PV_PaymentMethods (name, APIURL, secretkey, [key], logoiconurl, enabled) VALUES ('Coopenae Digital', 'https://api.coopenae.com/v1', 0x434F4F50454E414544494749544C, 0x434F4F50454E41454B4559, 'https://assets.votopuravida.cr/payment-icons/coopenae.png', 1);

-- Tipos de segmento
INSERT INTO PV_SegmentTypes (name, description) VALUES ('Demográfico', 'Segmentación por edad, género, ubicación geográfica');
INSERT INTO PV_SegmentTypes (name, description) VALUES ('Socioeconómico', 'Segmentación por nivel de ingresos y clase social');
INSERT INTO PV_SegmentTypes (name, description) VALUES ('Profesional', 'Segmentación por ocupación, industria o sector laboral');
INSERT INTO PV_SegmentTypes (name, description) VALUES ('Educativo', 'Segmentación por nivel educativo alcanzado');
INSERT INTO PV_SegmentTypes (name, description) VALUES ('Tecnológico', 'Segmentación por nivel de adopción tecnológica');
INSERT INTO PV_SegmentTypes (name, description) VALUES ('Intereses', 'Segmentación por preferencias e intereses específicos');
INSERT INTO PV_SegmentTypes (name, description) VALUES ('Político', 'Segmentación por afiliación o preferencias políticas');
INSERT INTO PV_SegmentTypes (name, description) VALUES ('Geográfico', 'Segmentación por ubicación específica o tipo de zona');

-- Segmentos de población detallados
-- Obtener IDs de tipos de segmento dinámicamente
DECLARE @SegmentDemografico INT = (SELECT segmenttypeid FROM PV_SegmentTypes WHERE name = 'Demográfico');
DECLARE @SegmentSocioeconomico INT = (SELECT segmenttypeid FROM PV_SegmentTypes WHERE name = 'Socioeconómico');
DECLARE @SegmentProfesional INT = (SELECT segmenttypeid FROM PV_SegmentTypes WHERE name = 'Profesional');
DECLARE @SegmentIntereses INT = (SELECT segmenttypeid FROM PV_SegmentTypes WHERE name = 'Intereses');
DECLARE @SegmentGeografico INT = (SELECT segmenttypeid FROM PV_SegmentTypes WHERE name = 'Geográfico');

-- Segmentos Demográficos
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Millennials Urbanos', 'Personas nacidas entre 1981-1996 viviendo en zonas urbanas', @SegmentDemografico);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Generación Z Digital', 'Personas nacidas después de 1997 con alta adopción tecnológica', @SegmentDemografico);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Adultos Mayores Activos', 'Personas mayores de 55 años económicamente activas', @SegmentDemografico);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Familias Jóvenes', 'Parejas con hijos menores de 18 años', @SegmentDemografico);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Mujeres Profesionales', 'Mujeres con educación superior en posiciones profesionales', @SegmentDemografico);

-- Segmentos Socioeconómicos
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Clase Media Emergente', 'Hogares con ingresos entre ₡800K-1.5M mensuales', @SegmentSocioeconomico);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Profesionales de Altos Ingresos', 'Individuos con ingresos superiores a ₡2M mensuales', @SegmentSocioeconomico);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Microempresarios', 'Propietarios de micro y pequeñas empresas', @SegmentSocioeconomico);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Estudiantes Universitarios', 'Estudiantes de educación superior activos', @SegmentSocioeconomico);

-- Segmentos Profesionales
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Sector Tecnológico', 'Trabajadores en empresas de tecnología e innovación', @SegmentProfesional);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Sector Público', 'Empleados gubernamentales y funcionarios públicos', @SegmentProfesional);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Educadores', 'Docentes de instituciones educativas públicas y privadas', @SegmentProfesional);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Profesionales de Salud', 'Médicos, enfermeras y personal sanitario', @SegmentProfesional);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Sector Financiero', 'Trabajadores en bancos, seguros y servicios financieros', @SegmentProfesional);

-- Segmentos de Intereses
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Ambientalistas Activos', 'Personas comprometidas con causas ambientales', @SegmentIntereses);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Innovadores Tecnológicos', 'Early adopters de nuevas tecnologías', @SegmentIntereses);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Participación Ciudadana', 'Ciudadanos altamente comprometidos con participación cívica', @SegmentIntereses);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Emprendedores', 'Personas con mentalidad emprendedora activa', @SegmentIntereses);

-- Segmentos Geográficos
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('GAM Central', 'Residentes del Gran Área Metropolitana central', @SegmentGeografico);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Zonas Rurales', 'Residentes de comunidades rurales', @SegmentGeografico);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Zonas Costeras', 'Residentes de provincias costeras (Guanacaste, Puntarenas, Limón)', @SegmentGeografico);
INSERT INTO PV_PopulationSegments (name, description, segmenttypeid) VALUES ('Zona Norte', 'Residentes de la región norte del país', @SegmentGeografico);



-- =============================================================================
-- 20. CONFIGURACIONES FINALES DE SEGURIDAD
-- =============================================================================
-- Reglas de validación del sistema usando IDs dinámicos
DECLARE @PropTypeInfraTech INT = (SELECT proposaltypeid FROM PV_ProposalTypes WHERE name = 'Infraestructura Tecnológica');
DECLARE @PropTypeDesarrolloSocial INT = (SELECT proposaltypeid FROM PV_ProposalTypes WHERE name = 'Desarrollo Social');
DECLARE @PropTypeSostenibilidad INT = (SELECT proposaltypeid FROM PV_ProposalTypes WHERE name = 'Sostenibilidad Ambiental');
DECLARE @PropTypeEducacion INT = (SELECT proposaltypeid FROM PV_ProposalTypes WHERE name = 'Educación y Capacitación');
DECLARE @PropTypeSalud INT = (SELECT proposaltypeid FROM PV_ProposalTypes WHERE name = 'Salud Pública');
DECLARE @PropTypeTransporte INT = (SELECT proposaltypeid FROM PV_ProposalTypes WHERE name = 'Transporte e Infraestructura');
DECLARE @PropTypeInnovacion INT = (SELECT proposaltypeid FROM PV_ProposalTypes WHERE name = 'Innovación Empresarial');
DECLARE @PropTypeCultura INT = (SELECT proposaltypeid FROM PV_ProposalTypes WHERE name = 'Cultura y Recreación');

INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeInfraTech, 'budget', 'max_value', '500000000', 'El presupuesto no puede exceder ₡500,000,000');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeInfraTech, 'title', 'min_length', '10', 'El título debe tener al menos 10 caracteres');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeInfraTech, 'description', 'min_length', '50', 'La descripción debe tener al menos 50 caracteres');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeDesarrolloSocial, 'budget', 'max_value', '200000000', 'Propuestas sociales no pueden exceder ₡200,000,000');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeSostenibilidad, 'budget', 'max_value', '1000000000', 'Propuestas de infraestructura no pueden exceder ₡1,000,000,000');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeEducacion, 'budget', 'max_value', '300000000', 'Propuestas educativas no pueden exceder ₡300,000,000');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeSalud, 'budget', 'max_value', '800000000', 'Propuestas de salud no pueden exceder ₡800,000,000');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeInfraTech, 'proposalcontent', 'min_length', '100', 'El contenido de la propuesta debe tener al menos 100 caracteres');

-- Reglas globales aplicadas a todos los tipos de propuesta
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeInfraTech, 'userid', 'required', '1', 'Debe especificar un usuario válido como creador');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeInfraTech, 'organizationid', 'required', '1', 'Debe especificar una organización válida');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeDesarrolloSocial, 'userid', 'required', '1', 'Debe especificar un usuario válido como creador');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeDesarrolloSocial, 'organizationid', 'required', '1', 'Debe especificar una organización válida');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeSostenibilidad, 'userid', 'required', '1', 'Debe especificar un usuario válido como creador');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeSostenibilidad, 'organizationid', 'required', '1', 'Debe especificar una organización válida');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeEducacion, 'userid', 'required', '1', 'Debe especificar un usuario válido como creador');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeEducacion, 'organizationid', 'required', '1', 'Debe especificar una organización válida');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeSalud, 'userid', 'required', '1', 'Debe especificar un usuario válido como creador');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeSalud, 'organizationid', 'required', '1', 'Debe especificar una organización válida');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeTransporte, 'userid', 'required', '1', 'Debe especificar un usuario válido como creador');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeTransporte, 'organizationid', 'required', '1', 'Debe especificar una organización válida');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeInnovacion, 'userid', 'required', '1', 'Debe especificar un usuario válido como creador');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeInnovacion, 'organizationid', 'required', '1', 'Debe especificar una organización válida');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeCultura, 'userid', 'required', '1', 'Debe especificar un usuario válido como creador');
INSERT INTO PV_ValidationRules (proposaltypeid, fieldname, ruletype, rulevalue, errormessage) VALUES (@PropTypeCultura, 'organizationid', 'required', '1', 'Debe especificar una organización válida');



-- =============================================================================
-- WORKFLOWS Y PROCESOS FINALES
-- =============================================================================

-- Tipos de workflow
INSERT INTO PV_workflowsType (name) VALUES ('Aprobación de Propuestas');
INSERT INTO PV_workflowsType (name) VALUES ('Validación de Documentos');
INSERT INTO PV_workflowsType (name) VALUES ('Procesamiento de Inversiones');
INSERT INTO PV_workflowsType (name) VALUES ('Análisis con IA');

-- Workflows principales (estructura real: workflowId(IDENTITY), name, description, endpoint, workflowTypeId, params)
INSERT INTO PV_workflows (name, description, endpoint, workflowTypeId, params) VALUES ('Aprobación Propuestas Tecnológicas', 'Proceso completo para propuestas de infraestructura tecnológica', '/api/workflow/proposal-approval', 1, '{"steps":["revision_inicial","validacion_tecnica","analisis_ia","aprobacion_presupuesto","validacion_final","publicacion"],"min_confidence_score":0.80,"required_validators":2}');
INSERT INTO PV_workflows (name, description, endpoint, workflowTypeId, params) VALUES ('Validación Documentos Técnicos', 'Proceso automatizado de revisión de documentación', '/api/workflow/document-validation', 2, '{"steps":["carga_documento","analisis_ia_automatico","revision_humana_condicional","aprobacion_final"],"auto_approve_threshold":0.95}');
INSERT INTO PV_workflows (name, description, endpoint, workflowTypeId, params) VALUES ('Procesamiento de Inversiones', 'Flujo para el procesamiento de nuevas inversiones', '/api/workflow/investment-processing', 3, '{"steps":["solicitud_inversion","validacion_kyc","analisis_riesgo","aprobacion_financiera","ejecucion"],"max_amount_auto":1000000}');
INSERT INTO PV_workflows (name, description, endpoint, workflowTypeId, params) VALUES ('Análisis de Impacto IA', 'Evaluación automática de propuestas con IA', '/api/workflow/ai-analysis', 4, '{"steps":["recepcion_propuesta","analisis_factibilidad","analisis_riesgo","analisis_impacto","reporte_final"],"confidence_threshold":0.85}');
