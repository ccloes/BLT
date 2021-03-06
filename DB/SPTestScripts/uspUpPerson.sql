USE [LCCHPDev]
GO

DECLARE	@return_value int
		, @PersonID int
		, @LastName varchar(50)
		, @FirstName varchar(50)
		, @MiddleName varchar(50)
		, @BirthDate date
		, @Gender CHAR(1)
		, @StatusID INT
		, @ForeignTravel BIT
		, @OutofSite BIT
		, @EatsForeignFood BIT
		, @PatientID BIT
		, @RetestDate DATE
		, @Moved BIT
		, @MovedDate DATE
		, @isClosed BIT
		, @isResolved BIT
		, @Notes NVARCHAR(3000)
		, @GuardianID INT
		, @isSmoker BIT

SET @PersonID = 4242
SET @LastName = 'Mchenry'
SET @FirstName = 'Jonathan'
SET @MiddleName = 'F.'
SET @BirthDate = '20141201'
SET @Gender = 'M'
SET @StatusID = NULL
SET @ForeignTravel = NULL
SET @OutofSite = 0
SET @EatsForeignFood = NULL
SET @PatientID = NULL
SET @RetestDate = NULL
SET @Moved = 0
SET @MovedDate = NULL
SET @isClosed = 0
SET @isResolved = 0
SET @Notes = N'updated name spelling and corrected birthdate'
SET @GuardianID = NULL
SET @isSmoker = 0

EXEC	@return_value = [dbo].[usp_upPerson]
		@Person_ID = @PersonID,
		@New_FirstName = @FirstName,
		@New_MiddleName = @MiddleName,
		@New_LastName = @LastName,
		@New_BirthDate = @BirthDate,
		@New_Gender = @Gender,
		@New_StatusID = @StatusID,
		@New_ForeignTravel = @ForeignTravel,
		@New_OutofSite = @OutofSite,
		@New_EatsForeignFood = @EatsForeignFood,
		@New_PatientID = @PatientID,
		@New_RetestDate = @RetestDate,
		@New_Moved = @Moved,
		@New_MovedDate = @MovedDate,
		@New_isClosed = @isClosed,
		@New_isResolved = @isResolved,
		@New_Notes = @Notes,
		@New_GuardianID = @GuardianID,
		@New_isSmoker = @isSmoker,
		@DEBUG = 1

SELECT	'Return Value' = @return_value
/*

update Person set Lastname = @LastName, FirstName = @Firstname, MiddleName = @MiddleName
		, BirthDate = @BirthDate, Gender = @Gender, OutofSite = @OutofSite, Moved = @Moved
		, isClosed = @isClosed, isResolved = @isResolved, isSmoker = @isSmoker
		where PersonID = @PersonID
		*/
		Select * from Person where PersonID = @PersonID
		SELECT * from personNotes order by PersonNotesID desc
		select * from ErrorLog order by ErrorID desc
