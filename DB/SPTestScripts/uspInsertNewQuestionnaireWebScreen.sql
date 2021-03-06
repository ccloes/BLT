USE [LCCHPDev]
GO

DECLARE	@return_value int,
		@QuestionnaireID int

EXEC	@return_value = [dbo].[usp_InsertNewQuestionnaireWebScreen]
		@Person_ID = 2690,
		@QuestionnaireDate = '20141222',
		@PaintPeeling = 1,
		@PaintDate = NULL,
		@VisitRemodel = 1,
		@RemodelDate = NULL,
		@Vitamins = 0,
		@Nursing = 1,
		@Pacifier = 0,
		@Bottle = 1,
		@BitesNails = 1,
		@EatsNonFood = 0,
		@NonFoodinMouth = 1,
		@EatsOutdoors = 1,
		@SucksThumb = 1,
		@HandWash = 1,
		@Daycare = 0,
		@QuestionnaireNotes = NULL,
		@Questionnaire_return_value = @QuestionnaireID OUTPUT

SELECT	@QuestionnaireID as N'@QuestionnaireID'

SELECT	'Return Value' = @return_value

GO

select * from Questionnaire order by QuestionnaireID desc