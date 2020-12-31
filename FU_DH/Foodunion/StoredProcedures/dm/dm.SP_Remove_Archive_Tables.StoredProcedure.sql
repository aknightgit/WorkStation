USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Remove_Archive_Tables]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dm].[SP_Remove_Archive_Tables] 
@retention_days int = 90
AS
BEGIN

DECLARE @QUERY NVARCHAR(255)
SET @QUERY = ''

SELECT @QUERY += 'DROP TABLE '+schema_name(schema_id)+'.'+[name]+';'
FROM sys.tables
WHERE CASE WHEN PATINDEX('%[^0-9]%',RIGHT([name],8)) = 0 AND PATINDEX('%[^0-9]%',RIGHT([name],9))<>0 THEN DATEDIFF(DAY,RIGHT([name],8),GETDATE()) END >@retention_days

EXEC( @QUERY)

SELECT CASE WHEN @QUERY = '' THEN 'No table were dropped' ELSE REPLACE(@QUERY,'DROP','Dropped') END


END

GO
