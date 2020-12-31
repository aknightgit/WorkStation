USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE PROCEDURE [rpt].[SP_RPT_ERP_Stock_Instock]
AS
BEGIN 
	



SELECT 
		wh.[WHS_ID] AS Warehouse_ID
	   ,si.Datekey
	   ,si.Bill_Type
	   ,si.Bill_No
	   ,sie.SKU_ID
	   ,sie.LOT_Display AS Batch_CD
	   ,sie.Produce_Date AS [Manufacturing_DT]
	   ,sie.[Expiry_Date] AS [Expiring_DT]
	   ,Sale_Unit_QTY AS [Order_QTY]
	   ,Sale_Unit_QTY AS [Actual_QTY]
	   ,sie.Sale_Unit AS Unit_Dsc
	   ,sie.Base_Unit_QTY AS Base_Unit_QTY
	   ,sie.Base_Unit AS Base_Unit
	   ,Price_Unit_QTY*prod.Sale_Unit_Weight_KG/1000 AS [Weight]
	   ,sie.Update_Time AS [Update_Time]
FROM [dm].[Fct_ERP_Stock_InStockEntry] sie
LEFT JOIN [dm].[Fct_ERP_Stock_InStock] si ON sie.InStock_ID = si.InStock_ID
LEFT JOIN [dm].[Dim_Warehouse] wh ON sie.Stock_Name = wh.[Warehouse_Name]
LEFT JOIN dm.Dim_Product prod ON sie.SKU_ID = prod.SKU_ID
WHERE wh.[WHS_ID] IS NOT NULL
UNION ALL
SELECT 
		wh.[WHS_ID] AS Warehouse_ID
	   ,ti.Datekey
	   ,ti.Bill_Type
	   ,ti.Bill_No
	   ,tie.SKU_ID
	   ,tie.LOT_Display AS Batch_CD
	   ,tie.Produce_Date AS [Manufacturing_DT]
	   ,tie.[Exipry_Date] AS [Expiring_DT]
	   ,Sale_QTY AS [Order_QTY]
	   ,Sale_QTY AS [Actual_QTY]
	   ,tie.Sale_Unit AS Unit_Dsc
	   ,tie.Base_Unit_QTY AS Base_Unit_QTY
	   ,tie.Base_Unit AS Base_Unit
	   ,Price_Unit_QTY*prod.Sale_Unit_Weight_KG/1000 AS [Weight]
	   ,tie.Update_Time AS [Update_Time]
FROM [dm].[Fct_ERP_Stock_TransferInEntry] tie
LEFT JOIN [dm].[Fct_ERP_Stock_TransferIn] ti ON tie.TransID = ti.TransID
LEFT JOIN [dm].[Dim_Warehouse] wh ON tie.Dest_Stock = wh.[Warehouse_Name]
LEFT JOIN dm.Dim_Product prod ON tie.SKU_ID = prod.SKU_ID
WHERE wh.[WHS_ID] IS NOT NULL
UNION ALL
SELECT 
		wh.[WHS_ID] AS Warehouse_ID
	   ,ri.Datekey
	   ,ri.Bill_Type
	   ,ri.Bill_No
	   ,rie.SKU_ID
	   ,rie.LOT_Display AS Batch_CD
	   ,rie.Produce_Date AS [Manufacturing_DT]
	   ,rie.[Expiry_Date] AS [Expiring_DT]
	   ,rie.Sale_Unit_QTY AS [Order_QTY]
	   ,rie.Sale_Unit_QTY AS [Actual_QTY]
	   ,rie.Sale_Unit AS Unit_Dsc
	   ,rie.Base_Unit_QTY AS Base_Unit_QTY
	   ,rie.Base_Unit AS Base_Unit
	   ,Price_Unit_QTY*prod.Sale_Unit_Weight_KG/1000 AS [Weight]
	   ,rie.Update_Time AS [Update_Time]
FROM [dm].[Fct_ERP_Stock_ReturnStockEntry] rie
LEFT JOIN [dm].[Fct_ERP_Stock_ReturnStock] ri ON rie.ReturnStock_ID = ri.ReturnStock_ID
LEFT JOIN [dm].[Dim_Warehouse] wh ON rie.Stock_Name = wh.[Warehouse_Name]
LEFT JOIN dm.Dim_Product prod ON rie.SKU_ID = prod.SKU_ID
WHERE wh.[WHS_ID] IS NOT NULL

UNION ALL
SELECT 
		wh.[WHS_ID] AS Warehouse_ID
	   ,mi.Datekey
	   ,mi.Bill_Type
	   ,mi.Bill_No
	   ,mie.SKU_ID
	   ,mie.LOT_Display AS Batch_CD
	   ,mie.Produce_Date AS [Manufacturing_DT]
	   ,mie.[Expiry_Date] AS [Expiring_DT]
	   ,CASE WHEN mie.Unit = sku.Sale_Unit THEN QTY ELSE QTY*cr.Convert_Rate END AS [Order_QTY]
	   ,CASE WHEN mie.Unit = sku.Sale_Unit THEN QTY ELSE QTY*cr.Convert_Rate END  AS [Actual_QTY]
	   ,sku.Sale_Unit AS Unit_Dsc
	   ,QTY AS Base_Unit_QTY
	   ,Unit AS Base_Unit
	   ,CASE WHEN mie.Unit = sku.Sale_Unit THEN QTY ELSE QTY*cr.Convert_Rate END *prod.Sale_Unit_Weight_KG/1000 AS [Weight]
	   ,mie.Update_Time AS [Update_Time]
FROM [dm].[Fct_ERP_Stock_MiscStockEntry] mie
LEFT JOIN [dm].[Fct_ERP_Stock_MiscStock] mi ON mie.MiscStock_ID = mi.MiscStock_ID
LEFT JOIN [dm].[Dim_Warehouse] wh ON mie.Stock_Name = wh.[Warehouse_Name]
LEFT JOIN dm.Dim_Product prod ON mie.SKU_ID = prod.SKU_ID
LEFT JOIN ods.[ods].[ERP_SKU_List] sku ON mie.SKU_ID = sku.SKU_ID
LEFT JOIN [dm].[Dim_ERP_Unit_ConvertRate] cr ON mie.Unit = cr.From_Unit AND sku.Sale_Unit = cr.To_Unit
WHERE wh.[WHS_ID] IS NOT NULL



END

GO
