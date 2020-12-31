USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_ERP_Flow]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE PROCEDURE [rpt].[SP_RPT_ERP_Flow]
as begin  
IF OBJECT_ID('TEMPDB..#SellIn') IS NOT NULL
BEGIN
  DROP TABLE #SellIn
END
--根据批号得出的生产日期作为时间主键----------------------------------孩子王的sell in数据从出库表取,其它的从order 表抽取
SELECT 
    -- cal.[Year]
    --,cal.Week_Year_NBR
    --,cal.Week_Date_Period
  --  ,so.Customer_Name
     soe.SKU_ID
    ,CONVERT(VARCHAR(8),soe.Produce_Date,112) AS Produce_Date
    ,SUM(soe.Sale_Unit_QTY) AS SellIn_QTY
    ,SUM(soe.Amount) AS SellIn_Amt
    ,SUM(soe.Base_Unit_QTY * Base_Unit_Weight_KG)/1000 AS Weight_Ton 
    INTO #SellIn
FROM [dm].[Fct_ERP_Sale_OrderEntry] soe
LEFT JOIN [dm].[Fct_ERP_Sale_Order] so ON soe.Sale_Order_ID = so.Sale_Order_ID
LEFT JOIN FU_EDW.Dim_Calendar cal ON soe.Produce_Date = cal.Date_NM
LEFT JOIN dm.Dim_Product prod ON soe.SKU_ID = prod.SKU_ID
WHERE so.Customer_Name <> '富友联合食品（中国）有限公司' AND so.Customer_Name NOT LIKE '%一次性现金客户%' AND so.FOC_Type IS NULL
GROUP BY 
      -- cal.[Year]
      --,cal.Week_Year_NBR
      --,cal.Week_Date_Period
    --  ,so.Customer_Name
       soe.Produce_Date
      ,soe.SKU_ID
--UNION ALL
--SELECT cal.[Year]
--    ,cal.Week_Year_NBR
--    ,cal.Week_Date_Period
--    ,os.Customer_Name
--    ,ose.SKU_ID
--    ,ose.Produce_Date AS Produce_Date
--    ,SUM(ose.Sale_Unit_QTY) AS SellIn_QTY
--    ,SUM(ose.Amount) AS SellIn_Amt
--    ,SUM(ose.Sale_Unit_QTY * Sale_Unit_Weight_KG)/1000 AS Weight_Ton 
--FROM [dm].[Fct_ERP_Stock_OutStockEntry] ose
--LEFT JOIN dm.Fct_ERP_Stock_OutStock os ON ose.OutStock_ID = os.OutStock_ID
--LEFT JOIN FU_EDW.Dim_Calendar cal ON ose.Produce_Date = cal.Date_NM
--LEFT JOIN dm.Dim_Product prod ON ose.SKU_ID = prod.SKU_ID
--WHERE os.Customer_Name = '孩子王儿童用品股份有限公司采购中心'
--GROUP BY cal.[Year]
--      ,cal.Week_Year_NBR
--      ,cal.Week_Date_Period
--      ,os.Customer_Name
--      ,ose.Produce_Date
--      ,ose.SKU_ID


IF OBJECT_ID('TEMPDB..#Produce') IS NOT NULL
BEGIN
DROP TABLE #Produce
END


SELECT 
    -- cal.[Year]
    --,cal.Week_Year_NBR
    --,cal.Week_Date_Period
     pl.SKU_ID
	,pl.Plant
    ,prod.Sale_Unit_CN
    ,CONVERT(VARCHAR(8),pl.Order_Date,112) Produce_Date
    ,SUM(pl.Actual_Output_Tray_Qty*prod.Qty_SaleInTray) AS Sale_Unit_Qty
    ,SUM(Actual_Weight_Ton) AS Weight_Ton
    INTO #Produce
FROM [ODS].[ods].[File_Plant] pl
LEFT JOIN dm.dim_product prod on pl.sku_id = prod.sku_id
LEFT JOIN FU_EDW.Dim_Calendar cal ON CONVERT(VARCHAR(8),pl.Order_Date,112)  = cal.Date_ID
--WHERE PL.brand='BRAVO MAMA'
GROUP BY 
--cal.[Year]
--    ,cal.Week_Year_NBR
--    ,cal.Week_Date_Period
     pl.SKU_ID
	,pl.Plant
    ,prod.Sale_Unit_CN
    ,pl.Order_Date


SELECT 
    --prod.[Year]
    -- ,prod.Week_Year_NBR
    -- ,prod.Week_Date_Period
      ISNULL(prod.Produce_Date,si.Produce_Date) AS Produce_Date
--     ,si.Customer_Name
     ,ISNULL(prod.SKU_ID,si.SKU_ID) AS SKU_ID
	 ,prod.Plant
     ,prod.Sale_Unit_CN AS Unit
     ,prod.Sale_Unit_Qty AS Produce_Qty
     ,prod.Weight_Ton AS Product_Vol
     ,si.SellIn_Qty AS SellIn_Qty
     ,si.Weight_Ton As SellIn_Vol
	 ,T1.QTY WriteOff_Qty
	 ,t2.Inventory_QTY
FROM #Produce prod 
FULL OUTER JOIN #SellIn si ON prod.Produce_Date = si.Produce_Date AND prod.SKU_ID = si.SKU_ID
LEFT JOIN (
------取WriteOff的数据
SELECT T1.SKU_ID,
LEFT(LOT,8) LOT,
UNIT,SUM(QTY) QTY
 FROM [dm].[Fct_ERP_Stock_MisdStock]  T
LEFT JOIN [dm].[Fct_ERP_Stock_MisdStockENTRY] T1 ON T1.MisdStock_ID=T.MisdStock_ID
where Bill_Type='报废出库单'
GROUP BY T1.SKU_ID,LEFT(LOT,8),UNIT
) T1 ON T1.SKU_ID=PROD.SKU_ID AND T1.LOT=PROD.Produce_Date
LEFT JOIN (
-------取目前库存的数据
SELECT SKU_ID,
LEFT(LOT,8) LOT,
Sale_Unit,
SUM(Sale_QTY) Inventory_QTY
  FROM [dm].[Fct_ERP_Stock_Inventory]
  WHERE Datekey IN (
 
SELECT MAX(Datekey)
  FROM [dm].[Fct_ERP_Stock_Inventory]
  )
  GROUP BY SKU_ID,
LEFT(LOT,8),
Sale_Unit) T2 ON T2.SKU_ID=PROD.SKU_ID AND T2.LOT=PROD.Produce_Date
ORDER BY prod.Produce_Date
end 
GO
