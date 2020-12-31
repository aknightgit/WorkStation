USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [rpt].[SP_RPT_Sales_YH_MonthlyPerformance_Overview]
AS BEGIN 


-----------------获取事实表中每个月最后一天
DROP  TABLE IF EXISTS #LastDay;
SELECT LEFT(Datekey,6) AS YearMonth
	  ,MAX(Datekey) AS LastDay
	  INTO #LastDay
FROM dm.Fct_KAStore_DailySalesInventory
WHERE Store_ID LIKE 'YH%'
AND Datekey<>CONVERT(VARCHAR(8),GETDATE(),112)
GROUP BY LEFT(Datekey,6)


-----------------区域Mapping， 每个月的mapping会有变动
DROP TABLE IF EXISTS #AreaMapping;
SELECT *, ROW_NUMBER() OVER(Partition by Monthkey,SalesTerritory,Area ORDER BY Store_Province) rid
INTO #AreaMapping
FROM (
	SELECT DISTINCT bk.Monthkey,stm.[Region] AS SalesTerritory,bk.Area,ds.Store_Province
	--,bk.TargetAmt
	FROM [dm].[Fct_Sales_SellOutTarget_ByKAarea] bk
	LEFT JOIN (SELECT DISTINCT Store_Province,Sales_Area_CN 
		FROM dm.Dim_Store WHERE Channel_Account='YH')ds ON ds.Sales_Area_CN=bk.Area 
	LEFT JOIN (SELECT * FROM [dm].[Dim_SalesTerritory_Mapping_Monthly] WHERE [Monthkey]=(SELECT MAX([Monthkey]) FROM [dm].[Dim_SalesTerritory_Mapping_Monthly]) AND [Channel]='YH') stm 
	ON ds.Store_Province LIKE '%'+stm.Province_Short+'%'
	WHERE bk.KA='YH'
	UNION
	SELECT 201912,'北区','北京','天津市'		--12月之前，天津还属于北京大区
)x
--SELECT * FROM #AreaMapping

-----------------Target
DROP TABLE IF EXISTS #Target
SELECT kds.Monthkey
	  ,kds.SalesTerritory
	  --,ISNULL(ds.Sales_Area_CN,'其他') AS Area
	  ,CASE WHEN kds.Monthkey<=201911 AND kds.Area IN ('重庆大区','四川大区','北京大区','福建大区','华东大区','安徽大区','陕西大区','东北大区') THEN LEFT(kds.Area,2)
			WHEN kds.Monthkey>201911 THEN kds.Area ELSE '其他' END AS Area
	  ,ISNULL(ds.Store_Province,m.Store_Province) AS Province
	  ,SUM(kds.Sales_Target *(CASE ISNULL(m.rid,1) WHEN 1 THEN 1 ELSE 0 END)) AS Sales_Target
INTO #Target
FROM [dm].[Fct_KAStore_SalesTarget_Monthly] kds WITH(NOLOCK)
LEFT JOIN [dm].[Dim_Store] ds WITH(NOLOCK) ON ds.Store_ID=kds.Store_ID
--LEFT JOIN [dm].[Dim_SalesTerritoryMapping] stm on ds.Store_Province like '%'+stm.province_Short+'%'
LEFT JOIN #AreaMapping m ON kds.Monthkey=m.Monthkey AND kds.SalesTerritory=m.SalesTerritory AND kds.Area=m.Area
WHERE kds.Channel='YH'
GROUP BY
		kds.Monthkey
	    ,kds.SalesTerritory 
		,CASE WHEN kds.Monthkey<=201911 AND kds.Area IN ('重庆大区','四川大区','北京大区','福建大区','华东大区','安徽大区','陕西大区','东北大区') THEN LEFT(kds.Area,2)
			WHEN kds.Monthkey>201911 THEN kds.Area ELSE '其他' END
	   ,ISNULL(ds.Store_Province,m.Store_Province)
ORDER BY 1,2

--SELECT * FROM #Target ORDER BY 1,2		

-----------------Actual Sales
DROP TABLE IF EXISTS #monthlysales;

SELECT 
	kds.Datekey/100 AS Monthkey,
	stm.[Region] AS SalesTerritory,
	ds.Store_Province,
	SUM(kds.Sales_AMT) AS Sales_AMT,
	MAX(d.Days_Cnt) AS Days_Cnt,
	MAX(d.Latest_Date) AS Latest_Date,
	MAX(l.Sales_AMT) AS Latest_AMT,
	MAX(inv.Ambient_Qty) AS Ambient_Qty,
	MAX(inv.Fresh_Qty) AS Fresh_Qty
INTO #monthlysales
FROM [dm].[Fct_KAStore_DailySalesInventory] kds WITH(NOLOCK)
JOIN [dm].[Dim_Store] ds ON kds.Store_ID=ds.Store_ID
LEFT JOIN (SELECT * FROM [dm].[Dim_SalesTerritory_Mapping_Monthly] WHERE [Monthkey]=(SELECT MAX([Monthkey]) FROM [dm].[Dim_SalesTerritory_Mapping_Monthly]) AND [Channel]='YH') stm 
on ds.Store_Province like '%'+stm.province_Short+'%'
LEFT JOIN (SELECT 
	kds.Datekey/100 AS Monthkey,
	COUNT(DISTINCT kds.Datekey) AS Days_Cnt,
	MAX(kds.Datekey) AS Latest_Date
	FROM [dm].[Fct_KAStore_DailySalesInventory] kds WITH(NOLOCK)
	JOIN [dm].[Dim_Store] ds ON kds.Store_ID=ds.Store_ID
	WHERE ds.Channel_Account='YH'
	GROUP BY kds.Datekey/100
	)d ON kds.Datekey/100=d.Monthkey
LEFT JOIN (
	SELECT Datekey,ds.Store_Province,SUM(Sales_AMT) AS Sales_AMT
	FROM [dm].[Fct_KAStore_DailySalesInventory] kds WITH(NOLOCK)
	JOIN [dm].[Dim_Store] ds ON kds.Store_ID=ds.Store_ID
	WHERE ds.Channel_Account='YH'
	GROUP BY Datekey,ds.Store_Province
	)l ON d.Latest_Date=l.Datekey AND ds.Store_Province=l.Store_Province
LEFT JOIN (
	SELECT Datekey,ds.Store_Province
		,SUM(CASE p.Product_Sort WHEN 'Ambient' THEN kds.Inventory_Qty ELSE 0 END) AS Ambient_Qty
		,SUM(CASE p.Product_Sort WHEN 'Fresh' THEN kds.Inventory_Qty ELSE 0 END) AS Fresh_Qty
	FROM [dm].[Fct_KAStore_DailySalesInventory] kds WITH(NOLOCK)
	JOIN [dm].[Dim_Store] ds ON kds.Store_ID=ds.Store_ID
	JOIN [dm].[Dim_Product] p ON kds.SKU_ID=p.SKU_ID
 	WHERE ds.Channel_Account='YH'
	GROUP BY Datekey,ds.Store_Province
	)inv ON d.Latest_Date=inv.Datekey AND ds.Store_Province=inv.Store_Province
WHERE ds.Channel_Account='YH'
GROUP BY kds.Datekey/100 ,
	stm.[Region],
	ds.Store_Province

--增加列：库存门店数量   Justin 2020-03-30

SELECT DATEKEY,Store_Province,SUM(CASE WHEN CONT=0 THEN 0 ELSE 1 END ) SC   into #StoreCount
FROM (
SELECT LEFT(KDS.[update_time],8) AS DATEKEY,KDS.[shop_id],DS.Store_Province,SUM(CASE WHEN CAST(INV_QTY AS FLOAT)=0 THEN 0 ELSE 1 END) CONT FROM   [ODS].[ods].[EDI_YH_Inventory] KDS WITH(NOLOCK)          
			JOIN [dm].[Dim_Store] ds ON kds.[shop_id]=ds.Account_Store_Code		
 			WHERE ds.Channel_Account='YH' 
			AND LEFT(KDS.[update_time],8)= CONVERT(VARCHAR(10),DATEADD(DAY,-1,GETDATE()),112)
			GROUP BY LEFT(KDS.[update_time],8),KDS.[shop_id],Store_Province,Account_Store_Code) S
GROUP BY  DATEKEY,Store_Province

 --计算进货指标和进货达成
 DROP TABLE IF EXISTS #SellIn;
 SELECT Datekey,SalesTerritory,Sales_Area_CN,SUM(Amount) AS Amount,SUM(TARGET) AS Target  INTO #SellIn
FROM (
	select LEFT(jxt.Datekey,6) AS Datekey,SalesTerritory,A.Account_Area_CN Sales_Area_CN,SUM(jxt.InStock_QTY * pl.SKU_Price) as Amount,0 AS TARGET
	from dm.Fct_YH_JXT_Daily jxt
	join dm.Dim_Product p on jxt.SKU_ID=p.SKU_ID
	join dm.Dim_Store s on jxt.Store_ID=s.Store_ID
	left join dm.Dim_Product_Pricelist pl on p.SKU_ID=pl.SKU_ID and pl.Price_List_No=
		(select MAX(Price_List_No) from dm.Dim_ERP_CustomerList where Customer_Name like '%富平%' and IsActive=1)
	LEFT JOIN (SELECT DISTINCT ISNULL(t.Monthkey,tm.Monthkey) AS YearMonth,
					ISNULL(t.SalesTerritory,tm.SalesTerritory) AS SalesTerritory,
					ISNULL(t.Area,'其他') AS Account_Area_CN,
					ISNULL(t.Province,tm.Store_Province) AS Province
				FROM #Target t
				FULL OUTER JOIN #monthlysales tm ON t.Monthkey=tm.Monthkey 
					AND tm.Store_Province=t.Province AND tm.SalesTerritory=t.SalesTerritory ) A  --保持与#Target 表 的Area 一致
	ON S.Store_Province=A.Province AND LEFT(JXT.Datekey,6)=A.YearMonth
	 group by  LEFT(jxt.Datekey,6) ,SalesTerritory,A.Account_Area_CN
 UNION
 SELECT MONTHKEY,SalesTerritory,AREA,0,CAST(TargetAmt AS FLOAT) AS TARGET 
 FROM [dm].[Fct_Sales_SellInTarget_ByKAarea] ST
 LEFT JOIN (SELECT DISTINCT ISNULL(t.Monthkey,tm.Monthkey) AS YearMonth,
					ISNULL(t.SalesTerritory,tm.SalesTerritory) AS SalesTerritory,
					ISNULL(t.Area,'其他') AS Account_Area_CN					 
				FROM #Target t
				FULL OUTER JOIN #monthlysales tm ON t.Monthkey=tm.Monthkey 
					AND tm.Store_Province=t.Province AND tm.SalesTerritory=t.SalesTerritory ) A  --保持与#Target 表 的Area 一致
 ON ST.Area=A.Account_Area_CN AND ST.MONTHKEY=A.YearMonth
 WHERE [KA]='YH' AND TargetAmt IS NOT NULL
 ) T
 GROUP BY Datekey,Sales_Area_CN,SalesTerritory


-----------------根据省份计算销量
SELECT ISNULL(t.Monthkey,tm.Monthkey) AS YearMonth,
	ISNULL(t.SalesTerritory,tm.SalesTerritory) AS SalesTerritory,
	ISNULL(t.Area,'其他') AS Account_Area_CN,
	--ISNULL(t.Province,tm.Store_Province) AS Province,
	SUM(t.Sales_Target) AS Sales_Target, --本月指标
	SUM(lm.Sales_AMT) AS LM_Sales, --上月销售
	SUM(tm.Sales_AMT) AS TM_Sales, --本月销售
	CASE WHEN SUM(dct.TMD)=0 THEN NULL 
		ELSE (CAST((DATEPART(dd,CAST(CAST(MAX(tm.Latest_Date) AS VARCHAR) AS DATE))) AS decimal(20,10))/MAX(dct.TMD)) 
		END AS TimeBar,  --时间进度
	CASE WHEN SUM(t.Sales_Target)>0 THEN MAX(tm.Sales_AMT)/SUM(t.Sales_Target) ELSE NULL END AS Arch,  --进度
	MAX(CASE WHEN tm.Days_Cnt * tm.Days_Cnt * lm.Sales_AMT = 0 THEN NULL 
		ELSE (tm.Sales_AMT/tm.Days_Cnt) / (lm.Sales_AMT/lm.Days_Cnt) 
		END - 1) AS Grouth,  --日均增长
	MAX(tm.Days_Cnt) AS Days_Cnt,
	MAX(lm.Days_Cnt) AS Days_Cnt_lm,
	CAST(CAST(MAX(tm.Latest_Date)AS varchar) AS DATE) AS Latest_Date,
	SUM(tm.Latest_AMT) AS Latest_AMT,
	SUM(tm.Fresh_Qty) AS Fresh_INV,
	SUM(tm.Ambient_Qty) AS Ambient_INV,
	SUM(SC.SC) AS StoreCount  INTO #SellOut
FROM #Target t
FULL OUTER JOIN #monthlysales tm ON t.Monthkey=tm.Monthkey 
	AND tm.Store_Province=t.Province AND tm.SalesTerritory=t.SalesTerritory
LEFT JOIN #monthlysales lm ON ISNULL(t.Monthkey,tm.Monthkey)=lm.Monthkey + CASE WHEN RIGHT(lm.Monthkey,2) = 12 THEN 89 ELSE 1 END
	AND lm.Store_Province=ISNULL(t.Province,tm.Store_Province) 
	AND lm.SalesTerritory=ISNULL(t.SalesTerritory,tm.SalesTerritory)
LEFT JOIN (SELECT Monthkey,COUNT(1) TMD 
	FROM dm.Dim_Calendar WITH(NOLOCK) GROUP BY Monthkey
	)dct ON ISNULL(t.Monthkey,tm.Monthkey) = dct.Monthkey
LEFT JOIN #StoreCount AS SC ON tm.Store_Province=SC.Store_Province
GROUP BY ISNULL(t.Monthkey,tm.Monthkey),
	ISNULL(t.SalesTerritory,tm.SalesTerritory),
	ISNULL(t.Area,'其他')
HAVING(ISNULL(t.SalesTerritory,tm.SalesTerritory) IS NOT NULL)
	ORDER BY 1,2,3

SELECT YearMonth,
       SalesTerritory,
	   Account_Area_CN,
	   SUM(Sales_Target) AS Sales_Target , --本月指标
	   SUM(LM_Sales) AS LM_Sales, --上月销售
	   SUM(TM_Sales) AS TM_Sales, --本月销售
	   SUM(TimeBar) AS TimeBar,  --时间进度
	   SUM(Arch) AS Arch,  --进度
	   SUM(Grouth) AS Grouth,  --日均增长
	   SUM(Days_Cnt) AS Days_Cnt,
	   SUM(Days_Cnt_lm) AS Days_Cnt_lm,
	   MAX(Latest_Date) AS Latest_Date,
	   SUM(Latest_AMT) AS Latest_AMT,
	   SUM(Fresh_INV) AS Fresh_INV,
	   SUM(Ambient_INV) AS Ambient_INV,
	   SUM(StoreCount) AS StoreCount,
	   SUM(SellIn_Amount) AS SellIn_Amount,
	   SUM(SellIn_Target) AS SellIn_Target,
	   SUM(Arch_SellIn) AS Arch_SellIn   
	   FROM(
SELECT YearMonth,
       SalesTerritory,
	   Account_Area_CN,
	   Sales_Target, --本月指标
	   LM_Sales, --上月销售
	   TM_Sales, --本月销售
	   TimeBar,  --时间进度
	   Arch,  --进度
	   Grouth,  --日均增长
	   Days_Cnt,
	   Days_Cnt_lm,
	   Latest_Date,
	   Latest_AMT,
	   Fresh_INV,
	   Ambient_INV,
	   StoreCount,
	   0 AS SellIn_Amount,
	   0 AS SellIn_Target,
	   0 AS Arch_SellIn
FROM #SellOut AS SO
UNION
SELECT  Datekey,
        SalesTerritory,
		Sales_Area_CN,
		0 Sales_Target, --本月指标
	   0 LM_Sales, --上月销售
	   0 TM_Sales, --本月销售
	   0 TimeBar,  --时间进度
	   0 Arch,  --进度
	   0 Grouth,  --日均增长
	   0 Days_Cnt,
	   0 Days_Cnt_lm,
	   NULL Latest_Date,
	   0 Latest_AMT,
	   0 Fresh_INV,
	   0 Ambient_INV,
	   0 StoreCount,
       SI.Amount SellIn_Amount,
	   SI.Target AS SellIn_Target,
	   CASE WHEN ISNULL(SI.Target,0)=0 THEN 0 ELSE SI.Amount/SI.Target END Arch_SellIn FROM  #SellIn AS SI) F
GROUP BY YearMonth,
       SalesTerritory,
	   Account_Area_CN
 

END

/*
-------------------------------把dm.Fct_KAStore_DailySalesInventory和Account_Area_CN关联
DROP TABLE IF EXISTS #Fct_KAStore_DailySalesInventory
SELECT CASE WHEN  ds.Account_Area_CN NOT IN ('重庆大区','四川大区','北京大区','福建大区','华东大区','安徽大区','陕西大区','东北大区')
	         AND LEFT(kds.Datekey,6)<'201912'  THEN '其他' 
			 WHEN LEFT(kds.Datekey,6)<'201912' THEN LEFT(ds.Account_Area_CN,2) 
			 WHEN ds.Account_Area_CN = '东北大区' THEN '东北' 
			 --WHEN ds.Account_Area_CN in ('天津大区','河北大区') THEN '津冀' 
			 WHEN ds.Account_Area_CN = '北京大区' THEN '北京'  
			 WHEN  LEFT(kds.Datekey,6)>='201912' THEN ISNULL(bk.Area,'其他') ELSE '其他' END  AS Account_Area_CN
		,kds.Datekey
		,kds.Store_ID
		,stm.SalesTerritory
		,ds.Channel_Account
		,kds.Sales_AMT
		,kds.Inventory_Qty
		,prod.Product_Sort
INTO #Fct_KAStore_DailySalesInventory
FROM dm.Fct_KAStore_DailySalesInventory kds WITH(NOLOCK)
JOIN dm.Dim_Store ds ON ds.Store_ID=kds.Store_ID
LEFT JOIN dm.Dim_Product prod ON kds.SKU_ID = prod.SKU_ID
LEFT JOIN [dm].[Dim_SalesTerritoryMapping] stm on ds.Store_Province like '%'+stm.province_Short+'%'
LEFT JOIN dm.Fct_Sales_SellOutTarget_ByKAarea bk ON bk.KA = 'YH' AND bk.Monthkey = LEFT(kds.Datekey,6) AND ds.Store_Province LIKE '%'+bk.Area+'%'


 --------------------------Monthly sales
DROP TABLE IF EXISTS #dailysales;
SELECT
	 SalesTerritory
	,Account_Area_CN
	,LEFT(Datekey,6) AS MonthKey
	,COUNT(DISTINCT Datekey) AS Days_Cnt
	,(SELECT SUM(cds2.Sales_AMT) 
		FROM #Fct_KAStore_DailySalesInventory cds2 
		LEFT JOIN #LastDay ld ON LEFT(cds2.Datekey,6) = ld.YearMonth 
		WHERE cds2.Channel_Account='YH'  AND kds.SalesTerritory = cds2.SalesTerritory AND kds.Account_Area_CN=cds2.Account_Area_CN
		AND cds2.Datekey = ld.LastDay AND LEFT(cds2.Datekey,6) = LEFT(kds.Datekey,6)
	 ) AS Sales_Amt_LD
	,SUM(Sales_AMT) AS Sales_AMT
INTO #dailysales
FROM #Fct_KAStore_DailySalesInventory kds
WHERE Channel_Account='YH'
GROUP BY  Account_Area_CN
	     ,LEFT(Datekey,6)
		 ,SalesTerritory

 --------------------------Last Monthly sales
  --bk.[MonthKey]-CASE WHEN bk.MonthKey%100=1 THEN 89 ELSE 1 END= LEFT(kds.Datekey,6)
DROP TABLE IF EXISTS #dailysales_LM;
SELECT
	 SalesTerritory
	,Account_Area_CN
	,LEFT(kds.Datekey,6)+CASE WHEN LEFT(kds.Datekey,6) = 12 THEN 89 ELSE 1 END AS MonthKey
	,COUNT(DISTINCT Datekey) AS Days_Cnt
	,(SELECT SUM(cds2.Sales_AMT) 
		FROM #Fct_KAStore_DailySalesInventory cds2
		LEFT JOIN #LastDay ld ON LEFT(cds2.Datekey,6) = ld.YearMonth 
		WHERE cds2.Channel_Account='YH'  AND kds.SalesTerritory = cds2.SalesTerritory
		AND kds.Account_Area_CN=cds2.Account_Area_CN AND cds2.Datekey = ld.LastDay 
		AND LEFT(kds.Datekey,6) = LEFT(cds2.Datekey,6)) AS Sales_Amt_LD
	,SUM(Sales_AMT) AS Sales_AMT
INTO #dailysales_LM
FROM #Fct_KAStore_DailySalesInventory kds
WHERE Channel_Account='YH'
GROUP BY Account_Area_CN
	     ,LEFT(kds.Datekey,6)
		 ,SalesTerritory
SELECT * FROM [dm].[Fct_KAStore_SalesTarget_Monthly] kds WITH(NOLOCK) ORDER BY 1,2
		

		
 --------------------------获取每个月最后一天的库存
DROP TABLE IF EXISTS #Inventory
SELECT  
	 SalesTerritory
	,Account_Area_CN
	 ,LEFT(kds.Datekey,6) AS MonthKey
	,COUNT(DISTINCT Datekey) AS Days_Cnt
	,(SELECT SUM(CASE WHEN cds2.Product_Sort='Ambient' THEN cds2.Inventory_Qty ELSE 0 END) 
		FROM #Fct_KAStore_DailySalesInventory cds2 
		LEFT JOIN #LastDay ld ON LEFT(cds2.Datekey,6) = ld.YearMonth 
	    WHERE cds2.Channel_Account='YH' AND cds2.SalesTerritory = kds.SalesTerritory
	     AND kds.Account_Area_CN=cds2.Account_Area_CN
		AND cds2.Datekey = ld.LastDay AND LEFT(cds2.Datekey,6) = LEFT(kds.Datekey,6)) AS Ambient_INV
	,(SELECT SUM(CASE WHEN cds2.Product_Sort='Fresh' THEN cds2.Inventory_Qty ELSE 0 END) 
		FROM #Fct_KAStore_DailySalesInventory cds2 
		LEFT JOIN #LastDay ld ON LEFT(cds2.Datekey,6) = ld.YearMonth 
	    WHERE cds2.Channel_Account='YH' AND cds2.SalesTerritory = kds.SalesTerritory
	     AND kds.Account_Area_CN=cds2.Account_Area_CN
		AND cds2.Datekey = ld.LastDay AND LEFT(cds2.Datekey,6) = LEFT(kds.Datekey,6)) AS Fresh_INV
INTO #Inventory
FROM #Fct_KAStore_DailySalesInventory kds WITH(NOLOCK)
WHERE Channel_Account='YH'
GROUP BY  Account_Area_CN
	     ,LEFT(kds.Datekey,6)
	     ,SalesTerritory
		 order by MonthKey



SELECT 
		 ISNULL(tar.Monthkey,ds.MonthKey)  AS Yearmonth
		,CASE WHEN ISNULL(tar.Account_Area_CN,ds.Account_Area_CN) = '其他' AND ISNULL(tar.SalesTerritory,ds.SalesTerritory) IS NULL THEN '其他大区' ELSE ISNULL(tar.SalesTerritory,ds.SalesTerritory) END AS SalesTerritory
		,ISNULL(tar.Account_Area_CN,ds.Account_Area_CN) AS Account_Area_CN
		,SUM(tar.Sales_Target) AS Sales_Target  --本月指标
		,SUM(lm.Sales_AMT) AS LM_Sales  --本月销售
		,SUM(ds.Sales_AMT) AS TM_Sales	--上月销售
		,CASE WHEN SUM(dct.TMD)=0 THEN NULL ELSE (CAST((DATEPART(dd,CAST(CAST(MAX(ld.LastDay) AS VARCHAR) AS DATE)))AS decimal(20,10))/ MAX(dct.TMD)) END AS TimeBar  --时间进度
		,CASE WHEN SUM(tar.Sales_Target)>0 THEN MAX(ds.Sales_AMT)/SUM(tar.Sales_Target) ELSE NULL END AS Arch  --进度
		,MAX(CASE WHEN ds.Days_Cnt =0 OR lm.Days_Cnt = 0 OR lm.Sales_AMT = 0 THEN NULL ELSE (ds.Sales_AMT/ds.Days_Cnt) / (lm.Sales_AMT/lm.Days_Cnt) END - 1) AS Grouth  --日均增长
		,MAX(ds.Days_Cnt) AS Days_Cnt
		,MAX(lm.Days_Cnt) AS Days_Cnt_lm
		,SUM(ds.Sales_Amt_LD) AS Latest_AMT
		,SUM(Fresh_INV) AS Fresh_INV
		,SUM(Ambient_INV) AS Ambient_INV
		,CAST(CAST(MAX(ld.LastDay)AS varchar) AS DATE) AS Latest_Date
		--SELECT *
	FROM #Target AS tar--本月指标
	FULL OUTER JOIN #dailysales ds ON ds.Account_Area_CN=tar.Account_Area_CN AND ds.MonthKey = tar.Monthkey AND tar.SalesTerritory = ds.SalesTerritory
	LEFT JOIN #dailysales_LM lm ON lm.[MonthKey]=ISNULL(tar.Monthkey,ds.MonthKey) AND ISNULL(tar.Account_Area_CN,ds.Account_Area_CN) = lm.Account_Area_CN AND ISNULL(tar.SalesTerritory,ds.SalesTerritory) = lm.SalesTerritory
	LEFT JOIN (SELECT Year_Month,COUNT(1) TMD FROM FU_EDW.Dim_Calendar WITH(NOLOCK) GROUP BY Year_Month)dct ON ISNULL(tar.Monthkey,ds.MonthKey) = dct.Year_Month
	LEFT JOIN #Inventory inv ON inv.MonthKey=ISNULL(tar.Monthkey,ds.MonthKey) AND inv.Account_Area_CN = ISNULL(tar.Account_Area_CN,ds.Account_Area_CN) AND ISNULL(tar.SalesTerritory,ds.SalesTerritory) = inv.SalesTerritory
	LEFT JOIN #LastDay ld ON ISNULL(tar.Monthkey,ds.MonthKey) = ld.YearMonth
	WHERE ISNULL(tar.Account_Area_CN,ds.Account_Area_CN) IS NOT NULL
	GROUP BY ISNULL(tar.Account_Area_CN,ds.Account_Area_CN)
		,ISNULL(tar.Monthkey,ds.MonthKey)
		,CASE WHEN ISNULL(tar.Account_Area_CN,ds.Account_Area_CN) = '其他' AND ISNULL(tar.SalesTerritory,ds.SalesTerritory) IS NULL THEN '其他大区' ELSE ISNULL(tar.SalesTerritory,ds.SalesTerritory) END

END

*/
GO
