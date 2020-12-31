USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [rpt].[SP_RPT_Sales_SLT_Overview]
AS BEGIN 


DROP TABLE IF EXISTS #dailysales ;
SELECT ds.* INTO #dailysales
FROM(
	SELECT Datekey,LEFT(si.Store_ID,2) AS Channel,'Sell Out' AS Item,tm.[Region] AS SalesTerritory, SUM(Sales_Amt) AS Sales
	--, SUM(Sales_Vol_KG) AS Sales_Vol_KG
	FROM dm.Fct_KAStore_DailySalesInventory si with(nolock)
	LEFT JOIN dm.Dim_Store st ON si.Store_ID = st.Store_ID
	LEFT JOIN (SELECT * FROM [dm].[Dim_SalesTerritory_Mapping_Monthly] WHERE [Monthkey]=(SELECT MAX([Monthkey]) FROM [dm].[Dim_SalesTerritory_Mapping_Monthly]) AND [Channel]='YH') tm  --用Dim_SalesTerritory_Mapping_Monthly 替代Dim_SalesTerritoryMapping Justin 2020-05-07
	ON st.Store_Province LIKE '%'+ tm.Province_Short + '%'
	WHERE LEFT(si.Store_ID,2) IN ('YH','VG','KW','CM') 
	GROUP BY Datekey,LEFT(si.Store_ID,2),tm.[Region]
	UNION

	SELECT Datekey,
		CASE WHEN ch.Channel_Name='YH' THEN 'YH'
		WHEN Channel_Name_Display='Vanguard' THEN 'VG'
		--WHEN Channel_Name_Display='CenturyMart' THEN 'CM'
		WHEN Channel_Name='KidsWant' THEN 'KW'
		WHEN Channel_Type IN('CP', 'Distributor') THEN ch.Channel_Category END,
		--ELSE 'Distributors' END AS Channel,
		'Sell In' AS Item,
		CASE WHEN ch.Channel_Name='YH' OR Channel_Name_Display='Vanguard' OR Channel_Name='KidsWant' 
			--OR Channel_Name_Display ='CenturyMart' 
			THEN 'KA'
		WHEN Channel_Type = 'CP' THEN 'Distributor'
		WHEN Channel_Type = 'Distributor' THEN 'Distributor'END AS Channel_Group,
		SUM(Amount) AS Sales
		--SUM(Weight_KG) AS Sales_Vol_KG
	FROM [dm].[Fct_Sales_SellIn_ByChannel] si WITH(NOLOCK)
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
	ON si.Channel_ID=ch.Channel_ID AND ch.Monthkey = si.DateKey/100
	WHERE ch.Team in ('Dragon Team','Offline','YH','MKT') AND Channel_Name <> 'KidsWant' AND si.Channel_ID <> 48--ZBOX
	and datekey>=20190201
	GROUP BY Datekey,
		CASE WHEN ch.Channel_Name='YH' THEN 'YH'
		WHEN Channel_Name_Display='Vanguard' THEN 'VG'
		--WHEN Channel_Name_Display='CenturyMart' THEN 'CM'
		WHEN Channel_Name='KidsWant' THEN 'KW'
		WHEN Channel_Type IN('CP', 'Distributor') THEN ch.Channel_Category  END,
		CASE WHEN ch.Channel_Name='YH' OR Channel_Name_Display='Vanguard' OR Channel_Name='KidsWant' 
		--OR Channel_Name_Display ='CenturyMart' 
		THEN 'KA'
		WHEN Channel_Type = 'CP' THEN 'Distributor'
		WHEN Channel_Type = 'Distributor' THEN 'Distributor'END 

	------------------孩子王寄售模式 使用调拨单计算sell in--------------------
	UNION ALL
	SELECT
	   [Datekey]
      ,'KW' AS Channel
	  ,'Sell In' AS Item
	  ,'KA' AS Channel_Group
      ,Sum(stie.Sale_QTY * isnull(pl.SKU_Price,p.Sale_Unit_RSP*0.85)) AS [Actual_AMT]
	FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
	JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
	JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON stie.SKU_ID=p.SKU_ID
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
		ON ch.Channel_Name='Kidswant' AND ch.Monthkey = sti.DateKey/100
	LEFT JOIN dm.Dim_Product_Pricelist pl WITH(NOLOCK) ON p.SKU_ID=pl.SKU_ID AND pl.Price_List_Name='统一供价' AND Is_Current=1
	WHERE stie.Dest_Stock like '%孩子王寄售仓%'
	--AND pl.SKU_ID IS NULL
	GROUP BY [Datekey]
)ds

--select * from #dailysales order by 1 desc,2
DROP TABLE IF EXISTS #weeklysales;
SELECT ws.* INTO #weeklysales
FROM (
	SELECT dc.Year,dc.Week_of_Year AS Week_Year_NBR,Channel,Item,SUM(Sales) AS WeeklySales ,SalesTerritory
	FROM #dailysales d 
	JOIN dm.Dim_Calendar dc ON dc.Datekey=d.Datekey 
	GROUP BY dc.Year,dc.Week_of_Year,Channel,Item,SalesTerritory
)ws

--SELECT * FROM #weeklysales

DROP TABLE IF EXISTS #monthlytarget;
SELECT mt.* into #monthlytarget
FROM (
	--------------------------------201912前用[dm].[Fct_KAStore_SalesTarget_Monthly]表里的target
	SELECT  SI.Monthkey,'KA' AS Channel_Group,SI.Channel,'Sell Out' AS Item,SUM(Sales_Target)/1000 AS MonthlyTarget,tm.[Region] AS SalesTerritory
	FROM [dm].[Fct_KAStore_SalesTarget_Monthly] si with(nolock) 
	LEFT JOIN dm.Dim_Store st ON si.Store_ID = st.Store_ID
	LEFT JOIN (SELECT * FROM [dm].[Dim_SalesTerritory_Mapping_Monthly] WHERE [Monthkey]=(SELECT MAX([Monthkey]) FROM [dm].[Dim_SalesTerritory_Mapping_Monthly]) AND [Channel]='YH') tm 
	ON st.Store_Province LIKE '%'+ tm.Province_Short + '%'
	WHERE SI.Monthkey < '201912' 
	GROUP BY SI.Monthkey,SI.Channel,tm.[Region]
	UNION ALL

	--------------------------------201912后用[dm].[[Fct_Sales_SellOutTarget_ByKAarea]]表里的target
	SELECT BK.Monthkey,'KA' AS Channel_Group,CASE KA WHEN 'Vanguard' THEN 'VG' WHEN 'Kidswant' THEN 'KW' ELSE KA END AS Channel,'Sell Out' AS Item,SUM(CAST(TargetAmt AS DECIMAL(20,10)))/1000 AS MonthlyTarget,
	       CASE WHEN KA = 'YH' AND bk.area in ('东北','津冀') THEN '北区' ELSE tm.[Region] END AS SalesTerritory
    FROM [dm].[Fct_Sales_SellOutTarget_ByKAarea] bk
	LEFT JOIN (SELECT  Channel_Account,ISNULL(Sales_Area_CN,Account_Area_CN) AS Area
		,MAX(Store_Province) AS Province 
		FROM [dm].[Dim_Store] s 
		JOIN (SELECT * FROM [dm].[Dim_SalesTerritory_Mapping_Monthly] WHERE [Monthkey]=(SELECT MAX([Monthkey]) FROM [dm].[Dim_SalesTerritory_Mapping_Monthly]) AND [Channel]='YH') m 
		ON CHARINDEX(m.Province_Short,s.Store_Province)>0 
		GROUP BY Channel_Account,ISNULL(Sales_Area_CN,Account_Area_CN)
		) st ON CASE WHEN bk.KA = 'Kidswant' THEN 'KW' WHEN bk.KA = 'CM' THEN 'CenturyMart' WHEN bk.KA = 'VG' THEN 'Vanguard' ELSE bk.KA END  = st.Channel_Account AND st.Area =bk.Area
	LEFT JOIN  (SELECT * FROM [dm].[Dim_SalesTerritory_Mapping_Monthly] WHERE [Monthkey]=(SELECT MAX([Monthkey]) FROM [dm].[Dim_SalesTerritory_Mapping_Monthly]) AND [Channel]='YH') tm ON ISNULL(st.Province, bk.Area) LIKE '%'+tm.Province_Short+'%'
	WHERE BK.Monthkey >= '201912'
	GROUP BY BK.Monthkey,CASE KA WHEN 'Vanguard' THEN 'VG' WHEN 'Kidswant' THEN 'KW' ELSE KA END ,CASE WHEN KA = 'YH' AND bk.area in ('东北','津冀') THEN '北区' ELSE tm.[Region] END
	UNION	

	SELECT  
		Datekey/100
		,CASE WHEN ch.Channel_Category in ('Vanguard','YH','Kidswant') THEN 'KA' ELSE 'CP' END AS Channel_Group
		,CASE WHEN Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
		    WHEN ch.Channel_Category='Kidswant' THEN 'KW'
			WHEN ch.Channel_Category='Vanguard' THEN 'VG'
			--WHEN ch.Channel_Category='CenturyMart' THEN 'CM'
			WHEN Channel_Type IN( 'CP','Distributor') THEN dc.Channel_Category
			ELSE 'Distributor' END AS Channel
		,'Sell In' AS Item
		,SUM(Target_AMT) AS MonthlyTarget
		,CASE WHEN Customer_Name='富平云商供应链管理有限公司'OR ch.Channel_Category='Kidswant' OR ch.Channel_Category='Vanguard' 
			--OR ch.Channel_Category='CenturyMart' 
			THEN 'CM'
			WHEN Channel_Type = 'CP' THEN 'Distributor'
		    WHEN Channel_Type = 'Distributor' THEN 'Distributor'END 
    FROM [dm].[Fct_Sales_SellInTarget_ByChannel_hist] ch
	LEFT JOIN dm.Dim_Channel dc ON ch.Customer_Name = dc.ERP_Customer_Name
	GROUP BY Datekey/100
		,CASE WHEN ch.Channel_Category in ('Vanguard','YH','Kidswant') THEN 'KA'	ELSE 'CP' END 
		,CASE WHEN Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
		    WHEN ch.Channel_Category='Kidswant' THEN 'KW'
			WHEN ch.Channel_Category='Vanguard' THEN 'VG'
			--WHEN ch.Channel_Category='CenturyMart' THEN 'CM'
			WHEN Channel_Type IN( 'CP','Distributor') THEN dc.Channel_Category
			ELSE 'Distributor' END
		,CASE WHEN Customer_Name='富平云商供应链管理有限公司'OR ch.Channel_Category='Kidswant' OR ch.Channel_Category='Vanguard' 
			--OR ch.Channel_Category='CenturyMart' 
			THEN 'CM'
			WHEN Channel_Type = 'CP' THEN 'Distributor'
		    WHEN Channel_Type = 'Distributor' THEN 'Distributor'END 
	UNION
	SELECT  
		Monthkey
		,CASE WHEN Channel_Category_Name in ('Vanguard','YH','Kidswant') THEN 'KA'	ELSE 'Distributor' END AS Channel_Group
		,CASE WHEN ERP_Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
			WHEN Channel_Category_Name='Vanguard' THEN 'VG'
			WHEN Channel_Category_Name='Kidswant' THEN 'KW'
			--WHEN Channel_Category_Name='CenturyMart' THEN 'CM'
			WHEN Channel_Type = 'Distributor' THEN Channel_Category_Name
			ELSE 'Distributor' END AS Channel
		--	ELSE 'Distributors' END AS Channel
		,'Sell In' AS Item
		,SUM(CASE WHEN ch.Channel_Type = 'Distributor' THEN Category_Target_Amt_KRMB ELSE ISNULL(Target_Amt_KRMB,Category_Target_Amt_KRMB) END) AS MonthlyTarget
		,CASE WHEN ERP_Customer_Name='富平云商供应链管理有限公司'OR Channel_Category_Name='Vanguard' OR Channel_Category_Name='Kidswant' 
		--OR Channel_Category_Name='CenturyMart' 
			THEN 'KA' 
		WHEN Channel_Type = 'Distributor' THEN 'Distributor' END AS Channel_Group
	FROM [dm].[Fct_Sales_SellInTarget_ByChannel] ch
	WHERE MonthKey>=201910 AND Team in ('Dragon Team','Offline','YH','MKT')
		AND (ISNULL(Target_Amt_KRMB,Category_Target_Amt_KRMB)>0 OR ISNULL(Target_Vol_MT,Category_Target_Vol_MT)>0)
	GROUP BY Monthkey
		,CASE WHEN Channel_Category_Name in ('Vanguard','YH','Kidswant') THEN 'KA'	ELSE 'Distributor' END
		,CASE WHEN ERP_Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
			WHEN Channel_Category_Name='Vanguard' THEN 'VG'
			WHEN Channel_Category_Name='Kidswant' THEN 'KW'
			--WHEN Channel_Category_Name='CenturyMart' THEN 'CM'
			WHEN Channel_Type = 'Distributor' THEN Channel_Category_Name
			ELSE 'Distributor' END
		,CASE WHEN ERP_Customer_Name='富平云商供应链管理有限公司'OR Channel_Category_Name='Vanguard'OR Channel_Category_Name='Kidswant' 
		--OR Channel_Category_Name='CenturyMart' 
		THEN 'KA' WHEN Channel_Type = 'Distributor' THEN 'Distributor' END
	HAVING(SUM(CASE WHEN ch.Channel_Type = 'Distributor' THEN Category_Target_Amt_KRMB ELSE ISNULL(Target_Amt_KRMB,Category_Target_Amt_KRMB) END) IS NOT NULL)
		--HAVING ISNULL(SUM(ISNULL(Target_Amt_KRMB,Category_Target_Amt_KRMB)),0)>0
)mt
--SELECT * FROM #monthlytarget ORDER BY 1 DESC,2

DROP TABLE IF EXISTS #weeklytarget;
SELECT wk.* into #weeklytarget
FROM (
	SELECT dc.Year as Yearkey,dc.Week_of_Year AS Week_Year_NBR,dc.Week_Nature_Str AS Week_Date_Period,MAX(DateKey) END_Date
		,Channel_Group,Channel,Item
		, max(MonthlyTarget)/max(md.days)*count(1) AS WeeklyTarget
		,SalesTerritory
	FROM #monthlytarget mt
	JOIN dm.[Dim_Calendar] AS dc with(nolock) ON mt.MonthKey = dc.Monthkey
	JOIN (SELECT Monthkey AS Year_Month,count(1) days FROM dm.[Dim_Calendar] with(nolock) GROUP BY Monthkey) md ON md.Year_Month = mt.MonthKey
	GROUP BY dc.Year,dc.Week_of_Year,dc.Week_Nature_Str,Channel_Group,Channel,Item,SalesTerritory
)wk

SELECT wt.Yearkey
	,k.Monthkey AS Monthkey	
	,wt.Week_Year_NBR
	,wt.Week_Date_Period
	,wt.Channel_Group
	,wt.Channel
	,wt.Item AS Item
	,wt.WeeklyTarget AS WeeklyTarget
	,ws.WeeklySales/1000 AS WeeklyActual
	,lws.WeeklySales/1000 AS LastWeekActual
	,CASE WHEN lws.WeeklySales IS NULL THEN NULL ELSE CASE WHEN lws.WeeklySales = 0 THEN NULL ELSE ws.WeeklySales/lws.WeeklySales-1 END END AS Raise	
	,mt.MonthlyTarget AS MonthlyTarget
	,m1.MonthlySales/1000 AS MonthlyActual
	,CASE WHEN ISNULL(mt.MonthlyTarget,0)=0 THEN NULL ELSE CASE WHEN mt.MonthlyTarget = 0 THEN NULL ELSE m1.MonthlySales/1000/mt.MonthlyTarget END END AS MonthlyArch
	--,m1.MonthlyVol/1000 AS MonthlyVolActual
	,l.LatestDay
	,wt.SalesTerritory
FROM #weeklytarget wt
LEFT JOIN #weeklysales ws ON wt.Yearkey=ws.Year 
	AND wt.Week_Year_NBR=ws.Week_Year_NBR AND wt.Channel=ws.Channel 
	AND wt.Item=ws.Item AND wt.SalesTerritory = ws.SalesTerritory
LEFT JOIN #weeklysales lws ON wt.Yearkey=lws.Year 
	AND wt.Week_Year_NBR=lws.Week_Year_NBR+1 AND wt.Channel=lws.Channel  
	AND wt.Item=lws.Item AND lws.SalesTerritory = wt.SalesTerritory
--LEFT JOIN (SELECT Year,Week_Year_NBR,MAX(Year_Month) Year_Month FROM FU_EDW.Dim_Calendar GROUP BY Year,Week_Year_NBR)k ON wt.Yearkey=k.Year AND wt.Week_Year_NBR=k.Week_Year_NBR
LEFT JOIN (SELECT DISTINCT Year,Week_of_Year,Monthkey FROM dm.Dim_Calendar)k ON wt.Yearkey=k.Year AND wt.Week_Year_NBR=k.Week_of_Year  --允许同一个week有两个月份可选 
LEFT JOIN #monthlytarget mt ON mt.Monthkey=k.Monthkey AND mt.Channel=wt.Channel AND mt.Item=wt.Item AND mt.SalesTerritory = wt.SalesTerritory
LEFT JOIN (
	SELECT Datekey/100 AS Monthkey,Channel,Item,SUM(Sales) AS MonthlySales,SalesTerritory
	--,SUM(Sales_Vol_KG) AS MonthlyVol 
	FROM #dailysales GROUP BY Datekey/100,Channel,Item,SalesTerritory
	) m1 ON m1.Monthkey=k.Monthkey AND m1.Channel=wt.Channel AND m1.Item=wt.Item and m1.SalesTerritory = wt.SalesTerritory
JOIN (SELECT MAX(Datekey) AS LatestDay FROM #dailysales WHERE Item='Sell Out')l ON 1 =1 
WHERE wt.END_Date<=CONVERT(VARCHAR(8),GETDATE()+7,112) AND wt.Channel IS NOT NULL 
AND wt.Channel <>'KW'   --排除 WK ,Justin 2020-05-15
--AND wt.Week_Year_NBR=31
ORDER BY 1,2,4,6
;
END



--select * from  [dm].[Fct_Sales_SellInTarget_ByChannel]

/*
 ;WITH dailysales AS(
	--SELECT Datekey, 'VG' AS Channel,'Sell Out' AS Item,SUM(Gross_Sale_Value) AS Sales,SUM(Sale_Qty)
	--FROM dm.Fct_CRV_DailySales with(nolock) GROUP BY Datekey



	SELECT Datekey,LEFT(si.Store_ID,2) AS Channel,'Sell Out' AS Item,tm.SalesTerritory, SUM(Sales_Amt) AS Sales
	--, SUM(Sales_Vol_KG) AS Sales_Vol_KG
	FROM dm.Fct_KAStore_DailySalesInventory si with(nolock)
	LEFT JOIN dm.Dim_Store st ON si.Store_ID = st.Store_ID
	LEFT JOIN dm.Dim_SalesTerritoryMapping tm ON st.Store_Province LIKE '%'+ tm.Province_Short + '%'
	WHERE LEFT(si.Store_ID,2) IN ('YH','VG','KW','CM') 
	GROUP BY Datekey,LEFT(si.Store_ID,2),tm.SalesTerritory
	UNION

	SELECT Datekey,
		CASE WHEN ch.Channel_Name='YH' THEN 'YH'
		WHEN Channel_Name_Display='Vanguard' THEN 'VG'
		--WHEN Channel_Name_Display='CenturyMart' THEN 'CM'
		WHEN Channel_Name='KidsWant' THEN 'KW'
		WHEN Channel_Type = 'CP' THEN ch.Channel_Category END,
		--ELSE 'Distributors' END AS Channel,
		'Sell In' AS Item,
		CASE WHEN ch.Channel_Name='YH' OR Channel_Name_Display='Vanguard' OR Channel_Name='KidsWant' 
			--OR Channel_Name_Display ='CenturyMart' 
			THEN 'KA'
		WHEN Channel_Type = 'CP' THEN 'CP' END AS Channel_Group,
		SUM(Amount) AS Sales
		--SUM(Weight_KG) AS Sales_Vol_KG
	FROM [dm].[Fct_Sales_SellIn_ByChannel] si WITH(NOLOCK)
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
	ON si.Channel_ID=ch.Channel_ID AND ch.Monthkey = si.DateKey/100
	WHERE ch.Team in ('Dragon Team','Offline','YH','MKT') AND Channel_Name <> 'KidsWant' AND si.Channel_ID <> 48--ZBOX
	and datekey>=20190201
	GROUP BY Datekey,
		CASE WHEN ch.Channel_Name='YH' THEN 'YH'
		WHEN Channel_Name_Display='Vanguard' THEN 'VG'
		--WHEN Channel_Name_Display='CenturyMart' THEN 'CM'
		WHEN Channel_Name='KidsWant' THEN 'KW'
		WHEN Channel_Type = 'CP' THEN ch.Channel_Category  END,
		CASE WHEN ch.Channel_Name='YH' OR Channel_Name_Display='Vanguard' OR Channel_Name='KidsWant' 
		--OR Channel_Name_Display ='CenturyMart' 
		THEN 'KA'
		WHEN Channel_Type = 'CP' THEN 'CP' END
		
	--	ELSE 'Distributors' END
	------------------孩子王寄售模式 使用调拨单计算sell in--------------------
	UNION ALL
	SELECT
	   [Datekey]
      ,'KW' AS Channel
	  ,'Sell In' AS Item
	  ,'KA' AS Channel_Group
      ,Sum(stie.Sale_QTY * isnull(pl.SKU_Price,p.Sale_Unit_RSP*0.85)) AS [Actual_AMT]
	FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
	JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
	JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON stie.SKU_ID=p.SKU_ID
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
		ON ch.Channel_Name='Kidswant' AND ch.Monthkey = sti.DateKey/100
	LEFT JOIN dm.Dim_Product_Pricelist pl WITH(NOLOCK) ON p.SKU_ID=pl.SKU_ID AND pl.Price_List_Name='统一供价' AND Is_Current=1
	WHERE stie.Dest_Stock like '%孩子王寄售仓%'
	--AND pl.SKU_ID IS NULL
	GROUP BY [Datekey]
	  


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
	SELECT Datekey/100 AS Monthkey,Channel,Item,SUM(Sales) AS MonthlySales,SalesTerritory
	--,SUM(Sales_Vol_KG) AS MonthlyVol 
	FROM dailysales GROUP BY Datekey/100,Channel,Item,SalesTerritory
	)
,weeklysales AS (
	SELECT dc.Year,dc.Week_Year_NBR,Channel,Item,SUM(Sales) AS WeeklySales ,SalesTerritory
	FROM dailysales d 
	JOIN FU_EDW.Dim_Calendar dc ON dc.Date_ID=d.Datekey 
	GROUP BY dc.Year,dc.Week_Year_NBR,Channel,Item,SalesTerritory
	)

,monthlytarget AS (
	--------------------------------201912前用[dm].[Fct_KAStore_SalesTarget_Monthly]表里的target
	SELECT  Monthkey,'KA' AS Channel_Group,Channel,'Sell Out' AS Item,SUM(Sales_Target)/1000 AS MonthlyTarget,tm.SalesTerritory
	FROM [dm].[Fct_KAStore_SalesTarget_Monthly] si with(nolock) 
	LEFT JOIN dm.Dim_Store st ON si.Store_ID = st.Store_ID
	LEFT JOIN dm.Dim_SalesTerritoryMapping tm ON st.Store_Province LIKE '%'+ tm.Province_Short + '%'
	WHERE Monthkey < '201912' 
	GROUP BY Monthkey,Channel,tm.SalesTerritory
	UNION ALL

	--------------------------------201912后用[dm].[[Fct_Sales_SellOutTarget_ByKAarea]]表里的target
	SELECT Monthkey,'KA' AS Channel_Group,CASE KA WHEN 'Vanguard' THEN 'VG' WHEN 'Kidswant' THEN 'KW' ELSE KA END AS Channel,'Sell Out' AS Item,SUM(CAST(TargetAmt AS DECIMAL(20,10)))/1000 AS MonthlyTarget,CASE WHEN KA = 'YH' AND bk.area in ('东北','津冀') THEN '北区' ELSE tm.SalesTerritory END AS SalesTerritory
    FROM [dm].[Fct_Sales_SellOutTarget_ByKAarea] bk
	LEFT JOIN (SELECT  Channel_Account,ISNULL(Sales_Area_CN,Account_Area_CN) AS Area
		,MAX(Store_Province) AS Province 
		FROM [dm].[Dim_Store] s 
		JOIN [dm].[Dim_SalesTerritoryMapping] m ON CHARINDEX(m.Province_Short,s.Store_Province)>0 
		GROUP BY Channel_Account,ISNULL(Sales_Area_CN,Account_Area_CN)
		) st ON CASE WHEN bk.KA = 'Kidswant' THEN 'KW' WHEN bk.KA = 'CM' THEN 'CenturyMart' WHEN bk.KA = 'VG' THEN 'Vanguard' ELSE bk.KA END  = st.Channel_Account AND st.Area =bk.Area
	LEFT JOIN  dm.Dim_SalesTerritoryMapping tm ON ISNULL(st.Province, bk.Area) LIKE '%'+tm.Province_Short+'%'
	WHERE Monthkey >= '201912'
	GROUP BY Monthkey,CASE KA WHEN 'Vanguard' THEN 'VG' WHEN 'Kidswant' THEN 'KW' ELSE KA END ,CASE WHEN KA = 'YH' AND bk.area in ('东北','津冀') THEN '北区' ELSE tm.SalesTerritory END
	UNION
	

	SELECT  
		Datekey/100
		,CASE WHEN ch.Channel_Category in ('Vanguard','YH','Kidswant') THEN 'KA' ELSE 'CP' END AS Channel_Group
		,CASE WHEN Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
		    WHEN ch.Channel_Category='Kidswant' THEN 'KW'
			WHEN ch.Channel_Category='Vanguard' THEN 'VG'
			--WHEN ch.Channel_Category='CenturyMart' THEN 'CM'
			WHEN Channel_Type = 'CP' THEN dc.Channel_Category
			ELSE 'Distributors' END AS Channel
		,'Sell In' AS Item
		,SUM(Target_AMT) AS MonthlyTarget
		,CASE WHEN Customer_Name='富平云商供应链管理有限公司'OR ch.Channel_Category='Kidswant' OR ch.Channel_Category='Vanguard' 
			--OR ch.Channel_Category='CenturyMart' 
			THEN 'CM'
			WHEN Channel_Type = 'CP' THEN 'CP' END
    FROM [dm].[Fct_Sales_SellInTarget_ByChannel_hist] ch
	LEFT JOIN dm.Dim_Channel dc ON ch.Customer_Name = dc.ERP_Customer_Name
	GROUP BY Datekey/100
		,CASE WHEN ch.Channel_Category in ('Vanguard','YH','Kidswant') THEN 'KA'	ELSE 'CP' END 
		,CASE WHEN Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
		    WHEN ch.Channel_Category='Kidswant' THEN 'KW'
			WHEN ch.Channel_Category='Vanguard' THEN 'VG'
			--WHEN ch.Channel_Category='CenturyMart' THEN 'CM'
			WHEN Channel_Type = 'CP' THEN dc.Channel_Category
			ELSE 'Distributors' END
		,CASE WHEN Customer_Name='富平云商供应链管理有限公司'OR ch.Channel_Category='Kidswant' OR ch.Channel_Category='Vanguard' 
			--OR ch.Channel_Category='CenturyMart' 
			THEN 'CM'
			WHEN Channel_Type = 'CP' THEN 'CP' END
	UNION
	SELECT  
		Monthkey
		,CASE WHEN Channel_Category_Name in ('Vanguard','YH','Kidswant') THEN 'KA'	ELSE 'CP' END AS Channel_Group
		,CASE WHEN ERP_Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
			WHEN Channel_Category_Name='Vanguard' THEN 'VG'
			WHEN Channel_Category_Name='Kidswant' THEN 'KW'
			--WHEN Channel_Category_Name='CenturyMart' THEN 'CM'
			WHEN Channel_Type = 'CP' THEN Channel_Category_Name
			ELSE 'Distributors' END AS Channel
		--	ELSE 'Distributors' END AS Channel
		,'Sell In' AS Item
		,SUM(CASE WHEN ch.Channel_Type = 'CP' THEN Category_Target_Amt_KRMB ELSE ISNULL(Target_Amt_KRMB,Category_Target_Amt_KRMB) END) AS MonthlyTarget
		,CASE WHEN ERP_Customer_Name='富平云商供应链管理有限公司'OR Channel_Category_Name='Vanguard'OR Channel_Category_Name='Kidswant' 
		--OR Channel_Category_Name='CenturyMart' 
		THEN 'KA' 
		WHEN Channel_Type = 'CP' THEN 'CP' END AS Channel_Group
	FROM [dm].[Fct_Sales_SellInTarget_ByChannel] ch
	WHERE MonthKey>=201910 AND Team in ('Dragon Team','Offline','YH','MKT')
	GROUP BY Monthkey
		,CASE WHEN Channel_Category_Name in ('Vanguard','YH','Kidswant') THEN 'KA'	ELSE 'CP' END
		,CASE WHEN ERP_Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
			WHEN Channel_Category_Name='Vanguard' THEN 'VG'
			WHEN Channel_Category_Name='Kidswant' THEN 'KW'
			--WHEN Channel_Category_Name='CenturyMart' THEN 'CM'
			WHEN Channel_Type = 'CP' THEN Channel_Category_Name
			ELSE 'Distributors' END
		,CASE WHEN ERP_Customer_Name='富平云商供应链管理有限公司'OR Channel_Category_Name='Vanguard'OR Channel_Category_Name='Kidswant' 
		--OR Channel_Category_Name='CenturyMart' 
		THEN 'KA' WHEN Channel_Type = 'CP' THEN 'CP' END
		HAVING ISNULL(SUM(ISNULL(Target_Amt_KRMB,Category_Target_Amt_KRMB)),0)>0
	)
	
,weeklytarget AS(
	SELECT dc.Year as Yearkey,dc.Week_Year_NBR,dc.Week_Date_Period,MAX(Date_ID) END_Date,Channel_Group,Channel,Item, max(MonthlyTarget)/max(md.days)*count(1) AS WeeklyTarget,SalesTerritory
	FROM monthlytarget mt
	JOIN [FU_EDW].[Dim_Calendar] AS dc with(nolock) ON mt.MonthKey = dc.Year_Month
	JOIN (SELECT Year_Month,count(1) days FROM [FU_EDW].[Dim_Calendar] with(nolock) GROUP BY Year_Month) md ON md.Year_Month = mt.MonthKey
	GROUP BY dc.Year,dc.Week_Year_NBR,dc.Week_Date_Period,Channel_Group,Channel,Item,SalesTerritory
	)
*/
GO
