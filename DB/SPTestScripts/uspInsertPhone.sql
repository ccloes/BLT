USE [LeadTrackingTesting-Liam]
GO

DECLARE	@return_value int,
		@PhoneNumberID_OUTPUT int

EXEC	@return_value = [dbo].[usp_InsertPhoneNumber]
		@CountryCode = 1,
		@PhoneNumber = 8582157300,
		@PhoneNumberTypeID = 2,
		@PhoneNumberID_OUTPUT = @PhoneNumberID_OUTPUT OUTPUT

SELECT	@PhoneNumberID_OUTPUT as N'@PhoneNumberID_OUTPUT'

SELECT	'Return Value' = @return_value

GO
