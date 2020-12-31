USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_Sales_VG_MonthlyPerformance_Overview_new]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [rpt].[SP_RPT_Sales_VG_MonthlyPerformance_Overview_new]
AS BEGIN 
-------------------------------获取事实表中每个月最后一天
DROP  TABLE IF EXISTS #LastDay
SELECT LEFT(Datekey,6) AS YearMonth
	  ,MAX(Datekey) AS LastDay
	  INTO #LastDay
FROM dm.Fct_CRV_DailySales
GROUP BY LEFT(Datekey,6)

--------------------------获取每个月的销售额和每个月最后一天的销售额
DROP TABLE IF EXISTS #Dailysales 
SELECT   CASE WHEN ISNULL(ds.Store_Province,'') NOT IN ('天津市','陕西省','江西省','浙江省') THEN '其他' ELSE LEFT(ds.Store_Province,2) END AS Store_Province
		,LEFT(Datekey,6) AS [MonthKey]
		,COUNT(DISTINCT Datekey) AS Days_Cnt
		,SUM( Gross_Sale_Value) AS Sales_AMT
		,(SELECT SUM(Gross_Sale_Value) FROM dm.Fct_CRV_DailySales cds2 LEFT JOIN #LastDay ld ON LEFT(cds2.Datekey,6) = ld.YearMonth JOIN dm.Dim_Store ds2 ON ds2.Store_ID=cds2.Store_ID WHERE CASE WHEN ISNULL(ds.Store_Province,'') NOT IN ('天津市','陕西省','江西省','浙江省') THEN '其他' 
		 ELSE LEFT(ds.Store_Province,2) END =CASE WHEN ISNULL(ds2.Store_Province,'') NOT IN ('天津市','陕西省','江西省','浙江省') THEN '其他' 
		 ELSE LEFT(ds2.Store_Province,2) END AND cds2.Datekey = ld.LastDay AND LEFT(cds2.Datekey,6) = LEFT(cds.Datekey,6)) AS Sales_Amt_LD
INTO #DailySales
FROM dm.Fct_CRV_DailySales cds WITH(NOLOCK)
JOIN dm.Dim_Store ds ON ds.Store_ID=cds.Store_ID
WHERE ds.Channel_Account='Vanguard'
GROUP BY  CASE WHEN ISNULL(ds.Store_Province,'') NOT IN ('天津市','陕西省','江西省','浙江省') THEN '其他' 
	ELSE LEFT(ds.Store_Province,2) END
	,LEFT(Datekey,6)
	ORDER BY 1 DESC

DROP TABLE IF EXISTS #SalesTarget 
CREATE TABLE #SalesTarget(
           Store_Province Nvarchar(100),
           Sales_Target  decimal(18, 2),
		   Year_Month int)
 
INSERT #SalesTarget
SELECT'江西','128969.79','201908'UNION
SELECT'天津','187121.08','201908'UNION
SELECT'陕西','207849.05','201908'UNION
SELECT'浙江','175031.07','201908'UNION
SELECT'其他','0','201908'UNION
SELECT'江西','110545','201909'UNION
SELECT'天津','161332','201909'UNION
SELECT'陕西','178156','201909'UNION
SELECT'浙江','150027','201909'UNION
SELECT'其他','0','201909'



--------------------------获取每个月最后一天的库存
DROP TABLE IF EXISTS #DailyInventory
SELECT   LEFT(cdy.Datekey,6) YearMonth
		,CASE WHEN ISNULL(ds.Store_Province,'') NOT IN ('天津市','陕西省','江西省','浙江省') THEN '其他' ELSE LEFT(ds.Store_Province,2) END AS Store_Province
		,(SELECT SUM(CASE WHEN prod2.Product_Sort='Fresh' THEN cds2.Qty ELSE 0 END) FROM dm.Fct_CRV_DailyInventory cds2 LEFT JOIN dm.Dim_Product prod2 ON cds2.SKU_ID = prod2.SKU_ID LEFT JOIN #LastDay ld ON LEFT(cds2.Datekey,6) = ld.YearMonth JOIN dm.Dim_Store ds2 ON ds2.Store_ID=cds2.Store_ID WHERE CASE WHEN ISNULL(ds.Store_Province,'') NOT IN ('天津市','陕西省','江西省','浙江省') THEN '其他' 
			ELSE LEFT(ds.Store_Province,2) END =CASE WHEN ISNULL(ds2.Store_Province,'') NOT IN ('天津市','陕西省','江西省','浙江省') THEN '其他' 
			ELSE LEFT(ds2.Store_Province,2) END AND cds2.Datekey = ld.LastDay AND LEFT(cds2.Datekey,6) = LEFT(cdy.Datekey,6) ) AS Fresh_INV
		,(SELECT SUM(CASE WHEN prod2.Product_Sort='Ambient' THEN cds2.Qty ELSE 0 END) FROM dm.Fct_CRV_DailyInventory cds2 LEFT JOIN dm.Dim_Product prod2 ON cds2.SKU_ID = prod2.SKU_ID LEFT JOIN #LastDay ld ON LEFT(cds2.Datekey,6) = ld.YearMonth JOIN dm.Dim_Store ds2 ON ds2.Store_ID=cds2.Store_ID WHERE CASE WHEN ISNULL(ds.Store_Province,'') NOT IN ('天津市','陕西省','江西省','浙江省') THEN '其他' 
			ELSE LEFT(ds.Store_Province,2) END =CASE WHEN ISNULL(ds2.Store_Province,'') NOT IN ('天津市','陕西省','江西省','浙江省') THEN '其他' 
			ELSE LEFT(ds2.Store_Province,2) END AND cds2.Datekey = ld.LastDay AND LEFT(cds2.Datekey,6) = LEFT(cdy.Datekey,6) ) AS Ambient_INV
INTO #DailyInventory
FROM dm.Fct_CRV_DailyInventory cdy WITH(NOLOCK)
JOIN dm.Dim_Store ds WITH(NOLOCK) ON ds.Store_ID=cdy.Store_ID
JOIn dm.Dim_Product p WITH(NOLOCK) ON cdy.SKU_ID=p.SKU_ID
WHERE ds.Channel_Account='Vanguard' AND ds.Store_Province is NOT NULL
GROUP BY  CASE WHEN ISNULL(ds.Store_Province,'') NOT IN ('天津市','陕西省','江西省','浙江省') THEN '其他' 
	      ELSE LEFT(ds.Store_Province,2) END
		 ,LEFT(cdy.Datekey,6) order by YearMonth



	SELECT 
		 COALESCE(st.Year_Month,inv.YearMonth,dss.[MonthKey]) AS YearMonth
		,COALESCE(st.Store_Province,inv.Store_Province,dss.Store_Province,dsslm.Store_Province) AS Store_Province
		,st.Sales_Target AS Sales_Target  --本月指标
		,SUM(dss.Sales_AMT) AS TM_Sales  --本月销售
		,SUM(dsslm.Sales_AMT) AS LM_Sales	--上月销售
		,CASE WHEN SUM(dct.TMD)=0 THEN NULL ELSE (CAST((DATEPART(dd,CAST(CAST(MAX(ld.LastDay) AS VARCHAR) AS DATE)))AS decimal(20,10))/ MAX(dct.TMD)) END AS TimeBar  --时间进度    select CAST(20.1423141 as decimal(20,2))
		,CASE WHEN SUM(st.Sales_Target)=0 THEN (CAST('N/A' AS char)) ELSE (CAST(CAST((SUM(dss.Sales_AMT)/SUM(st.Sales_Target)*100)as decimal(20,1)) AS char)+'%')END AS Arch  --进度
		,CASE WHEN SUM(dsslm.Sales_AMT)/SUM(dsslm.Days_Cnt)=0 THEN NULL ELSE ((SUM(dss.Sales_AMT)/SUM(dss.Days_Cnt)) /(SUM(dsslm.Sales_AMT)/SUM(dsslm.Days_Cnt)) - 1) END AS Grouth  --日均增长
		,SUM(dss.Sales_Amt_LD ) AS Latest_AMT 
		,SUM(Fresh_INV) AS Fresh_INV
		,SUM(Ambient_INV) AS Ambient_INV
		,CAST(CAST(MAX(ld.LastDay) AS VARCHAR) AS DATE) AS Latest_Date
	FROM #DailyInventory inv
	LEFT JOIN #DailySales dss ON dss.[MonthKey]= inv.YearMonth AND inv.Store_Province = dss.Store_Province
	LEFT JOIN #DailySales dsslm ON dsslm.[MonthKey]+CASE WHEN dsslm.MonthKey%100=12 THEN 89 ELSE 1 END=inv.YearMonth AND inv.Store_Province = dsslm.Store_Province
    LEFT JOIN (SELECT Store_Province,Year_Month,SUM(Sales_Target) AS Sales_Target  FROM #SalesTarget GROUP BY Store_Province,Year_Month)st ON st.Store_Province=dss.Store_Province AND st.Year_Month=dss.MonthKey
	LEFT JOIN #LastDay ld ON inv.YearMonth = ld.YearMonth
    LEFT JOIN (SELECT Year_Month,COUNT(1) TMD FROM FU_EDW.Dim_Calendar WITH(NOLOCK) GROUP BY Year_Month)dct ON inv.YearMonth = dct.Year_Month
	WHERE COALESCE(st.Store_Province,inv.Store_Province,dss.Store_Province,dsslm.Store_Province)  IS NOT NULL
	GROUP BY
	     COALESCE(st.Year_Month,inv.YearMonth,dss.[MonthKey])
		,COALESCE(st.Store_Province,inv.Store_Province,dss.Store_Province,dsslm.Store_Province) 
		,st.Sales_Target

DROP TABLE IF EXISTS #Dailysales
	
END
GO
