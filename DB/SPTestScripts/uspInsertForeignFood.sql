USE [LeadTrackingTesting-Liam]
GO

DECLARE	@return_value int,
		@NewForeignFoodID int

EXEC	@return_value = [dbo].[usp_InsertForeignFood]
		@ForeignFoodName = N'Garritas',
		@ForeignFoodDescription = N'mexican crackers',
		@NewForeignFoodID = @NewForeignFoodID OUTPUT

SELECT	@NewForeignFoodID as N'@NewForeignFoodID'

SELECT	'Return Value' = @return_value

GO


select * from ForeignFood