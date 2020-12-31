USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_ConvertQuery2HTMLTable_20200423] (
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

   --列，如果有
   IF EXISTS (SELECT 1 FROM sys.dm_exec_describe_first_result_SET(@SQLQuery, NULL, 0) WHERE NAME ='BG_Color')
   BEGIN
		SELECT @columnslist = 'BG_Color AS BG_Color,';
   END
   SELECT @columnslist += 'ISNULL(CAST(['+NAME + '] AS VARCHAR(500)),'''') AS TD,' FROM sys.dm_exec_describe_first_result_SET(@SQLQuery, NULL, 0);
    
   --表头，不包括BG_Color属性列
   SELECT @columnshead += ''''+NAME + ''' AS TH,' FROM sys.dm_exec_describe_first_result_SET(@SQLQuery, NULL, 0)  WHERE NAME NOT IN ('BG_Color')   ;
   SELECT @columnshead += '<td align=center><b>' + NAME + '</b></td>
   ' FROM sys.dm_exec_describe_first_result_SET(@SQLQuery, NULL, 0) WHERE NAME NOT IN ('BG_Color')   ;

   --去尾巴
   SET @columnslist = left (@columnslist, Len (@columnslist) - 1)
   SET @columnshead = left (@columnshead, Len (@columnshead) - 1)

   --SET @columnslist = Replace (@columnslist, ''')', ''') as TD')
   --PRINT @columnslist
   --PRINT @columnshead
   
   SET @FROMPOS = CHARINDEX ('FROM', @SQLQuery, 1)
   SET @restOfQuery = SUBSTRING(@SQLQuery, @FROMPOS, LEN(@SQLQuery) - @FROMPOS + 1)
   
   --SET @DynTSQL = CONCAT (
   --      'SELECT 
		 --(SELECT '
		 --, @columnshead
		 --,' FOR XML RAW(''TR''), ELEMENTS, TYPE) AS ''THEAD'',	 
		 --(SELECT TOP '
		 --,@RowCnt + ' '
   --      ,@columnslist
   --      ,' '
   --      ,@restOfQuery
		 --,@Orderby 
   --      ,' FOR XML RAW (''TR''), ELEMENTS, TYPE) AS ''TBODY'''
   --      ,' FOR XML PATH (''''), ROOT (''TABLE'')'
         --)
   --PRINT @DynTSQL

   --EXEC(@DynTSQL)
   --SELECT @DynTSQL; 
   --DECLARE @xml varchar(max)
   --SELECT @xml=(@DynTSQL);
   
   --SELECT @xml;
   
	DECLARE @Body VARCHAR(MAX),
		@BodySQL NVARCHAR(MAX),
		@TableHead VARCHAR(MAX),
		@TableTail VARCHAR(MAX);

	SET NoCount On;
	SET @TableHead = '<html><head>' +
				'<style>
				td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:11pt;}
				tr.even {background-color:white;}
				tr.odd {background-color:#eeeeee;}
				</style>' +
				'</head>' +
				'<body><table cellpadding=0 cellspacing=0 border=1>' +
				'<thead><tr bgcolor=#FFEFD8>' +
				@columnshead +
				'</tr></thead>';

	SELECT @BodySQL= N'SELECT @Body = CONVERT(VARCHAR(MAX),
		(SELECT TOP '+
		 @RowCnt + ' ' +
         @columnslist + ' ' +
         @restOfQuery + ' ' +
		 @Orderby + ' ' +
         'FOR XML RAW (''TR''), ELEMENTS, TYPE)
		 )'
	PRINT @BodySQL
	--EXEC @Body=(@BodySQL);
	EXEC sp_executesql @BodySQL,N'@Body VARCHAR(MAX) OUTPUT',@Body=@Body OUTPUT;
	PRINT @Body

	SET @TableTail = '</table></body></html>';

	SET @Body = Replace(@Body, '_x003D_', '=');
	SET @Body = Replace(@Body, '_x0020_', space(1));
	SET @Body = Replace(@Body, '<tr><BG_Color>', '<tr style="background:');
	SET @Body = Replace(@Body, '</BG_Color>', '">');
	--SET @Body = Replace(@Body, '<tr><TRRow>1</TRRow>', '<tr class="odd">');
	PRINT @Body
	--Select @TableHead + @Body + @TableTail;

   SET NOCOUNT OFF
END

GO
