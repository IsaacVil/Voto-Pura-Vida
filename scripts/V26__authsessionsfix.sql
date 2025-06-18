ALTER TABLE [dbo].[PV_authSession]
ALTER COLUMN token VARCHAR(MAX) NULL;

ALTER TABLE [dbo].[PV_authSession]
ALTER COLUMN refreshToken VARCHAR(MAX) NULL;

INSERT INTO PV_AuthPlatforms (name, secretKey, [key], iconURL)
VALUES ('google', 123, 123, 'google.com/url');
