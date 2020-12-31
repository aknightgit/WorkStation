USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_Sales_SLT_Overview]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [rpt].[SP_RPT_Sales_SLT_Overview]
AS BEGIN 


 ;WITH dailysales AS(
	--SELECT Datekey, 'VG' AS Channel,'Sell Out' AS Item,SUM(Gross_Sale_Value) AS Sales,SUM(Sale_Qty)
	--FROM dm.Fct_CRV_DailySales with(nolock) GROUP BY Datekey



	SELECT Datekey,LEFT(Store_ID,2) AS Channel,'Sell Out' AS Item, SUM(Sales_Amt) AS Sales
	--, SUM(Sales_Vol_KG) AS Sales_Vol_KG
	FROM dm.Fct_KAStore_DailySalesInventory with(nolock) 
	WHERE LEFT(Store_ID,2) IN ('YH','VG')
	GROUP BY Datekey,LEFT(Store_ID,2)

	UNION

	SELECT Datekey,
		CASE WHEN ch.Channel_Name='YH' THEN 'YH'
		WHEN Channel_Name_Display='Vanguard' THEN 'VG'
		WHEN Channel_Name='KidsWant' THEN 'KW'
		ELSE 'Distributors' END AS Channel,
		'Sell In' AS Item,
		SUM(Amount) AS Sales
		--SUM(Weight_KG) AS Sales_Vol_KG
	FROM [dm].[Fct_Sales_SellIn_ByChannel] si WITH(NOLOCK)
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
	ON si.Channel_ID=ch.Channel_ID AND ch.Monthkey = si.DateKey/100
	WHERE ch.Team in ('Dragon Team','Offline','YH')
	and datekey>=20190201
	GROUP BY Datekey,
		CASE WHEN ch.Channel_Name='YH' THEN 'YH'
		WHEN Channel_Name_Display='Vanguard' THEN 'VG'
		WHEN Channel_Name='KidsWant' THEN 'KW'
		ELSE 'Distributors' END
		--ORDER BY 1,2, 3
		/*
	SELECT Datekey, CASE Channel WHEN  'Vanguard' THEN 'VG' WHEN 'YH' THEN 'YH' ELSE 'Distributors' END AS Channel, 'Sell In' AS Item
		, SUM(Actual_AMT)*1000 AS Sales
		, SUM(Actual_VOL)*1000 AS Sales_Vol_KG
	FROM [rpt].[ERP_Sales_Order] 
	WHERE On_Off_Line IN ('Offline','YH','DRAGON TEAM') --Channel in ('Vanguard','YH')
	GROUP BY Datekey, CASE Channel WHEN  'Vanguard' THEN 'VG' WHEN 'YH' THEN 'YH'  ELSE 'Distributors' END 
	ORDER BY 1,2,3
	*/
	)
,monthlysales AS (
	SELECT Datekey/100 AS Monthkey,Channel,Item,SUM(Sales) AS MonthlySales
	--,SUM(Sales_Vol_KG) AS MonthlyVol 
	FROM dailysales GROUP BY Datekey/100,Channel,Item
	)
,weeklysales AS (
	SELECT dc.Year,dc.Week_Year_NBR,Channel,Item,SUM(Sales) AS WeeklySales 
	FROM dailysales d 
	JOIN FU_EDW.Dim_Calendar dc ON dc.Date_ID=d.Datekey 
	GROUP BY dc.Year,dc.Week_Year_NBR,Channel,Item
	)
,monthlytarget AS (
	SELECT  Monthkey,'KA' AS Channel_Group,Channel,'Sell Out' AS Item,SUM(Sales_Target)/1000 AS MonthlyTarget
	FROM [dm].[Fct_KAStore_SalesTarget_Monthly] with(nolock)
	GROUP BY Monthkey,Channel

	UNION

	SELECT Monthkey,
		CASE WHEN Region in ('Vanguard','YH') THEN 'KA'	ELSE 'CP' END AS Channel_Group,
		CASE WHEN Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
		WHEN Region='Vanguard' THEN 'VG'
		ELSE 'Distributors' END AS Channel,
		'Sell In' AS Item,
		SUM(Target_Amount) AS MonthlyTarget
	FROM [dm].[Fct_Sales_SellInTarget] with(nolock)
	WHERE Channel IN ('OFFLINE','YH','DRAGON TEAM')
	--AND Monthkey=201908
	GROUP BY Monthkey,
		CASE WHEN Region in ('Vanguard','YH') THEN 'KA'	ELSE 'CP' END,
		CASE WHEN Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
		WHEN Region='Vanguard' THEN 'VG'
		ELSE 'Distributors' END 
	)
,weeklytarget AS(
	SELECT dc.Year as Yearkey,dc.Week_Year_NBR,dc.Week_Date_Period,MAX(Date_ID) END_Date,Channel_Group,Channel,Item, max(MonthlyTarget)/max(md.days)*count(1) AS WeeklyTarget
	FROM monthlytarget mt
	JOIN [FU_EDW].[Dim_Calendar] AS dc with(nolock) ON mt.MonthKey = dc.Year_Month
	JOIN (SELECT Year_Month,count(1) days FROM [FU_EDW].[Dim_Calendar] with(nolock) GROUP BY Year_Month) md ON md.Year_Month = mt.MonthKey
	GROUP BY dc.Year,dc.Week_Year_NBR,dc.Week_Date_Period,Channel_Group,Channel,Item
	)
SELECT wt.Yearkey
	,k.Year_Month AS Monthkey	
	,wt.Week_Year_NBR
	,wt.Week_Date_Period
	,wt.Channel_Group
	,wt.Channel
	,wt.Item AS Item
	,wt.WeeklyTarget AS WeeklyTarget
	,ws.WeeklySales/1000 AS WeeklyActual
	,lws.WeeklySales/1000 AS LastWeekActual
	,CASE WHEN lws.WeeklySales IS NULL THEN NULL ELSE ws.WeeklySales/lws.WeeklySales-1 END AS Raise	
	,mt.MonthlyTarget AS MonthlyTarget
	,m1.MonthlySales/1000 AS MonthlyActual
	,CASE WHEN ISNULL(mt.MonthlyTarget,0)=0 THEN NULL ELSE m1.MonthlySales/1000/mt.MonthlyTarget END AS MonthlyArch
	--,m1.MonthlyVol/1000 AS MonthlyVolActual
	,l.LatestDay
FROM weeklytarget wt
LEFT JOIN weeklysales ws ON wt.Yearkey=ws.Year AND wt.Week_Year_NBR=ws.Week_Year_NBR AND wt.Channel=ws.Channel AND wt.Item=ws.Item
LEFT JOIN weeklysales lws ON wt.Yearkey=lws.Year AND wt.Week_Year_NBR=lws.Week_Year_NBR+1 AND wt.Channel=lws.Channel  AND wt.Item=lws.Item
--LEFT JOIN (SELECT Year,Week_Year_NBR,MAX(Year_Month) Year_Month FROM FU_EDW.Dim_Calendar GROUP BY Year,Week_Year_NBR)k ON wt.Yearkey=k.Year AND wt.Week_Year_NBR=k.Week_Year_NBR
LEFT JOIN (SELECT DISTINCT Year,Week_Year_NBR,Year_Month FROM FU_EDW.Dim_Calendar)k ON wt.Yearkey=k.Year AND wt.Week_Year_NBR=k.Week_Year_NBR  --允许同一个week有两个月份可选
LEFT JOIN monthlytarget mt ON mt.Monthkey=k.Year_Month AND mt.Channel=wt.Channel AND mt.Item=wt.Item
LEFT JOIN monthlysales m1 ON m1.Monthkey=k.Year_Month AND m1.Channel=wt.Channel AND m1.Item=wt.Item
JOIN (SELECT MAX(Datekey) AS LatestDay FROM dailysales WHERE Item='Sell Out')l ON 1 =1 
--WHERE wt.Week_Year_NBR=32
WHERE wt.END_Date<=CONVERT(VARCHAR(8),GETDATE()+7,112)
--AND wt.Week_Year_NBR=31
ORDER BY 1,2,4,6
;
END
GO
