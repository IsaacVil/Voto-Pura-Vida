ALTER TABLE [dbo].[PV_Proposals]
ADD [percentageRequested] DECIMAL(12,8) NULL;
GO

DROP PROCEDURE IF EXISTS [dbo].[PV_InvertirEnPropuesta];
GO