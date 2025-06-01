-- Drop all foreign key constraints first
DECLARE @sql NVARCHAR(MAX) = N'';

-- Drop all foreign keys
SELECT @sql = @sql + 'ALTER TABLE [' + s.name + '].[' + t.name + '] DROP CONSTRAINT [' + fk.name + '];' + CHAR(13) + CHAR(10)
FROM sys.foreign_keys fk
INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id;

IF LEN(@sql) > 0
    EXEC sp_executesql @sql;

-- Drop all tables
SET @sql = N'';
SELECT @sql = @sql + 'DROP TABLE [' + s.name + '].[' + t.name + '];' + CHAR(13) + CHAR(10)
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id;

IF LEN(@sql) > 0
    EXEC sp_executesql @sql;

-- Optionally, drop all views (uncomment if needed)
-- SET @sql = N'';
-- SELECT @sql = @sql + 'DROP VIEW [' + s.name + '].[' + v.name + '];' + CHAR(13) + CHAR(10)
-- FROM sys.views v
-- INNER JOIN sys.schemas s ON v.schema_id = s.schema_id;
-- IF LEN(@sql) > 0
--     EXEC sp_executesql @sql;

-- Optionally, drop all user-defined types, procs, etc. (add as needed)
