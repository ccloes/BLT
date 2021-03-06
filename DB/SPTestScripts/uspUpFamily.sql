USE [LCCHPDev]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_upFamily]
		@Family_ID = 2667,
		@New_Last_Name = N'Bonifacio',
		@New_Number_of_Smokers = 8,
		@New_Primary_Language_ID = 1,
		@New_Notes = N'Updated their last name',
		@New_Pets = NULL,
		@New_in_and_out = NULL,
		@New_Primary_Property_ID = NULL,
		@DEBUG = 1

SELECT	'Return Value' = @return_value

GO

select * from Family where FamilyID = 2667

select * from person order by personID desc

select P.LastName,P.FirstName,BTR.* 
from BloodTestResults BTR
JOIN Person AS P on BTR.PersonID = P.PersonID
where P.PersonID = 4370