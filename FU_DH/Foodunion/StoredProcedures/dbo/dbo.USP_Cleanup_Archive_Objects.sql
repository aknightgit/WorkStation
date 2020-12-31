USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[USP_Cleanup_Archive_Objects] 
@retention_days int = 90
AS
BEGIN

DECLARE @QUERY NVARCHAR(4000)
SET @QUERY = ''

SELECT @QUERY += 'DROP TABLE '+schema_name(schema_id)+'.['+[name]+'];'
FROM sys.tables
WHERE CASE WHEN PATINDEX('%[^0-9]%',RIGHT([name],8)) = 0 AND PATINDEX('%[^0-9]%',RIGHT([name],9))<>0 THEN DATEDIFF(DAY,RIGHT([name],8),GETDATE()) END >@retention_days

EXEC( @QUERY)

SELECT CASE WHEN @QUERY = '' THEN 'No table were dropped' ELSE REPLACE(@QUERY,'DROP','Dropped') END

SET @QUERY = ''

SELECT @QUERY += 'DROP PROC '+schema_name([uid])+'.['+[name]+'];' 
FROM sysobjects so 
WHERE so.xtype = 'P' AND CASE WHEN PATINDEX('%[^0-9]%',RIGHT([name],8)) = 0 AND PATINDEX('%[^0-9]%',RIGHT([name],9))<>0 THEN DATEDIFF(DAY,RIGHT([name],8),GETDATE()) END >@retention_days

EXEC( @QUERY)

SELECT CASE WHEN @QUERY = '' THEN 'No PROC were dropped' ELSE REPLACE(@QUERY,'DROP','Dropped') END


END

GO
