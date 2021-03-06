USE [LeadTrackingTesting-Liam]
GO

DECLARE	@return_value int,
		@FamilyID int

EXEC	@return_value = [dbo].[usp_InsertNewFamilyWebScreen]
		@FamilyLastName = N'Carter',
		@StreetNum = N'1313',
		@StreetName = N'MT Elbert',
		@StreetSuff = N'Dr',
		@CityName = N'Leadville',
		@StateAbbr = N'CO',
		@ZipCode = N'80461',
		@Language = 4,
		@NumSmokers = 2,
		@Pets = 0,
		@inandout = NULL,
		@FamilyID = @FamilyID OUTPUT

SELECT	@FamilyID as N'@FamilyID'

SELECT	'Return Value' = @return_value

-- 
/*
select * from family
join property on primaryPropertyID = PropertyID 
join [language] on primaryLanguageID = LanguageID
where lastname = 'Carter'
*/

GO
