USE [LCCHPDev]
GO

DECLARE	@return_value int,
		@PID int

EXEC	@return_value = [dbo].[usp_InsertPerson]
		@FirstName = N'Diane',
		@MiddleName = NULL,
		@LastName = N'Fujikawa',
		@BirthDate = '19880606',
		@Gender = N'F',
		@StatusID = NULL,
		@ForeignTravel = NULL,
		@OutofSite = NULL,
		@EatsForeignFood = NULL,
		@PatientID = NULL,
		@RetestDate = NULL,
		@Moved = NULL,
		@MovedDate = NULL,
		@isClosed = NULL,
		@isResolved = NULL,
		@New_Notes = NULL,
		@GuardianID = NULL,
		@isSmoker = NULL,
		@PID = @PID OUTPUT

SELECT	@PID as N'@PID'

SELECT	'Return Value' = @return_value

GO
