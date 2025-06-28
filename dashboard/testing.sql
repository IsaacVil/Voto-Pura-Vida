-- datos de prueba para dashboard

-- Inserts de usuarios de prueba del 1103 al 1112
SET IDENTITY_INSERT PV_Users ON;
DECLARE @UserStatusActiveVerified INT = (SELECT userStatusId FROM PV_UserStatus WHERE active = 1 AND verified = 1);
INSERT INTO PV_Users (userid, email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) VALUES
(1103, 'user1103@example.com', 'Nombre1103', 'Apellido1103', '1990-01-03', GETDATE(), 1, GETDATE(), 110300003, @UserStatusActiveVerified),
(1104, 'user1104@example.com', 'Nombre1104', 'Apellido1104', '1990-01-04', GETDATE(), 1, GETDATE(), 110400004, @UserStatusActiveVerified),
(1105, 'user1105@example.com', 'Nombre1105', 'Apellido1105', '1990-01-05', GETDATE(), 1, GETDATE(), 110500005, @UserStatusActiveVerified),
(1106, 'user1106@example.com', 'Nombre1106', 'Apellido1106', '1990-01-06', GETDATE(), 1, GETDATE(), 110600006, @UserStatusActiveVerified),
(1107, 'user1107@example.com', 'Nombre1107', 'Apellido1107', '1990-01-07', GETDATE(), 1, GETDATE(), 110700007, @UserStatusActiveVerified),
(1108, 'user1108@example.com', 'Nombre1108', 'Apellido1108', '1990-01-08', GETDATE(), 1, GETDATE(), 110800008, @UserStatusActiveVerified),
(1109, 'user1109@example.com', 'Nombre1109', 'Apellido1109', '1990-01-09', GETDATE(), 1, GETDATE(), 110900009, @UserStatusActiveVerified),
(1110, 'user1110@example.com', 'Nombre1110', 'Apellido1110', '1990-01-10', GETDATE(), 1, GETDATE(), 111000010, @UserStatusActiveVerified),
(1111, 'user1111@example.com', 'Nombre1111', 'Apellido1111', '1990-01-11', GETDATE(), 1, GETDATE(), 111100011, @UserStatusActiveVerified),
(1112, 'user1112@example.com', 'Nombre1112', 'Apellido1112', '1990-01-12', GETDATE(), 1, GETDATE(), 111200012, @UserStatusActiveVerified);


SET IDENTITY_INSERT PV_Users OFF;

-- existen ya usuarios con id 11ij con ij {01,02,03,..,12} y segmentos de distintos tipos con sus respectivas subdivisiones

-- primero asociemos usuarios a segmentos

-- Demográfico: (segmentids 1-4)
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1101, 1, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1102, 1, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1103, 2, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1104, 2, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1105, 3, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1106, 3, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1107, 4, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1108, 4, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1109, 4, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1110, 4, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1111, 3, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1112, 3, GETDATE(), 1);

-- Socioeconómico (segmentid 6-9)
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1101, 6, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1102, 7, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1103, 8, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1104, 9, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1105, 6, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1106, 7, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1107, 8, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1108, 9, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1109, 6, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1110, 7, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1111, 8, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1112, 9, GETDATE(), 1);

-- Geográfico (segmentid 19-22)
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1101, 22, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1102, 21, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1103, 20, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1104, 19, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1105, 22, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1106, 21, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1107, 20, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1108, 19, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1109, 22, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1110, 21, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1111, 20, GETDATE(), 1);
INSERT INTO PV_UserSegments (userid, segmentid, assigneddate, isactive)
VALUES (1112, 19, GETDATE(), 1);

-- base para que no de errores
INSERT INTO PV_VotingQuestions (question, questionTypeId, createdDate, checksum) VALUES ('�Est� de acuerdo con la propuesta?', 1, GETDATE(), 0x00);
INSERT INTO PV_VotingQuestions (question, questionTypeId, createdDate, checksum) VALUES ('�Est� usted a favor?', 2, GETDATE(), 0x00);


-- hagamos 5 propuestas
DECLARE @ProposalId1 INT, @ProposalId2 INT, @ProposalId3 INT, @ProposalId4 INT, @ProposalId5 INT;

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
) VALUES (
    'Propuesta demografica',
    'Descripción de la propuesta',
    'Contenido detallado de la propuesta',
    500000,                -- presupuesto
    1001,                  -- ID del usuario creador, otro que no hemos usado 
    GETDATE(),            -- fecha de creación
    GETDATE(),            -- fecha de última modificación
    1,                    -- ID de tipo de propuesta
    3,                    -- ID de status (aprobada)
    1,                    -- ID de organización
    0xA1B2C3,             -- checksum de ejemplo
    1                     -- versión
);
SET @ProposalId1 = SCOPE_IDENTITY();

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
) VALUES (
    'Propuesta socioeconomica',
    'Descripción de la propuesta',
    'Contenido detallado de la propuesta',
    100000,                -- presupuesto
    1002,                  -- ID del usuario creador, otro que no hemos usado 
    GETDATE(),            -- fecha de creación
    GETDATE(),            -- fecha de última modificación
    1,                    -- ID de tipo de propuesta
    3,                    -- ID de status (aprobada)
    1,                    -- ID de organización
    0xA1B2C3,             -- checksum de ejemplo
    1                     -- versión
);
SET @ProposalId2 = SCOPE_IDENTITY();

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
) VALUES (
    'Propuesta geografica',
    'Descripción de la propuesta',
    'Contenido detallado de la propuesta',
    5000000,                -- presupuesto
    1001,                  -- ID del usuario creador, otro que no hemos usado 
    GETDATE(),            -- fecha de creación
    GETDATE(),            -- fecha de última modificación
    1,                    -- ID de tipo de propuesta
    3,                    -- ID de status (aprobada)
    1,                    -- ID de organización
    0xA1B2C3,             -- checksum de ejemplo
    1                     -- versión
);
SET @ProposalId3 = SCOPE_IDENTITY();

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
) VALUES (
    'Propuesta demografica y geografica',
    'Descripción de la propuesta',
    'Contenido detallado de la propuesta',
    700000,                -- presupuesto
    1001,                  -- ID del usuario creador, otro que no hemos usado 
    GETDATE(),            -- fecha de creación
    GETDATE(),            -- fecha de última modificación
    1,                    -- ID de tipo de propuesta
    3,                    -- ID de status (aprobada)
    1,                    -- ID de organización
    0xA1B2C3,             -- checksum de ejemplo
    1                     -- versión
);
SET @ProposalId4 = SCOPE_IDENTITY();

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
) VALUES (
    'Propuesta socioeconomica y geografca',
    'Descripción de la propuesta',
    'Contenido detallado de la propuesta',
    900000,                -- presupuesto
    1001,                  -- ID del usuario creador, otro que no hemos usado 
    GETDATE(),            -- fecha de creación
    GETDATE(),            -- fecha de última modificación
    1,                    -- ID de tipo de propuesta
    3,                    -- ID de status (aprobada)
    1,                    -- ID de organización
    0xA1B2C3,             -- checksum de ejemplo
    1                     -- versión
);
SET @ProposalId5 = SCOPE_IDENTITY();

UPDATE PV_Proposals
SET percentagerequested = 50;

-- votaciones para las propuestas, ids 3-7
DECLARE @VotingConfig1 INT, 
        @VotingConfig2 INT, 
        @VotingConfig3 INT, 
        @VotingConfig4 INT, 
        @VotingConfig5 INT;

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
) VALUES (
    @ProposalId1,                                -- ID de la propuesta
    DATEADD(day, -15, GETDATE()),     -- startdate: hace 15 días
    DATEADD(day, -8, GETDATE()),      -- enddate: hace 8 días (7 días de duración)
    1,                                -- ID de tipo de votación
    1,                                -- allowweightedvotes
    0,                                -- requiresallvoters
    1,                                -- ID de método de notificación
    1001,                             -- ID de usuario que configura
    DATEADD(day, -15, GETDATE()),     -- configureddate: hace 15 días
    5,                                -- ID de status
    NULL,                             -- publisheddate
    NULL,                             -- finalizeddate
    0,                                -- publicVoting
    0xA1B2C3                          -- checksum de ejemplo
);
SET @VotingConfig1 = SCOPE_IDENTITY();

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
) VALUES (
    @ProposalId2,                                -- ID de la propuesta
    DATEADD(day, -15, GETDATE()),     -- startdate: hace 15 días
    DATEADD(day, -8, GETDATE()),      -- enddate: hace 8 días (7 días de duración)
    1,                                -- ID de tipo de votación
    1,                                -- allowweightedvotes
    0,                                -- requiresallvoters
    1,                                -- ID de método de notificación
    1001,                             -- ID de usuario que configura
    DATEADD(day, -15, GETDATE()),     -- configureddate: hace 15 días
    5,                                -- ID de status
    NULL,                             -- publisheddate
    NULL,                             -- finalizeddate
    0,                                -- publicVoting
    0xA1B2C3                          -- checksum de ejemplo
);
set @VotingConfig2 = SCOPE_IDENTITY();

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
) VALUES (
    @ProposalId3,                               -- ID de la propuesta
    DATEADD(day, -15, GETDATE()),     -- startdate: hace 15 días
    DATEADD(day, -8, GETDATE()),      -- enddate: hace 8 días (7 días de duración)
    1,                                -- ID de tipo de votación
    1,                                -- allowweightedvotes
    0,                                -- requiresallvoters
    1,                                -- ID de método de notificación
    1001,                             -- ID de usuario que configura
    DATEADD(day, -15, GETDATE()),     -- configureddate: hace 15 días
    5,                                -- ID de status
    NULL,                             -- publisheddate
    NULL,                             -- finalizeddate
    0,                                -- publicVoting
    0xA1B2C3                          -- checksum de ejemplo
);
set @VotingConfig3 = SCOPE_IDENTITY();

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
) VALUES (
    @ProposalId4,                                   -- ID de la propuesta
    DATEADD(day, -15, GETDATE()),     -- startdate: hace 15 días
    DATEADD(day, -8, GETDATE()),      -- enddate: hace 8 días (7 días de duración)
    1,                                -- ID de tipo de votación
    1,                                -- allowweightedvotes
    0,                                -- requiresallvoters
    1,                                -- ID de método de notificación
    1001,                             -- ID de usuario que configura
    DATEADD(day, -15, GETDATE()),     -- configureddate: hace 15 días
    5,                                -- ID de status
    NULL,                             -- publisheddate
    NULL,                             -- finalizeddate
    0,                                -- publicVoting
    0xA1B2C3                          -- checksum de ejemplo
);
set @VotingConfig4 = SCOPE_IDENTITY();

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
) VALUES (
    @ProposalId5,                                 -- ID de la propuesta
    DATEADD(day, -15, GETDATE()),     -- startdate: hace 15 días
    DATEADD(day, -8, GETDATE()),      -- enddate: hace 8 días (7 días de duración)
    1,                                -- ID de tipo de votación
    1,                                -- allowweightedvotes
    0,                                -- requiresallvoters
    1,                                -- ID de método de notificación
    1001,                             -- ID de usuario que configura
    DATEADD(day, -15, GETDATE()),     -- configureddate: hace 15 días
    5,                                -- ID de status
    NULL,                             -- publisheddate
    NULL,                             -- finalizeddate
    0,                                -- publicVoting
    0xA1B2C3                          -- checksum de ejemplo
);
set @VotingConfig5 = SCOPE_IDENTITY();

-- conectar a las config de voto los segmentios de interes

-- propuesta demografica VCid= 4
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig1,                      -- ID de configuración de votación
    1,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig1,                       -- ID de configuración de votación
    2,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig1,                       -- ID de configuración de votación
    3,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig1,                       -- ID de configuración de votación
    4,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);

-- Propuesta socioeconomica VCid= 5
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig2,                        -- ID de configuración de votación
    6,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig2,                        -- ID de configuración de votación
    7,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig2,                       -- ID de configuración de votación
    8,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig2,                       -- ID de configuración de votación
    9,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);

-- propuesta geografica VCid= 6
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig3,                      -- ID de configuración de votación
    19,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig3,                       -- ID de configuración de votación
    20,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig3,                       -- ID de configuración de votación
    21,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig3,                        -- ID de configuración de votación
    22,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);


-- propuesta demo+geo VCid= 7
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig4,                        -- ID de configuración de votación
    1,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig4,                        -- ID de configuración de votación
    2,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig4,                        -- ID de configuración de votación
    3,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig4,                       -- ID de configuración de votación
    4,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);

INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig4,                        -- ID de configuración de votación
    19,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig4,                       -- ID de configuración de votación
    20,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig4,                        -- ID de configuración de votación
    21,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig4,                       -- ID de configuración de votación
    22,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);


-- propuesta socio+geo VCid= 8
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig5,                       -- ID de configuración de votación
    6,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig5,                       -- ID de configuración de votación
    7,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig5,                        -- ID de configuración de votación
    8,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig5,                        -- ID de configuración de votación
    9,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);

INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig5,                       -- ID de configuración de votación
    19,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig5,                        -- ID de configuración de votación
    20,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig5,                        -- ID de configuración de votación
    21,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    @VotingConfig5,                       -- ID de configuración de votación
    22,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);


-- pongamos las opciones
-- prop. demo
DECLARE @OptionId1_Si INT, @OptionId1_No INT;
INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    @VotingConfig1,   -- ID de la votación
    'Sí',
    1,
    1, -- de acuerdo o no
    0xA1B2C3
);
SET @OptionId1_Si = SCOPE_IDENTITY();
INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    @VotingConfig1,
    'No',
    2,
    1,
    0xA1B2C3
);
SET @OptionId1_No = SCOPE_IDENTITY();

-- prop socio
DECLARE @OptionId2_Si INT, @OptionId2_No INT;
INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    @VotingConfig2, -- ID de la votación
    'Sí',
    1,
    1, -- de acuerdo o no
    0xA1B2C3
);
SET @OptionId2_Si = SCOPE_IDENTITY();
INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    @VotingConfig2,
    'No',
    2,
    1,
    0xA1B2C3
);
SET @OptionId2_No = SCOPE_IDENTITY();

-- prop geo
DECLARE @OptionId3_Si INT, @OptionId3_No INT;
INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    @VotingConfig3, -- ID de la votación
    'Sí',
    1,
    1, -- de acuerdo o no
    0xA1B2C3
);
SET @OptionId3_Si = SCOPE_IDENTITY();
INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    @VotingConfig3, 
    'No',
    2,
    1,
    0xA1B2C3
);
SET @OptionId3_No = SCOPE_IDENTITY();

-- prop demo + geo
DECLARE @OptionId4_Si INT, @OptionId4_No INT;
INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    @VotingConfig4,  -- ID de la votación
    'Sí',
    1,
    1, -- de acuerdo o no
    0xA1B2C3
);
SET @OptionId4_Si = SCOPE_IDENTITY();
INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    @VotingConfig4, 
    'No',
    2,
    1,
    0xA1B2C3
);
SET @OptionId4_No = SCOPE_IDENTITY();

-- prop socio+ geo
DECLARE @OptionId5_Si INT, @OptionId5_No INT;
INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    @VotingConfig5,  -- ID de la votación
    'Sí',
    1,
    1, -- de acuerdo o no
    0xA1B2C3
);
SET @OptionId5_Si = SCOPE_IDENTITY();
INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    @VotingConfig5, 
    'No',
    2,
    1,
    0xA1B2C3
);
SET @OptionId5_No = SCOPE_IDENTITY();

-- Ahora puedes usar @OptionIdX_Si y @OptionIdX_No en los inserts de PV_VotingMetrics para cada propuesta.

-- para los pagos
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 1101, 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 1102, 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 1103, 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 1104, 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 1105, 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 1106, 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 1107, 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 1108, 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 1109, 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 1110, 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 1111, 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 1112, 1);
INSERT INTO PV_AvailableMethods (name, token, exptokendate, maskaccount, userid, paymentmethodid) VALUES ('Tarjeta CR', 0x00, DATEADD(year,1,GETDATE()), '****1234', 1001, 1);

INSERT INTO PV_ExchangeRate(startDate, endDate, exchangeRate, enabled, currentExchangeRate, sourceCurrencyid, destinyCurrencyId) VALUES (GETDATE(), DATEADD(DAY, 300, GETDATE()), 0.5, 1,1,1,2)
-- Payment type
INSERT INTO PV_TransType(name) VALUES ('Interna')

-- Payment subtype
INSERT INTO PV_TransSubTypes(name) VALUES ('Inversion')
INSERT INTO PV_TransSubTypes(name) VALUES ('Dividendos')


-- Crear datos para tener tres propuestas de ejemplo con 4 tramos de inversión cada una 

DECLARE @proposalid INT
DECLARE @valorTotal DECIMAL(18,2)
DECLARE @userid INT

SET @proposalid = @ProposalId1
SET @valorTotal = (SELECT budget FROM PV_Proposals WHERE proposalid = @proposalid)
SET @userid = 1001

DECLARE @executionplanid INT
SELECT @executionplanid = executionplanid FROM PV_ExecutionPlans WHERE proposalid = @proposalid
IF @executionplanid IS NULL
BEGIN
    INSERT INTO PV_ExecutionPlans (proposalid, totalbudget, expectedStartdate, expectedenddate, createddate, expectedDurationInMonths)
    VALUES (
        @proposalid,
        @valorTotal,
        GETDATE(),
        DATEADD(MONTH, 4, GETDATE()),
        GETDATE(),
        4
    )
    SET @executionplanid = SCOPE_IDENTITY()
END

-- Crear steptype de nombre fiscalización de propuesta
DECLARE @steptypeid INT
SELECT @steptypeid = executionStepTypeId FROM PV_executionStepType WHERE name = CONCAT('Fiscalización de propuesta ', @proposalid)
IF @steptypeid IS NULL
BEGIN
    INSERT INTO PV_executionStepType (name)
    VALUES (CONCAT('Fiscalización de propuesta ', @proposalid))
    SET @steptypeid = SCOPE_IDENTITY()
END

-- Crear voting status 'Pending' si no existe
DECLARE @pendingstatusid INT
SELECT @pendingstatusid = statusid FROM PV_VotingStatus WHERE name = 'Pending'
IF @pendingstatusid IS NULL
BEGIN
    INSERT INTO PV_VotingStatus (name, description)
    VALUES ('Pending', 'Pendiente de revisión')
    SET @pendingstatusid = SCOPE_IDENTITY()
END

-- Crear 4 votaciones y execution plan steps para los 4 tramos
DECLARE @j INT = 1
WHILE @j <= 4
BEGIN
    -- Crear votación
    DECLARE @vote_checksum VARBINARY(256)
    SET @vote_checksum = HASHBYTES('SHA2_256', CONCAT('voto', '-', @j))

    INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeid, allowWeightedVotes, requiresAllVoters, notificationmethodid, userid, configureddate, statusid, publicVoting, checksum)
    VALUES (
        @proposalid,
        DATEADD(MONTH, @j, GETDATE()),
        DATEADD(MONTH, @j, GETDATE()),
        1, -- votingtypeid 
        0, 0, null, @userid, GETDATE(), @pendingstatusid, 0, @vote_checksum
    )
    DECLARE @votingconfigid INT = SCOPE_IDENTITY()

    -- Crear execution plan step
    INSERT INTO PV_executionPlanSteps (executionPlanId, stepIndex, description, stepTypeId, estimatedInitDate, estimatedEndDate, durationInMonts, KPI, votingId)
    VALUES (
        @executionplanid,
        @j,
        CONCAT('Fiscalización tramo ', @j, ' de la inversión'),
        @steptypeid,
        DATEADD(MONTH, @j, GETDATE()),
        DATEADD(MONTH, @j + 1, GETDATE()),
        1,
        'Tiempo de finalización ≤ 30 días; Costo ≤ $10,000; Satisfacción ≥ 90%', 
        @votingconfigid
    )
    SET @j = @j + 1
END

-- Crear los investment agreements para la propuesta
DECLARE @agreement_checksum VARBINARY(256)
SET @agreement_checksum = HASHBYTES('SHA2_256', 'Desembolso inicial de la propuesta')
INSERT INTO PV_InvestmentAgreements (
        name, description, signatureDate, porcentageInvested, userId, checksum, proposalid
    ) VALUES (
        'Adelanto',
        'Desembolso del 20% como adelanto',
        GETDATE(),
        20,
        @userid,
        @agreement_checksum,
        @proposalid
    )

-- Insertar los 4 investment agreements para los pagos pendientes del 20%
DECLARE @i INT = 1
WHILE @i <= 4
BEGIN
    DECLARE @tramo_checksum VARBINARY(256)
    SET @tramo_checksum = HASHBYTES('SHA2_256', CONCAT('Tramo', @i))
    INSERT INTO PV_InvestmentAgreements (
        name, description, signatureDate, porcentageInvested, userId, checksum, proposalid
    ) VALUES (
        CONCAT('Tramo ', @i),
        'Desembolso del 20% correspondiente al tramo ' + CAST(@i AS VARCHAR),
        GETDATE(),
        20,
        @userid,
        @tramo_checksum,
        @proposalid
    )
    SET @i = @i + 1
END


-- BLOQUE PARA PROPUESTA 2
SET @proposalid = @ProposalId2
SET @valorTotal = (SELECT budget FROM PV_Proposals WHERE proposalid = @proposalid)
SET @userid = 1002

DECLARE @executionplanid2 INT
SELECT @executionplanid2 = executionplanid FROM PV_ExecutionPlans WHERE proposalid = @proposalid
IF @executionplanid2 IS NULL
BEGIN
    INSERT INTO PV_ExecutionPlans (proposalid, totalbudget, expectedStartdate, expectedenddate, createddate, expectedDurationInMonths)
    VALUES (
        @proposalid,
        @valorTotal,
        GETDATE(),
        DATEADD(MONTH, 4, GETDATE()),
        GETDATE(),
        4
    )
    SET @executionplanid2 = SCOPE_IDENTITY()
END

DECLARE @steptypeid2 INT
SELECT @steptypeid2 = executionStepTypeId FROM PV_executionStepType WHERE name = CONCAT('Fiscalización de propuesta ', @proposalid)
IF @steptypeid2 IS NULL
BEGIN
    INSERT INTO PV_executionStepType (name)
    VALUES (CONCAT('Fiscalización de propuesta ', @proposalid))
    SET @steptypeid2 = SCOPE_IDENTITY()
END

DECLARE @pendingstatusid2 INT
SELECT @pendingstatusid2 = statusid FROM PV_VotingStatus WHERE name = 'Pending'
IF @pendingstatusid2 IS NULL
BEGIN
    INSERT INTO PV_VotingStatus (name, description)
    VALUES ('Pending', 'Pendiente de revisión')
    SET @pendingstatusid2 = SCOPE_IDENTITY()
END

SET @j = 1
WHILE @j <= 4
BEGIN
    SET @vote_checksum = HASHBYTES('SHA2_256', CONCAT('voto', '-', @j, '-', @proposalid))
    INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeid, allowWeightedVotes, requiresAllVoters, notificationmethodid, userid, configureddate, statusid, publicVoting, checksum)
    VALUES (
        @proposalid,
        DATEADD(MONTH, @j, GETDATE()),
        DATEADD(MONTH, @j, GETDATE()),
        1, 0, 0, null, @userid, GETDATE(), @pendingstatusid2, 0, @vote_checksum
    )
    SET @votingconfigid = SCOPE_IDENTITY()
    INSERT INTO PV_executionPlanSteps (executionPlanId, stepIndex, description, stepTypeId, estimatedInitDate, estimatedEndDate, durationInMonts, KPI, votingId)
    VALUES (
        @executionplanid2,
        @j,
        CONCAT('Fiscalización tramo ', @j, ' de la inversión'),
        @steptypeid2,
        DATEADD(MONTH, @j, GETDATE()),
        DATEADD(MONTH, @j + 1, GETDATE()),
        1,
        'Tiempo de finalización ≤ 30 días; Costo ≤ $10,000; Satisfacción ≥ 90%',
        @votingconfigid
    )
    SET @j = @j + 1
END

SET @agreement_checksum = HASHBYTES('SHA2_256', 'Desembolso inicial de la propuesta 2')
INSERT INTO PV_InvestmentAgreements (
        name, description, signatureDate, porcentageInvested, userId, checksum, proposalid
    ) VALUES (
        'Adelanto',
        'Desembolso del 20% como adelanto',
        GETDATE(),
        20,
        @userid,
        @agreement_checksum,
        @proposalid
    )
SET @i = 1
WHILE @i <= 4
BEGIN
    SET @tramo_checksum = HASHBYTES('SHA2_256', CONCAT('Tramo', @i, '-2'))
    INSERT INTO PV_InvestmentAgreements (
        name, description, signatureDate, porcentageInvested, userId, checksum, proposalid
    ) VALUES (
        CONCAT('Tramo ', @i),
        'Desembolso del 20% correspondiente al tramo ' + CAST(@i AS VARCHAR),
        GETDATE(),
        20,
        @userid,
        @tramo_checksum,
        @proposalid
    )
    SET @i = @i + 1
END

-- BLOQUE PARA PROPUESTA 3
SET @proposalid = @ProposalId3
SET @valorTotal = (SELECT budget FROM PV_Proposals WHERE proposalid = @proposalid)
SET @userid = 1001

DECLARE @executionplanid3 INT
SELECT @executionplanid3 = executionplanid FROM PV_ExecutionPlans WHERE proposalid = @proposalid
IF @executionplanid3 IS NULL
BEGIN
    INSERT INTO PV_ExecutionPlans (proposalid, totalbudget, expectedStartdate, expectedenddate, createddate, expectedDurationInMonths)
    VALUES (
        @proposalid,
        @valorTotal,
        GETDATE(),
        DATEADD(MONTH, 4, GETDATE()),
        GETDATE(),
        4
    )
    SET @executionplanid3 = SCOPE_IDENTITY()
END

DECLARE @steptypeid3 INT
SELECT @steptypeid3 = executionStepTypeId FROM PV_executionStepType WHERE name = CONCAT('Fiscalización de propuesta ', @proposalid)
IF @steptypeid3 IS NULL
BEGIN
    INSERT INTO PV_executionStepType (name)
    VALUES (CONCAT('Fiscalización de propuesta ', @proposalid))
    SET @steptypeid3 = SCOPE_IDENTITY()
END

DECLARE @pendingstatusid3 INT
SELECT @pendingstatusid3 = statusid FROM PV_VotingStatus WHERE name = 'Pending'
IF @pendingstatusid3 IS NULL
BEGIN
    INSERT INTO PV_VotingStatus (name, description)
    VALUES ('Pending', 'Pendiente de revisión')
    SET @pendingstatusid3 = SCOPE_IDENTITY()
END

SET @j = 1
WHILE @j <= 4
BEGIN
    SET @vote_checksum = HASHBYTES('SHA2_256', CONCAT('voto', '-', @j, '-', @proposalid))
    INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeid, allowWeightedVotes, requiresAllVoters, notificationmethodid, userid, configureddate, statusid, publicVoting, checksum)
    VALUES (
        @proposalid,
        DATEADD(MONTH, @j, GETDATE()),
        DATEADD(MONTH, @j, GETDATE()),
        1, 0, 0, null, @userid, GETDATE(), @pendingstatusid3, 0, @vote_checksum
    )
    SET @votingconfigid = SCOPE_IDENTITY()
    INSERT INTO PV_executionPlanSteps (executionPlanId, stepIndex, description, stepTypeId, estimatedInitDate, estimatedEndDate, durationInMonts, KPI, votingId)
    VALUES (
        @executionplanid3,
        @j,
        CONCAT('Fiscalización tramo ', @j, ' de la inversión'),
        @steptypeid3,
        DATEADD(MONTH, @j, GETDATE()),
        DATEADD(MONTH, @j + 1, GETDATE()),
        1,
        'Tiempo de finalización ≤ 30 días; Costo ≤ $10,000; Satisfacción ≥ 90%',
        @votingconfigid
    )
    SET @j = @j + 1
END

SET @agreement_checksum = HASHBYTES('SHA2_256', 'Desembolso inicial de la propuesta 3')
INSERT INTO PV_InvestmentAgreements (
        name, description, signatureDate, porcentageInvested, userId, checksum, proposalid
    ) VALUES (
        'Adelanto',
        'Desembolso del 20% como adelanto',
        GETDATE(),
        20,
        @userid,
        @agreement_checksum,
        @proposalid
    )
SET @i = 1
WHILE @i <= 4
BEGIN
    SET @tramo_checksum = HASHBYTES('SHA2_256', CONCAT('Tramo', @i, '-3'))
    INSERT INTO PV_InvestmentAgreements (
        name, description, signatureDate, porcentageInvested, userId, checksum, proposalid
    ) VALUES (
        CONCAT('Tramo ', @i),
        'Desembolso del 20% correspondiente al tramo ' + CAST(@i AS VARCHAR),
        GETDATE(),
        20,
        @userid,
        @tramo_checksum,
        @proposalid
    )
    SET @i = @i + 1
END

-- BLOQUE PARA PROPUESTA 4
SET @proposalid = @ProposalId4
SET @valorTotal = (SELECT budget FROM PV_Proposals WHERE proposalid = @proposalid)
SET @userid = 1001

DECLARE @executionplanid4 INT
SELECT @executionplanid4 = executionplanid FROM PV_ExecutionPlans WHERE proposalid = @proposalid
IF @executionplanid4 IS NULL
BEGIN
    INSERT INTO PV_ExecutionPlans (proposalid, totalbudget, expectedStartdate, expectedenddate, createddate, expectedDurationInMonths)
    VALUES (
        @proposalid,
        @valorTotal,
        GETDATE(),
        DATEADD(MONTH, 4, GETDATE()),
        GETDATE(),
        4
    )
    SET @executionplanid4 = SCOPE_IDENTITY()
END

DECLARE @steptypeid4 INT
SELECT @steptypeid4 = executionStepTypeId FROM PV_executionStepType WHERE name = CONCAT('Fiscalización de propuesta ', @proposalid)
IF @steptypeid4 IS NULL
BEGIN
    INSERT INTO PV_executionStepType (name)
    VALUES (CONCAT('Fiscalización de propuesta ', @proposalid))
    SET @steptypeid4 = SCOPE_IDENTITY()
END

DECLARE @pendingstatusid4 INT
SELECT @pendingstatusid4 = statusid FROM PV_VotingStatus WHERE name = 'Pending'
IF @pendingstatusid4 IS NULL
BEGIN
    INSERT INTO PV_VotingStatus (name, description)
    VALUES ('Pending', 'Pendiente de revisión')
    SET @pendingstatusid4 = SCOPE_IDENTITY()
END

SET @j = 1
WHILE @j <= 4
BEGIN
    SET @vote_checksum = HASHBYTES('SHA2_256', CONCAT('voto', '-', @j, '-', @proposalid))
    INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeid, allowWeightedVotes, requiresAllVoters, notificationmethodid, userid, configureddate, statusid, publicVoting, checksum)
    VALUES (
        @proposalid,
        DATEADD(MONTH, @j, GETDATE()),
        DATEADD(MONTH, @j, GETDATE()),
        1, 0, 0, null, @userid, GETDATE(), @pendingstatusid4, 0, @vote_checksum
    )
    SET @votingconfigid = SCOPE_IDENTITY()
    INSERT INTO PV_executionPlanSteps (executionPlanId, stepIndex, description, stepTypeId, estimatedInitDate, estimatedEndDate, durationInMonts, KPI, votingId)
    VALUES (
        @executionplanid4,
        @j,
        CONCAT('Fiscalización tramo ', @j, ' de la inversión'),
        @steptypeid4,
        DATEADD(MONTH, @j, GETDATE()),
        DATEADD(MONTH, @j + 1, GETDATE()),
        1,
        'Tiempo de finalización ≤ 30 días; Costo ≤ $10,000; Satisfacción ≥ 90%',
        @votingconfigid
    )
    SET @j = @j + 1
END

SET @agreement_checksum = HASHBYTES('SHA2_256', 'Desembolso inicial de la propuesta 4')
INSERT INTO PV_InvestmentAgreements (
        name, description, signatureDate, porcentageInvested, userId, checksum, proposalid
    ) VALUES (
        'Adelanto',
        'Desembolso del 20% como adelanto',
        GETDATE(),
        20,
        @userid,
        @agreement_checksum,
        @proposalid
    )
SET @i = 1
WHILE @i <= 4
BEGIN
    SET @tramo_checksum = HASHBYTES('SHA2_256', CONCAT('Tramo', @i, '-4'))
    INSERT INTO PV_InvestmentAgreements (
        name, description, signatureDate, porcentageInvested, userId, checksum, proposalid
    ) VALUES (
        CONCAT('Tramo ', @i),
        'Desembolso del 20% correspondiente al tramo ' + CAST(@i AS VARCHAR),
        GETDATE(),
        20,
        @userid,
        @tramo_checksum,
        @proposalid
    )
    SET @i = @i + 1
END

-- BLOQUE PARA PROPUESTA 5
SET @proposalid = @ProposalId5
SET @valorTotal = (SELECT budget FROM PV_Proposals WHERE proposalid = @proposalid)
SET @userid = 1001

DECLARE @executionplanid5 INT
SELECT @executionplanid5 = executionplanid FROM PV_ExecutionPlans WHERE proposalid = @proposalid
IF @executionplanid5 IS NULL
BEGIN
    INSERT INTO PV_ExecutionPlans (proposalid, totalbudget, expectedStartdate, expectedenddate, createddate, expectedDurationInMonths)
    VALUES (
        @proposalid,
        @valorTotal,
        GETDATE(),
        DATEADD(MONTH, 4, GETDATE()),
        GETDATE(),
        4
    )
    SET @executionplanid5 = SCOPE_IDENTITY()
END

DECLARE @steptypeid5 INT
SELECT @steptypeid5 = executionStepTypeId FROM PV_executionStepType WHERE name = CONCAT('Fiscalización de propuesta ', @proposalid)
IF @steptypeid5 IS NULL
BEGIN
    INSERT INTO PV_executionStepType (name)
    VALUES (CONCAT('Fiscalización de propuesta ', @proposalid))
    SET @steptypeid5 = SCOPE_IDENTITY()
END

DECLARE @pendingstatusid5 INT
SELECT @pendingstatusid5 = statusid FROM PV_VotingStatus WHERE name = 'Pending'
IF @pendingstatusid5 IS NULL
BEGIN
    INSERT INTO PV_VotingStatus (name, description)
    VALUES ('Pending', 'Pendiente de revisión')
    SET @pendingstatusid5 = SCOPE_IDENTITY()
END

SET @j = 1
WHILE @j <= 4
BEGIN
    SET @vote_checksum = HASHBYTES('SHA2_256', CONCAT('voto', '-', @j, '-', @proposalid))
    INSERT INTO PV_VotingConfigurations (proposalid, startdate, enddate, votingtypeid, allowWeightedVotes, requiresAllVoters, notificationmethodid, userid, configureddate, statusid, publicVoting, checksum)
    VALUES (
        @proposalid,
        DATEADD(MONTH, @j, GETDATE()),
        DATEADD(MONTH, @j, GETDATE()),
        1, 0, 0, null, @userid, GETDATE(), @pendingstatusid5, 0, @vote_checksum
    )
    SET @votingconfigid = SCOPE_IDENTITY()
    INSERT INTO PV_executionPlanSteps (executionPlanId, stepIndex, description, stepTypeId, estimatedInitDate, estimatedEndDate, durationInMonts, KPI, votingId)
    VALUES (
        @executionplanid5,
        @j,
        CONCAT('Fiscalización tramo ', @j, ' de la inversión'),
        @steptypeid5,
        DATEADD(MONTH, @j, GETDATE()),
        DATEADD(MONTH, @j + 1, GETDATE()),
        1,
        'Tiempo de finalización ≤ 30 días; Costo ≤ $10,000; Satisfacción ≥ 90%',
        @votingconfigid
    )
    SET @j = @j + 1
END

SET @agreement_checksum = HASHBYTES('SHA2_256', 'Desembolso inicial de la propuesta 5')
INSERT INTO PV_InvestmentAgreements (
        name, description, signatureDate, porcentageInvested, userId, checksum, proposalid
    ) VALUES (
        'Adelanto',
        'Desembolso del 20% como adelanto',
        GETDATE(),
        20,
        @userid,
        @agreement_checksum,
        @proposalid
    )
SET @i = 1
WHILE @i <= 4
BEGIN
    SET @tramo_checksum = HASHBYTES('SHA2_256', CONCAT('Tramo', @i, '-5'))
    INSERT INTO PV_InvestmentAgreements (
        name, description, signatureDate, porcentageInvested, userId, checksum, proposalid
    ) VALUES (
        CONCAT('Tramo ', @i),
        'Desembolso del 20% correspondiente al tramo ' + CAST(@i AS VARCHAR),
        GETDATE(),
        20,
        @userid,
        @tramo_checksum,
        @proposalid
    )
    SET @i = @i + 1
END


-- invierten 2 personas en cada una
EXEC PV_InvertirEnPropuesta
    @proposalid = @ProposalId1,                
    @userid = 1101,                    
    @amountInDollars = 1000,        
    @investmentdate = '2025-06-27T12:00:00',
    @paymentmethodName = 'SINPE Móvil',  
    @availablemethodName = 'Tarjeta CR'
;

EXEC PV_InvertirEnPropuesta
    @proposalid = @ProposalId1,                  
    @userid = 1102,                    
    @amountInDollars = 10000,        
    @investmentdate = '2025-06-27T12:00:00',
    @paymentmethodName = 'SINPE Móvil',  
    @availablemethodName = 'Tarjeta CR'
;


EXEC PV_InvertirEnPropuesta
    @proposalid = @ProposalId2,                  
    @userid = 1101,                    
    @amountInDollars = 7000,        
    @investmentdate = '2025-06-27T12:00:00',
    @paymentmethodName = 'SINPE Móvil',  
    @availablemethodName = 'Tarjeta CR'
;
EXEC PV_InvertirEnPropuesta
    @proposalid = @ProposalId2,              
    @userid = 1103,                    
    @amountInDollars = 1000,        
    @investmentdate = '2025-06-27T12:00:00',
    @paymentmethodName = 'SINPE Móvil',  
    @availablemethodName = 'Tarjeta CR'
;

EXEC PV_InvertirEnPropuesta
    @proposalid = @ProposalId3,                  
    @userid = 1102,                    
    @amountInDollars = 700000,        
    @investmentdate = '2025-06-27T12:00:00',
    @paymentmethodName = 'SINPE Móvil',  
    @availablemethodName = 'Tarjeta CR'
;
EXEC PV_InvertirEnPropuesta
    @proposalid = @ProposalId3,                
    @userid = 1105,                    
    @amountInDollars = 3000000,        
    @investmentdate = '2025-06-27T12:00:00',
    @paymentmethodName = 'SINPE Móvil',  
    @availablemethodName = 'Tarjeta CR'
;

INSERT INTO PV_VotingMetricsType (name)
VALUES
('Conteo de votos')

INSERT INTO PV_VotingMetrics (votingconfigid, optionid, segmentid, voteCounter, isactive, calculateddate, metrictypeId, metricvalue) VALUES
(@VotingConfig1, @OptionId1_Si, 1, 100, 1, GETDATE(), 1, 1),
(@VotingConfig1, @OptionId1_No, 1, 50, 1, GETDATE(), 1, 1),
(@VotingConfig1, @OptionId1_Si, 2, 150, 1, GETDATE(), 1, 1),
(@VotingConfig1, @OptionId1_No, 2, 75, 1, GETDATE(), 1, 1),
(@VotingConfig1, @OptionId1_Si, 3, 200, 1, GETDATE(), 1, 1),
(@VotingConfig1, @OptionId1_No, 3, 100, 1, GETDATE(), 1, 1),
(@VotingConfig1, @OptionId1_Si, 4, 250, 1, GETDATE(), 1, 1),
(@VotingConfig1, @OptionId1_No, 4, 125, 1, GETDATE(), 1, 1);

INSERT INTO PV_VotingMetrics (votingconfigid, optionid, segmentid, voteCounter, isactive, calculateddate, metrictypeId, metricvalue) VALUES
(@VotingConfig2, @OptionId2_Si, 6, 110, 1, GETDATE(), 1, 1),
(@VotingConfig2, @OptionId2_No, 6, 55, 1, GETDATE(), 1, 1),
(@VotingConfig2, @OptionId2_Si, 7, 160, 1, GETDATE(), 1, 1),
(@VotingConfig2, @OptionId2_No, 7, 80, 1, GETDATE(), 1, 1),
(@VotingConfig2, @OptionId2_Si, 8, 210, 1, GETDATE(), 1, 1),
(@VotingConfig2, @OptionId2_No, 8, 105, 1, GETDATE(), 1, 1),
(@VotingConfig2, @OptionId2_Si, 9, 260, 1, GETDATE(), 1, 1),
(@VotingConfig2, @OptionId2_No, 9, 130, 1, GETDATE(), 1, 1);

INSERT INTO PV_VotingMetrics (votingconfigid, optionid, segmentid, voteCounter, isactive, calculateddate, metrictypeId, metricvalue) VALUES
(@VotingConfig3, @OptionId3_Si, 19, 120, 1, GETDATE(), 1, 1),
(@VotingConfig3, @OptionId3_No, 19, 60, 1, GETDATE(), 1, 1),
(@VotingConfig3, @OptionId3_Si, 20, 170, 1, GETDATE(), 1, 1),
(@VotingConfig3, @OptionId3_No, 20, 85, 1, GETDATE(), 1, 1),
(@VotingConfig3, @OptionId3_Si, 21, 220, 1, GETDATE(), 1, 1),
(@VotingConfig3, @OptionId3_No, 21, 110, 1, GETDATE(), 1, 1),
(@VotingConfig3, @OptionId3_Si, 22, 270, 1, GETDATE(), 1, 1),
(@VotingConfig3, @OptionId3_No, 22, 135, 1, GETDATE(), 1, 1);

-- Métricas para propuesta demográfica + geográfica
INSERT INTO PV_VotingMetrics (votingconfigid, optionid, segmentid, voteCounter, isactive, calculateddate, metrictypeId, metricvalue) VALUES
(@VotingConfig4, @OptionId4_Si, 1, 12, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_No, 1, 130, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_Si, 2, 100, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_No, 2, 29, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_Si, 3, 42, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_No, 3, 23, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_Si, 4, 67, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_No, 4, 88, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_Si, 19, 9, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_No, 19, 40, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_Si, 20, 56, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_No, 20, 66, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_Si, 21, 77, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_No, 21, 81, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_Si, 22, 100, 1, GETDATE(), 1, 0),
(@VotingConfig4, @OptionId4_No, 22, 130, 1, GETDATE(), 1, 0);

-- Métricas para propuesta socioeconómica + geográfica
INSERT INTO PV_VotingMetrics (votingconfigid, optionid, segmentid, voteCounter, isactive, calculateddate, metrictypeId, metricvalue) VALUES
(@VotingConfig5, @OptionId5_Si, 6, 70, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_No, 6, 80, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_Si, 7, 90, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_No, 7, 20, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_Si, 8, 30, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_No, 8, 40, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_Si, 9, 50, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_No, 9, 60, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_Si, 19, 33, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_No, 19, 56, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_Si, 20, 55, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_No, 20, 77, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_Si, 21, 88, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_No, 21, 56, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_Si, 22, 27, 1, GETDATE(), 1, 0),
(@VotingConfig5, @OptionId5_No, 22, 100, 1, GETDATE(), 1, 0);