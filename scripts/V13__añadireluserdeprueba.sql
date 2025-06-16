INSERT INTO PV_Users(userid, email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) 
values (110100100, 'IsaacVillalobosB@gmail.com', 'Isaac', 'Villalobos', '1999-04-20', GETDATE(), 1, GETDATE(), 110100100, 99999999);
INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid) 
VALUES (1, CAST('JBSWY3DPEHPK3PXP' AS varbinary(256)), GETDATE(), 1, NULL, 110100100); 
INSERT INTO PV_UserStatus (userStatusId, active, verified)
values (99999999, 1, 1);
