USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[USP_ConvertQuery2HTMLTable_20200424] (
	@SQLQuery NVARCHAR(4000),
	@RowCnt VARCHAR(100),
	@Orderby NVARCHAR(1024) = ''
	)
AS
BEGIN
   --DECLaRE @SQLQuery NVARCHAR(3000) ='SELECT TOP 10 *FROM DM.Dim_Brand'
   DECLARE @columnslist NVARCHAR (max) = '';
   DECLARE @columnshead NVARCHAR (max) = '';
   DECLARE @restOfQuery NVARCHAR (max) = '';
   DECLARE @DynTSQL NVARCHAR (max)
   DECLARE @FROMPOS INT

   SET NOCOUNT ON

   SET @RowCnt = CASE WHEN ISNULL(@RowCnt,'') IN ('','null') THEN 100 ELSE @RowCnt END;
   SET @Orderby = CASE WHEN ISNULL(@Orderby,'') IN ('','null') THEN '' ELSE ' ORDER BY '+@Orderby END;

   SELECT @columnslist += 'ISNULL(CAST(['+NAME + '] AS VARCHAR(500)),''''),' FROM sys.dm_exec_describe_first_result_set(@SQLQuery, NULL, 0);
   SELECT @columnshead += ''''+NAME + ''' AS TH,' FROM sys.dm_exec_describe_first_result_set(@SQLQuery, NULL, 0);
   
   SET @columnslist = left (@columnslist, Len (@columnslist) - 1)
   SET @columnshead = left (@columnshead, Len (@columnshead) - 1)

   SET @columnslist = Replace (@columnslist, ''')', ''') as TD')
   --PRINT @columnslist
   --PRINT @columnshead
   
   SET @FROMPOS = CHARINDEX ('FROM', @SQLQuery, 1)
   SET @restOfQuery = SUBSTRING(@SQLQuery, @FROMPOS, LEN(@SQLQuery) - @FROMPOS + 1)
   
   SET @DynTSQL = CONCAT (
         'SELECT 
		 (SELECT '
		 , @columnshead
		 ,' FOR XML RAW(''TR''), ELEMENTS, TYPE) AS ''THEAD'',	 
		 (SELECT TOP '
		 ,@RowCnt + ' '
         ,@columnslist
         ,' '
         ,@restOfQuery
		 ,@Orderby 
         ,' FOR XML RAW (''TR''), ELEMENTS, TYPE) AS ''TBODY'''
         ,' FOR XML PATH (''''), ROOT (''TABLE'')'
         )
   PRINT @DynTSQL

   EXEC(@DynTSQL); 
   --DECLARE @xml xml
   --SELECT @xml=(@DynTSQL);

   --SELECT @xml;

   SET NOCOUNT OFF
END
GO
