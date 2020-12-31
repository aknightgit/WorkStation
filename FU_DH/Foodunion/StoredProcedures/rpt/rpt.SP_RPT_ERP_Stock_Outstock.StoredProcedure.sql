USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_ERP_Stock_Outstock]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [rpt].[SP_RPT_ERP_Stock_Outstock]
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
	   ,Price_Unit_QTY AS [Order_QTY]
	   ,Price_Unit_QTY AS [Actual_QTY]
	   ,Price_Unit AS Unit_Dsc
	   ,sie.Base_Unit_QTY AS Base_Unit_QTY
	   ,sie.Base_Unit AS Base_Unit
	   ,Price_Unit_QTY*prod.Sale_Unit_Weight_KG/1000 AS [Weight]
	   ,sie.Update_Time AS [Update_Time]
FROM [dm].[Fct_ERP_Stock_OutStockEntry] sie
LEFT JOIN [dm].[Fct_ERP_Stock_OutStock] si ON sie.OutStock_ID = si.OutStock_ID
LEFT JOIN [dm].[Dim_Warehouse] wh ON sie.Stock_Name = wh.[Warehouse_Name]
LEFT JOIN dm.Dim_Product prod ON sie.SKU_ID = prod.SKU_ID
WHERE wh.[WHS_ID] IS NOT NULL
UNION ALL
SELECT 
		wh.[WHS_ID]
	   ,ti.Datekey
	   ,ti.Bill_Type
	   ,ti.Bill_No
	   ,tie.SKU_ID
	   ,tie.LOT_Display AS Batch_CD
	   ,tie.Produce_Date AS [Manufacturing_DT]
	   ,tie.[Exipry_Date] AS [Expiring_DT]
	   ,QTY AS [Order_QTY]
	   ,QTY AS [Actual_QTY]
	   ,Unit AS Unit_Dsc
	   ,tie.Base_Unit_QTY
	   ,tie.Base_Unit
	   ,QTY*prod.Sale_Unit_Weight_KG/1000 AS [Weight]
	   ,tie.Update_Time AS [Update_Time]
FROM [dm].[Fct_ERP_Stock_TransferOutEntry] tie
LEFT JOIN [dm].[Fct_ERP_Stock_TransferOut] ti ON tie.TransID = ti.TransID
LEFT JOIN [dm].[Dim_Warehouse] wh ON tie.Source_Stock = wh.[Warehouse_Name]
LEFT JOIN dm.Dim_Product prod ON tie.SKU_ID = prod.SKU_ID
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
	   ,CASE WHEN mie.Unit = sku.Sale_Unit THEN QTY ELSE QTY*cr.Convert_Rate END*prod.Sale_Unit_Weight_KG/1000 AS [Weight]
	   ,mie.Update_Time AS [Update_Time]
FROM [dm].[Fct_ERP_Stock_MisdStockEntry] mie
LEFT JOIN [dm].[Fct_ERP_Stock_MisdStock] mi ON mie.MisdStock_ID = mi.MisdStock_ID
LEFT JOIN [dm].[Dim_Warehouse] wh ON mie.Stock_Name = wh.[Warehouse_Name]
LEFT JOIN dm.Dim_Product prod ON mie.SKU_ID = prod.SKU_ID
LEFT JOIN ods.[ods].[ERP_SKU_List] sku ON mie.SKU_ID = sku.SKU_ID
LEFT JOIN [dm].[Dim_ERP_Unit_ConvertRate] cr ON mie.Unit = cr.From_Unit AND sku.Sale_Unit = cr.To_Unit
WHERE wh.[WHS_ID] IS NOT NULL





END

GO
