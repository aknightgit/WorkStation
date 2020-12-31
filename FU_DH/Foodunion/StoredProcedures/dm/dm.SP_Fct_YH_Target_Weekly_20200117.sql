USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE    [dm].[SP_Fct_YH_Target_Weekly_20200117]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
	@DatabaseName varchar(100) = DB_NAME(),
	@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY 

	--TRUNCATE TABLE dm.[Fct_YH_Target_Weekly];

	--use actual SALEs to evaluate weekly target, from monthlyt target
	;with sal_hist as(
		select dc.Week_Day,sum(ys.Sales_AMT) Sales
		from dm.Fct_YH_Sales_Inventory ys with(nolock)
		join [FU_EDW].[Dim_Calendar] dc with(nolock) on ys.Calendar_DT=dc.Date_ID
		where dc.Date_NM > dateadd("MONTH",-3,getdate())   --latest 3 month sales
		group by dc.Week_Day
		--order by 1 desc
		)
	, sal_total as (select sum(sal_hist.Sales) sal_total from sal_hist) 

	SELECT 
		--dc.Date_ID,
		dc.Year as [Yearkey],
		dc.Week_Year_NBR as [Week_Year_NBR], 
		min(dc.date_id) as Start_Date,
		max(dc.date_id) as End_Date,
		ds.Store_ID as [Store_ID],
		'' as [Region],
		ds.Store_Name as [Store_Name],
		sum((cast(ods.Total_Target as decimal(18,9))/md.days) * factor) as Sales_Target, 
		sum((cast(ods.Ambient_Target as decimal(18,9))/md.days) * factor) as Ambient_Sales_Target,
		sum((cast(ods.Fresh_Target as decimal(18,9))/md.days) * factor) as Fresh_Sales_Target
	INTO #Target
	FROM [ODS].ods.[File_YHStore_BMTarget] AS ods with(nolock)
	JOIN [dm].Dim_Store ds  with(nolock) ON ods.Account_Store_Code = ds.Account_Store_Code AND ds.Channel_Account = 'YH'
	JOIN [FU_EDW].[Dim_Calendar] AS dc with(nolock) ON ods.MonthKey = dc.Year_Month
	JOIN (SELECT Year_Month,count(1) days FROM [FU_EDW].[Dim_Calendar] with(nolock) GROUP BY Year_Month) md ON md.Year_Month = ods.MonthKey
	JOIN (select sal_hist.Week_Day,sal_hist.Sales/sal_total*7 as factor
		from sal_hist,sal_total)sal
		ON sal.Week_Day = dc.Week_Day
	--WHERE ods.Account_Store_Code='9816'
	GROUP BY dc.Year,
		dc.Week_Year_NBR,
		ds.Store_ID,
		ds.Store_Name
	--ORDER BY 1;

	DELETE t
	FROM [dm].[Fct_YH_Target_Weekly] t
	JOIN #Target s ON t.[Yearkey] = s.[Yearkey] AND t.[Week_Year_NBR] = s.[Week_Year_NBR] ;

	INSERT INTO [dm].[Fct_YH_Target_Weekly]
           ([Yearkey]
           ,[Week_Year_NBR]
           ,[Start_Date]
           ,[End_Date]
           ,[Store_ID]
           ,[Region]
           ,[Store_Name]
           ,[Sales_Target]
           ,[Ambient_Sales_Target]
           ,[Fresh_Sales_Target]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By]
		   ,KPI_DESC)
	SELECT [Yearkey]
           ,[Week_Year_NBR]
           ,[Start_Date]
           ,[End_Date]
           ,[Store_ID]
           ,[Region]
           ,[Store_Name]
           ,[Sales_Target]
           ,[Ambient_Sales_Target]
           ,[Fresh_Sales_Target]
		   ,GETDATE() AS [Create_Time]
			,OBJECT_NAME(@@PROCID) AS [Create_By]
			,GETDATE() AS [Update_Time]
			,OBJECT_NAME(@@PROCID) AS [Update_By]
			,'Target'
	FROM #Target;
	--插入按周的实际销售额
	INSERT INTO [dm].[Fct_YH_Target_Weekly]
           ([Yearkey]
           ,[Week_Year_NBR]
           ,[Start_Date]
           ,[End_Date]
           ,[Store_ID]
           ,[Region]
           ,[Store_Name]
           ,[Sales_Target]
           ,[Ambient_Sales_Target]
           ,[Fresh_Sales_Target]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By]
		   ,KPI_DESC)
	SELECT 
		T1.Year,
		T1.Week_Year_NBR,
		0 START_DATE,
		CAST(CONVERT(VARCHAR(10),cast(T1.Week_Date_Period_End as date) ,112) AS INT) END_DATE,
		T.Store_ID,
		''REGION,
		''STORE_NAME,
		SUM(T.Sales_AMT)Sales_AMT,
		0 [Ambient_Sales_Target],
		0 [Fresh_Sales_Target],
		GETDATE() AS [Create_Time],
		OBJECT_NAME(@@PROCID) AS [Create_By],
		GETDATE() AS [Update_Time],
		OBJECT_NAME(@@PROCID) AS [Update_By],
		'Actual'KPI_DESC
	FROM dm.Fct_YH_Sales_Inventory T
	LEFT JOIN [FU_EDW].[Dim_Calendar] T1 ON T1.Date_ID=T.Calendar_DT
	WHERE Calendar_DT>='20190401'
	GROUP BY 
		T1.Year,
		T1.Week_Year_NBR,
		T1.Week_Date_Period_End,
		T.Store_ID;
   
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
--select top 100 *from [FU_EDW].[Dim_Calendar]


/*
;with sal_hist as(
	select dc.Week_Day,sum(ys.Sales_AMT) Sales
	from [dm].[Fct_YH_Sales] ys with(nolock)
	join [FU_EDW].[Dim_Calendar] dc with(nolock) on ys.POS_DT=dc.Date_ID
	group by dc.Week_Day
	--order by 1 desc
	)
, sal_total as (select sum(sal_hist.Sales) sal_total from sal_hist) 

SELECT 
	--dc.Date_ID,
	dc.Year,
	dc.Week_Year_NBR,
	ds.Store_ID,
	'',
	ds.Store_Name,
	min(dc.date_id) as Start_Date,
	max(dc.date_id) as End_Date,
	sum((cast(ods.Total_Target as decimal(18,9))/md.days) * factor) as Total_Target, 
	sum((cast(ods.Ambient_Target as decimal(18,9))/md.days) * factor) as Ambient_Target,
	sum((cast(ods.Fresh_Target as decimal(18,9))/md.days) * factor) as Fresh_Target,
	GETDATE() AS [Create_Time]
	,OBJECT_NAME(@@PROCID) AS [Create_By]
	,GETDATE() AS [Update_Time]
	,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM ODS.ods.[File_YHStore_BMTarget] AS ods with(nolock)
JOIN dm.Dim_Store ds  with(nolock) ON ods.Account_Store_Code = ds.Account_Store_Code
JOIN [FU_EDW].[Dim_Calendar] AS dc with(nolock) ON ods.MonthKey = dc.Year_Month
JOIN (SELECT Year_Month,count(1) days FROM [FU_EDW].[Dim_Calendar] with(nolock) GROUP BY Year_Month) md ON md.Year_Month = ods.MonthKey
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
GO
