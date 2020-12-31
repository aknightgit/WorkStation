﻿USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE  [rpt].[SP_RPT_ERP_FLOW_SELL_IN_OUT]
AS BEGIN
--------------------从ERP获取YHSellin 数据，以每一周的星期一作为时间主键
IF OBJECT_ID('TEMPDB..#SellIn') IS NOT NULL
BEGIN
DROP TABLE #SellIn
END


SELECT 
	SKU_ID
   ,Product_Sort
   ,Customer_Name
   ,Week_ID
   ,cal2.Week_Nature_Str
   ,Sale_Unit
   ,SUM(Sale_Unit_QTY)/2 Sale_Unit_M2W_Qty		
   ,SUM(Actual_Sale_Unit_QTY) AS Actual_Sale_Unit_QTY	 
     INTO #SellIn
FROM(

----------------------------------孩子王的sell in数据从出库表取,其它的从order 表抽取
	SELECT
	  soe.SKU_ID
	   ,prod.Product_Sort
	   ,CASE WHEN so.Customer_Name LIKE '%华润%' THEN '华润万家' ELSE so.Customer_Name END AS Customer_Name
	   ,cal.Start_of_Week AS Week_ID
	   ,prod.Sale_Unit
	   ,Sale_Unit_QTY AS Sale_Unit_QTY
	   ,Sale_Unit_QTY AS Actual_Sale_Unit_QTY

	FROM 
	[dm].[Fct_ERP_Sale_OrderEntry] SOe
	LEFT JOIN [dm].[Fct_ERP_Sale_Order] so on soe.Sale_Order_ID = so.Sale_Order_ID
	LEFT JOIN dm.Dim_Product prod ON soe.SKU_ID = prod.SKU_ID
	LEFT JOIN dm.Dim_Calendar cal ON so.Datekey = cal.Datekey
	WHERE so.Customer_Name <> '孩子王儿童用品股份有限公司采购中心'
	--上一周的sellIn数据
	UNION ALL
	SELECT
	  soe.SKU_ID
	   ,prod.Product_Sort
	   ,CASE WHEN so.Customer_Name LIKE '%华润%' THEN '华润万家' ELSE so.Customer_Name END AS Customer_Name
	   ,DATEADD(DAY,7,cal.Start_of_Week) AS Week_ID
	   ,prod.Sale_Unit
	   ,Sale_Unit_QTY AS Sale_Unit_QTY
	   ,0 AS Actual_Sale_Unit_QTY
	FROM 
	[dm].[Fct_ERP_Sale_OrderEntry] SOe
	LEFT JOIN [dm].[Fct_ERP_Sale_Order] so on soe.Sale_Order_ID = so.Sale_Order_ID
	LEFT JOIN dm.Dim_Product prod ON soe.SKU_ID = prod.SKU_ID
	LEFT JOIN dm.Dim_Calendar cal ON so.Datekey = cal.Datekey
	WHERE so.Customer_Name <> '孩子王儿童用品股份有限公司采购中心'
	--WHERE so.Customer_Name = '富平云商供应链管理有限公司'
	UNION ALL
		SELECT ose.SKU_ID
		  ,prod.Product_Sort
		  ,os.Customer_Name
		  ,cal.Start_of_Week AS Week_ID
		  ,prod.Sale_Unit
		  ,ose.Sale_Unit_QTY AS Sales_QTY
		  ,ose.Sale_Unit_QTY AS Actual_Sales_QTY
	FROM [dm].[Fct_ERP_Stock_OutStockEntry] ose
	LEFT JOIN dm.Fct_ERP_Stock_OutStock os ON ose.OutStock_ID = os.OutStock_ID
	LEFT JOIN dm.Dim_Calendar cal ON os.[Date] = cal.Date_Str
	LEFT JOIN dm.Dim_Product prod ON ose.SKU_ID = prod.SKU_ID
	WHERE os.Customer_Name = '孩子王儿童用品股份有限公司采购中心'
	--上一周的SellIn数据
	UNION ALL
	SELECT ose.SKU_ID
		  ,prod.Product_Sort
		  ,os.Customer_Name
	      ,DATEADD(DAY,7,cal.Start_of_Week) AS Week_ID
		  ,prod.Sale_Unit
		  ,ose.Sale_Unit_QTY AS Sales_QTY
		  ,ose.Sale_Unit_QTY AS Actual_Sales_QTY
	FROM [dm].[Fct_ERP_Stock_OutStockEntry] ose
	LEFT JOIN dm.Fct_ERP_Stock_OutStock os ON ose.OutStock_ID = os.OutStock_ID
	LEFT JOIN dm.Dim_Calendar cal ON os.[Date] = cal.Date_Str
	LEFT JOIN dm.Dim_Product prod ON ose.SKU_ID = prod.SKU_ID
	WHERE os.Customer_Name = '孩子王儿童用品股份有限公司采购中心'

) BASE
LEFT JOIN dm.Dim_Calendar cal2 ON base.Week_ID = cal2.Date_Str
WHERE WEEK_ID <= (SELECT MAX(eso.Date) FROM [dm].[Fct_ERP_Sale_Order] eso)
GROUP BY SKU_ID
		,Product_Sort
		,Customer_Name
		,Week_id
		,Week_Nature_Str
		,Sale_Unit

   ------------------------从EDI获取YHsellout数据，以每一周的星期一作为时间主键
IF OBJECT_ID('TEMPDB..#YH_SellOut') IS NOT NULL
BEGIN
DROP TABLE #YH_SellOut
END

SELECT
	SKU_ID
   ,Product_Sort
   ,Week_id
   ,'富平云商供应链管理有限公司' AS Customer_Name
   ,cal2.Week_Nature_Str
   ,Sale_Unit
   ,SUM(Sales_QTY)/2 AS Sales_M2W_QTY
   ,SUM(Actual_Sales_QTY) AS Actual_Sales_QTY
   INTO #YH_SellOut
FROM(
	SELECT 
	  sal.SKU_ID
	   ,prod.Product_Sort
	   ,cal.Start_of_Week AS Week_ID
	   ,prod.Sale_Unit
	   ,sal.Sales_QTY AS Sales_QTY
	   ,sal.Sales_QTY AS Actual_Sales_QTY
	  -- INTO #YH_SellOut
	FROM [dm].[Fct_YH_Sales_Inventory] sal
	LEFT JOIN dm.Dim_Product prod ON sal.SKU_ID = prod.SKU_ID
	LEFT JOIN dm.Dim_Calendar cal ON sal.Calendar_DT = cal.Datekey
	--上一周的Sellout数据
	UNION ALL
	SELECT 
	  sal.SKU_ID
	   ,prod.Product_Sort
	   ,DATEADD(DAY,7,cal.Start_of_Week) AS Week_ID
	   ,prod.Sale_Unit
	   ,sal.Sales_QTY AS Sales_QTY
	   ,0 AS Actual_Sales_QTY
	--   INTO #YH_SellOut
	FROM [dm].[Fct_YH_Sales_Inventory] sal
	LEFT JOIN dm.Dim_Product prod ON sal.SKU_ID = prod.SKU_ID
	LEFT JOIN dm.Dim_Calendar cal ON sal.Calendar_DT = cal.Datekey
) BASE
LEFT JOIN dm.Dim_Calendar cal2 ON base.Week_ID = cal2.Date_Str
WHERE cal2.Datekey<=(SELECT MAX(Calendar_DT) FROM [dm].[Fct_YH_Sales_Inventory] sal)
GROUP BY SKU_ID
		,Product_Sort
		,week_id
		,Week_Nature_Str
		,Sale_Unit


------------------------kidwants sellout 数据，以每一周的星期一作为时间主键

DROP TABLE IF EXISTS #KW_SellOut


SELECT
	SKU_ID
   ,Product_Sort
   ,Week_id
   ,'孩子王儿童用品股份有限公司采购中心' AS Customer_Name
   ,cal2.Week_Nature_Str
   ,Sale_Unit
   ,SUM(Sales_QTY)/2 AS Sales_M2W_QTY
   ,SUM(Actual_Sales_QTY) AS Actual_Sales_QTY
   INTO #KW_SellOut
FROM(
	SELECT 
	  sal.SKU_ID
	   ,prod.Product_Sort
	   ,cal.Start_of_Week AS Week_ID
	   ,prod.Sale_Unit
	   ,sal.Sales_QTY AS Sales_QTY
	   ,sal.Sales_QTY AS Actual_Sales_QTY
	  -- INTO #YH_SellOut
	FROM [dm].[Fct_Kidswant_DailySales] sal
	LEFT JOIN dm.Dim_Product prod ON sal.SKU_ID = prod.SKU_ID
	LEFT JOIN dm.Dim_Calendar cal ON sal.Datekey = cal.Datekey
	--上一周的Sellout数据
	UNION ALL
	SELECT 
	  sal.SKU_ID
	   ,prod.Product_Sort
	   ,DATEADD(DAY,7,cal.Start_of_Week) AS Week_ID
	   ,prod.Sale_Unit
	   ,sal.Sales_QTY AS Sales_QTY
	   ,0 AS Actual_Sales_QTY
	--   INTO #YH_SellOut
	FROM [dm].[Fct_Kidswant_DailySales] sal
	LEFT JOIN dm.Dim_Product prod ON sal.SKU_ID = prod.SKU_ID
	LEFT JOIN dm.Dim_Calendar cal ON sal.Datekey = cal.Datekey
) BASE
LEFT JOIN dm.Dim_Calendar cal2 ON base.Week_ID = cal2.Date_Str
WHERE cal2.Datekey<=(SELECT MAX(Datekey) FROM [dm].[Fct_Kidswant_DailySales] sal)
GROUP BY SKU_ID
		,Product_Sort
		,week_id
		,Week_Nature_Str
		,Sale_Unit

------------------------CRV sellout 数据，以每一周的星期一作为时间主键
DROP TABLE IF EXISTS #CRV_SellOut

SELECT
	SKU_ID
   ,Product_Sort
   ,Week_id
   ,'华润万家' AS Customer_Name
   ,cal2.Week_Nature_Str
   ,Sale_Unit
   ,SUM(Sales_QTY)/2 AS Sales_M2W_QTY
   ,SUM(Actual_Sales_QTY) AS Actual_Sales_QTY
   INTO #CRV_SellOut
FROM(
	SELECT 
	  sal.SKU_ID
	   ,prod.Product_Sort
	   ,cal.Start_of_Week AS Week_ID
	   ,prod.Sale_Unit
	   ,sal.Sale_QTY AS Sales_QTY
	   ,sal.Sale_QTY AS Actual_Sales_QTY
	  -- INTO #YH_SellOut
	FROM [dm].[Fct_CRV_DailySales] sal
	LEFT JOIN dm.Dim_Product prod ON sal.SKU_ID = prod.SKU_ID
	LEFT JOIN dm.Dim_Calendar cal ON sal.Datekey = cal.Datekey
	--上一周的Sellout数据
	UNION ALL
	SELECT 
	  sal.SKU_ID
	   ,prod.Product_Sort
	   ,DATEADD(DAY,7,cal.Start_of_Week) AS Week_ID
	   ,prod.Sale_Unit
	   ,sal.Sale_QTY AS Sales_QTY
	   ,0 AS Actual_Sales_QTY
	--   INTO #YH_SellOut
	FROM [dm].[Fct_CRV_DailySales] sal
	LEFT JOIN dm.Dim_Product prod ON sal.SKU_ID = prod.SKU_ID
	LEFT JOIN DM.Dim_Calendar cal ON sal.Datekey = cal.Datekey
) BASE
LEFT JOIN dm.Dim_Calendar cal2 ON base.Week_ID = cal2.Date_Str
WHERE cal2.Datekey<=(SELECT MAX(Datekey) FROM [dm].[Fct_CRV_DailySales] sal)
GROUP BY SKU_ID
		,Product_Sort
		,week_id
		,Week_Nature_Str
		,Sale_Unit

------------------------qulouxia sellout 数据，以每一周的星期一作为时间主键
DROP TABLE IF EXISTS #qulouxia_SellOut

SELECT
	SKU_ID
   ,Product_Sort
   ,Week_id
   ,'北京去楼下科技有限公司' AS Customer_Name
   ,cal2.Week_Nature_Str
   ,Sale_Unit
   ,SUM(Sales_QTY)/2 AS Sales_M2W_QTY
   ,SUM(Actual_Sales_QTY) AS Actual_Sales_QTY
   INTO #qulouxia_SellOut
FROM(
	SELECT 
	  sal.SKU_ID
	   ,prod.Product_Sort
	   ,cal.Start_of_Week AS Week_ID
	   ,prod.Sale_Unit
	   --,sal.Sales_QTY/ISNULL(acm.Split_Number,1) AS Sales_QTY
	   --,sal.Sales_QTY/ISNULL(acm.Split_Number,1) AS Actual_Sales_QTY
	   ,sal.Sales_QTY AS Sales_QTY
	   ,sal.Sales_QTY AS Actual_Sales_QTY
	  -- INTO #YH_SellOut
	FROM [dm].Fct_Qulouxia_Sales sal
	LEFT JOIN dm.Dim_Product prod ON sal.SKU_ID = prod.SKU_ID
	--LEFT JOIN dm.Dim_Product_AccountCodeMapping acm ON sal.SKU_ID = acm.SKU_ID and acm.Account = 'Qulouxia (去楼下)'
	LEFT JOIN dm.Dim_Calendar cal ON sal.Datekey = cal.Datekey
	--上一周的Sellout数据
	UNION ALL
	SELECT 
	  sal.SKU_ID
	   ,prod.Product_Sort
	   ,DATEADD(DAY,7,cal.Start_of_Week) AS Week_ID
	   ,prod.Sale_Unit
	   --,sal.Sales_QTY/ISNULL(acm.Split_Number,1) AS Sales_QTY
	   ,sal.Sales_QTY AS Sales_QTY
	   ,0 AS Actual_Sales_QTY
	--   INTO #YH_SellOut
	FROM [dm].Fct_Qulouxia_Sales sal
	LEFT JOIN dm.Dim_Product prod ON sal.SKU_ID = prod.SKU_ID
	--LEFT JOIN dm.Dim_Product_AccountCodeMapping acm ON sal.SKU_ID = acm.SKU_ID and acm.Account = 'Qulouxia (去楼下)'
	LEFT JOIN dm.Dim_Calendar cal ON sal.Datekey = cal.Datekey
) BASE
LEFT JOIN dm.Dim_Calendar cal2 ON base.Week_ID = cal2.Date_Str
WHERE cal2.Datekey<=(SELECT MAX(Datekey) FROM [dm].[Fct_CRV_DailySales] sal)
GROUP BY SKU_ID
		,Product_Sort
		,week_id
		,Week_Nature_Str
		,Sale_Unit

--以周和SKU关联Sell in 和Sellout ， 冷藏产品Sellout相对Sellin延迟一周，常温产品延迟两周
SELECT COALESCE( so.SKU_ID,si.SKU_ID,sima.SKU_ID,aso.SKU_ID,cso.SKU_ID,kwso.SKU_ID,qso.SKU_ID) AS SKU_ID
    ,COALESCE( so.Product_Sort,si.Product_Sort,sima.Product_Sort,aso.Product_Sort,cso.Product_Sort,kwso.Product_Sort,qso.Product_Sort) AS Product_Sort
	,COALESCE( so.Customer_Name,si.Customer_Name,sima.Customer_Name,aso.Customer_Name,cso.Customer_Name,kwso.Customer_Name,qso.Customer_Name)  AS Customer_Name
    ,convert(varchar(8),COALESCE( so.Week_ID,si.Week_ID,sima.Week_ID,aso.Week_ID,cso.Week_ID,kwso.Week_ID,qso.Week_ID),112) AS Week_ID
    ,COALESCE( so.Sale_Unit,si.Sale_Unit,sima.Sale_Unit,aso.Sale_Unit,cso.Sale_Unit,kwso.Sale_Unit,qso.Sale_Unit) AS Sale_Unit
    ,sima.Sale_Unit_M2W_Qty AS SellIn_Qty
    ,sima.Sale_Unit_M2W_Qty*prod.Sale_Unit_Weight_KG/1000 AS SellIn_Vol
	,si.Actual_Sale_Unit_QTY AS Actual_SellIn_QTY
	,si.Actual_Sale_Unit_QTY*prod.Sale_Unit_Weight_KG/1000 AS Actual_SellIn_Vol
    ,so.Sales_M2W_QTY AS SellOut_Qty 
    ,so.Sales_M2W_QTY*prod.Sale_Unit_Weight_KG/1000 AS SellOut_Vol
	,ISNULL(aso.Actual_Sales_QTY,0)+ISNULL(kwso.Actual_Sales_QTY,0)+ISNULL(cso.Actual_Sales_QTY,0)+ISNULL(qso.Actual_Sales_QTY,0) AS Actual_SellOut_QTY
	,ISNULL(aso.Actual_Sales_QTY*prod.Sale_Unit_Weight_KG/1000,0)+ISNULL(kwso.Actual_Sales_QTY*prod.Sale_Unit_Weight_KG/1000,0)+ISNULL(cso.Actual_Sales_QTY*prod.Sale_Unit_Weight_KG/1000,0)+ISNULL(qso.Actual_Sales_QTY*prod.Sale_Unit_Weight_KG/1000,0) AS Actual_SellOut_Vol
FROM 
(
----------------------YH
SELECT
	  '富平云商供应链管理有限公司' AS Customer_Name 
	 ,SKU_ID
     ,Product_Sort
     ,Week_ID 
     ,Sale_Unit
     ,Sales_M2W_QTY
	 ,Actual_Sales_QTY
FROM #YH_SellOut WHERE Product_Sort = 'Fresh'
UNION ALL
SELECT 
	 '富平云商供应链管理有限公司' AS Customer_Name 
	 ,SKU_ID
     ,Product_Sort
     ,Week_ID 
     ,Sale_Unit
     ,Sales_M2W_QTY
	 ,Actual_Sales_QTY
FROM #YH_SellOut WHERE Product_Sort = 'Ambient'
------------------------KW
UNION ALL
SELECT
	  '孩子王儿童用品股份有限公司采购中心' AS Customer_Name 
	 ,SKU_ID
     ,Product_Sort
     ,Week_ID 
     ,Sale_Unit
     ,Sales_M2W_QTY
	 ,Actual_Sales_QTY
FROM #KW_SellOut WHERE Product_Sort = 'Fresh'
UNION ALL
SELECT 
	 '孩子王儿童用品股份有限公司采购中心' AS Customer_Name 
	 ,SKU_ID
     ,Product_Sort
     ,Week_ID 
     ,Sale_Unit
     ,Sales_M2W_QTY
	 ,Actual_Sales_QTY
FROM #KW_SellOut WHERE Product_Sort = 'Ambient'

------------------------CRV
UNION ALL
SELECT
	  '华润万家' AS Customer_Name 
	 ,SKU_ID
     ,Product_Sort
     ,Week_ID 
     ,Sale_Unit
     ,Sales_M2W_QTY
	 ,Actual_Sales_QTY
FROM #CRV_SellOut WHERE Product_Sort = 'Fresh'
UNION ALL
SELECT 
	 '华润万家' AS Customer_Name 
	 ,SKU_ID
     ,Product_Sort
     ,Week_ID 
     ,Sale_Unit
     ,Sales_M2W_QTY
	 ,Actual_Sales_QTY
FROM #CRV_SellOut WHERE Product_Sort = 'Ambient'
------------------------CRV
UNION ALL
SELECT
	  Customer_Name AS Customer_Name 
	 ,SKU_ID
     ,Product_Sort
     ,Week_ID 
     ,Sale_Unit
     ,Sales_M2W_QTY
	 ,Actual_Sales_QTY
FROM #qulouxia_SellOut WHERE Product_Sort = 'Fresh'
UNION ALL
SELECT 
	  Customer_Name AS Customer_Name 
	 ,SKU_ID
     ,Product_Sort
     ,Week_ID 
     ,Sale_Unit
     ,Sales_M2W_QTY
	 ,Actual_Sales_QTY
FROM #qulouxia_SellOut WHERE Product_Sort = 'Ambient'
) so 
left join dm.Dim_Calendar b on so.Week_ID = b.Date_Str
FULL OUTER JOIN #SellIn si
ON si.SKU_ID = so.SKU_ID AND si.Week_ID = so.Week_ID AND si.Customer_Name = so.Customer_Name
FULL OUTER JOIN #SellIn sima
ON sima.SKU_ID = so.SKU_ID AND CASE WHEN sima.Product_Sort = 'Fresh' THEN DATEADD(DAY,7,sima.Week_ID) ELSE DATEADD(DAY,14,sima.Week_ID) END= so.Week_ID AND sima.Customer_Name = so.Customer_Name
FULL OUTER JOIN #YH_SellOut aso  ON si.SKU_ID = aso.SKU_ID AND si.Week_ID = aso.Week_ID and si.Customer_Name = aso.Customer_Name
FULL OUTER JOIN #KW_SellOut kwso  ON si.SKU_ID = kwso.SKU_ID AND si.Week_ID = kwso.Week_ID and si.Customer_Name = kwso.Customer_Name
FULL OUTER JOIN #CRV_SellOut cso  ON si.SKU_ID = aso.SKU_ID AND si.Week_ID = aso.Week_ID and si.Customer_Name = cso.Customer_Name
FULL OUTER JOIN #qulouxia_SellOut qso  ON si.SKU_ID = qso.SKU_ID AND si.Week_ID = qso.Week_ID and si.Customer_Name = qso.Customer_Name
LEFT JOIN dm.dim_product prod ON si.SKU_ID = prod.SKU_ID
WHERE COALESCE( so.Customer_Name,si.Customer_Name,aso.Customer_Name,cso.Customer_Name,kwso.Customer_Name,qso.Customer_Name) IN 
('孩子王儿童用品股份有限公司采购中心','华润万家','富平云商供应链管理有限公司','北京去楼下科技有限公司')
and b.Is_Past = 1
END
GO
