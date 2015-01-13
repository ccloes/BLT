USE [LeadTrackingTesting-Liam]
GO

DECLARE	@return_value int,
		@NewConstructionTypeID int

EXEC	@return_value = [dbo].[usp_InsertConstructionType]
		@ConstructionTypeName = N'Condominiums',
		@NewConstructionTypeID = @NewConstructionTypeID OUTPUT

SELECT	@NewConstructionTypeID as N'@NewConstructionTypeID'

SELECT	'Return Value' = @return_value

GO

Select * from ConstructionType