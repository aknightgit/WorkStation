USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC SP_STG2ODS_DELETE_INSERTER_SP_CREATER

@tableNM nvarchar(100),
@KEYID nvarchar(100)
AS
BEGIN
SET @tableNM = REPLACE(@tableNM,']','')
SET @tableNM = REPLACE(@tableNM,'[','')
SET @tableNM = REPLACE(@tableNM,'FU_STG.','')
SET @tableNM = REPLACE(@tableNM,'T_STG_','')
select @tableNM
set @KEYID = (select top 1 name as column_name from sys.columns where object_id = object_id(N'FU_STG.T_STG_'+@tableNM+'') )

select 'create PROCEDURE  [FU_ODS].[SP_UPINSERT_T_ODS_'+@tableNM+']'
UNION ALL 
select 'as'
UNION ALL 
select 'begin'
UNION ALL 
select 'DELETE  [FU_ODS].[T_ODS_'+@tableNM+'] WHERE '+@KEYID+' IN'
UNION ALL 
select '('
UNION ALL 
select 'SELECT DISTINCT '+@KEYID+' FROM [FU_STG].[T_STG_'+@tableNM+']'
UNION ALL 
select ')'
UNION ALL 
select ' '
UNION ALL 
select 'INSERT INTO [FU_ODS].[T_ODS_'+@tableNM+']('
UNION ALL 
select case when name = @KEYID THEN '' else ',' end+name as column_name from sys.columns where object_id = object_id(N'FU_STG.T_STG_'+@tableNM+'') 
UNION ALL 
select ')'
UNION ALL 
select 'SELECT'
UNION ALL 
select case when name = @KEYID THEN '' else ',' end+name as column_name from sys.columns where object_id = object_id(N'FU_STG.T_STG_'+@tableNM+'') 
UNION ALL 
select 'FROM [FU_STG].[T_STG_'+@tableNM+']'
UNION ALL 
select 'END'

END
GO
