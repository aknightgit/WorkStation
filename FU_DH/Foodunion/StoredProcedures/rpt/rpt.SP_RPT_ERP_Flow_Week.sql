USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [rpt].[SP_RPT_ERP_Flow_Week]
as begin  
IF OBJECT_ID('TEMPDB..#SellIn') IS NOT NULL
BEGIN
  DROP TABLE #SellIn
END
--生产数据用生产日期作为时间主键，---------------------------------孩子王的sell in数据从出库表取,其它的从order 表抽取
SELECT 
     soe.SKU_ID
	,prod.Product_Sort
    ,cal.Start_of_Week AS Produce_Date
    ,SUM(soe.Sale_Unit_QTY) AS SellIn_QTY
    ,SUM(soe.Amount) AS SellIn_Amt
    ,SUM(soe.Base_Unit_QTY * Base_Unit_Weight_KG)/1000 AS Weight_Ton 
    INTO #SellIn
FROM [dm].[Fct_ERP_Sale_OrderEntry] soe
LEFT JOIN [dm].[Fct_ERP_Sale_Order] so ON soe.Sale_Order_ID = so.Sale_Order_ID
LEFT JOIN dm.Dim_Calendar cal ON so.Datekey = cal.Datekey
LEFT JOIN dm.Dim_Product prod ON soe.SKU_ID = prod.SKU_ID
WHERE so.Customer_Name <> '富友联合食品（中国）有限公司' AND so.Customer_Name NOT LIKE '%一次性现金客户%' AND so.FOC_Type IS NULL
GROUP BY 
       cal.Start_of_Week
      ,soe.SKU_ID
	,prod.Product_Sort



IF OBJECT_ID('TEMPDB..#Produce') IS NOT NULL
BEGIN
DROP TABLE #Produce
END


SELECT 
     pl.SKU_ID
	,pl.Plant
    ,prod.Sale_Unit_CN
	,prod.Product_Sort
    ,cal.Start_of_Week Produce_Date
    ,SUM(pl.Actual_Output_Tray_Qty*prod.Qty_SaleInTray) AS Sale_Unit_Qty
    ,SUM(Actual_Weight_Ton) AS Weight_Ton
    INTO #Produce
FROM [ODS].[ods].[File_Plant] pl
LEFT JOIN dm.dim_product prod on pl.sku_id = prod.sku_id
LEFT JOIN dm.Dim_Calendar cal ON CONVERT(VARCHAR(10),pl.Order_Date,112)  = cal.Datekey
GROUP BY 
     pl.SKU_ID
	,pl.Plant
    ,prod.Sale_Unit_CN
	,prod.Product_Sort
    ,cal.Start_of_Week

-------------------------------------------------常温时间窗口4周
SELECT 

      REPLACE(CONVERT(VARCHAR(10),ISNULL(prod.Produce_Date,si.Produce_Date),112),'-','') AS Produce_Date
     ,ISNULL(prod.SKU_ID,si.SKU_ID) AS SKU_ID
	 ,prod.Plant
	 ,'Ambient Time Window 4 Weeks' AS Measure
     ,prod.Sale_Unit_CN AS Unit
     ,prod.Sale_Unit_Qty AS Produce_Qty
     ,prod.Weight_Ton AS Product_Vol
     ,si.SellIn_Qty AS SellIn_Qty
     ,si.Weight_Ton As SellIn_Vol
FROM dm.Dim_Calendar cal
LEFT JOIN 
(
SELECT SKU_ID,Plant,Product_Sort,Sale_Unit_CN,cal1.Date_Str AS Produce_Date,SUM(Sale_Unit_Qty) AS Sale_Unit_Qty,SUM(Weight_Ton) AS Weight_Ton
FROM dm.Dim_Calendar cal1
LEFT JOIN #Produce prod2 ON cal1.Date_Str < DATEADD(DAY,35,prod2.Produce_Date) AND cal1.Date_Str >= DATEADD(DAY,7,prod2.Produce_Date)
GROUP BY SKU_ID,Plant,Sale_Unit_CN,cal1.Date_Str ,Product_Sort
)
prod ON cal.Date_Str = prod.Produce_Date
FULL OUTER JOIN 
(
SELECT SKU_ID,Product_Sort,cal1.Date_Str AS Produce_Date,SUM(SellIn_QTY) AS SellIn_Qty,SUM(Weight_Ton) AS Weight_Ton
FROM dm.Dim_Calendar cal1
LEFT JOIN #SellIn si2 ON cal1.Date_Str <= DATEADD(DAY,28,si2.Produce_Date) AND cal1.Date_Str >= si2.Produce_Date
GROUP BY SKU_ID,cal1.Date_Str ,Product_Sort
)
 si ON cal.Date_Str = si.Produce_Date AND prod.SKU_ID = si.SKU_ID
WHERE ISNULL(prod.SKU_ID,si.SKU_ID) iS NOT NULL AND ISNULL(prod.Product_Sort,si.Product_Sort) = 'Ambient'
-------------------------------------------------常温时间窗口6周
UNION ALL
SELECT 

      REPLACE(CONVERT(VARCHAR(10),ISNULL(prod.Produce_Date,si.Produce_Date),112),'-','') AS Produce_Date
     ,ISNULL(prod.SKU_ID,si.SKU_ID) AS SKU_ID
	 ,prod.Plant
	 ,'Ambient Time Window 6 Weeks' AS Measure
     ,prod.Sale_Unit_CN AS Unit
     ,prod.Sale_Unit_Qty AS Produce_Qty
     ,prod.Weight_Ton AS Product_Vol
     ,si.SellIn_Qty AS SellIn_Qty
     ,si.Weight_Ton As SellIn_Vol
FROM dm.Dim_Calendar cal
LEFT JOIN 
(
SELECT SKU_ID,Product_Sort,Plant,Sale_Unit_CN,cal1.Date_Str AS Produce_Date,SUM(Sale_Unit_Qty) AS Sale_Unit_Qty,SUM(Weight_Ton) AS Weight_Ton
FROM dm.Dim_Calendar cal1
LEFT JOIN #Produce prod2 ON cal1.Date_Str < DATEADD(DAY,49,prod2.Produce_Date) AND cal1.Date_Str >= DATEADD(DAY,7,prod2.Produce_Date)
GROUP BY SKU_ID,Product_Sort,Plant,Sale_Unit_CN,cal1.Date_Str 
)
prod ON cal.Date_Str = prod.Produce_Date
FULL OUTER JOIN 
(
SELECT SKU_ID,Product_Sort,cal1.Date_Str AS Produce_Date,SUM(SellIn_QTY) AS SellIn_Qty,SUM(Weight_Ton) AS Weight_Ton
FROM dm.Dim_Calendar cal1
LEFT JOIN #SellIn si2 ON cal1.Date_Str <= DATEADD(DAY,42,si2.Produce_Date) AND cal1.Date_Str >= si2.Produce_Date
GROUP BY SKU_ID,Product_Sort,cal1.Date_Str 
)
 si ON cal.Date_Str = si.Produce_Date AND prod.SKU_ID = si.SKU_ID
WHERE ISNULL(prod.SKU_ID,si.SKU_ID) iS NOT NULL AND ISNULL(prod.Product_Sort,si.Product_Sort) = 'Ambient'
-------------------------------------------------冷藏时间窗口2周
UNION ALL
SELECT 

      REPLACE(CONVERT(VARCHAR(10),ISNULL(prod.Produce_Date,si.Produce_Date),112),'-','') AS Produce_Date
     ,ISNULL(prod.SKU_ID,si.SKU_ID) AS SKU_ID
	 ,prod.Plant
	 ,'Fresh Time Window 2 Weeks' AS Measure
     ,prod.Sale_Unit_CN AS Unit
     ,prod.Sale_Unit_Qty AS Produce_Qty
     ,prod.Weight_Ton AS Product_Vol
     ,si.SellIn_Qty AS SellIn_Qty
     ,si.Weight_Ton As SellIn_Vol
FROM dm.Dim_Calendar cal
LEFT JOIN 
(
SELECT SKU_ID,Product_Sort,Plant,Sale_Unit_CN,cal1.Date_Str AS Produce_Date,SUM(Sale_Unit_Qty) AS Sale_Unit_Qty,SUM(Weight_Ton) AS Weight_Ton
FROM dm.Dim_Calendar cal1
LEFT JOIN #Produce prod2 ON cal1.Date_Str < DATEADD(DAY,21,prod2.Produce_Date) AND cal1.Date_Str >= DATEADD(DAY,7,prod2.Produce_Date)
GROUP BY SKU_ID,Product_Sort,Plant,Sale_Unit_CN,cal1.Date_Str 
)
prod ON cal.Date_Str = prod.Produce_Date
FULL OUTER JOIN 
(
SELECT SKU_ID,Product_Sort,cal1.Date_Str AS Produce_Date,SUM(SellIn_QTY) AS SellIn_Qty,SUM(Weight_Ton) AS Weight_Ton
FROM dm.Dim_Calendar cal1
LEFT JOIN #SellIn si2 ON cal1.Date_Str <= DATEADD(DAY,14,si2.Produce_Date) AND cal1.Date_Str >= si2.Produce_Date
GROUP BY SKU_ID,Product_Sort,cal1.Date_Str 
)
 si ON cal.Date_Str = si.Produce_Date AND prod.SKU_ID = si.SKU_ID
WHERE ISNULL(prod.SKU_ID,si.SKU_ID) iS NOT NULL AND ISNULL(prod.Product_Sort,si.Product_Sort) = 'Fresh'



end 
GO
