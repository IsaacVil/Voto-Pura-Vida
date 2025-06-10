-- V3__fixLogs.sql
-- Add value1 and value2 fields to PV_Logs table

-- Add the two new varchar(250) fields
ALTER TABLE [dbo].[PV_Logs]
ADD [value1] [varchar](250) NULL,
    [value2] [varchar](250) NULL;