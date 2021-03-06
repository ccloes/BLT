USE [LCCHPDev]
GO

DECLARE	@Family_ID int

EXEC	[dbo].[usp_InsertFamily]
		@LastName = N'Kwon',
		@NumberofSmokers = NULL,
		@PrimaryLanguageID = 2,
		@Pets = 0,
		@inandout = 0,
		@PrimaryPropertyID = 5697,
		@Notes = NULL,
		@FID = @Family_ID OUTPUT

SELECT	@Family_ID as N'@FID'
select * from FamilyNotes 
GO

select * from FamilyNOTES 
LEFT OUTER JOIN Family on FamilyNOtes.FamilyID = Family.FamilyID
order by Family.familyID desc

-- select * from ErrorLog order by errorid desc