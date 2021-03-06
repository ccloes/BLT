DROP Database LCCHPTest
GO

USE [master]
GO
/****** Object:  Database [LCCHPTest]    Script Date: 1/5/2015 6:53:31 PM ******/
CREATE DATABASE [LCCHPTest]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'LCCHP', FILENAME = N'D:\MSSQL\Data\LCCHPTest.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 4096KB ), 
 FILEGROUP [LCCHPAttachments] CONTAINS FILESTREAM  DEFAULT 
( NAME = N'LCCHPAttachments', FILENAME = N'D:\MSSQL\Filestream\LCCHPAttachmentsTest' , MAXSIZE = UNLIMITED), 
 FILEGROUP [UData]  DEFAULT 
( NAME = N'LCCHP_UData', FILENAME = N'D:\MSSQL\Data\LCCHPTest_UData.ndf' , SIZE = 12288KB , MAXSIZE = UNLIMITED, FILEGROWTH = 4096KB )
 LOG ON 
( NAME = N'LCCHP_log', FILENAME = N'D:\MSSQL\Log\LCCHPTest_log.ldf' , SIZE = 17408KB , MAXSIZE = 2048GB , FILEGROWTH = 4096KB )
GO
ALTER DATABASE [LCCHPTest] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [LCCHPTest].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [LCCHPTest] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [LCCHPTest] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [LCCHPTest] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [LCCHPTest] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [LCCHPTest] SET ARITHABORT OFF 
GO
ALTER DATABASE [LCCHPTest] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [LCCHPTest] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [LCCHPTest] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [LCCHPTest] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [LCCHPTest] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [LCCHPTest] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [LCCHPTest] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [LCCHPTest] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [LCCHPTest] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [LCCHPTest] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [LCCHPTest] SET  DISABLE_BROKER 
GO
ALTER DATABASE [LCCHPTest] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [LCCHPTest] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [LCCHPTest] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [LCCHPTest] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [LCCHPTest] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [LCCHPTest] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [LCCHPTest] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [LCCHPTest] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [LCCHPTest] SET  MULTI_USER 
GO
ALTER DATABASE [LCCHPTest] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [LCCHPTest] SET DB_CHAINING OFF 
GO
ALTER DATABASE [LCCHPTest] SET FILESTREAM( NON_TRANSACTED_ACCESS = FULL, DIRECTORY_NAME = N'LCCHPAttachmentsTest' ) 
GO
ALTER DATABASE [LCCHPTest] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [LCCHPTest]
GO
/****** Object:  User [WIN-1M8NQQ69OEH\SQLMaintenenace]    Script Date: 1/5/2015 6:53:31 PM ******/
CREATE USER [WIN-1M8NQQ69OEH\SQLMaintenenace] FOR LOGIN [WIN-1M8NQQ69OEH\SQLMaintenenace] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [appUser]    Script Date: 1/5/2015 6:53:31 PM ******/
CREATE USER [appUser] FOR LOGIN [appUser] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [WIN-1M8NQQ69OEH\SQLMaintenenace]
GO
ALTER ROLE [db_owner] ADD MEMBER [appUser]
GO
ALTER ROLE [db_datareader] ADD MEMBER [appUser]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [appUser]
GO
/****** Object:  StoredProcedure [dbo].[TransProc]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TransProc] @PriKey INT, @CharCol CHAR(3) AS
BEGIN TRANSACTION InProc
INSERT INTO TestTrans VALUES (@PriKey, @CharCol)
INSERT INTO TestTrans VALUES (@PriKey + 1, @CharCol)
COMMIT TRANSACTION InProc;

GO
/****** Object:  StoredProcedure [dbo].[usp_InsertAccessAgreement]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new 
--				AccessAgreement records
-- =============================================
-- HISTORY
-- 12/13/2014	modified procedure to accept OUTPUT parameters

CREATE PROCEDURE [dbo].[usp_InsertAccessAgreement]   -- usp_InsertAccessAgreement 
	-- Add the parameters for the stored procedure here
	@AccessPurposeID int = NULL,
	@Notes varchar(3000) = NULL,
	@AccessAgreementFile varbinary(max) = NULL,
	@PropertyID int = NULL,
	@InsertedAccessAgreementID int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into AccessAgreement (AccessPurposeID, Notes, AccessAgreementFile, PropertyID) 
					 Values ( @AccessPurposeID, @Notes, @AccessAgreementFile, @PropertyID);
		SELECT @InsertedAccessAgreementID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertAccessPurpose]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new AccessPurpose records
-- =============================================
-- HISTORY
-- 12/13/2014	modified procedure to accept OUTPUT parameters

CREATE PROCEDURE [dbo].[usp_InsertAccessPurpose]   -- usp_InsertAccessPurpose 
	-- Add the parameters for the stored procedure here
	@AccessPurposeName varchar(50) = NULL,
	@AccessPurposeDescription varchar(250) = NULL,
	@AccessPurposeID int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into AccessPurpose ( AccessPurposeName, AccessPurposeDescription)
					 Values ( @AccessPurposeName, @AccessPurposeDescription);
		SELECT @AccessPurposeID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertArea]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new Area records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertArea]   -- usp_InsertArea 
	-- Add the parameters for the stored procedure here
	@AreaDescription varchar(250) = NULL,
	@AreaName varchar(50) = NULL,
	@NewAreaID int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Area ( AreaDescription, AreaName)
					 Values ( @AreaDescription, @AreaName);
		SELECT @NewAreaID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	-- Call procedure to print error information.
    EXECUTE dbo.uspPrintError;

    -- Roll back any active or uncommittable transactions before
    -- inserting information in the ErrorLog.
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END

    EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
END CATCH; 

-- Retrieve logged error information.
-- SELECT * FROM dbo.ErrorLog WHERE ErrorLogID = @ErrorLogID;




	--    SELECT ERROR_NUMBER() AS ErrorNumber
 --       ,ERROR_SEVERITY() AS ErrorSeverity
 --       ,ERROR_STATE() AS ErrorState
 --       ,ERROR_PROCEDURE() AS ErrorProcedure
 --       ,ERROR_LINE() AS ErrorLine
 --       ,ERROR_MESSAGE() AS ErrorMessage;
	--END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertBloodTestResults]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new BloodTestResults records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertBloodTestResults]   -- usp_InsertBloodTestResults 
	-- Add the parameters for the stored procedure here
	@isBaseline bit = NULL,
	@PersonID int = NULL,
	@SampleDate date = NULL,
	@LabSubmissionDate date = NULL,
	@LeadValue numeric(9,4) = NULL,
	@LeadValueCategoryID tinyint = NULL,
	@HemoglobinValue numeric(9,4) = NULL,
	@HemoglobinValueCategoryID tinyint = NULL, -- lookup in the database
	@HematocritValueCategoryID tinyint = NULL, -- lookup in the database
	@LabID int = NULL,
	@BloodTestCosts money = NULL,
	@sampleTypeID tinyint = NULL,
	@notes varchar(3000) = NULL,
	@TakenAfterPropertyRemediationCompleted bit = NULL,
	@BloodTestResultID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ExistsPersonID int -- does the person have a record in BloodTestResults table
			, @ErrorLogID int;
	-- Handle Null sampleDate?
	-- Handle Null LabSubmissionDate?

	-- check if the person exists
	IF NOT EXISTS (select PersonID from Person where PersonID = @PersonID)
	BEGIN
		RAISERROR ('Person does not exist. Cannot create a BloodtestResult record', 11, -1);
		RETURN;
	END

	-- check if the person has a record in BloodTestResults Table
	select @ExistsPersonID = PersonID from BloodTestResults

    -- Insert statements for procedure here
	BEGIN TRY
		-- Determine if this person already has an entry in BloodTestResults and set isBaseline appropriately.
		IF ( @isBaseline is NULL ) -- nothing passed in for baseline
		BEGIN
			IF  ( @ExistsPersonID is not NULL )
			BEGIN
				SET @isBaseline = 0;
			END
			ELSE -- the person has no entry in BloodTestResults, this is a baseline entry
			BEGIN
				SET @isBaseline = 1;
			END
		END
		ELSE IF ( @isBaseline = 0 ) -- this should not be a baseline entry according to passed in argument
		BEGIN
			IF (@ExistsPersonID is NULL)  -- the person does not have an entry in BloodTestResults, this is a baseline entry
			BEGIN
				Set @isBaseline = 1;
			END
		END
		ELSE IF ( @isBaseline = 1 ) -- this should be a baseline entry according to passed in argument
		BEGIN
			IF (@ExistsPersonID is not NULL)  -- the person already has an entry in BloodTestResults, this isn't a baseline entry
			BEGIN
				Set @isBaseline = 0;
			END
		END 

		 INSERT into BloodTestResults ( isBaseline, PersonID, SampleDate, LabSubmissionDate, LeadValue, LeadValueCategoryID,
		                                HemoglobinValue, HemoglobinValueCategoryID, HematocritValueCategoryID, LabID,
										BloodTestCosts, SampleTypeID, notes, TakenAfterPropertyRemediationCompleted)
					 Values ( @isBaseline, @PersonID, @SampleDate, @LabSubmissionDate, @LeadValue, @LeadValueCategoryID,
		                      @HemoglobinValue, @HemoglobinValueCategoryID, @HematocritValueCategoryID, @LabID,
							  @BloodTestCosts, @SampleTypeID, @notes, @TakenAfterPropertyRemediationCompleted);
		SELECT @BloodTestResultID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH; 
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertCleanupStatus]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new CleanupStatus records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertCleanupStatus]   -- usp_InsertCleanupStatus 
	-- Add the parameters for the stored procedure here
	@CleanupStatusDescription varchar(200) = NULL,
	@CleanupStatusName varchar(25) = NULL,
	@NewCleanupStatusID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into CleanupStatus ( CleanupStatusDescription, CleanupStatusName)
					 Values ( @CleanupStatusDescription, @CleanupStatusName);
		SELECT @NewCleanupStatusID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertConstructionType]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new ConstructionType records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertConstructionType]   -- usp_InsertConstructionType 
	-- Add the parameters for the stored procedure here
	@ConstructionTypeDescription varchar(250) = NULL,
	@ConstructionTypeName varchar(50) = NULL,
	@NewConstructionTypeID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into ConstructionType ( ConstructionTypeDescription, ConstructionTypeName)
					 Values ( @ConstructionTypeDescription, @ConstructionTypeName);
		SELECT @NewConstructionTypeID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertContractor]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new Contractor records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertContractor]   -- usp_InsertContractor 
	-- Add the parameters for the stored procedure here
	@ContractorDescription varchar(250) = NULL,
	@ContractorName varchar(50) = NULL,
	@NewContractorID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Contractor ( ContractorDescription, ContractorName)
					 Values ( @ContractorDescription, @ContractorName);
		SELECT @NewContractorID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertContractortoProperty]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new ContractortoProperty records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertContractortoProperty]   -- usp_InsertContractortoProperty 
	-- Add the parameters for the stored procedure here
	@ContractorID int = NULL,
	@PropertyID int = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into ContractortoProperty ( ContractorID, PropertyID, StartDate, EndDate)
					 Values ( @ContractorID, @PropertyID, @StartDate, @EndDate);
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertContractortoRemediation]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new ContractortoRemediation records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertContractortoRemediation]   -- usp_InsertContractortoRemediation 
	-- Add the parameters for the stored procedure here
	@ContractorID int = NULL,
	@RemediationID int = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL,
	@isSubContractor bit = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into ContractortoRemediation ( ContractorID, RemediationID, StartDate, EndDate, isSubContractor)
					 Values ( @ContractorID, @RemediationID, @StartDate, @EndDate, @isSubContractor);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertContractortoRemediationActionPlan]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new ContractortoRemediationPlan records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertContractortoRemediationActionPlan]   -- usp_InsertContractortoRemediationPlan 
	-- Add the parameters for the stored procedure here
	@ContractorID int = NULL,
	@RemediationActionPlanID int = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL,
	@isSubContractor bit = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into ContractortoRemediationActionPlan ( ContractorID, RemediationActionPlanID, StartDate, EndDate, isSubContractor)
					 Values ( @ContractorID, @RemediationActionPlanID, @StartDate, @EndDate, @isSubContractor);
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertCountry]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new Country records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertCountry]   -- usp_InsertCountry 
	-- Add the parameters for the stored procedure here
	@CountryName varchar(50) = NULL,
	@NewCountryID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Country ( CountryName)
					 Values ( @CountryName);
		SELECT @NewCountryID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertDaycare]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new Daycare records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertDaycare]   -- usp_InsertDaycare 
	-- Add the parameters for the stored procedure here
	@DaycareName varchar(50) = NULL,
	@DaycareDescription varchar(200) = NULL,
	@newDayCareID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Daycare ( DaycareName, DaycareDescription )
					 Values ( @DaycareName, @DaycareDescription );
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertDaycarePrimaryContact]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new DaycarePrimaryContact records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertDaycarePrimaryContact]   -- usp_InsertDaycarePrimaryContact 
	-- Add the parameters for the stored procedure here
	@DaycareID int = NULL,
	@PersonID int = NULL,
	@ContactPriority tinyint = NULL,
	@PrimaryPhoneNumberID int = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into DaycarePrimaryContact ( DayCareID, PersonID, ContactPriority, PrimaryPhoneNumberID )
					 Values ( @DayCareID, @PersonID, @ContactPriority, @PrimaryPhoneNumberID );
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertDaycaretoProperty]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new DaycaretoProperty records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertDaycaretoProperty]   -- usp_InsertDaycaretoProperty 
	-- Add the parameters for the stored procedure here
	@DaycareID int = NULL,
	@PropertyID int = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into DaycaretoProperty ( DaycareID, PropertyID, StartDate, EndDate)
					 Values ( @DaycareID, @PropertyID, @StartDate, @EndDate);
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertEmployer]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new Employer records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertEmployer]   -- usp_InsertEmployer 
	-- Add the parameters for the stored procedure here
	@EmployerName VARCHAR(50) = NULL,
	@NewEmployerID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Employer ( EmployerName )
					 Values ( @EmployerName );
		SELECT @NewEmployerID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertEmployertoProperty]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new EmployertoProperty records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertEmployertoProperty]   -- usp_InsertEmployertoProperty 
	-- Add the parameters for the stored procedure here
	@EmployerID int = NULL,
	@PropertyID int = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into EmployertoProperty ( EmployerID, PropertyID, StartDate, EndDate)
					 Values ( @EmployerID, @PropertyID, @StartDate, @EndDate);
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertEnvironmentalInvestigation]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new EnvironmentalInvestigation records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertEnvironmentalInvestigation]   -- usp_InsertEnvironmentalInvestigation 
	-- Add the parameters for the stored procedure here
	@ConductEnvironmentalInvestigation bit = NULL,
	@ConductEnvironmentalInvestigationDecisionDate date = NULL,
	@Cost money = NULL,
	@EnvironmentalInvestigationDate date = NULL,
	@PropertyID int = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL,
	@NewEnvironmentalInvestigation int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into EnvironmentalInvestigation ( ConductEnvironmentalInvestigation, ConductEnvironmentalInvestigationDecisionDate,
		                                          Cost, EnvironmentalInvestigationDate, PropertyID, StartDate, EndDate )
					 Values ( @ConductEnvironmentalInvestigation, @ConductEnvironmentalInvestigationDecisionDate,
		                      @Cost, @EnvironmentalInvestigationDate, @PropertyID, @StartDate, @EndDate  );
		SELECT @NewEnvironmentalInvestigation = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertEthnicity]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new Ethnicity records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertEthnicity]   -- usp_InsertEthnicity 
	-- Add the parameters for the stored procedure here
	@Ethnicity varchar(50) = NULL,
	@NewEthnicityID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Ethnicity ( Ethnicity )
					 Values ( @Ethnicity );
		SELECT @NewEthnicityID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertFamily]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		William Thier
-- Create date: 20140205
-- Description:	Stored Procedure to insert new Family names
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertFamily]  
	-- Add the parameters for the stored procedure here
	@LastName varchar(50),
	@NumberofSmokers tinyint = 0,
	@PrimaryLanguageID tinyint = 1,
	@Notes varchar(3000) = NULL,
	@Pets bit = 0,
	@inandout bit = NULL,
	@PrimaryPropertyID int,
	@FID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @DBNAME NVARCHAR(128), @ErrorLogID int;
	SET @DBNAME = DB_NAME();

	BEGIN TRY -- insert Family
		INSERT into Family ( LastName,  NumberofSmokers,  PrimaryLanguageID,  Notes, Pets, inandout
		            , PrimaryPropertyID) 
		            Values (@LastName, @NumberofSmokers, @PrimaryLanguageID, @Notes, @Pets, @inandout
					, @PrimaryPropertyID)
		SET @FID = SCOPE_IDENTITY();  -- uncomment to return primary key of inserted values
	END TRY -- insert Family
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH; 
END





GO
/****** Object:  StoredProcedure [dbo].[usp_InsertForeignFood]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new ForeignFood records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertForeignFood]   -- usp_InsertForeignFood 
	-- Add the parameters for the stored procedure here
	@ForeignFoodName varchar(50) = NULL,
	@ForeignFoodDescription varchar(256) = NULL,
	@NewForeignFoodID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into ForeignFood ( ForeignFoodName, ForeignFoodDescription )
					 Values ( @ForeignFoodName, @ForeignFoodDescription );
		SELECT @NewForeignFoodID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertForeignFoodtoCountry]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new ForeignFoodtoCountry records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertForeignFoodtoCountry]   -- usp_InsertForeignFoodtoCountry 
	-- Add the parameters for the stored procedure here
	@ForeignFoodID int = NULL,
	@CountryID tinyint = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into ForeignFoodtoCountry ( ForeignFoodID, CountryID ) --, StartDate, EndDate)
					 Values ( @ForeignFoodID, @CountryID ) -- , @StartDate, @EndDate);
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertGiftCard]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new GiftCard records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertGiftCard]   -- usp_InsertGiftCard 
	-- Add the parameters for the stored procedure here
	@GiftCardValue money = NULL,
	@IssueDate date = NULL,
	@PersonID int = NULL,
	@NewGiftCardID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here

	BEGIN TRY
		IF EXISTS (SELECT PersonID from Person where PersonID = @PersonID) print 'Person exists'
		 INSERT into GiftCard ( GiftCardValue, IssueDate, PersonID )
					 Values ( @GiftCardValue, @IssueDate, @PersonID );
		SELECT @NewGiftCardID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertHistoricFamily]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		William Thier
-- Create date: 20140205
-- Description:	Stored Procedure to insert Family names from existing database
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertHistoricFamily]  
	-- Add the parameters for the stored procedure here
	@LastName varchar(50),
	@NumberofSmokers tinyint = 0,
	@PrimaryLanguageID tinyint = 1,
	@Notes varchar(3000) = NULL,
	@Pets bit = 0,
	@inandout bit = NULL,
	@HistoricFID  smallint = NULL,
	@PrimaryPropertyID int,
	@FID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @DBNAME NVARCHAR(128), @ErrorLogID int;
	SET @DBNAME = DB_NAME();

	BEGIN TRY -- insert Family
		INSERT into Family ( LastName,  NumberofSmokers,  PrimaryLanguageID,  Notes, Pets, inandout
		            , HistoricFamilyID, PrimaryPropertyID) 
		            Values (@LastName, @NumberofSmokers, @PrimaryLanguageID, @Notes, @Pets, @inandout
					, @HistoricFID, @PrimaryPropertyID)
		SET @FID = SCOPE_IDENTITY();  -- uncomment to return primary key of inserted values
	END TRY -- insert Family
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH; 
END





GO
/****** Object:  StoredProcedure [dbo].[usp_InsertHobby]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new Hobby records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertHobby]   -- usp_InsertHobby 
	-- Add the parameters for the stored procedure here
	@HobbyName varchar(50) = NULL,
	@HobbyDescription varchar(256) = NULL,
	@NewHobbyID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Hobby ( HobbyName, HobbyDescription )
					 Values ( @HobbyName, @HobbyDescription );
		SELECT @NewHobbyID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertHomeRemedies]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new HomeRemedies records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertHomeRemedies]   -- usp_InsertHomeRemedies 
	-- Add the parameters for the stored procedure here
	@HomeRemedyName varchar(50) = NULL,
	@HomeRemedyDescription varchar(256) = NULL,
	@NewHomeRemedyID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into HomeRemedy ( HomeRemedyName, HomeRemedyDescription )
					 Values ( @HomeRemedyName, @HomeRemedyDescription );
		SELECT @NewHomeRemedyID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertHouseholdSourcesofLead]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new HouseholdSourcesofLead records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertHouseholdSourcesofLead]   -- usp_InsertHouseholdSourcesofLead 
	-- Add the parameters for the stored procedure here
	@HouseholdItemName varchar(50) = NULL,
	@HouseholdItemDescription varchar(512) = NULL,
	@NewHouseholdItemID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into HouseholdSourcesofLead ( HouseholdItemName, HouseholdItemDescription )
					 Values ( @HouseholdItemName, @HouseholdItemDescription );
		SELECT @NewHouseholdItemID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertInsuranceProvider]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new InsuranceProvider records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertInsuranceProvider]   -- usp_InsertInsuranceProvider 
	-- Add the parameters for the stored procedure here
	@InsuranceProviderName varchar(50) = NULL,
	@NewInsuranceProviderID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into InsuranceProvider ( InsuranceProviderName ) --, HouseholdItemDescription )
					 Values ( @InsuranceProviderName ) -- , @HouseholdItemDescription );
		SELECT @NewInsuranceProviderID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertLab]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new Lab records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertLab]   -- usp_InsertLab 
	-- Add the parameters for the stored procedure here
	@LabName varchar(50) = NULL,
	@LabDescription varchar(250) = NULL,
	@Notes varchar(3000) = NULL,
	@NewLabID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Lab ( LabName, LabDescription, Notes )
					 Values ( @LabName, @LabDescription, @Notes );
		SELECT @NewLabID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertLanguage]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		William Thier
-- Create date: 20130506
-- Description:	Stored Procedure to insert new Languages
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertLanguage]   -- usp_InsertLanguage "Italian"
	-- Add the parameters for the stored procedure here
	@LanguageName varchar(50),
	@LANGUAGEID int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @DBNAME NVARCHAR(128), @ErrorLogID int;
	SET @DBNAME = DB_NAME();

	BEGIN TRY
	     if Exists (select LanguageName from language where LanguageName = @LanguageName) 
		 BEGIN
		 RAISERROR
			(N'The language: %s already exists.',
			11, -- Severity.
			1, -- State.
			@LanguageName);
		 END
	
		INSERT into Language (LanguageName) Values (upper(@LanguageName))
		SET @LANGUAGEID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH; 
END





GO
/****** Object:  StoredProcedure [dbo].[usp_InsertMedium]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new Medium records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertMedium]   -- usp_InsertMedium 
	-- Add the parameters for the stored procedure here
	@MediumName varchar(50) = NULL,
	@MediumDescription varchar(250) = NULL,
	@TriggerLevel int = NULL,
	@TriggerLevelUnitsID smallint = NULL,
	@NewMediumID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Medium ( MediumName, MediumDescription, TriggerLevel, TriggerLevelUnitsID )
					 Values ( @MediumName, @MediumDescription, @TriggerLevel, @TriggerLevelUnitsID );
		SELECT @NewMediumID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertMediumSampleResults]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new MediumSampleResults records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertMediumSampleResults]   -- usp_InsertMediumSampleResults 
	-- Add the parameters for the stored procedure here
	@MediumID int = NULL,
	@MediumSampleValue numeric(9,4) = NULL,
	@UnitsID smallint = NULL,
	@SampleLevelCategoryID tinyint = NULL,
	@MediumSampleDate date = getdate,
	@LabID int = NULL,
	@LabSubmissionDate date = getdate,
	@Notes varchar(3000) = NULL,
	@IsAboveTriggerLevel bit = NULL,
	@NewMediumSampleResultsID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int, @TriggerlevelUnitsID smallint, @TriggerLevel numeric(9,4);
    -- Insert statements for procedure here
	-- See if Value is above Trigger Level - initially assume units are identical
	-- Determine Trigger level units and Trigger Level
	Select @TriggerLevel = M.TriggerLevel , @TriggerLevelUnitsID = M.TriggerLevelUnitsID FROM MediumSampleresults AS MSR 
		JOIN Medium as M on M.MediumID = MSR.MediumID 
		JOIN Units AS TLU on M.TriggerLevelUnitsID = TLU.UnitsID;

	-- IF the units are the same, 
	IF (@UnitsID = @TriggerlevelUnitsID )
	BEGIN
		print 'units are identical comparing values'
		IF ( @MediumSampleValue < @TriggerLevel ) 
			SET @IsAboveTriggerLevel = 0;
		ELSE 
			SET @IsAboveTriggerLevel = 1;
	END
	ELSE  
		print 'consider converting values to the same units'


	BEGIN TRY
		 INSERT into MediumSampleResults ( MediumID, MediumSampleValue, UnitsID, SampleLevelCategoryID, MediumSampleDate, LabID,
		                                   LabSubmissionDate, Notes, IsAboveTriggerLevel )
					 Values ( @MediumID, @MediumSampleValue, @UnitsID, @SampleLevelCategoryID, @MediumSampleDate, @LabID,
		                      @LabSubmissionDate, @Notes, @IsAboveTriggerLevel );
		SELECT @NewMediumSampleResultsID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertNewBloodLeadTestResultsWebScreen]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Liam Thier
-- Create date: 20141217
-- Description:	stored procedure to insert data retrieved from 
--				the Blood Lead Test Results web screen
-- =============================================
CREATE PROCEDURE [dbo].[usp_InsertNewBloodLeadTestResultsWebScreen] 
	-- Add the parameters for the stored procedure here
	@Person_ID int = NULL, 
	@Sample_Date date = NULL,
	@Lab_Date date = Null,
	@Blood_Lead_Result numeric(9,4)= NULL, -- Is this Lead value?
	-- @Flag = NULL, -- what is FLag?
	@Test_Type tinyint = NULL, -- SampleTypeID need to determine if/how new testTypes are created
	@Lab varchar(50) = NULL,  -- is this necessary i think the lab should be selected from a drop down with the option to add a new lab and an id should be passed?
	@Lab_ID int = NULL,
	@Child_Status_Code smallint = NULL, -- StatusID need to determine if/how new statusCodes are created
	@Hemoglobin_Value numeric(9,4) = NULL,
	@Blood_Test_Results_ID int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @BloodTestResult_return_value int, @ErrorLogID int;

	-- set default date if necessary 
	IF (@Sample_Date is null) 
	BEGIN
		set @Sample_Date = GetDate();
		RAISERROR ('Need to specify the SampleDate, setting to today by default', 5, 0);
	END
	
	IF (@Person_ID IS NULL)
	BEGIN
		RAISERROR ('Client name must be supplied', 11, -1);
		RETURN;
	END;
	BEGIN TRY
		EXEC	@BloodTestResult_return_value = [dbo].[usp_InsertBloodTestResults]
				@isBaseline = NULL,
				@PersonID = @Person_ID,
				@SampleDate = @Sample_Date,
				@LabSubmissionDate = @Lab_Date,
				@LeadValue = @Blood_Lead_Result,
				@LeadValueCategoryID = NULL,
				@HemoglobinValue = @Hemoglobin_Value,
				@HemoglobinValueCategoryID = NULL,
				@HematocritValueCategoryID = NULL,
				@LabID = @Lab_ID,
				@BloodTestCosts = NULL,
				@sampleTypeID = @Test_Type,
				@notes = NULL,
				@TakenAfterPropertyRemediationCompleted = NULL,
				@BloodTestResultID = @Blood_Test_Results_ID OUTPUT
	END TRY
	BEGIN CATCH
	    -- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH; 
		
END

GO
/****** Object:  StoredProcedure [dbo].[usp_InsertNewClientWebScreen]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Liam Thier
-- Create date: 20141115
-- Description:	stored procedure to insert data from the Add a new family web page
-- =============================================
CREATE PROCEDURE [dbo].[usp_InsertNewClientWebScreen]
	-- Add the parameters for the stored procedure here
	@Family_ID int = NULL, 
	@First_Name varchar(50) = NULL,
	@Middle_Name varchar(50) = NULL,
	@Last_Name varchar(50) = NULL,
	@Birth_Date date = NULL,
	@Gender_ char(1) = NULL,
	@Language_ID tinyint = NULL,
	-- @Child_ID varchar(50) = 'Leadville',
	-- @Ethnicity_ID varchar(2) = NULL, -- store as binary/bitmap
	@Moved_ bit = NULL,
	@Travel bit = NULL, --ForeignTravel
	@Travel_Notes varchar(3000) = NULL,
	@Out_of_Site bit = NULL, 
	@Hobby_ID smallint = NULL,
	@Hobby_Notes varchar(3000) = NULL,
	@Child_Notes varchar(3000) = NULL,
	@Release_Notes varchar(3000) = NULL,
	@is_Smoker bit = NULL,
	@Occupation_ID smallint = NULL,
	@Occupation_Start_Date date = NULL,
	@ClientID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- If no family ID was passed in exit
	IF (@Family_ID IS NULL)
	BEGIN
		RAISERROR ('Family name must be supplied', 11, -1);
		RETURN;
	END;

	-- If the family doesn't exist, return an error
	IF ((select FamilyID from family where FamilyID = @Family_ID) is NULL)
	BEGIN
		RAISERROR ('Unable to associate non existent family. Family does not exist.', 11, -1);
		RETURN;
	END
	
	if (@Last_Name is null)
	BEGIN
		select @Last_Name = Lastname from Family where FamilyID = @Family_ID
	END

	BEGIN
		DECLARE @ErrorLogID int,
				@PersontoFamily_return_value int,
				@PersontoLanguage_return_value int,
				@PersontoHobby_return_value int,
				@PersontoOccupation_return_value int,
				@PersontoEthnicity_return_value int;
		BEGIN TRY  -- insert new person
				EXEC	[dbo].[usp_InsertPerson]
					@FirstName = @First_Name,
					@MiddleName = @Middle_Name,
					@LastName = @Last_Name,
					@BirthDate = @Birth_Date,
					@Gender = @Gender_,
					-- @Ethnicity,
					@Moved = @Moved_,
					@ForeignTravel = @Travel,
					-- @TravelNotes,
					@OutofSite = @Out_of_Site,
					-- @HobbyNotes,
					@Notes = @Child_Notes,
					@isSmoker = @is_Smoker,
					@PID = @CLientID OUTPUT;

			BEGIN TRY  -- Associate New person to family
				if (@Family_ID is not NULL)
				EXEC	@PersontoFamily_return_value = usp_InsertPersontoFamily
						@PersonID = @ClientID, @FamilyID = @Family_ID, @OUTPUT = @PersontoFamily_return_value OUTPUT;
				
				BEGIN TRY  -- associate person to Language
					if (@Language_ID is not NULL)
					EXEC 	@PersontoLanguage_return_value = usp_InsertPersontoLanguage
							@LanguageID = @Language_ID, @PersonID = @ClientID, @isPrimaryLanguage = 1;

					BEGIN TRY -- associate person to Hobby
						if (@Hobby_ID is not NULL)
						EXEC	@PersontoHobby_return_value = usp_InsertPersontoHobby
								@HobbyID = @Hobby_ID, @PersonID = @ClientID;

						BEGIN TRY -- associate person to occupation
							if (@Occupation_ID is not NULL)
							EXEC	@PersontoOccupation_return_value = [dbo].[usp_InsertPersontoOccupation]
									@PersonID = @ClientID,
									@OccupationID = @Occupation_ID
						END TRY  -- associate person to occupation
						BEGIN CATCH -- associate person to occupation
							-- Call procedure to print error information.
							EXECUTE dbo.uspPrintError;

							-- Roll back any active or uncommittable transactions before
							-- inserting information in the ErrorLog.
							IF XACT_STATE() <> 0
							BEGIN
								ROLLBACK TRANSACTION;
							END

							EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
						END CATCH; -- associate person to occupation
					END TRY -- associate person to hobby
					BEGIN CATCH -- associate person to occupation
						-- Call procedure to print error information.
						EXECUTE dbo.uspPrintError;

						-- Roll back any active or uncommittable transactions before
						-- inserting information in the ErrorLog.
						IF XACT_STATE() <> 0
						BEGIN
							ROLLBACK TRANSACTION;
						END

						EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
					END CATCH; -- associate person to Hobby
				END TRY -- associate person to language
				BEGIN CATCH -- associate person to Language
					-- Call procedure to print error information.
					EXECUTE dbo.uspPrintError;

					-- Roll back any active or uncommittable transactions before
					-- inserting information in the ErrorLog.
					IF XACT_STATE() <> 0
					BEGIN
						ROLLBACK TRANSACTION;
					END

					EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
				END CATCH; -- associate person to Language
			END TRY -- Associate person to family
			BEGIN CATCH -- associate person to family
				-- Call procedure to print error information.
				EXECUTE dbo.uspPrintError;
				print 'FAILED TO ASSOCIATE PERSON TO FAMILY'
				-- Roll back any active or uncommittable transactions before
				-- inserting information in the ErrorLog.
				IF XACT_STATE() <> 0
				BEGIN
					ROLLBACK TRANSACTION;
				END

				EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
			END CATCH; -- associate person to family
		END TRY -- insert new person
		BEGIN CATCH -- insert person
			-- Call procedure to print error information.
			EXECUTE dbo.uspPrintError;

			-- Roll back any active or uncommittable transactions before
			-- inserting information in the ErrorLog.
			IF XACT_STATE() <> 0
			BEGIN
				ROLLBACK TRANSACTION;
			END

			EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
		END CATCH; -- insert new person
	END

	IF (@Family_ID is not NULL AND @PersontoFamily_return_value <> 0) 
	BEGIN
		RAISERROR ('Error associating person to family', 11, -1);
		RETURN;
	END
	
	IF (@Hobby_ID is not NULL AND @PersontoHobby_return_value <> 0)
	BEGIN
		RAISERROR ('Error associating person to Hobby', 11, -1);
		RETURN;
	END
	
	IF (@Language_ID is not NULL AND @PersontoLanguage_return_value <> 0) 
	BEGIN
		RAISERROR ('Error associating person to language', 11, -1);
		RETURN;
	END
	
	IF (@Occupation_ID is not NULL and @PersontoOccupation_return_value <> 0)
	BEGIN
		RAISERROR ('Error associating person to occupation', 11, -1);
		RETURN;
	END
END

GO
/****** Object:  StoredProcedure [dbo].[usp_InsertNewFamilyWebScreen]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Liam Thier
-- Create date: 20141115
-- Description:	stored procedure to insert data from the Add a new family web page
-- =============================================
-- 20150102	Fixed bug with family/property association checking
CREATE PROCEDURE [dbo].[usp_InsertNewFamilyWebScreen]
	-- Add the parameters for the stored procedure here
	@FamilyLastName varchar(50) = NULL, 
	@StreetNum varchar(15) = NULL,
	@StreetName varchar(50) = NULL,
	@StreetSuff varchar(20) = NULL,
	@ApartmentNum varchar(10) = NULL,
	@CityName varchar(50) = 'Leadville',
	@StateAbbr char(2) = 'CO',
	@ZipCode varchar(10) = '80461',
	@HomePhone bigint = NULL,
	@WorkPhone bigint = NULL,
	@Language tinyint = NULL, 
	@NumSmokers tinyint = NULL,
	@Pets bit = NULL,
	@inandout bit = NULL,
	@OtherNotes varchar(3000) = NULL,
	@FamilyID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF (@FamilyLastName IS NULL
		AND @StreetNum IS NULL
		AND @StreetName IS NULL
		AND @StreetSuff IS NULL
		AND @ApartmentNum IS NULL
		AND @HomePhone IS NULL
		AND @WorkPhone IS NULL)
	BEGIN
		RAISERROR ('You must supply at least one of the following: Family name, Street number, Street name, Street suffix, Apartment number, Home phone, or Work phone', 11, -1);
		RETURN;
	END;

	BEGIN
		DECLARE @PhoneTypeID tinyint, 
				@Family_return_value int,
				@PropID int, @LID tinyint,
				@PhoneNumberID_OUTPUT int,
				@Homephone_return_value int,
				@Workphone_return_value int,
				@ErrorLogID int;

		-- Insert the property address if it doesn't already exist
		-- NEED TO RETRIEVE PROPERTY ID IF IT ALREADY EXISTS
		SELECT @PropID = PropertyID from Property where StreetNumber = @StreetNum and Street = @StreetName 
												-- and StreetSuffix = @StreetSuff 
												and City = @CityName
												and [State] = @StateAbbr and Zipcode = @ZipCode
		if ( @PropID is NULL)
		BEGIN -- insert Property
			BEGIN TRY  -- insert Property
				EXEC	[dbo].[usp_InsertProperty]
						@StreetNumber = @StreetNum,
						@Street = @StreetName,
						@StreetSuffix = @StreetSuff,
						@City = @CityName,
						@State = @StateAbbr,
						@Zipcode = @ZipCode,
						@PropertyID = @PropID OUTPUT;
			END TRY  -- insert Property
			BEGIN CATCH  -- insert Property
			    -- Call procedure to print error information.
				EXECUTE dbo.uspPrintError;

				-- Roll back any active or uncommittable transactions before
				-- inserting information in the ErrorLog.
				IF XACT_STATE() <> 0
				BEGIN
					ROLLBACK TRANSACTION;
				END

				EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
			END CATCH; -- insert Property
		END -- insert property

		-- Check if Family is already associated with property, if so, skip insert and return warning:
		if ((select count(PrimarypropertyID) from Family where LastName = @FamilyLastName and PrimaryPropertyID = @PropID) > 0)
		BEGIN
			-- update address in the future??
			RAISERROR ('Family is already associated with that Property', 11, -1);
			RETURN;
		END
		ELSE
		BEGIN
			BEGIN TRY  -- insert Family
				EXEC	[dbo].[usp_InsertFamily]
						@LastName = @FamilyLastName,
						@NumberofSmokers = @NumSmokers,
						@PrimaryLanguageID = @Language,
						@Pets = @Pets,
						@inandout = @inandout,
						@PrimaryPropertyID = @PropID,
						@FID = @FamilyID OUTPUT;
			END TRY -- insert Family
			BEGIN CATCH
				-- Call procedure to print error information.
				EXECUTE dbo.uspPrintError;

				-- Roll back any active or uncommittable transactions before
				-- inserting information in the ErrorLog.
				IF XACT_STATE() <> 0
				BEGIN
					ROLLBACK TRANSACTION;
				END

				EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
			END CATCH; 
		END

		if (@HomePhone is not NULL) 
		BEGIN  -- insert Home Phone
			BEGIN TRY
				SELECT @PhoneTypeID = PhoneNumberTypeID from PhoneNumberType where PhoneNumberTypeName = 'Home Phone';
		print 'inserting home phone: ' + @HomePhone
				EXEC	@Homephone_return_value = [dbo].[usp_InsertPhoneNumber]
						@PhoneNumber = @HomePhone,
						@PhoneNumberTypeID = @PhoneTypeID,
						@PhoneNumberID_OUTPUT = @PhoneNumberID_OUTPUT OUTPUT
			END TRY 
			BEGIN CATCH
				-- Call procedure to print error information.
				EXECUTE dbo.uspPrintError;

				-- Roll back any active or uncommittable transactions before
				-- inserting information in the ErrorLog.
				IF XACT_STATE() <> 0
				BEGIN
					ROLLBACK TRANSACTION;
				END

				EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
			END CATCH; 
		END  -- insert Home Phone

		if (@WorkPhone is not NULL) 
		BEGIN  -- insert Work Phone
			BEGIN TRY
				SELECT @PhoneTypeID = PhoneNumberTypeID from PhoneNumberType where PhoneNumberTypeName = 'Work Phone';
print 'inserting work phone: ' + @WorkPhone
				EXEC	@Workphone_return_value = [dbo].[usp_InsertPhoneNumber]
						@PhoneNumber = @HomePhone,
						@PhoneNumberTypeID = @PhoneTypeID,
						@PhoneNumberID_OUTPUT = @PhoneNumberID_OUTPUT OUTPUT
			END TRY
			BEGIN CATCH
				-- Call procedure to print error information.
				EXECUTE dbo.uspPrintError;

				-- Roll back any active or uncommittable transactions before
				-- inserting information in the ErrorLog.
				IF XACT_STATE() <> 0
				BEGIN
					ROLLBACK TRANSACTION;
				END

				EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
			END CATCH; 
		END  -- insert Work Phone
	END
END

GO
/****** Object:  StoredProcedure [dbo].[usp_InsertNewQuestionnaireWebScreen]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Liam Thier
-- Create date: 20141208
-- Description:	stored procedure to insert data 
--              from the Lead Research Subject Questionnaire web page
-- =============================================
CREATE PROCEDURE [dbo].[usp_InsertNewQuestionnaireWebScreen]
	-- Add the parameters for the stored procedure here
	@Person_ID int = NULL,
	@QuestionnaireDate date = NULL,
	@PaintPeeling bit = NULL,
	@PaintAge int = NULL, -- RemodeledPropertyAge??
	@VisitRemodel bit = NULL,
	@RemodelPropertyAge int = NULL, -- how long ago was the property remodeled
	@Vitamins bit = NULL,
	@HandWash bit = NULL,
	@Bottle bit = NULL,
	@Nursing bit = NULL,
	@Pacifier bit = NULL,
	@BitesNails bit = NULL,
	@EatsOutdoors bit = NULL, 
	@NonFoodInMouth bit = NULL,
	@EatsNonFood bit = NULL,
	@SucksThumb bit = NULL,
	@Mouthing bit = NULL,
	@Daycare bit = NULL,
	@DayCareNotes varchar(3000) = NULL,
	@Source int = NULL,
	@QuestionnaireNotes varchar(3000) = NULL,
	@Questionnaire_return_value int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int; 
	-- set default date if necessary 
	IF (@QuestionnaireDate is null) 
	BEGIN
		print 'Need to specify QuestionnaireDate, setting to today by defualt';
		set @QuestionnaireDate = GetDate();
	END

	IF (@Person_ID IS NULL)
	BEGIN
		RAISERROR ('Client name must be supplied', 11, -1);
		RETURN;
	END;

	-- Client ID must already exist in the database
	IF ( (select PersonID from person where personID = @Person_ID ) is NULL)
	BEGIN
		RAISERROR ('Specified ClientID does not exist', 11, -1);
		RETURN;
	END

	BEGIN TRY
		EXEC	[dbo].[usp_InsertQuestionnaire]
				@PersonID = @Person_ID,
				@QuestionnaireDate = @QuestionnaireDate,
				@Source = NULL,
				@VisitRemodeledProperty = @VisitRemodel,
				@RemodeledPropertyAge = @RemodelPropertyAge,
				@isExposedtoPeelingPaint = NULL,
				@isTakingVitamins = @Vitamins,
				@isNursing = @Nursing,
				@isUsingPacifier = @Pacifier,
				@isUsingBottle = @Bottle,
				@BitesNails = @BitesNails,
				@NonFoodEating = @EatsNonFood,
				@NonFoodinMouth = @NonFoodInMouth,
				@EatOutside = @EatsOutdoors,
				@Suckling = NULL,
				@FrequentHandWashing = @HandWash,
				@Daycare = @Daycare,
				@Notes = @QuestionnaireNotes,
				@QuestionnaireID = @Questionnaire_return_value OUTPUT 
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH; 
END


GO
/****** Object:  StoredProcedure [dbo].[usp_InsertOccupation]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new Occupation records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertOccupation]   -- usp_InsertOccupation 
	-- Add the parameters for the stored procedure here
	@OccupationName varchar(50) = NULL,
	@OccupationDescription varchar(256) = NULL,
	@NewOccupationID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Occupation ( OccupationName, OccupationDescription )
					 Values ( @OccupationName, @OccupationDescription );
		SELECT @NewOccupationID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPerson]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		William Thier
-- Create date: 20130506
-- Description:	Stored Procedure to insert new people records
-- =============================================
-- DROP PROCEDURE usp_InsertPerson
CREATE PROCEDURE [dbo].[usp_InsertPerson]   -- usp_InsertPerson "Bonifacic",'James','Marco','19750205','M'
	-- Add the parameters for the stored procedure here
	@FirstName varchar(50) = NULL,
	@MiddleName varchar(50) = NULL,
	@LastName varchar(50) = NULL, 
	@BirthDate date = NULL,
	@Gender char(1) = NULL,
	@StatusID smallint = NULL,
	@ForeignTravel bit = NULL,
	@OutofSite bit = NULL,
	@EatsForeignFood bit = NULL,
	@PatientID smallint = NULL,
	@RetestDate datetime = NULL,
	@Moved bit = NULL,
	@MovedDate date = NULL,
	@isClosed bit = 0,
	@isResolved bit = 0,
	@Notes varchar(3000) = NULL,
	@GuardianID int = NULL,
	@isSmoker bit = NULL,
	@PID int OUTPUT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;

	-- set default retest date if none specified
	IF @RetestDate is null
		SET @RetestDate = DATEADD(yy,1,GetDate());

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into person ( LastName,  FirstName,  MiddleName,  BirthDate,  Gender,  StatusID, 
							  ForeignTravel,  OutofSite,  EatsForeignFood,  PatientID,  RetestDate, 
							  Moved,  MovedDate,  isClosed,  isResolved,  Notes, GuardianID,  isSmoker) 
					 Values (@LastName, @FirstName, @MiddleName, @BirthDate, @Gender, @StatusID,
							 @ForeignTravel, @OutofSite, @EatsForeignFood, @PatientID, @RetestDate,
							 @Moved, @MovedDate, @isClosed, @isResolved, @Notes, @GuardianID, @isSmoker);
		SET @PID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END






GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoAccessAgreement]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoAccessAgreement records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoAccessAgreement]   -- usp_InsertPersontoAccessAgreement
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@AccessAgreementID int = NULL,
	@AccessAgreementDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoAccessAgreement( PersonID, AccessAgreementID, AccessAgreementDate) --, EndDate)
					 Values ( @PersonID, @AccessAgreementID, @AccessAgreementDate ) -- , @EndDate);
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoDaycare]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoDaycare records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoDaycare]   -- usp_InsertPersontoDaycare
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@DaycareID int = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL,
	@DaycareNotes varchar(3000) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoDaycare( PersonID, DaycareID, StartDate, EndDate)
					 Values ( @PersonID, @DaycareID, @StartDate, @EndDate);
		--SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoEmployer]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoEmployer records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoEmployer]   -- usp_InsertPersontoEmployer
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@EmployerID int = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoEmployer( PersonID, EmployerID, StartDate, EndDate)
					 Values ( @PersonID, @EmployerID, @StartDate, @EndDate);
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoEthnicity]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoEthnicity records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoEthnicity]   -- usp_InsertPersontoEthnicity
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@EthnicityID int = NULL
	--@StartDate date = NULL,
	--@EndDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoEthnicity( PersonID, EthnicityID ) --, StartDate, EndDate)
					 Values ( @PersonID, @EthnicityID ) -- , @StartDate, @EndDate);
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoFamily]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoFamily records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoFamily]   -- usp_InsertPersontoFamily
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@FamilyID int = NULL,
	@OUTPUT int OUTPUT
	--@StartDate date = NULL,
	--@EndDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoFamily( PersonID, FamilyID ) --, StartDate, EndDate)
					 Values ( @PersonID, @FamilyID ) -- , @StartDate, @EndDate);
		SELECT @OUTPUT = SCOPE_IDENTITY();
	END TRY
BEGIN CATCH
    -- Call procedure to print error information.
    EXECUTE dbo.uspPrintError;

    -- Roll back any active or uncommittable transactions before
    -- inserting information in the ErrorLog.
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END

    EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
END CATCH; 
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoForeignFood]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoForeignFood records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoForeignFood]   -- usp_InsertPersontoForeignFood
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@ForeignFoodID int = NULL
	--@StartDate date = NULL,
	--@EndDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoForeignFood( PersonID, ForeignFoodID ) --, StartDate, EndDate)
					 Values ( @PersonID, @ForeignFoodID ) -- , @StartDate, @EndDate);
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoHobby]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoHobby records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoHobby]   -- usp_InsertPersontoHobby
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@HobbyID int = NULL
	--@StartDate date = NULL,
	--@EndDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoHobby( PersonID, HobbyID ) --, StartDate, EndDate)
					 Values ( @PersonID, @HobbyID ) -- , @StartDate, @EndDate);
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoHomeRemedy]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoHomeRemedy records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoHomeRemedy]   -- usp_InsertPersontoHomeRemedy
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@HomeRemedyID int = NULL
	--@StartDate date = NULL,
	--@EndDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoHomeRemedy( PersonID, HomeRemedyID ) --, StartDate, EndDate)
					 Values ( @PersonID, @HomeRemedyID ) -- , @StartDate, @EndDate);
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoInsurance]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoInsurance records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoInsurance]   -- usp_InsertPersontoInsurance
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@InsuranceID smallint = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL,
	@GroupID varchar(20) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoInsurance( PersonID, InsuranceID, StartDate, EndDate, GroupID)
					 Values ( @PersonID, @InsuranceID, @StartDate, @EndDate, @GroupID);
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoLanguage]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoLanguage records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoLanguage]   -- usp_InsertPersontoLanguage
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@LanguageID smallint = NULL,
	@isPrimaryLanguage bit = NULL
	--@StartDate date = NULL,
	--@EndDate date = NULL,
	--@GroupID varchar(20) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoLanguage( PersonID, LanguageID, isPrimaryLanguage ) -- StartDate, EndDate, GroupID)
					 Values ( @PersonID, @LanguageID, @isPrimaryLanguage ) -- @StartDate, @EndDate, @GroupID);
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoOccupation]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoOccupation records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoOccupation]   -- usp_InsertPersontoOccupation
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@OccupationID smallint = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL
	--@GroupID varchar(20) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @return_value int, @ErrorLogID int;

	-- at the very least assume the start date is today
	IF (@StartDate is NULL) SELECT @StartDate = GETDATE();

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoOccupation( PersonID, OccupationID, StartDate, EndDate)
					 Values ( @PersonID, @OccupationID, @StartDate, @EndDate);
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH; 
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoPhoneNumber]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoPhoneNumber records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoPhoneNumber]   -- usp_InsertPersontoPhoneNumber
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@PhoneNumberID int = NULL,
	@NumberPriority tinyint = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoPhoneNumber( PersonID, PhoneNumberID, NumberPriority)
					 Values ( @PersonID, @PhoneNumberID, @NumberPriority )
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoProperty]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoProperty records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoProperty]   -- usp_InsertPersontoProperty
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@PropertyID int = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL,
	@isPrimaryResidence bit = NULL,
	@NewPersontoPropertyID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoProperty( PersonID, PropertyID, StartDate, EndDate, isPrimaryResidence)
					 Values ( @PersonID, @PropertyID, @StartDate, @EndDate, @isPrimaryResidence )
		SELECT @NewPersontoPropertyID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoStatus]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoStatus records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoStatus]   -- usp_InsertPersontoStatus
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@StatusID int = NULL,
	@StatusDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoStatus( PersonID, StatusID, StatusDate ) -- , EndDate, isPrimaryResidence)
					 Values ( @PersonID, @StatusID, @StatusDate ) --, @EndDate, @isPrimaryResidence )
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoTravelCountry]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoTravelCountry records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoTravelCountry]   -- usp_InsertPersontoTravelCountry
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@TravelCountryID int = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoTravelCountry( PersonID, CountryID, StartDate, EndDate )
					 Values ( @PersonID, @TravelCountryID, @StartDate, @EndDate )
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPhoneNumber]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PhoneNumber records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPhoneNumber]   -- usp_InsertPhoneNumber 
	-- Add the parameters for the stored procedure here
	@CountryCode tinyint = 1,
	@PhoneNumber bigint = NULL,
	@PhoneNumberTypeID tinyint = NULL,
	@PhoneNumberID_OUTPUT int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PhoneNumber ( CountryCode, PhoneNumber, PhoneNumberTypeID )
					 Values ( @CountryCode, @PhoneNumber, @PhoneNumberTypeID );
		SELECT @PhoneNumberID_OUTPUT = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH; 
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPhoneNumberType]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20141220
-- Description:	Stored Procedure to insert new PhoneNumber records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPhoneNumberType]   -- usp_InsertPhoneNumberType
	-- Add the parameters for the stored procedure here
	@PhoneNumberTypeName VarChar(50) = NULL,
	@PhoneNumberTypeID_OUTPUT int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PhoneNumberType ( PhoneNumberTypeName )
					 Values ( @PhoneNumberTypeName );
		SELECT @PhoneNumberTypeID_OUTPUT = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH; 
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertProperty]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new property records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertProperty]   -- usp_InsertProperty 
	-- Add the parameters for the stored procedure here
	@ConstructionTypeID tinyint = NULL,
	@AreaID int = NULL,
	@isinHistoricDistrict bit = NULL, 
	@isRemodeled bit = NULL,
	@RemodelDate date = NULL,
	@isinCityLimits bit = NULL,
	@StreetNumber smallint = NULL,
	@Street varchar(50) = NULL,
	@StreetSuffix varchar(20) = NULL,
	@Apartmentnumber varchar(10) = NULL,
	@City varchar(50) = NULL,
	@State char(2) = NULL,
	@Zipcode varchar(12) = NULL,
	@YearBuilt smallint = NULL,
	@Ownerid int = NULL,
	@isOwnerOccuppied bit = NULL,
	@ReplacedPipesFaucets tinyint = 0,
	@TotalRemediationCosts money = NULL,
	@Notes varchar(3000) = NULL,
	@isResidential bit = NULL,
	@isCurrentlyBeingRemodeled bit = NULL,
	@hasPeelingChippingPaint bit = NULL,
	@County varchar(50) = NULL,
	@isRental bit = NULL,
	@PropertyID int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into property (ConstructionTypeID, AreaID, isinHistoricDistrict, isRemodeled, RemodelDate, 
							  isinCityLimits, StreetNumber, Street, StreetSuffix, ApartmentNumber, City, [State], Zipcode,
							  YearBuilt, OwnerID, isOwnerOccuppied, ReplacedPipesFaucets, TotalRemediationCosts, Notes,
							  isResidential, isCurrentlyBeingRemodeled, hasPeelingChippingPaint, County, isRental) 
					 Values ( @ConstructionTypeID, @AreaID, @isinHistoricDistrict, @isRemodeled, @RemodelDate, 
							  @isinCityLimits, @StreetNumber,  @Street, @StreetSuffix, @ApartmentNumber, @City, @State, @Zipcode,
							  @YearBuilt, @OwnerID, @isOwnerOccuppied, @ReplacedPipesFaucets, @TotalRemediationCosts, @Notes,
							  @isResidential, @isCurrentlyBeingRemodeled, @hasPeelingChippingPaint, @County, @isRental);
		SET @PropertyID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPropertySampleResults]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PropertySampleResults records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPropertySampleResults]   -- usp_InsertPropertySampleResults 
	-- Add the parameters for the stored procedure here
	@isBaseline bit = NULL,
	@PropertyID int = NULL,
	@LabSubmissionDate date = getdate,
	@LabID int = NULL,
	@SampleTypeID tinyint = NULL,
	@Notes varchar(3000) = NULL,
	@NewPropertySampleResultsID int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int, @ExistsPropertyID int;

	-- check if the property has a record in BloodTestResults Table
	select @ExistsPropertyID = PropertyID from PropertySampleResults


    -- Insert statements for procedure here
	BEGIN TRY
	-- Determine if this person already has an entry in BloodTestResults and set isBaseline appropriately.
		IF ( @isBaseline is NULL ) -- nothing passed in for baseline
		BEGIN
			IF  ( @ExistsPropertyID is not NULL )
			BEGIN
				SET @isBaseline = 0;
			END
			ELSE -- the person has no entry in BloodTestResults, this is a baseline entry
			BEGIN
				SET @isBaseline = 1;
			END
		END
		ELSE IF ( @isBaseline = 0 ) -- this should not be a baseline entry according to passed in argument
		BEGIN
			IF (@ExistsPropertyID is NULL)  -- the person does not have an entry in BloodTestResults, this is a baseline entry
			BEGIN
				Set @isBaseline = 1;
			END
		END
		ELSE IF ( @isBaseline = 1 ) -- this should be a baseline entry according to passed in argument
		BEGIN
			IF (@ExistsPropertyID is not NULL)  -- the person already has an entry in BloodTestResults, this isn't a baseline entry
			BEGIN
				Set @isBaseline = 0;
			END
		END 

		 INSERT into PropertySampleResults ( isBaseline, PropertyID, LabSubmissionDate, LabID,
		                                   SampleTypeID, Notes )
					 Values ( @isBaseline, @PropertyID, @LabSubmissionDate, @LabID,
		                                   @SampleTypeID, @Notes );
		SELECT @NewPropertySampleResultsID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPropertytoCleanupStatus]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PropertytoCleanupStatus records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPropertytoCleanupStatus]   -- usp_InsertPropertytoCleanupStatus
	-- Add the parameters for the stored procedure here
	@PropertyID int = NULL,
	@CleanupStatusID tinyint = NULL,
	@CleanupStatusDate date = NULL,
	@CostofCleanup money = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PropertytoCleanupStatus( PropertyID, CleanupStatusID, CleanupStatusDate, CostofCleanup )
					 Values ( @PropertyID, @CleanupStatusID, @CleanupStatusDate, @CostofCleanup )
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPropertytoHouseholdSourcesofLead]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PropertytoHouseholdSourcesofLead records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPropertytoHouseholdSourcesofLead]   -- usp_InsertPropertytoHouseholdSourcesofLead
	-- Add the parameters for the stored procedure here
	@PropertyID int = NULL,
	@HouseholdSourcesofLeadID int = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PropertytoHouseholdSourcesofLead( PropertyID, HouseholdSourcesofLeadID )
					 Values ( @PropertyID, @HouseholdSourcesofLeadID )
		SELECT SCOPE_IDENTITY();
	END TRY
		BEGIN CATCH
			-- Call procedure to print error information.
			EXECUTE dbo.uspPrintError;

			-- Roll back any active or uncommittable transactions before
			-- inserting information in the ErrorLog.
			IF XACT_STATE() <> 0
			BEGIN
				ROLLBACK TRANSACTION;
			END

			EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
		END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPropertytoMedium]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PropertytoMedium records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPropertytoMedium]   -- usp_InsertPropertytoMedium
	-- Add the parameters for the stored procedure here
	@PropertyID int = NULL,
	@MediumID int = NULL,
	@MediumTested bit = 1

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PropertytoMedium( PropertyID, MediumID, MediumTested )
					 Values ( @PropertyID, @MediumID, @MediumTested )
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertQuestionnaire]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new Questionnaire records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertQuestionnaire]
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@QuestionnaireDate date = getdate,
	@Source int = NULL,
	@VisitRemodeledProperty bit = NULL,
	@RemodeledPropertyAge int = NULL,
	@isExposedtoPeelingPaint bit = NULL,
	@isTakingVitamins bit = NULL,
	@isNursing bit = Null,
	@isUsingPacifier bit = NULL,
	@isUsingBottle bit = NULL,
	@BitesNails bit = NULL,
	@NonFoodEating bit = NULL,
	@NonFoodinMouth bit = NULL,
	@EatOutside bit = NULL,
	@Suckling bit = NULL,
	@FrequentHandWashing bit = NULL,
	@Daycare bit = NULL,
	@Notes varchar(3000) = NULL,
	@QuestionnaireID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Questionnaire ( PersonID, QuestionnaireDate, Source, VisitRemodeledProperty, RemodeledPropertyAge,
		                             isExposedtoPeelingPaint, isTakingVitamins, isNursing, isUsingPacifier, isUsingBottle,
									 Bitesnails, NonFoodEating, NonFoodinMouth, EatOutside, Suckling, FrequentHandWashing,
									 Daycare, Notes )
					 Values ( @PersonID, @QuestionnaireDate, @Source, @VisitRemodeledProperty, @RemodeledPropertyAge,
		                      @isExposedtoPeelingPaint, @isTakingVitamins, @isNursing, @isUsingPacifier, @isUsingBottle,
							  @Bitesnails, @NonFoodEating, @NonFoodinMouth, @EatOutside, @Suckling, @FrequentHandWashing,
							  @Daycare, @Notes );
		SELECT @QuestionnaireID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH; 
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertRemediation]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new Remediation records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertRemediation]   -- usp_InsertRemediation 
	-- Add the parameters for the stored procedure here
	@RemediationApprovalDate date = getdate,
	@RemediationStartDate date = NULL,
	@RemediationEndDate date = NULL,
	@PropertyID int = NULL,
	@RemediationActionPlanID int = NULL,
	@AccessAgreementID int = NULL,
	@FinalRemediationReportFile varbinary(max) = NULL,
	@FinalRemediationReportDate date = Null,
	@RemediationCost money = NULL,
	@OneYearRemediationCompleteDate date = NULL,
	@Notes varchar(3000) = NULL,
	@OneYearRemediatioNComplete bit = NULL,
	@NewRemediationID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Remediation ( RemediationApprovalDate, RemediationStartDate, RemediationEndDate, PropertyID
		                           , RemediationActionPlanID, AccessAgreementID, FinalRemediationReportFile, FinalRemediationReportDate
								   , RemediationCost, OneYearRemediationCompleteDate, Notes, OneYearRemediationComplete )
					 Values ( @RemediationApprovalDate, @RemediationStartDate, @RemediationEndDate, @PropertyID
		                      , @RemediationActionPlanID, @AccessAgreementID, @FinalRemediationReportFile, @FinalRemediationReportDate
							  , @RemediationCost, @OneYearRemediationCompleteDate, @Notes, @OneYearRemediationComplete);
		SELECT @NewRemediationID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertRemediationActionPlan]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new RemediationActionPlan records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertRemediationActionPlan]   -- usp_InsertRemediationActionPlan 
	-- Add the parameters for the stored procedure here
	@RemediationActionPlanApprovalDate date = getdate,
	@HomeOwnerConsultationDate date = NULL,
	@ContractorCompletedInvestigationDate date = NULL,
	@EnvironmentalInvestigationID int = NULL,
	@RemediationActionPlanFinalReportSubmissionDate date = NULL,
	@RemediationActionPlanFile varbinary(max) = NULL,
	@PropertyID int = NULL,
	@NewRemediationActionPlanID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into RemediationActionPlan ( RemediationActionPlanApprovalDate, HomeOwnerConsultationDate, ContractorCompletedInvestigationDate
		                                     , EnvironmentalInvestigationID, RemediationActionPlanFinalReportSubmissionDate,
											 RemediationActionPlanFile, PropertyID )
					 Values ( @RemediationActionPlanApprovalDate, @HomeOwnerConsultationDate, @ContractorCompletedInvestigationDate
								, @EnvironmentalInvestigationID, @RemediationActionPlanFinalReportSubmissionDate
								, @RemediationActionPlanFile, @PropertyID );
		SELECT @NewRemediationActionPlanID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertSampleLevelCategory]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new SampleLevelCategory records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertSampleLevelCategory]   -- usp_InsertSampleLevelCategory 
	-- Add the parameters for the stored procedure here
	@SampleLevelCategoryName varchar(20) = NULL,
	@SampleLevelCategoryDescription varchar(256) = NULL,
	@NewSampleLevelCategoryID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into SampleLevelCategory ( SampleLevelCategoryName, SampleLevelCategoryDescription )
					 Values ( @SampleLevelCategoryName, @SampleLevelCategoryDescription );
		SELECT @NewSampleLevelCategoryID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertSampleType]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new SampleType records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertSampleType]   -- usp_InsertSampleType 
	-- Add the parameters for the stored procedure here
	@SampleTypeName varchar(20) = NULL,
	@SampleTypeDescription varchar(256) = NULL,
	@NewSampleTypeID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into SampleType ( SampleTypeName, SampleTypeDescription )
					 Values ( @SampleTypeName, @SampleTypeDescription );
		SELECT @NewSampleTypeID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertStatus]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new Status records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertStatus]   -- usp_InsertStatus 
	-- Add the parameters for the stored procedure here
	@StatusName varchar(20) = NULL,
	@StatusDescription varchar(256) = NULL,
	@NewStatusID int OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int;
    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Status ( StatusName, StatusDescription )
					 Values ( @StatusName, @StatusDescription );
		SELECT @NewStatusID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END







GO
/****** Object:  StoredProcedure [dbo].[usp_SLBloodTestResults]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		William Thier
-- Create date: 20141222
-- Description:	select blood test results
--				optionally only return for a specific 
--				client
-- =============================================
CREATE PROCEDURE [dbo].[usp_SLBloodTestResults] 
	-- Add the parameters for the stored procedure here
	@ClientID int = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @spexecutesqlStr	NVARCHAR(4000),
			@Recompile BIT = 1, @ErrorLogID int; 

    -- Insert statements for procedure here
	SELECT @spexecutesqlStr = N'SELECT ''ClientID'' = [P].[personid], ''LastName'' = [P].[LastName], ''BirthDate'' = [P].[BirthDate]
								, ''TestDate'' = [BTR].[SampleDate], ''Hb g/dl'' = [BTR].[HemoglobinValue], ''Retest BL'' = DATEADD(yy,1,sampledate)
								, ''Retest HB'' = DATEADD(yy,1,sampledate), ''Close'' = [P].[isClosed], ''Moved'' = [P].[Moved]
								, ''Movedate'' = [P].[MovedDate]
							from [Person] [P]
							join [BloodTestResults] [BTR] on [P].[PersonID] = [BTR].[PersonID]
							WHERE 1 = 1'

	IF @ClientID IS NOT NULL
		SELECT @spexecutesqlStr = @spexecutesqlStr + N' AND [p].[PersonID] = @PersonID'
	ELSE
		SELECT @spexecutesqlStr = @spexecutesqlStr + N' ORDER BY [p].[LastName],[P].[PersonID] ASC'
		
	IF @ClientID is NULL
		SET @Recompile = 0;

	IF @Recompile = 1
		SELECT @spexecutesqlStr = @spexecutesqlStr + N' OPTION(RECOMPILE)';

	BEGIN TRY
		EXEC [sp_executesql] @spexecutesqlStr
		, N'@PersonID int'
		, @PersonID = @ClientID;
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH; 
END




GO
/****** Object:  StoredProcedure [dbo].[usp_SlColumnDetails]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Liam Thier
-- Create date: 20141124
-- Description:	stored procedure to list column details for each column in a table
-- =============================================
CREATE PROCEDURE [dbo].[usp_SlColumnDetails] 
	-- Add the parameters for the stored procedure here
	@TableName varchar(256) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 'Table' = @TableName,
    c.name 'Column Name',
    t.Name 'Data type',
    c.max_length 'Max Length',
    c.precision ,
    c.scale ,
    c.is_nullable,
    ISNULL(i.is_primary_key, 0) 'Primary Key'
	FROM    
		sys.columns c
	INNER JOIN 
		sys.types t ON c.user_type_id = t.user_type_id
	LEFT OUTER JOIN 
		sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
	LEFT OUTER JOIN 
		sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
	WHERE
		c.object_id = OBJECT_ID(@TableName)
END

GO
/****** Object:  StoredProcedure [dbo].[usp_SlCountFamilyMembers]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Liam Thier
-- Create date: 20141125
-- Description:	stored procedure to count family members
-- =============================================
CREATE PROCEDURE [dbo].[usp_SlCountFamilyMembers]
	-- Add the parameters for the stored procedure here
	@FamilyID int = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @spexecuteSQLStr NVARCHAR(4000)
			, @Recompile  BIT = 1, @ErrorLogID int;
	
	--IF (@FamilyID IS NULL)
	--BEGIN
	--	RAISERROR ('You must supply at least one parameter.', 11, -1);
	--	RETURN;
	--END;
	SELECT @spexecuteSQLStr =
		N'SELECT [f].[familyid], FamilyName = [f].[lastname], Members = count([p].[firstname]) from [person] as [p]
		 join [persontoFamily] [p2f] on [p2f].[personid] = [p].[personid] join [family] AS [f] on [f].[familyid] = [p2f].[familyid]
		 where 1=1';

	IF (@FamilyID IS NOT NULL) 
		SELECT @spexecuteSQLStr = @spexecuteSQLStr
			+ N' AND [f].[familyID] = @Family_ID';

	SELECT @spexecuteSQLStr = @spexecuteSQLStr
		+ N' group by [f].[familyid],[f].[lastname]
			order by [f].[lastname],[f].[familyid]';


	IF (@FamilyID IS NULL) 
		SET @Recompile = 0;
	
	IF @Recompile = 1
		SELECT @spexecuteSQLStr = @spexecuteSQLStr + N' OPTION(RECOMPILE)';

	BEGIN TRY    
		EXEC [sp_executesql] @spexecuteSQLStr
			, N'@Family_ID int'
			, @Family_ID = @FamilyID;
	END TRY
			BEGIN CATCH
			-- Call procedure to print error information.
			EXECUTE dbo.uspPrintError;

			-- Roll back any active or uncommittable transactions before
			-- inserting information in the ErrorLog.
			IF XACT_STATE() <> 0
			BEGIN
				ROLLBACK TRANSACTION;
			END

			EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
		END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[usp_SlCountParticipants]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Liam Thier
-- Create date: 2/13/2014
-- Description:	procedure returns the number of entries in the persons table, being the number of participants
-- =============================================
CREATE PROCEDURE [dbo].[usp_SlCountParticipants] 
	-- Add the parameters for the stored procedure here
	@Last_Name VARCHAR(50) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @spexecutesqlStr NVARCHAR(4000), @Recompile BIT = 1, @ErrorLogID int, @LastName VARCHAR(50);
	
	BEGIN TRY
		SELECT @spexecutesqlStr = 'SELECT Participants = count([PersonId]) from [person] WHERE 1=1'

		IF (@Last_Name IS NOT NULL)
		BEGIN
			SELECT @spexecutesqlStr = replace (@spexecutesqlStr, 'SELECT', 'SELECT [LastName], ')
			SELECT @spexecutesqlStr = @spexecutesqlStr + ' AND [LastName] = @LastName group by [LastName] order by [LastName] desc';
		END
		ELSE
			
		IF @Recompile = 1
		    SELECT @spexecutesqlStr = @spexecutesqlStr + N' OPTION(RECOMPILE)';

		EXEC [sp_executesql] @spexecutesqlStr
		, N'@LastName VARCHAR(50)'
		, @LastName = @Last_Name

	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END



GO
/****** Object:  StoredProcedure [dbo].[usp_SlFamilyNametoProperty]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Liam Thier
-- Create date: 20141123
-- Description:	User defined stored procedure to
--              select family and property address
-- =============================================
CREATE PROCEDURE [dbo].[usp_SlFamilyNametoProperty]
	-- Add the parameters for the stored procedure here
	@Family_Name varchar(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @spexecutesqlStr	NVARCHAR (4000),
        @Recompile  BIT = 1, @ErrorLogID int;

    -- Insert statements for procedure here
	select @spexecutesqlStr ='SELECT ''FamilyName'' = [F].[LastName],[Prop].[StreetNumber],[Prop].[Street],[Prop].[StreetSuffix],[Prop].[ZipCode]
	from [family] AS [F]
	join [Property] as [Prop] on [F].[PrimaryPropertyID] = [Prop].[PropertyID]
	where 1 = 1'
	
	-- Return all families and associated properties if nothing was passed in
	IF (@Family_Name IS NOT NULL)
		SELECT @spexecutesqlStr = @spexecutesqlStr + ' and [F].[LastName] = @FamilyName'
	ELSE
	    SET @Recompile = 0

	-- order by last name
	SELECT @spexecutesqlStr = @spexecutesqlStr + N' order by [F].[LastName]'
		
	IF @Recompile = 1
		SELECT @spexecutesqlStr = @spexecutesqlStr + N' OPTION(RECOMPILE)';

	BEGIN TRY 
		EXEC [sp_executesql] @spexecutesqlStr
		, N'@FamilyName varchar(50)'
		, @FamilyName = @Family_Name;
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Add error information to errorlog
		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
END


GO
/****** Object:  StoredProcedure [dbo].[usp_SLInsertedData]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		William Thier
-- Create date: 20130509
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[usp_SLInsertedData] 
	-- Add the parameters for the stored procedure here
	@Last_Name varchar(50) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @spexecutesqlStr	NVARCHAR(4000),
			@Recompile BIT = 1, @ErrorLogID int;

    -- Insert statements for procedure here
	SELECT @spexecutesqlStr = N'SELECT [P].[PersonID] 
								, ''FamilyLastName'' = [F].[Lastname]
								, [P].[LastName]
								, [P].[MiddleName]
								, [P].[FirstName]
								, [P].[BirthDate]
								, [P].[Gender]
								, ''StreetAddress'' = cast([Prop].[StreetNumber] as varchar)
									+ '' ''+ cast([Prop].[Street] as varchar) + '' '' 
									+ cast([Prop].[StreetSuffix] as varchar)
								, [Prop].[ApartmentNumber]
								, [Prop].[City]
								, [Prop].[State]
								, [Prop].[Zipcode]
								, ''PrimaryPhoneNumber'' = [Ph].[PhoneNumber]
								, [L].[LanguageName]
								, [F].[NumberofSmokers]
								, [F].[Pets]
								, [F].[inandout]
								, [F].[Notes]
								, [P].[Moved]
								, [P].[ForeignTravel]
								, [P].[OutofSite]
								, [H].[HobbyName]
								, [P].[Notes]
								, [P].[isSmoker]
								, [P].[RetestDate]
								, [Q].[QuestionnaireDate]
								, [Q].[isExposedtoPeelingPaint]
								, ''PaintAge'' = [Q].[RemodeledPropertyAge]
								, [Q].[VisitRemodeledProperty]
								, ''RemodelPropertyAge'' = [Q].[RemodeledPropertyAge]
								, [Q].[isTakingVitamins]
								, [Q].[FrequentHandWashing]
								, [Q].[isUsingBottle]
								, [Q].[isNursing]
								, [Q].[isUsingPacifier]
								, [Q].[BitesNails]
								, [Q].[EatOutside]
								, [Q].[NonFoodinMouth]
								, [Q].[NonFoodEating]
								, [Q].[Suckling]
								, [Q].[Daycare]
								, [Q].[Source]
								, [Q].[Notes]
								, [BTR].[SampleDate]
								, [BTR].[LabSubmissionDate]
								, [Lab].[LabName]
								, ''What is status code?''
								, [BTR].[HemoglobinValue]
						  FROM [LeadTrackingTesting-Liam].[dbo].[Person] AS [P]
						  LEFT OUTER JOIN [PersontoFamily] as [P2F] on [P].[PersonID] = [P2F].[PersonID]
						  LEFT OUTER JOIN [Family] AS [F] on [F].[FamilyID] = [P2F].[FamilyID]
						  LEFT OUTER JOIN [PersontoProperty] as [P2P] on [P].PersonID = [P2P].[PersonID]
						  LEFT OUTER JOIN [Questionnaire] as [Q] on [P].[PersonID] = [Q].[PersonID]
						  LEFT OUTER JOIN [BloodTestResults] as [BTR] on [P].[PersonID] = [BTR].[PersonID]
						  LEFT OUTER JOIN [PersontoLanguage] as [P2L] on [P2L].[PersonID] = [P].[PersonID]
						  LEFT OUTER JOIN [Language] as [L] on [L].LanguageID = [P2L].[LanguageID]
						  LEFT OUTER JOIN [Property] as [Prop] on [Prop].[PropertyID] = [F].[PrimaryPropertyID]
						  LEFT OUTER JOIN [PersontoPhoneNumber] as [P2Ph] on [P].[PersonID] = [P2Ph].[PersonID]
						  LEFT OUTER JOIN [PhoneNumber] as [Ph] on [Ph].[PhoneNumberID] = [P2Ph].[PhoneNumberID]
						  LEFT OUTER JOIN [PhoneNumberType] as [PhT] on [Ph].[PhoneNumberTypeID] = [PhT].[PhoneNumberTypeID]
						  LEFT OUTER JOIN [PersontoHobby] as [P2H] on [P].PersonID = [P2H].[HobbyID]
						  LEFT OUTER JOIN [Hobby] as [H] on [H].[HobbyID] = [P2H].[HobbyID]
						  LEFT OUTER JOIN [Lab] on [BTR].[LabID] = [Lab].[LabID]
							WHERE 1 = 1'

	if @Last_Name IS NOT NULL
		SELECT @spexecutesqlStr = @spexecutesqlStr + N' AND [p].[LastName] = @LastName ORDER BY [P].[PersonID] desc'
	ELSE
		SELECT @spexecutesqlStr = @spexecutesqlStr + N' ORDER BY [P].[PersonID] desc'

	IF @Last_name is NULL
		SET @Recompile = 0;

	IF @Recompile = 1
		SELECT @spexecutesqlStr = @spexecutesqlStr + N' OPTION(RECOMPILE)';

	BEGIN TRY
		EXEC [sp_executesql] @spexecutesqlStr
		, N'@Lastname varchar(50)'
		, @LastName = @Last_name;  
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;
	
END




GO
/****** Object:  StoredProcedure [dbo].[usp_SlListFamilyMembers]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Liam Thier
-- Create date: 20150103
-- Description:	stored procedure to list family members
-- =============================================
CREATE PROCEDURE [dbo].[usp_SlListFamilyMembers]
	-- Add the parameters for the stored procedure here
	@FamilyID int = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @spexecuteSQLStr NVARCHAR(4000)
			, @Recompile  BIT = 1, @ErrorLogID int;
	
	--IF (@FamilyID IS NULL)
	--BEGIN
	--	RAISERROR ('You must supply at least one parameter.', 11, -1);
	--	RETURN;
	--END;
	SELECT @spexecuteSQLStr =
		N'SELECT [f].[familyid], FamilyName = [f].[lastname],[P].[LastName],[P].[Firstname]  from [person] as [p]
		 join [persontoFamily] [p2f] on [p].[personid] = [p2f].[personid] 
		 join [family] AS [f] on [f].[familyid] = [p2f].[familyid]
		 where 1=1';

	IF (@FamilyID IS NOT NULL) 
		SELECT @spexecuteSQLStr = @spexecuteSQLStr
			+ N' AND [f].[familyID] = @Family_ID';

	SELECT @spexecuteSQLStr = @spexecuteSQLStr
		+ N' order by [f].[lastname],[f].[familyid]';


	IF (@FamilyID IS NULL) 
		SET @Recompile = 0;
	
	IF @Recompile = 1
		SELECT @spexecuteSQLStr = @spexecuteSQLStr + N' OPTION(RECOMPILE)';

	BEGIN TRY    
		EXEC [sp_executesql] @spexecuteSQLStr
			, N'@Family_ID int'
			, @Family_ID = @FamilyID;
	END TRY
			BEGIN CATCH
			-- Call procedure to print error information.
			EXECUTE dbo.uspPrintError;

			-- Roll back any active or uncommittable transactions before
			-- inserting information in the ErrorLog.
			IF XACT_STATE() <> 0
			BEGIN
				ROLLBACK TRANSACTION;
			END

			EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
		END CATCH;
END
GO
/****** Object:  StoredProcedure [dbo].[usp_SlPeopleByLastName]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SlPeopleByLastName]
		@Last_Name VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrorLogID int, @spExecutesqlStr NVARCHAR(4000), @Recompile BIT = 1;

	BEGIN TRY
		SELECT @spexecutesqlStr = 'SELECT [lastname],''Members'' = count([firstname]) from [person] WHERE 1=1';

		if (@Last_Name is not NULL)
		BEGIN
			SET @Recompile = 1;
			SELECT @spExecutesqlStr = @spExecutesqlStr + ' AND [person].[LastName] = @LastName'
		END
		ELSE
			SET @Recompile = 0

		-- Group by last name for counting purposes
		SELECT @spExecutesqlStr = @spExecutesqlStr + ' group by [lastname]'

		-- force recompile for selective query
		IF @Recompile = 1
			SELECT @spexecutesqlStr = @spexecutesqlStr + N' OPTION(RECOMPILE)';
		select @spExecutesqlStr

		EXEC [sp_executesql] @spExecutesqlStr 
			, N'@LastName VARCHAR(50)'
			, @LastName = @Last_Name;

	END TRY
	BEGIN CATCH
		-- Call procedure to print error information.
		EXECUTE dbo.uspPrintError;

		-- Roll back any active or uncommittable transactions before
		-- inserting information in the ErrorLog.
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END

		EXECUTE dbo.uspLogError @ErrorLogID = @ErrorLogID OUTPUT;
	END CATCH;

END



GO
/****** Object:  StoredProcedure [dbo].[usp_SlPeopleCountByLastName]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Liam Thier
-- Create date: 20141222
-- Description:	returns count of people grouped by 
--              last name. If a last name is passed in
--              displays a list of people with that last name
-- =============================================
CREATE PROCEDURE [dbo].[usp_SlPeopleCountByLastName]
	-- Add the parameters for the stored procedure here
	@Last_Name varchar(50) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @spexecutesqlStr	NVARCHAR (4000),
        @Recompile  BIT = 1;

    -- Insert statements for procedure here
	select @spexecutesqlStr ='select [lastname],''People'' = count([firstname]) from [person]
		where 1 = 1'
	
	-- Return all families and associated properties if nothing was passed in
	IF (@Last_Name IS NOT NULL)
		SELECT @spexecutesqlStr = @spexecutesqlStr + ' and [LastName] = @LastName'
	ELSE
	    SET @Recompile = 0

	SELECT @spexecutesqlStr = @spexecutesqlStr + ' group by lastname'

	IF @Recompile = 1
		SELECT @spexecutesqlStr = @spexecutesqlStr + N' OPTION(RECOMPILE)';
	
	EXEC [sp_executesql] @spexecutesqlStr
    , N'@LastName varchar(50)'
	, @LastName = @Last_Name;

END



GO
/****** Object:  StoredProcedure [dbo].[usp_SlTargeSampleType]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Liam Thier
-- Create date: 20150102
-- Description:	retrieve sample types for people (lead levels)
-- =============================================
CREATE PROCEDURE [dbo].[usp_SlTargeSampleType] 
	-- Add the parameters for the stored procedure here
	@Sample_Target varchar(50) = NULL, 
	@p2 int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @spexecutesqlStr nvarchar(4000), @RECOMPILE bit =1;
    -- Insert statements for procedure here

	SELECT @spexecutesqlStr = 'SELECT [SampleTypeName] from [SampleType] where 1=1'
	
	if (@Sample_Target IS NOT NULL)
		SELECT @spexecutesqlStr = @spexecutesqlStr + ' AND [SampleType].[SampleTarget] = @SampleTarget'

	IF @Recompile = 1
		SELECT @spexecutesqlStr = @spexecutesqlStr + ' OPTION(RECOMPILE)';

	EXEC [sp_executesql] @spexecutesqlStr
		, N'@SampleTarget varchar(50)', @SampleTarget = @Sample_Target

END

GO
/****** Object:  StoredProcedure [dbo].[usp_SlTargetSampleType]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Liam Thier
-- Create date: 20150102
-- Description:	retrieve sample types for people (lead levels)
-- =============================================
CREATE PROCEDURE [dbo].[usp_SlTargetSampleType] 
	-- Add the parameters for the stored procedure here
	@Sample_Target varchar(50) = NULL, 
	@p2 int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @spexecutesqlStr nvarchar(4000), @RECOMPILE bit =1;
    -- Insert statements for procedure here

	SELECT @spexecutesqlStr = 'SELECT [SampleTypeName] from [SampleType] where 1=1'
	
	if (@Sample_Target IS NOT NULL)
		SELECT @spexecutesqlStr = @spexecutesqlStr + ' AND [SampleType].[SampleTarget] = @SampleTarget'

	IF @Recompile = 1
		SELECT @spexecutesqlStr = @spexecutesqlStr + ' OPTION(RECOMPILE)';

	EXEC [sp_executesql] @spexecutesqlStr
		, N'@SampleTarget varchar(50)', @SampleTarget = @Sample_Target

END

GO
/****** Object:  StoredProcedure [dbo].[uspLogError]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspLogError] 
    @ErrorLogID [int] = 0 OUTPUT  -- Contains the ErrorLogID of the row inserted
                                  -- by uspLogError in the ErrorLog table.

AS
BEGIN
    SET NOCOUNT ON;

    -- Output parameter value of 0 indicates that error 
    -- information was not logged.
    SET @ErrorLogID = 0;

    BEGIN TRY
        -- Return if there is no error information to log.
        IF ERROR_NUMBER() IS NULL
            RETURN;

        -- Return if inside an uncommittable transaction.
        -- Data insertion/modification is not allowed when 
        -- a transaction is in an uncommittable state.
        IF XACT_STATE() = -1
        BEGIN
            PRINT 'Cannot log error since the current transaction is in an uncommittable state. ' 
                + 'Rollback the transaction before executing uspLogError in order to successfully log error information.';
            RETURN;
        END;

        INSERT [dbo].[ErrorLog] 
            (
            [UserName], 
            [ErrorNumber], 
            [ErrorSeverity], 
            [ErrorState], 
            [ErrorProcedure], 
            [ErrorLine], 
            [ErrorMessage]
            ) 
        VALUES 
            (
            CONVERT(sysname, CURRENT_USER), 
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            ERROR_MESSAGE()
            );

        -- Pass back the ErrorLogID of the row inserted
        SELECT @ErrorLogID = @@IDENTITY;
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred in stored procedure uspLogError: ';
        EXECUTE [dbo].[uspPrintError];
        RETURN -1;
    END CATCH
END; 
GO
/****** Object:  StoredProcedure [dbo].[uspPrintError]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspPrintError] 
AS
BEGIN
    SET NOCOUNT ON;

    -- Print error information. 
    PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
          ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
          ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
          ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
          ', Line ' + CONVERT(varchar(5), ERROR_LINE());
    PRINT ERROR_MESSAGE();
END;

GO
/****** Object:  Table [dbo].[AccessAgreement]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AccessAgreement](
	[AccessAgreementID] [int] IDENTITY(1,1) NOT NULL,
	[AccessPurposeID] [int] NULL,
	[Notes] [varchar](3000) NULL,
	[AccessAgreementFile] [varbinary](max) NULL,
	[PropertyID] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_AccessAgreement] PRIMARY KEY CLUSTERED 
(
	[AccessAgreementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData] TEXTIMAGE_ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AccessPurpose]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AccessPurpose](
	[AccessPurposeID] [int] IDENTITY(1,1) NOT NULL,
	[AccessPurposeName] [varchar](50) NULL,
	[AccessPurposeDescription] [varchar](253) NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_AccessPurpose] PRIMARY KEY CLUSTERED 
(
	[AccessPurposeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Area]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Area](
	[AreaID] [int] IDENTITY(1,1) NOT NULL,
	[AreaDescription] [varchar](253) NULL,
	[AreaName] [varchar](50) NULL,
	[HistoricAreaID] [char](1) NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Area] PRIMARY KEY CLUSTERED 
(
	[AreaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BloodTestResults]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BloodTestResults](
	[BloodTestResultsID] [int] IDENTITY(1,1) NOT NULL,
	[isBaseline] [bit] NOT NULL,
	[PersonID] [int] NULL,
	[SampleDate] [date] NOT NULL,
	[LabSubmissionDate] [date] NULL,
	[LeadValue] [numeric](9, 4) NULL,
	[LeadValueCategoryID] [tinyint] NULL,
	[HemoglobinValue] [numeric](9, 4) NULL,
	[HemoglobinValueCategoryID] [tinyint] NULL,
	[HematocritValueCategoryID] [tinyint] NULL,
	[LabID] [int] NULL,
	[BloodTestCosts] [money] NULL,
	[SampleTypeID] [tinyint] NULL,
	[notes] [varchar](3000) NULL,
	[HematocritValue]  AS ([hemoglobinValue]*(3)),
	[TakenAfterPropertyRemediationCompleted] [bit] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_BloodTestResults] PRIMARY KEY CLUSTERED 
(
	[BloodTestResultsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CleanupStatus]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CleanupStatus](
	[CleanupStatusID] [tinyint] IDENTITY(1,1) NOT NULL,
	[CleanupStatusDescription] [varchar](253) NULL,
	[CleanupStatusName] [varchar](50) NULL,
	[HistoricCleanupStatusID] [char](1) NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_CleanupStatus] PRIMARY KEY CLUSTERED 
(
	[CleanupStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ConstructionType]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ConstructionType](
	[ConstructionTypeID] [tinyint] IDENTITY(1,1) NOT NULL,
	[ConstructionTypeName] [varchar](50) NOT NULL,
	[ConstructionTypeDescription] [varchar](253) NULL,
	[HistoricConstructionTypeID] [char](1) NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_ConstructionType] PRIMARY KEY CLUSTERED 
(
	[ConstructionTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Contractor]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Contractor](
	[ContractorID] [int] IDENTITY(1,1) NOT NULL,
	[ContractorName] [varchar](50) NULL,
	[ContractorDescription] [varchar](253) NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Contractor] PRIMARY KEY CLUSTERED 
(
	[ContractorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ContractortoProperty]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractortoProperty](
	[ContractorID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_ContractortoProperty] PRIMARY KEY CLUSTERED 
(
	[ContractorID] ASC,
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[ContractortoRemediation]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractortoRemediation](
	[ContractorID] [int] NOT NULL,
	[RemediationID] [int] NOT NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[isSubContractor] [bit] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_ContractortoRemediation] PRIMARY KEY CLUSTERED 
(
	[ContractorID] ASC,
	[RemediationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[ContractortoRemediationActionPlan]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractortoRemediationActionPlan](
	[ContractorID] [int] NOT NULL,
	[RemediationActionPlanID] [int] NOT NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[isSubContractor] [bit] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_ContractortoRemediationActionPlan] PRIMARY KEY CLUSTERED 
(
	[ContractorID] ASC,
	[RemediationActionPlanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[Country]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Country](
	[CountryID] [tinyint] IDENTITY(1,1) NOT NULL,
	[CountryName] [varchar](50) NOT NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Daycare]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Daycare](
	[DaycareID] [int] IDENTITY(1,1) NOT NULL,
	[DaycareName] [varchar](50) NOT NULL,
	[DaycareDescription] [varchar](253) NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Daycare] PRIMARY KEY CLUSTERED 
(
	[DaycareID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DaycarePrimaryContact]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DaycarePrimaryContact](
	[DaycareID] [int] NOT NULL,
	[PersonID] [int] NOT NULL,
	[ContactPriority] [tinyint] NOT NULL,
	[PrimaryPhoneNumberID] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_DaycareContactPerson] PRIMARY KEY CLUSTERED 
(
	[DaycareID] ASC,
	[PersonID] ASC,
	[ContactPriority] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[DaycaretoProperty]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DaycaretoProperty](
	[DaycareID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_DaycaretoProperty] PRIMARY KEY CLUSTERED 
(
	[DaycareID] ASC,
	[PropertyID] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[Employer]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Employer](
	[EmployerID] [int] IDENTITY(1,1) NOT NULL,
	[EmployerName] [varchar](50) NOT NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Employer] PRIMARY KEY CLUSTERED 
(
	[EmployerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EmployertoProperty]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployertoProperty](
	[EmployerID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_EmployertoProperty] PRIMARY KEY CLUSTERED 
(
	[EmployerID] ASC,
	[PropertyID] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[EnvironmentalInvestigation]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnvironmentalInvestigation](
	[EnvironmentalInvestigationID] [int] IDENTITY(1,1) NOT NULL,
	[ConductEnvironmentalInvestigation] [bit] NULL,
	[ConductEnvironmentalInvestigationDecisionDate] [date] NULL,
	[Cost] [money] NULL,
	[EnvironmentalInvestigationDate] [date] NULL,
	[PropertyID] [int] NOT NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_EnvironmentalInvestigation] PRIMARY KEY CLUSTERED 
(
	[EnvironmentalInvestigationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[ErrorLog]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErrorLog](
	[ErrorID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](128) NOT NULL,
	[ErrorNumber] [int] NULL,
	[ErrorSeverity] [int] NULL,
	[ErrorState] [int] NULL,
	[ErrorProcedure] [nvarchar](128) NULL,
	[ErrorLine] [int] NULL,
	[ErrorMessage] [nvarchar](4000) NULL,
	[ErrorTime] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Error] PRIMARY KEY CLUSTERED 
(
	[ErrorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[Ethnicity]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Ethnicity](
	[EthnicityID] [tinyint] IDENTITY(1,1) NOT NULL,
	[Ethnicity] [varchar](50) NOT NULL,
	[HistoricEthnicityCode] [char](1) NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Ethnicity] PRIMARY KEY CLUSTERED 
(
	[EthnicityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Family]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Family](
	[FamilyID] [int] IDENTITY(1,1) NOT NULL,
	[Lastname] [varchar](50) NULL,
	[NumberofSmokers] [tinyint] NULL,
	[PrimaryLanguageID] [tinyint] NULL,
	[Notes] [varchar](3000) NULL,
	[Pets] [bit] NULL,
	[inandout] [bit] NULL,
	[HistoricFamilyID] [smallint] NULL,
	[PrimaryPropertyID] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Family] PRIMARY KEY CLUSTERED 
(
	[FamilyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FileType]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FileType](
	[FileTypeID] [smallint] IDENTITY(1,1) NOT NULL,
	[FileTypeName] [varchar](50) NOT NULL,
	[FileTypeDescription] [varchar](253) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_FileTypes] PRIMARY KEY CLUSTERED 
(
	[FileTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ForeignFood]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ForeignFood](
	[ForeignFoodID] [int] IDENTITY(1,1) NOT NULL,
	[ForeignFoodName] [varchar](50) NULL,
	[ForeignFoodDescription] [varchar](253) NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_ForeignFood] PRIMARY KEY CLUSTERED 
(
	[ForeignFoodID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ForeignFoodtoCountry]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ForeignFoodtoCountry](
	[ForeignFoodID] [int] NOT NULL,
	[CountryID] [tinyint] NOT NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_ForeignFoodtoCountry] PRIMARY KEY CLUSTERED 
(
	[ForeignFoodID] ASC,
	[CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[GiftCard]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GiftCard](
	[GiftCardID] [int] IDENTITY(1,1) NOT NULL,
	[GiftCardValue] [money] NOT NULL,
	[IssueDate] [date] NOT NULL,
	[PersonID] [int] NOT NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_GiftCertificate] PRIMARY KEY CLUSTERED 
(
	[GiftCardID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[Hobby]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Hobby](
	[HobbyID] [smallint] IDENTITY(1,1) NOT NULL,
	[HobbyDescription] [varchar](253) NULL,
	[HobbyName] [varchar](50) NULL,
	[InsertDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Hobby] PRIMARY KEY CLUSTERED 
(
	[HobbyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HomeRemedy]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HomeRemedy](
	[HomeRemedyID] [int] IDENTITY(1,1) NOT NULL,
	[HomeRemedyName] [varchar](50) NOT NULL,
	[HomeRemedyDescription] [varchar](253) NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_HomeRemedies] PRIMARY KEY CLUSTERED 
(
	[HomeRemedyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HouseholdSourcesofLead]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HouseholdSourcesofLead](
	[HouseholdSourcesofLeadID] [int] IDENTITY(1,1) NOT NULL,
	[HouseholdItemName] [varchar](50) NULL,
	[HouseholdItemDescription] [varchar](253) NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_HouseholdSourcesofLead] PRIMARY KEY CLUSTERED 
(
	[HouseholdSourcesofLeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InsuranceProvider]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InsuranceProvider](
	[InsuranceProviderID] [smallint] IDENTITY(1,1) NOT NULL,
	[InsuranceProviderName] [varchar](50) NOT NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_InsuranceProvider] PRIMARY KEY CLUSTERED 
(
	[InsuranceProviderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Lab]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Lab](
	[LabID] [int] IDENTITY(1,1) NOT NULL,
	[LabName] [varchar](50) NULL,
	[LabDescription] [varchar](253) NULL,
	[Notes] [varchar](3000) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Lab] PRIMARY KEY CLUSTERED 
(
	[LabID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LabOriginal]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LabOriginal](
	[LabID] [int] IDENTITY(1,1) NOT NULL,
	[LabName] [varchar](50) NULL,
	[LabDescription] [varchar](253) NULL,
	[Notes] [varchar](3000) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Language]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Language](
	[LanguageID] [tinyint] IDENTITY(1,1) NOT NULL,
	[LanguageName] [varchar](50) NOT NULL,
	[PrimLanguageCode] [char](1) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Language] PRIMARY KEY CLUSTERED 
(
	[LanguageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LCCHPAttachments]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LCCHPAttachments] AS FILETABLE ON [UData] FILESTREAM_ON [LCCHPAttachments]
WITH
(
FILETABLE_DIRECTORY = N'LCCHPAttachmentsTest', FILETABLE_COLLATE_FILENAME = SQL_Latin1_General_CP1_CI_AS
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Medium]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Medium](
	[MediumID] [int] IDENTITY(1,1) NOT NULL,
	[MediumName] [varchar](50) NOT NULL,
	[MediumDescription] [varchar](253) NULL,
	[TriggerLevel] [int] NULL,
	[TriggerLevelUnitsID] [int] NULL,
	[HistoricMediumCode] [char](1) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Medium] PRIMARY KEY CLUSTERED 
(
	[MediumID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MediumSampleResults]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MediumSampleResults](
	[MediumSampleResultsID] [int] IDENTITY(1,1) NOT NULL,
	[MediumID] [int] NOT NULL,
	[MediumSampleValue] [numeric](9, 4) NULL,
	[SampleLevelCategoryID] [tinyint] NULL,
	[MediumSampleDate] [date] NOT NULL,
	[LabID] [int] NULL,
	[LabSubmissionDate] [date] NULL,
	[Notes] [varchar](3000) NULL,
	[IsAboveTriggerLevel] [bit] NULL,
	[UnitsID] [smallint] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_MediumTestResults] PRIMARY KEY CLUSTERED 
(
	[MediumSampleResultsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Occupation]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Occupation](
	[OccupationID] [smallint] IDENTITY(1,1) NOT NULL,
	[OccupationName] [varchar](50) NOT NULL,
	[OccupationDescription] [varchar](253) NULL,
	[OccupationNotes] [varchar](3000) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Occupation] PRIMARY KEY CLUSTERED 
(
	[OccupationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Person]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Person](
	[PersonID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](50) NOT NULL,
	[MiddleName] [varchar](50) NULL,
	[LastName] [varchar](50) NOT NULL,
	[BirthDate] [date] NULL,
	[Gender] [char](1) NULL,
	[StatusID] [smallint] NULL,
	[ForeignTravel] [bit] NULL,
	[OutofSite] [bit] NULL,
	[EatsForeignFood] [bit] NULL,
	[PatientID] [smallint] NULL,
	[RetestDate] [date] NULL,
	[Moved] [bit] NULL,
	[MovedDate] [date] NULL,
	[isClosed] [bit] NULL,
	[isResolved] [bit] NULL,
	[Notes] [varchar](3000) NULL,
	[GuardianID] [int] NULL,
	[personCode] [smallint] NULL,
	[isSmoker] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Person] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PersontoAccessAgreement]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersontoAccessAgreement](
	[PersonID] [int] NOT NULL,
	[AccessAgreementID] [int] NOT NULL,
	[AccessAgreementDate] [date] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersontoAccessAgreement] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[AccessAgreementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PersontoDaycare]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PersontoDaycare](
	[PersonID] [int] NOT NULL,
	[DaycareID] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[DaycareNotes] [varchar](3000) NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersontoDaycare] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[DaycareID] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PersontoEmployer]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersontoEmployer](
	[PersonID] [int] NOT NULL,
	[EmployerID] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersontoEmployer] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[EmployerID] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PersontoEthnicity]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersontoEthnicity](
	[PersonID] [int] NOT NULL,
	[EthnicityID] [tinyint] NOT NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersontoEthnicity] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[EthnicityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PersontoFamily]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersontoFamily](
	[PersonID] [int] NOT NULL,
	[FamilyID] [int] NOT NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersontoFamily] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[FamilyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PersontoForeignFood]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersontoForeignFood](
	[PersonID] [int] NOT NULL,
	[ForeignFoodID] [int] NOT NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersontoForeignFood] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[ForeignFoodID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PersontoHobby]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersontoHobby](
	[PersonID] [int] NOT NULL,
	[HobbyID] [smallint] NOT NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersontoHobby] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[HobbyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PersontoHomeRemedy]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersontoHomeRemedy](
	[PersonID] [int] NOT NULL,
	[HomeRemedyID] [int] NOT NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersontoHomeRemedy] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[HomeRemedyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PersontoInsurance]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PersontoInsurance](
	[PersonID] [int] NOT NULL,
	[InsuranceID] [smallint] NOT NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[GroupID] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersontoInsurance] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[InsuranceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PersontoLanguage]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersontoLanguage](
	[PersonID] [int] NOT NULL,
	[LanguageID] [tinyint] NOT NULL,
	[isPrimaryLanguage] [bit] NOT NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersontoLanguage] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[LanguageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PersontoOccupation]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersontoOccupation](
	[PersonID] [int] NOT NULL,
	[OccupationID] [smallint] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersontoOccupation] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[OccupationID] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PersontoPerson]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersontoPerson](
	[Person1ID] [int] NOT NULL,
	[Person2ID] [int] NOT NULL,
	[RelationshipTypeID] [int] NOT NULL,
	[isGuardian] [bit] NULL,
	[isPrimaryContact] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL
) ON [UData]

GO
/****** Object:  Table [dbo].[PersontoPhoneNumber]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersontoPhoneNumber](
	[PersonID] [int] NOT NULL,
	[PhoneNumberID] [int] NOT NULL,
	[NumberPriority] [tinyint] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersontoPhoneNumber] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[PhoneNumberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PersontoProperty]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersontoProperty](
	[PersonID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[isPrimaryResidence] [bit] NULL,
	[FamilyID] [int] NULL,
	[PersontoPropertyID] [int] IDENTITY(1,1) NOT NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersontoProperty] PRIMARY KEY CLUSTERED 
(
	[PersontoPropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PersonToStatus]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonToStatus](
	[PersonID] [int] NOT NULL,
	[StatusID] [smallint] NOT NULL,
	[StatusDate] [date] NOT NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersonToStatus] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[StatusID] ASC,
	[StatusDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PersonToTravelCountry]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonToTravelCountry](
	[PersonID] [int] NOT NULL,
	[CountryID] [tinyint] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_PersonToTravelCountry] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[CountryID] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PhoneNumber]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PhoneNumber](
	[PhoneNumberID] [int] IDENTITY(1,1) NOT NULL,
	[CountryCode] [tinyint] NOT NULL,
	[PhoneNumber] [bigint] NULL,
	[PhoneNumberTypeID] [tinyint] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_PhoneNumber] PRIMARY KEY CLUSTERED 
(
	[PhoneNumberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PhoneNumberType]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PhoneNumberType](
	[PhoneNumberTypeID] [tinyint] IDENTITY(1,1) NOT NULL,
	[PhoneNumberTypeName] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_PhoneNumberType] PRIMARY KEY CLUSTERED 
(
	[PhoneNumberTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Property]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Property](
	[PropertyID] [int] IDENTITY(1,1) NOT NULL,
	[ConstructionTypeID] [tinyint] NULL,
	[AreaID] [int] NULL,
	[isinHistoricDistrict] [bit] NULL,
	[isRemodeled] [bit] NULL,
	[RemodelDate] [date] NULL,
	[isinCityLimits] [bit] NULL,
	[StreetNumber] [varchar](15) NULL,
	[Street] [varchar](50) NULL,
	[StreetSuffix] [varchar](20) NULL,
	[ApartmentNumber] [varchar](10) NULL,
	[City] [varchar](50) NULL,
	[State] [char](2) NULL,
	[Zipcode] [varchar](12) NULL,
	[YearBuilt] [smallint] NULL,
	[OwnerID] [int] NULL,
	[isOwnerOccuppied] [bit] NULL,
	[ReplacedPipesFaucets] [tinyint] NULL,
	[TotalRemediationCosts] [money] NULL,
	[notes] [varchar](3000) NULL,
	[isResidential] [bit] NULL,
	[isCurrentlyBeingRemodeled] [bit] NULL,
	[hasPeelingChippingPaint] [bit] NULL,
	[County] [varchar](50) NULL,
	[isRental] [bit] NULL,
	[HistoricPropertyID] [smallint] NULL,
	[InsertDate] [datetime] NOT NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Property] PRIMARY KEY CLUSTERED 
(
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PropertySampleResults]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PropertySampleResults](
	[PropertySampleResultsID] [int] IDENTITY(1,1) NOT NULL,
	[isBaseline] [bit] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[LabSubmissionDate] [date] NULL,
	[LabID] [int] NULL,
	[SampleTypeID] [tinyint] NULL,
	[Notes] [varchar](3000) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_PropertySampletResults] PRIMARY KEY CLUSTERED 
(
	[PropertySampleResultsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PropertytoCleanupStatus]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertytoCleanupStatus](
	[PropertyID] [int] NOT NULL,
	[CleanupStatusID] [tinyint] NOT NULL,
	[CleanupStatusDate] [date] NOT NULL,
	[CostofCleanup] [money] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_PropertytoCleanupStatus] PRIMARY KEY CLUSTERED 
(
	[PropertyID] ASC,
	[CleanupStatusID] ASC,
	[CleanupStatusDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PropertytoHouseholdSourcesofLead]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertytoHouseholdSourcesofLead](
	[PropertyID] [int] NOT NULL,
	[HouseholdSourcesofLeadID] [int] NOT NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_PropertytoHouseholdSourcesofLead] PRIMARY KEY CLUSTERED 
(
	[PropertyID] ASC,
	[HouseholdSourcesofLeadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[PropertytoMedium]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertytoMedium](
	[PropertyID] [int] NOT NULL,
	[MediumID] [int] NOT NULL,
	[MediumTested] [bit] NOT NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_PropertytoMedium] PRIMARY KEY CLUSTERED 
(
	[PropertyID] ASC,
	[MediumID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
/****** Object:  Table [dbo].[Questionnaire]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Questionnaire](
	[QuestionnaireID] [int] IDENTITY(1,1) NOT NULL,
	[PersonID] [int] NOT NULL,
	[QuestionnaireDate] [date] NULL,
	[Source] [int] NULL,
	[VisitRemodeledProperty] [bit] NULL,
	[RemodeledPropertyAge] [int] NULL,
	[isExposedtoPeelingPaint] [bit] NULL,
	[isTakingVitamins] [bit] NULL,
	[isNursing] [bit] NULL,
	[isUsingPacifier] [bit] NULL,
	[isUsingBottle] [bit] NULL,
	[BitesNails] [bit] NULL,
	[NonFoodEating] [bit] NULL,
	[NonFoodinMouth] [bit] NULL,
	[EatOutside] [bit] NULL,
	[Suckling] [bit] NULL,
	[FrequentHandWashing] [bit] NULL,
	[Daycare] [bit] NULL,
	[Notes] [varchar](3000) NULL,
	[InsertDate] [datetime] NOT NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Questionnaire] PRIMARY KEY CLUSTERED 
(
	[QuestionnaireID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RelationshipType]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RelationshipType](
	[RelationshipTypeID] [int] IDENTITY(1,1) NOT NULL,
	[RelationshipTypeName] [varchar](50) NULL,
	[RelationshipTypeDescription] [varchar](253) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_RelationshipType] PRIMARY KEY CLUSTERED 
(
	[RelationshipTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Remediation]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Remediation](
	[RemediationID] [int] IDENTITY(1,1) NOT NULL,
	[RemediationApprovalDate] [date] NULL,
	[RemediationStartDate] [date] NULL,
	[RemediationEndDate] [date] NULL,
	[PropertyID] [int] NULL,
	[AccessAgreementID] [int] NULL,
	[FinalRemediationReportFile] [varbinary](max) NULL,
	[FinalRemediationReportDate] [date] NULL,
	[RemediationCost] [money] NULL,
	[OneYearRemediationCompleteDate] [date] NULL,
	[Notes] [varchar](3000) NULL,
	[OneYearRemediationComplete] [bit] NULL,
	[RemediationActionPlanID] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Remediation] PRIMARY KEY CLUSTERED 
(
	[RemediationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData] TEXTIMAGE_ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RemediationActionPlan]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RemediationActionPlan](
	[RemediationActionPlanID] [int] IDENTITY(1,1) NOT NULL,
	[RemediationActionPlanApprovalDate] [date] NULL,
	[HomeOwnerConsultationDate] [date] NULL,
	[ContractorCompletedInvestigationDate] [date] NULL,
	[RemediationActionPlanFinalReportSubmissionDate] [date] NULL,
	[RemediationActionPlanFile] [varbinary](max) NULL,
	[PropertyID] [int] NULL,
	[EnvironmentalInvestigationID] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_RemediationActionPlan] PRIMARY KEY CLUSTERED 
(
	[RemediationActionPlanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData] TEXTIMAGE_ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SampleLevelCategory]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SampleLevelCategory](
	[SampleLevelCategoryID] [tinyint] IDENTITY(1,1) NOT NULL,
	[SampleLevelCategoryName] [varchar](50) NULL,
	[SampleLevelCategoryDescription] [varchar](253) NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_SampleLevelCategory] PRIMARY KEY CLUSTERED 
(
	[SampleLevelCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SampleType]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SampleType](
	[SampleTypeID] [tinyint] IDENTITY(1,1) NOT NULL,
	[SampleTypeName] [varchar](50) NULL,
	[SampleTypeDescription] [varchar](253) NULL,
	[historicSampleType] [char](1) NULL,
	[SampleTarget] [varchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_SampleType] PRIMARY KEY CLUSTERED 
(
	[SampleTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Status]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Status](
	[StatusID] [smallint] IDENTITY(1,1) NOT NULL,
	[StatusName] [varchar](50) NULL,
	[StatusDescription] [varchar](253) NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED 
(
	[StatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Units]    Script Date: 1/5/2015 6:53:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Units](
	[UnitsID] [smallint] IDENTITY(1,1) NOT NULL,
	[Units] [varchar](20) NOT NULL,
	[UnitsDescription] [varchar](253) NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Units] PRIMARY KEY CLUSTERED 
(
	[UnitsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
) ON [UData]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [NonClusteredIndex-20141220-115023]    Script Date: 1/5/2015 6:53:31 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20141220-115023] ON [dbo].[Person]
(
	[LastName] ASC,
	[RetestDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [UData]
GO
ALTER TABLE [dbo].[AccessAgreement] ADD  CONSTRAINT [DF_AccessAgreement_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[AccessPurpose] ADD  CONSTRAINT [DF_AccessPurpose_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Area] ADD  CONSTRAINT [DF_Area_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[BloodTestResults] ADD  CONSTRAINT [DF_BloodTestResults_isBaseline]  DEFAULT ((0)) FOR [isBaseline]
GO
ALTER TABLE [dbo].[BloodTestResults] ADD  CONSTRAINT [DF_BloodTestResults_SampleDate]  DEFAULT (getdate()) FOR [SampleDate]
GO
ALTER TABLE [dbo].[BloodTestResults] ADD  CONSTRAINT [DF_BloodTestResults_TakenAfterPropertyRemediationCompleted]  DEFAULT ((0)) FOR [TakenAfterPropertyRemediationCompleted]
GO
ALTER TABLE [dbo].[BloodTestResults] ADD  CONSTRAINT [DF_BloodTestResults_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[CleanupStatus] ADD  CONSTRAINT [DF_CleanupStatus_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[ConstructionType] ADD  CONSTRAINT [DF_ConstructionType_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Contractor] ADD  CONSTRAINT [DF_Contractor_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[ContractortoProperty] ADD  CONSTRAINT [DF_ContractortoProperty_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[ContractortoRemediation] ADD  CONSTRAINT [DF_ContractortoRemediation_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[ContractortoRemediationActionPlan] ADD  CONSTRAINT [DF_ContractortoRemediationActionPlan_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Country] ADD  CONSTRAINT [DF_Country_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Daycare] ADD  CONSTRAINT [DF_Daycare_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[DaycarePrimaryContact] ADD  CONSTRAINT [DF_DaycareContactPerson_ContactPriority]  DEFAULT ((1)) FOR [ContactPriority]
GO
ALTER TABLE [dbo].[DaycarePrimaryContact] ADD  CONSTRAINT [DF_DaycarePrimaryContact_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[DaycaretoProperty] ADD  CONSTRAINT [DF_DaycaretoProperty_StartDate]  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [dbo].[DaycaretoProperty] ADD  CONSTRAINT [DF_DaycaretoProperty_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Employer] ADD  CONSTRAINT [DF_Employer_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[EmployertoProperty] ADD  CONSTRAINT [DF_EmployertoProperty_StartDate]  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [dbo].[EmployertoProperty] ADD  CONSTRAINT [DF_EmployertoProperty_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[EnvironmentalInvestigation] ADD  CONSTRAINT [DF_EnvironmentalInvestigation_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[ErrorLog] ADD  CONSTRAINT [DF_ErrorLog_ErrorTime]  DEFAULT (getdate()) FOR [ErrorTime]
GO
ALTER TABLE [dbo].[ErrorLog] ADD  CONSTRAINT [DF_ErrorLog_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Ethnicity] ADD  CONSTRAINT [DF_Ethnicity_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Family] ADD  CONSTRAINT [DF_Family_PrimaryLanguageID]  DEFAULT ((1)) FOR [PrimaryLanguageID]
GO
ALTER TABLE [dbo].[Family] ADD  CONSTRAINT [DF_Family_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[FileType] ADD  CONSTRAINT [DF_FileType_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[ForeignFood] ADD  CONSTRAINT [DF_ForeignFood_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[ForeignFoodtoCountry] ADD  CONSTRAINT [DF_ForeignFoodtoCountry_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[GiftCard] ADD  CONSTRAINT [DF_GiftCertificate_GiftCertificateValue]  DEFAULT ((25)) FOR [GiftCardValue]
GO
ALTER TABLE [dbo].[GiftCard] ADD  CONSTRAINT [DF_GiftCard_IssueDate]  DEFAULT (getdate()) FOR [IssueDate]
GO
ALTER TABLE [dbo].[GiftCard] ADD  CONSTRAINT [DF_GiftCard_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Hobby] ADD  CONSTRAINT [DF_Hobby_InsertDate]  DEFAULT (getdate()) FOR [InsertDate]
GO
ALTER TABLE [dbo].[Hobby] ADD  CONSTRAINT [DF_Hobby_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[HomeRemedy] ADD  CONSTRAINT [DF_HomeRemedy_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[HouseholdSourcesofLead] ADD  CONSTRAINT [DF_HouseholdSourcesofLead_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[InsuranceProvider] ADD  CONSTRAINT [DF_InsuranceProvider_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Lab] ADD  CONSTRAINT [DF_Lab_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Language] ADD  CONSTRAINT [DF_Language_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Medium] ADD  CONSTRAINT [DF_Medium_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[MediumSampleResults] ADD  CONSTRAINT [DF_MediumTestResults_MediumTestDate]  DEFAULT (getdate()) FOR [MediumSampleDate]
GO
ALTER TABLE [dbo].[MediumSampleResults] ADD  CONSTRAINT [DF_MediumSampleResults_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Occupation] ADD  CONSTRAINT [DF_Occupation_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Person] ADD  CONSTRAINT [DF_Person_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersontoAccessAgreement] ADD  CONSTRAINT [DF_PersontoAccessAgreement_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersontoDaycare] ADD  CONSTRAINT [DF_PersontoDaycare_StartDate]  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [dbo].[PersontoDaycare] ADD  CONSTRAINT [DF_PersontoDaycare_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersontoEmployer] ADD  CONSTRAINT [DF_PersontoEmployer_StartDate]  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [dbo].[PersontoEmployer] ADD  CONSTRAINT [DF_PersontoEmployer_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersontoEthnicity] ADD  CONSTRAINT [DF_PersontoEthnicity_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersontoFamily] ADD  CONSTRAINT [DF_PersontoFamily_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersontoForeignFood] ADD  CONSTRAINT [DF_PersontoForeignFood_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersontoHobby] ADD  CONSTRAINT [DF_PersontoHobby_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersontoHomeRemedy] ADD  CONSTRAINT [DF_PersontoHomeRemedy_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersontoInsurance] ADD  CONSTRAINT [DF_PersontoInsurance_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersontoLanguage] ADD  CONSTRAINT [DF_PersontoLanguage_isPrimaryLanguage]  DEFAULT ((1)) FOR [isPrimaryLanguage]
GO
ALTER TABLE [dbo].[PersontoLanguage] ADD  CONSTRAINT [DF_PersontoLanguage_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersontoOccupation] ADD  CONSTRAINT [DF_PersontoOccupation_StartDate]  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [dbo].[PersontoOccupation] ADD  CONSTRAINT [DF_PersontoOccupation_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersontoPerson] ADD  CONSTRAINT [DF_PersontoPerson_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersontoPerson] ADD  CONSTRAINT [DF_PersontoPerson_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[PersontoPhoneNumber] ADD  CONSTRAINT [DF_PersontoPhoneNumber_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersontoProperty] ADD  CONSTRAINT [DF_PersontoProperty_StartDate]  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [dbo].[PersontoProperty] ADD  CONSTRAINT [DF_PersontoProperty_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersonToStatus] ADD  CONSTRAINT [DF_PersonToStatus_StatusDate]  DEFAULT (getdate()) FOR [StatusDate]
GO
ALTER TABLE [dbo].[PersonToStatus] ADD  CONSTRAINT [DF_PersonToStatus_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PersonToTravelCountry] ADD  CONSTRAINT [DF_PersonToTravelCountry_StartDate]  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [dbo].[PersonToTravelCountry] ADD  CONSTRAINT [DF_PersonToTravelCountry_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PhoneNumber] ADD  CONSTRAINT [DF_PhoneNumber_CountryCode]  DEFAULT ((1)) FOR [CountryCode]
GO
ALTER TABLE [dbo].[PhoneNumber] ADD  CONSTRAINT [DF_PhoneNumber_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PhoneNumberType] ADD  CONSTRAINT [DF_PhoneNumberType_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Property] ADD  CONSTRAINT [DF_Property_InsertDate]  DEFAULT (getdate()) FOR [InsertDate]
GO
ALTER TABLE [dbo].[Property] ADD  CONSTRAINT [DF_Property_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PropertySampleResults] ADD  CONSTRAINT [DF_PropertyTestResults_isBaseline]  DEFAULT ((0)) FOR [isBaseline]
GO
ALTER TABLE [dbo].[PropertySampleResults] ADD  CONSTRAINT [DF_PropertySampleResults_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PropertytoCleanupStatus] ADD  CONSTRAINT [DF_PropertytoCleanupStatus_CleanupStatusDate]  DEFAULT (getdate()) FOR [CleanupStatusDate]
GO
ALTER TABLE [dbo].[PropertytoCleanupStatus] ADD  CONSTRAINT [DF_PropertytoCleanupStatus_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PropertytoHouseholdSourcesofLead] ADD  CONSTRAINT [DF_PropertytoHouseholdSourcesofLead_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[PropertytoMedium] ADD  CONSTRAINT [DF_PropertytoMedium_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Questionnaire] ADD  CONSTRAINT [DF_Questionnaire_isTakingVitamins]  DEFAULT ((0)) FOR [isTakingVitamins]
GO
ALTER TABLE [dbo].[Questionnaire] ADD  CONSTRAINT [DF_Questionnaire_isNursing]  DEFAULT ((0)) FOR [isNursing]
GO
ALTER TABLE [dbo].[Questionnaire] ADD  CONSTRAINT [DF_Questionnaire_isUsingPacifier]  DEFAULT ((0)) FOR [isUsingPacifier]
GO
ALTER TABLE [dbo].[Questionnaire] ADD  CONSTRAINT [DF_Questionnaire_isUsingBottle]  DEFAULT ((0)) FOR [isUsingBottle]
GO
ALTER TABLE [dbo].[Questionnaire] ADD  CONSTRAINT [DF_Questionnaire_Bitesnails]  DEFAULT ((0)) FOR [BitesNails]
GO
ALTER TABLE [dbo].[Questionnaire] ADD  CONSTRAINT [DF_Questionnaire_NonFoodEating]  DEFAULT ((0)) FOR [NonFoodEating]
GO
ALTER TABLE [dbo].[Questionnaire] ADD  CONSTRAINT [DF_Questionnaire_NonFoodinMouth]  DEFAULT ((0)) FOR [NonFoodinMouth]
GO
ALTER TABLE [dbo].[Questionnaire] ADD  CONSTRAINT [DF_Questionnaire_EatOutside]  DEFAULT ((0)) FOR [EatOutside]
GO
ALTER TABLE [dbo].[Questionnaire] ADD  CONSTRAINT [DF_Questionnaire_Suckling]  DEFAULT ((0)) FOR [Suckling]
GO
ALTER TABLE [dbo].[Questionnaire] ADD  CONSTRAINT [DF_Questionnaire_FrequentHandWashing]  DEFAULT ((0)) FOR [FrequentHandWashing]
GO
ALTER TABLE [dbo].[Questionnaire] ADD  CONSTRAINT [DF_Questionnaire_Daycare]  DEFAULT ((1)) FOR [Daycare]
GO
ALTER TABLE [dbo].[Questionnaire] ADD  CONSTRAINT [DF_Questionnaire_InsertDate]  DEFAULT (getdate()) FOR [InsertDate]
GO
ALTER TABLE [dbo].[Questionnaire] ADD  CONSTRAINT [DF_Questionnaire_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[RelationshipType] ADD  CONSTRAINT [DF_RelationshipType_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[RelationshipType] ADD  CONSTRAINT [DF_RelationshipType_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[Remediation] ADD  CONSTRAINT [DF_Remediation_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[RemediationActionPlan] ADD  CONSTRAINT [DF_RemediationActionPlan_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[SampleLevelCategory] ADD  CONSTRAINT [DF_SampleLevelCategory_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[SampleType] ADD  CONSTRAINT [DF_SampleType_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Status] ADD  CONSTRAINT [DF_Status_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Units] ADD  CONSTRAINT [DF_Units_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[AccessAgreement]  WITH CHECK ADD  CONSTRAINT [FK_AccessAgreement_AccessPurpose] FOREIGN KEY([AccessPurposeID])
REFERENCES [dbo].[AccessPurpose] ([AccessPurposeID])
GO
ALTER TABLE [dbo].[AccessAgreement] CHECK CONSTRAINT [FK_AccessAgreement_AccessPurpose]
GO
ALTER TABLE [dbo].[AccessAgreement]  WITH CHECK ADD  CONSTRAINT [FK_AccessAgreement_Property] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([PropertyID])
GO
ALTER TABLE [dbo].[AccessAgreement] CHECK CONSTRAINT [FK_AccessAgreement_Property]
GO
ALTER TABLE [dbo].[BloodTestResults]  WITH CHECK ADD  CONSTRAINT [FK_BloodTestResults_HematocritLevelCategory] FOREIGN KEY([HematocritValueCategoryID])
REFERENCES [dbo].[SampleLevelCategory] ([SampleLevelCategoryID])
GO
ALTER TABLE [dbo].[BloodTestResults] CHECK CONSTRAINT [FK_BloodTestResults_HematocritLevelCategory]
GO
ALTER TABLE [dbo].[BloodTestResults]  WITH CHECK ADD  CONSTRAINT [FK_BloodTestResults_HemoglobinLevelCategory] FOREIGN KEY([HemoglobinValueCategoryID])
REFERENCES [dbo].[SampleLevelCategory] ([SampleLevelCategoryID])
GO
ALTER TABLE [dbo].[BloodTestResults] CHECK CONSTRAINT [FK_BloodTestResults_HemoglobinLevelCategory]
GO
ALTER TABLE [dbo].[BloodTestResults]  WITH CHECK ADD  CONSTRAINT [FK_BloodTestResults_Lab] FOREIGN KEY([LabID])
REFERENCES [dbo].[Lab] ([LabID])
GO
ALTER TABLE [dbo].[BloodTestResults] CHECK CONSTRAINT [FK_BloodTestResults_Lab]
GO
ALTER TABLE [dbo].[BloodTestResults]  WITH CHECK ADD  CONSTRAINT [FK_BloodTestResults_LeadLevelCategory] FOREIGN KEY([LeadValueCategoryID])
REFERENCES [dbo].[SampleLevelCategory] ([SampleLevelCategoryID])
GO
ALTER TABLE [dbo].[BloodTestResults] CHECK CONSTRAINT [FK_BloodTestResults_LeadLevelCategory]
GO
ALTER TABLE [dbo].[BloodTestResults]  WITH CHECK ADD  CONSTRAINT [FK_BloodTestResults_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[BloodTestResults] CHECK CONSTRAINT [FK_BloodTestResults_Person]
GO
ALTER TABLE [dbo].[BloodTestResults]  WITH CHECK ADD  CONSTRAINT [FK_BloodTestResults_SampleType] FOREIGN KEY([SampleTypeID])
REFERENCES [dbo].[SampleType] ([SampleTypeID])
GO
ALTER TABLE [dbo].[BloodTestResults] CHECK CONSTRAINT [FK_BloodTestResults_SampleType]
GO
ALTER TABLE [dbo].[ContractortoProperty]  WITH CHECK ADD  CONSTRAINT [FK_ContractortoProperty_Contractor] FOREIGN KEY([ContractorID])
REFERENCES [dbo].[Contractor] ([ContractorID])
GO
ALTER TABLE [dbo].[ContractortoProperty] CHECK CONSTRAINT [FK_ContractortoProperty_Contractor]
GO
ALTER TABLE [dbo].[ContractortoProperty]  WITH CHECK ADD  CONSTRAINT [FK_ContractortoProperty_Property] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([PropertyID])
GO
ALTER TABLE [dbo].[ContractortoProperty] CHECK CONSTRAINT [FK_ContractortoProperty_Property]
GO
ALTER TABLE [dbo].[ContractortoRemediation]  WITH CHECK ADD  CONSTRAINT [FK_ContractortoRemediation_Contractor] FOREIGN KEY([ContractorID])
REFERENCES [dbo].[Contractor] ([ContractorID])
GO
ALTER TABLE [dbo].[ContractortoRemediation] CHECK CONSTRAINT [FK_ContractortoRemediation_Contractor]
GO
ALTER TABLE [dbo].[ContractortoRemediation]  WITH CHECK ADD  CONSTRAINT [FK_ContractortoRemediation_Remediation] FOREIGN KEY([RemediationID])
REFERENCES [dbo].[Remediation] ([RemediationID])
GO
ALTER TABLE [dbo].[ContractortoRemediation] CHECK CONSTRAINT [FK_ContractortoRemediation_Remediation]
GO
ALTER TABLE [dbo].[ContractortoRemediationActionPlan]  WITH CHECK ADD  CONSTRAINT [FK_ContractortoRemediationActionPlan_Contractor] FOREIGN KEY([ContractorID])
REFERENCES [dbo].[Contractor] ([ContractorID])
GO
ALTER TABLE [dbo].[ContractortoRemediationActionPlan] CHECK CONSTRAINT [FK_ContractortoRemediationActionPlan_Contractor]
GO
ALTER TABLE [dbo].[ContractortoRemediationActionPlan]  WITH CHECK ADD  CONSTRAINT [FK_ContractortoRemediationActionPlan_RemediationActionPlan] FOREIGN KEY([RemediationActionPlanID])
REFERENCES [dbo].[RemediationActionPlan] ([RemediationActionPlanID])
GO
ALTER TABLE [dbo].[ContractortoRemediationActionPlan] CHECK CONSTRAINT [FK_ContractortoRemediationActionPlan_RemediationActionPlan]
GO
ALTER TABLE [dbo].[ContractortoRemediationActionPlan]  WITH CHECK ADD  CONSTRAINT [FK_ContractortoRemediationPlan_RemediationActionPlan] FOREIGN KEY([RemediationActionPlanID])
REFERENCES [dbo].[RemediationActionPlan] ([RemediationActionPlanID])
GO
ALTER TABLE [dbo].[ContractortoRemediationActionPlan] CHECK CONSTRAINT [FK_ContractortoRemediationPlan_RemediationActionPlan]
GO
ALTER TABLE [dbo].[ContractortoRemediationActionPlan]  WITH CHECK ADD  CONSTRAINT [FK_ContractortoSamplingPlan_Contractor] FOREIGN KEY([ContractorID])
REFERENCES [dbo].[Contractor] ([ContractorID])
GO
ALTER TABLE [dbo].[ContractortoRemediationActionPlan] CHECK CONSTRAINT [FK_ContractortoSamplingPlan_Contractor]
GO
ALTER TABLE [dbo].[DaycarePrimaryContact]  WITH CHECK ADD  CONSTRAINT [FK_DaycareContactPerson_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[DaycarePrimaryContact] CHECK CONSTRAINT [FK_DaycareContactPerson_Person]
GO
ALTER TABLE [dbo].[DaycarePrimaryContact]  WITH CHECK ADD  CONSTRAINT [FK_DaycarePrimaryContact_PersontoPhoneNumber] FOREIGN KEY([PersonID], [PrimaryPhoneNumberID])
REFERENCES [dbo].[PersontoPhoneNumber] ([PersonID], [PhoneNumberID])
GO
ALTER TABLE [dbo].[DaycarePrimaryContact] CHECK CONSTRAINT [FK_DaycarePrimaryContact_PersontoPhoneNumber]
GO
ALTER TABLE [dbo].[DaycarePrimaryContact]  WITH CHECK ADD  CONSTRAINT [FK_DaycarePrimaryContact_PhoneNumber] FOREIGN KEY([PrimaryPhoneNumberID])
REFERENCES [dbo].[PhoneNumber] ([PhoneNumberID])
GO
ALTER TABLE [dbo].[DaycarePrimaryContact] CHECK CONSTRAINT [FK_DaycarePrimaryContact_PhoneNumber]
GO
ALTER TABLE [dbo].[DaycaretoProperty]  WITH CHECK ADD  CONSTRAINT [FK_DaycaretoProperty_Daycare] FOREIGN KEY([DaycareID])
REFERENCES [dbo].[Daycare] ([DaycareID])
GO
ALTER TABLE [dbo].[DaycaretoProperty] CHECK CONSTRAINT [FK_DaycaretoProperty_Daycare]
GO
ALTER TABLE [dbo].[DaycaretoProperty]  WITH CHECK ADD  CONSTRAINT [FK_DaycaretoProperty_Property] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([PropertyID])
GO
ALTER TABLE [dbo].[DaycaretoProperty] CHECK CONSTRAINT [FK_DaycaretoProperty_Property]
GO
ALTER TABLE [dbo].[EmployertoProperty]  WITH CHECK ADD  CONSTRAINT [FK_EmployertoProperty_Employer] FOREIGN KEY([EmployerID])
REFERENCES [dbo].[Employer] ([EmployerID])
GO
ALTER TABLE [dbo].[EmployertoProperty] CHECK CONSTRAINT [FK_EmployertoProperty_Employer]
GO
ALTER TABLE [dbo].[EmployertoProperty]  WITH CHECK ADD  CONSTRAINT [FK_EmployertoProperty_Property] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([PropertyID])
GO
ALTER TABLE [dbo].[EmployertoProperty] CHECK CONSTRAINT [FK_EmployertoProperty_Property]
GO
ALTER TABLE [dbo].[EnvironmentalInvestigation]  WITH CHECK ADD  CONSTRAINT [FK_EnvironmentalInvestigation_Property] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([PropertyID])
GO
ALTER TABLE [dbo].[EnvironmentalInvestigation] CHECK CONSTRAINT [FK_EnvironmentalInvestigation_Property]
GO
ALTER TABLE [dbo].[ForeignFoodtoCountry]  WITH CHECK ADD  CONSTRAINT [FK_ForeignFoodtoCountry_Country] FOREIGN KEY([CountryID])
REFERENCES [dbo].[Country] ([CountryID])
GO
ALTER TABLE [dbo].[ForeignFoodtoCountry] CHECK CONSTRAINT [FK_ForeignFoodtoCountry_Country]
GO
ALTER TABLE [dbo].[ForeignFoodtoCountry]  WITH CHECK ADD  CONSTRAINT [FK_ForeignFoodtoCountry_ForeignFood] FOREIGN KEY([ForeignFoodID])
REFERENCES [dbo].[ForeignFood] ([ForeignFoodID])
GO
ALTER TABLE [dbo].[ForeignFoodtoCountry] CHECK CONSTRAINT [FK_ForeignFoodtoCountry_ForeignFood]
GO
ALTER TABLE [dbo].[GiftCard]  WITH CHECK ADD  CONSTRAINT [FK_GiftCard_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[GiftCard] CHECK CONSTRAINT [FK_GiftCard_Person]
GO
ALTER TABLE [dbo].[MediumSampleResults]  WITH CHECK ADD  CONSTRAINT [FK_MediumSampleResults_Lab] FOREIGN KEY([LabID])
REFERENCES [dbo].[Lab] ([LabID])
GO
ALTER TABLE [dbo].[MediumSampleResults] CHECK CONSTRAINT [FK_MediumSampleResults_Lab]
GO
ALTER TABLE [dbo].[MediumSampleResults]  WITH CHECK ADD  CONSTRAINT [FK_MediumSampleResults_Medium] FOREIGN KEY([MediumID])
REFERENCES [dbo].[Medium] ([MediumID])
GO
ALTER TABLE [dbo].[MediumSampleResults] CHECK CONSTRAINT [FK_MediumSampleResults_Medium]
GO
ALTER TABLE [dbo].[MediumSampleResults]  WITH CHECK ADD  CONSTRAINT [FK_MediumSampleResults_SampleLevelCategory] FOREIGN KEY([SampleLevelCategoryID])
REFERENCES [dbo].[SampleLevelCategory] ([SampleLevelCategoryID])
GO
ALTER TABLE [dbo].[MediumSampleResults] CHECK CONSTRAINT [FK_MediumSampleResults_SampleLevelCategory]
GO
ALTER TABLE [dbo].[MediumSampleResults]  WITH CHECK ADD  CONSTRAINT [FK_MediumSampleResults_Units] FOREIGN KEY([UnitsID])
REFERENCES [dbo].[Units] ([UnitsID])
GO
ALTER TABLE [dbo].[MediumSampleResults] CHECK CONSTRAINT [FK_MediumSampleResults_Units]
GO
ALTER TABLE [dbo].[PersontoAccessAgreement]  WITH CHECK ADD  CONSTRAINT [FK_PersontoAccessAgreement_AccessAgreement] FOREIGN KEY([AccessAgreementID])
REFERENCES [dbo].[AccessAgreement] ([AccessAgreementID])
GO
ALTER TABLE [dbo].[PersontoAccessAgreement] CHECK CONSTRAINT [FK_PersontoAccessAgreement_AccessAgreement]
GO
ALTER TABLE [dbo].[PersontoAccessAgreement]  WITH CHECK ADD  CONSTRAINT [FK_PersontoAccessAgreement_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoAccessAgreement] CHECK CONSTRAINT [FK_PersontoAccessAgreement_Person]
GO
ALTER TABLE [dbo].[PersontoDaycare]  WITH CHECK ADD  CONSTRAINT [FK_PersontoDaycare_Daycare] FOREIGN KEY([DaycareID])
REFERENCES [dbo].[Daycare] ([DaycareID])
GO
ALTER TABLE [dbo].[PersontoDaycare] CHECK CONSTRAINT [FK_PersontoDaycare_Daycare]
GO
ALTER TABLE [dbo].[PersontoDaycare]  WITH CHECK ADD  CONSTRAINT [FK_PersontoDaycare_PersontoDaycare] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoDaycare] CHECK CONSTRAINT [FK_PersontoDaycare_PersontoDaycare]
GO
ALTER TABLE [dbo].[PersontoEmployer]  WITH CHECK ADD  CONSTRAINT [FK_PersontoEmployer_Employer] FOREIGN KEY([EmployerID])
REFERENCES [dbo].[Employer] ([EmployerID])
GO
ALTER TABLE [dbo].[PersontoEmployer] CHECK CONSTRAINT [FK_PersontoEmployer_Employer]
GO
ALTER TABLE [dbo].[PersontoEmployer]  WITH CHECK ADD  CONSTRAINT [FK_PersontoEmployer_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoEmployer] CHECK CONSTRAINT [FK_PersontoEmployer_Person]
GO
ALTER TABLE [dbo].[PersontoEthnicity]  WITH CHECK ADD  CONSTRAINT [FK_PersontoEthnicity_Ethnicity] FOREIGN KEY([EthnicityID])
REFERENCES [dbo].[Ethnicity] ([EthnicityID])
GO
ALTER TABLE [dbo].[PersontoEthnicity] CHECK CONSTRAINT [FK_PersontoEthnicity_Ethnicity]
GO
ALTER TABLE [dbo].[PersontoEthnicity]  WITH CHECK ADD  CONSTRAINT [FK_PersontoEthnicity_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoEthnicity] CHECK CONSTRAINT [FK_PersontoEthnicity_Person]
GO
ALTER TABLE [dbo].[PersontoFamily]  WITH CHECK ADD  CONSTRAINT [FK_PersontoFamily_Family] FOREIGN KEY([FamilyID])
REFERENCES [dbo].[Family] ([FamilyID])
GO
ALTER TABLE [dbo].[PersontoFamily] CHECK CONSTRAINT [FK_PersontoFamily_Family]
GO
ALTER TABLE [dbo].[PersontoFamily]  WITH CHECK ADD  CONSTRAINT [FK_PersontoFamily_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoFamily] CHECK CONSTRAINT [FK_PersontoFamily_Person]
GO
ALTER TABLE [dbo].[PersontoForeignFood]  WITH CHECK ADD  CONSTRAINT [FK_PersontoForeignFood_ForeignFood] FOREIGN KEY([ForeignFoodID])
REFERENCES [dbo].[ForeignFood] ([ForeignFoodID])
GO
ALTER TABLE [dbo].[PersontoForeignFood] CHECK CONSTRAINT [FK_PersontoForeignFood_ForeignFood]
GO
ALTER TABLE [dbo].[PersontoForeignFood]  WITH CHECK ADD  CONSTRAINT [FK_PersontoForeignFood_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoForeignFood] CHECK CONSTRAINT [FK_PersontoForeignFood_Person]
GO
ALTER TABLE [dbo].[PersontoHobby]  WITH CHECK ADD  CONSTRAINT [FK_PersontoHobby_Hobby] FOREIGN KEY([HobbyID])
REFERENCES [dbo].[Hobby] ([HobbyID])
GO
ALTER TABLE [dbo].[PersontoHobby] CHECK CONSTRAINT [FK_PersontoHobby_Hobby]
GO
ALTER TABLE [dbo].[PersontoHobby]  WITH CHECK ADD  CONSTRAINT [FK_PersontoHobby_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoHobby] CHECK CONSTRAINT [FK_PersontoHobby_Person]
GO
ALTER TABLE [dbo].[PersontoHomeRemedy]  WITH CHECK ADD  CONSTRAINT [FK_PersontoHomeRemedy_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoHomeRemedy] CHECK CONSTRAINT [FK_PersontoHomeRemedy_Person]
GO
ALTER TABLE [dbo].[PersontoHomeRemedy]  WITH CHECK ADD  CONSTRAINT [FK_PersontoHomeRemedy_PersontoHomeRemedy] FOREIGN KEY([HomeRemedyID])
REFERENCES [dbo].[HomeRemedy] ([HomeRemedyID])
GO
ALTER TABLE [dbo].[PersontoHomeRemedy] CHECK CONSTRAINT [FK_PersontoHomeRemedy_PersontoHomeRemedy]
GO
ALTER TABLE [dbo].[PersontoInsurance]  WITH CHECK ADD  CONSTRAINT [FK_PersontoInsurance_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoInsurance] CHECK CONSTRAINT [FK_PersontoInsurance_Person]
GO
ALTER TABLE [dbo].[PersontoInsurance]  WITH CHECK ADD  CONSTRAINT [FK_PersontoInsurance_PersontoInsurance] FOREIGN KEY([InsuranceID])
REFERENCES [dbo].[InsuranceProvider] ([InsuranceProviderID])
GO
ALTER TABLE [dbo].[PersontoInsurance] CHECK CONSTRAINT [FK_PersontoInsurance_PersontoInsurance]
GO
ALTER TABLE [dbo].[PersontoLanguage]  WITH CHECK ADD  CONSTRAINT [FK_PersontoLanguage_Language] FOREIGN KEY([LanguageID])
REFERENCES [dbo].[Language] ([LanguageID])
GO
ALTER TABLE [dbo].[PersontoLanguage] CHECK CONSTRAINT [FK_PersontoLanguage_Language]
GO
ALTER TABLE [dbo].[PersontoLanguage]  WITH CHECK ADD  CONSTRAINT [FK_PersontoLanguage_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoLanguage] CHECK CONSTRAINT [FK_PersontoLanguage_Person]
GO
ALTER TABLE [dbo].[PersontoOccupation]  WITH CHECK ADD  CONSTRAINT [FK_PersontoOccupation_Occupation] FOREIGN KEY([OccupationID])
REFERENCES [dbo].[Occupation] ([OccupationID])
GO
ALTER TABLE [dbo].[PersontoOccupation] CHECK CONSTRAINT [FK_PersontoOccupation_Occupation]
GO
ALTER TABLE [dbo].[PersontoOccupation]  WITH CHECK ADD  CONSTRAINT [FK_PersontoOccupation_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoOccupation] CHECK CONSTRAINT [FK_PersontoOccupation_Person]
GO
ALTER TABLE [dbo].[PersontoPerson]  WITH CHECK ADD  CONSTRAINT [FK_PersontoPerson_Person1ID] FOREIGN KEY([Person1ID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoPerson] CHECK CONSTRAINT [FK_PersontoPerson_Person1ID]
GO
ALTER TABLE [dbo].[PersontoPerson]  WITH CHECK ADD  CONSTRAINT [FK_PersontoPerson_Person2ID] FOREIGN KEY([Person2ID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoPerson] CHECK CONSTRAINT [FK_PersontoPerson_Person2ID]
GO
ALTER TABLE [dbo].[PersontoPerson]  WITH CHECK ADD  CONSTRAINT [FK_PersontoPerson_RelationshipType] FOREIGN KEY([RelationshipTypeID])
REFERENCES [dbo].[RelationshipType] ([RelationshipTypeID])
GO
ALTER TABLE [dbo].[PersontoPerson] CHECK CONSTRAINT [FK_PersontoPerson_RelationshipType]
GO
ALTER TABLE [dbo].[PersontoPhoneNumber]  WITH CHECK ADD  CONSTRAINT [FK_PersontoPhoneNumber_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoPhoneNumber] CHECK CONSTRAINT [FK_PersontoPhoneNumber_Person]
GO
ALTER TABLE [dbo].[PersontoPhoneNumber]  WITH CHECK ADD  CONSTRAINT [FK_PersontoPhoneNumber_PhoneNumber] FOREIGN KEY([PhoneNumberID])
REFERENCES [dbo].[PhoneNumber] ([PhoneNumberID])
GO
ALTER TABLE [dbo].[PersontoPhoneNumber] CHECK CONSTRAINT [FK_PersontoPhoneNumber_PhoneNumber]
GO
ALTER TABLE [dbo].[PersontoProperty]  WITH CHECK ADD  CONSTRAINT [FK_PersontoProperty_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersontoProperty] CHECK CONSTRAINT [FK_PersontoProperty_Person]
GO
ALTER TABLE [dbo].[PersontoProperty]  WITH CHECK ADD  CONSTRAINT [FK_PersontoProperty_Property] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([PropertyID])
GO
ALTER TABLE [dbo].[PersontoProperty] CHECK CONSTRAINT [FK_PersontoProperty_Property]
GO
ALTER TABLE [dbo].[PersonToStatus]  WITH CHECK ADD  CONSTRAINT [FK_PersonToStatus_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersonToStatus] CHECK CONSTRAINT [FK_PersonToStatus_Person]
GO
ALTER TABLE [dbo].[PersonToStatus]  WITH CHECK ADD  CONSTRAINT [FK_PersonToStatus_Status] FOREIGN KEY([StatusID])
REFERENCES [dbo].[Status] ([StatusID])
GO
ALTER TABLE [dbo].[PersonToStatus] CHECK CONSTRAINT [FK_PersonToStatus_Status]
GO
ALTER TABLE [dbo].[PersonToTravelCountry]  WITH CHECK ADD  CONSTRAINT [FK_PersonToTravelCountry_Country] FOREIGN KEY([CountryID])
REFERENCES [dbo].[Country] ([CountryID])
GO
ALTER TABLE [dbo].[PersonToTravelCountry] CHECK CONSTRAINT [FK_PersonToTravelCountry_Country]
GO
ALTER TABLE [dbo].[PersonToTravelCountry]  WITH CHECK ADD  CONSTRAINT [FK_PersonToTravelCountry_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[PersonToTravelCountry] CHECK CONSTRAINT [FK_PersonToTravelCountry_Person]
GO
ALTER TABLE [dbo].[PhoneNumber]  WITH CHECK ADD  CONSTRAINT [FK_PhoneNumber_PhoneNumber] FOREIGN KEY([PhoneNumberTypeID])
REFERENCES [dbo].[PhoneNumberType] ([PhoneNumberTypeID])
GO
ALTER TABLE [dbo].[PhoneNumber] CHECK CONSTRAINT [FK_PhoneNumber_PhoneNumber]
GO
ALTER TABLE [dbo].[Property]  WITH CHECK ADD  CONSTRAINT [FK_Property_Area] FOREIGN KEY([AreaID])
REFERENCES [dbo].[Area] ([AreaID])
GO
ALTER TABLE [dbo].[Property] CHECK CONSTRAINT [FK_Property_Area]
GO
ALTER TABLE [dbo].[Property]  WITH CHECK ADD  CONSTRAINT [FK_Property_ConstructionType] FOREIGN KEY([ConstructionTypeID])
REFERENCES [dbo].[ConstructionType] ([ConstructionTypeID])
GO
ALTER TABLE [dbo].[Property] CHECK CONSTRAINT [FK_Property_ConstructionType]
GO
ALTER TABLE [dbo].[Property]  WITH CHECK ADD  CONSTRAINT [FK_Property_Person] FOREIGN KEY([OwnerID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[Property] CHECK CONSTRAINT [FK_Property_Person]
GO
ALTER TABLE [dbo].[PropertySampleResults]  WITH CHECK ADD  CONSTRAINT [FK_PropertySampleResults_SampleType] FOREIGN KEY([SampleTypeID])
REFERENCES [dbo].[SampleType] ([SampleTypeID])
GO
ALTER TABLE [dbo].[PropertySampleResults] CHECK CONSTRAINT [FK_PropertySampleResults_SampleType]
GO
ALTER TABLE [dbo].[PropertySampleResults]  WITH CHECK ADD  CONSTRAINT [FK_PropertySampletResults_Property] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([PropertyID])
GO
ALTER TABLE [dbo].[PropertySampleResults] CHECK CONSTRAINT [FK_PropertySampletResults_Property]
GO
ALTER TABLE [dbo].[PropertytoCleanupStatus]  WITH CHECK ADD  CONSTRAINT [FK_PropertytoCleanupStatus_CleanupStatus] FOREIGN KEY([CleanupStatusID])
REFERENCES [dbo].[CleanupStatus] ([CleanupStatusID])
GO
ALTER TABLE [dbo].[PropertytoCleanupStatus] CHECK CONSTRAINT [FK_PropertytoCleanupStatus_CleanupStatus]
GO
ALTER TABLE [dbo].[PropertytoCleanupStatus]  WITH CHECK ADD  CONSTRAINT [FK_PropertytoCleanupStatus_Property] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([PropertyID])
GO
ALTER TABLE [dbo].[PropertytoCleanupStatus] CHECK CONSTRAINT [FK_PropertytoCleanupStatus_Property]
GO
ALTER TABLE [dbo].[PropertytoHouseholdSourcesofLead]  WITH CHECK ADD  CONSTRAINT [FK_HouseholdSourcesofLead_PropertytoHouseholdSourcesofLead] FOREIGN KEY([HouseholdSourcesofLeadID])
REFERENCES [dbo].[HouseholdSourcesofLead] ([HouseholdSourcesofLeadID])
GO
ALTER TABLE [dbo].[PropertytoHouseholdSourcesofLead] CHECK CONSTRAINT [FK_HouseholdSourcesofLead_PropertytoHouseholdSourcesofLead]
GO
ALTER TABLE [dbo].[PropertytoHouseholdSourcesofLead]  WITH CHECK ADD  CONSTRAINT [FK_Property_PropertytoHouseholdSourcesofLead] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([PropertyID])
GO
ALTER TABLE [dbo].[PropertytoHouseholdSourcesofLead] CHECK CONSTRAINT [FK_Property_PropertytoHouseholdSourcesofLead]
GO
ALTER TABLE [dbo].[PropertytoMedium]  WITH CHECK ADD  CONSTRAINT [FK_PropertytoMedium_Medium] FOREIGN KEY([MediumID])
REFERENCES [dbo].[Medium] ([MediumID])
GO
ALTER TABLE [dbo].[PropertytoMedium] CHECK CONSTRAINT [FK_PropertytoMedium_Medium]
GO
ALTER TABLE [dbo].[PropertytoMedium]  WITH CHECK ADD  CONSTRAINT [FK_PropertytoMedium_Property] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([PropertyID])
GO
ALTER TABLE [dbo].[PropertytoMedium] CHECK CONSTRAINT [FK_PropertytoMedium_Property]
GO
ALTER TABLE [dbo].[Questionnaire]  WITH CHECK ADD  CONSTRAINT [FK_Questionnaire_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[Questionnaire] CHECK CONSTRAINT [FK_Questionnaire_Person]
GO
ALTER TABLE [dbo].[Remediation]  WITH CHECK ADD  CONSTRAINT [FK_Remediation_Property] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([PropertyID])
GO
ALTER TABLE [dbo].[Remediation] CHECK CONSTRAINT [FK_Remediation_Property]
GO
ALTER TABLE [dbo].[Remediation]  WITH CHECK ADD  CONSTRAINT [FK_Remediation_RemediationActionPlan] FOREIGN KEY([RemediationActionPlanID])
REFERENCES [dbo].[RemediationActionPlan] ([RemediationActionPlanID])
GO
ALTER TABLE [dbo].[Remediation] CHECK CONSTRAINT [FK_Remediation_RemediationActionPlan]
GO
ALTER TABLE [dbo].[RemediationActionPlan]  WITH CHECK ADD  CONSTRAINT [FK_RemediationActionPlan_EnvironmentalInvestigation] FOREIGN KEY([EnvironmentalInvestigationID])
REFERENCES [dbo].[EnvironmentalInvestigation] ([EnvironmentalInvestigationID])
GO
ALTER TABLE [dbo].[RemediationActionPlan] CHECK CONSTRAINT [FK_RemediationActionPlan_EnvironmentalInvestigation]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the access purpose' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccessAgreement', @level2type=N'COLUMN',@level2name=N'AccessPurposeID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of access agreements' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccessAgreement'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'friendly name for the access purpose' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccessPurpose', @level2type=N'COLUMN',@level2name=N'AccessPurposeName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'a description of the access purpose' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccessPurpose', @level2type=N'COLUMN',@level2name=N'AccessPurposeDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of purposes for access requests/agreements' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccessPurpose'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier of the area' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Area', @level2type=N'COLUMN',@level2name=N'AreaID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'friendly description/name of the area' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Area', @level2type=N'COLUMN',@level2name=N'AreaDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of areas and basic information' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Area'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier for the blood test results object' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BloodTestResults', @level2type=N'COLUMN',@level2name=N'BloodTestResultsID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 = no; 1 = yes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BloodTestResults', @level2type=N'COLUMN',@level2name=N'isBaseline'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the sample was taken' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BloodTestResults', @level2type=N'COLUMN',@level2name=N'SampleDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the sample was submitted to the lab' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BloodTestResults', @level2type=N'COLUMN',@level2name=N'LabSubmissionDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the associated lead value categorization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BloodTestResults', @level2type=N'COLUMN',@level2name=N'LeadValueCategoryID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the associated hemoglobin value categorization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BloodTestResults', @level2type=N'COLUMN',@level2name=N'HemoglobinValueCategoryID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the associated hematocrit value categorization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BloodTestResults', @level2type=N'COLUMN',@level2name=N'HematocritValueCategoryID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the lab to which the samples were submitted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BloodTestResults', @level2type=N'COLUMN',@level2name=N'LabID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'cost of the blood tests' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BloodTestResults', @level2type=N'COLUMN',@level2name=N'BloodTestCosts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the type of sample; i.e. venus, capo, soil, water, nitton analyzer . . . ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BloodTestResults', @level2type=N'COLUMN',@level2name=N'SampleTypeID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - No, 1 - yes; was the blood sample taken after property remediation was completed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BloodTestResults', @level2type=N'COLUMN',@level2name=N'TakenAfterPropertyRemediationCompleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Collection of blood test result values and categorization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BloodTestResults'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier of the cleanup status object' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CleanupStatus', @level2type=N'COLUMN',@level2name=N'CleanupStatusID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'description of the cleanup status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CleanupStatus', @level2type=N'COLUMN',@level2name=N'CleanupStatusDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'short name for the cleanup status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CleanupStatus', @level2type=N'COLUMN',@level2name=N'CleanupStatusName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of clean up status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CleanupStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier of the construction type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConstructionType', @level2type=N'COLUMN',@level2name=N'ConstructionTypeID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'description of the construction type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConstructionType', @level2type=N'COLUMN',@level2name=N'ConstructionTypeName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of construction types' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConstructionType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the contractor started occuping the property' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContractortoProperty', @level2type=N'COLUMN',@level2name=N'StartDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date contractor ended property occupation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContractortoProperty', @level2type=N'COLUMN',@level2name=N'EndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for contractor and occupied properties' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContractortoProperty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'building which the contractor occupies for purpose of business (contractor offices)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContractortoProperty', @level2type=N'CONSTRAINT',@level2name=N'FK_ContractortoProperty_Contractor'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the contractor started working on the remidiation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContractortoRemediation', @level2type=N'COLUMN',@level2name=N'StartDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the contractor stopped working on the remediation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContractortoRemediation', @level2type=N'COLUMN',@level2name=N'EndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - no, 1 - yes.  is this contractor a sub contractor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContractortoRemediation', @level2type=N'COLUMN',@level2name=N'isSubContractor'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for contractors and remediations' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContractortoRemediation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for contractor and sampling plan' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ContractortoRemediationActionPlan'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier of the country' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country', @level2type=N'COLUMN',@level2name=N'CountryID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'name of the country' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country', @level2type=N'COLUMN',@level2name=N'CountryName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of countries' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'name of the daycare' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Daycare', @level2type=N'COLUMN',@level2name=N'DaycareName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'short description of the daycare business' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Daycare', @level2type=N'COLUMN',@level2name=N'DaycareDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of daycare facilities' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Daycare'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'priority of this person in the contact list (1 being highest priority)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DaycarePrimaryContact', @level2type=N'COLUMN',@level2name=N'ContactPriority'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the primary contact number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DaycarePrimaryContact', @level2type=N'COLUMN',@level2name=N'PrimaryPhoneNumberID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for daycare and person - identifying contact person' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DaycarePrimaryContact'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the daycare started occupying the property' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DaycaretoProperty', @level2type=N'COLUMN',@level2name=N'StartDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the daycare stopped occupying the property' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DaycaretoProperty', @level2type=N'COLUMN',@level2name=N'EndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for daycare and property' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DaycaretoProperty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier of the employer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Employer', @level2type=N'COLUMN',@level2name=N'EmployerID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'name of the employer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Employer', @level2type=N'COLUMN',@level2name=N'EmployerName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of employers' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Employer'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the employer started occuppying the property' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployertoProperty', @level2type=N'COLUMN',@level2name=N'StartDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the employer stopped occuppying the property' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployertoProperty', @level2type=N'COLUMN',@level2name=N'EndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for employer and property' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmployertoProperty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - no, 1 - yes; is an environmental investigation going to be conducted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnvironmentalInvestigation', @level2type=N'COLUMN',@level2name=N'ConductEnvironmentalInvestigation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the workgroup decided whether to conduct an environmental investigation or not' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnvironmentalInvestigation', @level2type=N'COLUMN',@level2name=N'ConductEnvironmentalInvestigationDecisionDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'cost of the environmental investigation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnvironmentalInvestigation', @level2type=N'COLUMN',@level2name=N'Cost'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier of ethnicities' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Ethnicity', @level2type=N'COLUMN',@level2name=N'EthnicityID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'friendly shortname of ethnicity' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Ethnicity', @level2type=N'COLUMN',@level2name=N'Ethnicity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of ethnicities' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Ethnicity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier for the family object' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Family', @level2type=N'COLUMN',@level2name=N'FamilyID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'family name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Family', @level2type=N'COLUMN',@level2name=N'Lastname'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'number of smokers in the family' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Family', @level2type=N'COLUMN',@level2name=N'NumberofSmokers'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the families primary language; default = 1 (English)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Family', @level2type=N'COLUMN',@level2name=N'PrimaryLanguageID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of families' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Family'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of various foreign foods' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ForeignFood'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'foreign food and country linking table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ForeignFoodtoCountry'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier for the gift certificate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GiftCard', @level2type=N'COLUMN',@level2name=N'GiftCardID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'value of the gift certificate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GiftCard', @level2type=N'COLUMN',@level2name=N'GiftCardValue'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of gift certificate objects' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GiftCard'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier of hobby objects' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Hobby', @level2type=N'COLUMN',@level2name=N'HobbyID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'short description of the hobby' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Hobby', @level2type=N'COLUMN',@level2name=N'HobbyDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of hobbies' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Hobby'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of home remedies' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'HomeRemedy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'household items that may contribute to EBL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'HouseholdSourcesofLead'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier for insurance company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InsuranceProvider', @level2type=N'COLUMN',@level2name=N'InsuranceProviderID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'name of the insurance company' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InsuranceProvider', @level2type=N'COLUMN',@level2name=N'InsuranceProviderName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of insurance companies' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InsuranceProvider'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier for the lab object' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Lab', @level2type=N'COLUMN',@level2name=N'LabID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of lab names and basic attributes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Lab'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier of langauge object' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Language', @level2type=N'COLUMN',@level2name=N'LanguageID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'spoken language' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Language', @level2type=N'COLUMN',@level2name=N'LanguageName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of spoken languages' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Language'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier of the medium' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Medium', @level2type=N'COLUMN',@level2name=N'MediumID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'short name for the medium' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Medium', @level2type=N'COLUMN',@level2name=N'MediumName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'short description of the medium' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Medium', @level2type=N'COLUMN',@level2name=N'MediumDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'mediumcode identifier from legacy database' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Medium', @level2type=N'COLUMN',@level2name=N'HistoricMediumCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of mediums that are tested' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Medium'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tested medium id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MediumSampleResults', @level2type=N'COLUMN',@level2name=N'MediumID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'value of the test result for the medium' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MediumSampleResults', @level2type=N'COLUMN',@level2name=N'MediumSampleValue'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'sample level category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MediumSampleResults', @level2type=N'COLUMN',@level2name=N'SampleLevelCategoryID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the medium was tested' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MediumSampleResults', @level2type=N'COLUMN',@level2name=N'MediumSampleDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the lab to which the sample was submitted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MediumSampleResults', @level2type=N'COLUMN',@level2name=N'LabID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the sample was submitted to the lab' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MediumSampleResults', @level2type=N'COLUMN',@level2name=N'LabSubmissionDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'notes about the medium sample' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MediumSampleResults', @level2type=N'COLUMN',@level2name=N'Notes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of test results for various medums' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MediumSampleResults'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier of the occupation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Occupation', @level2type=N'COLUMN',@level2name=N'OccupationID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'name of the occupation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Occupation', @level2type=N'COLUMN',@level2name=N'OccupationName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'short description of the occupation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Occupation', @level2type=N'COLUMN',@level2name=N'OccupationDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of occupation objects' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Occupation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier for each person' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Person', @level2type=N'COLUMN',@level2name=N'PersonID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'personID of the person''s guardian' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Person', @level2type=N'COLUMN',@level2name=N'GuardianID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of people and basic attributes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Person'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the access agreement was signed' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoAccessAgreement', @level2type=N'COLUMN',@level2name=N'AccessAgreementDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for person and access agreement' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoAccessAgreement'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the person started attending the daycare' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoDaycare', @level2type=N'COLUMN',@level2name=N'StartDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the person stopped attending the daycare' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoDaycare', @level2type=N'COLUMN',@level2name=N'EndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for person and daycare for people attending daycare' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoDaycare'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the person started working for the employer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoEmployer', @level2type=N'COLUMN',@level2name=N'StartDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the person stopped working for the employer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoEmployer', @level2type=N'COLUMN',@level2name=N'EndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for person and employer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoEmployer'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for person and ethnicity' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoEthnicity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the corresponding person' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoFamily', @level2type=N'COLUMN',@level2name=N'PersonID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the corresponding family' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoFamily', @level2type=N'COLUMN',@level2name=N'FamilyID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for person and family tables' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoFamily'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for person and foreign food (many to many)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoForeignFood'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for person and hobby' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoHobby'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for perosn and home remedy' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoHomeRemedy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date the person started the insurance policy with the provider' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoInsurance', @level2type=N'COLUMN',@level2name=N'StartDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date the person stopped the insurance policy with the provider' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoInsurance', @level2type=N'COLUMN',@level2name=N'EndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'insurance company and policy group id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoInsurance', @level2type=N'COLUMN',@level2name=N'GroupID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for person and insurance' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoInsurance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 = no; 1 = yes; is this language the person''s primary language' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoLanguage', @level2type=N'COLUMN',@level2name=N'isPrimaryLanguage'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for person and language' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoLanguage'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the person started the occupation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoOccupation', @level2type=N'COLUMN',@level2name=N'StartDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the person ceased the occupation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoOccupation', @level2type=N'COLUMN',@level2name=N'EndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for person and occupatoin' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoOccupation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of relationships between people' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoPerson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1st person in the relationship' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoPerson', @level2type=N'CONSTRAINT',@level2name=N'FK_PersontoPerson_Person1ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'2nd person in the relationship' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoPerson', @level2type=N'CONSTRAINT',@level2name=N'FK_PersontoPerson_Person2ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'how is person1 related to person2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoPerson', @level2type=N'CONSTRAINT',@level2name=N'FK_PersontoPerson_RelationshipType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'order which this number should be used to contact the person (1 being first, 2 being 2nd . . . )' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoPhoneNumber', @level2type=N'COLUMN',@level2name=N'NumberPriority'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for person and phonenumber' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoPhoneNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the person started occuppying the property' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoProperty', @level2type=N'COLUMN',@level2name=N'StartDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the person stopped occuppying the property' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoProperty', @level2type=N'COLUMN',@level2name=N'EndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary family id mainly from legacy system' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoProperty', @level2type=N'COLUMN',@level2name=N'FamilyID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for person and property - indicating when a person occuppied a property' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersontoProperty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the status was effective' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersonToStatus', @level2type=N'COLUMN',@level2name=N'StatusDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for person and status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersonToStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the person entered the country' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersonToTravelCountry', @level2type=N'COLUMN',@level2name=N'StartDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the person left the country' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersonToTravelCountry', @level2type=N'COLUMN',@level2name=N'EndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for person and country traveled too' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PersonToTravelCountry'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'code for the country' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PhoneNumber', @level2type=N'COLUMN',@level2name=N'CountryCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'telephone number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PhoneNumber', @level2type=N'COLUMN',@level2name=N'PhoneNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of phone number objects' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PhoneNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier for the property object' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Property', @level2type=N'COLUMN',@level2name=N'PropertyID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of properties and basic attributes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Property'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier for property test results' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertySampleResults', @level2type=N'COLUMN',@level2name=N'PropertySampleResultsID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'is this a baseline test result for the property' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertySampleResults', @level2type=N'COLUMN',@level2name=N'isBaseline'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the property to which the test results apply' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertySampleResults', @level2type=N'COLUMN',@level2name=N'PropertyID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date the proeprty test samples were submitted to the lab' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertySampleResults', @level2type=N'COLUMN',@level2name=N'LabSubmissionDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the lab to which the property samples were submitted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertySampleResults', @level2type=N'COLUMN',@level2name=N'LabID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the sample type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertySampleResults', @level2type=N'COLUMN',@level2name=N'SampleTypeID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'notes about the property tests' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertySampleResults', @level2type=N'COLUMN',@level2name=N'Notes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of property test results' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertySampleResults'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date of the cleanup status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertytoCleanupStatus', @level2type=N'COLUMN',@level2name=N'CleanupStatusDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'cost of the cleanup' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertytoCleanupStatus', @level2type=N'COLUMN',@level2name=N'CostofCleanup'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for property and cleanup status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertytoCleanupStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for property and household sources of lead' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertytoHouseholdSourcesofLead'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 - yes; 1 - no.  Has the medium been tested.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertytoMedium', @level2type=N'COLUMN',@level2name=N'MediumTested'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'linking table for property and media' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PropertytoMedium'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier for the questionnaire object' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'QuestionnaireID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the patient the questionnaire is referring to' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'PersonID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'id of the person completing the questionnaire' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'Source'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 = no; 1 = yes.  has the patient visited remodeled properties' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'VisitRemodeledProperty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Age of the remodeled property in years' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'RemodeledPropertyAge'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'has the patient been exposed to peeling paint' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'isExposedtoPeelingPaint'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 = no; 1 = yes.  Is the patient taking vitamins regularly' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'isTakingVitamins'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'is the patient nursing' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'isNursing'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'is the patient using a pacifier' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'isUsingPacifier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'is the patient using a bottle' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'isUsingBottle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'does the patient bite nails' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'BitesNails'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'does the patient consume non food products' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'NonFoodEating'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'does the patient put non food items in mouth?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'NonFoodinMouth'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'does the patient eat outside?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'EatOutside'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'does the patient suckle' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'Suckling'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'does the patient frequently wash hands througout the day' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'FrequentHandWashing'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 = no; 1 = yes; does the patient attend daycare on a regular basis' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire', @level2type=N'COLUMN',@level2name=N'Daycare'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of questionnaire questions and answers, typically only completed by flagged patients' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Questionnaire'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier for the RelationshipType object' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelationshipType', @level2type=N'COLUMN',@level2name=N'RelationshipTypeID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of RelationshipType names and basic attributes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelationshipType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of remediation data' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Remediation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Meeting date between homeowner and workgroup to review the sampling plan' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RemediationActionPlan', @level2type=N'COLUMN',@level2name=N'HomeOwnerConsultationDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of sampling plans' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RemediationActionPlan'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier for sample level categorization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SampleLevelCategory', @level2type=N'COLUMN',@level2name=N'SampleLevelCategoryID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'description of sample level category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SampleLevelCategory', @level2type=N'COLUMN',@level2name=N'SampleLevelCategoryName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of sample level categorizations' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SampleLevelCategory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier of sample type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SampleType', @level2type=N'COLUMN',@level2name=N'SampleTypeID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'friendly name for the sample type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SampleType', @level2type=N'COLUMN',@level2name=N'SampleTypeName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'extended description of the sample type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SampleType', @level2type=N'COLUMN',@level2name=N'SampleTypeDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of sample types' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SampleType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'unique identifier of status objects' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Status', @level2type=N'COLUMN',@level2name=N'StatusID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'friendly name/description of status object' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Status', @level2type=N'COLUMN',@level2name=N'StatusName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'collection of status objects' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Status'
GO
USE [master]
GO
ALTER DATABASE [LCCHPTest] SET  READ_WRITE 
GO
