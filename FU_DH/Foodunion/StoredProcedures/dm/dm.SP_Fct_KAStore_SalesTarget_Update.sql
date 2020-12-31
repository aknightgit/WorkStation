USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE   [dm].[SP_Fct_KAStore_SalesTarget_Update]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY 

	--Target Monthly
	 /* ------- 历史数据，已经固定，不需要再每天刷新

	TRUNCATE TABLE  [dm].[Fct_KAStore_SalesTarget_Monthly] 

	--YH Target
	INSERT INTO [dm].[Fct_KAStore_SalesTarget_Monthly]
           ([Monthkey]
           ,[Channel]
		   ,[Channel_ID]
		   ,[SalesTerritory]
		   ,[Area]
           ,[Store_ID]
           ,[Store_Code]
           ,[Store_Name]
           ,[Ambient_Sales_Target]
           ,[Fresh_Sales_Target]
           ,[Sales_Target]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT 
		ods.MonthKey,
		'YH',
		5 AS Channel_ID,
		tm.SalesTerritory,
		s.Account_Area_CN,
		s.Store_ID,
		ods.[Account_Store_Code],	
		s.Store_Name,		
		ods.Ambient_Target AS [Ambient_Sales_Target],
		ods.Fresh_Target AS [Fresh_Sales_Target],
		ods.Total_Target AS [Sales_Target],
		GETDATE() AS [Create_Time],
		@ProcName AS [Create_By],
		GETDATE() AS [Update_Time],
		@ProcName AS [Update_By]
    FROM ODS.ods.[File_YHStore_BMTarget] ods
    JOIN dm.Dim_Store s
		ON ods.[Account_Store_Code]=s.[Account_Store_Code] AND s.Channel_Account = 'YH'
	LEFT JOIN [dm].[Dim_SalesTerritoryMapping] tm 
		ON s.Store_Province LIKE '%'+tm.Province_Short+'%'
 --  WHERE ods.MonthKey < '201912'
	

    --VG/KW/ZB 其他渠道
	INSERT INTO [dm].[Fct_KAStore_SalesTarget_Monthly]
           ([Monthkey]
           ,[Channel]
		   ,Channel_ID
           ,[Store_ID]
           ,[Store_Code]
           ,[Store_Name]
           ,[Ambient_Sales_Target]
           ,[Fresh_Sales_Target]
           ,[Sales_Target]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT 201908,'VG',15,'','','',0,0,700000.00,GETDATE(),'Mannual',GETDATE(),'Mannual'
	UNION 
	SELECT 201909,'VG',15,'','','',0,0,600000.00,GETDATE(),'Mannual',GETDATE(),'Mannual'
	UNION 
	SELECT 201910,'VG',15,'','','',0,0,855000.00,GETDATE(),'Mannual',GETDATE(),'Mannual'
	UNION 
	SELECT 201911,'VG',15,'','','',0,0,750000.00,GETDATE(),'Mannual',GETDATE(),'Mannual'
	UNION 
	SELECT 201912,'VG',15,'','','',0,0,750000.00,GETDATE(),'Mannual',GETDATE(),'Mannual'
	
	--添加孩子王KW值，只是为了[rpt].[SP_RPT_Sales_SLT_Overview]中使用
	UNION 
	SELECT 201911,'KW',16,'','','',0,0,0.00,GETDATE(),'Mannual',GETDATE(),'Mannual'
	UNION 
	SELECT 201912,'KW',16,'','','',0,0,200000.00,GETDATE(),'Mannual',GETDATE(),'Mannual'

	--添加世纪华联指标
	UNION 
	SELECT 201912,'CM',87,'','','',0,0,12000.00,GETDATE(),'Mannual',GETDATE(),'Mannual';
	
	*/


	-------------------------12月之后的target从[dm].[Fct_Sales_SellOutTarget_ByKAarea]拿
	-------------------------只到区域级别，不再到门店
	DELETE [dm].[Fct_KAStore_SalesTarget_Monthly]  WHERE Monthkey >=201912 AND Channel IN ('YH','KW','VG');
	INSERT INTO[dm].[Fct_KAStore_SalesTarget_Monthly] 
	 (      [Monthkey]
           ,[Channel]
		   ,Channel_ID
		   ,[SalesTerritory]
		   ,Area
		   ,Store_ID
           ,[Sales_Target]
		   ,Ambient_Sales_Target
		   ,Fresh_Sales_Target
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT bk.Monthkey
		  ,bk.KA AS [Channel]
		  ,bk.Channel_ID
		  ,tm.[Region]
		  ,bk.Area
		  ,bk.Area
		  ,SUM(CAST(CAST(TargetAmt AS FLOAT)  AS INT)) AS TargetAmt
		  ,SUM(CAST(CAST(TargetAmt_Ambient AS FLOAT) AS INT)) AS TargetAmt_Ambient
		  ,SUM(CAST(CAST(TargetAmt_Fresh AS FLOAT)	  AS INT)) AS TargetAmt_Fresh
		  ,GETDATE()
		  ,'[dm].[SP_Fct_KAStore_SalesTarget_Update]'
		  ,GETDATE()
		  ,'[dm].[SP_Fct_KAStore_SalesTarget_Update]'
	FROM [dm].[Fct_Sales_SellOutTarget_ByKAarea] bk WITH(NOLOCK)
	LEFT JOIN (
		SELECT  
		CASE Channel_Account
			WHEN 'Vanguard' THEN 'VG'
			WHEN 'CenturyMart' THEN 'CM'
			WHEN 'RTMart' THEN 'RT'
			ELSE Channel_Account END AS Channel_Account
		,ISNULL(Sales_Area_CN,'') AS Area
		,MAX(Store_Province) AS Province 
		FROM dm.dim_store WITH(NOLOCK)
		GROUP BY Channel_Account
			,ISNULL(Sales_Area_CN,'')
			) st ON bk.KA = st.Channel_Account 
				AND st.Area LIKE '%'+bk.Area+'%' 
	LEFT JOIN  (SELECT * FROM [dm].[Dim_SalesTerritory_Mapping_Monthly] WHERE [Monthkey]=(SELECT MAX([Monthkey]) FROM [dm].[Dim_SalesTerritory_Mapping_Monthly]) AND [Channel]='YH' ) tm    --用Dim_SalesTerritory_Mapping_Monthly 替代Dim_SalesTerritoryMapping  Justin 2020-05-06
	ON ISNULL(st.Province, bk.Area) LIKE '%'+tm.Province_Short+'%'
    GROUP BY bk.Monthkey
		  ,bk.KA
		  ,bk.Channel_ID
		  ,tm.[Region]
		  ,bk.Area
	-------------------------------------------------------------------------------------------------------------
	
	--YH/KW/VG Weekly target
	
	--use actual SALEs to evaluate weekly target, from monthly target
	DROP TABLE IF EXISTS #Target;
	;with sal_hist as(
		select dc.Day_of_Week,sum(ys.Sales_AMT) Sales
		from [dm].[Fct_YH_Sales_Inventory] ys with(nolock)
		join [dm].[Dim_Calendar] dc with(nolock) on ys.Calendar_DT=dc.Datekey
		where dc.Date > dateadd("MONTH",-3,getdate())   --latest 3 month sales
		group by dc.Day_of_Week
		--order by 1 desc
		)
	, sal_total as (select sum(sal_hist.Sales) sal_total from sal_hist) 
	SELECT 
		--dc.Datekey,
		dc.Year as [Yearkey],
		dc.Week_of_Year as Week_of_Year, 
		min(dc.Start_of_Week) as Start_Date,
		max(dc.End_of_Week) as End_Date,
		'YH' AS [Channel],
		CAST('5' AS nvarchar(50)) AS Channel_ID,
		CAST(st.SalesTerritory AS nvarchar(50)) AS [SalesTerritory],
		st.area,
		st.Store_ID as [Store_ID],
		st.Account_Store_Code as [Store_Code],
		'' as [Region],
		st.Store_Name as [Store_Name],
		sum((cast(st.Total_Target as decimal(18,9))/dc.Days_in_Month) * factor) as Sales_Target, 
		sum((cast(st.Ambient_Target as decimal(18,9))/dc.Days_in_Month) * factor) as Ambient_Sales_Target,
		sum((cast(st.Fresh_Target as decimal(18,9))/dc.Days_in_Month) * factor) as Fresh_Sales_Target
	INTO #Target
	FROM (
		SELECT ods.Account_Store_Code,ods.Total_Target,ods.Ambient_Target,ods.Fresh_Target,ds.Store_ID,ds.Store_Name,tm.[Region] AS SalesTerritory,ds.Account_Area_CN AS Area,ods.MonthKey 
		FROM [ODS].ods.[File_YHStore_BMTarget] AS ods with(nolock)
		JOIN [dm].Dim_Store ds  with(nolock) ON ods.Account_Store_Code = ds.Account_Store_Code AND ds.Channel_Account = 'YH'
		LEFT JOIN (SELECT * FROM [dm].[Dim_SalesTerritory_Mapping_Monthly] WHERE [Monthkey]=(SELECT MAX([Monthkey]) FROM [dm].[Dim_SalesTerritory_Mapping_Monthly]) AND [Channel]='YH' ) tm ON ds.Store_Province LIKE '%'+tm.Province_Short+'%'
		WHERE ODS.MonthKey <'201912'
		UNION ALL
		SELECT '' AS Account_Store_Code,bk.TargetAmt,bk.TargetAmt_Ambient,bk.TargetAmt_Fresh,'' AS Store_ID,'' AS Store_Name
			,CASE bk.Area WHEN '东北' THEN '北区' 
				WHEN '津冀' THEN '北区' 
				ELSE tm.[Region] END AS SalesTerritory
			,bk.Area
			,bk.Monthkey 
		FROM [dm].[Fct_Sales_SellOutTarget_ByKAarea] bk
		LEFT JOIN (SELECT * FROM [dm].[Dim_SalesTerritory_Mapping_Monthly] WHERE [Monthkey]=(SELECT MAX([Monthkey]) FROM [dm].[Dim_SalesTerritory_Mapping_Monthly]) AND [Channel]='YH' ) tm ON bk.Area LIKE '%'+tm.Province_Short+'%'
		WHERE bk.KA = 'YH'
	) st
	JOIN [dm].[Dim_Calendar] AS dc with(nolock) ON st.MonthKey = dc.Monthkey
	--JOIN (SELECT Monthkey,count(1) days FROM [dm].[Dim_Calendar] with(nolock) GROUP BY Monthkey) md ON md.Monthkey = st.MonthKey
	JOIN (select sal_hist.Day_of_Week,sal_hist.Sales/sal_total*7 as factor
		from sal_hist,sal_total)sal
		ON sal.Day_of_Week = dc.Day_of_Week
	--WHERE ods.Account_Store_Code='9816'
--	WHERE ods.MonthKey < '201912'
	GROUP BY dc.Year,
		dc.Week_of_Year,
		st.Store_ID,
		st.Account_Store_Code,
		st.Store_Name,
		st.SalesTerritory,
		st.Area
	--ORDER BY 1;
	
	--VG target没有按照门店给到，只到月份汇总
	INSERT INTO #Target
           ([Yearkey]
           ,[Week_of_Year]
           ,[Start_Date]
           ,[End_Date]
           ,[Channel]
		   ,[Channel_ID]
		   ,[SalesTerritory]
		   ,[area]
           ,[Store_ID]
           ,[Store_Code]
		   ,[Region]
           ,[Store_Name]
           ,[Ambient_Sales_Target]
           ,[Fresh_Sales_Target]
           ,[Sales_Target]
		   )
	SELECT a.Year
		   ,a.[Week_of_Year]
           ,a.[Start_Date]
           ,a.[End_Date]
		   ,t.[Channel]
		   ,t.Channel_ID
		   ,t.[SalesTerritory]
		   ,t.Area
           ,''		   
           ,''    
		   ,''
		   ,''       
           ,0 AS [Ambient_Sales_Target]
           ,0 AS [Fresh_Sales_Target]
		   ,SUM(t.[Sales_Target]/w.mday*w.wday) AS [Sales_Target]
	FROM (
		SELECT Monthkey,[Channel],[Sales_Target],Channel_ID,[SalesTerritory],Area
		FROM [dm].[Fct_KAStore_SalesTarget_Monthly]
		WHERE [Channel] IN ('VG','KW','CM'/*,'YH'*/)
		)t
	JOIN (SELECT c.Monthkey,c.Week_of_Year,COUNT(1) wday,MAX(Day_of_Month) mday from dm.Dim_Calendar c	GROUP BY c.Monthkey,c.Week_of_Year)w 
		ON w.Monthkey=t.Monthkey
	--JOIN (SELECT c.Monthkey,COUNT(1) mday from dm.Dim_Calendar c GROUP BY c.Monthkey)m 
	--	ON t.Monthkey=m.Monthkey
	JOIN (SELECT Year,Week_of_Year,Min(Start_of_Week) [Start_Date],Max(End_of_Week) [End_Date],MAX(Monthkey) Month
		FROM dm.Dim_Calendar WHERE Year=2019
		GROUP BY Year,Week_of_Year )a ON a.Week_of_Year=w.Week_of_Year AND w.Monthkey/100=a.Year
	GROUP BY  a.Year
		,a.[Week_of_Year]
        ,a.[Start_Date]
        ,a.[End_Date]
		,t.[Channel]
	    ,t.Channel_ID
		,t.[SalesTerritory]
		,t.Area


	DELETE t
	FROM [dm].[Fct_KAStore_SalesTarget_Weekly] t
	JOIN #Target s ON t.[Yearkey] = s.[Yearkey] AND t.[Week_Year_NBR] = s.[Week_of_Year] ;


	INSERT INTO [dm].[Fct_KAStore_SalesTarget_Weekly]
           ([Yearkey]
           ,[Week_Year_NBR]
           ,[Start_Date]
           ,[End_Date]
           ,[Channel]
		   ,Channel_ID
		   ,[SalesTerritory]
		   ,Area
           ,[Store_ID]
           ,[Store_Code]
           ,[Store_Name]
           ,[Ambient_Sales_Target]
           ,[Fresh_Sales_Target]
           ,[Sales_Target]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT [Yearkey]
           ,[Week_of_Year]
           ,CONVERT(VARCHAR(8),[Start_Date],112)
           ,CONVERT(VARCHAR(8),[End_Date],112)
		   ,[Channel]
		   ,[Channel_ID]
		   ,[SalesTerritory]
		   ,ISNULL([Area],'')
           ,[Store_ID]	
		   ,[Store_Code]	   
           ,[Store_Name]           
           ,[Ambient_Sales_Target]
           ,[Fresh_Sales_Target]
		   ,[Sales_Target]
		   ,GETDATE() AS [Create_Time]
		   ,'[dm].[SP_Fct_KAStore_SalesTarget_Update]'  AS [Create_By]
		   ,GETDATE() AS [Update_Time]
		   ,'[dm].[SP_Fct_KAStore_SalesTarget_Update]'  AS [Update_By]
	FROM #Target;
	
   
	DROP TABLE #Target;

	END TRY
	BEGIN CATCH

	SELECT @errmsg =  ERROR_MESSAGE();

	 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

	 RAISERROR(@errmsg,16,1);

	END CATCH

END


--select min(MonthKey),max(MonthKey) from ODS.ods.[File_YHStore_BMTarget] ods
--select top 10 *from ODS.ods.[File_YHStore_BMTarget] order by 1 desc
--select top 100 *from [dm].[Dim_Calendar]


/*
;with sal_hist as(
	select dc.Week_Day,sum(ys.Sales_AMT) Sales
	from [dm].[Fct_YH_Sales] ys with(nolock)
	join [dm].[Dim_Calendar] dc with(nolock) on ys.POS_DT=dc.Datekey
	group by dc.Week_Day
	--order by 1 desc
	)
, sal_total as (select sum(sal_hist.Sales) sal_total from sal_hist) 

SELECT 
	--dc.Datekey,
	dc.Year,
	dc.Week_Year_NBR,
	ds.Store_ID,
	'',
	ds.Store_Name,
	min(dc.Datekey) as Start_Date,
	max(dc.Datekey) as End_Date,
	sum((cast(ods.Total_Target as decimal(18,9))/md.days) * factor) as Total_Target, 
	sum((cast(ods.Ambient_Target as decimal(18,9))/md.days) * factor) as Ambient_Target,
	sum((cast(ods.Fresh_Target as decimal(18,9))/md.days) * factor) as Fresh_Target,
	GETDATE() AS [Create_Time]
	,OBJECT_NAME(@@PROCID) AS [Create_By]
	,GETDATE() AS [Update_Time]
	,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM ODS.ods.[File_YHStore_BMTarget] AS ods with(nolock)
JOIN dm.Dim_Store ds  with(nolock) ON ods.Account_Store_Code = ds.Account_Store_Code
JOIN [dm].[Dim_Calendar] AS dc with(nolock) ON ods.MonthKey = dc.Year_Month
JOIN (SELECT Year_Month,count(1) days FROM [dm].[Dim_Calendar] with(nolock) GROUP BY Year_Month) md ON md.Year_Month = ods.MonthKey
JOIN (select sal_hist.Week_Day,sal_hist.Sales/sal_total*7 as factor
	from sal_hist,sal_total)sal
	ON sal.Week_Day = dc.Week_Day
WHERE ods.Account_Store_Code='9816'
GROUP BY dc.Year,
	dc.Week_Year_NBR,
	ds.Store_ID,
	ds.Account_Region_CN,
	ds.Store_Name
ORDER BY 1

*/


--select * from  dm.[Fct_YH_Target_Weekly]
--where Store_ID='YH0600'
--order by 1,2

--SELECT 
--*
--INTO [dm].[Fct_KAStore_SalesTarget_Weekly_20191128]
--FROM [dm].[Fct_KAStore_SalesTarget_Weekly]
GO
