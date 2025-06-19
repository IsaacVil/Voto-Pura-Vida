-- Check if PV_InvestmentTypes table exists
SELECT CASE 
    WHEN EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = 'dbo' 
        AND TABLE_NAME = 'PV_InvestmentTypes'
    ) 
    THEN 'PV_InvestmentTypes table EXISTS' 
    ELSE 'PV_InvestmentTypes table DOES NOT EXIST' 
END AS TableStatus;

-- Show all tables with 'Investment' in the name
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo' 
AND TABLE_NAME LIKE '%Investment%';
