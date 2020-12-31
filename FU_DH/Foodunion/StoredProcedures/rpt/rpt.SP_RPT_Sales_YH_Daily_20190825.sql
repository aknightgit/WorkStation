USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [rpt].[SP_RPT_Sales_YH_Daily_20190825]
AS BEGIN 


 
	DROP TABLE IF EXISTS #dailysales;
	SELECT  
		CASE WHEN ds.Account_Area_CN NOT IN ('重庆大区','四川大区','北京大区','福建大区','华东大区','安徽大区') THEN '其他' 
		ELSE LEFT(ds.Account_Area_CN,2) END AS Account_Area_CN
		, kds.Datekey
		, DENSE_RANK() OVER(ORDER BY kds.Datekey/100 DESC) mid
		, SUM(Sales_AMT) AS Sales_AMT
	INTO #dailysales
	FROM dm.Fct_KAStore_DailySalesInventory kds WITH(NOLOCK)
	JOIN dm.Dim_Store ds ON ds.Store_ID=kds.Store_ID
	WHERE ds.Channel_Account='YH'
	--AND kds.Datekey BETWEEN 20190801 AND 20190831
	AND  kds.Datekey > CONVERT(VARCHAR(8),Dateadd("MM",-2,EOMONTH(getdate())),112)
	GROUP BY  CASE WHEN ds.Account_Area_CN NOT IN ('重庆大区','四川大区','北京大区','福建大区','华东大区','安徽大区') THEN '其他' 
		ELSE LEFT(ds.Account_Area_CN,2) END
		, kds.Datekey
	ORDER BY 2 DESC

	SELECT 
		tar.Account_Area_CN
		,tar.Sales_Target  --本月指标
		,SUM(lm.LM_Sales) AS LM_Sales  --本月销售
		,SUM(tm.TM_Sales) AS TM_Sales	--上月销售
		--,MAX(tm.TM_Days_Cnt) AS TM_Days_Cnt
		--,MAX(dct.TMD) AS TM_Days_ALL
		--,MAX(lm.LM_Days_Cnt) AS LM_Days_Cnt
		--,SUM(tm.TM_Sales/tm.TM_Days_Cnt) AS TM_Avg
		--,SUM(lm.lM_Sales/lm.LM_Days_Cnt) AS LM_Avg
		,(CAST(SUM(tm.TM_Days_Cnt) AS decimal(20,10))/ SUM(dct.TMD)) AS TimeBar  --时间进度
		,MAX(tm.TM_Sales)/tar.Sales_Target AS Arch  --进度
		,MAX((tm.TM_Sales/tm.TM_Days_Cnt) / (lm.lM_Sales/lm.LM_Days_Cnt) - 1) AS Grouth  --日均增长
		,SUM(yt.Sales_AMT) AS Latest_AMT
		,SUM(Fresh_INV) AS Fresh_INV
		,SUM(Ambient_INV) AS Ambient_INV
		,CAST(CAST(MAX(Latest_Date)AS varchar) AS DATE) AS Latest_Date
		--SELECT *
	FROM (SELECT  
		CASE WHEN ds.Account_Area_CN NOT IN ('重庆大区','四川大区','北京大区','福建大区','华东大区','安徽大区') THEN '其他' 
		ELSE LEFT(ds.Account_Area_CN,2) END AS Account_Area_CN
		, SUM(Sales_Target) AS Sales_Target
		FROM dm.Fct_KAStore_SalesTarget_Monthly kds WITH(NOLOCK)
		JOIN dm.Dim_Store ds WITH(NOLOCK) ON ds.Store_ID=kds.Store_ID
		WHERE ds.Channel_Account='YH'
		AND kds.Monthkey=CONVERT(VARCHAR(6),GETDATE(),112)
		GROUP BY  CASE WHEN ds.Account_Area_CN NOT IN ('重庆大区','四川大区','北京大区','福建大区','华东大区','安徽大区') THEN '其他' 
			ELSE LEFT(ds.Account_Area_CN,2) END
		)tar--本月指标
	LEFT JOIN (SELECT Account_Area_CN,SUM(Sales_AMT) AS LM_Sales ,COUNT(DISTINCT Datekey) AS LM_Days_Cnt FROM #dailysales WHERE mid=2 GROUP BY Account_Area_CN)lm ON lm.Account_Area_CN=tar.Account_Area_CN 
	LEFT JOIN (SELECT Account_Area_CN,SUM(Sales_AMT) AS TM_Sales ,COUNT(DISTINCT Datekey) AS TM_Days_Cnt FROM #dailysales WHERE mid=1 GROUP BY Account_Area_CN)tm ON tm.Account_Area_CN=tar.Account_Area_CN 
	LEFT JOIN #dailysales yt ON yt.Account_Area_CN=tar.Account_Area_CN AND yt.Datekey = (SELECT MAX(Datekey) FROM dm.Fct_KAStore_DailySalesInventory WITH(NOLOCK))
	LEFT JOIN (SELECT COUNT(1) TMD FROM FU_EDW.Dim_Calendar WITH(NOLOCK) WHERE Year_Month=CONVERT(VARCHAR(6),GETDATE(),112))dct ON 1=1
	LEFT JOIN (
		SELECT CASE WHEN ds.Account_Area_CN NOT IN ('重庆大区','四川大区','北京大区','福建大区','华东大区','安徽大区') THEN '其他' 
			ELSE LEFT(ds.Account_Area_CN,2) END AS Account_Area_CN
			,SUM(CASE WHEN p.Product_Sort='Fresh' THEN kds.Inventory_Qty ELSE 0 END) AS Fresh_INV
			,SUM(CASE WHEN p.Product_Sort='Ambient' THEN kds.Inventory_Qty ELSE 0 END) AS Ambient_INV
			,MAX(Datekey) AS Latest_Date
		FROM dm.Fct_KAStore_DailySalesInventory kds WITH(NOLOCK)
		JOIN dm.Dim_Store ds WITH(NOLOCK) ON ds.Store_ID=kds.Store_ID
		JOIn dm.Dim_Product p WITH(NOLOCK) ON kds.SKU_ID=p.SKU_ID
		WHERE ds.Channel_Account='YH'
		AND Datekey=(SELECT MAX(Datekey) FROM dm.Fct_KAStore_DailySalesInventory WITH(NOLOCK))
		GROUP BY  CASE WHEN ds.Account_Area_CN NOT IN ('重庆大区','四川大区','北京大区','福建大区','华东大区','安徽大区') THEN '其他' 
		ELSE LEFT(ds.Account_Area_CN,2) END 
	)inv ON inv.Account_Area_CN=tar.Account_Area_CN
	WHERE tar.Account_Area_CN IS NOT NULL
	GROUP BY tar.Account_Area_CN
		,tar.Sales_Target

	DROP TABLE IF EXISTS #dailysales;

END
GO
