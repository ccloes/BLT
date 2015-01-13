USE LCCHPTest
GO

/****** Script for SelectTopNRows command from SSMS  ******/

SELECT TOP 1000 [UnitsCode]
      ,[Units]
  FROM [TESTAccessImport].[dbo].[lkUnits]

  insert into Units (Units, UnitsDescription)
    select Units,UnitsCode from TESTAccessImport..lkUnits


	insert into Units (Units) VALUES('mg/kg')
	insert into Units (Units) VALUES('ug/L')