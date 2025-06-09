USE [master]
GO
/****** Object:  Database [VotoPuraVida]    Script Date: 7/6/2025 23:44:27 ******/
CREATE DATABASE [VotoPuraVida]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'VotoPuraVida', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\VotoPuraVida.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'VotoPuraVida_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\VotoPuraVida_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [VotoPuraVida] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [VotoPuraVida].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [VotoPuraVida] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [VotoPuraVida] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [VotoPuraVida] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [VotoPuraVida] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [VotoPuraVida] SET ARITHABORT OFF 
GO
ALTER DATABASE [VotoPuraVida] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [VotoPuraVida] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [VotoPuraVida] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [VotoPuraVida] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [VotoPuraVida] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [VotoPuraVida] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [VotoPuraVida] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [VotoPuraVida] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [VotoPuraVida] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [VotoPuraVida] SET  DISABLE_BROKER 
GO
ALTER DATABASE [VotoPuraVida] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [VotoPuraVida] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [VotoPuraVida] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [VotoPuraVida] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [VotoPuraVida] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [VotoPuraVida] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [VotoPuraVida] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [VotoPuraVida] SET RECOVERY FULL 
GO
ALTER DATABASE [VotoPuraVida] SET  MULTI_USER 
GO
ALTER DATABASE [VotoPuraVida] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [VotoPuraVida] SET DB_CHAINING OFF 
GO
ALTER DATABASE [VotoPuraVida] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [VotoPuraVida] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [VotoPuraVida] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [VotoPuraVida] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'VotoPuraVida', N'ON'
GO
ALTER DATABASE [VotoPuraVida] SET QUERY_STORE = ON
GO
ALTER DATABASE [VotoPuraVida] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [VotoPuraVida]
GO
/****** Object:  Table [dbo].[PV_Addresses]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Addresses](
	[addressid] [int] IDENTITY(1,1) NOT NULL,
	[line1] [varchar](200) NOT NULL,
	[line2] [varchar](200) NULL,
	[zipcode] [varchar](8) NOT NULL,
	[geoposition] [geometry] NOT NULL,
	[cityid] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[addressid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_AIAnalysisType]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_AIAnalysisType](
	[analysisTypeId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[analysisTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_AIConnections]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_AIConnections](
	[connectionid] [int] IDENTITY(1,1) NOT NULL,
	[providerid] [int] NOT NULL,
	[connectionname] [varchar](100) NOT NULL,
	[publicKey] [varbinary](512) NOT NULL,
	[privateKey] [varbinary](256) NOT NULL,
	[organizationid] [int] NULL,
	[projectid] [varchar](100) NULL,
	[region] [varchar](50) NULL,
	[environment] [varchar](20) NOT NULL,
	[isactive] [bit] NOT NULL,
	[createdby] [int] NOT NULL,
	[createdate] [datetime] NOT NULL,
	[lastused] [datetime] NULL,
	[usagecount] [bigint] NOT NULL,
	[modelId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[connectionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_AIDocumentAnalysis]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_AIDocumentAnalysis](
	[analysisid] [bigint] IDENTITY(1,1) NOT NULL,
	[documentid] [int] NOT NULL,
	[analysisDocTypeId] [int] NOT NULL,
	[confidence] [decimal](5, 4) NOT NULL,
	[result] [varchar](20) NOT NULL,
	[findings] [text] NOT NULL,
	[extracteddata] [text] NULL,
	[flags] [text] NULL,
	[humanreviewrequired] [bit] NOT NULL,
	[reviewerid] [int] NULL,
	[reviewdate] [datetime] NULL,
	[reviewcomments] [text] NULL,
	[finalresult] [varchar](20) NULL,
	[analysisdate] [datetime] NOT NULL,
	[workflowId] [int] NULL,
	[AIConnectionId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[analysisid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_AIModels]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_AIModels](
	[modelid] [int] IDENTITY(1,1) NOT NULL,
	[providerid] [int] NOT NULL,
	[modelname] [varchar](100) NOT NULL,
	[displayname] [varchar](150) NOT NULL,
	[modeltypeId] [int] NOT NULL,
	[maxinputtokens] [int] NOT NULL,
	[maxoutputtokens] [int] NOT NULL,
	[costperinputtoken] [decimal](10, 8) NOT NULL,
	[costperoutputtoken] [decimal](10, 8) NOT NULL,
	[isactive] [bit] NOT NULL,
	[capabilities] [text] NULL,
	[createdate] [datetime] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[modelid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_AIModelTypes]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_AIModelTypes](
	[AIModelId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[AIModelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_AIProposalAnalysis]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_AIProposalAnalysis](
	[analysisid] [bigint] IDENTITY(1,1) NOT NULL,
	[proposalid] [int] NOT NULL,
	[analysistype] [int] NOT NULL,
	[confidence] [decimal](5, 4) NOT NULL,
	[findings] [text] NOT NULL,
	[recommendations] [text] NULL,
	[riskfactors] [text] NULL,
	[complianceissues] [text] NULL,
	[budgetanalysis] [text] NULL,
	[marketanalysis] [text] NULL,
	[humanreviewrequired] [bit] NOT NULL,
	[reviewerid] [int] NULL,
	[reviewdate] [datetime] NULL,
	[reviewcomments] [text] NULL,
	[analysisdate] [datetime] NOT NULL,
	[workflowId] [int] NULL,
	[AIConnectionId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[analysisid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_AIProviders]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_AIProviders](
	[providerid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](100) NOT NULL,
	[baseurl] [varchar](500) NOT NULL,
	[description] [varchar](300) NULL,
	[isactive] [bit] NOT NULL,
	[ratelimitrpm] [int] NULL,
	[ratelimittpm] [bigint] NULL,
	[supportedmodels] [text] NULL,
	[createdate] [datetime] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[providerid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_AllowedCountries]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_AllowedCountries](
	[allowedcountryid] [int] IDENTITY(1,1) NOT NULL,
	[countryid] [int] NOT NULL,
	[isallowed] [bit] NOT NULL,
	[createddate] [datetime] NOT NULL,
	[lastmodified] [datetime] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[allowedcountryid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_AllowedIPs]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_AllowedIPs](
	[allowedipid] [int] IDENTITY(1,1) NOT NULL,
	[ipaddress] [varchar](45) NOT NULL,
	[ipmask] [varchar](45) NULL,
	[addressid] [int] NULL,
	[isallowed] [bit] NOT NULL,
	[description] [varchar](200) NULL,
	[createddate] [datetime] NOT NULL,
	[lastmodified] [datetime] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[allowedipid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_AuthPlatforms]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_AuthPlatforms](
	[authPlatformId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[secretKey] [varbinary](128) NOT NULL,
	[key] [varbinary](128) NOT NULL,
	[iconURL] [varchar](200) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[authPlatformId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_authSession]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_authSession](
	[AuthsessionId] [int] IDENTITY(1,1) NOT NULL,
	[sessionId] [varbinary](16) NOT NULL,
	[externalUser] [varbinary](16) NOT NULL,
	[token] [varbinary](128) NOT NULL,
	[refreshToken] [varbinary](128) NOT NULL,
	[userId] [int] NULL,
	[authPlatformId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[AuthsessionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_AvailableMethods]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_AvailableMethods](
	[availablemethodid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](45) NOT NULL,
	[token] [varbinary](128) NOT NULL,
	[exptokendate] [datetime] NOT NULL,
	[maskaccount] [varchar](20) NOT NULL,
	[userid] [int] NOT NULL,
	[paymentmethodid] [int] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[availablemethodid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Balances]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Balances](
	[balanceid] [int] IDENTITY(1,1) NOT NULL,
	[balance] [real] NOT NULL,
	[lastbalance] [real] NOT NULL,
	[lastupdate] [datetime] NOT NULL,
	[checksum] [varbinary](250) NOT NULL,
	[freezeamount] [real] NULL,
	[userid] [int] NULL,
	[fundid] [int] NOT NULL,
	[organizationId] [int] NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[balanceid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_blockchain]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_blockchain](
	[blockchainId] [int] IDENTITY(1,1) NOT NULL,
	[blockchainParamsId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[blockchainId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_BlockChainConnections]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_BlockChainConnections](
	[connectionId] [int] IDENTITY(1,1) NOT NULL,
	[blockchainId] [int] NULL,
	[workflowId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[connectionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_BlockchainParams]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_BlockchainParams](
	[blockChainParamsId] [int] IDENTITY(1,1) NOT NULL,
	[wallet_address] [varchar](100) NOT NULL,
	[wallet_private_key_encrypted] [varbinary](510) NOT NULL,
	[wallet_public] [varchar](50) NOT NULL,
	[blockchain_network] [varchar](50) NOT NULL,
	[blockchain_rpc_url] [varchar](250) NOT NULL,
	[blockchain_chain_id] [int] NOT NULL,
	[blockchain_explorer_url] [varchar](250) NOT NULL,
	[gas_price_default] [decimal](38, 18) NOT NULL,
	[gas_limit_default] [bigint] NULL,
	[gas_currency] [varchar](50) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[blockChainParamsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Cities]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Cities](
	[cityid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NOT NULL,
	[stateid] [int] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[cityid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Countries]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Countries](
	[countryid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NOT NULL,
	[languageid] [int] NOT NULL,
	[currencyid] [int] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[countryid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_CryptoKeys]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_CryptoKeys](
	[keyid] [int] IDENTITY(1,1) NOT NULL,
	[encryptedpublickey] [varbinary](max) NOT NULL,
	[encryptedprivatekey] [varbinary](max) NOT NULL,
	[createdAt] [datetime] NOT NULL,
	[userid] [int] NULL,
	[organizationid] [int] NULL,
	[expirationdate] [datetime] NOT NULL,
	[status] [varchar](20) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[keyid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Currency]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Currency](
	[currencyid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](25) NOT NULL,
	[symbol] [varchar](5) NOT NULL,
	[acronym] [varchar](5) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[currencyid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Documents]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Documents](
	[documentid] [int] IDENTITY(1,1) NOT NULL,
	[documenthash] [varbinary](256) NOT NULL,
	[aivalidationstatus] [varchar](20) NOT NULL,
	[aivalidationresult] [text] NULL,
	[humanvalidationrequired] [bit] NOT NULL,
	[mediafileId] [int] NULL,
	[periodicVerificationId] [int] NULL,
	[documentTypeId] [int] NULL,
	[version] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[documentid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_DocumentSections]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_DocumentSections](
	[sectionId] [int] IDENTITY(1,1) NOT NULL,
	[documenTypeId] [int] NULL,
	[title] [varchar](50) NOT NULL,
	[summary] [text] NULL,
	[possibleFindings] [varchar](500) NOT NULL,
	[creationDate] [datetime] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[sectionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_DocumentTypes]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_DocumentTypes](
	[documentTypeId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](100) NULL,
	[description] [varchar](300) NULL,
	[workflowId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[documentTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_EndType]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_EndType](
	[endtypeid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[endtypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ExchangeRate]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_ExchangeRate](
	[exchangeRateid] [int] IDENTITY(1,1) NOT NULL,
	[startDate] [datetime] NOT NULL,
	[endDate] [datetime] NOT NULL,
	[exchangeRate] [decimal](15, 8) NOT NULL,
	[enabled] [bit] NOT NULL,
	[currentExchangeRate] [bit] NOT NULL,
	[sourceCurrencyid] [int] NOT NULL,
	[destinyCurrencyId] [int] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[exchangeRateid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ExecutionPlans]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_ExecutionPlans](
	[executionplanid] [int] IDENTITY(1,1) NOT NULL,
	[proposalid] [int] NOT NULL,
	[totalbudget] [decimal](18, 2) NOT NULL,
	[expectedStartdate] [datetime] NOT NULL,
	[expectedenddate] [datetime] NOT NULL,
	[createddate] [datetime] NOT NULL,
	[expectedDurationInMonths] [decimal](18, 0) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[executionplanid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_executionPlanSteps]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_executionPlanSteps](
	[planStepId] [int] IDENTITY(1,1) NOT NULL,
	[executionPlanId] [int] NULL,
	[stepIndex] [int] NULL,
	[description] [varchar](100) NOT NULL,
	[stepTypeId] [int] NULL,
	[estimatedInitDate] [datetime] NULL,
	[estimatedEndDate] [datetime] NULL,
	[durationInMonts] [decimal](18, 0) NOT NULL,
	[KPI] [text] NOT NULL,
	[votingId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[planStepId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_executionStepType]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_executionStepType](
	[executionStepTypeId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[executionStepTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_FinancialReports]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_FinancialReports](
	[reportid] [int] IDENTITY(1,1) NOT NULL,
	[proposalid] [int] NOT NULL,
	[reportperiod] [varchar](20) NOT NULL,
	[totalrevenue] [decimal](18, 2) NOT NULL,
	[totalexpenses] [decimal](18, 2) NOT NULL,
	[netprofit] [decimal](18, 2) NOT NULL,
	[availablefordividends] [decimal](18, 2) NOT NULL,
	[reportfile] [varchar](500) NULL,
	[submitteddate] [datetime] NOT NULL,
	[approvedby] [int] NULL,
	[approveddate] [datetime] NULL,
	[workflowId] [int] NULL,
	[documentId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[reportid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Funds]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Funds](
	[fundid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[fundid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Genders]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Genders](
	[genderId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[genderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_IdentityOrganizationValidation]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_IdentityOrganizationValidation](
	[orgValidationId] [int] IDENTITY(1,1) NOT NULL,
	[organizationid] [int] NULL,
	[validationId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[orgValidationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_IdentityUserValidation]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_IdentityUserValidation](
	[userValidationId] [int] IDENTITY(1,1) NOT NULL,
	[userid] [int] NULL,
	[validationid] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[userValidationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_IdentityValidations]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_IdentityValidations](
	[validationid] [int] IDENTITY(1,1) NOT NULL,
	[validationdate] [datetime] NOT NULL,
	[validationtype] [varchar](30) NOT NULL,
	[validationresult] [varchar](20) NOT NULL,
	[aivalidationresult] [text] NULL,
	[validationhash] [varbinary](256) NOT NULL,
	[workflowId] [int] NULL,
	[verified] [bit] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[validationid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_InvestmentAgreements]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_InvestmentAgreements](
	[agreementId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](500) NOT NULL,
	[signatureDate] [datetime] NULL,
	[porcentageInvested] [decimal](18, 0) NULL,
	[investmentId] [int] NULL,
	[documentId] [int] NULL,
	[organizationId] [int] NULL,
	[userId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[agreementId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Investments]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Investments](
	[investmentid] [int] IDENTITY(1,1) NOT NULL,
	[proposalid] [int] NOT NULL,
	[amount] [decimal](18, 2) NOT NULL,
	[equitypercentage] [decimal](5, 4) NOT NULL,
	[investmentdate] [datetime] NOT NULL,
	[investmenthash] [varbinary](256) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[investmentid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_investmentSteps]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_investmentSteps](
	[invesmentStepId] [int] IDENTITY(1,1) NOT NULL,
	[investmentAgreementId] [int] NULL,
	[stepIndex] [int] NULL,
	[description] [varchar](300) NOT NULL,
	[amount] [decimal](18, 0) NOT NULL,
	[remainingAmount] [decimal](18, 0) NOT NULL,
	[estimatedDate] [datetime] NULL,
	[transactionId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[invesmentStepId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Languages]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Languages](
	[languageid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NOT NULL,
	[culture] [varchar](20) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[languageid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Logs]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Logs](
	[logid] [int] IDENTITY(1,1) NOT NULL,
	[description] [varchar](120) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[posttime] [datetime] NOT NULL,
	[computer] [varchar](45) NOT NULL,
	[trace] [varchar](200) NOT NULL,
	[referenceid1] [bigint] NULL,
	[referenceid2] [bigint] NULL,
	[checksum] [varbinary](250) NOT NULL,
	[logtypeid] [int] NOT NULL,
	[logsourceid] [int] NOT NULL,
	[logseverityid] [int] NOT NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[logid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_LogSeverity]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_LogSeverity](
	[logseverityid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](45) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[logseverityid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_LogSource]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_LogSource](
	[logsourceid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](45) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[logsourceid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_LogTypes]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_LogTypes](
	[logtypeid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](45) NOT NULL,
	[ref1description] [varchar](120) NOT NULL,
	[ref2description] [varchar](120) NOT NULL,
	[val1description] [varchar](120) NOT NULL,
	[val2description] [varchar](120) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[logtypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_mediafiles]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_mediafiles](
	[mediafileid] [int] IDENTITY(1,1) NOT NULL,
	[mediapath] [varchar](300) NULL,
	[deleted] [bit] NULL,
	[lastupdate] [datetime] NULL,
	[userid] [int] NULL,
	[mediatypeid] [int] NULL,
	[sizeMB] [int] NULL,
	[encoding] [varchar](20) NULL,
	[samplerate] [int] NULL,
	[languagecode] [varchar](10) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[mediafileid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_mediaTypes]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_mediaTypes](
	[mediaTypeId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NULL,
	[playerimpl] [varchar](100) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[mediaTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_MFA]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_MFA](
	[MFAid] [int] IDENTITY(1,1) NOT NULL,
	[MFAmethodid] [int] NOT NULL,
	[MFA_secret] [varbinary](256) NOT NULL,
	[createdAt] [datetime] NOT NULL,
	[enabled] [bit] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[MFAid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_MFAMethods]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_MFAMethods](
	[MFAmethodid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](100) NOT NULL,
	[description] [varchar](200) NOT NULL,
	[requiressecret] [bit] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[MFAmethodid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Modules]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Modules](
	[moduleid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](40) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[moduleid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_NotificationMethods]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_NotificationMethods](
	[notificationmethodid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](200) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[notificationmethodid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_NotificationSettings]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_NotificationSettings](
	[notificationsettingid] [int] IDENTITY(1,1) NOT NULL,
	[userid] [int] NULL,
	[organizationid] [int] NULL,
	[notificationmethodid] [int] NOT NULL,
	[isenabled] [bit] NOT NULL,
	[starttime] [time](7) NULL,
	[endtime] [time](7) NULL,
	[alloweddays] [varchar](20) NULL,
	[ipwhitelist] [varchar](500) NULL,
	[frequency] [varchar](20) NOT NULL,
	[lastnotification] [datetime] NULL,
	[createddate] [datetime] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[notificationsettingid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_OrganizationAddresses]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_OrganizationAddresses](
	[orgaddressid] [int] IDENTITY(1,1) NOT NULL,
	[organizationid] [int] NOT NULL,
	[addressid] [int] NOT NULL,
	[addresstype] [varchar](20) NOT NULL,
	[isactive] [bit] NOT NULL,
	[assigneddate] [datetime] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[orgaddressid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_OrganizationDocuments]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_OrganizationDocuments](
	[orgDocumentId] [int] IDENTITY(1,1) NOT NULL,
	[documentid] [int] NULL,
	[organizationId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[orgDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_OrganizationPermissions]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_OrganizationPermissions](
	[orgpermissionid] [int] IDENTITY(1,1) NOT NULL,
	[organizationid] [int] NOT NULL,
	[permissionid] [int] NOT NULL,
	[enabled] [bit] NOT NULL,
	[deleted] [bit] NOT NULL,
	[assigneddate] [datetime] NOT NULL,
	[lastupdate] [datetime] NOT NULL,
	[checksum] [varbinary](256) NOT NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[orgpermissionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_OrganizationPerUser]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_OrganizationPerUser](
	[organizationPerUserId] [int] IDENTITY(1,1) NOT NULL,
	[userId] [int] NULL,
	[organizationId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[organizationPerUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_OrganizationRoles]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_OrganizationRoles](
	[orgrolemappingid] [int] IDENTITY(1,1) NOT NULL,
	[organizationid] [int] NOT NULL,
	[roleid] [int] NOT NULL,
	[enabled] [bit] NOT NULL,
	[deleted] [bit] NOT NULL,
	[assigneddate] [datetime] NOT NULL,
	[lastupdate] [datetime] NOT NULL,
	[checksum] [varbinary](256) NOT NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[orgrolemappingid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Organizations]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Organizations](
	[organizationid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](100) NOT NULL,
	[description] [varchar](200) NULL,
	[userid] [int] NOT NULL,
	[createdAt] [datetime] NOT NULL,
	[legalIdentification] [varchar](16) NULL,
	[OrganizationTypeId] [int] NULL,
	[MinJointVentures] [int] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[organizationid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_OrganizationTypes]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_OrganizationTypes](
	[organizationTypeId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[organizationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_OrgMFA]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_OrgMFA](
	[orgmfaid] [int] IDENTITY(1,1) NOT NULL,
	[organizationid] [int] NOT NULL,
	[MFAid] [int] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[orgmfaid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Payment]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Payment](
	[paymentid] [int] IDENTITY(1,1) NOT NULL,
	[amount] [bigint] NOT NULL,
	[actualamount] [bigint] NOT NULL,
	[result] [smallint] NOT NULL,
	[reference] [varchar](100) NOT NULL,
	[auth] [varchar](60) NOT NULL,
	[chargetoken] [varbinary](250) NOT NULL,
	[description] [varchar](120) NULL,
	[date] [datetime] NOT NULL,
	[checksum] [varbinary](250) NOT NULL,
	[moduleid] [int] NOT NULL,
	[paymentmethodid] [int] NOT NULL,
	[availablemethodid] [int] NOT NULL,
	[userid] [int] NOT NULL,
	[error] [varchar](120) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[paymentid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_PaymentMethods]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_PaymentMethods](
	[paymentmethodid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](45) NOT NULL,
	[APIURL] [varchar](225) NOT NULL,
	[secretkey] [varbinary](125) NOT NULL,
	[key] [varbinary](125) NOT NULL,
	[logoiconurl] [varchar](225) NULL,
	[enabled] [bit] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	
	[paymentmethodid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_periodicVerification]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_periodicVerification](
	[periodicVerificationId] [int] IDENTITY(1,1) NOT NULL,
	[scheduleId] [int] NULL,
	[lastupdated] [datetime] NULL,
	[enabled] [bit] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[periodicVerificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Permissions]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Permissions](
	[permissionid] [int] IDENTITY(1,1) NOT NULL,
	[description] [varchar](100) NOT NULL,
	[code] [varchar](10) NOT NULL,
	[moduleid] [int] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[permissionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_PopulationSegments]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_PopulationSegments](
	[segmentid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NOT NULL,
	[description] [varchar](200) NULL,
	[segmenttypeid] [int] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[segmentid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ProjectMonitoring]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_ProjectMonitoring](
	[monitoringid] [int] IDENTITY(1,1) NOT NULL,
	[proposalid] [int] NOT NULL,
	[reportedby] [int] NOT NULL,
	[reportdate] [datetime] NOT NULL,
	[reporttypeId] [int] NOT NULL,
	[description] [text] NOT NULL,
	[evidence] [text] NULL,
	[statusid] [int] NOT NULL,
	[reviewedby] [int] NULL,
	[reviewdate] [datetime] NULL,
	[executionPlanId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[monitoringid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_proposalCommentDocuments]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_proposalCommentDocuments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[documentId] [int] NULL,
	[commentId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ProposalComments]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_ProposalComments](
	[commentid] [int] IDENTITY(1,1) NOT NULL,
	[proposalid] [int] NOT NULL,
	[userid] [int] NOT NULL,
	[comment] [text] NOT NULL,
	[commentdate] [datetime] NOT NULL,
	[statusid] [int] NOT NULL,
	[reviewedby] [int] NULL,
	[reviewdate] [datetime] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[commentid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ProposalDocuments]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_ProposalDocuments](
	[proposalDocumentId] [int] IDENTITY(1,1) NOT NULL,
	[proposalid] [int] NOT NULL,
	[documenthash] [varbinary](256) NOT NULL,
	[documentId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[proposalDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ProposalRequirements]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_ProposalRequirements](
	[requirementid] [int] IDENTITY(1,1) NOT NULL,
	[proposaltypeid] [int] NOT NULL,
	[requirementtypeid] [int] NOT NULL,
	[fieldname] [varchar](50) NOT NULL,
	[isrequired] [bit] NOT NULL,
	[minlength] [int] NULL,
	[maxlength] [int] NULL,
	[datatype] [varchar](20) NOT NULL,
	[validationrule] [varchar](500) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[requirementid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ProposalRequirementTypes]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_ProposalRequirementTypes](
	[requirementtypeid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](200) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[requirementtypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ProposalRequirementValues]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_ProposalRequirementValues](
	[valuekey] [int] IDENTITY(1,1) NOT NULL,
	[proposalid] [int] NOT NULL,
	[requirementid] [int] NOT NULL,
	[textvalue] [text] NULL,
	[numbervalue] [decimal](18, 4) NULL,
	[datevalue] [datetime] NULL,
	[filevalue] [varchar](500) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[valuekey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Proposals]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Proposals](
	[proposalid] [int] IDENTITY(1,1) NOT NULL,
	[title] [varchar](200) NOT NULL,
	[description] [text] NOT NULL,
	[proposalcontent] [text] NOT NULL,
	[budget] [decimal](18, 2) NULL,
	[createdby] [int] NOT NULL,
	[createdon] [datetime] NOT NULL,
	[lastmodified] [datetime] NOT NULL,
	[proposaltypeid] [int] NOT NULL,
	[statusid] [int] NOT NULL,
	[organizationid] [int] NULL,
	[checksum] [varbinary](256) NOT NULL,
	[version] [int] NOT NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[proposalid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ProposalStatus]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_ProposalStatus](
	[statusid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NOT NULL,
	[description] [varchar](100) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[statusid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ProposalTypes]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_ProposalTypes](
	[proposaltypeid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](200) NULL,
	[requiresgovernmentapproval] [bit] NOT NULL,
	[requiresvalidatorapproval] [bit] NOT NULL,
	[validatorcount] [int] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[proposaltypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ProposalVersions]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_ProposalVersions](
	[versionid] [int] IDENTITY(1,1) NOT NULL,
	[proposalid] [int] NOT NULL,
	[versionnumber] [int] NOT NULL,
	[title] [varchar](200) NOT NULL,
	[description] [text] NOT NULL,
	[proposalcontent] [text] NOT NULL,
	[budget] [decimal](18, 2) NULL,
	[createdby] [int] NOT NULL,
	[createdon] [datetime] NOT NULL,
	[isactive] [bit] NOT NULL,
	[changecomments] [text] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[versionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ProposasalCommentStatus]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_ProposasalCommentStatus](
	[statusCommentId] [int] IDENTITY(1,1) NOT NULL,
	[status] [varchar](50) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
 CONSTRAINT [PK__PV_Proje__8EF2CEFAA822F745] PRIMARY KEY CLUSTERED 
(
	[statusCommentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_PublicVote]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_PublicVote](
	[publicVoteId] [int] IDENTITY(1,1) NOT NULL,
	[userId] [int] NULL,
	[voteId] [int] NULL,
	[publicResult] [varchar](50) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[publicVoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_questionType]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_questionType](
	[questionTypeId] [int] IDENTITY(1,1) NOT NULL,
	[type] [varchar](50) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
 CONSTRAINT [PK_PV_questionType] PRIMARY KEY CLUSTERED 
(
	[questionTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_RecurrencyType]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_RecurrencyType](
	[recurrencytypeid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[recurrencytypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ReportTypes]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_ReportTypes](
	[reportTypeId] [int] NOT NULL,
	[name] [nchar](30) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
 CONSTRAINT [PK_PV_ReportTypes] PRIMARY KEY CLUSTERED 
(
	[reportTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_RolePermissions]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_RolePermissions](
	[rolepermissionid] [int] IDENTITY(1,1) NOT NULL,
	[enabled] [bit] NOT NULL,
	[deleted] [bit] NOT NULL,
	[lastupdate] [datetime] NOT NULL,
	[checksum] [varbinary](250) NOT NULL,
	[roleid] [int] NOT NULL,
	[permissionid] [int] NOT NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[rolepermissionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Roles]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Roles](
	[roleid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[roleid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Schedules]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Schedules](
	[scheduleid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](45) NOT NULL,
	[repetitions] [int] NOT NULL,
	[enddate] [datetime] NOT NULL,
	[recurrencytypeid] [int] NOT NULL,
	[endtypeid] [int] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[scheduleid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_SegmentTypes]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_SegmentTypes](
	[segmenttypeid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NOT NULL,
	[description] [varchar](100) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[segmenttypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_States]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_States](
	[stateid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NOT NULL,
	[countryid] [int] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[stateid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Transactions]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Transactions](
	[transactionid] [int] IDENTITY(1,1) NOT NULL,
	[amount] [bigint] NOT NULL,
	[description] [varchar](120) NULL,
	[date] [datetime] NOT NULL,
	[posttime] [datetime] NOT NULL,
	[reference1] [bigint] NOT NULL,
	[reference2] [bigint] NOT NULL,
	[value1] [varchar](100) NOT NULL,
	[value2] [varchar](100) NOT NULL,
	[processmanagerid] [int] NOT NULL,
	[convertedamount] [bigint] NOT NULL,
	[checksum] [varbinary](250) NOT NULL,
	[transtypeid] [int] NOT NULL,
	[transsubtypeid] [int] NOT NULL,
	[paymentid] [int] NOT NULL,
	[currencyid] [int] NOT NULL,
	[exchangerateid] [int] NOT NULL,
	[scheduleid] [int] NOT NULL,
	[balanceid] [int] NOT NULL,
	[fundid] [int] NOT NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[transactionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Translation]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Translation](
	[translationid] [int] IDENTITY(1,1) NOT NULL,
	[code] [varchar](20) NOT NULL,
	[caption] [text] NOT NULL,
	[enabled] [bit] NOT NULL,
	[languageid] [int] NOT NULL,
	[moduleid] [int] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[translationid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_TransSubTypes]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_TransSubTypes](
	[transsubtypeid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[transsubtypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_TransType]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_TransType](
	[transtypeid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[transtypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_TypesPerOrganization]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_TypesPerOrganization](
	[TypesPerOrganizationId] [int] IDENTITY(1,1) NOT NULL,
	[organizationId] [int] NULL,
	[OrganizationTypeId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[TypesPerOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_UserAddresses]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_UserAddresses](
	[useraddressid] [int] IDENTITY(1,1) NOT NULL,
	[userid] [int] NOT NULL,
	[addressid] [int] NOT NULL,
	[addresstype] [varchar](20) NOT NULL,
	[isactive] [bit] NOT NULL,
	[assigneddate] [datetime] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[useraddressid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_UserDocuments]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_UserDocuments](
	[userDocumentId] [int] IDENTITY(1,1) NOT NULL,
	[documentid] [int] NULL,
	[userId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[userDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_UserMFA]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_UserMFA](
	[usermfaid] [int] IDENTITY(1,1) NOT NULL,
	[userid] [int] NOT NULL,
	[MFAid] [int] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[usermfaid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_UserPermissions]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_UserPermissions](
	[userpermissionid] [int] IDENTITY(1,1) NOT NULL,
	[enabled] [bit] NOT NULL,
	[deleted] [bit] NOT NULL,
	[lastupdate] [datetime] NOT NULL,
	[checksum] [varbinary](250) NOT NULL,
	[userid] [int] NOT NULL,
	[permissionid] [int] NOT NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[userpermissionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_UserRoles]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_UserRoles](
	[userroleid] [int] IDENTITY(1,1) NOT NULL,
	[userid] [int] NULL,
	[roleid] [int] NULL,
	[lastupdate] [datetime] NULL,
	[checksum] [varbinary](250) NULL,
	[enabled] [bit] NOT NULL,
	[deleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[userroleid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Users]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Users](
	[userid] [int] IDENTITY(1,1) NOT NULL,
	[password] [varbinary](256) NOT NULL,
	[email] [varchar](100) NOT NULL,
	[firstname] [varchar](50) NOT NULL,
	[lastname] [varchar](50) NOT NULL,
	[birthdate] [datetime] NOT NULL,
	[createdAt] [datetime] NOT NULL,
	[genderId] [int] NOT NULL,
	[lastupdate] [datetime] NOT NULL,
	[dni] [bigint] NOT NULL,
	[userStatusId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[userid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_UserSegments]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_UserSegments](
	[usersegmentid] [int] IDENTITY(1,1) NOT NULL,
	[userid] [int] NOT NULL,
	[segmentid] [int] NOT NULL,
	[assigneddate] [datetime] NOT NULL,
	[isactive] [bit] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[usersegmentid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_UserStatus]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_UserStatus](
	[userStatusId] [int] IDENTITY(1,1) NOT NULL,
	[active] [bit] NULL,
	[verified] [bit] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[userStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ValidationRules]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_ValidationRules](
	[validationruleid] [int] IDENTITY(1,1) NOT NULL,
	[proposaltypeid] [int] NOT NULL,
	[fieldname] [varchar](50) NOT NULL,
	[ruletype] [varchar](30) NOT NULL,
	[rulevalue] [varchar](500) NULL,
	[errormessage] [varchar](200) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[validationruleid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_VoteResults]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_VoteResults](
	[resultid] [int] IDENTITY(1,1) NOT NULL,
	[votingconfigid] [int] NOT NULL,
	[optionid] [int] NOT NULL,
	[votecount] [int] NOT NULL,
	[weightedcount] [decimal](10, 2) NOT NULL,
	[lastupdated] [datetime] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[resultid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_VoterRegistry]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_VoterRegistry](
	[registryid] [int] IDENTITY(1,1) NOT NULL,
	[votingconfigid] [int] NOT NULL,
	[userid] [int] NOT NULL,
	[votercommitment] [varbinary](256) NOT NULL,
	[registrationdate] [datetime] NOT NULL,
	[hasVoted] [bit] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[registryid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Votes]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Votes](
	[voteid] [int] IDENTITY(1,1) NOT NULL,
	[votingconfigid] [int] NOT NULL,
	[votercommitment] [varbinary](256) NOT NULL,
	[encryptedvote] [varbinary](512) NOT NULL,
	[votehash] [varbinary](256) NOT NULL,
	[nullifierhash] [varbinary](256) NOT NULL,
	[votedate] [datetime] NOT NULL,
	[blockhash] [varbinary](256) NOT NULL,
	[merkleproof] [varbinary](1024) NULL,
	[blockchainId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[voteid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_VotingConfigurations]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_VotingConfigurations](
	[votingconfigid] [int] IDENTITY(1,1) NOT NULL,
	[proposalid] [int] NOT NULL,
	[startdate] [datetime] NOT NULL,
	[enddate] [datetime] NOT NULL,
	[votingtypeId] [int] NOT NULL,
	[allowweightedvotes] [bit] NOT NULL,
	[requiresallvoters] [bit] NOT NULL,
	[notificationmethodid] [int] NULL,
	[userid] [int] NOT NULL,
	[configureddate] [datetime] NOT NULL,
	[statusid] [int] NOT NULL,
	[publisheddate] [datetime] NULL,
	[finalizeddate] [datetime] NULL,
	[publicVoting] [bit] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[votingconfigid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_VotingMetrics]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_VotingMetrics](
	[metricid] [int] IDENTITY(1,1) NOT NULL,
	[votingconfigid] [int] NOT NULL,
	[metrictypeId] [int] NOT NULL,
	[metricvalue] [decimal](18, 4) NOT NULL,
	[segmentid] [int] NULL,
	[calculateddate] [datetime] NOT NULL,
	[isactive] [bit] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[metricid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_VotingMetricsType]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_VotingMetricsType](
	[VotingMetricTypeId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[VotingMetricTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_VotingOptions]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_VotingOptions](
	[optionid] [int] IDENTITY(1,1) NOT NULL,
	[votingconfigid] [int] NOT NULL,
	[optiontext] [varchar](200) NOT NULL,
	[optionorder] [int] NOT NULL,
	[questionId] [int] NOT NULL,
	[mediafileId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[optionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_VotingQuestions]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_VotingQuestions](
	[questionId] [int] IDENTITY(1,1) NOT NULL,
	[question] [varchar](500) NULL,
	[questionTypeId] [int] NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[questionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_VotingStatus]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_VotingStatus](
	[statusid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NOT NULL,
	[description] [varchar](100) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[statusid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_VotingTargetSegments]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_VotingTargetSegments](
	[targetsegmentid] [int] IDENTITY(1,1) NOT NULL,
	[votingconfigid] [int] NOT NULL,
	[segmentid] [int] NOT NULL,
	[voteweight] [decimal](5, 2) NOT NULL,
	[assigneddate] [datetime] NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[targetsegmentid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_VotingTypes]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_VotingTypes](
	[votingTypeId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[votingTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_workflows]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_workflows](
	[workflowId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](300) NOT NULL,
	[endpoint] [varchar](255) NOT NULL,
	[workflowTypeId] [int] NULL,
	[params] [nvarchar](max) NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[workflowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_workflowsType]    Script Date: 7/6/2025 23:44:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_workflowsType](
	[workflowTypeId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[checksum] [varbinary](256) NULL,
	[creationDate] [datetime] NOT NULL DEFAULT (getdate()),
	[updatedDate] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[workflowTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PV_AIConnections] ADD  DEFAULT ('production') FOR [environment]
GO
ALTER TABLE [dbo].[PV_AIConnections] ADD  DEFAULT ((1)) FOR [isactive]
GO
ALTER TABLE [dbo].[PV_AIConnections] ADD  DEFAULT (getdate()) FOR [createdate]
GO
ALTER TABLE [dbo].[PV_AIConnections] ADD  DEFAULT ((0)) FOR [usagecount]
GO
ALTER TABLE [dbo].[PV_AIDocumentAnalysis] ADD  DEFAULT ((0)) FOR [humanreviewrequired]
GO
ALTER TABLE [dbo].[PV_AIDocumentAnalysis] ADD  DEFAULT (getdate()) FOR [analysisdate]
GO
ALTER TABLE [dbo].[PV_AIModels] ADD  DEFAULT ((1)) FOR [isactive]
GO
ALTER TABLE [dbo].[PV_AIModels] ADD  DEFAULT (getdate()) FOR [createdate]
GO
ALTER TABLE [dbo].[PV_AIProposalAnalysis] ADD  DEFAULT ((0)) FOR [humanreviewrequired]
GO
ALTER TABLE [dbo].[PV_AIProposalAnalysis] ADD  DEFAULT (getdate()) FOR [analysisdate]
GO
ALTER TABLE [dbo].[PV_AIProviders] ADD  DEFAULT ((1)) FOR [isactive]
GO
ALTER TABLE [dbo].[PV_AIProviders] ADD  DEFAULT (getdate()) FOR [createdate]
GO
ALTER TABLE [dbo].[PV_AllowedCountries] ADD  DEFAULT ((1)) FOR [isallowed]
GO
ALTER TABLE [dbo].[PV_AllowedCountries] ADD  DEFAULT (getdate()) FOR [createddate]
GO
ALTER TABLE [dbo].[PV_AllowedCountries] ADD  DEFAULT (getdate()) FOR [lastmodified]
GO
ALTER TABLE [dbo].[PV_AllowedIPs] ADD  DEFAULT ((1)) FOR [isallowed]
GO
ALTER TABLE [dbo].[PV_AllowedIPs] ADD  DEFAULT (getdate()) FOR [createddate]
GO
ALTER TABLE [dbo].[PV_AllowedIPs] ADD  DEFAULT (getdate()) FOR [lastmodified]
GO
ALTER TABLE [dbo].[PV_Documents] ADD  DEFAULT ('Pending') FOR [aivalidationstatus]
GO
ALTER TABLE [dbo].[PV_Documents] ADD  DEFAULT ((0)) FOR [humanvalidationrequired]
GO
ALTER TABLE [dbo].[PV_ExecutionPlans] ADD  DEFAULT (getdate()) FOR [createddate]
GO
ALTER TABLE [dbo].[PV_FinancialReports] ADD  DEFAULT (getdate()) FOR [submitteddate]
GO
ALTER TABLE [dbo].[PV_IdentityValidations] ADD  DEFAULT (getdate()) FOR [validationdate]
GO
ALTER TABLE [dbo].[PV_Investments] ADD  DEFAULT (getdate()) FOR [investmentdate]
GO
ALTER TABLE [dbo].[PV_NotificationSettings] ADD  DEFAULT ((1)) FOR [isenabled]
GO
ALTER TABLE [dbo].[PV_NotificationSettings] ADD  DEFAULT ('Immediate') FOR [frequency]
GO
ALTER TABLE [dbo].[PV_NotificationSettings] ADD  DEFAULT (getdate()) FOR [createddate]
GO
ALTER TABLE [dbo].[PV_OrganizationAddresses] ADD  DEFAULT ('Headquarters') FOR [addresstype]
GO
ALTER TABLE [dbo].[PV_OrganizationAddresses] ADD  DEFAULT ((1)) FOR [isactive]
GO
ALTER TABLE [dbo].[PV_OrganizationAddresses] ADD  DEFAULT (getdate()) FOR [assigneddate]
GO
ALTER TABLE [dbo].[PV_OrganizationPermissions] ADD  DEFAULT ((1)) FOR [enabled]
GO
ALTER TABLE [dbo].[PV_OrganizationPermissions] ADD  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[PV_OrganizationPermissions] ADD  DEFAULT (getdate()) FOR [assigneddate]
GO
ALTER TABLE [dbo].[PV_OrganizationPermissions] ADD  DEFAULT (getdate()) FOR [lastupdate]
GO
ALTER TABLE [dbo].[PV_OrganizationRoles] ADD  DEFAULT ((1)) FOR [enabled]
GO
ALTER TABLE [dbo].[PV_OrganizationRoles] ADD  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[PV_OrganizationRoles] ADD  DEFAULT (getdate()) FOR [assigneddate]
GO
ALTER TABLE [dbo].[PV_OrganizationRoles] ADD  DEFAULT (getdate()) FOR [lastupdate]
GO
ALTER TABLE [dbo].[PV_Organizations] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[PV_Organizations] ADD  DEFAULT (getdate()) FOR [updatedDate]
GO
ALTER TABLE [dbo].[PV_ProjectMonitoring] ADD  CONSTRAINT [DF__PV_Projec__repor__31F82575]  DEFAULT (getdate()) FOR [reportdate]
GO
ALTER TABLE [dbo].[PV_ProposalComments] ADD  DEFAULT (getdate()) FOR [commentdate]
GO
ALTER TABLE [dbo].[PV_ProposalComments] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[PV_ProposalComments] ADD  DEFAULT (getdate()) FOR [updatedDate]
GO
ALTER TABLE [dbo].[PV_ProposalRequirements] ADD  DEFAULT ((1)) FOR [isrequired]
GO
ALTER TABLE [dbo].[PV_ProposalRequirements] ADD  DEFAULT ('Text') FOR [datatype]
GO
ALTER TABLE [dbo].[PV_Proposals] ADD  DEFAULT (getdate()) FOR [createdon]
GO
ALTER TABLE [dbo].[PV_Proposals] ADD  DEFAULT (getdate()) FOR [lastmodified]
GO
ALTER TABLE [dbo].[PV_Proposals] ADD  DEFAULT ((1)) FOR [version]
GO
ALTER TABLE [dbo].[PV_ProposalTypes] ADD  DEFAULT ((0)) FOR [requiresgovernmentapproval]
GO
ALTER TABLE [dbo].[PV_ProposalTypes] ADD  DEFAULT ((0)) FOR [requiresvalidatorapproval]
GO
ALTER TABLE [dbo].[PV_ProposalTypes] ADD  DEFAULT ((1)) FOR [validatorcount]
GO
ALTER TABLE [dbo].[PV_ProposalVersions] ADD  DEFAULT (getdate()) FOR [createdon]
GO
ALTER TABLE [dbo].[PV_ProposalVersions] ADD  DEFAULT ((0)) FOR [isactive]
GO
ALTER TABLE [dbo].[PV_UserAddresses] ADD  DEFAULT ('Primary') FOR [addresstype]
GO
ALTER TABLE [dbo].[PV_UserAddresses] ADD  DEFAULT ((1)) FOR [isactive]
GO
ALTER TABLE [dbo].[PV_UserAddresses] ADD  DEFAULT (getdate()) FOR [assigneddate]
GO
ALTER TABLE [dbo].[PV_Users] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[PV_Users] ADD  DEFAULT (getdate()) FOR [updatedDate]
GO
ALTER TABLE [dbo].[PV_UserSegments] ADD  DEFAULT (getdate()) FOR [assigneddate]
GO
ALTER TABLE [dbo].[PV_UserSegments] ADD  DEFAULT ((1)) FOR [isactive]
GO
ALTER TABLE [dbo].[PV_VoteResults] ADD  DEFAULT ((0)) FOR [votecount]
GO
ALTER TABLE [dbo].[PV_VoteResults] ADD  DEFAULT ((0)) FOR [weightedcount]
GO
ALTER TABLE [dbo].[PV_VoteResults] ADD  DEFAULT (getdate()) FOR [lastupdated]
GO
ALTER TABLE [dbo].[PV_VoteResults] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[PV_VoteResults] ADD  DEFAULT (getdate()) FOR [updatedDate]
GO
ALTER TABLE [dbo].[PV_VoterRegistry] ADD  DEFAULT (getdate()) FOR [registrationdate]
GO
ALTER TABLE [dbo].[PV_VoterRegistry] ADD  DEFAULT ((0)) FOR [hasVoted]
GO
ALTER TABLE [dbo].[PV_VoterRegistry] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[PV_VoterRegistry] ADD  DEFAULT (getdate()) FOR [updatedDate]
GO
ALTER TABLE [dbo].[PV_Votes] ADD  DEFAULT (getdate()) FOR [votedate]
GO
ALTER TABLE [dbo].[PV_VotingConfigurations] ADD  DEFAULT ((0)) FOR [allowweightedvotes]
GO
ALTER TABLE [dbo].[PV_VotingConfigurations] ADD  DEFAULT ((0)) FOR [requiresallvoters]
GO
ALTER TABLE [dbo].[PV_VotingConfigurations] ADD  DEFAULT (getdate()) FOR [configureddate]
GO
ALTER TABLE [dbo].[PV_VotingConfigurations] ADD  DEFAULT ((1)) FOR [statusid]
GO
ALTER TABLE [dbo].[PV_VotingConfigurations] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[PV_VotingConfigurations] ADD  DEFAULT (getdate()) FOR [updatedDate]
GO
ALTER TABLE [dbo].[PV_VotingMetrics] ADD  DEFAULT (getdate()) FOR [calculateddate]
GO
ALTER TABLE [dbo].[PV_VotingMetrics] ADD  DEFAULT ((1)) FOR [isactive]
GO
ALTER TABLE [dbo].[PV_VotingOptions] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[PV_VotingOptions] ADD  DEFAULT (getdate()) FOR [updatedDate]
GO
ALTER TABLE [dbo].[PV_VotingTargetSegments] ADD  DEFAULT ((1.0)) FOR [voteweight]
GO
ALTER TABLE [dbo].[PV_VotingTargetSegments] ADD  DEFAULT (getdate()) FOR [assigneddate]
GO
ALTER TABLE [dbo].[PV_Addresses]  WITH CHECK ADD  CONSTRAINT [FK_PV_Addresses_PV_Cities] FOREIGN KEY([cityid])
REFERENCES [dbo].[PV_Cities] ([cityid])
GO
ALTER TABLE [dbo].[PV_Addresses] CHECK CONSTRAINT [FK_PV_Addresses_PV_Cities]
GO
ALTER TABLE [dbo].[PV_AIConnections]  WITH CHECK ADD  CONSTRAINT [FK_AiModels_AIconnections] FOREIGN KEY([modelId])
REFERENCES [dbo].[PV_AIModels] ([modelid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PV_AIConnections] CHECK CONSTRAINT [FK_AiModels_AIconnections]
GO
ALTER TABLE [dbo].[PV_AIConnections]  WITH CHECK ADD  CONSTRAINT [FK_organizationId_AIConnections] FOREIGN KEY([organizationid])
REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO
ALTER TABLE [dbo].[PV_AIConnections] CHECK CONSTRAINT [FK_organizationId_AIConnections]
GO
ALTER TABLE [dbo].[PV_AIConnections]  WITH CHECK ADD  CONSTRAINT [FK_PV_AIConnections_PV_AIProviders] FOREIGN KEY([providerid])
REFERENCES [dbo].[PV_AIProviders] ([providerid])
GO
ALTER TABLE [dbo].[PV_AIConnections] CHECK CONSTRAINT [FK_PV_AIConnections_PV_AIProviders]
GO
ALTER TABLE [dbo].[PV_AIConnections]  WITH CHECK ADD  CONSTRAINT [FK_PV_AIConnections_PV_Users] FOREIGN KEY([createdby])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_AIConnections] CHECK CONSTRAINT [FK_PV_AIConnections_PV_Users]
GO
ALTER TABLE [dbo].[PV_AIDocumentAnalysis]  WITH CHECK ADD  CONSTRAINT [FK_AIConnectionId_DocumentAnalysis] FOREIGN KEY([AIConnectionId])
REFERENCES [dbo].[PV_AIConnections] ([connectionid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PV_AIDocumentAnalysis] CHECK CONSTRAINT [FK_AIConnectionId_DocumentAnalysis]
GO
ALTER TABLE [dbo].[PV_AIDocumentAnalysis]  WITH CHECK ADD  CONSTRAINT [FK_AnalysisDocument_WorkFlow] FOREIGN KEY([workflowId])
REFERENCES [dbo].[PV_workflows] ([workflowId])
GO
ALTER TABLE [dbo].[PV_AIDocumentAnalysis] CHECK CONSTRAINT [FK_AnalysisDocument_WorkFlow]
GO
ALTER TABLE [dbo].[PV_AIDocumentAnalysis]  WITH CHECK ADD  CONSTRAINT [FK_AnalysisType_AIAnalyDocType] FOREIGN KEY([analysisDocTypeId])
REFERENCES [dbo].[PV_AIAnalysisType] ([analysisTypeId])
GO
ALTER TABLE [dbo].[PV_AIDocumentAnalysis] CHECK CONSTRAINT [FK_AnalysisType_AIAnalyDocType]
GO
ALTER TABLE [dbo].[PV_AIDocumentAnalysis]  WITH CHECK ADD  CONSTRAINT [FK_PV_AIDocumentAnalysis_PV_UserDocuments] FOREIGN KEY([documentid])
REFERENCES [dbo].[PV_Documents] ([documentid])
GO
ALTER TABLE [dbo].[PV_AIDocumentAnalysis] CHECK CONSTRAINT [FK_PV_AIDocumentAnalysis_PV_UserDocuments]
GO
ALTER TABLE [dbo].[PV_AIDocumentAnalysis]  WITH CHECK ADD  CONSTRAINT [FK_PV_AIDocumentAnalysis_PV_Users] FOREIGN KEY([reviewerid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_AIDocumentAnalysis] CHECK CONSTRAINT [FK_PV_AIDocumentAnalysis_PV_Users]
GO
ALTER TABLE [dbo].[PV_AIModels]  WITH CHECK ADD  CONSTRAINT [FK_AiModelTypes_modeltypeId] FOREIGN KEY([modeltypeId])
REFERENCES [dbo].[PV_AIModelTypes] ([AIModelId])
GO
ALTER TABLE [dbo].[PV_AIModels] CHECK CONSTRAINT [FK_AiModelTypes_modeltypeId]
GO
ALTER TABLE [dbo].[PV_AIModels]  WITH CHECK ADD  CONSTRAINT [FK_PV_AIModels_PV_AIProviders] FOREIGN KEY([providerid])
REFERENCES [dbo].[PV_AIProviders] ([providerid])
GO
ALTER TABLE [dbo].[PV_AIModels] CHECK CONSTRAINT [FK_PV_AIModels_PV_AIProviders]
GO
ALTER TABLE [dbo].[PV_AIProposalAnalysis]  WITH CHECK ADD  CONSTRAINT [FK_AIConnectionId_AIProposalAnalysis] FOREIGN KEY([AIConnectionId])
REFERENCES [dbo].[PV_AIConnections] ([connectionid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PV_AIProposalAnalysis] CHECK CONSTRAINT [FK_AIConnectionId_AIProposalAnalysis]
GO
ALTER TABLE [dbo].[PV_AIProposalAnalysis]  WITH CHECK ADD  CONSTRAINT [FK_AIProposalAnalysis_Workflow] FOREIGN KEY([workflowId])
REFERENCES [dbo].[PV_workflows] ([workflowId])
GO
ALTER TABLE [dbo].[PV_AIProposalAnalysis] CHECK CONSTRAINT [FK_AIProposalAnalysis_Workflow]
GO
ALTER TABLE [dbo].[PV_AIProposalAnalysis]  WITH CHECK ADD  CONSTRAINT [FK_AnalysisType_ProposalAIAnaylsisType] FOREIGN KEY([analysistype])
REFERENCES [dbo].[PV_AIAnalysisType] ([analysisTypeId])
GO
ALTER TABLE [dbo].[PV_AIProposalAnalysis] CHECK CONSTRAINT [FK_AnalysisType_ProposalAIAnaylsisType]
GO
ALTER TABLE [dbo].[PV_AIProposalAnalysis]  WITH CHECK ADD  CONSTRAINT [FK_PV_AIProposalAnalysis_PV_Proposals] FOREIGN KEY([proposalid])
REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO
ALTER TABLE [dbo].[PV_AIProposalAnalysis] CHECK CONSTRAINT [FK_PV_AIProposalAnalysis_PV_Proposals]
GO
ALTER TABLE [dbo].[PV_AIProposalAnalysis]  WITH CHECK ADD  CONSTRAINT [FK_PV_AIProposalAnalysis_PV_Users] FOREIGN KEY([reviewerid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_AIProposalAnalysis] CHECK CONSTRAINT [FK_PV_AIProposalAnalysis_PV_Users]
GO
ALTER TABLE [dbo].[PV_AllowedCountries]  WITH CHECK ADD  CONSTRAINT [FK_PV_AllowedCountries_PV_Countries] FOREIGN KEY([countryid])
REFERENCES [dbo].[PV_Countries] ([countryid])
GO
ALTER TABLE [dbo].[PV_AllowedCountries] CHECK CONSTRAINT [FK_PV_AllowedCountries_PV_Countries]
GO
ALTER TABLE [dbo].[PV_AllowedIPs]  WITH CHECK ADD  CONSTRAINT [FK_PV_AllowedIPs_PV_Countries] FOREIGN KEY([addressid])
REFERENCES [dbo].[PV_Addresses] ([addressid])
GO
ALTER TABLE [dbo].[PV_AllowedIPs] CHECK CONSTRAINT [FK_PV_AllowedIPs_PV_Countries]
GO
ALTER TABLE [dbo].[PV_authSession]  WITH CHECK ADD  CONSTRAINT [FK_Authsessions_AuthPlatforms] FOREIGN KEY([authPlatformId])
REFERENCES [dbo].[PV_AuthPlatforms] ([authPlatformId])
GO
ALTER TABLE [dbo].[PV_authSession] CHECK CONSTRAINT [FK_Authsessions_AuthPlatforms]
GO
ALTER TABLE [dbo].[PV_authSession]  WITH CHECK ADD  CONSTRAINT [FK_Users_UserSessions] FOREIGN KEY([userId])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_authSession] CHECK CONSTRAINT [FK_Users_UserSessions]
GO
ALTER TABLE [dbo].[PV_AvailableMethods]  WITH CHECK ADD  CONSTRAINT [FK_PV_AvailableMethods_PV_PaymentMethods] FOREIGN KEY([paymentmethodid])
REFERENCES [dbo].[PV_PaymentMethods] ([paymentmethodid])
GO
ALTER TABLE [dbo].[PV_AvailableMethods] CHECK CONSTRAINT [FK_PV_AvailableMethods_PV_PaymentMethods]
GO
ALTER TABLE [dbo].[PV_AvailableMethods]  WITH CHECK ADD  CONSTRAINT [FK_PV_AvailableMethods_PV_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_AvailableMethods] CHECK CONSTRAINT [FK_PV_AvailableMethods_PV_Users]
GO
ALTER TABLE [dbo].[PV_Balances]  WITH CHECK ADD  CONSTRAINT [FK_Balances_ToOrganizationId] FOREIGN KEY([organizationId])
REFERENCES [dbo].[PV_Organizations] ([organizationid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PV_Balances] CHECK CONSTRAINT [FK_Balances_ToOrganizationId]
GO
ALTER TABLE [dbo].[PV_Balances]  WITH CHECK ADD  CONSTRAINT [FK_PV_Balances_PV_Funds] FOREIGN KEY([fundid])
REFERENCES [dbo].[PV_Funds] ([fundid])
GO
ALTER TABLE [dbo].[PV_Balances] CHECK CONSTRAINT [FK_PV_Balances_PV_Funds]
GO
ALTER TABLE [dbo].[PV_Balances]  WITH CHECK ADD  CONSTRAINT [FK_PV_Balances_PV_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_Balances] CHECK CONSTRAINT [FK_PV_Balances_PV_Users]
GO
ALTER TABLE [dbo].[PV_blockchain]  WITH CHECK ADD  CONSTRAINT [FK_BlockChain_BlockChainParams] FOREIGN KEY([blockchainParamsId])
REFERENCES [dbo].[PV_BlockchainParams] ([blockChainParamsId])
GO
ALTER TABLE [dbo].[PV_blockchain] CHECK CONSTRAINT [FK_BlockChain_BlockChainParams]
GO
ALTER TABLE [dbo].[PV_BlockChainConnections]  WITH CHECK ADD  CONSTRAINT [FK_BlockChainConnection_workflowId] FOREIGN KEY([workflowId])
REFERENCES [dbo].[PV_workflows] ([workflowId])
GO
ALTER TABLE [dbo].[PV_BlockChainConnections] CHECK CONSTRAINT [FK_BlockChainConnection_workflowId]
GO
ALTER TABLE [dbo].[PV_BlockChainConnections]  WITH CHECK ADD  CONSTRAINT [FK_BlockChainConnectionsId_BlockChainId] FOREIGN KEY([blockchainId])
REFERENCES [dbo].[PV_blockchain] ([blockchainId])
GO
ALTER TABLE [dbo].[PV_BlockChainConnections] CHECK CONSTRAINT [FK_BlockChainConnectionsId_BlockChainId]
GO
ALTER TABLE [dbo].[PV_Cities]  WITH CHECK ADD  CONSTRAINT [FK_PV_Cities_PV_States] FOREIGN KEY([stateid])
REFERENCES [dbo].[PV_States] ([stateid])
GO
ALTER TABLE [dbo].[PV_Cities] CHECK CONSTRAINT [FK_PV_Cities_PV_States]
GO
ALTER TABLE [dbo].[PV_Countries]  WITH CHECK ADD  CONSTRAINT [FK_PV_Countries_PV_Currency] FOREIGN KEY([currencyid])
REFERENCES [dbo].[PV_Currency] ([currencyid])
GO
ALTER TABLE [dbo].[PV_Countries] CHECK CONSTRAINT [FK_PV_Countries_PV_Currency]
GO
ALTER TABLE [dbo].[PV_Countries]  WITH CHECK ADD  CONSTRAINT [FK_PV_Countries_PV_Languages] FOREIGN KEY([languageid])
REFERENCES [dbo].[PV_Languages] ([languageid])
GO
ALTER TABLE [dbo].[PV_Countries] CHECK CONSTRAINT [FK_PV_Countries_PV_Languages]
GO
ALTER TABLE [dbo].[PV_CryptoKeys]  WITH CHECK ADD  CONSTRAINT [FK_PV_CryptoKeys_PV_Organizations] FOREIGN KEY([organizationid])
REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO
ALTER TABLE [dbo].[PV_CryptoKeys] CHECK CONSTRAINT [FK_PV_CryptoKeys_PV_Organizations]
GO
ALTER TABLE [dbo].[PV_CryptoKeys]  WITH CHECK ADD  CONSTRAINT [FK_PV_CryptoKeys_PV_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_CryptoKeys] CHECK CONSTRAINT [FK_PV_CryptoKeys_PV_Users]
GO
ALTER TABLE [dbo].[PV_Documents]  WITH CHECK ADD  CONSTRAINT [FK_Documents_DocumentsType] FOREIGN KEY([documentTypeId])
REFERENCES [dbo].[PV_DocumentTypes] ([documentTypeId])
GO
ALTER TABLE [dbo].[PV_Documents] CHECK CONSTRAINT [FK_Documents_DocumentsType]
GO
ALTER TABLE [dbo].[PV_Documents]  WITH CHECK ADD  CONSTRAINT [FK_mediaFileId_mediafiles_Users] FOREIGN KEY([mediafileId])
REFERENCES [dbo].[PV_mediafiles] ([mediafileid])
GO
ALTER TABLE [dbo].[PV_Documents] CHECK CONSTRAINT [FK_mediaFileId_mediafiles_Users]
GO
ALTER TABLE [dbo].[PV_Documents]  WITH CHECK ADD  CONSTRAINT [FK_periodicVerifcationId_periodicUserVerification] FOREIGN KEY([periodicVerificationId])
REFERENCES [dbo].[PV_periodicVerification] ([periodicVerificationId])
GO
ALTER TABLE [dbo].[PV_Documents] CHECK CONSTRAINT [FK_periodicVerifcationId_periodicUserVerification]
GO
ALTER TABLE [dbo].[PV_DocumentSections]  WITH CHECK ADD  CONSTRAINT [FK_DocumentSections_Documents] FOREIGN KEY([documenTypeId])
REFERENCES [dbo].[PV_DocumentTypes] ([documentTypeId])
GO
ALTER TABLE [dbo].[PV_DocumentSections] CHECK CONSTRAINT [FK_DocumentSections_Documents]
GO
ALTER TABLE [dbo].[PV_DocumentTypes]  WITH CHECK ADD  CONSTRAINT [FK_DocumentType_Workflows] FOREIGN KEY([workflowId])
REFERENCES [dbo].[PV_workflows] ([workflowId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PV_DocumentTypes] CHECK CONSTRAINT [FK_DocumentType_Workflows]
GO
ALTER TABLE [dbo].[PV_ExchangeRate]  WITH CHECK ADD  CONSTRAINT [FK_PV_ExchangeRate_PV_Currency_Destiny] FOREIGN KEY([destinyCurrencyId])
REFERENCES [dbo].[PV_Currency] ([currencyid])
GO
ALTER TABLE [dbo].[PV_ExchangeRate] CHECK CONSTRAINT [FK_PV_ExchangeRate_PV_Currency_Destiny]
GO
ALTER TABLE [dbo].[PV_ExchangeRate]  WITH CHECK ADD  CONSTRAINT [FK_PV_ExchangeRate_PV_Currency_Source] FOREIGN KEY([sourceCurrencyid])
REFERENCES [dbo].[PV_Currency] ([currencyid])
GO
ALTER TABLE [dbo].[PV_ExchangeRate] CHECK CONSTRAINT [FK_PV_ExchangeRate_PV_Currency_Source]
GO
ALTER TABLE [dbo].[PV_ExecutionPlans]  WITH CHECK ADD  CONSTRAINT [FK_PV_ExecutionPlans_PV_Proposals] FOREIGN KEY([proposalid])
REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO
ALTER TABLE [dbo].[PV_ExecutionPlans] CHECK CONSTRAINT [FK_PV_ExecutionPlans_PV_Proposals]
GO
ALTER TABLE [dbo].[PV_executionPlanSteps]  WITH CHECK ADD  CONSTRAINT [FK_ExecutionPlanSteps_ExecutionPlan] FOREIGN KEY([executionPlanId])
REFERENCES [dbo].[PV_ExecutionPlans] ([executionplanid])
GO
ALTER TABLE [dbo].[PV_executionPlanSteps] CHECK CONSTRAINT [FK_ExecutionPlanSteps_ExecutionPlan]
GO
ALTER TABLE [dbo].[PV_executionPlanSteps]  WITH CHECK ADD  CONSTRAINT [FK_ExecutionPlanSteps_ExecutionStepType] FOREIGN KEY([stepTypeId])
REFERENCES [dbo].[PV_executionStepType] ([executionStepTypeId])
GO
ALTER TABLE [dbo].[PV_executionPlanSteps] CHECK CONSTRAINT [FK_ExecutionPlanSteps_ExecutionStepType]
GO
ALTER TABLE [dbo].[PV_executionPlanSteps]  WITH CHECK ADD  CONSTRAINT [FK_executionPlanSteps_VotingConfiguration] FOREIGN KEY([votingId])
REFERENCES [dbo].[PV_VotingConfigurations] ([votingconfigid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PV_executionPlanSteps] CHECK CONSTRAINT [FK_executionPlanSteps_VotingConfiguration]
GO
ALTER TABLE [dbo].[PV_FinancialReports]  WITH CHECK ADD  CONSTRAINT [FK_DocumentId_FinancialReports] FOREIGN KEY([documentId])
REFERENCES [dbo].[PV_Documents] ([documentid])
GO
ALTER TABLE [dbo].[PV_FinancialReports] CHECK CONSTRAINT [FK_DocumentId_FinancialReports]
GO
ALTER TABLE [dbo].[PV_FinancialReports]  WITH CHECK ADD  CONSTRAINT [FK_FinancialReports_workflow] FOREIGN KEY([workflowId])
REFERENCES [dbo].[PV_workflows] ([workflowId])
GO
ALTER TABLE [dbo].[PV_FinancialReports] CHECK CONSTRAINT [FK_FinancialReports_workflow]
GO
ALTER TABLE [dbo].[PV_FinancialReports]  WITH CHECK ADD  CONSTRAINT [FK_PV_FinancialReports_PV_Proposals] FOREIGN KEY([proposalid])
REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO
ALTER TABLE [dbo].[PV_FinancialReports] CHECK CONSTRAINT [FK_PV_FinancialReports_PV_Proposals]
GO
ALTER TABLE [dbo].[PV_FinancialReports]  WITH CHECK ADD  CONSTRAINT [FK_PV_FinancialReports_PV_Users] FOREIGN KEY([approvedby])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_FinancialReports] CHECK CONSTRAINT [FK_PV_FinancialReports_PV_Users]
GO
ALTER TABLE [dbo].[PV_IdentityOrganizationValidation]  WITH CHECK ADD  CONSTRAINT [FK_Organization_IdentityValidation] FOREIGN KEY([organizationid])
REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO
ALTER TABLE [dbo].[PV_IdentityOrganizationValidation] CHECK CONSTRAINT [FK_Organization_IdentityValidation]
GO
ALTER TABLE [dbo].[PV_IdentityOrganizationValidation]  WITH CHECK ADD  CONSTRAINT [FK_PV_IdentityOrgValidation_Validation] FOREIGN KEY([validationId])
REFERENCES [dbo].[PV_IdentityValidations] ([validationid])
GO
ALTER TABLE [dbo].[PV_IdentityOrganizationValidation] CHECK CONSTRAINT [FK_PV_IdentityOrgValidation_Validation]
GO
ALTER TABLE [dbo].[PV_IdentityUserValidation]  WITH CHECK ADD  CONSTRAINT [FK_user_PV_IdentityUserValidation] FOREIGN KEY([validationid])
REFERENCES [dbo].[PV_IdentityValidations] ([validationid])
GO
ALTER TABLE [dbo].[PV_IdentityUserValidation] CHECK CONSTRAINT [FK_user_PV_IdentityUserValidation]
GO
ALTER TABLE [dbo].[PV_IdentityUserValidation]  WITH CHECK ADD  CONSTRAINT [FK_UserValidation_user] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_IdentityUserValidation] CHECK CONSTRAINT [FK_UserValidation_user]
GO
ALTER TABLE [dbo].[PV_IdentityValidations]  WITH CHECK ADD  CONSTRAINT [FK_IdentityValidations_Workflow] FOREIGN KEY([workflowId])
REFERENCES [dbo].[PV_workflows] ([workflowId])
GO
ALTER TABLE [dbo].[PV_IdentityValidations] CHECK CONSTRAINT [FK_IdentityValidations_Workflow]
GO
ALTER TABLE [dbo].[PV_InvestmentAgreements]  WITH CHECK ADD  CONSTRAINT [FK_DocumentId_investmentAgreement] FOREIGN KEY([documentId])
REFERENCES [dbo].[PV_Documents] ([documentid])
GO
ALTER TABLE [dbo].[PV_InvestmentAgreements] CHECK CONSTRAINT [FK_DocumentId_investmentAgreement]
GO
ALTER TABLE [dbo].[PV_InvestmentAgreements]  WITH CHECK ADD  CONSTRAINT [FK_InvestmentAgreements_Agreement] FOREIGN KEY([investmentId])
REFERENCES [dbo].[PV_Investments] ([investmentid])
GO
ALTER TABLE [dbo].[PV_InvestmentAgreements] CHECK CONSTRAINT [FK_InvestmentAgreements_Agreement]
GO
ALTER TABLE [dbo].[PV_InvestmentAgreements]  WITH CHECK ADD  CONSTRAINT [FK_PV_InvestmentAgreements_PV_Organizations] FOREIGN KEY([organizationId])
REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO
ALTER TABLE [dbo].[PV_InvestmentAgreements] CHECK CONSTRAINT [FK_PV_InvestmentAgreements_PV_Organizations]
GO
ALTER TABLE [dbo].[PV_InvestmentAgreements]  WITH CHECK ADD  CONSTRAINT [FK_PV_InvestmentAgreements_PV_Users] FOREIGN KEY([userId])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_InvestmentAgreements] CHECK CONSTRAINT [FK_PV_InvestmentAgreements_PV_Users]
GO
ALTER TABLE [dbo].[PV_Investments]  WITH CHECK ADD  CONSTRAINT [FK_PV_Investments_PV_Proposals] FOREIGN KEY([proposalid])
REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO
ALTER TABLE [dbo].[PV_Investments] CHECK CONSTRAINT [FK_PV_Investments_PV_Proposals]
GO
ALTER TABLE [dbo].[PV_investmentSteps]  WITH CHECK ADD  CONSTRAINT [FK_InvesmentStep_PaymentId] FOREIGN KEY([transactionId])
REFERENCES [dbo].[PV_Transactions] ([transactionid])
GO
ALTER TABLE [dbo].[PV_investmentSteps] CHECK CONSTRAINT [FK_InvesmentStep_PaymentId]
GO
ALTER TABLE [dbo].[PV_investmentSteps]  WITH CHECK ADD  CONSTRAINT [FK_InvestmentAgreementID_invesmentStep] FOREIGN KEY([investmentAgreementId])
REFERENCES [dbo].[PV_InvestmentAgreements] ([agreementId])
GO
ALTER TABLE [dbo].[PV_investmentSteps] CHECK CONSTRAINT [FK_InvestmentAgreementID_invesmentStep]
GO
ALTER TABLE [dbo].[PV_Logs]  WITH CHECK ADD  CONSTRAINT [FK_PV_Logs_PV_LogSeverity] FOREIGN KEY([logseverityid])
REFERENCES [dbo].[PV_LogSeverity] ([logseverityid])
GO
ALTER TABLE [dbo].[PV_Logs] CHECK CONSTRAINT [FK_PV_Logs_PV_LogSeverity]
GO
ALTER TABLE [dbo].[PV_Logs]  WITH CHECK ADD  CONSTRAINT [FK_PV_Logs_PV_LogSource] FOREIGN KEY([logsourceid])
REFERENCES [dbo].[PV_LogSource] ([logsourceid])
GO
ALTER TABLE [dbo].[PV_Logs] CHECK CONSTRAINT [FK_PV_Logs_PV_LogSource]
GO
ALTER TABLE [dbo].[PV_Logs]  WITH CHECK ADD  CONSTRAINT [FK_PV_Logs_PV_LogTypes] FOREIGN KEY([logtypeid])
REFERENCES [dbo].[PV_LogTypes] ([logtypeid])
GO
ALTER TABLE [dbo].[PV_Logs] CHECK CONSTRAINT [FK_PV_Logs_PV_LogTypes]
GO
ALTER TABLE [dbo].[PV_mediafiles]  WITH CHECK ADD  CONSTRAINT [FK_mediatypeId_MediaTypes] FOREIGN KEY([mediatypeid])
REFERENCES [dbo].[PV_mediaTypes] ([mediaTypeId])
GO
ALTER TABLE [dbo].[PV_mediafiles] CHECK CONSTRAINT [FK_mediatypeId_MediaTypes]
GO
ALTER TABLE [dbo].[PV_mediafiles]  WITH CHECK ADD  CONSTRAINT [FK_userId_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_mediafiles] CHECK CONSTRAINT [FK_userId_Users]
GO
ALTER TABLE [dbo].[PV_MFA]  WITH CHECK ADD  CONSTRAINT [FK_PV_MFA_PV_MFAMethods] FOREIGN KEY([MFAmethodid])
REFERENCES [dbo].[PV_MFAMethods] ([MFAmethodid])
GO
ALTER TABLE [dbo].[PV_MFA] CHECK CONSTRAINT [FK_PV_MFA_PV_MFAMethods]
GO
ALTER TABLE [dbo].[PV_NotificationSettings]  WITH CHECK ADD  CONSTRAINT [FK_PV_NotificationSettings_PV_NotificationMethods] FOREIGN KEY([notificationmethodid])
REFERENCES [dbo].[PV_NotificationMethods] ([notificationmethodid])
GO
ALTER TABLE [dbo].[PV_NotificationSettings] CHECK CONSTRAINT [FK_PV_NotificationSettings_PV_NotificationMethods]
GO
ALTER TABLE [dbo].[PV_NotificationSettings]  WITH CHECK ADD  CONSTRAINT [FK_PV_NotificationSettings_PV_Organizations] FOREIGN KEY([organizationid])
REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO
ALTER TABLE [dbo].[PV_NotificationSettings] CHECK CONSTRAINT [FK_PV_NotificationSettings_PV_Organizations]
GO
ALTER TABLE [dbo].[PV_NotificationSettings]  WITH CHECK ADD  CONSTRAINT [FK_PV_NotificationSettings_PV_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_NotificationSettings] CHECK CONSTRAINT [FK_PV_NotificationSettings_PV_Users]
GO
ALTER TABLE [dbo].[PV_OrganizationAddresses]  WITH CHECK ADD  CONSTRAINT [FK_PV_OrganizationAddresses_PV_Addresses] FOREIGN KEY([addressid])
REFERENCES [dbo].[PV_Addresses] ([addressid])
GO
ALTER TABLE [dbo].[PV_OrganizationAddresses] CHECK CONSTRAINT [FK_PV_OrganizationAddresses_PV_Addresses]
GO
ALTER TABLE [dbo].[PV_OrganizationAddresses]  WITH CHECK ADD  CONSTRAINT [FK_PV_OrganizationAddresses_PV_Organizations] FOREIGN KEY([organizationid])
REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO
ALTER TABLE [dbo].[PV_OrganizationAddresses] CHECK CONSTRAINT [FK_PV_OrganizationAddresses_PV_Organizations]
GO
ALTER TABLE [dbo].[PV_OrganizationDocuments]  WITH CHECK ADD  CONSTRAINT [FK_OrgDocs_Org] FOREIGN KEY([organizationId])
REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO
ALTER TABLE [dbo].[PV_OrganizationDocuments] CHECK CONSTRAINT [FK_OrgDocs_Org]
GO
ALTER TABLE [dbo].[PV_OrganizationDocuments]  WITH CHECK ADD  CONSTRAINT [FK_OrgDocuments_documents] FOREIGN KEY([documentid])
REFERENCES [dbo].[PV_Documents] ([documentid])
GO
ALTER TABLE [dbo].[PV_OrganizationDocuments] CHECK CONSTRAINT [FK_OrgDocuments_documents]
GO
ALTER TABLE [dbo].[PV_OrganizationPermissions]  WITH CHECK ADD  CONSTRAINT [FK_PV_OrganizationPermissions_PV_Organizations] FOREIGN KEY([organizationid])
REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO
ALTER TABLE [dbo].[PV_OrganizationPermissions] CHECK CONSTRAINT [FK_PV_OrganizationPermissions_PV_Organizations]
GO
ALTER TABLE [dbo].[PV_OrganizationPermissions]  WITH CHECK ADD  CONSTRAINT [FK_PV_OrganizationPermissions_PV_Permissions] FOREIGN KEY([permissionid])
REFERENCES [dbo].[PV_Permissions] ([permissionid])
GO
ALTER TABLE [dbo].[PV_OrganizationPermissions] CHECK CONSTRAINT [FK_PV_OrganizationPermissions_PV_Permissions]
GO
ALTER TABLE [dbo].[PV_OrganizationPerUser]  WITH CHECK ADD  CONSTRAINT [FK_UserOrganizations] FOREIGN KEY([userId])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_OrganizationPerUser] CHECK CONSTRAINT [FK_UserOrganizations]
GO
ALTER TABLE [dbo].[PV_OrganizationPerUser]  WITH CHECK ADD  CONSTRAINT [FK_UserOrganizations_Org] FOREIGN KEY([organizationId])
REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO
ALTER TABLE [dbo].[PV_OrganizationPerUser] CHECK CONSTRAINT [FK_UserOrganizations_Org]
GO
ALTER TABLE [dbo].[PV_OrganizationRoles]  WITH CHECK ADD  CONSTRAINT [FK_PV_OrganizationRoles_PV_Organizations] FOREIGN KEY([organizationid])
REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO
ALTER TABLE [dbo].[PV_OrganizationRoles] CHECK CONSTRAINT [FK_PV_OrganizationRoles_PV_Organizations]
GO
ALTER TABLE [dbo].[PV_OrganizationRoles]  WITH CHECK ADD  CONSTRAINT [FK_PV_OrganizationRoles_PV_Roles] FOREIGN KEY([roleid])
REFERENCES [dbo].[PV_Roles] ([roleid])
GO
ALTER TABLE [dbo].[PV_OrganizationRoles] CHECK CONSTRAINT [FK_PV_OrganizationRoles_PV_Roles]
GO
ALTER TABLE [dbo].[PV_Organizations]  WITH CHECK ADD  CONSTRAINT [FK_PV_Organizations_PV_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_Organizations] CHECK CONSTRAINT [FK_PV_Organizations_PV_Users]
GO
ALTER TABLE [dbo].[PV_OrgMFA]  WITH CHECK ADD  CONSTRAINT [FK_PV_OrgMFA_PV_MFA] FOREIGN KEY([MFAid])
REFERENCES [dbo].[PV_MFA] ([MFAid])
GO
ALTER TABLE [dbo].[PV_OrgMFA] CHECK CONSTRAINT [FK_PV_OrgMFA_PV_MFA]
GO
ALTER TABLE [dbo].[PV_OrgMFA]  WITH CHECK ADD  CONSTRAINT [FK_PV_OrgMFA_PV_Organizations] FOREIGN KEY([organizationid])
REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO
ALTER TABLE [dbo].[PV_OrgMFA] CHECK CONSTRAINT [FK_PV_OrgMFA_PV_Organizations]
GO
ALTER TABLE [dbo].[PV_Payment]  WITH CHECK ADD  CONSTRAINT [FK_PV_Payment_PV_AvailableMethods] FOREIGN KEY([availablemethodid])
REFERENCES [dbo].[PV_AvailableMethods] ([availablemethodid])
GO
ALTER TABLE [dbo].[PV_Payment] CHECK CONSTRAINT [FK_PV_Payment_PV_AvailableMethods]
GO
ALTER TABLE [dbo].[PV_Payment]  WITH CHECK ADD  CONSTRAINT [FK_PV_Payment_PV_Modules] FOREIGN KEY([moduleid])
REFERENCES [dbo].[PV_Modules] ([moduleid])
GO
ALTER TABLE [dbo].[PV_Payment] CHECK CONSTRAINT [FK_PV_Payment_PV_Modules]
GO
ALTER TABLE [dbo].[PV_Payment]  WITH CHECK ADD  CONSTRAINT [FK_PV_Payment_PV_PaymentMethods] FOREIGN KEY([paymentmethodid])
REFERENCES [dbo].[PV_PaymentMethods] ([paymentmethodid])
GO
ALTER TABLE [dbo].[PV_Payment] CHECK CONSTRAINT [FK_PV_Payment_PV_PaymentMethods]
GO
ALTER TABLE [dbo].[PV_Payment]  WITH CHECK ADD  CONSTRAINT [FK_PV_Payment_PV_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_Payment] CHECK CONSTRAINT [FK_PV_Payment_PV_Users]
GO
ALTER TABLE [dbo].[PV_periodicVerification]  WITH CHECK ADD  CONSTRAINT [FK_scheduleId_schedule] FOREIGN KEY([scheduleId])
REFERENCES [dbo].[PV_Schedules] ([scheduleid])
GO
ALTER TABLE [dbo].[PV_periodicVerification] CHECK CONSTRAINT [FK_scheduleId_schedule]
GO
ALTER TABLE [dbo].[PV_Permissions]  WITH CHECK ADD  CONSTRAINT [FK_PV_Permissions_PV_Modules] FOREIGN KEY([moduleid])
REFERENCES [dbo].[PV_Modules] ([moduleid])
GO
ALTER TABLE [dbo].[PV_Permissions] CHECK CONSTRAINT [FK_PV_Permissions_PV_Modules]
GO
ALTER TABLE [dbo].[PV_PopulationSegments]  WITH CHECK ADD  CONSTRAINT [FK_PV_PopulationSegments_PV_SegmentTypes] FOREIGN KEY([segmenttypeid])
REFERENCES [dbo].[PV_SegmentTypes] ([segmenttypeid])
GO
ALTER TABLE [dbo].[PV_PopulationSegments] CHECK CONSTRAINT [FK_PV_PopulationSegments_PV_SegmentTypes]
GO
ALTER TABLE [dbo].[PV_ProjectMonitoring]  WITH CHECK ADD  CONSTRAINT [FK_ExecutionPlanID_ProjectMonitoring] FOREIGN KEY([executionPlanId])
REFERENCES [dbo].[PV_ExecutionPlans] ([executionplanid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PV_ProjectMonitoring] CHECK CONSTRAINT [FK_ExecutionPlanID_ProjectMonitoring]
GO
ALTER TABLE [dbo].[PV_ProjectMonitoring]  WITH CHECK ADD  CONSTRAINT [FK_PV_ProjectMonitoring_PV_Proposals] FOREIGN KEY([proposalid])
REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO
ALTER TABLE [dbo].[PV_ProjectMonitoring] CHECK CONSTRAINT [FK_PV_ProjectMonitoring_PV_Proposals]
GO
ALTER TABLE [dbo].[PV_ProjectMonitoring]  WITH CHECK ADD  CONSTRAINT [FK_PV_ProjectMonitoring_PV_ReportTypes] FOREIGN KEY([reporttypeId])
REFERENCES [dbo].[PV_ReportTypes] ([reportTypeId])
GO
ALTER TABLE [dbo].[PV_ProjectMonitoring] CHECK CONSTRAINT [FK_PV_ProjectMonitoring_PV_ReportTypes]
GO
ALTER TABLE [dbo].[PV_ProjectMonitoring]  WITH CHECK ADD  CONSTRAINT [FK_PV_ProjectMonitoring_PV_Users] FOREIGN KEY([reportedby])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_ProjectMonitoring] CHECK CONSTRAINT [FK_PV_ProjectMonitoring_PV_Users]
GO
ALTER TABLE [dbo].[PV_ProjectMonitoring]  WITH CHECK ADD  CONSTRAINT [FK_PV_ProjectMonitoring_PV_Users_Reviewer] FOREIGN KEY([reviewedby])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_ProjectMonitoring] CHECK CONSTRAINT [FK_PV_ProjectMonitoring_PV_Users_Reviewer]
GO
ALTER TABLE [dbo].[PV_proposalCommentDocuments]  WITH CHECK ADD  CONSTRAINT [FK_proposalCommentId_proposalComments] FOREIGN KEY([commentId])
REFERENCES [dbo].[PV_ProposalComments] ([commentid])
GO
ALTER TABLE [dbo].[PV_proposalCommentDocuments] CHECK CONSTRAINT [FK_proposalCommentId_proposalComments]
GO
ALTER TABLE [dbo].[PV_proposalCommentDocuments]  WITH CHECK ADD  CONSTRAINT [FK_proposalCommentsId_documentId] FOREIGN KEY([documentId])
REFERENCES [dbo].[PV_Documents] ([documentid])
GO
ALTER TABLE [dbo].[PV_proposalCommentDocuments] CHECK CONSTRAINT [FK_proposalCommentsId_documentId]
GO
ALTER TABLE [dbo].[PV_ProposalComments]  WITH CHECK ADD  CONSTRAINT [FK_ProposalStatus_ProposalComments] FOREIGN KEY([statusid])
REFERENCES [dbo].[PV_ProposasalCommentStatus] ([statusCommentId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PV_ProposalComments] CHECK CONSTRAINT [FK_ProposalStatus_ProposalComments]
GO
ALTER TABLE [dbo].[PV_ProposalComments]  WITH CHECK ADD  CONSTRAINT [FK_PV_ProposalComments_PV_Proposals] FOREIGN KEY([proposalid])
REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO
ALTER TABLE [dbo].[PV_ProposalComments] CHECK CONSTRAINT [FK_PV_ProposalComments_PV_Proposals]
GO
ALTER TABLE [dbo].[PV_ProposalComments]  WITH CHECK ADD  CONSTRAINT [FK_PV_ProposalComments_PV_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_ProposalComments] CHECK CONSTRAINT [FK_PV_ProposalComments_PV_Users]
GO
ALTER TABLE [dbo].[PV_ProposalComments]  WITH CHECK ADD  CONSTRAINT [FK_PV_ProposalComments_PV_Users_Reviewer] FOREIGN KEY([reviewedby])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_ProposalComments] CHECK CONSTRAINT [FK_PV_ProposalComments_PV_Users_Reviewer]
GO
ALTER TABLE [dbo].[PV_ProposalDocuments]  WITH CHECK ADD  CONSTRAINT [FK_Documents_ProposalDocuments] FOREIGN KEY([documentId])
REFERENCES [dbo].[PV_Documents] ([documentid])
GO
ALTER TABLE [dbo].[PV_ProposalDocuments] CHECK CONSTRAINT [FK_Documents_ProposalDocuments]
GO
ALTER TABLE [dbo].[PV_ProposalDocuments]  WITH CHECK ADD  CONSTRAINT [FK_PV_ProposalDocuments_PV_Proposals] FOREIGN KEY([proposalid])
REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO
ALTER TABLE [dbo].[PV_ProposalDocuments] CHECK CONSTRAINT [FK_PV_ProposalDocuments_PV_Proposals]
GO
ALTER TABLE [dbo].[PV_ProposalRequirements]  WITH CHECK ADD  CONSTRAINT [FK_PV_ProposalRequirements_PV_ProposalRequirementTypes] FOREIGN KEY([requirementtypeid])
REFERENCES [dbo].[PV_ProposalRequirementTypes] ([requirementtypeid])
GO
ALTER TABLE [dbo].[PV_ProposalRequirements] CHECK CONSTRAINT [FK_PV_ProposalRequirements_PV_ProposalRequirementTypes]
GO
ALTER TABLE [dbo].[PV_ProposalRequirements]  WITH CHECK ADD  CONSTRAINT [FK_PV_ProposalRequirements_PV_ProposalTypes] FOREIGN KEY([proposaltypeid])
REFERENCES [dbo].[PV_ProposalTypes] ([proposaltypeid])
GO
ALTER TABLE [dbo].[PV_ProposalRequirements] CHECK CONSTRAINT [FK_PV_ProposalRequirements_PV_ProposalTypes]
GO
ALTER TABLE [dbo].[PV_ProposalRequirementValues]  WITH CHECK ADD  CONSTRAINT [FK_PV_ProposalRequirementValues_PV_ProposalRequirements] FOREIGN KEY([requirementid])
REFERENCES [dbo].[PV_ProposalRequirements] ([requirementid])
GO
ALTER TABLE [dbo].[PV_ProposalRequirementValues] CHECK CONSTRAINT [FK_PV_ProposalRequirementValues_PV_ProposalRequirements]
GO
ALTER TABLE [dbo].[PV_ProposalRequirementValues]  WITH CHECK ADD  CONSTRAINT [FK_PV_ProposalRequirementValues_PV_Proposals] FOREIGN KEY([proposalid])
REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO
ALTER TABLE [dbo].[PV_ProposalRequirementValues] CHECK CONSTRAINT [FK_PV_ProposalRequirementValues_PV_Proposals]
GO
ALTER TABLE [dbo].[PV_Proposals]  WITH CHECK ADD  CONSTRAINT [FK_PV_Proposals_PV_Organizations] FOREIGN KEY([organizationid])
REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO
ALTER TABLE [dbo].[PV_Proposals] CHECK CONSTRAINT [FK_PV_Proposals_PV_Organizations]
GO
ALTER TABLE [dbo].[PV_Proposals]  WITH CHECK ADD  CONSTRAINT [FK_PV_Proposals_PV_ProposalStatus] FOREIGN KEY([statusid])
REFERENCES [dbo].[PV_ProposalStatus] ([statusid])
GO
ALTER TABLE [dbo].[PV_Proposals] CHECK CONSTRAINT [FK_PV_Proposals_PV_ProposalStatus]
GO
ALTER TABLE [dbo].[PV_Proposals]  WITH CHECK ADD  CONSTRAINT [FK_PV_Proposals_PV_ProposalTypes] FOREIGN KEY([proposaltypeid])
REFERENCES [dbo].[PV_ProposalTypes] ([proposaltypeid])
GO
ALTER TABLE [dbo].[PV_Proposals] CHECK CONSTRAINT [FK_PV_Proposals_PV_ProposalTypes]
GO
ALTER TABLE [dbo].[PV_Proposals]  WITH CHECK ADD  CONSTRAINT [FK_PV_Proposals_PV_Users] FOREIGN KEY([createdby])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_Proposals] CHECK CONSTRAINT [FK_PV_Proposals_PV_Users]
GO
ALTER TABLE [dbo].[PV_ProposalVersions]  WITH CHECK ADD  CONSTRAINT [FK_PV_ProposalVersions_PV_Proposals] FOREIGN KEY([proposalid])
REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO
ALTER TABLE [dbo].[PV_ProposalVersions] CHECK CONSTRAINT [FK_PV_ProposalVersions_PV_Proposals]
GO
ALTER TABLE [dbo].[PV_ProposalVersions]  WITH CHECK ADD  CONSTRAINT [FK_PV_ProposalVersions_PV_Users] FOREIGN KEY([createdby])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_ProposalVersions] CHECK CONSTRAINT [FK_PV_ProposalVersions_PV_Users]
GO
ALTER TABLE [dbo].[PV_PublicVote]  WITH CHECK ADD  CONSTRAINT [FK_PublicVote_Tousers] FOREIGN KEY([userId])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_PublicVote] CHECK CONSTRAINT [FK_PublicVote_Tousers]
GO
ALTER TABLE [dbo].[PV_PublicVote]  WITH CHECK ADD  CONSTRAINT [FK_PublicVote_Votes] FOREIGN KEY([voteId])
REFERENCES [dbo].[PV_Votes] ([voteid])
GO
ALTER TABLE [dbo].[PV_PublicVote] CHECK CONSTRAINT [FK_PublicVote_Votes]
GO
ALTER TABLE [dbo].[PV_RolePermissions]  WITH CHECK ADD  CONSTRAINT [FK_PV_RolePermissions_PV_Permissions] FOREIGN KEY([permissionid])
REFERENCES [dbo].[PV_Permissions] ([permissionid])
GO
ALTER TABLE [dbo].[PV_RolePermissions] CHECK CONSTRAINT [FK_PV_RolePermissions_PV_Permissions]
GO
ALTER TABLE [dbo].[PV_RolePermissions]  WITH CHECK ADD  CONSTRAINT [FK_PV_RolePermissions_PV_Roles] FOREIGN KEY([roleid])
REFERENCES [dbo].[PV_Roles] ([roleid])
GO
ALTER TABLE [dbo].[PV_RolePermissions] CHECK CONSTRAINT [FK_PV_RolePermissions_PV_Roles]
GO
ALTER TABLE [dbo].[PV_Schedules]  WITH CHECK ADD  CONSTRAINT [FK_PV_Schedules_PV_EndType] FOREIGN KEY([endtypeid])
REFERENCES [dbo].[PV_EndType] ([endtypeid])
GO
ALTER TABLE [dbo].[PV_Schedules] CHECK CONSTRAINT [FK_PV_Schedules_PV_EndType]
GO
ALTER TABLE [dbo].[PV_Schedules]  WITH CHECK ADD  CONSTRAINT [FK_PV_Schedules_PV_RecurrencyType] FOREIGN KEY([recurrencytypeid])
REFERENCES [dbo].[PV_RecurrencyType] ([recurrencytypeid])
GO
ALTER TABLE [dbo].[PV_Schedules] CHECK CONSTRAINT [FK_PV_Schedules_PV_RecurrencyType]
GO
ALTER TABLE [dbo].[PV_States]  WITH CHECK ADD  CONSTRAINT [FK_PV_States_PV_Countries] FOREIGN KEY([countryid])
REFERENCES [dbo].[PV_Countries] ([countryid])
GO
ALTER TABLE [dbo].[PV_States] CHECK CONSTRAINT [FK_PV_States_PV_Countries]
GO
ALTER TABLE [dbo].[PV_Transactions]  WITH CHECK ADD  CONSTRAINT [FK_PV_Transactions_PV_Balances] FOREIGN KEY([balanceid])
REFERENCES [dbo].[PV_Balances] ([balanceid])
GO
ALTER TABLE [dbo].[PV_Transactions] CHECK CONSTRAINT [FK_PV_Transactions_PV_Balances]
GO
ALTER TABLE [dbo].[PV_Transactions]  WITH CHECK ADD  CONSTRAINT [FK_PV_Transactions_PV_Currency] FOREIGN KEY([currencyid])
REFERENCES [dbo].[PV_Currency] ([currencyid])
GO
ALTER TABLE [dbo].[PV_Transactions] CHECK CONSTRAINT [FK_PV_Transactions_PV_Currency]
GO
ALTER TABLE [dbo].[PV_Transactions]  WITH CHECK ADD  CONSTRAINT [FK_PV_Transactions_PV_ExchangeRate] FOREIGN KEY([exchangerateid])
REFERENCES [dbo].[PV_ExchangeRate] ([exchangeRateid])
GO
ALTER TABLE [dbo].[PV_Transactions] CHECK CONSTRAINT [FK_PV_Transactions_PV_ExchangeRate]
GO
ALTER TABLE [dbo].[PV_Transactions]  WITH CHECK ADD  CONSTRAINT [FK_PV_Transactions_PV_Funds] FOREIGN KEY([fundid])
REFERENCES [dbo].[PV_Funds] ([fundid])
GO
ALTER TABLE [dbo].[PV_Transactions] CHECK CONSTRAINT [FK_PV_Transactions_PV_Funds]
GO
ALTER TABLE [dbo].[PV_Transactions]  WITH CHECK ADD  CONSTRAINT [FK_PV_Transactions_PV_Payment] FOREIGN KEY([paymentid])
REFERENCES [dbo].[PV_Payment] ([paymentid])
GO
ALTER TABLE [dbo].[PV_Transactions] CHECK CONSTRAINT [FK_PV_Transactions_PV_Payment]
GO
ALTER TABLE [dbo].[PV_Transactions]  WITH CHECK ADD  CONSTRAINT [FK_PV_Transactions_PV_Schedules] FOREIGN KEY([scheduleid])
REFERENCES [dbo].[PV_Schedules] ([scheduleid])
GO
ALTER TABLE [dbo].[PV_Transactions] CHECK CONSTRAINT [FK_PV_Transactions_PV_Schedules]
GO
ALTER TABLE [dbo].[PV_Transactions]  WITH CHECK ADD  CONSTRAINT [FK_PV_Transactions_PV_TransSubTypes] FOREIGN KEY([transsubtypeid])
REFERENCES [dbo].[PV_TransSubTypes] ([transsubtypeid])
GO
ALTER TABLE [dbo].[PV_Transactions] CHECK CONSTRAINT [FK_PV_Transactions_PV_TransSubTypes]
GO
ALTER TABLE [dbo].[PV_Transactions]  WITH CHECK ADD  CONSTRAINT [FK_PV_Transactions_PV_TransType] FOREIGN KEY([transtypeid])
REFERENCES [dbo].[PV_TransType] ([transtypeid])
GO
ALTER TABLE [dbo].[PV_Transactions] CHECK CONSTRAINT [FK_PV_Transactions_PV_TransType]
GO
ALTER TABLE [dbo].[PV_Translation]  WITH CHECK ADD  CONSTRAINT [FK_PV_Translation_PV_Languages] FOREIGN KEY([languageid])
REFERENCES [dbo].[PV_Languages] ([languageid])
GO
ALTER TABLE [dbo].[PV_Translation] CHECK CONSTRAINT [FK_PV_Translation_PV_Languages]
GO
ALTER TABLE [dbo].[PV_Translation]  WITH CHECK ADD  CONSTRAINT [FK_PV_Translation_PV_Modules] FOREIGN KEY([moduleid])
REFERENCES [dbo].[PV_Modules] ([moduleid])
GO
ALTER TABLE [dbo].[PV_Translation] CHECK CONSTRAINT [FK_PV_Translation_PV_Modules]
GO
ALTER TABLE [dbo].[PV_TypesPerOrganization]  WITH CHECK ADD  CONSTRAINT [FK_Organizatio_TypesPerOrganization] FOREIGN KEY([organizationId])
REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO
ALTER TABLE [dbo].[PV_TypesPerOrganization] CHECK CONSTRAINT [FK_Organizatio_TypesPerOrganization]
GO
ALTER TABLE [dbo].[PV_TypesPerOrganization]  WITH CHECK ADD  CONSTRAINT [FK_OrganizatioNTypes_TypesPerOrganization] FOREIGN KEY([OrganizationTypeId])
REFERENCES [dbo].[PV_OrganizationTypes] ([organizationTypeId])
GO
ALTER TABLE [dbo].[PV_TypesPerOrganization] CHECK CONSTRAINT [FK_OrganizatioNTypes_TypesPerOrganization]
GO
ALTER TABLE [dbo].[PV_UserAddresses]  WITH CHECK ADD  CONSTRAINT [FK_PV_UserAddresses_PV_Addresses] FOREIGN KEY([addressid])
REFERENCES [dbo].[PV_Addresses] ([addressid])
GO
ALTER TABLE [dbo].[PV_UserAddresses] CHECK CONSTRAINT [FK_PV_UserAddresses_PV_Addresses]
GO
ALTER TABLE [dbo].[PV_UserAddresses]  WITH CHECK ADD  CONSTRAINT [FK_PV_UserAddresses_PV_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_UserAddresses] CHECK CONSTRAINT [FK_PV_UserAddresses_PV_Users]
GO
ALTER TABLE [dbo].[PV_UserDocuments]  WITH CHECK ADD  CONSTRAINT [FK_UserDocuments_Documents] FOREIGN KEY([documentid])
REFERENCES [dbo].[PV_Documents] ([documentid])
GO
ALTER TABLE [dbo].[PV_UserDocuments] CHECK CONSTRAINT [FK_UserDocuments_Documents]
GO
ALTER TABLE [dbo].[PV_UserDocuments]  WITH CHECK ADD  CONSTRAINT [FK_UserDocuments_Users] FOREIGN KEY([userId])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_UserDocuments] CHECK CONSTRAINT [FK_UserDocuments_Users]
GO
ALTER TABLE [dbo].[PV_UserMFA]  WITH CHECK ADD  CONSTRAINT [FK_PV_UserMFA_PV_MFA] FOREIGN KEY([MFAid])
REFERENCES [dbo].[PV_MFA] ([MFAid])
GO
ALTER TABLE [dbo].[PV_UserMFA] CHECK CONSTRAINT [FK_PV_UserMFA_PV_MFA]
GO
ALTER TABLE [dbo].[PV_UserMFA]  WITH CHECK ADD  CONSTRAINT [FK_PV_UserMFA_PV_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_UserMFA] CHECK CONSTRAINT [FK_PV_UserMFA_PV_Users]
GO
ALTER TABLE [dbo].[PV_UserPermissions]  WITH CHECK ADD  CONSTRAINT [FK_PV_UserPermissions_PV_Permissions] FOREIGN KEY([permissionid])
REFERENCES [dbo].[PV_Permissions] ([permissionid])
GO
ALTER TABLE [dbo].[PV_UserPermissions] CHECK CONSTRAINT [FK_PV_UserPermissions_PV_Permissions]
GO
ALTER TABLE [dbo].[PV_UserPermissions]  WITH CHECK ADD  CONSTRAINT [FK_PV_UserPermissions_PV_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_UserPermissions] CHECK CONSTRAINT [FK_PV_UserPermissions_PV_Users]
GO
ALTER TABLE [dbo].[PV_UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_PV_UserRoles_PV_Roles] FOREIGN KEY([roleid])
REFERENCES [dbo].[PV_Roles] ([roleid])
GO
ALTER TABLE [dbo].[PV_UserRoles] CHECK CONSTRAINT [FK_PV_UserRoles_PV_Roles]
GO
ALTER TABLE [dbo].[PV_UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_PV_UserRoles_PV_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_UserRoles] CHECK CONSTRAINT [FK_PV_UserRoles_PV_Users]
GO
ALTER TABLE [dbo].[PV_Users]  WITH CHECK ADD  CONSTRAINT [FK_genderId_Users] FOREIGN KEY([genderId])
REFERENCES [dbo].[PV_Genders] ([genderId])
GO
ALTER TABLE [dbo].[PV_Users] CHECK CONSTRAINT [FK_genderId_Users]
GO
ALTER TABLE [dbo].[PV_Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_UserStatus] FOREIGN KEY([userStatusId])
REFERENCES [dbo].[PV_UserStatus] ([userStatusId])
GO
ALTER TABLE [dbo].[PV_Users] CHECK CONSTRAINT [FK_Users_UserStatus]
GO
ALTER TABLE [dbo].[PV_UserSegments]  WITH CHECK ADD  CONSTRAINT [FK_PV_UserSegments_PV_PopulationSegments] FOREIGN KEY([segmentid])
REFERENCES [dbo].[PV_PopulationSegments] ([segmentid])
GO
ALTER TABLE [dbo].[PV_UserSegments] CHECK CONSTRAINT [FK_PV_UserSegments_PV_PopulationSegments]
GO
ALTER TABLE [dbo].[PV_UserSegments]  WITH CHECK ADD  CONSTRAINT [FK_PV_UserSegments_PV_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_UserSegments] CHECK CONSTRAINT [FK_PV_UserSegments_PV_Users]
GO
ALTER TABLE [dbo].[PV_ValidationRules]  WITH CHECK ADD  CONSTRAINT [FK_PV_ValidationRules_PV_ProposalTypes] FOREIGN KEY([proposaltypeid])
REFERENCES [dbo].[PV_ProposalTypes] ([proposaltypeid])
GO
ALTER TABLE [dbo].[PV_ValidationRules] CHECK CONSTRAINT [FK_PV_ValidationRules_PV_ProposalTypes]
GO
ALTER TABLE [dbo].[PV_VoteResults]  WITH CHECK ADD  CONSTRAINT [FK_PV_VoteResults_PV_VotingConfigurations] FOREIGN KEY([votingconfigid])
REFERENCES [dbo].[PV_VotingConfigurations] ([votingconfigid])
GO
ALTER TABLE [dbo].[PV_VoteResults] CHECK CONSTRAINT [FK_PV_VoteResults_PV_VotingConfigurations]
GO
ALTER TABLE [dbo].[PV_VoteResults]  WITH CHECK ADD  CONSTRAINT [FK_PV_VoteResults_PV_VotingOptions] FOREIGN KEY([optionid])
REFERENCES [dbo].[PV_VotingOptions] ([optionid])
GO
ALTER TABLE [dbo].[PV_VoteResults] CHECK CONSTRAINT [FK_PV_VoteResults_PV_VotingOptions]
GO
ALTER TABLE [dbo].[PV_VoterRegistry]  WITH CHECK ADD  CONSTRAINT [FK_PV_VoterRegistry_PV_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_VoterRegistry] CHECK CONSTRAINT [FK_PV_VoterRegistry_PV_Users]
GO
ALTER TABLE [dbo].[PV_VoterRegistry]  WITH CHECK ADD  CONSTRAINT [FK_PV_VoterRegistry_PV_VotingConfigurations] FOREIGN KEY([votingconfigid])
REFERENCES [dbo].[PV_VotingConfigurations] ([votingconfigid])
GO
ALTER TABLE [dbo].[PV_VoterRegistry] CHECK CONSTRAINT [FK_PV_VoterRegistry_PV_VotingConfigurations]
GO
ALTER TABLE [dbo].[PV_Votes]  WITH CHECK ADD  CONSTRAINT [FK_PV_Votes_PV_VotingConfigurations] FOREIGN KEY([votingconfigid])
REFERENCES [dbo].[PV_VotingConfigurations] ([votingconfigid])
GO
ALTER TABLE [dbo].[PV_Votes] CHECK CONSTRAINT [FK_PV_Votes_PV_VotingConfigurations]
GO
ALTER TABLE [dbo].[PV_Votes]  WITH CHECK ADD  CONSTRAINT [FK_Votes_blockchain] FOREIGN KEY([blockchainId])
REFERENCES [dbo].[PV_blockchain] ([blockchainId])
GO
ALTER TABLE [dbo].[PV_Votes] CHECK CONSTRAINT [FK_Votes_blockchain]
GO
ALTER TABLE [dbo].[PV_VotingConfigurations]  WITH CHECK ADD  CONSTRAINT [FK_PV_VotingConfigurations_PV_NotificationMethods] FOREIGN KEY([notificationmethodid])
REFERENCES [dbo].[PV_NotificationMethods] ([notificationmethodid])
GO
ALTER TABLE [dbo].[PV_VotingConfigurations] CHECK CONSTRAINT [FK_PV_VotingConfigurations_PV_NotificationMethods]
GO
ALTER TABLE [dbo].[PV_VotingConfigurations]  WITH CHECK ADD  CONSTRAINT [FK_PV_VotingConfigurations_PV_Proposals] FOREIGN KEY([proposalid])
REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO
ALTER TABLE [dbo].[PV_VotingConfigurations] CHECK CONSTRAINT [FK_PV_VotingConfigurations_PV_Proposals]
GO
ALTER TABLE [dbo].[PV_VotingConfigurations]  WITH CHECK ADD  CONSTRAINT [FK_PV_VotingConfigurations_PV_Users] FOREIGN KEY([userid])
REFERENCES [dbo].[PV_Users] ([userid])
GO
ALTER TABLE [dbo].[PV_VotingConfigurations] CHECK CONSTRAINT [FK_PV_VotingConfigurations_PV_Users]
GO
ALTER TABLE [dbo].[PV_VotingConfigurations]  WITH CHECK ADD  CONSTRAINT [FK_PV_VotingConfigurations_PV_VotingStates] FOREIGN KEY([statusid])
REFERENCES [dbo].[PV_VotingStatus] ([statusid])
GO
ALTER TABLE [dbo].[PV_VotingConfigurations] CHECK CONSTRAINT [FK_PV_VotingConfigurations_PV_VotingStates]
GO
ALTER TABLE [dbo].[PV_VotingConfigurations]  WITH CHECK ADD  CONSTRAINT [FK_VontingConfigurations_VotingTypes] FOREIGN KEY([votingtypeId])
REFERENCES [dbo].[PV_VotingTypes] ([votingTypeId])
GO
ALTER TABLE [dbo].[PV_VotingConfigurations] CHECK CONSTRAINT [FK_VontingConfigurations_VotingTypes]
GO
ALTER TABLE [dbo].[PV_VotingMetrics]  WITH CHECK ADD  CONSTRAINT [FK_PV_VotingMetrics_PV_PopulationSegments] FOREIGN KEY([segmentid])
REFERENCES [dbo].[PV_PopulationSegments] ([segmentid])
GO
ALTER TABLE [dbo].[PV_VotingMetrics] CHECK CONSTRAINT [FK_PV_VotingMetrics_PV_PopulationSegments]
GO
ALTER TABLE [dbo].[PV_VotingMetrics]  WITH CHECK ADD  CONSTRAINT [FK_PV_VotingMetrics_PV_VotingConfigurations] FOREIGN KEY([votingconfigid])
REFERENCES [dbo].[PV_VotingConfigurations] ([votingconfigid])
GO
ALTER TABLE [dbo].[PV_VotingMetrics] CHECK CONSTRAINT [FK_PV_VotingMetrics_PV_VotingConfigurations]
GO
ALTER TABLE [dbo].[PV_VotingMetrics]  WITH CHECK ADD  CONSTRAINT [FK_VotingMetric_VotingMetricType] FOREIGN KEY([metrictypeId])
REFERENCES [dbo].[PV_VotingMetricsType] ([VotingMetricTypeId])
GO
ALTER TABLE [dbo].[PV_VotingMetrics] CHECK CONSTRAINT [FK_VotingMetric_VotingMetricType]
GO
ALTER TABLE [dbo].[PV_VotingOptions]  WITH CHECK ADD  CONSTRAINT [FK_PV_VotingOptions_PV_VotingConfigurations] FOREIGN KEY([votingconfigid])
REFERENCES [dbo].[PV_VotingConfigurations] ([votingconfigid])
GO
ALTER TABLE [dbo].[PV_VotingOptions] CHECK CONSTRAINT [FK_PV_VotingOptions_PV_VotingConfigurations]
GO
ALTER TABLE [dbo].[PV_VotingOptions]  WITH CHECK ADD  CONSTRAINT [FK_Questions_VotingOptions] FOREIGN KEY([questionId])
REFERENCES [dbo].[PV_VotingQuestions] ([questionId])
GO
ALTER TABLE [dbo].[PV_VotingOptions] CHECK CONSTRAINT [FK_Questions_VotingOptions]
GO
ALTER TABLE [dbo].[PV_VotingOptions]  WITH CHECK ADD  CONSTRAINT [FK_VotingOptions_MediaFileId] FOREIGN KEY([mediafileId])
REFERENCES [dbo].[PV_mediafiles] ([mediafileid])
GO
ALTER TABLE [dbo].[PV_VotingOptions] CHECK CONSTRAINT [FK_VotingOptions_MediaFileId]
GO
ALTER TABLE [dbo].[PV_VotingQuestions]  WITH CHECK ADD  CONSTRAINT [FK_QuestionType_Questions] FOREIGN KEY([questionTypeId])
REFERENCES [dbo].[PV_questionType] ([questionTypeId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PV_VotingQuestions] CHECK CONSTRAINT [FK_QuestionType_Questions]
GO
ALTER TABLE [dbo].[PV_VotingTargetSegments]  WITH CHECK ADD  CONSTRAINT [FK_PV_VotingTargetSegments_PV_PopulationSegments] FOREIGN KEY([segmentid])
REFERENCES [dbo].[PV_PopulationSegments] ([segmentid])
GO
ALTER TABLE [dbo].[PV_VotingTargetSegments] CHECK CONSTRAINT [FK_PV_VotingTargetSegments_PV_PopulationSegments]
GO
ALTER TABLE [dbo].[PV_VotingTargetSegments]  WITH CHECK ADD  CONSTRAINT [FK_PV_VotingTargetSegments_PV_VotingConfigurations] FOREIGN KEY([votingconfigid])
REFERENCES [dbo].[PV_VotingConfigurations] ([votingconfigid])
GO
ALTER TABLE [dbo].[PV_VotingTargetSegments] CHECK CONSTRAINT [FK_PV_VotingTargetSegments_PV_VotingConfigurations]
GO
ALTER TABLE [dbo].[PV_workflows]  WITH CHECK ADD  CONSTRAINT [FK_workflows_workflowTypes] FOREIGN KEY([workflowTypeId])
REFERENCES [dbo].[PV_workflowsType] ([workflowTypeId])
GO
ALTER TABLE [dbo].[PV_workflows] CHECK CONSTRAINT [FK_workflows_workflowTypes]
GO
USE [master]
GO
ALTER DATABASE [VotoPuraVida] SET  READ_WRITE 
GO
