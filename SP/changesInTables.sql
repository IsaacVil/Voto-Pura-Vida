-- ESTOS SON UNOS CAMBIOS LIGEROS EN LAS TABLAS DE LA BASE DE DATOS

-- Agregar columna userid a PV_Investments
ALTER TABLE [dbo].[PV_Investments]
ADD [userid] INT NOT NULL;
GO

ALTER TABLE [dbo].[PV_Investments]
ADD CONSTRAINT FK_PV_Investments_PV_Users FOREIGN KEY ([userid])
REFERENCES [dbo].[PV_Users]([userid]);
GO


-- Agregar columna de proposalid a PV_InvestmentAgreements
ALTER TABLE [dbo].[PV_InvestmentAgreements]
ADD [proposalid] INT NOT NULL;
GO

ALTER TABLE [dbo].[PV_InvestmentAgreements]
ADD CONSTRAINT FK_PV_InvestmentAgreements_PV_Proposals FOREIGN KEY ([proposalid])
REFERENCES [dbo].[PV_Proposals]([proposalid]);
GO

