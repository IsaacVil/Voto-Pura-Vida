CREATE TABLE [dbo].[PV_VotingStatus] (
[statusid] int NOT NULL IDENTITY(1,1),
[name] varchar(30) NOT NULL,
[description] varchar(100),
PRIMARY KEY ([statusid])
);

CREATE TABLE [dbo].[PV_Languages] (
[languageid] int NOT NULL IDENTITY(1,1),
[name] varchar(60) NOT NULL,
[culture] varchar(20) NOT NULL,
PRIMARY KEY ([languageid])
);

CREATE TABLE [dbo].[PV_Transactions] (
[transactionid] int NOT NULL IDENTITY(1,1),
[amount] bigint NOT NULL,
[description] varchar(120),
[date] datetime NOT NULL,
[posttime] datetime NOT NULL,
[reference1] bigint NOT NULL,
[reference2] bigint NOT NULL,
[value1] varchar(100) NOT NULL,
[value2] varchar(100) NOT NULL,
[processmanagerid] int NOT NULL,
[convertedamount] bigint NOT NULL,
[checksum] varbinary(250) NOT NULL,
[transtypeid] int NOT NULL,
[transsubtypeid] int NOT NULL,
[paymentid] int NOT NULL,
[currencyid] int NOT NULL,
[exchangerateid] int NOT NULL,
[scheduleid] int NOT NULL,
[balanceid] int NOT NULL,
[fundid] int NOT NULL,
PRIMARY KEY ([transactionid])
);

CREATE TABLE [dbo].[PV_ExchangeRate] (
[exchangeRateid] int NOT NULL IDENTITY(1,1),
[startDate] datetime NOT NULL,
[endDate] datetime NOT NULL,
[exchangeRate] decimal(15,8) NOT NULL,
[enabled] bit NOT NULL,
[currentExchangeRate] bit NOT NULL,
[sourceCurrencyid] int NOT NULL,
[destinyCurrencyId] int NOT NULL,
PRIMARY KEY ([exchangeRateid])
);

CREATE TABLE [dbo].[PV_LogTypes] (
[logtypeid] int NOT NULL IDENTITY(1,1),
[name] varchar(45) NOT NULL,
[ref1description] varchar(120) NOT NULL,
[ref2description] varchar(120) NOT NULL,
[val1description] varchar(120) NOT NULL,
[val2description] varchar(120) NOT NULL,
PRIMARY KEY ([logtypeid])
);

CREATE TABLE [dbo].[PV_AllowedCountries] (
[allowedcountryid] int NOT NULL IDENTITY(1,1),
[countryid] int NOT NULL,
[isallowed] bit DEFAULT ((1)) NOT NULL,
[createddate] datetime DEFAULT (getdate()) NOT NULL,
[lastmodified] datetime DEFAULT (getdate()) NOT NULL,
PRIMARY KEY ([allowedcountryid])
);

CREATE TABLE [dbo].[PV_Investments] (
[investmentid] int NOT NULL IDENTITY(1,1),
[proposalid] int NOT NULL,
[amount] decimal(18,2) NOT NULL,
[equitypercentage] decimal(5,4) NOT NULL,
[investmentdate] datetime DEFAULT (getdate()) NOT NULL,
[investmenthash] varbinary(256) NOT NULL,
PRIMARY KEY ([investmentid])
);

CREATE TABLE [dbo].[PV_OrganizationPerUser] (
[organizationPerUserId] int NOT NULL IDENTITY(1,1),
[userId] int,
[organizationId] int,
PRIMARY KEY ([organizationPerUserId])
);

CREATE TABLE [dbo].[PV_UserDocuments] (
[userDocumentId] int NOT NULL IDENTITY(1,1),
[documentid] int,
[userId] int,
PRIMARY KEY ([userDocumentId])
);

CREATE TABLE [dbo].[PV_AIConnections] (
[connectionid] int NOT NULL IDENTITY(1,1),
[providerid] int NOT NULL,
[connectionname] varchar(100) NOT NULL,
[publicKey] varbinary(512) NOT NULL,
[privateKey] varbinary(256) NOT NULL,
[organizationid] int,
[projectid] varchar(100),
[region] varchar(50),
[environment] varchar(20) DEFAULT ('production') NOT NULL,
[isactive] bit DEFAULT ((1)) NOT NULL,
[createdby] int NOT NULL,
[createdate] datetime DEFAULT (getdate()) NOT NULL,
[lastused] datetime,
[usagecount] bigint DEFAULT ((0)) NOT NULL,
PRIMARY KEY ([connectionid])
);

CREATE TABLE [dbo].[PV_ProposalComments] (
[commentid] int NOT NULL IDENTITY(1,1),
[proposalid] int NOT NULL,
[userid] int NOT NULL,
[comment] text NOT NULL,
[commentdate] datetime DEFAULT (getdate()) NOT NULL,
[statusid] int NOT NULL,
[reviewedby] int,
[reviewdate] datetime,
PRIMARY KEY ([commentid])
);

CREATE TABLE [dbo].[PV_AvailableMethods] (
[availablemethodid] int NOT NULL IDENTITY(1,1),
[name] varchar(45) NOT NULL,
[token] varbinary(128) NOT NULL,
[exptokendate] datetime NOT NULL,
[maskaccount] varchar(20) NOT NULL,
[userid] int NOT NULL,
[paymentmethodid] int NOT NULL,
PRIMARY KEY ([availablemethodid])
);

CREATE TABLE [dbo].[PV_investmentSteps] (
[invesmentStepId] int NOT NULL IDENTITY(1,1),
[investmentAgreementId] int,
[stepIndex] int,
[description] varchar(300) NOT NULL,
[amount] decimal(18,0) NOT NULL,
[remainingAmount] decimal(18,0) NOT NULL,
[estimatedDate] datetime,
[paymentId] int,
PRIMARY KEY ([invesmentStepId])
);

CREATE TABLE [dbo].[PV_Genders] (
[genderId] int NOT NULL IDENTITY(1,1),
[name] varchar(50),
PRIMARY KEY ([genderId])
);

CREATE TABLE [dbo].[PV_AuthPlatforms] (
[authPlatformId] int NOT NULL IDENTITY(1,1),
[name] varchar(50) NOT NULL,
[secretKey] varbinary(128) NOT NULL,
[key] varbinary(128) NOT NULL,
[iconURL] varchar(200) NOT NULL,
PRIMARY KEY ([authPlatformId])
);

CREATE TABLE [dbo].[PV_documentAnalysis_workflow] (
[analysisid] bigint NOT NULL IDENTITY(1,1),
[documentid] int NOT NULL,
[analysisDocTypeId] int NOT NULL,
[confidence] decimal(5,4) NOT NULL,
[result] varchar(20) NOT NULL,
[findings] text NOT NULL,
[extracteddata] text,
[flags] text,
[humanreviewrequired] bit DEFAULT ((0)) NOT NULL,
[reviewerid] int,
[reviewdate] datetime,
[reviewcomments] text,
[finalresult] varchar(20),
[analysisdate] datetime DEFAULT (getdate()) NOT NULL,
[workflowId] int,
PRIMARY KEY ([analysisid])
);

CREATE TABLE [dbo].[PV_PublicVote] (
[publicVoteId] int NOT NULL IDENTITY(1,1),
[userId] int,
[voteId] int,
[publicResult] varchar(50),
PRIMARY KEY ([publicVoteId])
);

CREATE TABLE [dbo].[PV_workflowsType] (
[workflowTypeId] int NOT NULL IDENTITY(1,1),
[name] varchar(50) NOT NULL,
PRIMARY KEY ([workflowTypeId])
);

CREATE TABLE [dbo].[PV_ValidationRules] (
[validationruleid] int NOT NULL IDENTITY(1,1),
[proposaltypeid] int NOT NULL,
[fieldname] varchar(50) NOT NULL,
[ruletype] varchar(30) NOT NULL,
[rulevalue] varchar(500),
[errormessage] varchar(200) NOT NULL,
PRIMARY KEY ([validationruleid])
);

CREATE TABLE [dbo].[PV_MFAMethods] (
[MFAmethodid] int NOT NULL IDENTITY(1,1),
[name] varchar(100) NOT NULL,
[description] varchar(200) NOT NULL,
[requiressecret] bit NOT NULL,
PRIMARY KEY ([MFAmethodid])
);

CREATE TABLE [dbo].[PV_PaymentMethods] (
[paymentmethodid] int NOT NULL IDENTITY(1,1),
[name] varchar(45) NOT NULL,
[APIURL] varchar(225) NOT NULL,
[secretkey] varbinary(125) NOT NULL,
[key] varbinary(125) NOT NULL,
[logoiconurl] varchar(225),
[enabled] bit NOT NULL,
PRIMARY KEY ([paymentmethodid])
);

CREATE TABLE [dbo].[PV_Roles] (
[roleid] int NOT NULL IDENTITY(1,1),
[name] varchar(30) NOT NULL,
PRIMARY KEY ([roleid])
);

CREATE TABLE [dbo].[PV_Users] (
[userid] int NOT NULL IDENTITY(1,1),
[password] varbinary(256) NOT NULL,
[email] varchar(120) NOT NULL,
[firstname] varchar(50) NOT NULL,
[lastname] varchar(50) NOT NULL,
[birthdate] datetime NOT NULL,
[createdAt] datetime NOT NULL,
[genderId] int NOT NULL,
[lastupdate] datetime NOT NULL,
[dni] bigint NOT NULL,
[userStatusId] int,
PRIMARY KEY ([userid])
);

CREATE TABLE [dbo].[PV_ProposalStatus] (
[statusid] int NOT NULL IDENTITY(1,1),
[name] varchar(30) NOT NULL,
[description] varchar(100),
PRIMARY KEY ([statusid])
);

CREATE TABLE [dbo].[PV_AIModelTypes] (
[AIModelId] int NOT NULL IDENTITY(1,1),
[name] varchar(50),
PRIMARY KEY ([AIModelId])
);

CREATE TABLE [dbo].[PV_Countries] (
[countryid] int NOT NULL IDENTITY(1,1),
[name] varchar(60) NOT NULL,
[languageid] int NOT NULL,
[currencyid] int NOT NULL,
PRIMARY KEY ([countryid])
);

CREATE TABLE [dbo].[PV_Cities] (
[cityid] int NOT NULL IDENTITY(1,1),
[name] varchar(60) NOT NULL,
[stateid] int NOT NULL,
PRIMARY KEY ([cityid])
);

CREATE TABLE [dbo].[PV_ProjectMonitoring] (
[monitoringid] int NOT NULL IDENTITY(1,1),
[proposalid] int NOT NULL,
[reportedby] int NOT NULL,
[reportdate] datetime DEFAULT (getdate()) NOT NULL,
[reporttype] varchar(30) NOT NULL,
[description] text NOT NULL,
[evidence] text,
[statusid] int NOT NULL,
[reviewedby] int,
[reviewdate] datetime,
PRIMARY KEY ([monitoringid])
);

CREATE TABLE [dbo].[PV_TransSubTypes] (
[transsubtypeid] int NOT NULL IDENTITY(1,1),
[name] varchar(30) NOT NULL,
PRIMARY KEY ([transsubtypeid])
);

CREATE TABLE [dbo].[PV_Funds] (
[fundid] int NOT NULL IDENTITY(1,1),
[name] varchar(30),
PRIMARY KEY ([fundid])
);

CREATE TABLE [dbo].[PV_PopulationSegments] (
[segmentid] int NOT NULL IDENTITY(1,1),
[name] varchar(60) NOT NULL,
[description] varchar(200),
[segmenttypeid] int NOT NULL,
PRIMARY KEY ([segmentid])
);

CREATE TABLE [dbo].[PV_VoterRegistry] (
[registryid] int NOT NULL IDENTITY(1,1),
[votingconfigid] int NOT NULL,
[userid] int NOT NULL,
[votercommitment] varbinary(256) NOT NULL,
[registrationdate] datetime DEFAULT (getdate()) NOT NULL,
[hasVoted] bit DEFAULT ((0)) NOT NULL,
PRIMARY KEY ([registryid])
);

CREATE TABLE [dbo].[PV_UserStatus] (
[userStatusId] int NOT NULL IDENTITY(1,1),
[active] bit,
[verified] bit,
PRIMARY KEY ([userStatusId])
);

CREATE TABLE [dbo].[PV_ProjectStatus] (
[projectstatusid] int NOT NULL IDENTITY(1,1),
[name] varchar(30) NOT NULL,
[description] varchar(100),
PRIMARY KEY ([projectstatusid])
);

CREATE TABLE [dbo].[PV_IdentityOrganizationValidation] (
[orgValidationId] int NOT NULL IDENTITY(1,1),
[organizationid] int,
[validationId] int,
PRIMARY KEY ([orgValidationId])
);

CREATE TABLE [dbo].[PV_VotingQuestions] (
[questionId] int NOT NULL IDENTITY(1,1),
[question] varchar(500),
PRIMARY KEY ([questionId])
);

CREATE TABLE [dbo].[PV_ValidationStatus] (
[statusValidationId] int NOT NULL IDENTITY(1,1),
[status] varchar(50),
PRIMARY KEY ([statusValidationId])
);

CREATE TABLE [dbo].[PV_LogSeverity] (
[logseverityid] int NOT NULL IDENTITY(1,1),
[name] varchar(45) NOT NULL,
PRIMARY KEY ([logseverityid])
);

CREATE TABLE [dbo].[PV_OrgMFA] (
[orgmfaid] int NOT NULL IDENTITY(1,1),
[organizationid] int NOT NULL,
[MFAid] int NOT NULL,
PRIMARY KEY ([orgmfaid])
);

CREATE TABLE [dbo].[PV_MFA] (
[MFAid] int NOT NULL IDENTITY(1,1),
[MFAmethodid] int NOT NULL,
[MFA_secret] varbinary(256) NOT NULL,
[createdAt] datetime NOT NULL,
[enabled] bit NOT NULL,
PRIMARY KEY ([MFAid])
);

CREATE TABLE [dbo].[PV_EligibleVoters] (
[eligibleid] int NOT NULL IDENTITY(1,1),
[votingconfigid] int NOT NULL,
[segmentid] int NOT NULL,
[voteweight] decimal(5,2) DEFAULT ((1.0)) NOT NULL,
[assigneddate] datetime DEFAULT (getdate()) NOT NULL,
PRIMARY KEY ([eligibleid])
);

CREATE TABLE [dbo].[PV_ProposalRequirementTypes] (
[requirementtypeid] int NOT NULL IDENTITY(1,1),
[name] varchar(50) NOT NULL,
[description] varchar(200),
PRIMARY KEY ([requirementtypeid])
);

CREATE TABLE [dbo].[PV_Currency] (
[currencyid] int NOT NULL IDENTITY(1,1),
[name] varchar(25) NOT NULL,
[symbol] varchar(5) NOT NULL,
[acronym] varchar(5) NOT NULL,
PRIMARY KEY ([currencyid])
);

CREATE TABLE [dbo].[PV_authSession] (
[AuthsessionId] int NOT NULL IDENTITY(1,1),
[sessionId] varbinary(16) NOT NULL,
[externalUser] varbinary(16) NOT NULL,
[token] varbinary(128) NOT NULL,
[refreshToken] varbinary(128) NOT NULL,
[userId] int,
[authPlatformId] int,
PRIMARY KEY ([AuthsessionId])
);

CREATE TABLE [dbo].[PV_proposalCommentDocuments] (
[Id] int NOT NULL IDENTITY(1,1),
[documentId] int,
[commentId] int,
PRIMARY KEY ([Id])
);

CREATE TABLE [dbo].[PV_ProposalRequirements] (
[requirementid] int NOT NULL IDENTITY(1,1),
[proposaltypeid] int NOT NULL,
[requirementtypeid] int NOT NULL,
[fieldname] varchar(50) NOT NULL,
[isrequired] bit DEFAULT ((1)) NOT NULL,
[minlength] int,
[maxlength] int,
[datatype] varchar(20) DEFAULT ('Text') NOT NULL,
[validationrule] varchar(500),
PRIMARY KEY ([requirementid])
);

CREATE TABLE [dbo].[PV_AllowedIPs] (
[allowedipid] int NOT NULL IDENTITY(1,1),
[ipaddress] varchar(45) NOT NULL,
[ipmask] varchar(45),
[countryid] int,
[isallowed] bit DEFAULT ((1)) NOT NULL,
[description] varchar(200),
[createddate] datetime DEFAULT (getdate()) NOT NULL,
[lastmodified] datetime DEFAULT (getdate()) NOT NULL,
PRIMARY KEY ([allowedipid])
);

CREATE TABLE [dbo].[PV_AIProposalAnalysis] (
[analysisid] bigint NOT NULL IDENTITY(1,1),
[proposalid] int NOT NULL,
[analysistype] int NOT NULL,
[confidence] decimal(5,4) NOT NULL,
[findings] text NOT NULL,
[recommendations] text,
[riskfactors] text,
[complianceissues] text,
[budgetanalysis] text,
[marketanalysis] text,
[humanreviewrequired] bit DEFAULT ((0)) NOT NULL,
[reviewerid] int,
[reviewdate] datetime,
[reviewcomments] text,
[analysisdate] datetime DEFAULT (getdate()) NOT NULL,
[workflowId] int,
[validationId] int,
PRIMARY KEY ([analysisid])
);

CREATE TABLE [dbo].[PV_Proposals] (
[proposalid] int NOT NULL IDENTITY(1,1),
[title] varchar(200) NOT NULL,
[description] text NOT NULL,
[proposalcontent] text NOT NULL,
[budget] decimal(18,2),
[createdby] int,
[createdon] datetime DEFAULT (getdate()) NOT NULL,
[lastmodified] datetime DEFAULT (getdate()) NOT NULL,
[proposaltypeid] int NOT NULL,
[statusid] int NOT NULL,
[organizationid] int,
[checksum] varbinary(256) NOT NULL,
[version] int DEFAULT ((1)) NOT NULL,
PRIMARY KEY ([proposalid])
);

CREATE TABLE [dbo].[PV_ProposalVersions] (
[versionid] int NOT NULL IDENTITY(1,1),
[proposalid] int NOT NULL,
[versionnumber] int NOT NULL,
[title] varchar(200) NOT NULL,
[description] text NOT NULL,
[proposalcontent] text NOT NULL,
[budget] decimal(18,2),
[createdby] int NOT NULL,
[createdon] datetime DEFAULT (getdate()) NOT NULL,
[isactive] bit DEFAULT ((0)) NOT NULL,
[changecomments] text,
[checksum] varbinary(256) NOT NULL,
PRIMARY KEY ([versionid])
);

CREATE TABLE [dbo].[PV_VotingTypes] (
[votingTypeId] int NOT NULL IDENTITY(1,1),
[name] varchar(50),
PRIMARY KEY ([votingTypeId])
);

CREATE TABLE [dbo].[PV_NotificationMethods] (
[notificationmethodid] int NOT NULL IDENTITY(1,1),
[name] varchar(50) NOT NULL,
[description] varchar(200),
PRIMARY KEY ([notificationmethodid])
);

CREATE TABLE [dbo].[PV_UserAddresses] (
[useraddressid] int NOT NULL IDENTITY(1,1),
[userid] int NOT NULL,
[addressid] int NOT NULL,
[addresstype] varchar(20) DEFAULT ('Primary') NOT NULL,
[isactive] bit DEFAULT ((1)) NOT NULL,
[assigneddate] datetime DEFAULT (getdate()) NOT NULL,
PRIMARY KEY ([useraddressid])
);

CREATE TABLE [dbo].[PV_TransType] (
[transtypeid] int NOT NULL IDENTITY(1,1),
[name] varchar(30) NOT NULL,
PRIMARY KEY ([transtypeid])
);

CREATE TABLE [dbo].[PV_LogSource] (
[logsourceid] int NOT NULL IDENTITY(1,1),
[name] varchar(45) NOT NULL,
PRIMARY KEY ([logsourceid])
);

CREATE TABLE [dbo].[PV_Votes] (
[voteid] int NOT NULL IDENTITY(1,1),
[votingconfigid] int NOT NULL,
[votercommitment] varbinary(256) NOT NULL,
[encryptedvote] varbinary(512) NOT NULL,
[votehash] varbinary(256) NOT NULL,
[nullifierhash] varbinary(256) NOT NULL,
[votedate] datetime DEFAULT (getdate()) NOT NULL,
[blockhash] varbinary(256) NOT NULL,
[merkleproof] varbinary(1024),
[blockchainId] int,
PRIMARY KEY ([voteid])
);

CREATE TABLE [dbo].[PV_mediaTypes] (
[mediaTypeId] int NOT NULL IDENTITY(1,1),
[name] varchar(30),
[playerimpl] varchar(100),
PRIMARY KEY ([mediaTypeId])
);

CREATE TABLE [dbo].[PV_UserSegments] (
[usersegmentid] int NOT NULL IDENTITY(1,1),
[userid] int NOT NULL,
[segmentid] int NOT NULL,
[assigneddate] datetime DEFAULT (getdate()) NOT NULL,
[isactive] bit DEFAULT ((1)) NOT NULL,
PRIMARY KEY ([usersegmentid])
);

CREATE TABLE [dbo].[PV_UserValidatorApprovals] (
[validatorapprovalid] int NOT NULL IDENTITY(1,1),
[validatorid] int NOT NULL,
[approved] bit NOT NULL,
[comments] text,
[approvaldate] datetime DEFAULT (getdate()) NOT NULL,
[digitalsignature] varbinary(512) NOT NULL,
[validationId] int,
[validationStatusId] int,
PRIMARY KEY ([validatorapprovalid])
);

CREATE TABLE [dbo].[PV_TypesPerOrganization] (
[TypesPerOrganizationId] int NOT NULL IDENTITY(1,1),
[organizationId] int,
[OrganizationTypeId] int,
PRIMARY KEY ([TypesPerOrganizationId])
);

CREATE TABLE [dbo].[PV_RolePermissions] (
[rolepermissionid] int NOT NULL IDENTITY(1,1),
[enabled] bit NOT NULL,
[deleted] bit NOT NULL,
[lastupdate] datetime NOT NULL,
[checksum] varbinary(250) NOT NULL,
[roleid] int NOT NULL,
[permissionid] int NOT NULL,
PRIMARY KEY ([rolepermissionid])
);

CREATE TABLE [dbo].[PV_IdentityValidations] (
[validationid] int NOT NULL IDENTITY(1,1),
[validationdate] datetime DEFAULT (getdate()) NOT NULL,
[validationtype] varchar(30) NOT NULL,
[validationresult] varchar(20) NOT NULL,
[aivalidationresult] text,
[validationhash] varbinary(256) NOT NULL,
[workflowId] int,
PRIMARY KEY ([validationid])
);

CREATE TABLE [dbo].[PV_Balances] (
[balanceid] int NOT NULL IDENTITY(1,1),
[balance] real NOT NULL,
[lastbalance] real NOT NULL,
[lastupdate] datetime NOT NULL,
[checksum] varbinary(250) NOT NULL,
[freezeamount] real,
[userid] int NOT NULL,
[fundid] int NOT NULL,
PRIMARY KEY ([balanceid])
);

CREATE TABLE [dbo].[PV_RecurrencyType] (
[recurrencytypeid] int NOT NULL IDENTITY(1,1),
[name] varchar(30) NOT NULL,
PRIMARY KEY ([recurrencytypeid])
);

CREATE TABLE [dbo].[PV_DocumentTypes] (
[documentTypeId] int NOT NULL IDENTITY(1,1),
[name] varchar(100),
[description] varchar(300),
PRIMARY KEY ([documentTypeId])
);

CREATE TABLE [dbo].[PV_OrganizationAddresses] (
[orgaddressid] int NOT NULL IDENTITY(1,1),
[organizationid] int NOT NULL,
[addressid] int NOT NULL,
[addresstype] varchar(20) DEFAULT ('Headquarters') NOT NULL,
[isactive] bit DEFAULT ((1)) NOT NULL,
[assigneddate] datetime DEFAULT (getdate()) NOT NULL,
PRIMARY KEY ([orgaddressid])
);

CREATE TABLE [dbo].[PV_Organizations] (
[organizationid] int NOT NULL IDENTITY(1,1),
[name] varchar(50) NOT NULL,
[description] varchar(200),
[userid] int NOT NULL,
[createdAt] datetime NOT NULL,
[legalIdentification] varchar(16),
[OrganizationTypeId] int,
PRIMARY KEY ([organizationid])
);

CREATE TABLE [dbo].[PV_SegmentTypes] (
[segmenttypeid] int NOT NULL IDENTITY(1,1),
[name] varchar(30) NOT NULL,
[description] varchar(100),
PRIMARY KEY ([segmenttypeid])
);

CREATE TABLE [dbo].[PV_UserPermissions] (
[userpermissionid] int NOT NULL IDENTITY(1,1),
[enabled] bit NOT NULL,
[deleted] bit NOT NULL,
[lastupdate] datetime NOT NULL,
[checksum] varbinary(250) NOT NULL,
[userid] int NOT NULL,
[permissionid] int NOT NULL,
PRIMARY KEY ([userpermissionid])
);

CREATE TABLE [dbo].[PV_OrganizationDocuments] (
[orgDocumentId] int NOT NULL IDENTITY(1,1),
[documentid] int,
[organizationId] int,
PRIMARY KEY ([orgDocumentId])
);

CREATE TABLE [dbo].[PV_BlockchainParams] (
[blockChainParamsId] int NOT NULL IDENTITY(1,1),
[wallet_address] varchar(100) NOT NULL,
[wallet_private_key_encrypted] varbinary(510) NOT NULL,
[wallet_public] varchar(50) NOT NULL,
[blockchain_network] varchar(50) NOT NULL,
[blockchain_rpc_url] varchar(250) NOT NULL,
[blockchain_chain_id] int NOT NULL,
[blockchain_explorer_url] varchar(250) NOT NULL,
[gas_price_default] decimal(38,18) NOT NULL,
[gas_limit_default] bigint,
[gas_currency] varchar(50) NOT NULL,
PRIMARY KEY ([blockChainParamsId])
);

CREATE TABLE [dbo].[PV_OrganizationValidatorApprovals] (
[approvalid] int NOT NULL IDENTITY(1,1),
[validatorGroupId] int,
[approvedvalidators] int DEFAULT ((0)) NOT NULL,
[statusValidationId] int NOT NULL,
[createddate] datetime DEFAULT (getdate()) NOT NULL,
[completeddate] datetime,
[miniumApprovals] int,
[validationId] int,
PRIMARY KEY ([approvalid])
);

CREATE TABLE [dbo].[PV_UserRoles] (
[userroleid] int NOT NULL IDENTITY(1,1),
[userid] int,
[roleid] int,
[lastupdate] datetime,
[checksum] varbinary(250),
[enabled] bit NOT NULL,
[deleted] bit NOT NULL,
PRIMARY KEY ([userroleid])
);

CREATE TABLE [dbo].[PV_Permissions] (
[permissionid] int NOT NULL IDENTITY(1,1),
[description] varchar(100) NOT NULL,
[code] varchar(10) NOT NULL,
[moduleid] int NOT NULL,
PRIMARY KEY ([permissionid])
);

CREATE TABLE [dbo].[PV_periodicVerification] (
[periodicVerificationId] int NOT NULL IDENTITY(1,1),
[scheduleId] int,
[lastupdated] datetime,
[enabled] bit,
PRIMARY KEY ([periodicVerificationId])
);

CREATE TABLE [dbo].[PV_IdentityUserValidation] (
[userValidationId] int NOT NULL IDENTITY(1,1),
[userid] int,
[validationid] int,
PRIMARY KEY ([userValidationId])
);

CREATE TABLE [dbo].[PV_ProposalTypes] (
[proposaltypeid] int NOT NULL IDENTITY(1,1),
[name] varchar(50) NOT NULL,
[description] varchar(200),
[requiresgovernmentapproval] bit DEFAULT ((0)) NOT NULL,
[requiresvalidatorapproval] bit DEFAULT ((0)) NOT NULL,
[validatorcount] int DEFAULT ((1)) NOT NULL,
PRIMARY KEY ([proposaltypeid])
);

CREATE TABLE [dbo].[PV_workflows] (
[workflowId] int NOT NULL IDENTITY(1,1),
[name] varchar(50) NOT NULL,
[description] varchar(300) NOT NULL,
[endpoint] varchar(255) NOT NULL,
[workflowTypeId] int,
[params] nvarchar(max),
PRIMARY KEY ([workflowId])
);

CREATE TABLE [dbo].[PV_Payment] (
[paymentid] int NOT NULL IDENTITY(1,1),
[amount] bigint NOT NULL,
[actualamount] bigint NOT NULL,
[result] smallint NOT NULL,
[reference] varchar(100) NOT NULL,
[auth] varchar(60) NOT NULL,
[chargetoken] varbinary(250) NOT NULL,
[description] varchar(120),
[date] datetime NOT NULL,
[checksum] varbinary(250) NOT NULL,
[moduleid] int NOT NULL,
[paymentmethodid] int NOT NULL,
[availablemethodid] int NOT NULL,
[userid] int NOT NULL,
[error] varchar(120),
PRIMARY KEY ([paymentid])
);

CREATE TABLE [dbo].[PV_States] (
[stateid] int NOT NULL IDENTITY(1,1),
[name] varchar(60) NOT NULL,
[countryid] int NOT NULL,
PRIMARY KEY ([stateid])
);

CREATE TABLE [dbo].[PV_EndType] (
[endtypeid] int NOT NULL IDENTITY(1,1),
[name] varchar(30) NOT NULL,
PRIMARY KEY ([endtypeid])
);

CREATE TABLE [dbo].[PV_OrganizationTypes] (
[organizationTypeId] int NOT NULL IDENTITY(1,1),
[name] varchar(50) NOT NULL,
PRIMARY KEY ([organizationTypeId])
);

CREATE TABLE [dbo].[PV_ValidatorGroups] (
[validatorgroupid] int NOT NULL IDENTITY(1,1),
[name] varchar(100) NOT NULL,
[description] varchar(300),
[fees] decimal(5,2),
[equitypercentage] decimal(5,2),
[organizationid] int NOT NULL,
[isactive] bit DEFAULT ((1)) NOT NULL,
PRIMARY KEY ([validatorgroupid])
);

CREATE TABLE [dbo].[PV_ProposalValidations] (
[validationid] int NOT NULL IDENTITY(1,1),
[proposalid] int NOT NULL,
[validationdate] datetime DEFAULT (getdate()) NOT NULL,
[validationresult] varchar(20) NOT NULL,
[comments] text,
[validationhash] varbinary(256) NOT NULL,
[workflowid] int,
PRIMARY KEY ([validationid])
);

CREATE TABLE [dbo].[PV_ProposalDocuments] (
[proposalDocumentId] int NOT NULL IDENTITY(1,1),
[proposalid] int NOT NULL,
[documenthash] varbinary(256) NOT NULL,
[documentId] int,
PRIMARY KEY ([proposalDocumentId])
);

CREATE TABLE [dbo].[PV_VotingMetrics] (
[metricid] int NOT NULL IDENTITY(1,1),
[votingconfigid] int NOT NULL,
[metrictypeId] int NOT NULL,
[metricname] varchar(50) NOT NULL,
[metricvalue] decimal(18,4) NOT NULL,
[stringvalue] varchar(200),
[segmentid] int,
[calculateddate] datetime DEFAULT (getdate()) NOT NULL,
[isactive] bit DEFAULT ((1)) NOT NULL,
[workflowId] int,
PRIMARY KEY ([metricid])
);

CREATE TABLE [dbo].[PV_ProposalRequirementValues] (
[valuekey] int NOT NULL IDENTITY(1,1),
[proposalid] int NOT NULL,
[requirementid] int NOT NULL,
[textvalue] text,
[numbervalue] decimal(18,4),
[datevalue] datetime,
[filevalue] varchar(500),
PRIMARY KEY ([valuekey])
);

CREATE TABLE [dbo].[PV_Schedules] (
[scheduleid] int NOT NULL IDENTITY(1,1),
[name] varchar(45) NOT NULL,
[repetitions] int NOT NULL,
[enddate] datetime NOT NULL,
[recurrencytypeid] int NOT NULL,
[endtypeid] int NOT NULL,
PRIMARY KEY ([scheduleid])
);

CREATE TABLE [dbo].[PV_VotingOptions] (
[optionid] int NOT NULL IDENTITY(1,1),
[votingconfigid] int NOT NULL,
[optiontext] varchar(200) NOT NULL,
[optionorder] int NOT NULL,
[questionId] int NOT NULL,
[mediafileId] int,
PRIMARY KEY ([optionid])
);

CREATE TABLE [dbo].[PV_UserMFA] (
[usermfaid] int NOT NULL IDENTITY(1,1),
[userid] int NOT NULL,
[MFAid] int NOT NULL,
PRIMARY KEY ([usermfaid])
);

CREATE TABLE [dbo].[PV_ExecutionPlans] (
[executionplanid] int NOT NULL IDENTITY(1,1),
[proposalid] int NOT NULL,
[totalbudget] decimal(18,2) NOT NULL,
[startdate] datetime NOT NULL,
[expectedenddate] datetime NOT NULL,
[createddate] datetime DEFAULT (getdate()) NOT NULL,
PRIMARY KEY ([executionplanid])
);

CREATE TABLE [dbo].[PV_DocumentSections] (
[sectionId] int NOT NULL IDENTITY(1,1),
[documentId] int,
[title] varchar(50),
[summary] text,
PRIMARY KEY ([sectionId])
);

CREATE TABLE [dbo].[PV_VotingConfigurations] (
[votingconfigid] int NOT NULL IDENTITY(1,1),
[proposalid] int NOT NULL,
[startdate] datetime NOT NULL,
[enddate] datetime NOT NULL,
[votingtypeId] int NOT NULL,
[allowweightedvotes] bit DEFAULT ((0)) NOT NULL,
[requiresallvoters] bit DEFAULT ((0)) NOT NULL,
[notificationmethodid] int,
[userid] int NOT NULL,
[configureddate] datetime DEFAULT (getdate()) NOT NULL,
[statusid] int DEFAULT ((1)) NOT NULL,
[publisheddate] datetime,
[finalizeddate] datetime,
[publicVoting] bit,
PRIMARY KEY ([votingconfigid])
);

CREATE TABLE [dbo].[PV_mediafiles] (
[mediafileid] int NOT NULL IDENTITY(1,1),
[mediapath] varchar(300),
[deleted] bit,
[lastupdate] datetime,
[userid] int,
[mediatypeid] int,
[sizeMB] int,
[encoding] varchar(20),
[samplerate] int,
[languagecode] varchar(10),
PRIMARY KEY ([mediafileid])
);

CREATE TABLE [dbo].[PV_VoteResults] (
[resultid] int NOT NULL IDENTITY(1,1),
[votingconfigid] int NOT NULL,
[optionid] int NOT NULL,
[votecount] int DEFAULT ((0)) NOT NULL,
[weightedcount] decimal(10,2) DEFAULT ((0)) NOT NULL,
[lastupdated] datetime DEFAULT (getdate()) NOT NULL,
PRIMARY KEY ([resultid])
);

CREATE TABLE [dbo].[PV_CryptoKeys] (
[keyid] int NOT NULL IDENTITY(1,1),
[publickey] varbinary(max) NOT NULL,
[privatekey] varbinary(max) NOT NULL,
[createdAt] datetime NOT NULL,
[userid] int,
[organizationid] int,
[expirationdate] datetime NOT NULL,
[status] varchar(20) NOT NULL,
PRIMARY KEY ([keyid])
);

CREATE TABLE [dbo].[PV_AIAnalysisType] (
[analysisTypeId] int NOT NULL IDENTITY(1,1),
[name] varchar(50),
PRIMARY KEY ([analysisTypeId])
);

CREATE TABLE [dbo].[PV_DividendDistributions] (
[distributionid] int NOT NULL IDENTITY(1,1),
[proposalid] int NOT NULL,
[reportid] int NOT NULL,
[totaldividends] decimal(18,2) NOT NULL,
[distributiondate] datetime NOT NULL,
[processedby] int NOT NULL,
[distributionhash] varbinary(256) NOT NULL,
[workflowId] int,
PRIMARY KEY ([distributionid])
);

CREATE TABLE [dbo].[PV_executionStepType] (
[executionStepTypeId] int NOT NULL IDENTITY(1,1),
[name] varchar(50) NOT NULL,
PRIMARY KEY ([executionStepTypeId])
);

CREATE TABLE [dbo].[PV_VotingMetricsType] (
[VotingMetricTypeId] int NOT NULL IDENTITY(1,1),
[name] varchar(50),
PRIMARY KEY ([VotingMetricTypeId])
);

CREATE TABLE [dbo].[PV_OrganizationRoles] (
[orgrolemappingid] int NOT NULL IDENTITY(1,1),
[organizationid] int NOT NULL,
[roleid] int NOT NULL,
[enabled] bit DEFAULT ((1)) NOT NULL,
[deleted] bit DEFAULT ((0)) NOT NULL,
[assigneddate] datetime DEFAULT (getdate()) NOT NULL,
[lastupdate] datetime DEFAULT (getdate()) NOT NULL,
[checksum] varbinary(250) NOT NULL,
PRIMARY KEY ([orgrolemappingid])
);

CREATE TABLE [dbo].[PV_OrganizationPermissions] (
[orgpermissionid] int NOT NULL IDENTITY(1,1),
[organizationid] int NOT NULL,
[permissionid] int NOT NULL,
[enabled] bit DEFAULT ((1)) NOT NULL,
[deleted] bit DEFAULT ((0)) NOT NULL,
[assigneddate] datetime DEFAULT (getdate()) NOT NULL,
[lastupdate] datetime DEFAULT (getdate()) NOT NULL,
[checksum] varbinary(250) NOT NULL,
PRIMARY KEY ([orgpermissionid])
);

CREATE TABLE [dbo].[PV_VotingTargetSegments] (
[targetsegmentid] int NOT NULL IDENTITY(1,1),
[votingconfigid] int NOT NULL,
[segmentid] int NOT NULL,
[voteweight] decimal(5,2) DEFAULT ((1.0)) NOT NULL,
[assigneddate] datetime DEFAULT (getdate()) NOT NULL,
PRIMARY KEY ([targetsegmentid])
);

CREATE TABLE [dbo].[PV_Documents] (
[documentid] int NOT NULL IDENTITY(1,1),
[documenthash] varbinary(256) NOT NULL,
[aivalidationstatus] varchar(20) DEFAULT ('Pending') NOT NULL,
[aivalidationresult] text,
[humanvalidationrequired] bit DEFAULT ((0)) NOT NULL,
[mediafileId] int,
[periodicVerificationId] int,
[documentTypeId] int,
[version] int,
PRIMARY KEY ([documentid])
);

CREATE TABLE [dbo].[PV_Translation] (
[translationid] int NOT NULL IDENTITY(1,1),
[code] varchar(20) NOT NULL,
[caption] text NOT NULL,
[enabled] bit NOT NULL,
[languageid] int NOT NULL,
[moduleid] int NOT NULL,
PRIMARY KEY ([translationid])
);

CREATE TABLE [dbo].[PV_InvestmentAgreements] (
[agreementId] int NOT NULL IDENTITY(1,1),
[name] varchar(50) NOT NULL,
[description] varchar(500) NOT NULL,
[signatureDate] datetime,
[totalamount] decimal(18,0),
[investmentId] int,
[documentId] int,
PRIMARY KEY ([agreementId])
);

CREATE TABLE [dbo].[PV_Addresses] (
[addressid] int NOT NULL IDENTITY(1,1),
[line1] varchar(200) NOT NULL,
[line2] varchar(200),
[zipcode] varchar(8) NOT NULL,
[geoposition] sys.geometry NOT NULL,
[cityid] int NOT NULL,
PRIMARY KEY ([addressid])
);

CREATE TABLE [dbo].[PV_FinancialReports] (
[reportid] int NOT NULL IDENTITY(1,1),
[proposalid] int NOT NULL,
[reportperiod] varchar(20) NOT NULL,
[totalrevenue] decimal(18,2) NOT NULL,
[totalexpenses] decimal(18,2) NOT NULL,
[netprofit] decimal(18,2) NOT NULL,
[availablefordividends] decimal(18,2) NOT NULL,
[reportfile] varchar(500),
[submitteddate] datetime DEFAULT (getdate()) NOT NULL,
[approvedby] int,
[approveddate] datetime,
[workflowId] int,
[documentId] int,
PRIMARY KEY ([reportid])
);

CREATE TABLE [dbo].[PV_Logs] (
[logid] int NOT NULL IDENTITY(1,1),
[description] varchar(120) NOT NULL,
[name] varchar(50) NOT NULL,
[posttime] datetime NOT NULL,
[computer] varchar(45) NOT NULL,
[trace] varchar(200) NOT NULL,
[referenceid1] bigint,
[referenceid2] bigint,
[checksum] varbinary(250) NOT NULL,
[logtypeid] int NOT NULL,
[logsourceid] int NOT NULL,
[logseverityid] int NOT NULL,
PRIMARY KEY ([logid])
);

CREATE TABLE [dbo].[PV_Modules] (
[moduleid] int NOT NULL IDENTITY(1,1),
[name] varchar(40) NOT NULL,
PRIMARY KEY ([moduleid])
);

CREATE TABLE [dbo].[PV_AIProviders] (
[providerid] int NOT NULL IDENTITY(1,1),
[name] varchar(100) NOT NULL,
[baseurl] varchar(500) NOT NULL,
[description] varchar(300),
[isactive] bit DEFAULT ((1)) NOT NULL,
[ratelimitrpm] int,
[ratelimittpm] bigint,
[supportedmodels] text,
[createdate] datetime DEFAULT (getdate()) NOT NULL,
PRIMARY KEY ([providerid])
);

CREATE TABLE [dbo].[PV_AIModels] (
[modelid] int NOT NULL IDENTITY(1,1),
[providerid] int NOT NULL,
[modelname] varchar(100) NOT NULL,
[displayname] varchar(150) NOT NULL,
[modeltypeId] int NOT NULL,
[maxinputtokens] int NOT NULL,
[maxoutputtokens] int NOT NULL,
[costperinputtoken] decimal(10,8) NOT NULL,
[costperoutputtoken] decimal(10,8) NOT NULL,
[isactive] bit DEFAULT ((1)) NOT NULL,
[capabilities] text,
[createdate] datetime DEFAULT (getdate()) NOT NULL,
PRIMARY KEY ([modelid])
);

CREATE TABLE [dbo].[PV_DividendPayments] (
[dividendpaymentid] int NOT NULL IDENTITY(1,1),
[distributionid] int NOT NULL,
[investmentid] int NOT NULL,
[amount] decimal(18,2) NOT NULL,
[paymentid] int NOT NULL,
[paymentdate] datetime DEFAULT (getdate()) NOT NULL,
[workflowId] int,
PRIMARY KEY ([dividendpaymentid])
);

CREATE TABLE [dbo].[PV_executionPlanSteps] (
[planStepId] int NOT NULL IDENTITY(1,1),
[executionPlanId] int,
[stepIndex] int,
[description] varchar(100) NOT NULL,
[stepTypeId] int,
[estimatedInitDate] datetime,
[estimatedEndDate] datetime,
PRIMARY KEY ([planStepId])
);

CREATE TABLE [dbo].[PV_NotificationSettings] (
[notificationsettingid] int NOT NULL IDENTITY(1,1),
[userid] int,
[organizationid] int,
[notificationmethodid] int NOT NULL,
[isenabled] bit DEFAULT ((1)) NOT NULL,
[starttime] time(7),
[endtime] time(7),
[alloweddays] varchar(20),
[ipwhitelist] varchar(500),
[frequency] varchar(20) DEFAULT ('Immediate') NOT NULL,
[lastnotification] datetime,
[createddate] datetime DEFAULT (getdate()) NOT NULL,
PRIMARY KEY ([notificationsettingid])
);

CREATE TABLE [dbo].[PV_UserInvestments] (
[userInvestmentId] int NOT NULL IDENTITY(1,1),
[userId] int,
[investmentAgreementId] int,
PRIMARY KEY ([userInvestmentId])
);

CREATE TABLE [dbo].[PV_OrganizationInvestments] (
[organizationInvesmentId] int NOT NULL IDENTITY(1,1),
[organizationId] int,
[investmentAgreementId] int,
PRIMARY KEY ([organizationInvesmentId])
);

CREATE TABLE [dbo].[PV_blockchain] (
[blockchainId] int NOT NULL IDENTITY(1,1),
[blockchainParamsId] int,
PRIMARY KEY ([blockchainId])
);

CREATE TABLE [dbo].[PV_BlockChainConnections] (
[connectionId] int NOT NULL IDENTITY(1,1),
[blockchainId] int,
[workflowId] int,
PRIMARY KEY ([connectionId])
);


ALTER TABLE [dbo].[PV_Transactions]
ADD CONSTRAINT [FK_PV_Transactions_PV_Funds]
FOREIGN KEY ([fundid]) 
REFERENCES [dbo].[PV_Funds]([fundid])





ALTER TABLE [dbo].[PV_Transactions]
ADD CONSTRAINT [FK_PV_Transactions_PV_Currency]
FOREIGN KEY ([currencyid]) 
REFERENCES [dbo].[PV_Currency]([currencyid])





ALTER TABLE [dbo].[PV_Transactions]
ADD CONSTRAINT [FK_PV_Transactions_PV_ExchangeRate]
FOREIGN KEY ([exchangerateid]) 
REFERENCES [dbo].[PV_ExchangeRate]([exchangeRateid])





ALTER TABLE [dbo].[PV_Transactions]
ADD CONSTRAINT [FK_PV_Transactions_PV_Balances]
FOREIGN KEY ([balanceid]) 
REFERENCES [dbo].[PV_Balances]([balanceid])





ALTER TABLE [dbo].[PV_Transactions]
ADD CONSTRAINT [FK_PV_Transactions_PV_Payment]
FOREIGN KEY ([paymentid]) 
REFERENCES [dbo].[PV_Payment]([paymentid])





ALTER TABLE [dbo].[PV_Transactions]
ADD CONSTRAINT [FK_PV_Transactions_PV_Schedules]
FOREIGN KEY ([scheduleid]) 
REFERENCES [dbo].[PV_Schedules]([scheduleid])





ALTER TABLE [dbo].[PV_Transactions]
ADD CONSTRAINT [FK_PV_Transactions_PV_TransSubTypes]
FOREIGN KEY ([transsubtypeid]) 
REFERENCES [dbo].[PV_TransSubTypes]([transsubtypeid])





ALTER TABLE [dbo].[PV_Transactions]
ADD CONSTRAINT [FK_PV_Transactions_PV_TransType]
FOREIGN KEY ([transtypeid]) 
REFERENCES [dbo].[PV_TransType]([transtypeid])





ALTER TABLE [dbo].[PV_ExchangeRate]
ADD CONSTRAINT [FK_PV_ExchangeRate_PV_Currency_Source]
FOREIGN KEY ([sourceCurrencyid]) 
REFERENCES [dbo].[PV_Currency]([currencyid])





ALTER TABLE [dbo].[PV_ExchangeRate]
ADD CONSTRAINT [FK_PV_ExchangeRate_PV_Currency_Destiny]
FOREIGN KEY ([destinyCurrencyId]) 
REFERENCES [dbo].[PV_Currency]([currencyid])





ALTER TABLE [dbo].[PV_AllowedCountries]
ADD CONSTRAINT [FK_PV_AllowedCountries_PV_Countries]
FOREIGN KEY ([countryid]) 
REFERENCES [dbo].[PV_Countries]([countryid])





ALTER TABLE [dbo].[PV_Investments]
ADD CONSTRAINT [FK_PV_Investments_PV_Proposals]
FOREIGN KEY ([proposalid]) 
REFERENCES [dbo].[PV_Proposals]([proposalid])





ALTER TABLE [dbo].[PV_OrganizationPerUser]
ADD CONSTRAINT [FK_UserOrganizations]
FOREIGN KEY ([userId]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_OrganizationPerUser]
ADD CONSTRAINT [FK_UserOrganizations_Org]
FOREIGN KEY ([organizationId]) 
REFERENCES [dbo].[PV_Organizations]([organizationid])





ALTER TABLE [dbo].[PV_UserDocuments]
ADD CONSTRAINT [FK_UserDocuments_Users]
FOREIGN KEY ([userId]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_UserDocuments]
ADD CONSTRAINT [FK_UserDocuments_Documents]
FOREIGN KEY ([documentid]) 
REFERENCES [dbo].[PV_Documents]([documentid])





ALTER TABLE [dbo].[PV_AIConnections]
ADD CONSTRAINT [FK_PV_AIConnections_PV_Users]
FOREIGN KEY ([createdby]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_AIConnections]
ADD CONSTRAINT [FK_PV_AIConnections_PV_AIProviders]
FOREIGN KEY ([providerid]) 
REFERENCES [dbo].[PV_AIProviders]([providerid])





ALTER TABLE [dbo].[PV_AIConnections]
ADD CONSTRAINT [FK_organizationId_AIConnections]
FOREIGN KEY ([organizationid]) 
REFERENCES [dbo].[PV_Organizations]([organizationid])





ALTER TABLE [dbo].[PV_ProposalComments]
ADD CONSTRAINT [FK_PV_ProposalComments_PV_Users_Reviewer]
FOREIGN KEY ([reviewedby]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_ProposalComments]
ADD CONSTRAINT [FK_PV_ProposalComments_PV_Proposals]
FOREIGN KEY ([proposalid]) 
REFERENCES [dbo].[PV_Proposals]([proposalid])





ALTER TABLE [dbo].[PV_ProposalComments]
ADD CONSTRAINT [FK_PV_ProposalComments_PV_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_AvailableMethods]
ADD CONSTRAINT [FK_PV_AvailableMethods_PV_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_AvailableMethods]
ADD CONSTRAINT [FK_PV_AvailableMethods_PV_PaymentMethods]
FOREIGN KEY ([paymentmethodid]) 
REFERENCES [dbo].[PV_PaymentMethods]([paymentmethodid])





ALTER TABLE [dbo].[PV_investmentSteps]
ADD CONSTRAINT [FK_InvesmentStep_PaymentId]
FOREIGN KEY ([paymentId]) 
REFERENCES [dbo].[PV_Payment]([paymentid])





ALTER TABLE [dbo].[PV_investmentSteps]
ADD CONSTRAINT [FK_InvestmentAgreementID_invesmentStep]
FOREIGN KEY ([investmentAgreementId]) 
REFERENCES [dbo].[PV_InvestmentAgreements]([agreementId])





ALTER TABLE [dbo].[PV_documentAnalysis_workflow]
ADD CONSTRAINT [FK_AnalysisDocument_WorkFlow]
FOREIGN KEY ([workflowId]) 
REFERENCES [dbo].[PV_workflows]([workflowId])





ALTER TABLE [dbo].[PV_documentAnalysis_workflow]
ADD CONSTRAINT [FK_AnalysisType_AIAnalyDocType]
FOREIGN KEY ([analysisDocTypeId]) 
REFERENCES [dbo].[PV_AIAnalysisType]([analysisTypeId])





ALTER TABLE [dbo].[PV_documentAnalysis_workflow]
ADD CONSTRAINT [FK_PV_AIDocumentAnalysis_PV_UserDocuments]
FOREIGN KEY ([documentid]) 
REFERENCES [dbo].[PV_Documents]([documentid])





ALTER TABLE [dbo].[PV_documentAnalysis_workflow]
ADD CONSTRAINT [FK_PV_AIDocumentAnalysis_PV_Users]
FOREIGN KEY ([reviewerid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_PublicVote]
ADD CONSTRAINT [FK_PublicVote_Tousers]
FOREIGN KEY ([userId]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_PublicVote]
ADD CONSTRAINT [FK_PublicVote_Votes]
FOREIGN KEY ([voteId]) 
REFERENCES [dbo].[PV_Votes]([voteid])





ALTER TABLE [dbo].[PV_ValidationRules]
ADD CONSTRAINT [FK_PV_ValidationRules_PV_ProposalTypes]
FOREIGN KEY ([proposaltypeid]) 
REFERENCES [dbo].[PV_ProposalTypes]([proposaltypeid])





ALTER TABLE [dbo].[PV_Users]
ADD CONSTRAINT [FK_genderId_Users]
FOREIGN KEY ([genderId]) 
REFERENCES [dbo].[PV_Genders]([genderId])





ALTER TABLE [dbo].[PV_Users]
ADD CONSTRAINT [FK_Users_UserStatus]
FOREIGN KEY ([userStatusId]) 
REFERENCES [dbo].[PV_UserStatus]([userStatusId])





ALTER TABLE [dbo].[PV_Countries]
ADD CONSTRAINT [FK_PV_Countries_PV_Currency]
FOREIGN KEY ([currencyid]) 
REFERENCES [dbo].[PV_Currency]([currencyid])





ALTER TABLE [dbo].[PV_Countries]
ADD CONSTRAINT [FK_PV_Countries_PV_Languages]
FOREIGN KEY ([languageid]) 
REFERENCES [dbo].[PV_Languages]([languageid])





ALTER TABLE [dbo].[PV_Cities]
ADD CONSTRAINT [FK_PV_Cities_PV_States]
FOREIGN KEY ([stateid]) 
REFERENCES [dbo].[PV_States]([stateid])





ALTER TABLE [dbo].[PV_ProjectMonitoring]
ADD CONSTRAINT [FK_PV_ProjectMonitoring_PV_Users_Reviewer]
FOREIGN KEY ([reviewedby]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_ProjectMonitoring]
ADD CONSTRAINT [FK_PV_ProjectMonitoring_PV_Proposals]
FOREIGN KEY ([proposalid]) 
REFERENCES [dbo].[PV_Proposals]([proposalid])





ALTER TABLE [dbo].[PV_ProjectMonitoring]
ADD CONSTRAINT [FK_PV_ProjectMonitoring_PV_Users]
FOREIGN KEY ([reportedby]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_PopulationSegments]
ADD CONSTRAINT [FK_PV_PopulationSegments_PV_SegmentTypes]
FOREIGN KEY ([segmenttypeid]) 
REFERENCES [dbo].[PV_SegmentTypes]([segmenttypeid])





ALTER TABLE [dbo].[PV_VoterRegistry]
ADD CONSTRAINT [FK_PV_VoterRegistry_PV_VotingConfigurations]
FOREIGN KEY ([votingconfigid]) 
REFERENCES [dbo].[PV_VotingConfigurations]([votingconfigid])





ALTER TABLE [dbo].[PV_VoterRegistry]
ADD CONSTRAINT [FK_PV_VoterRegistry_PV_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_IdentityOrganizationValidation]
ADD CONSTRAINT [FK_PV_IdentityOrgValidation_Validation]
FOREIGN KEY ([validationId]) 
REFERENCES [dbo].[PV_IdentityValidations]([validationid])





ALTER TABLE [dbo].[PV_IdentityOrganizationValidation]
ADD CONSTRAINT [FK_Organization_IdentityValidation]
FOREIGN KEY ([organizationid]) 
REFERENCES [dbo].[PV_Organizations]([organizationid])





ALTER TABLE [dbo].[PV_OrgMFA]
ADD CONSTRAINT [FK_PV_OrgMFA_PV_MFA]
FOREIGN KEY ([MFAid]) 
REFERENCES [dbo].[PV_MFA]([MFAid])





ALTER TABLE [dbo].[PV_OrgMFA]
ADD CONSTRAINT [FK_PV_OrgMFA_PV_Organizations]
FOREIGN KEY ([organizationid]) 
REFERENCES [dbo].[PV_Organizations]([organizationid])





ALTER TABLE [dbo].[PV_MFA]
ADD CONSTRAINT [FK_PV_MFA_PV_MFAMethods]
FOREIGN KEY ([MFAmethodid]) 
REFERENCES [dbo].[PV_MFAMethods]([MFAmethodid])





ALTER TABLE [dbo].[PV_EligibleVoters]
ADD CONSTRAINT [FK_PV_EligibleVoters_PV_VotingConfigurations]
FOREIGN KEY ([votingconfigid]) 
REFERENCES [dbo].[PV_VotingConfigurations]([votingconfigid])





ALTER TABLE [dbo].[PV_EligibleVoters]
ADD CONSTRAINT [FK_PV_EligibleVoters_PV_PopulationSegments]
FOREIGN KEY ([segmentid]) 
REFERENCES [dbo].[PV_PopulationSegments]([segmentid])





ALTER TABLE [dbo].[PV_authSession]
ADD CONSTRAINT [FK_Users_UserSessions]
FOREIGN KEY ([userId]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_authSession]
ADD CONSTRAINT [FK_Authsessions_AuthPlatforms]
FOREIGN KEY ([authPlatformId]) 
REFERENCES [dbo].[PV_AuthPlatforms]([authPlatformId])





ALTER TABLE [dbo].[PV_proposalCommentDocuments]
ADD CONSTRAINT [FK_proposalCommentsId_documentId]
FOREIGN KEY ([documentId]) 
REFERENCES [dbo].[PV_Documents]([documentid])





ALTER TABLE [dbo].[PV_proposalCommentDocuments]
ADD CONSTRAINT [FK_proposalCommentId_proposalComments]
FOREIGN KEY ([commentId]) 
REFERENCES [dbo].[PV_ProposalComments]([commentid])





ALTER TABLE [dbo].[PV_ProposalRequirements]
ADD CONSTRAINT [FK_PV_ProposalRequirements_PV_ProposalTypes]
FOREIGN KEY ([proposaltypeid]) 
REFERENCES [dbo].[PV_ProposalTypes]([proposaltypeid])





ALTER TABLE [dbo].[PV_ProposalRequirements]
ADD CONSTRAINT [FK_PV_ProposalRequirements_PV_ProposalRequirementTypes]
FOREIGN KEY ([requirementtypeid]) 
REFERENCES [dbo].[PV_ProposalRequirementTypes]([requirementtypeid])





ALTER TABLE [dbo].[PV_AllowedIPs]
ADD CONSTRAINT [FK_PV_AllowedIPs_PV_Countries]
FOREIGN KEY ([countryid]) 
REFERENCES [dbo].[PV_Countries]([countryid])





ALTER TABLE [dbo].[PV_AIProposalAnalysis]
ADD CONSTRAINT [FK_AnalysisType_ProposalAIAnaylsisType]
FOREIGN KEY ([analysistype]) 
REFERENCES [dbo].[PV_AIAnalysisType]([analysisTypeId])





ALTER TABLE [dbo].[PV_AIProposalAnalysis]
ADD CONSTRAINT [FK_PV_AIProposalAnalysis_PV_Users]
FOREIGN KEY ([reviewerid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_AIProposalAnalysis]
ADD CONSTRAINT [FK_ProposalValidationId_ProposalAnalysis]
FOREIGN KEY ([validationId]) 
REFERENCES [dbo].[PV_ProposalValidations]([validationid])





ALTER TABLE [dbo].[PV_AIProposalAnalysis]
ADD CONSTRAINT [FK_AIProposalAnalysis_Workflow]
FOREIGN KEY ([workflowId]) 
REFERENCES [dbo].[PV_workflows]([workflowId])





ALTER TABLE [dbo].[PV_AIProposalAnalysis]
ADD CONSTRAINT [FK_PV_AIProposalAnalysis_PV_Proposals]
FOREIGN KEY ([proposalid]) 
REFERENCES [dbo].[PV_Proposals]([proposalid])





ALTER TABLE [dbo].[PV_Proposals]
ADD CONSTRAINT [FK_PV_Proposals_PV_Organizations]
FOREIGN KEY ([organizationid]) 
REFERENCES [dbo].[PV_Organizations]([organizationid])





ALTER TABLE [dbo].[PV_Proposals]
ADD CONSTRAINT [FK_PV_Proposals_PV_Users]
FOREIGN KEY ([createdby]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_Proposals]
ADD CONSTRAINT [FK_PV_Proposals_PV_ProposalStatus]
FOREIGN KEY ([statusid]) 
REFERENCES [dbo].[PV_ProposalStatus]([statusid])





ALTER TABLE [dbo].[PV_Proposals]
ADD CONSTRAINT [FK_PV_Proposals_PV_ProposalTypes]
FOREIGN KEY ([proposaltypeid]) 
REFERENCES [dbo].[PV_ProposalTypes]([proposaltypeid])





ALTER TABLE [dbo].[PV_ProposalVersions]
ADD CONSTRAINT [FK_PV_ProposalVersions_PV_Proposals]
FOREIGN KEY ([proposalid]) 
REFERENCES [dbo].[PV_Proposals]([proposalid])





ALTER TABLE [dbo].[PV_ProposalVersions]
ADD CONSTRAINT [FK_PV_ProposalVersions_PV_Users]
FOREIGN KEY ([createdby]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_UserAddresses]
ADD CONSTRAINT [FK_PV_UserAddresses_PV_Addresses]
FOREIGN KEY ([addressid]) 
REFERENCES [dbo].[PV_Addresses]([addressid])





ALTER TABLE [dbo].[PV_UserAddresses]
ADD CONSTRAINT [FK_PV_UserAddresses_PV_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_Votes]
ADD CONSTRAINT [FK_PV_Votes_PV_VotingConfigurations]
FOREIGN KEY ([votingconfigid]) 
REFERENCES [dbo].[PV_VotingConfigurations]([votingconfigid])





ALTER TABLE [dbo].[PV_Votes]
ADD CONSTRAINT [FK_Votes_blockchain]
FOREIGN KEY ([blockchainId]) 
REFERENCES [dbo].[PV_blockchain]([blockchainId])





ALTER TABLE [dbo].[PV_UserSegments]
ADD CONSTRAINT [FK_PV_UserSegments_PV_PopulationSegments]
FOREIGN KEY ([segmentid]) 
REFERENCES [dbo].[PV_PopulationSegments]([segmentid])





ALTER TABLE [dbo].[PV_UserSegments]
ADD CONSTRAINT [FK_PV_UserSegments_PV_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_UserValidatorApprovals]
ADD CONSTRAINT [FK_ValidatioNStatusId_UserValidator]
FOREIGN KEY ([validationStatusId]) 
REFERENCES [dbo].[PV_ValidationStatus]([statusValidationId])





ALTER TABLE [dbo].[PV_UserValidatorApprovals]
ADD CONSTRAINT [FK_PV_ValidatorApprovals_PV_Users]
FOREIGN KEY ([validatorid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_UserValidatorApprovals]
ADD CONSTRAINT [FK_UserValidatorApprovals_ProposalValidations]
FOREIGN KEY ([validationId]) 
REFERENCES [dbo].[PV_ProposalValidations]([validationid])





ALTER TABLE [dbo].[PV_TypesPerOrganization]
ADD CONSTRAINT [FK_OrganizatioNTypes_TypesPerOrganization]
FOREIGN KEY ([OrganizationTypeId]) 
REFERENCES [dbo].[PV_OrganizationTypes]([organizationTypeId])





ALTER TABLE [dbo].[PV_TypesPerOrganization]
ADD CONSTRAINT [FK_Organizatio_TypesPerOrganization]
FOREIGN KEY ([organizationId]) 
REFERENCES [dbo].[PV_Organizations]([organizationid])





ALTER TABLE [dbo].[PV_RolePermissions]
ADD CONSTRAINT [FK_PV_RolePermissions_PV_Roles]
FOREIGN KEY ([roleid]) 
REFERENCES [dbo].[PV_Roles]([roleid])





ALTER TABLE [dbo].[PV_RolePermissions]
ADD CONSTRAINT [FK_PV_RolePermissions_PV_Permissions]
FOREIGN KEY ([permissionid]) 
REFERENCES [dbo].[PV_Permissions]([permissionid])





ALTER TABLE [dbo].[PV_IdentityValidations]
ADD CONSTRAINT [FK_IdentityValidations_Workflow]
FOREIGN KEY ([workflowId]) 
REFERENCES [dbo].[PV_workflows]([workflowId])





ALTER TABLE [dbo].[PV_Balances]
ADD CONSTRAINT [FK_PV_Balances_PV_Funds]
FOREIGN KEY ([fundid]) 
REFERENCES [dbo].[PV_Funds]([fundid])





ALTER TABLE [dbo].[PV_Balances]
ADD CONSTRAINT [FK_PV_Balances_PV_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_OrganizationAddresses]
ADD CONSTRAINT [FK_PV_OrganizationAddresses_PV_Addresses]
FOREIGN KEY ([addressid]) 
REFERENCES [dbo].[PV_Addresses]([addressid])





ALTER TABLE [dbo].[PV_OrganizationAddresses]
ADD CONSTRAINT [FK_PV_OrganizationAddresses_PV_Organizations]
FOREIGN KEY ([organizationid]) 
REFERENCES [dbo].[PV_Organizations]([organizationid])





ALTER TABLE [dbo].[PV_Organizations]
ADD CONSTRAINT [FK_PV_Organizations_PV_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_UserPermissions]
ADD CONSTRAINT [FK_PV_UserPermissions_PV_Permissions]
FOREIGN KEY ([permissionid]) 
REFERENCES [dbo].[PV_Permissions]([permissionid])





ALTER TABLE [dbo].[PV_UserPermissions]
ADD CONSTRAINT [FK_PV_UserPermissions_PV_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_OrganizationDocuments]
ADD CONSTRAINT [FK_OrgDocuments_documents]
FOREIGN KEY ([documentid]) 
REFERENCES [dbo].[PV_Documents]([documentid])





ALTER TABLE [dbo].[PV_OrganizationDocuments]
ADD CONSTRAINT [FK_OrgDocs_Org]
FOREIGN KEY ([organizationId]) 
REFERENCES [dbo].[PV_Organizations]([organizationid])





ALTER TABLE [dbo].[PV_OrganizationValidatorApprovals]
ADD CONSTRAINT [FK_OrganizationValidatorGroups_ProposalValidations]
FOREIGN KEY ([validationId]) 
REFERENCES [dbo].[PV_ProposalValidations]([validationid])





ALTER TABLE [dbo].[PV_OrganizationValidatorApprovals]
ADD CONSTRAINT [FK_ValidatioNStatus_ValidationOrg]
FOREIGN KEY ([statusValidationId]) 
REFERENCES [dbo].[PV_ValidationStatus]([statusValidationId])





ALTER TABLE [dbo].[PV_OrganizationValidatorApprovals]
ADD CONSTRAINT [FK_ValidatorGroups_ORganizationValidatorAppro]
FOREIGN KEY ([validatorGroupId]) 
REFERENCES [dbo].[PV_ValidatorGroups]([validatorgroupid])





ALTER TABLE [dbo].[PV_UserRoles]
ADD CONSTRAINT [FK_PV_UserRoles_PV_Roles]
FOREIGN KEY ([roleid]) 
REFERENCES [dbo].[PV_Roles]([roleid])





ALTER TABLE [dbo].[PV_UserRoles]
ADD CONSTRAINT [FK_PV_UserRoles_PV_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_Permissions]
ADD CONSTRAINT [FK_PV_Permissions_PV_Modules]
FOREIGN KEY ([moduleid]) 
REFERENCES [dbo].[PV_Modules]([moduleid])





ALTER TABLE [dbo].[PV_periodicVerification]
ADD CONSTRAINT [FK_scheduleId_schedule]
FOREIGN KEY ([scheduleId]) 
REFERENCES [dbo].[PV_Schedules]([scheduleid])





ALTER TABLE [dbo].[PV_IdentityUserValidation]
ADD CONSTRAINT [FK_UserValidation_user]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_IdentityUserValidation]
ADD CONSTRAINT [FK_user_PV_IdentityUserValidation]
FOREIGN KEY ([validationid]) 
REFERENCES [dbo].[PV_IdentityValidations]([validationid])





ALTER TABLE [dbo].[PV_workflows]
ADD CONSTRAINT [FK_workflows_workflowTypes]
FOREIGN KEY ([workflowTypeId]) 
REFERENCES [dbo].[PV_workflowsType]([workflowTypeId])





ALTER TABLE [dbo].[PV_Payment]
ADD CONSTRAINT [FK_PV_Payment_PV_Modules]
FOREIGN KEY ([moduleid]) 
REFERENCES [dbo].[PV_Modules]([moduleid])





ALTER TABLE [dbo].[PV_Payment]
ADD CONSTRAINT [FK_PV_Payment_PV_AvailableMethods]
FOREIGN KEY ([availablemethodid]) 
REFERENCES [dbo].[PV_AvailableMethods]([availablemethodid])





ALTER TABLE [dbo].[PV_Payment]
ADD CONSTRAINT [FK_PV_Payment_PV_PaymentMethods]
FOREIGN KEY ([paymentmethodid]) 
REFERENCES [dbo].[PV_PaymentMethods]([paymentmethodid])





ALTER TABLE [dbo].[PV_Payment]
ADD CONSTRAINT [FK_PV_Payment_PV_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_States]
ADD CONSTRAINT [FK_PV_States_PV_Countries]
FOREIGN KEY ([countryid]) 
REFERENCES [dbo].[PV_Countries]([countryid])





ALTER TABLE [dbo].[PV_ValidatorGroups]
ADD CONSTRAINT [FK_PV_ValidatorGroups_PV_Organizations]
FOREIGN KEY ([organizationid]) 
REFERENCES [dbo].[PV_Organizations]([organizationid])





ALTER TABLE [dbo].[PV_ProposalValidations]
ADD CONSTRAINT [FK_PV_ProposalValidations_PV_Proposals]
FOREIGN KEY ([proposalid]) 
REFERENCES [dbo].[PV_Proposals]([proposalid])





ALTER TABLE [dbo].[PV_ProposalValidations]
ADD CONSTRAINT [FK_WorkflowId_ProposalValidations]
FOREIGN KEY ([workflowid]) 
REFERENCES [dbo].[PV_workflows]([workflowId])





ALTER TABLE [dbo].[PV_ProposalDocuments]
ADD CONSTRAINT [FK_Documents_ProposalDocuments]
FOREIGN KEY ([documentId]) 
REFERENCES [dbo].[PV_Documents]([documentid])





ALTER TABLE [dbo].[PV_ProposalDocuments]
ADD CONSTRAINT [FK_PV_ProposalDocuments_PV_Proposals]
FOREIGN KEY ([proposalid]) 
REFERENCES [dbo].[PV_Proposals]([proposalid])





ALTER TABLE [dbo].[PV_VotingMetrics]
ADD CONSTRAINT [FK_VotingMetric_VotingMetricType]
FOREIGN KEY ([metrictypeId]) 
REFERENCES [dbo].[PV_VotingMetricsType]([VotingMetricTypeId])





ALTER TABLE [dbo].[PV_VotingMetrics]
ADD CONSTRAINT [FK_PV_VotingMetrics_PV_PopulationSegments]
FOREIGN KEY ([segmentid]) 
REFERENCES [dbo].[PV_PopulationSegments]([segmentid])





ALTER TABLE [dbo].[PV_VotingMetrics]
ADD CONSTRAINT [FK_PV_VotingMetrics_PV_VotingConfigurations]
FOREIGN KEY ([votingconfigid]) 
REFERENCES [dbo].[PV_VotingConfigurations]([votingconfigid])





ALTER TABLE [dbo].[PV_VotingMetrics]
ADD CONSTRAINT [FK_VotingMetrics_workflowId]
FOREIGN KEY ([workflowId]) 
REFERENCES [dbo].[PV_workflows]([workflowId])




ALTER TABLE [dbo].[PV_ProposalRequirementValues]
ADD CONSTRAINT [FK_PV_ProposalRequirementValues_PV_Proposals]
FOREIGN KEY ([proposalid]) 
REFERENCES [dbo].[PV_Proposals]([proposalid])





ALTER TABLE [dbo].[PV_ProposalRequirementValues]
ADD CONSTRAINT [FK_PV_ProposalRequirementValues_PV_ProposalRequirements]
FOREIGN KEY ([requirementid]) 
REFERENCES [dbo].[PV_ProposalRequirements]([requirementid])





ALTER TABLE [dbo].[PV_Schedules]
ADD CONSTRAINT [FK_PV_Schedules_PV_EndType]
FOREIGN KEY ([endtypeid]) 
REFERENCES [dbo].[PV_EndType]([endtypeid])





ALTER TABLE [dbo].[PV_Schedules]
ADD CONSTRAINT [FK_PV_Schedules_PV_RecurrencyType]
FOREIGN KEY ([recurrencytypeid]) 
REFERENCES [dbo].[PV_RecurrencyType]([recurrencytypeid])





ALTER TABLE [dbo].[PV_VotingOptions]
ADD CONSTRAINT [FK_PV_VotingOptions_PV_VotingConfigurations]
FOREIGN KEY ([votingconfigid]) 
REFERENCES [dbo].[PV_VotingConfigurations]([votingconfigid])





ALTER TABLE [dbo].[PV_VotingOptions]
ADD CONSTRAINT [FK_Questions_VotingOptions]
FOREIGN KEY ([questionId]) 
REFERENCES [dbo].[PV_VotingQuestions]([questionId])





ALTER TABLE [dbo].[PV_VotingOptions]
ADD CONSTRAINT [FK_VotingOptions_MediaFileId]
FOREIGN KEY ([mediafileId]) 
REFERENCES [dbo].[PV_mediafiles]([mediafileid])





ALTER TABLE [dbo].[PV_UserMFA]
ADD CONSTRAINT [FK_PV_UserMFA_PV_MFA]
FOREIGN KEY ([MFAid]) 
REFERENCES [dbo].[PV_MFA]([MFAid])





ALTER TABLE [dbo].[PV_UserMFA]
ADD CONSTRAINT [FK_PV_UserMFA_PV_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_ExecutionPlans]
ADD CONSTRAINT [FK_PV_ExecutionPlans_PV_Proposals]
FOREIGN KEY ([proposalid]) 
REFERENCES [dbo].[PV_Proposals]([proposalid])





ALTER TABLE [dbo].[PV_DocumentSections]
ADD CONSTRAINT [FK_DocumentSections_Documents]
FOREIGN KEY ([documentId]) 
REFERENCES [dbo].[PV_Documents]([documentid])





ALTER TABLE [dbo].[PV_VotingConfigurations]
ADD CONSTRAINT [FK_PV_VotingConfigurations_PV_Proposals]
FOREIGN KEY ([proposalid]) 
REFERENCES [dbo].[PV_Proposals]([proposalid])





ALTER TABLE [dbo].[PV_VotingConfigurations]
ADD CONSTRAINT [FK_PV_VotingConfigurations_PV_NotificationMethods]
FOREIGN KEY ([notificationmethodid]) 
REFERENCES [dbo].[PV_NotificationMethods]([notificationmethodid])





ALTER TABLE [dbo].[PV_VotingConfigurations]
ADD CONSTRAINT [FK_PV_VotingConfigurations_PV_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_VotingConfigurations]
ADD CONSTRAINT [FK_VontingConfigurations_VotingTypes]
FOREIGN KEY ([votingtypeId]) 
REFERENCES [dbo].[PV_VotingTypes]([votingTypeId])





ALTER TABLE [dbo].[PV_VotingConfigurations]
ADD CONSTRAINT [FK_PV_VotingConfigurations_PV_VotingStates]
FOREIGN KEY ([statusid]) 
REFERENCES [dbo].[PV_VotingStatus]([statusid])





ALTER TABLE [dbo].[PV_mediafiles]
ADD CONSTRAINT [FK_mediatypeId_MediaTypes]
FOREIGN KEY ([mediatypeid]) 
REFERENCES [dbo].[PV_mediaTypes]([mediaTypeId])





ALTER TABLE [dbo].[PV_mediafiles]
ADD CONSTRAINT [FK_userId_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_VoteResults]
ADD CONSTRAINT [FK_PV_VoteResults_PV_VotingConfigurations]
FOREIGN KEY ([votingconfigid]) 
REFERENCES [dbo].[PV_VotingConfigurations]([votingconfigid])





ALTER TABLE [dbo].[PV_VoteResults]
ADD CONSTRAINT [FK_PV_VoteResults_PV_VotingOptions]
FOREIGN KEY ([optionid]) 
REFERENCES [dbo].[PV_VotingOptions]([optionid])





ALTER TABLE [dbo].[PV_CryptoKeys]
ADD CONSTRAINT [FK_PV_CryptoKeys_PV_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_CryptoKeys]
ADD CONSTRAINT [FK_PV_CryptoKeys_PV_Organizations]
FOREIGN KEY ([organizationid]) 
REFERENCES [dbo].[PV_Organizations]([organizationid])





ALTER TABLE [dbo].[PV_DividendDistributions]
ADD CONSTRAINT [FK_PV_DividendDistributions_PV_Proposals]
FOREIGN KEY ([proposalid]) 
REFERENCES [dbo].[PV_Proposals]([proposalid])





ALTER TABLE [dbo].[PV_DividendDistributions]
ADD CONSTRAINT [FK_PV_DividendDistributions_PV_Users]
FOREIGN KEY ([processedby]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_DividendDistributions]
ADD CONSTRAINT [FK_PV_DividendDistributions_PV_FinancialReports]
FOREIGN KEY ([reportid]) 
REFERENCES [dbo].[PV_FinancialReports]([reportid])





ALTER TABLE [dbo].[PV_DividendDistributions]
ADD CONSTRAINT [FK_WorkFlowId_DividendDistrubutions]
FOREIGN KEY ([workflowId]) 
REFERENCES [dbo].[PV_workflows]([workflowId])




ALTER TABLE [dbo].[PV_OrganizationRoles]
ADD CONSTRAINT [FK_PV_OrganizationRoles_PV_Roles]
FOREIGN KEY ([roleid]) 
REFERENCES [dbo].[PV_Roles]([roleid])





ALTER TABLE [dbo].[PV_OrganizationRoles]
ADD CONSTRAINT [FK_PV_OrganizationRoles_PV_Organizations]
FOREIGN KEY ([organizationid]) 
REFERENCES [dbo].[PV_Organizations]([organizationid])





ALTER TABLE [dbo].[PV_OrganizationPermissions]
ADD CONSTRAINT [FK_PV_OrganizationPermissions_PV_Permissions]
FOREIGN KEY ([permissionid]) 
REFERENCES [dbo].[PV_Permissions]([permissionid])





ALTER TABLE [dbo].[PV_OrganizationPermissions]
ADD CONSTRAINT [FK_PV_OrganizationPermissions_PV_Organizations]
FOREIGN KEY ([organizationid]) 
REFERENCES [dbo].[PV_Organizations]([organizationid])





ALTER TABLE [dbo].[PV_VotingTargetSegments]
ADD CONSTRAINT [FK_PV_VotingTargetSegments_PV_VotingConfigurations]
FOREIGN KEY ([votingconfigid]) 
REFERENCES [dbo].[PV_VotingConfigurations]([votingconfigid])





ALTER TABLE [dbo].[PV_VotingTargetSegments]
ADD CONSTRAINT [FK_PV_VotingTargetSegments_PV_PopulationSegments]
FOREIGN KEY ([segmentid]) 
REFERENCES [dbo].[PV_PopulationSegments]([segmentid])





ALTER TABLE [dbo].[PV_Documents]
ADD CONSTRAINT [FK_periodicVerifcationId_periodicUserVerification]
FOREIGN KEY ([periodicVerificationId]) 
REFERENCES [dbo].[PV_periodicVerification]([periodicVerificationId])





ALTER TABLE [dbo].[PV_Documents]
ADD CONSTRAINT [FK_mediaFileId_mediafiles_Users]
FOREIGN KEY ([mediafileId]) 
REFERENCES [dbo].[PV_mediafiles]([mediafileid])





ALTER TABLE [dbo].[PV_Documents]
ADD CONSTRAINT [FK_Documents_DocumentsType]
FOREIGN KEY ([documentTypeId]) 
REFERENCES [dbo].[PV_DocumentTypes]([documentTypeId])





ALTER TABLE [dbo].[PV_Translation]
ADD CONSTRAINT [FK_PV_Translation_PV_Languages]
FOREIGN KEY ([languageid]) 
REFERENCES [dbo].[PV_Languages]([languageid])





ALTER TABLE [dbo].[PV_Translation]
ADD CONSTRAINT [FK_PV_Translation_PV_Modules]
FOREIGN KEY ([moduleid]) 
REFERENCES [dbo].[PV_Modules]([moduleid])





ALTER TABLE [dbo].[PV_InvestmentAgreements]
ADD CONSTRAINT [FK_InvestmentAgreements_Agreement]
FOREIGN KEY ([investmentId]) 
REFERENCES [dbo].[PV_Investments]([investmentid])




ALTER TABLE [dbo].[PV_InvestmentAgreements]
ADD CONSTRAINT [FK_DocumentId_investmentAgreement]
FOREIGN KEY ([documentId]) 
REFERENCES [dbo].[PV_Documents]([documentid])




ALTER TABLE [dbo].[PV_Addresses]
ADD CONSTRAINT [FK_PV_Addresses_PV_Cities]
FOREIGN KEY ([cityid]) 
REFERENCES [dbo].[PV_Cities]([cityid])





ALTER TABLE [dbo].[PV_FinancialReports]
ADD CONSTRAINT [FK_PV_FinancialReports_PV_Proposals]
FOREIGN KEY ([proposalid]) 
REFERENCES [dbo].[PV_Proposals]([proposalid])





ALTER TABLE [dbo].[PV_FinancialReports]
ADD CONSTRAINT [FK_PV_FinancialReports_PV_Users]
FOREIGN KEY ([approvedby]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_FinancialReports]
ADD CONSTRAINT [FK_FinancialReports_workflow]
FOREIGN KEY ([workflowId]) 
REFERENCES [dbo].[PV_workflows]([workflowId])




ALTER TABLE [dbo].[PV_FinancialReports]
ADD CONSTRAINT [FK_DocumentId_FinancialReports]
FOREIGN KEY ([documentId]) 
REFERENCES [dbo].[PV_Documents]([documentid])




ALTER TABLE [dbo].[PV_Logs]
ADD CONSTRAINT [FK_PV_Logs_PV_LogTypes]
FOREIGN KEY ([logtypeid]) 
REFERENCES [dbo].[PV_LogTypes]([logtypeid])





ALTER TABLE [dbo].[PV_Logs]
ADD CONSTRAINT [FK_PV_Logs_PV_LogSeverity]
FOREIGN KEY ([logseverityid]) 
REFERENCES [dbo].[PV_LogSeverity]([logseverityid])





ALTER TABLE [dbo].[PV_Logs]
ADD CONSTRAINT [FK_PV_Logs_PV_LogSource]
FOREIGN KEY ([logsourceid]) 
REFERENCES [dbo].[PV_LogSource]([logsourceid])





ALTER TABLE [dbo].[PV_AIModels]
ADD CONSTRAINT [FK_AiModelTypes_modeltypeId]
FOREIGN KEY ([modelid]) 
REFERENCES [dbo].[PV_AIModelTypes]([AIModelId])





ALTER TABLE [dbo].[PV_AIModels]
ADD CONSTRAINT [FK_PV_AIModels_PV_AIProviders]
FOREIGN KEY ([providerid]) 
REFERENCES [dbo].[PV_AIProviders]([providerid])





ALTER TABLE [dbo].[PV_DividendPayments]
ADD CONSTRAINT [FK_PV_DividendPayments_PV_Payment]
FOREIGN KEY ([paymentid]) 
REFERENCES [dbo].[PV_Payment]([paymentid])





ALTER TABLE [dbo].[PV_DividendPayments]
ADD CONSTRAINT [FK_PV_DividendPayments_PV_Investments]
FOREIGN KEY ([investmentid]) 
REFERENCES [dbo].[PV_Investments]([investmentid])





ALTER TABLE [dbo].[PV_DividendPayments]
ADD CONSTRAINT [FK_PV_DividendPayments_PV_DividendDistributions]
FOREIGN KEY ([distributionid]) 
REFERENCES [dbo].[PV_DividendDistributions]([distributionid])





ALTER TABLE [dbo].[PV_DividendPayments]
ADD CONSTRAINT [FK_WorkFlow_DividendPayments]
FOREIGN KEY ([workflowId]) 
REFERENCES [dbo].[PV_workflows]([workflowId])




ALTER TABLE [dbo].[PV_executionPlanSteps]
ADD CONSTRAINT [FK_ExecutionPlanSteps_ExecutionPlan]
FOREIGN KEY ([executionPlanId]) 
REFERENCES [dbo].[PV_ExecutionPlans]([executionplanid])





ALTER TABLE [dbo].[PV_executionPlanSteps]
ADD CONSTRAINT [FK_ExecutionPlanSteps_ExecutionStepType]
FOREIGN KEY ([stepTypeId]) 
REFERENCES [dbo].[PV_executionStepType]([executionStepTypeId])





ALTER TABLE [dbo].[PV_NotificationSettings]
ADD CONSTRAINT [FK_PV_NotificationSettings_PV_Users]
FOREIGN KEY ([userid]) 
REFERENCES [dbo].[PV_Users]([userid])





ALTER TABLE [dbo].[PV_NotificationSettings]
ADD CONSTRAINT [FK_PV_NotificationSettings_PV_NotificationMethods]
FOREIGN KEY ([notificationmethodid]) 
REFERENCES [dbo].[PV_NotificationMethods]([notificationmethodid])





ALTER TABLE [dbo].[PV_NotificationSettings]
ADD CONSTRAINT [FK_PV_NotificationSettings_PV_Organizations]
FOREIGN KEY ([organizationid]) 
REFERENCES [dbo].[PV_Organizations]([organizationid])





ALTER TABLE [dbo].[PV_UserInvestments]
ADD CONSTRAINT [FK_userInvestments_UserId]
FOREIGN KEY ([userId]) 
REFERENCES [dbo].[PV_Users]([userid])




ALTER TABLE [dbo].[PV_UserInvestments]
ADD CONSTRAINT [FK_userInvestments_InvestmentAgreement]
FOREIGN KEY ([investmentAgreementId]) 
REFERENCES [dbo].[PV_InvestmentAgreements]([agreementId])




ALTER TABLE [dbo].[PV_OrganizationInvestments]
ADD CONSTRAINT [FK_OrganizatioNInvestment_Organizations]
FOREIGN KEY ([organizationId]) 
REFERENCES [dbo].[PV_Organizations]([organizationid])




ALTER TABLE [dbo].[PV_OrganizationInvestments]
ADD CONSTRAINT [FK_OrganizationInvestments_InvesmentAgreements]
FOREIGN KEY ([investmentAgreementId]) 
REFERENCES [dbo].[PV_InvestmentAgreements]([agreementId])




ALTER TABLE [dbo].[PV_blockchain]
ADD CONSTRAINT [FK_BlockChain_BlockChainParams]
FOREIGN KEY ([blockchainParamsId]) 
REFERENCES [dbo].[PV_BlockchainParams]([blockChainParamsId])




ALTER TABLE [dbo].[PV_BlockChainConnections]
ADD CONSTRAINT [FK_BlockChainConnection_workflowId]
FOREIGN KEY ([workflowId]) 
REFERENCES [dbo].[PV_workflows]([workflowId])




ALTER TABLE [dbo].[PV_BlockChainConnections]
ADD CONSTRAINT [FK_BlockChainConnectionsId_BlockChainId]
FOREIGN KEY ([blockchainId]) 
REFERENCES [dbo].[PV_blockchain]([blockchainId])




