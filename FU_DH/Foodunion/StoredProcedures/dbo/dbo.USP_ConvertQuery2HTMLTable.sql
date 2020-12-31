USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*-------------------------------------------------
Sample：
[dbo].[USP_ConvertQuery2HTMLTable_20200601] 'SELECT 
      [负责人]
      ,[负责区域]
      ,[Sell-in指标] AS [Sell]
      ,[MTD Sell-In达成] AS [MTD]
      ,[Sell-in Ach%]
      ,[Sell-Out指标]
      ,[MTD Sell-Out达成]
      ,[Sell-Out Ach%]
	  ,[Row_Attr]
  FROM [rpt].[Sales_销售区域达成日报]
  WHERE [负责人] NOT IN (''Unassigned'') ',100,
  'Director DESC,Manager,[负责区域]'
-------------------------------------------------*/


CREATE PROC [dbo].[USP_ConvertQuery2HTMLTable] (
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
	DECLARE @DynTSQL NVARCHAR (max);
	DECLARE @FROMPOS INT;
	DECLARE @SQL NVARCHAR(MAX);
	DECLARE @SQL1 NVARCHAR(MAX);
	DECLARE @SQL2 NVARCHAR(MAX);
	DECLARE @CONT INT;
	DECLARE @I INT;

	SET NOCOUNT ON;

	SET @RowCnt = CASE WHEN ISNULL(@RowCnt,'') IN ('','null') THEN 100 ELSE @RowCnt END;
	SET @Orderby = CASE WHEN ISNULL(@Orderby,'') IN ('','null') THEN '' ELSE ' ORDER BY '+@Orderby END;

	SET @SQL=@SQLQuery
	SET @CONT=(SELECT  (LEN(@SQLQuery) - LEN(REPLACE(@SQLQuery, ' AS ', '')))/4)
	SET @I=0

	WHILE  @I<@CONT
	BEGIN 
	SET @SQL1= LEFT(@SQL,CHARINDEX(' AS ',@SQL))
	SET @SQL2= SUBSTRING(@SQL, CHARINDEX(' AS ',@SQL),4000)
	SELECT  @SQL = @SQL1+SUBSTRING(@SQL2,CHARINDEX(',',@SQL2),4000)
	SET @I=@I+1
	END


	--列，如果有
	IF EXISTS (SELECT 1 FROM sys.dm_exec_describe_first_result_SET(@SQL, NULL, 0) WHERE NAME ='Row_Attr')
	BEGIN
		SELECT @columnslist = 'Row_Attr AS Row_Attr,';
	END
	SELECT @columnslist += 'ISNULL(CAST(['+NAME + '] AS VARCHAR(500)),'''') AS td,' FROM sys.dm_exec_describe_first_result_SET(@SQL, NULL, 0)
	WHERE NAME NOT IN ('Row_Attr')  ;
    
	--表头，不包括Row_Attr属性列
	--SELECT @columnshead += ''''+NAME + ''' AS TH,' FROM sys.dm_exec_describe_first_result_SET(@SQLQuery, NULL, 0)  WHERE NAME NOT IN ('Row_Attr')   ;
	SELECT @columnshead += '<td align=center><b>' + NAME + '</b></td>' FROM sys.dm_exec_describe_first_result_SET(@SQLQuery, NULL, 0) WHERE NAME NOT IN ('Row_Attr')   ;

	--去尾巴
	SET @columnslist = left (@columnslist, Len (@columnslist) - 1)
	--SET @columnshead = left (@columnshead, Len (@columnshead) - 1)
	--SET @columnslist = Replace (@columnslist, ''')', ''') as TD')
	--PRINT @columnslist
	--PRINT @columnshead
   
	SET @FROMPOS = CHARINDEX ('FROM', @SQLQuery, 1)
	SET @restOfQuery = SUBSTRING(@SQLQuery, @FROMPOS, LEN(@SQLQuery) - @FROMPOS + 1)
 
   
	DECLARE 
		@Body VARCHAR(MAX),
		@TableHead VARCHAR(MAX),
		@TableTail VARCHAR(MAX);

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

	SELECT @DynTSQL= N'SELECT @Body = CONVERT(VARCHAR(MAX),
		(SELECT TOP '+
			@RowCnt + ' ' +
			@columnslist + ' ' +
			@restOfQuery + ' ' +
			@Orderby + ' ' +
			'FOR XML RAW (''tr''), ELEMENTS, TYPE)
			)'
	--PRINT @DynTSQL
	--EXEC @Body=(@BodySQL);
	EXEC sp_executesql @DynTSQL,N'@Body VARCHAR(MAX) OUTPUT',@Body=@Body OUTPUT;
	--PRINT @Body

	SET @TableTail = '</table></body></html>';

	SET @Body = Replace(@Body, '_x003D_', '=');
	SET @Body = Replace(@Body, '_x0020_', space(1));
	SET @Body = Replace(@Body, '<tr><Row_Attr>', '<tr ');
	SET @Body = Replace(@Body, '</Row_Attr>', '>');
	SET @Body = Replace(@Body, '<tr><Row_Attr/>', '<tr>');	
	--SET @Body = Replace(@Body, '<tr><TRRow>1</TRRow>', '<tr class="odd">');
	--PRINT @Body
	SELECT @TableHead + @Body + @TableTail;

	SET NOCOUNT OFF
END


--SELECT TOP 100 ISNULL(CAST([负责人] AS VARCHAR(500)),'') as TD,ISNULL(CAST([负责区域] AS VARCHAR(500)),'') as TD,ISNULL(CAST([Sell-in指标] AS VARCHAR(500)),'') as TD,ISNULL(CAST([MTD Sell-In达成] AS VARCHAR(500)),'') as TD,ISNULL(CAST([Sell-in Ach%] AS VARCHAR(500)),'') as TD,ISNULL(CAST([Sell-Out指标] AS VARCHAR(500)),'') as TD,ISNULL(CAST([MTD Sell-Out达成] AS VARCHAR(500)),'') as TD,ISNULL(CAST([Sell-Out Ach%] AS VARCHAR(500)),'') as TD,ISNULL(CAST([Row_Attr] AS VARCHAR(500)),'') as TD FROM [rpt].[Sales_销售区域达成日报]
--  WHERE [负责人] NOT IN ('Unassigned')  ORDER BY Director DESC,Manager,[负责区域] FOR XML RAW ('TR'), ELEMENTS, TYPE


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


--DECLARE @html varchar(MAX)
--SET @html = '<TABLE border=1 style="width:100%">
--                    <TR style="background:#a7bfde;font-weight:bold;">
--                        <td>q1</td>
--                        <td>q2</td>
--                        <td>Compare</td>
--                    </TR>'+
--                    (
--                    SELECT [td/@style] = 'background:blue;color:white;','yellow','red')
--                          ,[td] = [负责人]
--                          ,null
--                          ,[td/@style] = 'background:blue;color:white;','yellow','red')
--                          ,[td] = [负责区域]
--                          ,null
--                          ,[td/@style] = 'background:blue;color:white;','yellow','red')
--                          ,[td] = name 
--                     FROM [rpt].[Sales_销售区域达成日报]
--                    FOR XML PATH('TR')
--                    )
--                    +'</TABLE>'        
--SELECT @html

/*
Declare @Body varchar(max),
    @TableHead varchar(max),
    @TableTail varchar(max);

SET NoCount On;
SET @TableTail = '</table></body></html>';
SET @TableHead = '<html><head>' +
            '<style>
    td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:11pt;}
    tr.even {background-color:white;}
    tr.odd {background-color:#eeeeee;}
            </style>' +
            '</head>' +
            '<body><table cellpadding=0 cellspacing=0 border=0>' +
            '<tr bgcolor=#FFEFD8><td align=center><b>Server Name</b></td>' +
            '<td align=center><b>Product</b></td>' +
            '<td align=center><b>Provider</b></td>' +
            '<td align=center><b>Data Source</b></td>' +
            '<td align=center><b>Is Linked?</b></td></tr>';

Select @Body = CONVERT(VARCHAR(MAX),(Select Row_Number() Over(Order By is_linked, name) % 2 As [TRRow],
        name As [TD],
        product As [TD],
        provider As [TD],
        data_source As [TD align=center],
        is_linked As [TD align=center]
    From sys.servers
    Order By is_linked, name
    For XML Raw('tr'), Elements));

SET @Body = Replace(@Body, '_x003D_', '=');
SET @Body = Replace(@Body, '_x0020_', space(1));
SET @Body = Replace(@Body, '<tr><TRRow>0</TRRow>', '<tr class="even">');
SET @Body = Replace(@Body, '<tr><TRRow>1</TRRow>', '<tr class="odd">');

Select @TableHead + @Body + @TableTail;
*/

GO
