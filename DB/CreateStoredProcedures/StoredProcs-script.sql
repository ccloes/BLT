USE [LeadTrackingTesting-Liam]
GO
/****** Object:  StoredProcedure [dbo].[usp_InsertAccessAgreement]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into AccessAgreement (AccessPurposeID, Notes, AccessAgreementFile, PropertyID) 
					 Values ( @AccessPurposeID, @Notes, @AccessAgreementFile, @PropertyID);
		SELECT @InsertedAccessAgreementID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertAccessPurpose]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@AccessPurposeName varchar(100) = NULL,
	@AccessPurposeDescription varchar(250) = NULL,
	@AccessPurposeID int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into AccessPurpose ( AccessPurposeName, AccessPurposeDescription)
					 Values ( @AccessPurposeName, @AccessPurposeDescription);
		SELECT @AccessPurposeID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertArea]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@AreaName varchar(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Area ( AreaDescription, AreaName)
					 Values ( @AreaDescription, @AreaName);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertBloodTestResults]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertCleanupStatus]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@CleanupStatusName varchar(25) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into CleanupStatus ( CleanupStatusDescription, CleanupStatusName)
					 Values ( @CleanupStatusDescription, @CleanupStatusName);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertConstructionType]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@ConstructionTypeName varchar(50) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into ConstructionType ( ConstructionTypeDescription, ConstructionTypeName)
					 Values ( @ConstructionTypeDescription, @ConstructionTypeName);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertContractor]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@ContractorName varchar(50) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Contractor ( ContractorDescription, ContractorName)
					 Values ( @ContractorDescription, @ContractorName);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertContractortoProperty]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into ContractortoProperty ( ContractorID, PropertyID, StartDate, EndDate)
					 Values ( @ContractorID, @PropertyID, @StartDate, @EndDate);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertContractortoRemediation]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into ContractortoRemediation ( ContractorID, RemediationID, StartDate, EndDate, isSubContractor)
					 Values ( @ContractorID, @RemediationID, @StartDate, @EndDate, @isSubContractor);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertContractortoRemediationPlan]    Script Date: 12/20/2014 11:59:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new ContractortoRemediationPlan records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertContractortoRemediationPlan]   -- usp_InsertContractortoRemediationPlan 
	-- Add the parameters for the stored procedure here
	@ContractorID int = NULL,
	@RemediationPlanID int = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL,
	@isSubContractor bit = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into ContractortoRemediationPlan ( ContractorID, RemediationPlanID, StartDate, EndDate, isSubContractor)
					 Values ( @ContractorID, @RemediationPlanID, @StartDate, @EndDate, @isSubContractor);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertCountry]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@CountryName varchar(50) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Country ( CountryName)
					 Values ( @CountryName);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertDaycare]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Daycare ( DaycareName, DaycareDescription )
					 Values ( @DaycareName, @DaycareDescription );
		SELECT @newDayCareID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertDaycarePrimaryContact]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into DaycarePrimaryContact ( DayCareID, PersonID, ContactPriority, PrimaryPhoneNumberID )
					 Values ( @DayCareID, @PersonID, @ContactPriority, @PrimaryPhoneNumberID );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertDaycaretoProperty]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into DaycaretoProperty ( DaycareID, PropertyID, StartDate, EndDate)
					 Values ( @DaycareID, @PropertyID, @StartDate, @EndDate);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertEmployer]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	--@EmployerID int = NULL,
	@EmployerName int = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Employer ( EmployerName )
					 Values ( @EmployerName );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertEmployertoProperty]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into EmployertoProperty ( EmployerID, PropertyID, StartDate, EndDate)
					 Values ( @EmployerID, @PropertyID, @StartDate, @EndDate);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertEnvironmentalInvestigation]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@EnvironmentalInvestigationID int = NULL,
	@ConductEnvironmentalInvestigation bit = NULL,
	@ConductEnvironmentalInvestigationDecisionDate date = NULL,
	@Cost money = NULL,
	@EnvironmentalInvestigationDate date = NULL,
	@SamplingPlanID int = NULL,
	@PropertyID int = NULL,
	@RemediationID int = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into EnvironmentalInvestigation ( ConductEnvironmentalInvestigation, ConductEnvironmentalInvestigationDecisionDate,
		                                          Cost, EnvironmentalInvestigationDate, SamplingPlanID, PropertyID,
												  RemeditationID, StartDate, EndDate )
					 Values ( @ConductEnvironmentalInvestigation, @ConductEnvironmentalInvestigationDecisionDate,
		                      @Cost, @EnvironmentalInvestigationDate, @SamplingPlanID, @PropertyID,
							  @RemediationID, @StartDate, @EndDate  );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertEthnicity]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@Ethnicity varchar(50) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Ethnicity ( Ethnicity )
					 Values ( @Ethnicity );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertFamily]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	DECLARE @DBNAME NVARCHAR(128);
	SET @DBNAME = DB_NAME();

	BEGIN TRY
	 --    if Exists (select LastName from Family where LastName = @LastName) 
		-- BEGIN
		-- RAISERROR
		--	(N'The Family name: %s already exists.',
		--	11, -- Severity.
		--	-1, -- State.
		--	@LastName)
		--	select Family.LastName,Family.FamilyID,Person.FirstName from Family 
		--	Left outer join PersonToFamily on PersonToFamily.FamilyID = Family.FamilyID
		--	left outer join Person on Person.PersonId = PersonToFamily.PersonId
		--	where Family.LastName = @LastName;
		--return
		-- END
	
		INSERT into Family ( LastName,  NumberofSmokers,  PrimaryLanguageID,  Notes, Pets, inandout
		            , PrimaryPropertyID) 
		            Values (@LastName, @NumberofSmokers, @PrimaryLanguageID, @Notes, @Pets, @inandout
					, @PrimaryPropertyID)
		SET @FID = SCOPE_IDENTITY();  -- uncomment to return primary key of inserted values
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END





GO
/****** Object:  StoredProcedure [dbo].[usp_InsertForeignFood]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@ForeignFoodDescription varchar(256) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into ForeignFood ( ForeignFoodName, ForeignFoodDescription )
					 Values ( @ForeignFoodName, @ForeignFoodDescription );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertForeignFoodtoCountry]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into ForeignFoodtoCountry ( ForeignFoodID, CountryID ) --, StartDate, EndDate)
					 Values ( @ForeignFoodID, @CountryID ) -- , @StartDate, @EndDate);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertGiftCard]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@IssueDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into GiftCard ( GiftCardValue, IssueDate )
					 Values ( @GiftCardValue, @IssueDate );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertHobby]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@HobbyDescription varchar(256) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Hobby ( HobbyName, HobbyDescription )
					 Values ( @HobbyName, @HobbyDescription );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertHomeRemedies]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@HomeRemedyDescription varchar(256) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into HomeRemedies ( HomeRemedyName, HomeRemedyDescription )
					 Values ( @HomeRemedyName, @HomeRemedyDescription );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertHouseholdSourcesofLead]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@HouseholdItemDescription varchar(512) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into HouseholdSourcesofLead ( HouseholdItemName, HouseholdItemDescription )
					 Values ( @HouseholdItemName, @HouseholdItemDescription );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertInsuranceProvider]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@InsuranceProviderName varchar(50) = NULL
--	@HouseholdItemDescription varchar(512) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into InsuranceProvider ( InsuranceProviderName ) --, HouseholdItemDescription )
					 Values ( @InsuranceProviderName ) -- , @HouseholdItemDescription );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertLab]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@Notes varchar(3000) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Lab ( LabName, LabDescription, Notes )
					 Values ( @LabName, @LabDescription, @Notes );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertLabtoProperty]    Script Date: 12/20/2014 11:59:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new LabtoProperty records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertLabtoProperty]   -- usp_InsertLabtoProperty
	-- Add the parameters for the stored procedure here
	@LabID int = NULL,
	@PropertyID int = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into LabtoProperty( LabID, PropertyID, StartDate, EndDate)
					 Values ( @LabID, @PropertyID, @StartDate, @EndDate);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertLanguage]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	DECLARE @DBNAME NVARCHAR(128);
	SET @DBNAME = DB_NAME();

	BEGIN TRY
	     if Exists (select LanguageName from language where LanguageName = @LanguageName) 
		 BEGIN
		 RAISERROR
			(N'The language: %s already exists.',
			16, -- Severity.
			1, -- State.
			@LanguageName);
		 END
	
		INSERT into Language (LanguageName) Values (@LanguageName)
		SET @LANGUAGEID = SCOPE_IDENTITY();
	--	SELECT SCOPE_IDENTITY();  -- uncomment to return primary key of inserted values
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END





GO
/****** Object:  StoredProcedure [dbo].[usp_InsertMedium]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@TriggerLevelUnits varchar(20) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Medium ( MediumName, MediumDescription, TriggerLevel, TriggerLevelUnits )
					 Values ( @MediumName, @MediumDescription, @TriggerLevel, @TriggerLevelUnits );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertMediumSampleResults]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@SampleLevelCategoryID tinyint = NULL,
	@MediumSampleDate date = getdate,
	@LabID int = NULL,
	@LabSubmissionDate date = getdate,
	@Notes varchar(3000) = NULL,
	@IsAboveTriggerLevel bit = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into MediumSampleResults ( MediumID, MediumSampleValue, SampleLevelCategoryID, MediumSampleDate, LabID,
		                                   LabSubmissionDate, Notes, IsAboveTriggerLevel )
					 Values ( @MediumID, @MediumSampleValue, @SampleLevelCategoryID, @MediumSampleDate, @LabID,
		                      @LabSubmissionDate, @Notes, @IsAboveTriggerLevel );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertNewBloodLeadTestResultsWebScreen]    Script Date: 12/20/2014 11:59:33 AM ******/
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

	DECLARE @BloodTestResult_return_value int;

	-- set default date if necessary 
	IF (@Sample_Date is null) 
	BEGIN
		print 'Need to specify the SampleDate, setting to today by default';
		set @Sample_Date = GetDate();
	END
	
	IF (@Person_ID IS NULL)
	BEGIN
		RAISERROR ('Client name must be supplied', 11, -1);
		RETURN;
	END;

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

			

		select 'Inserted ' + cast(@Blood_Test_Results_ID as varchar) + ' Blood test results to BlootTestResults Table'
END

GO
/****** Object:  StoredProcedure [dbo].[usp_InsertNewClientWebScreen]    Script Date: 12/20/2014 11:59:33 AM ******/
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

	IF ((select FamilyID from family where FamilyID = @Family_ID) is NULL)
	BEGIN
		RAISERROR ('Unable to associate non existent family. Family does not exist.', 11, -1);
		RETURN;
	END

	IF (@Family_ID IS NULL)
	BEGIN
		RAISERROR ('Family name must be supplied', 11, -1);
		RETURN;
	END;

	if (@Last_Name is null)
	BEGIN
		select @Last_Name = Lastname from Family where FamilyID = @Family_ID
	END

	BEGIN
		DECLARE @PersontoFamily_return_value int,
				@PersontoLanguage_return_value int,
				@PersontoHobby_return_value int,
				@PersontoOccupation_return_value int,
				@PersontoEthnicity_return_value int;

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

		-- SET @ClientID = @Person_return_value;
		select 'Inserted ' + cast(@ClientID as varchar) + ' personID to personTable'
		-- Associate New person with a family
		if (@Family_ID is not NULL)
		EXEC	@PersontoFamily_return_value = usp_InsertPersontoFamily
				@PersonID = @ClientID, @FamilyID = @Family_ID;
				
		if (@Language_ID is not NULL)
		EXEC 	@PersontoLanguage_return_value = usp_InsertPersontoLanguage
				@LanguageID = @Language_ID, @PersonID = @ClientID, @isPrimaryLanguage = 1;

		if (@Hobby_ID is not NULL)
		EXEC	@PersontoHobby_return_value = usp_InsertPersontoHobby
				@HobbyID = @Hobby_ID, @PersonID = @ClientID;

		if (@Occupation_ID is not NULL)
		EXEC	@PersontoOccupation_return_value = [dbo].[usp_InsertPersontoOccupation]
				@PersonID = @ClientID,
				@OccupationID = @Occupation_ID
	END

	if ((@Family_ID is not NULL AND @PersontoFamily_return_value <> 0) or (@Hobby_ID is not NULL AND @PersontoHobby_return_value <> 0) or
		(@Language_ID is not NULL AND @PersontoLanguage_return_value <> 0) or (@Occupation_ID is not NULL and @PersontoOccupation_return_value <> 0))
	BEGIN
		PRINT 'ERROR associating person to either family, hobby, language, or occupation';
	END
END

GO
/****** Object:  StoredProcedure [dbo].[usp_InsertNewFamilyWebScreen]    Script Date: 12/20/2014 11:59:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Liam Thier
-- Create date: 20141115
-- Description:	stored procedure to insert data from the Add a new family web page
-- =============================================
CREATE PROCEDURE [dbo].[usp_InsertNewFamilyWebScreen]
	-- Add the parameters for the stored procedure here
	@FamilyLastName varchar(50) = NULL, 
	@StreetNum varchar(15) = NULL,
	@StreetName varchar(50) = NULL,
	@StreetSuff varchar(20) = NULL,
	@ApartmentNum varchar(10) = NULL,
	@CityName varchar(50) = 'Leadville',
	@StateAbbr varchar(2) = 'CO',
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
		DECLARE @Family_return_value int,
				@PropID int, @LID tinyint,
				@Homephone_return_value int,
				@Workphone_return_value int;

		-- Insert the property address if it doesn't already exist
		-- NEED TO RETRIEVE PROPERTY ID IF IT ALREADY EXISTS
		SELECT @PropID = PropertyID from Property where StreetNumber = @StreetNum and Street = @StreetName 
												and StreetSuffix = @StreetSuff and City = @CityName
												and [State] = @StateAbbr and Zipcode = @ZipCode
		if ( @PropID is NULL)
			BEGIN
				EXEC	[dbo].[usp_InsertProperty]
						@StreetNumber = @StreetNum,
						@Street = @StreetName,
						@StreetSuffix = @StreetSuff,
						@City = @CityName,
						@State = @StateAbbr,
						@Zipcode = @ZipCode,
						@PropertyID = @PropID OUTPUT;
			END

		-- Insert the property address if it doesn't already exist
		-- NEED TO RETRIEVE PROPERTY ID IF IT ALREADY EXISTS
		--SELECT @LID = LanguageID from [Language] where LanguageID = @Language
		--if ( @LID is NULL)
		--	BEGIN
		--		EXEC	[dbo].[usp_InsertLanguage]
		--				@LanguageName = @Language,
		--				@LanguageID = @LID OUTPUT;
		--	END


		EXEC	[dbo].[usp_InsertFamily]
				@LastName = @FamilyLastName,
				@NumberofSmokers = @NumSmokers,
				@PrimaryLanguageID = @Language,
				@Pets = @Pets,
				@inandout = @inandout,
				@PrimaryPropertyID = @PropID,
				@FID = @FamilyID OUTPUT;

		
		if (@HomePhone is not NULL) 
		BEGIN
			EXEC	@Homephone_return_value = [dbo].[usp_InsertPhoneNumber]
					@PhoneNumber = @HomePhone
		END

		if (@WorkPhone is not NULL) 
		BEGIN
			EXEC	@Workphone_return_value = [dbo].[usp_InsertPhoneNumber]
					@PhoneNumber = @WorkPhone
		END
	END
END

GO
/****** Object:  StoredProcedure [dbo].[usp_InsertNewQuestionnaireWebScreen]    Script Date: 12/20/2014 11:59:33 AM ******/
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

	-- set default date if necessary 
	IF (@QuestionnaireDate is null) 
	BEGIN
		print 'Need to specify QuestionnaireDate, setting to today by defualt';
		set @QuestionnaireDate = GetDate();
	END
	select 'Questionnaire date:  ' + convert(varchar,@QuestionnaireDate,101)
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


/*
		-- Associate New person with a family
		if (@Family_ID is not NULL)
		EXEC	@PersontoFamily_return_value = usp_InsertPersontoFamily
				@PersonID = @Person_return_value, @FamilyID = @Family_ID;

		if (@Language_ID is not NULL)
		EXEC 	@PersontoLanguage_return_value = usp_InsertPersontoLanguage
				@LanguageID = @Language_ID, @PersonID = @Person_return_value, @isPrimaryLanguage = 1;

		if (@Hobby_ID is not NULL)
		EXEC	@PersontoHobby_return_value = usp_InsertPersontoHobby
				@HobbyID = @Hobby_ID, @PersonID = @Person_return_value;
	END

	*/
END


GO
/****** Object:  StoredProcedure [dbo].[usp_InsertOccupation]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@OccupationDescription varchar(256) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Occupation ( OccupationName, OccupationDescription )
					 Values ( @OccupationName, @OccupationDescription );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPerson]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END






GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoAccessAgreement]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoAccessAgreement( PersonID, AccessAgreementID, AccessAgreementDate) --, EndDate)
					 Values ( @PersonID, @AccessAgreementID, @AccessAgreementDate ) -- , @EndDate);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoDaycare]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoDaycare( PersonID, DaycareID, StartDate, EndDate)
					 Values ( @PersonID, @DaycareID, @StartDate, @EndDate);
		--SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoEmployer]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoEmployer( PersonID, EmployerID, StartDate, EndDate)
					 Values ( @PersonID, @EmployerID, @StartDate, @EndDate);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoEthnicity]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoEthnicity( PersonID, EthnicityID ) --, StartDate, EndDate)
					 Values ( @PersonID, @EthnicityID ) -- , @StartDate, @EndDate);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoFamily]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@FamilyID int = NULL
	--@StartDate date = NULL,
	--@EndDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoFamily( PersonID, FamilyID ) --, StartDate, EndDate)
					 Values ( @PersonID, @FamilyID ) -- , @StartDate, @EndDate);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoForeignFood]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoForeignFood( PersonID, ForeignFoodID ) --, StartDate, EndDate)
					 Values ( @PersonID, @ForeignFoodID ) -- , @StartDate, @EndDate);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoGiftCard]    Script Date: 12/20/2014 11:59:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		William Thier
-- Create date: 20140817
-- Description:	Stored Procedure to insert new PersontoGiftCard records
-- =============================================

CREATE PROCEDURE [dbo].[usp_InsertPersontoGiftCard]   -- usp_InsertPersontoGiftCard
	-- Add the parameters for the stored procedure here
	@PersonID int = NULL,
	@GiftCardID int = NULL
	--@StartDate date = NULL,
	--@EndDate date = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoGiftCard( PersonID, GiftCardID ) --, StartDate, EndDate)
					 Values ( @PersonID, @GiftCardID ) -- , @StartDate, @EndDate);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoHobby]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoHobby( PersonID, HobbyID ) --, StartDate, EndDate)
					 Values ( @PersonID, @HobbyID ) -- , @StartDate, @EndDate);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoHomeRemedy]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoHomeRemedy( PersonID, HomeRemedyID ) --, StartDate, EndDate)
					 Values ( @PersonID, @HomeRemedyID ) -- , @StartDate, @EndDate);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoInsurance]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoInsurance( PersonID, InsuranceID, StartDate, EndDate, GroupID)
					 Values ( @PersonID, @InsuranceID, @StartDate, @EndDate, @GroupID);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoLanguage]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoLanguage( PersonID, LanguageID, isPrimaryLanguage ) -- StartDate, EndDate, GroupID)
					 Values ( @PersonID, @LanguageID, @isPrimaryLanguage ) -- @StartDate, @EndDate, @GroupID);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoOccupation]    Script Date: 12/20/2014 11:59:33 AM ******/
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

	DECLARE @return_value int;

	-- at the very least assume the start date is today
	IF (@StartDate is NULL) SELECT @StartDate = GETDATE();

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoOccupation( PersonID, OccupationID, StartDate, EndDate)
					 Values ( @PersonID, @OccupationID, @StartDate, @EndDate);
		SELECT @return_value = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoPhoneNumber]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoPhoneNumber( PersonID, PhoneNumberID, NumberPriority)
					 Values ( @PersonID, @PhoneNumberID, @NumberPriority )
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoProperty]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@isPrimaryResidence bit = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoProperty( PersonID, PropertyID, StartDate, EndDate, isPrimaryResidence)
					 Values ( @PersonID, @PropertyID, @StartDate, @EndDate, @isPrimaryResidence )
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoStatus]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoStatus( PersonID, StatusID, StatusDate ) -- , EndDate, isPrimaryResidence)
					 Values ( @PersonID, @StatusID, @StatusDate ) --, @EndDate, @isPrimaryResidence )
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPersontoTravelCountry]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PersontoTravelCountry( PersonID, CountryID, StartDate, EndDate )
					 Values ( @PersonID, @TravelCountryID, @StartDate, @EndDate )
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPhoneNumber]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@PhoneNumber bigint = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PhoneNumber ( CountryCode, PhoneNumber )
					 Values ( @CountryCode, @PhoneNumber );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertProperty]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@State varchar(20) = NULL,
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into property (ConstructionTypeID, AreaID, isinHistoricDistrict, isRemodeled, RemodelDate, 
							  isinCityLimits, StreetNumber, Street, StreetSuffix, ApartmentNumber, City, State, Zipcode,
							  YearBuilt, OwnerID, isOwnerOccuppied, ReplacedPipesFaucets, TotalRemediationCosts, Notes,
							  isResidential, isCurrentlyBeingRemodeled, hasPeelingChippingPaint, County, isRental) 
					 Values ( @ConstructionTypeID, @AreaID, @isinHistoricDistrict, @isRemodeled, @RemodelDate, 
							  @isinCityLimits, @StreetNumber,  @Street, @StreetSuffix, @ApartmentNumber, @City, @State, @Zipcode,
							  @YearBuilt, @OwnerID, @isOwnerOccuppied, @ReplacedPipesFaucets, @TotalRemediationCosts, @Notes,
							  @isResidential, @isCurrentlyBeingRemodeled, @hasPeelingChippingPaint, @County, @isRental);
		SET @PropertyID = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPropertySampleResults]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@Notes varchar(3000) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PropertySampleResults ( isBaseline, PropertyID, LabSubmissionDate, LabID,
		                                   SampleTypeID, Notes )
					 Values ( @isBaseline, @PropertyID, @LabSubmissionDate, @LabID,
		                                   @SampleTypeID, @Notes );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPropertytoCleanupStatus]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PropertytoCleanupStatus( PropertyID, CleanupStatusID, CleanupStatusDate, CostofCleanup )
					 Values ( @PropertyID, @CleanupStatusID, @CleanupStatusDate, @CostofCleanup )
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPropertytoHouseholdSourcesofLead]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PropertytoHouseholdSourcesofLead( PropertyID, HouseholdSourcesofLeadID )
					 Values ( @PropertyID, @HouseholdSourcesofLeadID )
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertPropertytoMedium]    Script Date: 12/20/2014 11:59:33 AM ******/
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

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into PropertytoMedium( PropertyID, MediumID, MediumTested )
					 Values ( @PropertyID, @MediumID, @MediumTested )
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertQuestionnaire]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertRemediation]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@EnvironmentalInvestigationID int = NULL,
	@RemediationApprovalDate date = getdate,
	@RemediationStartDate date = NULL,
	@RemediationEndDate date = NULL,
	@PropertyID int = NULL,
	@AccessAgreementID int = NULL,
	@FinalRemediationReportFile varbinary(max) = NULL,
	@FinalRemediationReportDate date = Null,
	@RemediationCost money = NULL,
	@OneYearRemediationCompleteDate date = NULL,
	@Notes varchar(3000) = NULL,
	@OneYearRemediatioNComplete bit = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Remediation ( EnvironmentalInvestigationID, RemediationApprovalDate, RemediationStartDate,
		                           RemediationEndDate, PropertyID, AccessAgreementID, FinalRemediationReportFile,
								   FinalRemediationReportDate, RemediationCost, OneYearRemediationCompleteDate,
								   Notes, OneYearRemediationComplete )
					 Values ( @EnvironmentalInvestigationID, @RemediationApprovalDate, @RemediationStartDate,
		                      @RemediationEndDate, @PropertyID, @AccessAgreementID, @FinalRemediationReportFile,
							  @FinalRemediationReportDate, @RemediationCost, @OneYearRemediationCompleteDate,
							  @Notes, @OneYearRemediationComplete);
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertRemediationActionPlan]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@RemediationActionPlanFinalReportSubmissionDate date = NULL,
	@RemediationActionPlanFile varbinary(max) = NULL,
	@PropertyID int = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into RemediationActionPlan ( RemediationActionPlanApprovalDate, HomeOwnerConsultationDate,
		                                     ContractorCompletedInvestigationDate, RemediationActionPlanFinalReportSubmissionDate,
											 RemediationActionPlanFile, PropertyID )
					 Values ( @RemediationActionPlanApprovalDate, @HomeOwnerConsultationDate,
		                      @ContractorCompletedInvestigationDate, @RemediationActionPlanFinalReportSubmissionDate,
							  @RemediationActionPlanFile, @PropertyID );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertSampleLevelCategory]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@SampleLevelCategoryDescription varchar(256) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into SampleLevelCategory ( SampleLevelCategoryName, SampleLevelCategoryDescription )
					 Values ( @SampleLevelCategoryName, @SampleLevelCategoryDescription );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertSampleType]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@SampleTypeDescription varchar(256) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into SampleType ( SampleTypeName, SampleTypeDescription )
					 Values ( @SampleTypeName, @SampleTypeDescription );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_InsertStatus]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@StatusDescription varchar(256) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		 INSERT into Status ( StatusName, StatusDescription )
					 Values ( @StatusName, @StatusDescription );
		SELECT SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	    SELECT ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END







GO
/****** Object:  StoredProcedure [dbo].[usp_SLBloodTestResults]    Script Date: 12/20/2014 11:59:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		William Thier
-- Create date: 20130509
-- Description:	
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
			@Recompile BIT = 1

    -- Insert statements for procedure here
	SELECT @spexecutesqlStr = N'SELECT ''ClientID'' = [P].[personid], ''LastName'' = [P].[LastName], ''BirthDate'' = [P].[BirthDate]
								, ''TestDate'' = [BTR].[SampleDate], ''Hb g/dl'' = [BTR].[HemoglobinValue], ''Retest BL'' = DATEADD(yy,1,sampledate)
								, ''Retest HB'' = DATEADD(yy,1,sampledate), ''Close'' = [P].[isClosed], ''Moved'' = [P].[Moved]
								, ''Movedate'' = [P].[MovedDate]
							from [Person] [P]
							join [BloodTestResults] [BTR] on [P].[PersonID] = [BTR].[PersonID]
							WHERE 1 = 1'

	if @ClientID IS NOT NULL
		SELECT @spexecutesqlStr = @spexecutesqlStr + N' AND [p].[PersonID] = @PersonID'

	IF @ClientID is NULL
		SET @Recompile = 0;

	IF @Recompile = 1
		SELECT @spexecutesqlStr = @spexecutesqlStr + N' OPTION(RECOMPILE)';

	-- SELECT @spexecutesqlStr;

	EXEC [sp_executesql] @spexecutesqlStr
    , N'@PersonID int'
	, @PersonID = @ClientID;
	
END




GO
/****** Object:  StoredProcedure [dbo].[usp_SlColumnDetails]    Script Date: 12/20/2014 11:59:33 AM ******/
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
/****** Object:  StoredProcedure [dbo].[usp_SlCountFamilyMembers]    Script Date: 12/20/2014 11:59:33 AM ******/
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

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @spexecuteSQLStr NVARCHAR(4000)
			, @Recompile  BIT = 1;
	
	IF (@FamilyID IS NULL)
	BEGIN
		RAISERROR ('You must supply at least one parameter.', 11, -1);
		RETURN;
	END;
	SELECT @spexecuteSQLStr =
		N'SELECT family = f.lastname, f.familyid, members = count(p.firstname) from person as p';

	SELECT @spexecuteSQLStr = @spexecuteSQLStr 
		+ N' join persontoFamily p2f on p2f.personid = p.personid join family f on f.familyid = p2f.familyid';

	SELECT @spexecuteSQLStr = @spexecuteSQLStr
		+ N' where 1=1';

	IF (@FamilyID IS NOT NULL) 
		SELECT @spexecuteSQLStr = @spexecuteSQLStr
			+ N' AND f.familyID = @Family_ID';

	SELECT @spexecuteSQLStr = @spexecuteSQLStr
		+ N' group by f.familyid,f.lastname';

	IF (@FamilyID IS NULL) SET @Recompile = 0;
	
	IF @Recompile = 1
		SELECT @spexecuteSQLStr = @spexecuteSQLStr + N' OPTION(RECOMPILE)';
    
	SELECT @spexecuteSQLStr, @FamilyID;
	
	EXEC [sp_executesql] @spexecuteSQLStr
		, N'@Family_ID int'
		, @Family_ID = @FamilyID;

GO
/****** Object:  StoredProcedure [dbo].[usp_SlCountParticipants]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select Participants = count(PersonId) from person
END



GO
/****** Object:  StoredProcedure [dbo].[usp_SlFamilyNametoProperty]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@FamilyName varchar(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@FamilyName IS NULL)
	BEGIN
		RAISERROR ('You must supply a family name.', 11, -1);
		RETURN;
	END;
    -- Insert statements for procedure here
	select FamilyName = F.LastName,Prop.StreetNumber,Prop.Street,Prop.StreetSuffix
	from family F
	join Property as Prop on F.PrimaryPropertyID = Prop.PropertyID
	where F.Lastname = @FamilyName
END


GO
/****** Object:  StoredProcedure [dbo].[usp_SLInsertedData]    Script Date: 12/20/2014 11:59:33 AM ******/
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
	@LastName varchar(50) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @spexecutesqlStr	NVARCHAR(4000),
			@Recompile BIT = 1

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
	if @Lastname IS NOT NULL
		SELECT @spexecutesqlStr = @spexecutesqlStr + N' AND [p].[LastName] = @LastName ORDER BY [P].[PersonID] desc'

	IF @Lastname is NULL
		SET @Recompile = 0;

	IF @Recompile = 1
		SELECT @spexecutesqlStr = @spexecutesqlStr + N' OPTION(RECOMPILE)';

	-- SELECT @spexecutesqlStr;

	EXEC [sp_executesql] @spexecutesqlStr
    , N'@Lastname varchar(50)'
	, @LastName = @Lastname;  
	
END




GO
/****** Object:  StoredProcedure [dbo].[usp_SlPeopleByLastName]    Script Date: 12/20/2014 11:59:33 AM ******/
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
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
select lastname,count(firstname) from person group by lastname

END



GO
