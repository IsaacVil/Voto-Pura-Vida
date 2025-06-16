SET IDENTITY_INSERT PV_UserStatus ON;
INSERT INTO PV_UserStatus (userStatusId, active, verified)
VALUES (99999999, 1, 1);
SET IDENTITY_INSERT PV_UserStatus OFF;

SET IDENTITY_INSERT PV_Users ON;
INSERT INTO PV_Users(userid, email, firstname, lastname, birthdate, createdAt, genderId, lastupdate, dni, userStatusId) 
VALUES (110100100, 'IsaacVillalobosB@gmail.com', 'Isaac', 'Villalobos', '1999-04-20', GETDATE(), 1, GETDATE(), 110100100, 99999999);
SET IDENTITY_INSERT PV_Users OFF;

INSERT INTO PV_MFA (MFAmethodid, MFA_secret, createdAt, enabled, organizationid, userid) 
VALUES (1, CAST('JBSWY3DPEHPK3PXP' AS varbinary(256)), GETDATE(), 1, NULL, 110100100);

INSERT INTO PV_IdentityValidations (
    validationdate, validationtype, validationresult, aivalidationresult, validationhash, workflowId, verified
) VALUES (
    GETDATE(), 'email', 'success', NULL, 0x123456, NULL, 1
);

DECLARE @validationid INT = SCOPE_IDENTITY();

INSERT INTO PV_IdentityUserValidation (userid, validationid)
VALUES (110100100, @validationid);