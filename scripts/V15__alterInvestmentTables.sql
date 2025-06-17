-- ESTOS SON UNOS CAMBIOS LIGEROS EN LAS TABLAS DE LA BASE DE DATOS

-- Agregar columna userid a PV_Investments
ALTER TABLE [dbo].[PV_Investments]
ADD [userid] INT NULL;
GO

ALTER TABLE [dbo].[PV_Investments]
ADD CONSTRAINT FK_PV_Investments_PV_Users FOREIGN KEY ([userid])
REFERENCES [dbo].[PV_Users]([userid]);
GO


-- Agregar columna de proposalid a PV_InvestmentAgreements
ALTER TABLE [dbo].[PV_InvestmentAgreements]
ADD [proposalid] INT NULL;
GO

ALTER TABLE [dbo].[PV_InvestmentAgreements]
ADD CONSTRAINT FK_PV_InvestmentAgreements_PV_Proposals FOREIGN KEY ([proposalid])
REFERENCES [dbo].[PV_Proposals]([proposalid]);
GO


-- Cambiar soporte de los decimal para el amount y equitypercentage de PV_Investments
ALTER TABLE [dbo].[PV_Investments]
ALTER COLUMN [amount] DECIMAL(28,2) NOT NULL;
ALTER TABLE [dbo].[PV_Investments]
ALTER COLUMN [equitypercentage] DECIMAL(12,8) NOT NULL;
GO

-- Lo mismo para las proposals con el budget
ALTER TABLE [dbo].[PV_Proposals]
ALTER COLUMN [budget] DECIMAL(28,2) NULL;
GO