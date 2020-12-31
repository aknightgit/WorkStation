USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_SOP_Forecast_Weekly]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [rpt].[SP_RPT_SOP_Forecast_Weekly]
AS
BEGIN

-------------------------------YH	获得每个城市 每个sku最早销售时间
DROP TABLE IF EXISTS #YH_Sales_Lim
SELECT SKU_ID
	  ,st.Store_City
	  ,st.Store_Province
	  ,MIN(Calendar_DT) AS Date_MIN
INTO #YH_Sales_Lim
FROM [dm].Fct_YH_Sales_Inventory sal
LEFT JOIN dm.Dim_Store st ON sal.Store_ID = st.Store_ID
WHERE sal.Inventory_AMT>0 OR sal.Inventory_AMT>0
GROUP BY SKU_ID
	  ,st.Store_City
	  ,st.Store_Province
----------------------------------------YH SOP
DROP TABLE IF EXISTS #YH_SOP
SELECT cal.Week_ID
	  ,cal.Week_Year_NBR
	  ,cal.[year]
	  ,st.Store_City
	  ,st.Store_Province
	  ,prod.SKU_ID
	  ,SUM(sal.Sales_AMT		) AS Sales_AMT
	  ,SUM(sal.sales_QTY		) AS sales_QTY
	  ,SUM(salM3W.Sales_AMT_M3W	) AS Sales_AMT_M3W
	  ,SUM(salM3W.sales_QTY_M3W	) AS sales_QTY_M3W
	  ,SUM(sal.DiscountSales_AMT) AS DiscountSales_AMT
	  ,SUM(sal.DiscountSales_QTY) AS DiscountSales_QTY
	  ,SUM(sal.END_Inventory_AMT) AS END_Inventory_AMT
	  ,SUM(sal.END_Inventory_QTY) AS END_Inventory_QTY
INTO #YH_SOP
FROM (SELECT DISTINCT CONVERT(VARCHAR(8),CAST(LEFT(Week_Date_Period,10) AS DATE),112) AS Week_ID,Week_Year_NBR,[year] FROM FU_EDW.Dim_Calendar) cal
CROSS JOIN (SELECT DISTINCT Store_City,Store_Province FROM dm.Dim_Store) st
CROSS JOIN dm.Dim_Product prod
INNER JOIN #YH_Sales_Lim sl ON st.Store_City = sl.Store_City AND sl.SKU_ID = prod.SKU_ID AND cal.Week_ID>=sl.Date_MIN AND st.Store_Province = sl.Store_Province
LEFT JOIN 
(
SELECT st.Store_City
	  ,st.Store_Province
	  ,CONVERT(VARCHAR(8),CAST(LEFT(cal.Week_Date_Period,10) AS DATE),112) AS Week_ID
	  ,si.SKU_ID
	  ,SUM(si.Sales_AMT) AS Sales_AMT
	  ,SUM(si.Sales_QTY) AS sales_QTY
	  ,SUM(si.DiscountSales_AMT) AS DiscountSales_AMT
	  ,SUM(si.DiscountSales_QTY) AS DiscountSales_QTY
	  ,(SELECT SUM(Inventory_AMT) FROM [dm].Fct_YH_Sales_Inventory si2 LEFT JOIN dm.Dim_Store st2 ON si2.Store_ID = st2.Store_ID WHERE st.Store_City = st2.Store_City AND st.Store_Province = st2.Store_Province AND si.SKU_ID = si2.SKU_ID AND si2.Calendar_DT = CONVERT(VARCHAR(8),CAST(cal.Week_Date_Period_End AS DATE),112)) AS END_Inventory_AMT
	  ,(SELECT SUM(Inventory_QTY) FROM [dm].Fct_YH_Sales_Inventory si3 LEFT JOIN dm.Dim_Store st3 ON si3.Store_ID = st3.Store_ID WHERE st.Store_City = st3.Store_City AND st.Store_Province = st3.Store_Province AND si.SKU_ID = si3.SKU_ID AND si3.Calendar_DT = CONVERT(VARCHAR(8),CAST(cal.Week_Date_Period_End AS DATE),112)) AS END_Inventory_QTY
FROM [dm].Fct_YH_Sales_Inventory si
LEFT JOIN dm.Dim_Store st ON si.Store_ID = st.Store_ID
LEFT JOIN FU_EDW.Dim_Calendar cal ON si.Calendar_DT = cal.Date_ID
GROUP BY st.Store_City
		,st.Store_Province
	    ,LEFT(cal.Week_Date_Period,10)
		,cal.Week_Date_Period_End
		,si.SKU_ID
) sal 
ON cal.Week_ID = sal.Week_ID AND sal.Store_City = st.Store_City AND sal.SKU_ID = prod.SKU_ID AND sal.Store_Province = st.Store_Province
LEFT JOIN 
(
SELECT st.Store_City
	  ,st.Store_Province
	  ,CONVERT(VARCHAR(8),CAST(LEFT(cal.Week_Date_Period,10) AS DATE),112) AS Week_ID
	-- ,cal.Date_ID
	  ,si.SKU_ID
	  ,SUM(si.Sales_AMT) AS Sales_AMT_M3W
	  ,SUM(si.Sales_QTY) AS sales_QTY_M3W
	  --,SUM(si.DiscountSales_AMT) AS DiscountSales_AMT
	  --,SUM(si.DiscountSales_QTY) AS DiscountSales_QTY

FROM [dm].Fct_YH_Sales_Inventory si
LEFT JOIN dm.Dim_Store st ON si.Store_ID = st.Store_ID
LEFT JOIN FU_EDW.Dim_Calendar cal ON si.Calendar_DT<= cal.Date_ID AND si.Calendar_DT>CONVERT(VARCHAR(8),DATEADD(DAY,-21,cal.Date_NM),112)
INNER JOIN (SELECT DISTINCT CONVERT(VARCHAR(8),CAST(Week_Date_Period_End AS DATE),112) AS WeekEnd FROM FU_EDW.Dim_Calendar) calll ON cal.Date_ID = calll.WeekEnd
--where CONVERT(VARCHAR(8),CAST(LEFT(cal.Week_Date_Period,10) AS DATE),112) between 20190204 and 20190225 and Store_City = '广元市' and SKU_ID = '1172004'
GROUP BY st.Store_City
		,st.Store_Province
	    ,LEFT(cal.Week_Date_Period,10)
	 --   ,cal.Date_ID
		,si.SKU_ID 
) salM3W
ON cal.Week_ID = salM3W.Week_ID AND salM3W.Store_City = st.Store_City AND salM3W.SKU_ID = prod.SKU_ID AND salM3W.Store_Province = st.Store_Province
WHERE COALESCE(
	  sal.Sales_AMT
	  ,sal.sales_QTY
	  ,salM3W.Sales_AMT_M3W
	  ,salM3W.sales_QTY_M3W
	  ,sal.DiscountSales_AMT
	  ,sal.DiscountSales_QTY
	  ,sal.END_Inventory_AMT
	  ,sal.END_Inventory_QTY) IS NOT NULL
GROUP BY cal.Week_ID
	    ,cal.Week_Year_NBR
	    ,cal.[year]
	    ,st.Store_City
		,st.Store_Province
	    ,prod.SKU_ID

-------------------------------------用YH的结果计算折扣率
DROP TABLE IF EXISTS #Discount
SELECT Week_ID
	  ,SKU_ID
	  ,CASE WHEN SUM(Sales_AMT)=0 THEN NULL ELSE SUM(DiscountSales_AMT)/SUM(Sales_AMT) END AS Discount_Rate
	  INTO #Discount
FROM #YH_SOP
GROUP BY  Week_ID
	  ,SKU_ID


---------------------------------------------------------------KIDWANTS 
DROP TABLE IF EXISTS #KW_Sales_Lim
SELECT SKU_ID
	  ,st.Store_City
		,st.Store_Province
	  ,MIN(Datekey) AS Date_MIN
INTO #KW_Sales_Lim
FROM dm.Fct_Kidswant_DailySales sal
LEFT JOIN dm.Dim_Store st ON sal.Store_ID = st.Store_ID
WHERE sal.Sales_Qty>0 OR sal.Sales_AMT>0
GROUP BY SKU_ID
	  ,st.Store_City
		,st.Store_Province
----------------------------------------KW SOP
DROP TABLE IF EXISTS #KW_SOP
SELECT cal.Week_ID
	  ,cal.Week_Year_NBR
	  ,cal.[year]
	  ,st.Store_City
	  ,st.Store_Province
	  ,prod.SKU_ID
	  ,SUM(sal.Sales_AMT		) AS Sales_AMT
	  ,SUM(sal.sales_QTY		) AS sales_QTY
	  ,SUM(salM3W.Sales_AMT_M3W	) AS Sales_AMT_M3W
	  ,SUM(salM3W.sales_QTY_M3W	) AS sales_QTY_M3W
	  ,ISNULL(SUM(sal.Sales_AMT)*MAX(dc.Discount_Rate),0) AS DiscountSales_AMT
	  ,0 AS DiscountSales_QTY
	  ,SUM(sal.END_Inventory_AMT) AS END_Inventory_AMT
	  ,SUM(sal.END_Inventory_QTY) AS END_Inventory_QTY
INTO #KW_SOP
FROM (SELECT DISTINCT CONVERT(VARCHAR(8),CAST(LEFT(Week_Date_Period,10) AS DATE),112) AS Week_ID,Week_Year_NBR,[year] FROM FU_EDW.Dim_Calendar) cal
CROSS JOIN (SELECT DISTINCT Store_City,Store_Province FROM dm.Dim_Store) st
CROSS JOIN dm.Dim_Product prod
INNER JOIN #KW_Sales_Lim sl ON st.Store_City = sl.Store_City AND sl.SKU_ID = prod.SKU_ID AND cal.Week_ID>=sl.Date_MIN AND st.Store_Province = sl.Store_Province
LEFT JOIN 
(
SELECT st.Store_City
		,st.Store_Province
	  ,CONVERT(VARCHAR(8),CAST(LEFT(cal.Week_Date_Period,10) AS DATE),112) AS Week_ID
	  ,si.SKU_ID
	  ,SUM(si.Sales_AMT) AS Sales_AMT
	  ,SUM(si.Sales_QTY) AS sales_QTY
	  ,(SELECT SUM(Ending_AMT) FROM [dm].Fct_Kidswant_DailySales si2 LEFT JOIN dm.Dim_Store st2 ON si2.Store_ID = st2.Store_ID WHERE st.Store_City = st2.Store_City AND st.Store_Province = st2.Store_Province AND si.SKU_ID = si2.SKU_ID AND si2.Datekey = CONVERT(VARCHAR(8),CAST(cal.Week_Date_Period_End AS DATE),112)) AS END_Inventory_AMT
	  ,(SELECT SUM(Ending_Qty) FROM [dm].Fct_Kidswant_DailySales si3 LEFT JOIN dm.Dim_Store st3 ON si3.Store_ID = st3.Store_ID WHERE st.Store_City = st3.Store_City AND st.Store_Province = st3.Store_Province AND si.SKU_ID = si3.SKU_ID AND si3.Datekey = CONVERT(VARCHAR(8),CAST(cal.Week_Date_Period_End AS DATE),112)) AS END_Inventory_QTY
FROM [dm].Fct_Kidswant_DailySales si
LEFT JOIN dm.Dim_Store st ON si.Store_ID = st.Store_ID
LEFT JOIN FU_EDW.Dim_Calendar cal ON si.Datekey = cal.Date_ID
GROUP BY st.Store_City
		,st.Store_Province
	    ,LEFT(cal.Week_Date_Period,10)
		,cal.Week_Date_Period_End
		,si.SKU_ID
) sal 
ON cal.Week_ID = sal.Week_ID AND sal.Store_City = st.Store_City AND sal.SKU_ID = prod.SKU_ID AND sal.Store_Province = st.Store_Province
LEFT JOIN 
(
SELECT st.Store_City
	  ,st.Store_Province
	  ,CONVERT(VARCHAR(8),CAST(LEFT(cal.Week_Date_Period,10) AS DATE),112) AS Week_ID
	  ,si.SKU_ID
	  ,SUM(si.Sales_AMT) AS Sales_AMT_M3W
	  ,SUM(si.Sales_QTY) AS sales_QTY_M3W
FROM [dm].Fct_Kidswant_DailySales si
LEFT JOIN dm.Dim_Store st ON si.Store_ID = st.Store_ID
LEFT JOIN FU_EDW.Dim_Calendar cal ON si.Datekey<= cal.Date_ID AND si.Datekey>CONVERT(VARCHAR(8),DATEADD(DAY,-21,cal.Date_NM),112)
INNER JOIN (SELECT DISTINCT CONVERT(VARCHAR(8),CAST(Week_Date_Period_End AS DATE),112) AS WeekEnd FROM FU_EDW.Dim_Calendar) calll ON cal.Date_ID = calll.WeekEnd
GROUP BY st.Store_City
		,st.Store_Province
	    ,LEFT(cal.Week_Date_Period,10)
		,si.SKU_ID 
) salM3W
ON cal.Week_ID = salM3W.Week_ID AND salM3W.Store_City = st.Store_City AND salM3W.SKU_ID = prod.SKU_ID AND salM3W.Store_Province = st.Store_Province
LEFT JOIN #Discount dc ON dc.Week_ID = cal.Week_ID AND dc.SKU_ID = prod.SKU_ID
WHERE COALESCE(
	  sal.Sales_AMT
	  ,sal.sales_QTY
	  ,salM3W.Sales_AMT_M3W
	  ,salM3W.sales_QTY_M3W
	  ,sal.END_Inventory_AMT
	  ,sal.END_Inventory_QTY) IS NOT NULL
GROUP BY cal.Week_ID
	    ,cal.Week_Year_NBR
	    ,cal.[year]
	    ,st.Store_City
		,st.Store_Province
	    ,prod.SKU_ID

-------------------------------------------------------VG
DROP TABLE IF EXISTS #VG_Sales_Lim
SELECT SKU_ID
	  ,st.Store_City
	  ,st.Store_Province
	  ,MIN(Datekey) AS Date_MIN
INTO #VG_Sales_Lim
FROM [dm].[Fct_CRV_DailySales] sal
LEFT JOIN dm.Dim_Store st ON sal.Store_ID = st.Store_ID
WHERE sal.Sale_Qty>0 OR sal.Gross_Sale_Value>0
GROUP BY SKU_ID
	  ,st.Store_City
	  ,st.Store_Province
----------------------------------组合VGsales和inventory
DROP TABLE IF EXISTS #VG_Sales_Inventory
SELECT ISNULL(inv.Datekey,sal.Datekey) AS Datekey
	  ,ISNULL(inv.Store_ID,sal.Store_ID) AS Store_ID
	  ,ISNULL(inv.SKU_ID,sal.SKU_ID) AS SKU_ID
	  ,sal.Sale_Qty AS Sales_Qty
	  ,sal.Gross_Sale_Value AS Sales_AMT
	  ,inv.Qty AS Inventory_Qty
	  ,inv.Gross_Cost_Value AS Inventory_Amt
INTO #VG_Sales_Inventory
FROM [dm].[Fct_CRV_DailyInventory] inv
FULL OUTER JOIN [dm].[Fct_CRV_DailySales] sal ON inv.Datekey = sal.Datekey AND inv.Store_ID = sal.Store_ID AND inv.SKU_ID = sal.SKU_ID


----------------------------------------VG SOP
DROP TABLE IF EXISTS #VG_SOP
SELECT cal.Week_ID
	  ,cal.Week_Year_NBR
	  ,cal.[year]
	  ,st.Store_City
	  ,st.Store_Province
	  ,prod.SKU_ID
	  ,SUM(sal.Sales_AMT		) AS Sales_AMT
	  ,SUM(sal.sales_QTY		) AS sales_QTY
	  ,SUM(salM3W.Sales_AMT_M3W	) AS Sales_AMT_M3W
	  ,SUM(salM3W.sales_QTY_M3W	) AS sales_QTY_M3W
	  ,ISNULL(SUM(sal.Sales_AMT)*MAX(dc.Discount_Rate),0) AS DiscountSales_AMT
	  ,0 AS DiscountSales_QTY
	  ,SUM(sal.END_Inventory_AMT) AS END_Inventory_AMT
	  ,SUM(sal.END_Inventory_QTY) AS END_Inventory_QTY
INTO #VG_SOP
FROM (SELECT DISTINCT CONVERT(VARCHAR(8),CAST(LEFT(Week_Date_Period,10) AS DATE),112) AS Week_ID,Week_Year_NBR,[year] FROM FU_EDW.Dim_Calendar) cal
CROSS JOIN (SELECT DISTINCT Store_City,Store_Province FROM dm.Dim_Store) st
CROSS JOIN dm.Dim_Product prod
INNER JOIN #VG_Sales_Lim sl ON st.Store_City = sl.Store_City AND sl.SKU_ID = prod.SKU_ID AND cal.Week_ID>=sl.Date_MIN AND st.Store_Province = sl.Store_Province
LEFT JOIN 
(
SELECT st.Store_City
	  ,st.Store_Province
	  ,CONVERT(VARCHAR(8),CAST(LEFT(cal.Week_Date_Period,10) AS DATE),112) AS Week_ID
	  ,si.SKU_ID
	  ,SUM(si.Sales_AMT) AS Sales_AMT
	  ,SUM(si.Sales_QTY) AS sales_QTY
	  ,(SELECT SUM(Inventory_Qty) FROM #VG_Sales_Inventory si2 LEFT JOIN dm.Dim_Store st2 ON si2.Store_ID = st2.Store_ID WHERE st.Store_City = st2.Store_City AND st.Store_Province = st2.Store_Province AND si.SKU_ID = si2.SKU_ID AND si2.Datekey = CONVERT(VARCHAR(8),CAST(cal.Week_Date_Period_End AS DATE),112)) AS END_Inventory_AMT
	  ,(SELECT SUM(Inventory_Qty) FROM #VG_Sales_Inventory si3 LEFT JOIN dm.Dim_Store st3 ON si3.Store_ID = st3.Store_ID WHERE st.Store_City = st3.Store_City AND st.Store_Province = st3.Store_Province AND si.SKU_ID = si3.SKU_ID AND si3.Datekey = CONVERT(VARCHAR(8),CAST(cal.Week_Date_Period_End AS DATE),112)) AS END_Inventory_QTY
FROM #VG_Sales_Inventory si
LEFT JOIN dm.Dim_Store st ON si.Store_ID = st.Store_ID
LEFT JOIN FU_EDW.Dim_Calendar cal ON si.Datekey = cal.Date_ID
GROUP BY st.Store_City
		,st.Store_Province
	    ,LEFT(cal.Week_Date_Period,10)
		,cal.Week_Date_Period_End
		,si.SKU_ID
) sal 
ON cal.Week_ID = sal.Week_ID AND sal.Store_City = st.Store_City AND sal.SKU_ID = prod.SKU_ID AND sal.Store_Province = st.Store_Province
LEFT JOIN 
(
SELECT st.Store_City
	  ,st.Store_Province
	  ,CONVERT(VARCHAR(8),CAST(LEFT(cal.Week_Date_Period,10) AS DATE),112) AS Week_ID
	  ,si.SKU_ID
	  ,SUM(si.Sales_AMT) AS Sales_AMT_M3W
	  ,SUM(si.Sales_QTY) AS sales_QTY_M3W
FROM #VG_Sales_Inventory si
LEFT JOIN dm.Dim_Store st ON si.Store_ID = st.Store_ID
LEFT JOIN FU_EDW.Dim_Calendar cal ON si.Datekey<= cal.Date_ID AND si.Datekey>CONVERT(VARCHAR(8),DATEADD(DAY,-21,cal.Date_NM),112)
INNER JOIN (SELECT DISTINCT CONVERT(VARCHAR(8),CAST(Week_Date_Period_End AS DATE),112) AS WeekEnd FROM FU_EDW.Dim_Calendar) calll ON cal.Date_ID = calll.WeekEnd
GROUP BY st.Store_City
		,st.Store_Province
	    ,LEFT(cal.Week_Date_Period,10)
		,si.SKU_ID 
) salM3W
ON cal.Week_ID = salM3W.Week_ID AND salM3W.Store_City = st.Store_City AND salM3W.SKU_ID = prod.SKU_ID AND salM3W.Store_Province = st.Store_Province
LEFT JOIN #Discount dc ON dc.Week_ID = cal.Week_ID AND dc.SKU_ID = prod.SKU_ID
WHERE COALESCE(
	  sal.Sales_AMT
	  ,sal.sales_QTY
	  ,salM3W.Sales_AMT_M3W
	  ,salM3W.sales_QTY_M3W
	  ,sal.END_Inventory_AMT
	  ,sal.END_Inventory_QTY) IS NOT NULL
GROUP BY cal.Week_ID
	    ,cal.Week_Year_NBR
	    ,cal.[year]
	    ,st.Store_City
		,st.Store_Province
	    ,prod.SKU_ID

--------------------------------------------------union
SELECT Week_ID
	  ,Week_Year_NBR
	  ,[YEAR]
	  ,'YH' AS DataSource
	  ,Store_City
	  ,store_Province
	  ,Store_Province+Store_City AS Store_Province_City
	  ,SKU_ID
	  ,Sales_AMT
	  ,sales_QTY
	  ,0 AS Sales_AMT_Forecast
	  ,0 AS sales_QTY_Forecast
	  ,Sales_AMT_M3W
	  ,sales_QTY_M3W
	  ,DiscountSales_AMT
	  ,DiscountSales_QTY
	  ,END_Inventory_AMT
	  ,END_Inventory_QTY
FROM #YH_SOP
UNION ALL
SELECT Week_ID
	  ,Week_Year_NBR
	  ,[YEAR]
	  ,'KW' AS DataSource
	  ,Store_City
	  ,Store_Province
	  ,Store_Province+Store_City AS Store_Province_City
	  ,SKU_ID
	  ,Sales_AMT
	  ,sales_QTY
	  ,0 AS Sales_AMT_Forecast
	  ,0 AS sales_QTY_Forecast
	  ,Sales_AMT_M3W
	  ,sales_QTY_M3W
	  ,DiscountSales_AMT
	  ,DiscountSales_QTY
	  ,END_Inventory_AMT
	  ,END_Inventory_QTY
FROM #KW_SOP
UNION ALL
SELECT Week_ID
	  ,Week_Year_NBR
	  ,[YEAR]
	  ,'VG' AS DataSource
	  ,Store_City
	  ,Store_Province
	  ,Store_Province+Store_City AS Store_Province_City
	  ,SKU_ID
	  ,Sales_AMT
	  ,sales_QTY
	  ,0 AS Sales_AMT_Forecast
	  ,0 AS sales_QTY_Forecast
	  ,Sales_AMT_M3W
	  ,sales_QTY_M3W
	  ,DiscountSales_AMT
	  ,DiscountSales_QTY
	  ,END_Inventory_AMT
	  ,END_Inventory_QTY
FROM #VG_SOP







END

GO
