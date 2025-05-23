USE [master]
GO
/****** Object:  Database [VotoPuraVida]    Script Date: 5/22/2025 10:59:00 PM ******/
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** MASTER DATA TABLES ******/

-- Languages
CREATE TABLE [dbo].[PV_Languages](
    [languageid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](60) NOT NULL,
    [culture] [varchar](20) NOT NULL,
 CONSTRAINT [PK_PV_Languages] PRIMARY KEY CLUSTERED ([languageid] ASC)
) ON [PRIMARY]
GO

-- Currency
CREATE TABLE [dbo].[PV_Currency](
    [currencyid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](25) NOT NULL,
    [symbol] [varchar](5) NOT NULL,
    [acronym] [varchar](5) NOT NULL,
 CONSTRAINT [PK_PV_Currency] PRIMARY KEY CLUSTERED ([currencyid] ASC)
) ON [PRIMARY]
GO

-- Countries
CREATE TABLE [dbo].[PV_Countries](
    [countryid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](60) NOT NULL,
    [languageid] [int] NOT NULL,
    [currencyid] [int] NOT NULL,
 CONSTRAINT [PK_PV_Countries] PRIMARY KEY CLUSTERED ([countryid] ASC)
) ON [PRIMARY]
GO

-- States
CREATE TABLE [dbo].[PV_States](
    [stateid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](60) NOT NULL,
    [countryid] [int] NOT NULL,
 CONSTRAINT [PK_PV_States] PRIMARY KEY CLUSTERED ([stateid] ASC)
) ON [PRIMARY]
GO

-- Cities
CREATE TABLE [dbo].[PV_Cities](
    [cityid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](60) NOT NULL,
    [stateid] [int] NOT NULL,
 CONSTRAINT [PK_PV_Cities] PRIMARY KEY CLUSTERED ([cityid] ASC)
) ON [PRIMARY]
GO

-- Addresses
CREATE TABLE [dbo].[PV_Addresses](
    [addressid] [int] IDENTITY(1,1) NOT NULL,
    [line1] [varchar](200) NOT NULL,
    [line2] [varchar](200) NULL,
    [zipcode] [varchar](8) NOT NULL,
    [geoposition] [geometry] NOT NULL,
    [cityid] [int] NOT NULL,
 CONSTRAINT [PK_PV_Addresses] PRIMARY KEY CLUSTERED ([addressid] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Modules
CREATE TABLE [dbo].[PV_Modules](
    [moduleid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](40) NOT NULL,
 CONSTRAINT [PK_PV_Modules] PRIMARY KEY CLUSTERED ([moduleid] ASC)
) ON [PRIMARY]
GO

-- Roles
CREATE TABLE [dbo].[PV_Roles](
    [roleid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](30) NOT NULL,
 CONSTRAINT [PK_PV_Roles] PRIMARY KEY CLUSTERED ([roleid] ASC)
) ON [PRIMARY]
GO

-- Permissions
CREATE TABLE [dbo].[PV_Permissions](
    [permissionid] [int] IDENTITY(1,1) NOT NULL,
    [description] [varchar](100) NOT NULL,
    [code] [varchar](10) NOT NULL,
    [moduleid] [int] NOT NULL,
 CONSTRAINT [PK_PV_Permissions] PRIMARY KEY CLUSTERED ([permissionid] ASC)
) ON [PRIMARY]
GO

/****** USER MANAGEMENT TABLES ******/

-- Users
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
 CONSTRAINT [PK_PV_Users] PRIMARY KEY CLUSTERED ([userid] ASC)
) ON [PRIMARY]
GO

-- Organizations
CREATE TABLE [dbo].[PV_Organizations](
    [organizationid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](50) NOT NULL,
    [description] [varchar](200) NULL,
    [representativeid] [int] NOT NULL,
    [createdAt] [datetime] NOT NULL,
 CONSTRAINT [PK_PV_Organizations] PRIMARY KEY CLUSTERED ([organizationid] ASC)
) ON [PRIMARY]
GO

-- MFA Methods
CREATE TABLE [dbo].[PV_MFAMethods](
    [MFAmethodid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](100) NOT NULL,
    [description] [varchar](200) NOT NULL,
    [requiressecret] [bit] NOT NULL,
 CONSTRAINT [PK_PV_MFAMethods] PRIMARY KEY CLUSTERED ([MFAmethodid] ASC)
) ON [PRIMARY]
GO

-- MFA
CREATE TABLE [dbo].[PV_MFA](
    [MFAid] [int] IDENTITY(1,1) NOT NULL,
    [MFAmethodid] [int] NOT NULL,
    [MFA_secret] [varbinary](256) NOT NULL,
    [createdAt] [datetime] NOT NULL,
    [enabled] [bit] NOT NULL,
 CONSTRAINT [PK_PV_MFA] PRIMARY KEY CLUSTERED ([MFAid] ASC)
) ON [PRIMARY]
GO

-- User MFA
CREATE TABLE [dbo].[PV_UserMFA](
    [usermfaid] [int] IDENTITY(1,1) NOT NULL,
    [userid] [int] NOT NULL,
    [MFAid] [int] NOT NULL,
 CONSTRAINT [PK_PV_UserMFA] PRIMARY KEY CLUSTERED ([usermfaid] ASC)
) ON [PRIMARY]
GO

-- Organization MFA
CREATE TABLE [dbo].[PV_OrgMFA](
    [orgmfaid] [int] IDENTITY(1,1) NOT NULL,
    [organizationid] [int] NOT NULL,
    [MFAid] [int] NOT NULL,
 CONSTRAINT [PK_PV_OrgMFA] PRIMARY KEY CLUSTERED ([orgmfaid] ASC)
) ON [PRIMARY]
GO

-- Crypto Keys
CREATE TABLE [dbo].[PV_CryptoKeys](
    [keyid] [int] IDENTITY(1,1) NOT NULL,
    [publickey] [varbinary](max) NOT NULL,
    [privatekey] [varbinary](max) NOT NULL,
    [createdAt] [datetime] NOT NULL,
    [userid] [int] NULL,
    [organizationid] [int] NULL,
    [expirationdate] [datetime] NOT NULL,
    [status] [varchar](20) NOT NULL,
 CONSTRAINT [PK_PV_CryptoKeys] PRIMARY KEY CLUSTERED ([keyid] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- User Roles
CREATE TABLE [dbo].[PV_UserRoles](
    [userroleid] [int] IDENTITY(1,1) NOT NULL,
    [userid] [int] NULL,
    [roleid] [int] NULL,
    [lastupdate] [datetime] NULL,
    [checksum] [varbinary](250) NULL,
    [enabled] [bit] NOT NULL,
    [deleted] [bit] NOT NULL,
 CONSTRAINT [PK_PV_UserRoles] PRIMARY KEY CLUSTERED ([userroleid] ASC)
) ON [PRIMARY]
GO

-- Role Permissions
CREATE TABLE [dbo].[PV_RolePermissions](
    [rolepermissionid] [int] IDENTITY(1,1) NOT NULL,
    [enabled] [bit] NOT NULL,
    [deleted] [bit] NOT NULL,
    [lastupdate] [datetime] NOT NULL,
    [checksum] [varbinary](250) NOT NULL,
    [roleid] [int] NOT NULL,
    [permissionid] [int] NOT NULL,
 CONSTRAINT [PK_PV_RolePermissions] PRIMARY KEY CLUSTERED ([rolepermissionid] ASC)
) ON [PRIMARY]
GO

-- User Permissions
CREATE TABLE [dbo].[PV_UserPermissions](
    [userpermissionid] [int] IDENTITY(1,1) NOT NULL,
    [enabled] [bit] NOT NULL,
    [deleted] [bit] NOT NULL,
    [lastupdate] [datetime] NOT NULL,
    [checksum] [varbinary](250) NOT NULL,
    [userid] [int] NOT NULL,
    [permissionid] [int] NOT NULL,
 CONSTRAINT [PK_PV_UserPermissions] PRIMARY KEY CLUSTERED ([userpermissionid] ASC)
) ON [PRIMARY]
GO

-- User Addresses
CREATE TABLE [dbo].[PV_UserAddresses](
    [useraddressid] [int] IDENTITY(1,1) NOT NULL,
    [userid] [int] NOT NULL,
    [addressid] [int] NOT NULL,
    [addresstype] [varchar](20) NOT NULL DEFAULT 'Primary',
    [isactive] [bit] NOT NULL DEFAULT 1,
    [assigneddate] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [PK_PV_UserAddresses] PRIMARY KEY CLUSTERED ([useraddressid] ASC)
) ON [PRIMARY]
GO

-- Organization Addresses
CREATE TABLE [dbo].[PV_OrganizationAddresses](
    [orgaddressid] [int] IDENTITY(1,1) NOT NULL,
    [organizationid] [int] NOT NULL,
    [addressid] [int] NOT NULL,
    [addresstype] [varchar](20) NOT NULL DEFAULT 'Headquarters',
    [isactive] [bit] NOT NULL DEFAULT 1,
    [assigneddate] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [PK_PV_OrganizationAddresses] PRIMARY KEY CLUSTERED ([orgaddressid] ASC)
) ON [PRIMARY]
GO

-- Organization Roles
CREATE TABLE [dbo].[PV_OrganizationRoles](
    [orgrolemappingid] [int] IDENTITY(1,1) NOT NULL,
    [organizationid] [int] NOT NULL,
    [roleid] [int] NOT NULL,
    [enabled] [bit] NOT NULL DEFAULT 1,
    [deleted] [bit] NOT NULL DEFAULT 0,
    [assigneddate] [datetime] NOT NULL DEFAULT GETDATE(),
    [lastupdate] [datetime] NOT NULL DEFAULT GETDATE(),
    [checksum] [varbinary](250) NOT NULL,
 CONSTRAINT [PK_PV_OrganizationRoles] PRIMARY KEY CLUSTERED ([orgrolemappingid] ASC)
) ON [PRIMARY]
GO

-- Organization Permissions
CREATE TABLE [dbo].[PV_OrganizationPermissions](
    [orgpermissionid] [int] IDENTITY(1,1) NOT NULL,
    [organizationid] [int] NOT NULL,
    [permissionid] [int] NOT NULL,
    [enabled] [bit] NOT NULL DEFAULT 1,
    [deleted] [bit] NOT NULL DEFAULT 0,
    [assigneddate] [datetime] NOT NULL DEFAULT GETDATE(),
    [lastupdate] [datetime] NOT NULL DEFAULT GETDATE(),
    [checksum] [varbinary](250) NOT NULL,
 CONSTRAINT [PK_PV_OrganizationPermissions] PRIMARY KEY CLUSTERED ([orgpermissionid] ASC)
) ON [PRIMARY]
GO

/****** FOREIGN REGISTRATION TABLES ******/

-- Allowed Countries
CREATE TABLE [dbo].[PV_AllowedCountries](
    [allowedcountryid] [int] IDENTITY(1,1) NOT NULL,
    [countryid] [int] NOT NULL,
    [isallowed] [bit] NOT NULL DEFAULT 1,
    [createddate] [datetime] NOT NULL DEFAULT GETDATE(),
    [lastmodified] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [PK_PV_AllowedCountries] PRIMARY KEY CLUSTERED ([allowedcountryid] ASC)
) ON [PRIMARY]
GO

-- IP Whitelist
CREATE TABLE [dbo].[PV_AllowedIPs](
    [allowedipid] [int] IDENTITY(1,1) NOT NULL,
    [ipaddress] [varchar](45) NOT NULL,
    [ipmask] [varchar](45) NULL,
    [countryid] [int] NULL,
    [isallowed] [bit] NOT NULL DEFAULT 1,
    [description] [varchar](200) NULL,
    [createddate] [datetime] NOT NULL DEFAULT GETDATE(),
    [lastmodified] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [PK_PV_AllowedIPs] PRIMARY KEY CLUSTERED ([allowedipid] ASC)
) ON [PRIMARY]
GO

-- Identity Validations
CREATE TABLE [dbo].[PV_IdentityValidations](
    [validationid] [int] IDENTITY(1,1) NOT NULL,
    [userid] [int] NOT NULL,
    [validationdate] [datetime] NOT NULL DEFAULT GETDATE(),
    [validationtype] [varchar](30) NOT NULL,
    [validationresult] [varchar](20) NOT NULL,
    [validatedby] [int] NULL,
    [aivalidationresult] [text] NULL,
    [validationhash] [varbinary](256) NOT NULL,
 CONSTRAINT [PK_PV_IdentityValidations] PRIMARY KEY CLUSTERED ([validationid] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- User Documents
CREATE TABLE [dbo].[PV_UserDocuments](
    [documentid] [int] IDENTITY(1,1) NOT NULL,
    [userid] [int] NOT NULL,
    [documenttype] [varchar](50) NOT NULL,
    [filename] [varchar](255) NOT NULL,
    [filepath] [varchar](500) NOT NULL,
    [filesize] [bigint] NOT NULL,
    [mimetype] [varchar](100) NOT NULL,
    [uploadeddate] [datetime] NOT NULL DEFAULT GETDATE(),
    [documenthash] [varbinary](256) NOT NULL,
    [aivalidationstatus] [varchar](20) NOT NULL DEFAULT 'Pending',
    [aivalidationresult] [text] NULL,
    [humanvalidationrequired] [bit] NOT NULL DEFAULT 0,
 CONSTRAINT [PK_PV_UserDocuments] PRIMARY KEY CLUSTERED ([documentid] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Multi-validator Approvals
CREATE TABLE [dbo].[PV_MultiValidatorApprovals](
    [approvalid] [int] IDENTITY(1,1) NOT NULL,
    [userid] [int] NULL,
    [proposalid] [int] NULL,
    [requesttype] [varchar](30) NOT NULL,
    [requiredvalidators] [int] NOT NULL DEFAULT 2,
    [approvedvalidators] [int] NOT NULL DEFAULT 0,
    [status] [varchar](20) NOT NULL DEFAULT 'Pending',
    [createddate] [datetime] NOT NULL DEFAULT GETDATE(),
    [completeddate] [datetime] NULL,
 CONSTRAINT [PK_PV_MultiValidatorApprovals] PRIMARY KEY CLUSTERED ([approvalid] ASC)
) ON [PRIMARY]
GO

-- Validator Approvals
CREATE TABLE [dbo].[PV_ValidatorApprovals](
    [validatorapprovalid] [int] IDENTITY(1,1) NOT NULL,
    [multivalidatorapprovalid] [int] NOT NULL,
    [validatorid] [int] NOT NULL,
    [approved] [bit] NOT NULL,
    [comments] [text] NULL,
    [approvaldate] [datetime] NOT NULL DEFAULT GETDATE(),
    [digitalsignature] [varbinary](512) NOT NULL,
 CONSTRAINT [PK_PV_ValidatorApprovals] PRIMARY KEY CLUSTERED ([validatorapprovalid] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** VOTING SYSTEM TABLES ******/

-- Segment Types
CREATE TABLE [dbo].[PV_SegmentTypes](
    [segmenttypeid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](30) NOT NULL,
    [description] [varchar](100) NULL,
 CONSTRAINT [PK_PV_SegmentTypes] PRIMARY KEY CLUSTERED ([segmenttypeid] ASC)
) ON [PRIMARY]
GO

-- Population Segments
CREATE TABLE [dbo].[PV_PopulationSegments](
    [segmentid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](60) NOT NULL,
    [description] [varchar](200) NULL,
    [segmenttypeid] [int] NOT NULL,
 CONSTRAINT [PK_PV_PopulationSegments] PRIMARY KEY CLUSTERED ([segmentid] ASC)
) ON [PRIMARY]
GO

-- User Segments
CREATE TABLE [dbo].[PV_UserSegments](
    [usersegmentid] [int] IDENTITY(1,1) NOT NULL,
    [userid] [int] NOT NULL,
    [segmentid] [int] NOT NULL,
    [assigneddate] [datetime] NOT NULL DEFAULT GETDATE(),
    [isactive] [bit] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_PV_UserSegments] PRIMARY KEY CLUSTERED ([usersegmentid] ASC)
) ON [PRIMARY]
GO

-- Proposal Types
CREATE TABLE [dbo].[PV_ProposalTypes](
    [proposaltypeid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](50) NOT NULL,
    [description] [varchar](200) NULL,
    [requiresgovernmentapproval] [bit] NOT NULL DEFAULT 0,
    [requiresvalidatorapproval] [bit] NOT NULL DEFAULT 0,
    [validatorcount] [int] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_PV_ProposalTypes] PRIMARY KEY CLUSTERED ([proposaltypeid] ASC)
) ON [PRIMARY]
GO

-- Proposal Status
CREATE TABLE [dbo].[PV_ProposalStatus](
    [statusid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](30) NOT NULL,
    [description] [varchar](100) NULL,
 CONSTRAINT [PK_PV_ProposalStatus] PRIMARY KEY CLUSTERED ([statusid] ASC)
) ON [PRIMARY]
GO

-- Proposals (UNIFIED - with nullable user/org and proposalcontent)
CREATE TABLE [dbo].[PV_Proposals](
    [proposalid] [int] IDENTITY(1,1) NOT NULL,
    [title] [varchar](200) NOT NULL,
    [description] [text] NOT NULL,
    [proposalcontent] [text] NOT NULL,
    [budget] [decimal](18,2) NULL,
    [createdby] [int] NULL,
    [createdon] [datetime] NOT NULL DEFAULT GETDATE(),
    [lastmodified] [datetime] NOT NULL DEFAULT GETDATE(),
    [proposaltypeid] [int] NOT NULL,
    [statusid] [int] NOT NULL,
    [organizationid] [int] NULL,
    [checksum] [varbinary](256) NOT NULL,
    [version] [int] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_PV_Proposals] PRIMARY KEY CLUSTERED ([proposalid] ASC),
 CONSTRAINT [CK_PV_Proposals_UserOrOrg] CHECK (([createdby] IS NOT NULL) OR ([organizationid] IS NOT NULL))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Proposal Versions
CREATE TABLE [dbo].[PV_ProposalVersions](
    [versionid] [int] IDENTITY(1,1) NOT NULL,
    [proposalid] [int] NOT NULL,
    [versionnumber] [int] NOT NULL,
    [title] [varchar](200) NOT NULL,
    [description] [text] NOT NULL,
    [proposalcontent] [text] NOT NULL,
    [budget] [decimal](18,2) NULL,
    [createdby] [int] NOT NULL,
    [createdon] [datetime] NOT NULL DEFAULT GETDATE(),
    [isactive] [bit] NOT NULL DEFAULT 0,
    [changecomments] [text] NULL,
    [checksum] [varbinary](256) NOT NULL,
 CONSTRAINT [PK_PV_ProposalVersions] PRIMARY KEY CLUSTERED ([versionid] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Proposal Requirement Types
CREATE TABLE [dbo].[PV_ProposalRequirementTypes](
    [requirementtypeid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](50) NOT NULL,
    [description] [varchar](200) NULL,
 CONSTRAINT [PK_PV_ProposalRequirementTypes] PRIMARY KEY CLUSTERED ([requirementtypeid] ASC)
) ON [PRIMARY]
GO

-- Proposal Requirements
CREATE TABLE [dbo].[PV_ProposalRequirements](
    [requirementid] [int] IDENTITY(1,1) NOT NULL,
    [proposaltypeid] [int] NOT NULL,
    [requirementtypeid] [int] NOT NULL,
    [fieldname] [varchar](50) NOT NULL,
    [isrequired] [bit] NOT NULL DEFAULT 1,
    [minlength] [int] NULL,
    [maxlength] [int] NULL,
    [datatype] [varchar](20) NOT NULL DEFAULT 'Text',
    [validationrule] [varchar](500) NULL,
 CONSTRAINT [PK_PV_ProposalRequirements] PRIMARY KEY CLUSTERED ([requirementid] ASC)
) ON [PRIMARY]
GO

-- Proposal Requirement Values
CREATE TABLE [dbo].[PV_ProposalRequirementValues](
    [valuekey] [int] IDENTITY(1,1) NOT NULL,
    [proposalid] [int] NOT NULL,
    [requirementid] [int] NOT NULL,
    [textvalue] [text] NULL,
    [numbervalue] [decimal](18,4) NULL,
    [datevalue] [datetime] NULL,
    [filevalue] [varchar](500) NULL,
 CONSTRAINT [PK_PV_ProposalRequirementValues] PRIMARY KEY CLUSTERED ([valuekey] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Validation Rules
CREATE TABLE [dbo].[PV_ValidationRules](
    [validationruleid] [int] IDENTITY(1,1) NOT NULL,
    [proposaltypeid] [int] NOT NULL,
    [fieldname] [varchar](50) NOT NULL,
    [ruletype] [varchar](30) NOT NULL,
    [rulevalue] [varchar](500) NULL,
    [errormessage] [varchar](200) NOT NULL,
 CONSTRAINT [PK_PV_ValidationRules] PRIMARY KEY CLUSTERED ([validationruleid] ASC)
) ON [PRIMARY]
GO

-- Proposal Documents
CREATE TABLE [dbo].[PV_ProposalDocuments](
    [documentid] [int] IDENTITY(1,1) NOT NULL,
    [proposalid] [int] NOT NULL,
    [filename] [varchar](255) NOT NULL,
    [filepath] [varchar](500) NOT NULL,
    [filesize] [bigint] NOT NULL,
    [mimetype] [varchar](100) NOT NULL,
    [uploadeddate] [datetime] NOT NULL DEFAULT GETDATE(),
    [documenthash] [varbinary](256) NOT NULL,
 CONSTRAINT [PK_PV_ProposalDocuments] PRIMARY KEY CLUSTERED ([documentid] ASC)
) ON [PRIMARY]
GO

-- Notification Methods
CREATE TABLE [dbo].[PV_NotificationMethods](
    [notificationmethodid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](50) NOT NULL,
    [description] [varchar](200) NULL,
 CONSTRAINT [PK_PV_NotificationMethods] PRIMARY KEY CLUSTERED ([notificationmethodid] ASC)
) ON [PRIMARY]
GO

-- Notification Settings
CREATE TABLE [dbo].[PV_NotificationSettings](
    [notificationsettingid] [int] IDENTITY(1,1) NOT NULL,
    [userid] [int] NULL,
    [organizationid] [int] NULL,
    [notificationmethodid] [int] NOT NULL,
    [isenabled] [bit] NOT NULL DEFAULT 1,
    [starttime] [time] NULL,
    [endtime] [time] NULL,
    [alloweddays] [varchar](20) NULL,
    [ipwhitelist] [varchar](500) NULL,
    [frequency] [varchar](20) NOT NULL DEFAULT 'Immediate',
    [lastnotification] [datetime] NULL,
    [createddate] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [PK_PV_NotificationSettings] PRIMARY KEY CLUSTERED ([notificationsettingid] ASC)
) ON [PRIMARY]
GO

-- Voting States
CREATE TABLE [dbo].[PV_VotingStates](
    [stateid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](30) NOT NULL,
    [description] [varchar](100) NULL,
 CONSTRAINT [PK_PV_VotingStates] PRIMARY KEY CLUSTERED ([stateid] ASC)
) ON [PRIMARY]
GO

-- Voting Configurations (UNIFIED with state management)
CREATE TABLE [dbo].[PV_VotingConfigurations](
    [votingconfigid] [int] IDENTITY(1,1) NOT NULL,
    [proposalid] [int] NOT NULL,
    [startdate] [datetime] NOT NULL,
    [enddate] [datetime] NOT NULL,
    [votingtype] [varchar](20) NOT NULL,
    [allowweightedvotes] [bit] NOT NULL DEFAULT 0,
    [requiresallvoters] [bit] NOT NULL DEFAULT 0,
    [notificationmethodid] [int] NULL,
    [configuredby] [int] NOT NULL,
    [configureddate] [datetime] NOT NULL DEFAULT GETDATE(),
    [stateid] [int] NOT NULL DEFAULT 1,
    [publisheddate] [datetime] NULL,
    [finalizeddate] [datetime] NULL,
 CONSTRAINT [PK_PV_VotingConfigurations] PRIMARY KEY CLUSTERED ([votingconfigid] ASC)
) ON [PRIMARY]
GO

-- Voting Options
CREATE TABLE [dbo].[PV_VotingOptions](
    [optionid] [int] IDENTITY(1,1) NOT NULL,
    [votingconfigid] [int] NOT NULL,
    [optiontext] [varchar](200) NOT NULL,
    [optionorder] [int] NOT NULL,
 CONSTRAINT [PK_PV_VotingOptions] PRIMARY KEY CLUSTERED ([optionid] ASC)
) ON [PRIMARY]
GO

-- Eligible Voters (segment-based approach)
CREATE TABLE [dbo].[PV_EligibleVoters](
    [eligibleid] [int] IDENTITY(1,1) NOT NULL,
    [votingconfigid] [int] NOT NULL,
    [segmentid] [int] NOT NULL,
    [voteweight] [decimal](5,2) NOT NULL DEFAULT 1.0,
    [assigneddate] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [PK_PV_EligibleVoters] PRIMARY KEY CLUSTERED ([eligibleid] ASC)
) ON [PRIMARY]
GO

-- Voting Target Segments
CREATE TABLE [dbo].[PV_VotingTargetSegments](
    [targetsegmentid] [int] IDENTITY(1,1) NOT NULL,
    [votingconfigid] [int] NOT NULL,
    [segmentid] [int] NOT NULL,
    [voteweight] [decimal](5,2) NOT NULL DEFAULT 1.0,
    [assigneddate] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [PK_PV_VotingTargetSegments] PRIMARY KEY CLUSTERED ([targetsegmentid] ASC)
) ON [PRIMARY]
GO

-- Voter Registry (for anonymous voting)
CREATE TABLE [dbo].[PV_VoterRegistry](
    [registryid] [int] IDENTITY(1,1) NOT NULL,
    [votingconfigid] [int] NOT NULL,
    [userid] [int] NOT NULL,
    [votercommitment] [varbinary](256) NOT NULL,
    [registrationdate] [datetime] NOT NULL DEFAULT GETDATE(),
    [hasVoted] [bit] NOT NULL DEFAULT 0,
 CONSTRAINT [PK_PV_VoterRegistry] PRIMARY KEY CLUSTERED ([registryid] ASC),
 CONSTRAINT [UK_PV_VoterRegistry_User] UNIQUE ([votingconfigid], [userid])
) ON [PRIMARY]
GO

-- Votes (Web3 anonymous approach)
CREATE TABLE [dbo].[PV_Votes](
    [voteid] [int] IDENTITY(1,1) NOT NULL,
    [votingconfigid] [int] NOT NULL,
    [votercommitment] [varbinary](256) NOT NULL,
    [encryptedvote] [varbinary](512) NOT NULL,
    [votehash] [varbinary](256) NOT NULL,
    [nullifierhash] [varbinary](256) NOT NULL,
    [votedate] [datetime] NOT NULL DEFAULT GETDATE(),
    [blockhash] [varbinary](256) NOT NULL,
    [merkleproof] [varbinary](1024) NULL,
 CONSTRAINT [PK_PV_Votes] PRIMARY KEY CLUSTERED ([voteid] ASC),
 CONSTRAINT [UK_PV_Votes_Nullifier] UNIQUE ([votingconfigid], [nullifierhash])
) ON [PRIMARY]
GO

-- Vote Results
CREATE TABLE [dbo].[PV_VoteResults](
    [resultid] [int] IDENTITY(1,1) NOT NULL,
    [votingconfigid] [int] NOT NULL,
    [optionid] [int] NOT NULL,
    [votecount] [int] NOT NULL DEFAULT 0,
    [weightedcount] [decimal](10,2) NOT NULL DEFAULT 0,
    [lastupdated] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [PK_PV_VoteResults] PRIMARY KEY CLUSTERED ([resultid] ASC)
) ON [PRIMARY]
GO

-- Voting Metrics
CREATE TABLE [dbo].[PV_VotingMetrics](
    [metricid] [int] IDENTITY(1,1) NOT NULL,
    [votingconfigid] [int] NOT NULL,
    [metrictype] [varchar](30) NOT NULL,
    [metricname] [varchar](50) NOT NULL,
    [metricvalue] [decimal](18,4) NOT NULL,
    [stringvalue] [varchar](200) NULL,
    [segmentid] [int] NULL,
    [calculateddate] [datetime] NOT NULL DEFAULT GETDATE(),
    [isactive] [bit] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_PV_VotingMetrics] PRIMARY KEY CLUSTERED ([metricid] ASC)
) ON [PRIMARY]
GO

-- Proposal Comments
CREATE TABLE [dbo].[PV_ProposalComments](
    [commentid] [int] IDENTITY(1,1) NOT NULL,
    [proposalid] [int] NOT NULL,
    [userid] [int] NOT NULL,
    [comment] [text] NOT NULL,
    [commentdate] [datetime] NOT NULL DEFAULT GETDATE(),
    [statusid] [int] NOT NULL,
    [reviewedby] [int] NULL,
    [reviewdate] [datetime] NULL,
 CONSTRAINT [PK_PV_ProposalComments] PRIMARY KEY CLUSTERED ([commentid] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** CROWDFUNDING MODULE TABLES ******/

-- Validator Groups
CREATE TABLE [dbo].[PV_ValidatorGroups](
    [validatorgroupid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](100) NOT NULL,
    [description] [varchar](300) NULL,
    [grouptype] [varchar](30) NOT NULL,
    [fees] [decimal](5,2) NULL,
    [equitypercentage] [decimal](5,2) NULL,
    [organizationid] [int] NOT NULL,
    [isactive] [bit] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_PV_ValidatorGroups] PRIMARY KEY CLUSTERED ([validatorgroupid] ASC)
) ON [PRIMARY]
GO

-- Proposal Validations
CREATE TABLE [dbo].[PV_ProposalValidations](
    [validationid] [int] IDENTITY(1,1) NOT NULL,
    [proposalid] [int] NOT NULL,
    [validatorgroupid] [int] NULL,
    [validatedby] [int] NOT NULL,
    [validationdate] [datetime] NOT NULL DEFAULT GETDATE(),
    [validationresult] [varchar](20) NOT NULL,
    [comments] [text] NULL,
    [validationhash] [varbinary](256) NOT NULL,
 CONSTRAINT [PK_PV_ProposalValidations] PRIMARY KEY CLUSTERED ([validationid] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Government Approvals
CREATE TABLE [dbo].[PV_GovernmentApprovals](
    [approvalid] [int] IDENTITY(1,1) NOT NULL,
    [proposalid] [int] NOT NULL,
    [approvedby] [int] NOT NULL,
    [approvaldate] [datetime] NOT NULL DEFAULT GETDATE(),
    [approvaltype] [varchar](50) NOT NULL,
    [benefits] [text] NULL,
    [conditions] [text] NULL,
    [employeerequirement] [int] NULL,
    [locationrequirement] [varchar](100) NULL,
    [sectorrequirement] [varchar](100) NULL,
 CONSTRAINT [PK_PV_GovernmentApprovals] PRIMARY KEY CLUSTERED ([approvalid] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Execution Plans
CREATE TABLE [dbo].[PV_ExecutionPlans](
    [executionplanid] [int] IDENTITY(1,1) NOT NULL,
    [proposalid] [int] NOT NULL,
    [totalbudget] [decimal](18,2) NOT NULL,
    [startdate] [datetime] NOT NULL,
    [expectedenddate] [datetime] NOT NULL,
    [paymentplan] [text] NOT NULL,
    [disbursementplan] [text] NOT NULL,
    [createddate] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [PK_PV_ExecutionPlans] PRIMARY KEY CLUSTERED ([executionplanid] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Project Status
CREATE TABLE [dbo].[PV_ProjectStatus](
    [projectstatusid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](30) NOT NULL,
    [description] [varchar](100) NULL,
 CONSTRAINT [PK_PV_ProjectStatus] PRIMARY KEY CLUSTERED ([projectstatusid] ASC)
) ON [PRIMARY]
GO

/****** PAYMENT SYSTEM TABLES ******/

-- Payment Methods
CREATE TABLE [dbo].[PV_PaymentMethods](
    [paymentmethodid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](45) NOT NULL,
    [APIURL] [varchar](225) NOT NULL,
    [secretkey] [varbinary](125) NOT NULL,
    [key] [varbinary](125) NOT NULL,
    [logoiconurl] [varchar](225) NULL,
    [enabled] [bit] NOT NULL,
 CONSTRAINT [PK_PV_PaymentMethods] PRIMARY KEY CLUSTERED ([paymentmethodid] ASC)
) ON [PRIMARY]
GO

-- Available Methods
CREATE TABLE [dbo].[PV_AvailableMethods](
    [availablemethodid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](45) NOT NULL,
    [token] [varbinary](128) NOT NULL,
    [exptokendate] [datetime] NOT NULL,
    [maskaccount] [varchar](20) NOT NULL,
    [userid] [int] NOT NULL,
    [paymentmethodid] [int] NOT NULL,
 CONSTRAINT [PK_PV_AvailableMethods] PRIMARY KEY CLUSTERED ([availablemethodid] ASC)
) ON [PRIMARY]
GO

-- Payments
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
 CONSTRAINT [PK_PV_Payment] PRIMARY KEY CLUSTERED ([paymentid] ASC)
) ON [PRIMARY]
GO

-- Investments
CREATE TABLE [dbo].[PV_Investments](
    [investmentid] [int] IDENTITY(1,1) NOT NULL,
    [proposalid] [int] NOT NULL,
    [investorid] [int] NOT NULL,
    [amount] [decimal](18,2) NOT NULL,
    [equitypercentage] [decimal](5,4) NOT NULL,
    [investmentdate] [datetime] NOT NULL DEFAULT GETDATE(),
    [paymentid] [int] NOT NULL,
    [investmenthash] [varbinary](256) NOT NULL,
 CONSTRAINT [PK_PV_Investments] PRIMARY KEY CLUSTERED ([investmentid] ASC)
) ON [PRIMARY]
GO

-- Project Monitoring
CREATE TABLE [dbo].[PV_ProjectMonitoring](
    [monitoringid] [int] IDENTITY(1,1) NOT NULL,
    [proposalid] [int] NOT NULL,
    [reportedby] [int] NOT NULL,
    [reportdate] [datetime] NOT NULL DEFAULT GETDATE(),
    [reporttype] [varchar](30) NOT NULL,
    [description] [text] NOT NULL,
    [evidence] [text] NULL,
    [statusid] [int] NOT NULL,
    [reviewedby] [int] NULL,
    [reviewdate] [datetime] NULL,
 CONSTRAINT [PK_PV_ProjectMonitoring] PRIMARY KEY CLUSTERED ([monitoringid] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Financial Reports
CREATE TABLE [dbo].[PV_FinancialReports](
    [reportid] [int] IDENTITY(1,1) NOT NULL,
    [proposalid] [int] NOT NULL,
    [reportperiod] [varchar](20) NOT NULL,
    [totalrevenue] [decimal](18,2) NOT NULL,
    [totalexpenses] [decimal](18,2) NOT NULL,
    [netprofit] [decimal](18,2) NOT NULL,
    [availablefordividends] [decimal](18,2) NOT NULL,
    [reportfile] [varchar](500) NULL,
    [submitteddate] [datetime] NOT NULL DEFAULT GETDATE(),
    [approvedby] [int] NULL,
    [approveddate] [datetime] NULL,
 CONSTRAINT [PK_PV_FinancialReports] PRIMARY KEY CLUSTERED ([reportid] ASC)
) ON [PRIMARY]
GO

-- Dividend Distributions
CREATE TABLE [dbo].[PV_DividendDistributions](
    [distributionid] [int] IDENTITY(1,1) NOT NULL,
    [proposalid] [int] NOT NULL,
    [reportid] [int] NOT NULL,
    [totaldividends] [decimal](18,2) NOT NULL,
    [distributiondate] [datetime] NOT NULL,
    [processedby] [int] NOT NULL,
    [distributionhash] [varbinary](256) NOT NULL,
 CONSTRAINT [PK_PV_DividendDistributions] PRIMARY KEY CLUSTERED ([distributionid] ASC)
) ON [PRIMARY]
GO

-- Dividend Payments
CREATE TABLE [dbo].[PV_DividendPayments](
    [dividendpaymentid] [int] IDENTITY(1,1) NOT NULL,
    [distributionid] [int] NOT NULL,
    [investmentid] [int] NOT NULL,
    [amount] [decimal](18,2) NOT NULL,
    [paymentid] [int] NOT NULL,
    [paymentdate] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [PK_PV_DividendPayments] PRIMARY KEY CLUSTERED ([dividendpaymentid] ASC)
) ON [PRIMARY]
GO

/****** SUPPORTING SYSTEM TABLES ******/

-- Funds
CREATE TABLE [dbo].[PV_Funds](
    [fundid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](30) NULL,
 CONSTRAINT [PK_PV_Funds] PRIMARY KEY CLUSTERED ([fundid] ASC)
) ON [PRIMARY]
GO

-- Balances
CREATE TABLE [dbo].[PV_Balances](
    [balanceid] [int] IDENTITY(1,1) NOT NULL,
    [balance] [real] NOT NULL,
    [lastbalance] [real] NOT NULL,
    [lastupdate] [datetime] NOT NULL,
    [checksum] [varbinary](250) NOT NULL,
    [freezeamount] [real] NULL,
    [userid] [int] NOT NULL,
    [fundid] [int] NOT NULL,
 CONSTRAINT [PK_PV_Balances] PRIMARY KEY CLUSTERED ([balanceid] ASC)
) ON [PRIMARY]
GO

-- Exchange Rate
CREATE TABLE [dbo].[PV_ExchangeRate](
    [exchangeRateid] [int] IDENTITY(1,1) NOT NULL,
    [startDate] [datetime] NOT NULL,
    [endDate] [datetime] NOT NULL,
    [exchangeRate] [decimal](15, 8) NOT NULL,
    [enabled] [bit] NOT NULL,
    [currentExchangeRate] [bit] NOT NULL,
    [sourceCurrencyid] [int] NOT NULL,
    [destinyCurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_PV_ExchangeRate] PRIMARY KEY CLUSTERED ([exchangeRateid] ASC)
) ON [PRIMARY]
GO

-- Transaction Types and Subtypes
CREATE TABLE [dbo].[PV_TransType](
    [transtypeid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](30) NOT NULL,
 CONSTRAINT [PK_PV_TransType] PRIMARY KEY CLUSTERED ([transtypeid] ASC)
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PV_TransSubTypes](
    [transsubtypeid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](30) NOT NULL,
 CONSTRAINT [PK_PV_TransSubTypes] PRIMARY KEY CLUSTERED ([transsubtypeid] ASC)
) ON [PRIMARY]
GO

-- Schedule related tables
CREATE TABLE [dbo].[PV_RecurrencyType](
    [recurrencytypeid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](30) NOT NULL,
 CONSTRAINT [PK_PV_RecurrencyType] PRIMARY KEY CLUSTERED ([recurrencytypeid] ASC)
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PV_EndType](
    [endtypeid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](30) NOT NULL,
 CONSTRAINT [PK_PV_EndType] PRIMARY KEY CLUSTERED ([endtypeid] ASC)
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PV_Schedules](
    [scheduleid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](45) NOT NULL,
    [repetitions] [int] NOT NULL,
    [enddate] [datetime] NOT NULL,
    [recurrencytypeid] [int] NOT NULL,
    [endtypeid] [int] NOT NULL,
 CONSTRAINT [PK_PV_Schedules] PRIMARY KEY CLUSTERED ([scheduleid] ASC)
) ON [PRIMARY]
GO

-- Transactions
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
 CONSTRAINT [PK_PV_Transactions] PRIMARY KEY CLUSTERED ([transactionid] ASC)
) ON [PRIMARY]
GO

-- Logging System
CREATE TABLE [dbo].[PV_LogSource](
    [logsourceid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](45) NOT NULL,
 CONSTRAINT [PK_PV_LogSource] PRIMARY KEY CLUSTERED ([logsourceid] ASC)
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PV_LogSeverity](
    [logseverityid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](45) NOT NULL,
 CONSTRAINT [PK_PV_LogSeverity] PRIMARY KEY CLUSTERED ([logseverityid] ASC)
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PV_LogTypes](
    [logtypeid] [int] IDENTITY(1,1) NOT NULL,
    [name] [varchar](45) NOT NULL,
    [ref1description] [varchar](120) NOT NULL,
    [ref2description] [varchar](120) NOT NULL,
    [val1description] [varchar](120) NOT NULL,
    [val2description] [varchar](120) NOT NULL,
 CONSTRAINT [PK_PV_LogTypes] PRIMARY KEY CLUSTERED ([logtypeid] ASC)
) ON [PRIMARY]
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
 CONSTRAINT [PK_PV_Logs] PRIMARY KEY CLUSTERED ([logid] ASC)
) ON [PRIMARY]
GO

-- Translation System
CREATE TABLE [dbo].[PV_Translation](
    [translationid] [int] IDENTITY(1,1) NOT NULL,
    [code] [varchar](20) NOT NULL,
    [caption] [text] NOT NULL,
    [enabled] [bit] NOT NULL,
    [languageid] [int] NOT NULL,
    [moduleid] [int] NOT NULL,
 CONSTRAINT [PK_PV_Translation] PRIMARY KEY CLUSTERED ([translationid] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** FOREIGN KEY CONSTRAINTS ******/

-- Master data relationships
ALTER TABLE [dbo].[PV_Countries] WITH CHECK ADD CONSTRAINT [FK_PV_Countries_PV_Languages] 
FOREIGN KEY([languageid]) REFERENCES [dbo].[PV_Languages] ([languageid])
GO

ALTER TABLE [dbo].[PV_Countries] WITH CHECK ADD CONSTRAINT [FK_PV_Countries_PV_Currency] 
FOREIGN KEY([currencyid]) REFERENCES [dbo].[PV_Currency] ([currencyid])
GO

ALTER TABLE [dbo].[PV_States] WITH CHECK ADD CONSTRAINT [FK_PV_States_PV_Countries] 
FOREIGN KEY([countryid]) REFERENCES [dbo].[PV_Countries] ([countryid])
GO

ALTER TABLE [dbo].[PV_Cities] WITH CHECK ADD CONSTRAINT [FK_PV_Cities_PV_States] 
FOREIGN KEY([stateid]) REFERENCES [dbo].[PV_States] ([stateid])
GO

ALTER TABLE [dbo].[PV_Addresses] WITH CHECK ADD CONSTRAINT [FK_PV_Addresses_PV_Cities] 
FOREIGN KEY([cityid]) REFERENCES [dbo].[PV_Cities] ([cityid])
GO

-- User management relationships
ALTER TABLE [dbo].[PV_Organizations] WITH CHECK ADD CONSTRAINT [FK_PV_Organizations_PV_Users] 
FOREIGN KEY([representativeid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_MFA] WITH CHECK ADD CONSTRAINT [FK_PV_MFA_PV_MFAMethods] 
FOREIGN KEY([MFAmethodid]) REFERENCES [dbo].[PV_MFAMethods] ([MFAmethodid])
GO

ALTER TABLE [dbo].[PV_UserMFA] WITH CHECK ADD CONSTRAINT [FK_PV_UserMFA_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_UserMFA] WITH CHECK ADD CONSTRAINT [FK_PV_UserMFA_PV_MFA] 
FOREIGN KEY([MFAid]) REFERENCES [dbo].[PV_MFA] ([MFAid])
GO

ALTER TABLE [dbo].[PV_OrgMFA] WITH CHECK ADD CONSTRAINT [FK_PV_OrgMFA_PV_Organizations] 
FOREIGN KEY([organizationid]) REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO

ALTER TABLE [dbo].[PV_OrgMFA] WITH CHECK ADD CONSTRAINT [FK_PV_OrgMFA_PV_MFA] 
FOREIGN KEY([MFAid]) REFERENCES [dbo].[PV_MFA] ([MFAid])
GO

ALTER TABLE [dbo].[PV_CryptoKeys] WITH CHECK ADD CONSTRAINT [FK_PV_CryptoKeys_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_CryptoKeys] WITH CHECK ADD CONSTRAINT [FK_PV_CryptoKeys_PV_Organizations] 
FOREIGN KEY([organizationid]) REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO

ALTER TABLE [dbo].[PV_Permissions] WITH CHECK ADD CONSTRAINT [FK_PV_Permissions_PV_Modules] 
FOREIGN KEY([moduleid]) REFERENCES [dbo].[PV_Modules] ([moduleid])
GO

ALTER TABLE [dbo].[PV_UserRoles] WITH CHECK ADD CONSTRAINT [FK_PV_UserRoles_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_UserRoles] WITH CHECK ADD CONSTRAINT [FK_PV_UserRoles_PV_Roles] 
FOREIGN KEY([roleid]) REFERENCES [dbo].[PV_Roles] ([roleid])
GO

ALTER TABLE [dbo].[PV_RolePermissions] WITH CHECK ADD CONSTRAINT [FK_PV_RolePermissions_PV_Roles] 
FOREIGN KEY([roleid]) REFERENCES [dbo].[PV_Roles] ([roleid])
GO

ALTER TABLE [dbo].[PV_RolePermissions] WITH CHECK ADD CONSTRAINT [FK_PV_RolePermissions_PV_Permissions] 
FOREIGN KEY([permissionid]) REFERENCES [dbo].[PV_Permissions] ([permissionid])
GO

ALTER TABLE [dbo].[PV_UserPermissions] WITH CHECK ADD CONSTRAINT [FK_PV_UserPermissions_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_UserPermissions] WITH CHECK ADD CONSTRAINT [FK_PV_UserPermissions_PV_Permissions] 
FOREIGN KEY([permissionid]) REFERENCES [dbo].[PV_Permissions] ([permissionid])
GO

ALTER TABLE [dbo].[PV_UserAddresses] WITH CHECK ADD CONSTRAINT [FK_PV_UserAddresses_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_UserAddresses] WITH CHECK ADD CONSTRAINT [FK_PV_UserAddresses_PV_Addresses] 
FOREIGN KEY([addressid]) REFERENCES [dbo].[PV_Addresses] ([addressid])
GO

ALTER TABLE [dbo].[PV_OrganizationAddresses] WITH CHECK ADD CONSTRAINT [FK_PV_OrganizationAddresses_PV_Organizations] 
FOREIGN KEY([organizationid]) REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO

ALTER TABLE [dbo].[PV_OrganizationAddresses] WITH CHECK ADD CONSTRAINT [FK_PV_OrganizationAddresses_PV_Addresses] 
FOREIGN KEY([addressid]) REFERENCES [dbo].[PV_Addresses] ([addressid])
GO

ALTER TABLE [dbo].[PV_OrganizationRoles] WITH CHECK ADD CONSTRAINT [FK_PV_OrganizationRoles_PV_Organizations] 
FOREIGN KEY([organizationid]) REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO

ALTER TABLE [dbo].[PV_OrganizationRoles] WITH CHECK ADD CONSTRAINT [FK_PV_OrganizationRoles_PV_Roles] 
FOREIGN KEY([roleid]) REFERENCES [dbo].[PV_Roles] ([roleid])
GO

ALTER TABLE [dbo].[PV_OrganizationPermissions] WITH CHECK ADD CONSTRAINT [FK_PV_OrganizationPermissions_PV_Organizations] 
FOREIGN KEY([organizationid]) REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO

ALTER TABLE [dbo].[PV_OrganizationPermissions] WITH CHECK ADD CONSTRAINT [FK_PV_OrganizationPermissions_PV_Permissions] 
FOREIGN KEY([permissionid]) REFERENCES [dbo].[PV_Permissions] ([permissionid])
GO

-- Foreign registration relationships
ALTER TABLE [dbo].[PV_AllowedCountries] WITH CHECK ADD CONSTRAINT [FK_PV_AllowedCountries_PV_Countries] 
FOREIGN KEY([countryid]) REFERENCES [dbo].[PV_Countries] ([countryid])
GO

ALTER TABLE [dbo].[PV_AllowedIPs] WITH CHECK ADD CONSTRAINT [FK_PV_AllowedIPs_PV_Countries] 
FOREIGN KEY([countryid]) REFERENCES [dbo].[PV_Countries] ([countryid])
GO

-- ...existing code...

ALTER TABLE [dbo].[PV_IdentityValidations] WITH CHECK ADD CONSTRAINT [FK_PV_IdentityValidations_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_IdentityValidations] WITH CHECK ADD CONSTRAINT [FK_PV_IdentityValidations_PV_Users_Validator] 
FOREIGN KEY([validatedby]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_UserDocuments] WITH CHECK ADD CONSTRAINT [FK_PV_UserDocuments_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_MultiValidatorApprovals] WITH CHECK ADD CONSTRAINT [FK_PV_MultiValidatorApprovals_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_MultiValidatorApprovals] WITH CHECK ADD CONSTRAINT [FK_PV_MultiValidatorApprovals_PV_Proposals] 
FOREIGN KEY([proposalid]) REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO

ALTER TABLE [dbo].[PV_ValidatorApprovals] WITH CHECK ADD CONSTRAINT [FK_PV_ValidatorApprovals_PV_MultiValidatorApprovals] 
FOREIGN KEY([multivalidatorapprovalid]) REFERENCES [dbo].[PV_MultiValidatorApprovals] ([approvalid])
GO

ALTER TABLE [dbo].[PV_ValidatorApprovals] WITH CHECK ADD CONSTRAINT [FK_PV_ValidatorApprovals_PV_Users] 
FOREIGN KEY([validatorid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

-- Voting system relationships
ALTER TABLE [dbo].[PV_PopulationSegments] WITH CHECK ADD CONSTRAINT [FK_PV_PopulationSegments_PV_SegmentTypes] 
FOREIGN KEY([segmenttypeid]) REFERENCES [dbo].[PV_SegmentTypes] ([segmenttypeid])
GO

ALTER TABLE [dbo].[PV_UserSegments] WITH CHECK ADD CONSTRAINT [FK_PV_UserSegments_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_UserSegments] WITH CHECK ADD CONSTRAINT [FK_PV_UserSegments_PV_PopulationSegments] 
FOREIGN KEY([segmentid]) REFERENCES [dbo].[PV_PopulationSegments] ([segmentid])
GO

ALTER TABLE [dbo].[PV_Proposals] WITH CHECK ADD CONSTRAINT [FK_PV_Proposals_PV_Users] 
FOREIGN KEY([createdby]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_Proposals] WITH CHECK ADD CONSTRAINT [FK_PV_Proposals_PV_ProposalTypes] 
FOREIGN KEY([proposaltypeid]) REFERENCES [dbo].[PV_ProposalTypes] ([proposaltypeid])
GO

ALTER TABLE [dbo].[PV_Proposals] WITH CHECK ADD CONSTRAINT [FK_PV_Proposals_PV_ProposalStatus] 
FOREIGN KEY([statusid]) REFERENCES [dbo].[PV_ProposalStatus] ([statusid])
GO

ALTER TABLE [dbo].[PV_Proposals] WITH CHECK ADD CONSTRAINT [FK_PV_Proposals_PV_Organizations] 
FOREIGN KEY([organizationid]) REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO

ALTER TABLE [dbo].[PV_ProposalVersions] WITH CHECK ADD CONSTRAINT [FK_PV_ProposalVersions_PV_Proposals] 
FOREIGN KEY([proposalid]) REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO

ALTER TABLE [dbo].[PV_ProposalVersions] WITH CHECK ADD CONSTRAINT [FK_PV_ProposalVersions_PV_Users] 
FOREIGN KEY([createdby]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_ProposalRequirements] WITH CHECK ADD CONSTRAINT [FK_PV_ProposalRequirements_PV_ProposalTypes] 
FOREIGN KEY([proposaltypeid]) REFERENCES [dbo].[PV_ProposalTypes] ([proposaltypeid])
GO

ALTER TABLE [dbo].[PV_ProposalRequirements] WITH CHECK ADD CONSTRAINT [FK_PV_ProposalRequirements_PV_ProposalRequirementTypes] 
FOREIGN KEY([requirementtypeid]) REFERENCES [dbo].[PV_ProposalRequirementTypes] ([requirementtypeid])
GO

ALTER TABLE [dbo].[PV_ProposalRequirementValues] WITH CHECK ADD CONSTRAINT [FK_PV_ProposalRequirementValues_PV_Proposals] 
FOREIGN KEY([proposalid]) REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO

ALTER TABLE [dbo].[PV_ProposalRequirementValues] WITH CHECK ADD CONSTRAINT [FK_PV_ProposalRequirementValues_PV_ProposalRequirements] 
FOREIGN KEY([requirementid]) REFERENCES [dbo].[PV_ProposalRequirements] ([requirementid])
GO

ALTER TABLE [dbo].[PV_ValidationRules] WITH CHECK ADD CONSTRAINT [FK_PV_ValidationRules_PV_ProposalTypes] 
FOREIGN KEY([proposaltypeid]) REFERENCES [dbo].[PV_ProposalTypes] ([proposaltypeid])
GO

ALTER TABLE [dbo].[PV_ProposalDocuments] WITH CHECK ADD CONSTRAINT [FK_PV_ProposalDocuments_PV_Proposals] 
FOREIGN KEY([proposalid]) REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO

ALTER TABLE [dbo].[PV_NotificationSettings] WITH CHECK ADD CONSTRAINT [FK_PV_NotificationSettings_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_NotificationSettings] WITH CHECK ADD CONSTRAINT [FK_PV_NotificationSettings_PV_Organizations] 
FOREIGN KEY([organizationid]) REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO

ALTER TABLE [dbo].[PV_NotificationSettings] WITH CHECK ADD CONSTRAINT [FK_PV_NotificationSettings_PV_NotificationMethods] 
FOREIGN KEY([notificationmethodid]) REFERENCES [dbo].[PV_NotificationMethods] ([notificationmethodid])
GO

ALTER TABLE [dbo].[PV_VotingConfigurations] WITH CHECK ADD CONSTRAINT [FK_PV_VotingConfigurations_PV_Proposals] 
FOREIGN KEY([proposalid]) REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO

ALTER TABLE [dbo].[PV_VotingConfigurations] WITH CHECK ADD CONSTRAINT [FK_PV_VotingConfigurations_PV_Users] 
FOREIGN KEY([configuredby]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_VotingConfigurations] WITH CHECK ADD CONSTRAINT [FK_PV_VotingConfigurations_PV_NotificationMethods] 
FOREIGN KEY([notificationmethodid]) REFERENCES [dbo].[PV_NotificationMethods] ([notificationmethodid])
GO

ALTER TABLE [dbo].[PV_VotingConfigurations] WITH CHECK ADD CONSTRAINT [FK_PV_VotingConfigurations_PV_VotingStates] 
FOREIGN KEY([stateid]) REFERENCES [dbo].[PV_VotingStates] ([stateid])
GO

ALTER TABLE [dbo].[PV_VotingOptions] WITH CHECK ADD CONSTRAINT [FK_PV_VotingOptions_PV_VotingConfigurations] 
FOREIGN KEY([votingconfigid]) REFERENCES [dbo].[PV_VotingConfigurations] ([votingconfigid])
GO

ALTER TABLE [dbo].[PV_EligibleVoters] WITH CHECK ADD CONSTRAINT [FK_PV_EligibleVoters_PV_VotingConfigurations] 
FOREIGN KEY([votingconfigid]) REFERENCES [dbo].[PV_VotingConfigurations] ([votingconfigid])
GO

ALTER TABLE [dbo].[PV_EligibleVoters] WITH CHECK ADD CONSTRAINT [FK_PV_EligibleVoters_PV_PopulationSegments] 
FOREIGN KEY([segmentid]) REFERENCES [dbo].[PV_PopulationSegments] ([segmentid])
GO

ALTER TABLE [dbo].[PV_VotingTargetSegments] WITH CHECK ADD CONSTRAINT [FK_PV_VotingTargetSegments_PV_VotingConfigurations] 
FOREIGN KEY([votingconfigid]) REFERENCES [dbo].[PV_VotingConfigurations] ([votingconfigid])
GO

ALTER TABLE [dbo].[PV_VotingTargetSegments] WITH CHECK ADD CONSTRAINT [FK_PV_VotingTargetSegments_PV_PopulationSegments] 
FOREIGN KEY([segmentid]) REFERENCES [dbo].[PV_PopulationSegments] ([segmentid])
GO

ALTER TABLE [dbo].[PV_VoterRegistry] WITH CHECK ADD CONSTRAINT [FK_PV_VoterRegistry_PV_VotingConfigurations] 
FOREIGN KEY([votingconfigid]) REFERENCES [dbo].[PV_VotingConfigurations] ([votingconfigid])
GO

ALTER TABLE [dbo].[PV_VoterRegistry] WITH CHECK ADD CONSTRAINT [FK_PV_VoterRegistry_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_Votes] WITH CHECK ADD CONSTRAINT [FK_PV_Votes_PV_VotingConfigurations] 
FOREIGN KEY([votingconfigid]) REFERENCES [dbo].[PV_VotingConfigurations] ([votingconfigid])
GO

ALTER TABLE [dbo].[PV_VoteResults] WITH CHECK ADD CONSTRAINT [FK_PV_VoteResults_PV_VotingConfigurations] 
FOREIGN KEY([votingconfigid]) REFERENCES [dbo].[PV_VotingConfigurations] ([votingconfigid])
GO

ALTER TABLE [dbo].[PV_VoteResults] WITH CHECK ADD CONSTRAINT [FK_PV_VoteResults_PV_VotingOptions] 
FOREIGN KEY([optionid]) REFERENCES [dbo].[PV_VotingOptions] ([optionid])
GO

ALTER TABLE [dbo].[PV_VotingMetrics] WITH CHECK ADD CONSTRAINT [FK_PV_VotingMetrics_PV_VotingConfigurations] 
FOREIGN KEY([votingconfigid]) REFERENCES [dbo].[PV_VotingConfigurations] ([votingconfigid])
GO

ALTER TABLE [dbo].[PV_VotingMetrics] WITH CHECK ADD CONSTRAINT [FK_PV_VotingMetrics_PV_PopulationSegments] 
FOREIGN KEY([segmentid]) REFERENCES [dbo].[PV_PopulationSegments] ([segmentid])
GO

ALTER TABLE [dbo].[PV_ProposalComments] WITH CHECK ADD CONSTRAINT [FK_PV_ProposalComments_PV_Proposals] 
FOREIGN KEY([proposalid]) REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO

ALTER TABLE [dbo].[PV_ProposalComments] WITH CHECK ADD CONSTRAINT [FK_PV_ProposalComments_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_ProposalComments] WITH CHECK ADD CONSTRAINT [FK_PV_ProposalComments_PV_Users_Reviewer] 
FOREIGN KEY([reviewedby]) REFERENCES [dbo].[PV_Users] ([userid])
GO

-- Crowdfunding relationships
ALTER TABLE [dbo].[PV_ValidatorGroups] WITH CHECK ADD CONSTRAINT [FK_PV_ValidatorGroups_PV_Organizations] 
FOREIGN KEY([organizationid]) REFERENCES [dbo].[PV_Organizations] ([organizationid])
GO

ALTER TABLE [dbo].[PV_ProposalValidations] WITH CHECK ADD CONSTRAINT [FK_PV_ProposalValidations_PV_Proposals] 
FOREIGN KEY([proposalid]) REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO

ALTER TABLE [dbo].[PV_ProposalValidations] WITH CHECK ADD CONSTRAINT [FK_PV_ProposalValidations_PV_ValidatorGroups] 
FOREIGN KEY([validatorgroupid]) REFERENCES [dbo].[PV_ValidatorGroups] ([validatorgroupid])
GO

ALTER TABLE [dbo].[PV_ProposalValidations] WITH CHECK ADD CONSTRAINT [FK_PV_ProposalValidations_PV_Users] 
FOREIGN KEY([validatedby]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_GovernmentApprovals] WITH CHECK ADD CONSTRAINT [FK_PV_GovernmentApprovals_PV_Proposals] 
FOREIGN KEY([proposalid]) REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO

ALTER TABLE [dbo].[PV_GovernmentApprovals] WITH CHECK ADD CONSTRAINT [FK_PV_GovernmentApprovals_PV_Users] 
FOREIGN KEY([approvedby]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_ExecutionPlans] WITH CHECK ADD CONSTRAINT [FK_PV_ExecutionPlans_PV_Proposals] 
FOREIGN KEY([proposalid]) REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO

-- Payment system relationships
ALTER TABLE [dbo].[PV_AvailableMethods] WITH CHECK ADD CONSTRAINT [FK_PV_AvailableMethods_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_AvailableMethods] WITH CHECK ADD CONSTRAINT [FK_PV_AvailableMethods_PV_PaymentMethods] 
FOREIGN KEY([paymentmethodid]) REFERENCES [dbo].[PV_PaymentMethods] ([paymentmethodid])
GO

ALTER TABLE [dbo].[PV_Payment] WITH CHECK ADD CONSTRAINT [FK_PV_Payment_PV_Modules] 
FOREIGN KEY([moduleid]) REFERENCES [dbo].[PV_Modules] ([moduleid])
GO

ALTER TABLE [dbo].[PV_Payment] WITH CHECK ADD CONSTRAINT [FK_PV_Payment_PV_PaymentMethods] 
FOREIGN KEY([paymentmethodid]) REFERENCES [dbo].[PV_PaymentMethods] ([paymentmethodid])
GO

ALTER TABLE [dbo].[PV_Payment] WITH CHECK ADD CONSTRAINT [FK_PV_Payment_PV_AvailableMethods] 
FOREIGN KEY([availablemethodid]) REFERENCES [dbo].[PV_AvailableMethods] ([availablemethodid])
GO

ALTER TABLE [dbo].[PV_Payment] WITH CHECK ADD CONSTRAINT [FK_PV_Payment_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_Investments] WITH CHECK ADD CONSTRAINT [FK_PV_Investments_PV_Proposals] 
FOREIGN KEY([proposalid]) REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO

ALTER TABLE [dbo].[PV_Investments] WITH CHECK ADD CONSTRAINT [FK_PV_Investments_PV_Users] 
FOREIGN KEY([investorid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_Investments] WITH CHECK ADD CONSTRAINT [FK_PV_Investments_PV_Payment] 
FOREIGN KEY([paymentid]) REFERENCES [dbo].[PV_Payment] ([paymentid])
GO

ALTER TABLE [dbo].[PV_ProjectMonitoring] WITH CHECK ADD CONSTRAINT [FK_PV_ProjectMonitoring_PV_Proposals] 
FOREIGN KEY([proposalid]) REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO

ALTER TABLE [dbo].[PV_ProjectMonitoring] WITH CHECK ADD CONSTRAINT [FK_PV_ProjectMonitoring_PV_Users] 
FOREIGN KEY([reportedby]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_ProjectMonitoring] WITH CHECK ADD CONSTRAINT [FK_PV_ProjectMonitoring_PV_Users_Reviewer] 
FOREIGN KEY([reviewedby]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_FinancialReports] WITH CHECK ADD CONSTRAINT [FK_PV_FinancialReports_PV_Proposals] 
FOREIGN KEY([proposalid]) REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO

ALTER TABLE [dbo].[PV_FinancialReports] WITH CHECK ADD CONSTRAINT [FK_PV_FinancialReports_PV_Users] 
FOREIGN KEY([approvedby]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_DividendDistributions] WITH CHECK ADD CONSTRAINT [FK_PV_DividendDistributions_PV_Proposals] 
FOREIGN KEY([proposalid]) REFERENCES [dbo].[PV_Proposals] ([proposalid])
GO

ALTER TABLE [dbo].[PV_DividendDistributions] WITH CHECK ADD CONSTRAINT [FK_PV_DividendDistributions_PV_FinancialReports] 
FOREIGN KEY([reportid]) REFERENCES [dbo].[PV_FinancialReports] ([reportid])
GO

ALTER TABLE [dbo].[PV_DividendDistributions] WITH CHECK ADD CONSTRAINT [FK_PV_DividendDistributions_PV_Users] 
FOREIGN KEY([processedby]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_DividendPayments] WITH CHECK ADD CONSTRAINT [FK_PV_DividendPayments_PV_DividendDistributions] 
FOREIGN KEY([distributionid]) REFERENCES [dbo].[PV_DividendDistributions] ([distributionid])
GO

ALTER TABLE [dbo].[PV_DividendPayments] WITH CHECK ADD CONSTRAINT [FK_PV_DividendPayments_PV_Investments] 
FOREIGN KEY([investmentid]) REFERENCES [dbo].[PV_Investments] ([investmentid])
GO

ALTER TABLE [dbo].[PV_DividendPayments] WITH CHECK ADD CONSTRAINT [FK_PV_DividendPayments_PV_Payment] 
FOREIGN KEY([paymentid]) REFERENCES [dbo].[PV_Payment] ([paymentid])
GO

-- Supporting system relationships
ALTER TABLE [dbo].[PV_Balances] WITH CHECK ADD CONSTRAINT [FK_PV_Balances_PV_Users] 
FOREIGN KEY([userid]) REFERENCES [dbo].[PV_Users] ([userid])
GO

ALTER TABLE [dbo].[PV_Balances] WITH CHECK ADD CONSTRAINT [FK_PV_Balances_PV_Funds] 
FOREIGN KEY([fundid]) REFERENCES [dbo].[PV_Funds] ([fundid])
GO

ALTER TABLE [dbo].[PV_ExchangeRate] WITH CHECK ADD CONSTRAINT [FK_PV_ExchangeRate_PV_Currency_Source] 
FOREIGN KEY([sourceCurrencyid]) REFERENCES [dbo].[PV_Currency] ([currencyid])
GO

ALTER TABLE [dbo].[PV_ExchangeRate] WITH CHECK ADD CONSTRAINT [FK_PV_ExchangeRate_PV_Currency_Destiny] 
FOREIGN KEY([destinyCurrencyId]) REFERENCES [dbo].[PV_Currency] ([currencyid])
GO

ALTER TABLE [dbo].[PV_Schedules] WITH CHECK ADD CONSTRAINT [FK_PV_Schedules_PV_RecurrencyType] 
FOREIGN KEY([recurrencytypeid]) REFERENCES [dbo].[PV_RecurrencyType] ([recurrencytypeid])
GO

ALTER TABLE [dbo].[PV_Schedules] WITH CHECK ADD CONSTRAINT [FK_PV_Schedules_PV_EndType] 
FOREIGN KEY([endtypeid]) REFERENCES [dbo].[PV_EndType] ([endtypeid])
GO

ALTER TABLE [dbo].[PV_Transactions] WITH CHECK ADD CONSTRAINT [FK_PV_Transactions_PV_TransType] 
FOREIGN KEY([transtypeid]) REFERENCES [dbo].[PV_TransType] ([transtypeid])
GO

ALTER TABLE [dbo].[PV_Transactions] WITH CHECK ADD CONSTRAINT [FK_PV_Transactions_PV_TransSubTypes] 
FOREIGN KEY([transsubtypeid]) REFERENCES [dbo].[PV_TransSubTypes] ([transsubtypeid])
GO

ALTER TABLE [dbo].[PV_Transactions] WITH CHECK ADD CONSTRAINT [FK_PV_Transactions_PV_Payment] 
FOREIGN KEY([paymentid]) REFERENCES [dbo].[PV_Payment] ([paymentid])
GO

ALTER TABLE [dbo].[PV_Transactions] WITH CHECK ADD CONSTRAINT [FK_PV_Transactions_PV_Currency] 
FOREIGN KEY([currencyid]) REFERENCES [dbo].[PV_Currency] ([currencyid])
GO

ALTER TABLE [dbo].[PV_Transactions] WITH CHECK ADD CONSTRAINT [FK_PV_Transactions_PV_ExchangeRate] 
FOREIGN KEY([exchangerateid]) REFERENCES [dbo].[PV_ExchangeRate] ([exchangeRateid])
GO

ALTER TABLE [dbo].[PV_Transactions] WITH CHECK ADD CONSTRAINT [FK_PV_Transactions_PV_Schedules] 
FOREIGN KEY([scheduleid]) REFERENCES [dbo].[PV_Schedules] ([scheduleid])
GO

ALTER TABLE [dbo].[PV_Transactions] WITH CHECK ADD CONSTRAINT [FK_PV_Transactions_PV_Balances] 
FOREIGN KEY([balanceid]) REFERENCES [dbo].[PV_Balances] ([balanceid])
GO

ALTER TABLE [dbo].[PV_Transactions] WITH CHECK ADD CONSTRAINT [FK_PV_Transactions_PV_Funds] 
FOREIGN KEY([fundid]) REFERENCES [dbo].[PV_Funds] ([fundid])
GO

-- Logging system relationships
ALTER TABLE [dbo].[PV_Logs] WITH CHECK ADD CONSTRAINT [FK_PV_Logs_PV_LogTypes] 
FOREIGN KEY([logtypeid]) REFERENCES [dbo].[PV_LogTypes] ([logtypeid])
GO

ALTER TABLE [dbo].[PV_Logs] WITH CHECK ADD CONSTRAINT [FK_PV_Logs_PV_LogSource] 
FOREIGN KEY([logsourceid]) REFERENCES [dbo].[PV_LogSource] ([logsourceid])
GO

ALTER TABLE [dbo].[PV_Logs] WITH CHECK ADD CONSTRAINT [FK_PV_Logs_PV_LogSeverity] 
FOREIGN KEY([logseverityid]) REFERENCES [dbo].[PV_LogSeverity] ([logseverityid])
GO

-- Translation system relationships
ALTER TABLE [dbo].[PV_Translation] WITH CHECK ADD CONSTRAINT [FK_PV_Translation_PV_Languages] 
FOREIGN KEY([languageid]) REFERENCES [dbo].[PV_Languages] ([languageid])
GO

ALTER TABLE [dbo].[PV_Translation] WITH CHECK ADD CONSTRAINT [FK_PV_Translation_PV_Modules] 
FOREIGN KEY([moduleid]) REFERENCES [dbo].[PV_Modules] ([moduleid])
GO

/****** INDEXES FOR PERFORMANCE ******/

-- Critical query indexes
CREATE NONCLUSTERED INDEX [IX_PV_Users_Email] ON [dbo].[PV_Users] ([email])
GO

CREATE NONCLUSTERED INDEX [IX_PV_Users_DNI] ON [dbo].[PV_Users] ([dni])
GO

CREATE NONCLUSTERED INDEX [IX_PV_Proposals_Status] ON [dbo].[PV_Proposals] ([statusid])
GO

CREATE NONCLUSTERED INDEX [IX_PV_Proposals_Type] ON [dbo].[PV_Proposals] ([proposaltypeid])
GO

CREATE NONCLUSTERED INDEX [IX_PV_VotingConfigurations_State] ON [dbo].[PV_VotingConfigurations] ([stateid])
GO

CREATE NONCLUSTERED INDEX [IX_PV_Votes_Config] ON [dbo].[PV_Votes] ([votingconfigid])
GO

CREATE NONCLUSTERED INDEX [IX_PV_Votes_Nullifier] ON [dbo].[PV_Votes] ([nullifierhash])
GO

CREATE NONCLUSTERED INDEX [IX_PV_VoterRegistry_HasVoted] ON [dbo].[PV_VoterRegistry] ([votingconfigid], [hasVoted])
GO

CREATE NONCLUSTERED INDEX [IX_PV_UserDocuments_AI_Status] ON [dbo].[PV_UserDocuments] ([aivalidationstatus])
GO

CREATE NONCLUSTERED INDEX [IX_PV_Payments_User] ON [dbo].[PV_Payment] ([userid])
GO

CREATE NONCLUSTERED INDEX [IX_PV_Investments_Proposal] ON [dbo].[PV_Investments] ([proposalid])
GO

CREATE NONCLUSTERED INDEX [IX_PV_UserSegments_Active] ON [dbo].[PV_UserSegments] ([isactive])
GO

CREATE NONCLUSTERED INDEX [IX_PV_Logs_PostTime] ON [dbo].[PV_Logs] ([posttime])
GO

CREATE NONCLUSTERED INDEX [IX_PV_Transactions_Date] ON [dbo].[PV_Transactions] ([date])
GO
