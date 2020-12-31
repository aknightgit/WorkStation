USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE   [dm].[SP_Fct_KAStore_SalesTarget_Update_20191206]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY 

	--Target Monthly
	TRUNCATE TABLE [dm].[Fct_KAStore_SalesTarget_Monthly];

	--YH Target
	INSERT INTO [dm].[Fct_KAStore_SalesTarget_Monthly]
           ([Monthkey]
           ,[Channel]
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
   
    --VG/KW/ZB 其他渠道
	INSERT INTO [dm].[Fct_KAStore_SalesTarget_Monthly]
           ([Monthkey]
           ,[Channel]
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
	SELECT 201908,'VG','','','',0,0,700000.00,GETDATE(),'Mannual',GETDATE(),'Mannual'
	UNION 
	SELECT 201909,'VG','','','',0,0,600000.00,GETDATE(),'Mannual',GETDATE(),'Mannual'
	UNION 
	SELECT 201910,'VG','','','',0,0,855000.00,GETDATE(),'Mannual',GETDATE(),'Mannual'
	UNION 
	SELECT 201911,'VG','','','',0,0,750000.00,GETDATE(),'Mannual',GETDATE(),'Mannual'
	UNION 
	SELECT 201912,'VG','','','',0,0,750000.00,GETDATE(),'Mannual',GETDATE(),'Mannual'
	
	--添加孩子王KW值，只是为了[rpt].[SP_RPT_Sales_SLT_Overview]中使用
	UNION 
	SELECT 201911,'KW','','','',0,0,0.00,GETDATE(),'Mannual',GETDATE(),'Mannual'
	UNION 
	SELECT 201912,'KW','','','',0,0,200000.00,GETDATE(),'Mannual',GETDATE(),'Mannual'

	--添加世纪华联指标
	UNION 
	SELECT 201912,'CM','','','',0,0,12000.00,GETDATE(),'Mannual',GETDATE(),'Mannual';
	
	-------------------------------------------------------------------------------------------------------------
	
	--YH/KW/VG Weekly target
	
	--use actual SALEs to evaluate weekly target, from monthly target
	;with sal_hist as(
		select dc.Week_Day,sum(ys.Sales_AMT) Sales
		from [dm].[Fct_YH_Sales_Inventory] ys with(nolock)
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
		'YH' AS [Channel],
		ds.Store_ID as [Store_ID],
		ds.Account_Store_Code as [Store_Code],
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
		ds.Account_Store_Code,
		ds.Store_Name
	--ORDER BY 1;

	--VG target没有按照门店给到，只到月份汇总
	INSERT INTO #Target
           ([Yearkey]
           ,[Week_Year_NBR]
           ,[Start_Date]
           ,[End_Date]
           ,[Channel]
           ,[Store_ID]
           ,[Store_Code]
		   ,[Region]
           ,[Store_Name]
           ,[Ambient_Sales_Target]
           ,[Fresh_Sales_Target]
           ,[Sales_Target]
		   )
	SELECT a.Year
		   ,a.[Week_Year_NBR]
           ,a.[Start_Date]
           ,a.[End_Date]
		   ,t.[Channel]
           ,''		   
           ,''    
		   ,''
		   ,''       
           ,0 AS [Ambient_Sales_Target]
           ,0 AS [Fresh_Sales_Target]
		   ,SUM(t.[Sales_Target]/m.mday*w.wday) AS [Sales_Target]
	FROM (
		SELECT Monthkey,[Channel],[Sales_Target] 
		FROM [dm].[Fct_KAStore_SalesTarget_Monthly]
		WHERE [Channel] IN ('VG','KW','CM')
		)t
	JOIN (SELECT c.Year_Month,c.Week_Year_NBR,COUNT(1) wday from FU_EDW.Dim_Calendar c	GROUP BY c.Year_Month,c.Week_Year_NBR)w 
		ON w.Year_Month=t.Monthkey
	JOIN (SELECT c.Year_Month,COUNT(1) mday from FU_EDW.Dim_Calendar c GROUP BY c.Year_Month)m 
		ON t.Monthkey=m.Year_Month
	JOIN (SELECT Year,Week_Year_NBR,Min(Date_ID) [Start_Date],Max(Date_ID) [End_Date],MAX(Year_Month) Month
		FROM FU_EDW.Dim_Calendar WHERE Year=2019
		GROUP BY Year,Week_Year_NBR )a ON a.Week_Year_NBR=w.Week_Year_NBR AND w.Year_Month/100=a.Year
	GROUP BY  a.Year
		,a.[Week_Year_NBR]
        ,a.[Start_Date]
        ,a.[End_Date]
		,t.[Channel]


	DELETE t
	FROM [dm].[Fct_KAStore_SalesTarget_Weekly] t
	JOIN #Target s ON t.[Yearkey] = s.[Yearkey] AND t.[Week_Year_NBR] = s.[Week_Year_NBR] ;


	INSERT INTO [dm].[Fct_KAStore_SalesTarget_Weekly]
           ([Yearkey]
           ,[Week_Year_NBR]
           ,[Start_Date]
           ,[End_Date]
           ,[Channel]
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
           ,[Week_Year_NBR]
           ,[Start_Date]
           ,[End_Date]
		   ,[Channel]
           ,[Store_ID]	
		   ,[Store_Code]	   
           ,[Store_Name]           
           ,[Ambient_Sales_Target]
           ,[Fresh_Sales_Target]
		   ,[Sales_Target]
		   ,GETDATE() AS [Create_Time]
		   ,@ProcName AS [Create_By]
		   ,GETDATE() AS [Update_Time]
		   ,@ProcName AS [Update_By]
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

--SELECT 
--*
--INTO [dm].[Fct_KAStore_SalesTarget_Weekly_20191128]
--FROM [dm].[Fct_KAStore_SalesTarget_Weekly]
GO
