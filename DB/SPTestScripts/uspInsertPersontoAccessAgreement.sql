USE [LeadTrackingTesting-Liam]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_InsertPersontoAccessAgreement]
		@PersonID = 2789,
		@AccessAgreementID = 1,
		@AccessAgreementDate = '20150101'

SELECT	'Return Value' = @return_value

GO

select P.LastName, P.FirstName, AP.AccessPurposeName, P2A.AccessAgreementDate, AA.AccessAgreementFile from Person as P 
JOIN PersontoAccessAgreement as P2A on P.PersonID = P2A.PersonID
JOIN AccessAgreement as AA on AA.AccessAgreementID = P2A.AccessAgreementID
JOIN AccessPurpose as AP on AA.AccessPurposeID = AP.AccessPurposeID