ALTER TABLE [dbo].[PV_Logs]
ADD [value1] [varchar](250) NULL,
    [value2] [varchar](250) NULL;

ALTER TABLE [dbo].[PV_Investments]
ADD [userid] INT NULL;
GO

ALTER TABLE [dbo].[PV_Investments]
ADD CONSTRAINT FK_PV_Investments_PV_Users FOREIGN KEY ([userid])
REFERENCES [dbo].[PV_Users]([userid]);
GO

ALTER TABLE [dbo].[PV_InvestmentAgreements]
ADD [proposalid] INT NULL;
GO

ALTER TABLE [dbo].[PV_InvestmentAgreements]
ADD CONSTRAINT FK_PV_InvestmentAgreements_PV_Proposals FOREIGN KEY ([proposalid])
REFERENCES [dbo].[PV_Proposals]([proposalid]);
GO

ALTER TABLE [dbo].[PV_Investments]
ALTER COLUMN [amount] DECIMAL(28,2) NOT NULL;
ALTER TABLE [dbo].[PV_Investments]
ALTER COLUMN [equitypercentage] DECIMAL(12,8) NOT NULL;
GO

ALTER TABLE [dbo].[PV_Proposals]
ALTER COLUMN [budget] DECIMAL(28,2) NULL;
GO


ALTER TABLE [dbo].[PV_authSession]
ALTER COLUMN token VARCHAR(MAX) NULL;

ALTER TABLE [dbo].[PV_authSession]
ALTER COLUMN refreshToken VARCHAR(MAX) NULL;

ALTER TABLE [dbo].[PV_Proposals]
ADD [percentageRequested] DECIMAL(12,8) NULL;
GO

DROP PROCEDURE IF EXISTS [dbo].[PV_InvertirEnPropuesta];
GO

--Tabla faltantr de crear
CREATE TABLE [dbo].[PV_InvestmentTypes](
    [investmenttypeid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](100) NOT NULL,
    [description] [varchar](500) NULL,
    [minimuminvestment] [decimal](18, 2) NOT NULL,
    [maximuminvestment] [decimal](18, 2) NOT NULL,
    [riskrating] [varchar](50) NOT NULL,
    [expectedreturnrate] [decimal](5, 2) NOT NULL,
    PRIMARY KEY CLUSTERED 
    (
        [investmenttypeid] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO