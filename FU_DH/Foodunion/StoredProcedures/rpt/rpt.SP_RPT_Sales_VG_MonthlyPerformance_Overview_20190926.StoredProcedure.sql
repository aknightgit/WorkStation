USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_Sales_VG_MonthlyPerformance_Overview_20190926]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [rpt].[SP_RPT_Sales_VG_MonthlyPerformance_Overview_20190926]
AS BEGIN 

DROP  TABLE IF EXISTS #LastDay
SELECT LEFT(Datekey,6) AS YearMonth
	  ,MAX(Datekey) AS LastDay
	  INTO #LastDay
FROM dm.Fct_CRV_DailySales
GROUP BY LEFT(Datekey,6)


   DROP TABLE IF EXISTS #Dailysales 
SELECT  
		CASE WHEN ISNULL(ds.Store_Province,'') NOT IN ('天津市','陕西省','江西省','浙江省') THEN '其他' 
		ELSE LEFT(ds.Store_Province,2) END AS Store_Province
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
	--AND kds.Datekey BETWEEN 20190801 AND 20190831
    --AND cds.Datekey > CONVERT(VARCHAR(8),Dateadd("MM",-2,EOMONTH(getdate())),112)
	GROUP BY  CASE WHEN ISNULL(ds.Store_Province,'') NOT IN ('天津市','陕西省','江西省','浙江省') THEN '其他' 
		ELSE LEFT(ds.Store_Province,2) END
		,LEFT(Datekey,6)
		ORDER BY 1 DESC

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


	SELECT 
		st.Store_Province
		,st.Sales_Target AS Sales_Target  --本月指标
		,SUM(dss.Sales_AMT) AS TM_Sales  --本月销售
		,SUM(dsslm.Sales_AMT) AS LM_Sales	--上月销售
		--,MAX(tm.TM_Days_Cnt) AS TM_Days_Cnt
		--,MAX(dct.TMD) AS TM_Days_ALL
		--,MAX(lm.LM_Days_Cnt) AS LM_Days_Cnt
		--,SUM(tm.TM_Sales/tm.TM_Days_Cnt) AS TM_Avg
		--,SUM(lm.lM_Sales/lm.LM_Days_Cnt) AS LM_Avg
		--,DATEPART(dd,getdate()-1) 
		,CASE WHEN SUM(dct.TMD)=0 THEN NULL ELSE (CAST((DATEPART(dd,getdate()-1))AS decimal(20,10))/ MAX(dct.TMD)) END AS TimeBar  --时间进度    select CAST(20.1423141 as decimal(20,2))
		,CASE WHEN SUM(st.Sales_Target)=0 THEN (CAST('N/A' AS char)) ELSE (CAST(CAST((SUM(dss.Sales_AMT)/SUM(st.Sales_Target)*100)as decimal(20,1)) AS char)+'%')END AS Arch  --进度
		,CASE WHEN SUM(dsslm.Sales_AMT)/SUM(dsslm.Days_Cnt)=0 THEN NULL ELSE ((SUM(dss.Sales_AMT)/SUM(dss.Days_Cnt)) /(SUM(dsslm.Sales_AMT)/SUM(dsslm.Days_Cnt)) - 1) END AS Grouth  --日均增长
		,SUM(dss.Sales_Amt_LD ) AS Latest_AMT 
		,SUM(Fresh_INV) AS Fresh_INV
		,SUM(Ambient_INV) AS Ambient_INV
		,CAST(CAST(MAX(Latest_Date)AS varchar) AS DATE) AS Latest_Date
	

		--SELECT *
	FROM (SELECT CASE WHEN ds.Store_Province  NOT IN ('天津市','陕西省','江西省','浙江省') THEN '其他'
      ELSE LEFT(ds.Store_Province,2) END AS Store_Province
      ,SUM(CASE WHEN p.Product_Sort='Fresh' THEN cdy.Qty ELSE 0 END) AS Fresh_INV
      ,SUM(CASE WHEN p.Product_Sort='Ambient' THEN cdy.Qty ELSE 0 END) AS Ambient_INV
     ,MAX(Datekey) AS Latest_Date
	FROM dm.Fct_CRV_DailyInventory cdy WITH(NOLOCK)
    JOIN dm.Dim_Store ds WITH(NOLOCK) ON ds.Store_ID=cdy.Store_ID
    JOIn dm.Dim_Product p WITH(NOLOCK) ON cdy.SKU_ID=p.SKU_ID
    WHERE ds.Channel_Account='Vanguard' AND ds.Store_Province is NOT NULL
    AND Datekey=(SELECT MAX(Datekey) FROM dm.Fct_CRV_DailyInventory WITH(NOLOCK))
    GROUP BY  CASE WHEN ds.Store_Province  NOT IN ('天津市','陕西省','江西省','浙江省') THEN '其他'
    ELSE LEFT(ds.Store_Province,2) END)tex
	LEFT JOIN #DailySales dss ON dss.[MonthKey]= LEFT(tex.Latest_Date,6) AND tex.Store_Province = dss.Store_Province
	LEFT JOIN #DailySales dsslm ON dsslm.[MonthKey]+CASE WHEN dsslm.MonthKey%100=12 THEN 89 ELSE 1 END=LEFT(tex.Latest_Date,6) AND tex.Store_Province = dsslm.Store_Province
    LEFT JOIN (SELECT Store_Province,Year_Month,SUM(Sales_Target) AS Sales_Target  FROM #SalesTarget GROUP BY Store_Province,Year_Month)st ON st.Store_Province=dss.Store_Province AND st.Year_Month=dss.MonthKey
    LEFT JOIN (SELECT COUNT(1) TMD FROM FU_EDW.Dim_Calendar WITH(NOLOCK) WHERE Year_Month=CONVERT(VARCHAR(6),GETDATE(),112))dct ON 1=1
	WHERE st.Store_Province IS NOT NULL
	GROUP BY st.Store_Province
		,st.Sales_Target

DROP TABLE IF EXISTS #Dailysales
	
END
GO
