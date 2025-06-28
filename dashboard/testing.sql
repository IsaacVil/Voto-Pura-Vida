-- datos de prueba para dashboard

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


-- hagamos 5 propuestas
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

UPDATE PV_Proposals
SET percentagerequested = 50;

-- votaciones para las propuestas, ids 3-7

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
    3,                                -- ID de la propuesta
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
    4,                                -- ID de la propuesta
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
    5,                                -- ID de la propuesta
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
    6,                                -- ID de la propuesta
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
    7,                                -- ID de la propuesta
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

-- conectar a las config de voto los segmentios de interes

-- propuesta demografica VCid= 4
INSERT INTO PV_VotingTargetSegments (
    votingconfigid,
    segmentid,
    voteweight,
    assigneddate
) VALUES (
    4,                      -- ID de configuración de votación
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
    4,                      -- ID de configuración de votación
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
    4,                      -- ID de configuración de votación
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
    4,                      -- ID de configuración de votación
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
    5,                      -- ID de configuración de votación
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
    5,                      -- ID de configuración de votación
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
    5,                      -- ID de configuración de votación
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
    5,                      -- ID de configuración de votación
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
    6,                      -- ID de configuración de votación
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
    6,                      -- ID de configuración de votación
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
    6,                      -- ID de configuración de votación
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
    6,                      -- ID de configuración de votación
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
    7,                      -- ID de configuración de votación
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
    7,                      -- ID de configuración de votación
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
    7,                      -- ID de configuración de votación
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
    7,                      -- ID de configuración de votación
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
    7,                      -- ID de configuración de votación
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
    7,                      -- ID de configuración de votación
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
    7,                      -- ID de configuración de votación
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
    7,                      -- ID de configuración de votación
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
    8,                      -- ID de configuración de votación
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
    8,                      -- ID de configuración de votación
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
    8,                      -- ID de configuración de votación
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
    8,                      -- ID de configuración de votación
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
    8,                      -- ID de configuración de votación
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
    8,                      -- ID de configuración de votación
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
    8,                      -- ID de configuración de votación
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
    8,                      -- ID de configuración de votación
    22,                      -- ID de segmento
    1.00,                   -- peso del voto
    DATEADD(day, -15, GETDATE()) -- fecha de asignación (hace 15 días)
);


-- pongamos las opciones
-- prop. demo
INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    4, -- ID de la votación
    'Sí',
    1,
    1, -- de acuerdo o no
    0xA1B2C3
),
(
    4,
    'No',
    2,
    1,
    0xA1B2C3
);

-- prop socio

INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    5, -- ID de la votación
    'Sí',
    1,
    1, -- de acuerdo o no
    0xA1B2C3
),
(
    5,
    'No',
    2,
    1,
    0xA1B2C3
);

-- prop geo

INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    6, -- ID de la votación
    'Sí',
    1,
    1, -- de acuerdo o no
    0xA1B2C3
),
(
    6,
    'No',
    2,
    1,
    0xA1B2C3
);

-- prop demo + gep

INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    7, -- ID de la votación
    'Sí',
    1,
    1, -- de acuerdo o no
    0xA1B2C3
),
(
    7,
    'No',
    2,
    1,
    0xA1B2C3
);

-- prop socio+ geo

INSERT INTO PV_VotingOptions (
    votingconfigid,
    optiontext,
    optionorder,
    questionId,
    checksum
) VALUES (
    8, -- ID de la votación
    'Sí',
    1,
    1, -- de acuerdo o no
    0xA1B2C3
),
(
    8,
    'No',
    2,
    1,
    0xA1B2C3
);





-- votemos 

-- propuesta demografica (5 si, 6 no)
INSERT INTO PV_Votes (
    votingconfigid,
    userId,
    votercommitment,
    encryptedvote,
    votehash,
    nullifierhash,
    votedate,
    blockhash,
    checksum,
    publicResult
)
VALUES
(4, 1101, 0x01, CONVERT(varbinary(max), '{"userid":1101,"optionid":5,"timestamp":"2025-06-12T12:00:00Z"}'), 0x02, 0x03, GETDATE(), 0x04, 0x05, null),
(4, 1102, 0x11, CONVERT(varbinary(max), '{"userid":1102,"optionid":5,"timestamp":"2025-06-12T12:01:00Z"}'), 0x12, 0x13, GETDATE(), 0x14, 0x15, null),
(4, 1103, 0x21, CONVERT(varbinary(max), '{"userid":1103,"optionid":5,"timestamp":"2025-06-12T12:02:00Z"}'), 0x22, 0x23, GETDATE(), 0x24, 0x25, null),
(4, 1104, 0x31, CONVERT(varbinary(max), '{"userid":1104,"optionid":6,"timestamp":"2025-06-12T12:03:00Z"}'), 0x32, 0x33, GETDATE(), 0x34, 0x35, null),
(4, 1105, 0x41, CONVERT(varbinary(max), '{"userid":1105,"optionid":6,"timestamp":"2025-06-12T12:04:00Z"}'), 0x42, 0x43, GETDATE(), 0x44, 0x45, null),
(4, 1106, 0x51, CONVERT(varbinary(max), '{"userid":1106,"optionid":6,"timestamp":"2025-06-12T12:05:00Z"}'), 0x52, 0x53, GETDATE(), 0x54, 0x55, null),
(4, 1107, 0x61, CONVERT(varbinary(max), '{"userid":1107,"optionid":5,"timestamp":"2025-06-12T12:06:00Z"}'), 0x62, 0x63, GETDATE(), 0x64, 0x65, null),
(4, 1108, 0x71, CONVERT(varbinary(max), '{"userid":1108,"optionid":5,"timestamp":"2025-06-12T12:07:00Z"}'), 0x72, 0x73, GETDATE(), 0x74, 0x75, null),
(4, 1109, 0x81, CONVERT(varbinary(max), '{"userid":1109,"optionid":5,"timestamp":"2025-06-12T12:08:00Z"}'), 0x82, 0x83, GETDATE(), 0x84, 0x85, null),
(4, 1110, 0x91, CONVERT(varbinary(max), '{"userid":1110,"optionid":6,"timestamp":"2025-06-12T12:09:00Z"}'), 0x92, 0x93, GETDATE(), 0x94, 0x95, null),
(4, 1111, 0xA1, CONVERT(varbinary(max), '{"userid":1111,"optionid":6,"timestamp":"2025-06-12T12:10:00Z"}'), 0xA2, 0xA3, GETDATE(), 0xA4, 0xA5, null),
(4, 1112, 0xB1, CONVERT(varbinary(max), '{"userid":1112,"optionid":6,"timestamp":"2025-06-12T12:11:00Z"}'), 0xB2, 0xB3, GETDATE(), 0xB4, 0xB5, null);


-- propuesta socioeconomica (7 si, 8 no)
INSERT INTO PV_Votes (
    votingconfigid,
    userId,
    votercommitment,
    encryptedvote,
    votehash,
    nullifierhash,
    votedate,
    blockhash,
    checksum,
    publicResult
)
VALUES
(5, 1101, 0x01, CONVERT(varbinary(max), '{"userid":1101,"optionid":7,"timestamp":"2025-06-12T12:00:00Z"}'), 0x02, 0x03, GETDATE(), 0x04, 0x05, null),
(5, 1102, 0x11, CONVERT(varbinary(max), '{"userid":1102,"optionid":8,"timestamp":"2025-06-12T12:01:00Z"}'), 0x12, 0x13, GETDATE(), 0x14, 0x15, null),
(5, 1103, 0x21, CONVERT(varbinary(max), '{"userid":1103,"optionid":7,"timestamp":"2025-06-12T12:02:00Z"}'), 0x22, 0x23, GETDATE(), 0x24, 0x25, null),
(5, 1104, 0x31, CONVERT(varbinary(max), '{"userid":1104,"optionid":8,"timestamp":"2025-06-12T12:03:00Z"}'), 0x32, 0x33, GETDATE(), 0x34, 0x35, null),
(5, 1105, 0x41, CONVERT(varbinary(max), '{"userid":1105,"optionid":7,"timestamp":"2025-06-12T12:04:00Z"}'), 0x42, 0x43, GETDATE(), 0x44, 0x45, null),
(5, 1106, 0x51, CONVERT(varbinary(max), '{"userid":1106,"optionid":8,"timestamp":"2025-06-12T12:05:00Z"}'), 0x52, 0x53, GETDATE(), 0x54, 0x55, null),
(5, 1107, 0x61, CONVERT(varbinary(max), '{"userid":1107,"optionid":7,"timestamp":"2025-06-12T12:06:00Z"}'), 0x62, 0x63, GETDATE(), 0x64, 0x65, null),
(5, 1108, 0x71, CONVERT(varbinary(max), '{"userid":1108,"optionid":8,"timestamp":"2025-06-12T12:07:00Z"}'), 0x72, 0x73, GETDATE(), 0x74, 0x75, null),
(5, 1109, 0x81, CONVERT(varbinary(max), '{"userid":1109,"optionid":7,"timestamp":"2025-06-12T12:08:00Z"}'), 0x82, 0x83, GETDATE(), 0x84, 0x85, null),
(5, 1110, 0x91, CONVERT(varbinary(max), '{"userid":1110,"optionid":8,"timestamp":"2025-06-12T12:09:00Z"}'), 0x92, 0x93, GETDATE(), 0x94, 0x95, null),
(5, 1111, 0xA1, CONVERT(varbinary(max), '{"userid":1111,"optionid":8,"timestamp":"2025-06-12T12:10:00Z"}'), 0xA2, 0xA3, GETDATE(), 0xA4, 0xA5, null),
(5, 1112, 0xB1, CONVERT(varbinary(max), '{"userid":1112,"optionid":8,"timestamp":"2025-06-12T12:11:00Z"}'), 0xB2, 0xB3, GETDATE(), 0xB4, 0xB5, null);

-- propuesta geografica (9 si, 10 no)
INSERT INTO PV_Votes (
    votingconfigid,
    userId,
    votercommitment,
    encryptedvote,
    votehash,
    nullifierhash,
    votedate,
    blockhash,
    checksum,
    publicResult
)
VALUES
(6, 1101, 0x01, CONVERT(varbinary(max), '{"userid":1101,"optionid":9,"timestamp":"2025-06-12T12:00:00Z"}'), 0x02, 0x03, GETDATE(), 0x04, 0x05, null),
(6, 1102, 0x11, CONVERT(varbinary(max), '{"userid":1102,"optionid":9,"timestamp":"2025-06-12T12:01:00Z"}'), 0x12, 0x13, GETDATE(), 0x14, 0x15, null),
(6, 1103, 0x21, CONVERT(varbinary(max), '{"userid":1103,"optionid":9,"timestamp":"2025-06-12T12:02:00Z"}'), 0x22, 0x23, GETDATE(), 0x24, 0x25, null),
(6, 1104, 0x31, CONVERT(varbinary(max), '{"userid":1104,"optionid":9,"timestamp":"2025-06-12T12:03:00Z"}'), 0x32, 0x33, GETDATE(), 0x34, 0x35, null),
(6, 1105, 0x41, CONVERT(varbinary(max), '{"userid":1105,"optionid":9,"timestamp":"2025-06-12T12:04:00Z"}'), 0x42, 0x43, GETDATE(), 0x44, 0x45, null),
(6, 1106, 0x51, CONVERT(varbinary(max), '{"userid":1106,"optionid":9,"timestamp":"2025-06-12T12:05:00Z"}'), 0x52, 0x53, GETDATE(), 0x54, 0x55, null),
(6, 1107, 0x61, CONVERT(varbinary(max), '{"userid":1107,"optionid":9,"timestamp":"2025-06-12T12:06:00Z"}'), 0x62, 0x63, GETDATE(), 0x64, 0x65, null),
(6, 1108, 0x71, CONVERT(varbinary(max), '{"userid":1108,"optionid":9,"timestamp":"2025-06-12T12:07:00Z"}'), 0x72, 0x73, GETDATE(), 0x74, 0x75, null),
(6, 1109, 0x81, CONVERT(varbinary(max), '{"userid":1109,"optionid":9,"timestamp":"2025-06-12T12:08:00Z"}'), 0x82, 0x83, GETDATE(), 0x84, 0x85, null),
(6, 1110, 0x91, CONVERT(varbinary(max), '{"userid":1110,"optionid":9,"timestamp":"2025-06-12T12:09:00Z"}'), 0x92, 0x93, GETDATE(), 0x94, 0x95, null),
(6, 1111, 0xA1, CONVERT(varbinary(max), '{"userid":1111,"optionid":10,"timestamp":"2025-06-12T12:10:00Z"}'), 0xA2, 0xA3, GETDATE(), 0xA4, 0xA5, null),
(6, 1112, 0xB1, CONVERT(varbinary(max), '{"userid":1112,"optionid":10,"timestamp":"2025-06-12T12:11:00Z"}'), 0xB2, 0xB3, GETDATE(), 0xB4, 0xB5, null);

-- propuesta demo y geo (11 si, 12 no)
INSERT INTO PV_Votes (
    votingconfigid,
    userId,
    votercommitment,
    encryptedvote,
    votehash,
    nullifierhash,
    votedate,
    blockhash,
    checksum,
    publicResult
)
VALUES
(7, 1101, 0x01, CONVERT(varbinary(max), '{"userid":1101,"optionid":11,"timestamp":"2025-06-12T12:00:00Z"}'), 0x02, 0x03, GETDATE(), 0x04, 0x05, null),
(7, 1102, 0x11, CONVERT(varbinary(max), '{"userid":1102,"optionid":11,"timestamp":"2025-06-12T12:01:00Z"}'), 0x12, 0x13, GETDATE(), 0x14, 0x15, null),
(7, 1103, 0x21, CONVERT(varbinary(max), '{"userid":1103,"optionid":12,"timestamp":"2025-06-12T12:02:00Z"}'), 0x22, 0x23, GETDATE(), 0x24, 0x25, null),
(7, 1104, 0x31, CONVERT(varbinary(max), '{"userid":1104,"optionid":12,"timestamp":"2025-06-12T12:03:00Z"}'), 0x32, 0x33, GETDATE(), 0x34, 0x35, null),
(7, 1105, 0x41, CONVERT(varbinary(max), '{"userid":1105,"optionid":12,"timestamp":"2025-06-12T12:04:00Z"}'), 0x42, 0x43, GETDATE(), 0x44, 0x45, null),
(7, 1106, 0x51, CONVERT(varbinary(max), '{"userid":1106,"optionid":12,"timestamp":"2025-06-12T12:05:00Z"}'), 0x52, 0x53, GETDATE(), 0x54, 0x55, null),
(7, 1107, 0x61, CONVERT(varbinary(max), '{"userid":1107,"optionid":11,"timestamp":"2025-06-12T12:06:00Z"}'), 0x62, 0x63, GETDATE(), 0x64, 0x65, null),
(7, 1108, 0x71, CONVERT(varbinary(max), '{"userid":1108,"optionid":12,"timestamp":"2025-06-12T12:07:00Z"}'), 0x72, 0x73, GETDATE(), 0x74, 0x75, null),
(7, 1109, 0x81, CONVERT(varbinary(max), '{"userid":1109,"optionid":12,"timestamp":"2025-06-12T12:08:00Z"}'), 0x82, 0x83, GETDATE(), 0x84, 0x85, null),
(7, 1110, 0x91, CONVERT(varbinary(max), '{"userid":1110,"optionid":11,"timestamp":"2025-06-12T12:09:00Z"}'), 0x92, 0x93, GETDATE(), 0x94, 0x95, null),
(7, 1111, 0xA1, CONVERT(varbinary(max), '{"userid":1111,"optionid":11,"timestamp":"2025-06-12T12:10:00Z"}'), 0xA2, 0xA3, GETDATE(), 0xA4, 0xA5, null),
(7, 1112, 0xB1, CONVERT(varbinary(max), '{"userid":1112,"optionid":12,"timestamp":"2025-06-12T12:11:00Z"}'), 0xB2, 0xB3, GETDATE(), 0xB4, 0xB5, null);

-- propuesta socio y geo (13 si, 14 no)
INSERT INTO PV_Votes (
    votingconfigid,
    userId,
    votercommitment,
    encryptedvote,
    votehash,
    nullifierhash,
    votedate,
    blockhash,
    checksum,
    publicResult
)
VALUES
(8, 1101, 0x01, CONVERT(varbinary(max), '{"userid":1101,"optionid":13,"timestamp":"2025-06-12T12:00:00Z"}'), 0x02, 0x03, GETDATE(), 0x04, 0x05, null),
(8, 1102, 0x11, CONVERT(varbinary(max), '{"userid":1102,"optionid":13,"timestamp":"2025-06-12T12:01:00Z"}'), 0x12, 0x13, GETDATE(), 0x14, 0x15, null),
(8, 1103, 0x21, CONVERT(varbinary(max), '{"userid":1103,"optionid":13,"timestamp":"2025-06-12T12:02:00Z"}'), 0x22, 0x23, GETDATE(), 0x24, 0x25, null),
(8, 1104, 0x31, CONVERT(varbinary(max), '{"userid":1104,"optionid":13,"timestamp":"2025-06-12T12:03:00Z"}'), 0x32, 0x33, GETDATE(), 0x34, 0x35, null),
(8, 1105, 0x41, CONVERT(varbinary(max), '{"userid":1105,"optionid":13,"timestamp":"2025-06-12T12:04:00Z"}'), 0x42, 0x43, GETDATE(), 0x44, 0x45, null),
(8, 1106, 0x51, CONVERT(varbinary(max), '{"userid":1106,"optionid":14,"timestamp":"2025-06-12T12:05:00Z"}'), 0x52, 0x53, GETDATE(), 0x54, 0x55, null),
(8, 1107, 0x61, CONVERT(varbinary(max), '{"userid":1107,"optionid":14,"timestamp":"2025-06-12T12:06:00Z"}'), 0x62, 0x63, GETDATE(), 0x64, 0x65, null),
(8, 1108, 0x71, CONVERT(varbinary(max), '{"userid":1108,"optionid":14,"timestamp":"2025-06-12T12:07:00Z"}'), 0x72, 0x73, GETDATE(), 0x74, 0x75, null),
(8, 1109, 0x81, CONVERT(varbinary(max), '{"userid":1109,"optionid":14,"timestamp":"2025-06-12T12:08:00Z"}'), 0x82, 0x83, GETDATE(), 0x84, 0x85, null),
(8, 1110, 0x91, CONVERT(varbinary(max), '{"userid":1110,"optionid":14,"timestamp":"2025-06-12T12:09:00Z"}'), 0x92, 0x93, GETDATE(), 0x94, 0x95, null),
(8, 1111, 0xA1, CONVERT(varbinary(max), '{"userid":1111,"optionid":14,"timestamp":"2025-06-12T12:10:00Z"}'), 0xA2, 0xA3, GETDATE(), 0xA4, 0xA5, null),
(8, 1112, 0xB1, CONVERT(varbinary(max), '{"userid":1112,"optionid":14,"timestamp":"2025-06-12T12:11:00Z"}'), 0xB2, 0xB3, GETDATE(), 0xB4, 0xB5, null);

-- Cambiar ciertos datos que dan problema
DELETE FROM PV_Votes
WHERE ISJSON(CONVERT(varchar(max), encryptedvote)) = 0;

UPDATE PV_VotingConfigurations
SET enddate = DATEADD(year, -1, GETDATE())
WHERE votingconfigid IN (1, 2);

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

SET @proposalid = 3
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

DECLARE @proposalid INT
DECLARE @valorTotal DECIMAL(18,2)
DECLARE @userid INT

SET @proposalid = 4
SET @valorTotal = (SELECT budget FROM PV_Proposals WHERE proposalid = @proposalid)
SET @userid = 1002

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


DECLARE @proposalid INT
DECLARE @valorTotal DECIMAL(18,2)
DECLARE @userid INT

SET @proposalid = 5
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

-- invierten 2 personas en cada una
EXEC PV_InvertirEnPropuesta
    @proposalid = 3,                
    @userid = 1101,                    
    @amountInDollars = 1000,        
    @investmentdate = '2025-06-27T12:00:00',
    @paymentmethodName = 'SINPE Móvil',  
    @availablemethodName = 'Tarjeta CR'
;

EXEC PV_InvertirEnPropuesta
    @proposalid = 3,                
    @userid = 1102,                    
    @amountInDollars = 10000,        
    @investmentdate = '2025-06-27T12:00:00',
    @paymentmethodName = 'SINPE Móvil',  
    @availablemethodName = 'Tarjeta CR'
;


EXEC PV_InvertirEnPropuesta
    @proposalid = 4,                
    @userid = 1101,                    
    @amountInDollars = 7000,        
    @investmentdate = '2025-06-27T12:00:00',
    @paymentmethodName = 'SINPE Móvil',  
    @availablemethodName = 'Tarjeta CR'
;
EXEC PV_InvertirEnPropuesta
    @proposalid = 4,                
    @userid = 1103,                    
    @amountInDollars = 1000,        
    @investmentdate = '2025-06-27T12:00:00',
    @paymentmethodName = 'SINPE Móvil',  
    @availablemethodName = 'Tarjeta CR'
;

EXEC PV_InvertirEnPropuesta
    @proposalid = 5,                
    @userid = 1102,                    
    @amountInDollars = 700000,        
    @investmentdate = '2025-06-27T12:00:00',
    @paymentmethodName = 'SINPE Móvil',  
    @availablemethodName = 'Tarjeta CR'
;
EXEC PV_InvertirEnPropuesta
    @proposalid = 5,                
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
(4, 5, 1, 2, 1, GETDATE(),1,10), -- 1101, 1102 votaron Sí
(4, 5, 2, 1, 1, GETDATE(),1,10), -- 1103 votó Sí
(4, 6, 2, 1, 1, GETDATE(),1,10), -- 1104 votó No
(4, 6, 3, 2, 1, GETDATE(),1,10), -- 1105, 1106 votaron No
(4, 5, 4, 2, 1, GETDATE(),1,10), -- 1107, 1108 votaron Sí
(4, 5, 3, 2, 1, GETDATE(),1,10), -- 1111, 1112 votaron Sí (segmento 3)
(4, 6, 4, 2, 1, GETDATE(),1,10); -- 1109, 1110 votaron No (segmento 4)

-- Propuesta socioeconómica (votingconfigid=5, opciones 7=Sí, 8=No, segmentos 6-9)
INSERT INTO PV_VotingMetrics (votingconfigid, optionid, segmentid, voteCounter, isactive, calculateddate, metrictypeId, metricvalue) VALUES
(5, 7, 6, 2, 1, GETDATE(),1,10), -- 1101, 1105 votaron Sí
(5, 8, 7, 2, 1, GETDATE(),1,10), -- 1102, 1106 votaron No
(5, 7, 8, 2, 1, GETDATE(),1,10), -- 1103, 1107 votaron Sí
(5, 8, 9, 2, 1, GETDATE(),1,10), -- 1104, 1108 votaron No
(5, 7, 6, 1, 1, GETDATE(),1,10), -- 1109 votó Sí (segmento 6)
(5, 8, 7, 1, 1, GETDATE(),1,10), -- 1110 votó No (segmento 7)
(5, 7, 8, 1, 1, GETDATE(),1,10), -- 1111 votó Sí (segmento 8)
(5, 8, 9, 1, 1, GETDATE(),1,10); -- 1112 votó No (segmento 9)

-- Propuesta geográfica (votingconfigid=6, opciones 9=Sí, 10=No, segmentos 19-22)
INSERT INTO PV_VotingMetrics (votingconfigid, optionid, segmentid, voteCounter, isactive, calculateddate, metrictypeId, metricvalue) VALUES
(6, 9, 22, 2, 1, GETDATE(),1,10), -- 1101, 1105 votaron Sí
(6, 9, 21, 2, 1, GETDATE(),1,10), -- 1102, 1106 votaron Sí
(6, 9, 20, 2, 1, GETDATE(),1,10), -- 1103, 1107 votaron Sí
(6, 9, 19, 2, 1, GETDATE(),1,10), -- 1104, 1108 votaron Sí
(6, 9, 22, 1, 1, GETDATE(),1,10), -- 1109 votó Sí (segmento 22)
(6, 9, 21, 1, 1, GETDATE(),1,10), -- 1110 votó Sí (segmento 21)
(6, 10, 20, 1, 1, GETDATE(),1,10), -- 1111 votó No (segmento 20)
(6, 10, 19, 1, 1, GETDATE(),1,10); -- 1112 votó No (segmento 19)

-- Propuesta demo+geo (votingconfigid=7, opciones 11=Sí, 12=No, segmentos 1-4, 19-22)
INSERT INTO PV_VotingMetrics (votingconfigid, optionid, segmentid, voteCounter, isactive, calculateddate, metrictypeId, metricvalue) VALUES
(7, 11, 1, 2, 1, GETDATE(),1,10), -- 1101, 1102 votaron Sí
(7, 12, 2, 2, 1, GETDATE(),1,10), -- 1103, 1104 votaron No
(7, 12, 3, 2, 1, GETDATE(),1,10), -- 1105, 1106 votaron No
(7, 11, 4, 2, 1, GETDATE(),1,10), -- 1107, 1110 votaron Sí
(7, 12, 4, 2, 1, GETDATE(),1,10), -- 1108, 1109 votaron No
(7, 11, 3, 2, 1, GETDATE(),1,10), -- 1111, 1112 votaron Sí (segmento 3)
(7, 12, 19, 2, 1, GETDATE(),1,10), -- 1104, 1108 votaron No (segmento 19)
(7, 11, 22, 2, 1, GETDATE(),1,10); -- 1101, 1105 votaron Sí (segmento 22)

-- Propuesta socio+geo (votingconfigid=8, opciones 13=Sí, 14=No, segmentos 6-9, 19-22)
INSERT INTO PV_VotingMetrics (votingconfigid, optionid, segmentid, voteCounter, isactive, calculateddate, metrictypeId, metricvalue) VALUES
(8, 13, 6, 2, 1, GETDATE(),1,10), -- 1101, 1105 votaron Sí
(8, 14, 7, 2, 1, GETDATE(),1,10), -- 1102, 1106 votaron No
(8, 13, 8, 2, 1, GETDATE(),1,10), -- 1103, 1107 votaron Sí
(8, 14, 9, 2, 1, GETDATE(),1,10), -- 1104, 1108 votaron No
(8, 13, 6, 1, 1, GETDATE(),1,10), -- 1109 votó Sí (segmento 6)
(8, 14, 7, 1, 1, GETDATE(),1,10), -- 1110 votó No (segmento 7)
(8, 13, 8, 1, 1, GETDATE(),1,10), -- 1111 votó Sí (segmento 8)
(8, 14, 9, 1, 1, GETDATE(),1,10); -- 1112 votó No (segmento 9)

INSERT INTO PV_VotingMetrics (votingconfigid, optionid, segmentid, voteCounter, isactive, calculateddate, metrictypeId, metricvalue) VALUES
(8, 13, 19, 2, 1, GETDATE(),1,10), -- 1104, 1108 votaron Sí (segmento 19)
(8, 14, 19, 2, 1, GETDATE(),1,10), -- 1112, 1108 votaron No (segmento 19)
(8, 13, 20, 2, 1, GETDATE(),1,10), -- 1103, 1107 votaron Sí (segmento 20)
(8, 14, 20, 1, 1, GETDATE(),1,10), -- 1111 votó No (segmento 20)
(8, 13, 21, 1, 1, GETDATE(),1,10), -- 1106 votó Sí (segmento 21)
(8, 14, 21, 2, 1, GETDATE(),1,10), -- 1110, 1102 votaron No (segmento 21)
(8, 13, 22, 2, 1, GETDATE(),1,10), -- 1101, 1105 votaron Sí (segmento 22)
(8, 14, 22, 1, 1, GETDATE(),1,10); -- 1109 votó No (segmento 22)

