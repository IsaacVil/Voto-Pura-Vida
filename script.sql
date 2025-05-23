USE [master]
GO
/****** Object:  Database [VotoPuraVida]    Script Date: 5/20/2025 10:59:00 PM ******/
CREATE DATABASE [VotoPuraVida]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'VotoPuraVida', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\VotoPuraVida.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'VotoPuraVida_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\VotoPuraVida_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
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
/****** Object:  Table [dbo].[PV_Addresses]    Script Date: 5/20/2025 10:59:00 PM ******/
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
 CONSTRAINT [PK_PV_Addresses] PRIMARY KEY CLUSTERED 
(
	[addressid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_AvailableMethods]    Script Date: 5/20/2025 10:59:00 PM ******/
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
 CONSTRAINT [PK_PV_AvailableMethods] PRIMARY KEY CLUSTERED 
(
	[availablemethodid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Balances]    Script Date: 5/20/2025 10:59:00 PM ******/
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
	[userid] [int] NOT NULL,
	[fundid] [int] NOT NULL,
 CONSTRAINT [PK_PV_Balances] PRIMARY KEY CLUSTERED 
(
	[balanceid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Cities]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Cities](
	[cityid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NOT NULL,
	[stateid] [int] NOT NULL,
 CONSTRAINT [PK_PV_Cities] PRIMARY KEY CLUSTERED 
(
	[cityid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Countries]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Countries](
	[countryid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NOT NULL,
	[languageid] [int] NOT NULL,
	[currencyid] [int] NOT NULL,
 CONSTRAINT [PK_PV_Countries] PRIMARY KEY CLUSTERED 
(
	[countryid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_CryptoKeys]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_CryptoKeys](
	[keyid] [int] IDENTITY(1,1) NOT NULL,
	[publickey] [varbinary](max) NOT NULL,
	[privatekey] [varbinary](max) NOT NULL,
	[createdAt] [datetime] NOT NULL,
	[userid] [int] NULL,
	[organizationid] [int] NULL,
	[expirationdate] [datetime] NOT NULL,
	[status] [varchar](20) NOT NULL,
 CONSTRAINT [PK_PV_CryptoKeys] PRIMARY KEY CLUSTERED 
(
	[keyid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Currency]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Currency](
	[currencyid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](25) NOT NULL,
	[symbol] [varchar](5) NOT NULL,
	[acronym] [varchar](5) NOT NULL,
 CONSTRAINT [PK_PV_Currency] PRIMARY KEY CLUSTERED 
(
	[currencyid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_EndType]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_EndType](
	[endtypeid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NOT NULL,
 CONSTRAINT [PK_PV_EndType] PRIMARY KEY CLUSTERED 
(
	[endtypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_ExchangeRate]    Script Date: 5/20/2025 10:59:00 PM ******/
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
 CONSTRAINT [PK_PV_ExchangeRate] PRIMARY KEY CLUSTERED 
(
	[exchangeRateid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Funds]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Funds](
	[fundid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NULL,
 CONSTRAINT [PK_PV_Funds] PRIMARY KEY CLUSTERED 
(
	[fundid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Languages]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Languages](
	[languageid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NOT NULL,
	[culture] [varchar](20) NOT NULL,
 CONSTRAINT [PK_PV_Languages] PRIMARY KEY CLUSTERED 
(
	[languageid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Logs]    Script Date: 5/20/2025 10:59:00 PM ******/
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
 CONSTRAINT [PK_PV_Logs] PRIMARY KEY CLUSTERED 
(
	[logid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_LogSeverity]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_LogSeverity](
	[logseverityid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](45) NOT NULL,
 CONSTRAINT [PK_PV_LogSeverity] PRIMARY KEY CLUSTERED 
(
	[logseverityid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_LogSource]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_LogSource](
	[logsourceid] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_PV_LogSource] PRIMARY KEY CLUSTERED 
(
	[logsourceid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_LogTypes]    Script Date: 5/20/2025 10:59:00 PM ******/
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
 CONSTRAINT [PK_PV_LogTypes] PRIMARY KEY CLUSTERED 
(
	[logtypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_MFA]    Script Date: 5/20/2025 10:59:00 PM ******/
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
 CONSTRAINT [PK_PV_MFA] PRIMARY KEY CLUSTERED 
(
	[MFAid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_MFAMethods]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_MFAMethods](
	[MFAmethodid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](100) NOT NULL,
	[description] [varchar](200) NOT NULL,
	[requiressecret] [bit] NOT NULL,
 CONSTRAINT [PK_PV_MFAMethods] PRIMARY KEY CLUSTERED 
(
	[MFAmethodid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Modules]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Modules](
	[moduleid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](40) NOT NULL,
 CONSTRAINT [PK_PV_Modules] PRIMARY KEY CLUSTERED 
(
	[moduleid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Organizations]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Organizations](
	[organizationid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](200) NULL,
	[representativeid] [int] NOT NULL,
	[createdAt] [datetime] NOT NULL,
 CONSTRAINT [PK_PV_Organizations] PRIMARY KEY CLUSTERED 
(
	[organizationid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_OrgMFA]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_OrgMFA](
	[orgmfaid] [int] IDENTITY(1,1) NOT NULL,
	[organizationid] [int] NOT NULL,
	[MFAid] [int] NOT NULL,
 CONSTRAINT [PK_PV_OrgMFA] PRIMARY KEY CLUSTERED 
(
	[orgmfaid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Payment]    Script Date: 5/20/2025 10:59:00 PM ******/
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
 CONSTRAINT [PK_PV_Payment] PRIMARY KEY CLUSTERED 
(
	[paymentid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_PaymentMethods]    Script Date: 5/20/2025 10:59:00 PM ******/
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
 CONSTRAINT [PK_PV_PaymentMethods] PRIMARY KEY CLUSTERED 
(
	[paymentmethodid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Permissions]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Permissions](
	[permissionid] [int] IDENTITY(1,1) NOT NULL,
	[description] [varchar](100) NOT NULL,
	[code] [varchar](10) NOT NULL,
	[moduleid] [int] NOT NULL,
 CONSTRAINT [PK_PV_Permissions] PRIMARY KEY CLUSTERED 
(
	[permissionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_RecurrencyType]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_RecurrencyType](
	[recurrencytypeid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NOT NULL,
 CONSTRAINT [PK_PV_RecurrencyType] PRIMARY KEY CLUSTERED 
(
	[recurrencytypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_RolePermissions]    Script Date: 5/20/2025 10:59:00 PM ******/
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
 CONSTRAINT [PK_PV_RolePermissions] PRIMARY KEY CLUSTERED 
(
	[rolepermissionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Roles]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Roles](
	[roleid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NOT NULL,
 CONSTRAINT [PK_PV_Roles] PRIMARY KEY CLUSTERED 
(
	[roleid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Schedules]    Script Date: 5/20/2025 10:59:00 PM ******/
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
 CONSTRAINT [PK_PV_Schedules] PRIMARY KEY CLUSTERED 
(
	[scheduleid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_States]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_States](
	[stateid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NOT NULL,
	[countryid] [int] NOT NULL,
 CONSTRAINT [PK_PV_States] PRIMARY KEY CLUSTERED 
(
	[stateid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Transactions]    Script Date: 5/20/2025 10:59:00 PM ******/
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
 CONSTRAINT [PK_PV_Transactions] PRIMARY KEY CLUSTERED 
(
	[transactionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Translation]    Script Date: 5/20/2025 10:59:00 PM ******/
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
 CONSTRAINT [PK_PV_Translation] PRIMARY KEY CLUSTERED 
(
	[translationid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_TransSubTypes]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_TransSubTypes](
	[transsubtypeid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NOT NULL,
 CONSTRAINT [PK_PV_TransSubTypes] PRIMARY KEY CLUSTERED 
(
	[transsubtypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_TransType]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_TransType](
	[transtypeid] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](30) NOT NULL,
 CONSTRAINT [PK_PV_TransType] PRIMARY KEY CLUSTERED 
(
	[transtypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_UserMFA]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_UserMFA](
	[usermfaid] [int] IDENTITY(1,1) NOT NULL,
	[userid] [int] NOT NULL,
	[MFAid] [int] NOT NULL,
 CONSTRAINT [PK_PV_UserMFA] PRIMARY KEY CLUSTERED 
(
	[usermfaid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_UserPermissions]    Script Date: 5/20/2025 10:59:00 PM ******/
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
 CONSTRAINT [PK_PV_UserPermissions] PRIMARY KEY CLUSTERED 
(
	[userpermissionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_UserRoles]    Script Date: 5/20/2025 10:59:00 PM ******/
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
 CONSTRAINT [PK_PV_UserRoles] PRIMARY KEY CLUSTERED 
(
	[userroleid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PV_Users]    Script Date: 5/20/2025 10:59:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PV_Users](
	[userid] [int] IDENTITY(1,1) NOT NULL,
	[password] [varbinary](256) NOT NULL,
	[email] [varchar](120) NOT NULL,
	[firstname] [varchar](50) NOT NULL,
	[lastname] [varchar](50) NOT NULL,
	[birthdate] [datetime] NOT NULL,
	[createdAt] [datetime] NOT NULL,
	[gender] [varchar](30) NOT NULL,
	[lastupdate] [datetime] NOT NULL,
	[dni] [bigint] NOT NULL,
 CONSTRAINT [PK_PV_Users] PRIMARY KEY CLUSTERED 
(
	[userid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PV_Addresses]  WITH CHECK ADD  CONSTRAINT [address-city] FOREIGN KEY([cityid])
REFERENCES [dbo].[PV_Cities] ([cityid])
GO
ALTER TABLE [dbo].[PV_Addresses] CHECK CONSTRAINT [address-city]
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
ALTER TABLE [dbo].[PV_Cities]  WITH CHECK ADD  CONSTRAINT [cities-states] FOREIGN KEY([stateid])
REFERENCES [dbo].[PV_States] ([stateid])
GO
ALTER TABLE [dbo].[PV_Cities] CHECK CONSTRAINT [cities-states]
GO
ALTER TABLE [dbo].[PV_Countries]  WITH CHECK ADD  CONSTRAINT [currency-countries] FOREIGN KEY([currencyid])
REFERENCES [dbo].[PV_Currency] ([currencyid])
GO
ALTER TABLE [dbo].[PV_Countries] CHECK CONSTRAINT [currency-countries]
GO
ALTER TABLE [dbo].[PV_Countries]  WITH CHECK ADD  CONSTRAINT [language-countries] FOREIGN KEY([languageid])
REFERENCES [dbo].[PV_Languages] ([languageid])
GO
ALTER TABLE [dbo].[PV_Countries] CHECK CONSTRAINT [language-countries]
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
ALTER TABLE [dbo].[PV_ExchangeRate]  WITH CHECK ADD  CONSTRAINT [currency-exchangeRate-destiny] FOREIGN KEY([destinyCurrencyId])
REFERENCES [dbo].[PV_Currency] ([currencyid])
GO
ALTER TABLE [dbo].[PV_ExchangeRate] CHECK CONSTRAINT [currency-exchangeRate-destiny]
GO
ALTER TABLE [dbo].[PV_ExchangeRate]  WITH CHECK ADD  CONSTRAINT [currency-exhangerate-source] FOREIGN KEY([sourceCurrencyid])
REFERENCES [dbo].[PV_Currency] ([currencyid])
GO
ALTER TABLE [dbo].[PV_ExchangeRate] CHECK CONSTRAINT [currency-exhangerate-source]
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
ALTER TABLE [dbo].[PV_MFA]  WITH CHECK ADD  CONSTRAINT [FK_PV_MFA_PV_MFAMethods] FOREIGN KEY([MFAmethodid])
REFERENCES [dbo].[PV_MFAMethods] ([MFAmethodid])
GO
ALTER TABLE [dbo].[PV_MFA] CHECK CONSTRAINT [FK_PV_MFA_PV_MFAMethods]
GO
ALTER TABLE [dbo].[PV_Organizations]  WITH CHECK ADD  CONSTRAINT [FK_PV_Organizations_PV_Users] FOREIGN KEY([representativeid])
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
ALTER TABLE [dbo].[PV_Permissions]  WITH CHECK ADD  CONSTRAINT [FK_PV_Permissions_PV_Modules] FOREIGN KEY([moduleid])
REFERENCES [dbo].[PV_Modules] ([moduleid])
GO
ALTER TABLE [dbo].[PV_Permissions] CHECK CONSTRAINT [FK_PV_Permissions_PV_Modules]
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
ALTER TABLE [dbo].[PV_States]  WITH CHECK ADD  CONSTRAINT [states-country] FOREIGN KEY([countryid])
REFERENCES [dbo].[PV_Countries] ([countryid])
GO
ALTER TABLE [dbo].[PV_States] CHECK CONSTRAINT [states-country]
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
USE [master]
GO
ALTER DATABASE [VotoPuraVida] SET  READ_WRITE 
GO
