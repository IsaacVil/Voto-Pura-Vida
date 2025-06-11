DELETE FROM PV_Votes;
DELETE FROM PV_CryptoKeys;
INSERT INTO PV_IdentityUserValidation (userid, validationid)
SELECT 
    u.userid, 
    v.validationid
FROM PV_Users u
JOIN PV_IdentityValidations v ON v.verified = 1
LEFT JOIN PV_IdentityUserValidation iuv ON iuv.userid = u.userid
WHERE iuv.userid IS NULL
  AND v.validationid = (
      SELECT TOP 1 validationid 
      FROM PV_IdentityValidations v2 
      WHERE v2.verified = 1
      ORDER BY v2.validationid DESC
  );