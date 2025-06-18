-- Vamos a darle permisos al userid 1 de ver las votaciones, es el permiso con id 9
INSERT INTO PV_UserPermissions (enabled, deleted, lastupdate, checksum, userid, permissionid) VALUES (1, 0, GETDATE(), 0x00, 1, 9);
