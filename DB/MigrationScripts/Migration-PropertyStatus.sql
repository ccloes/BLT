USE LCCHPTEST
GO

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [ActionStatusCode]
      ,[ActionStatus]
  FROM [TESTAccessImport].[dbo].[lkActionStatus]


insert into [Status] (StatusName,StatusDescription)
select ActionStatus,ActionStatusCode from TestAccessImport..lkActionStatus

select * from [status]