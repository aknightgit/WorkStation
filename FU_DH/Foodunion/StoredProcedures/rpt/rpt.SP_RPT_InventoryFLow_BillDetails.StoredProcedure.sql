USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_InventoryFLow_BillDetails]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [rpt].[SP_RPT_InventoryFLow_BillDetails]
AS
BEGIN

SELECT *, DENSE_RANK() OVER(PARTITION BY SKU_ID ORDER BY Bill_Type)	RID
FROM (

	

	--调拨单
	SELECT 
	--top 100 
		CASE WHEN w.Org_Group IN ('JV1-Dongying','JV1-SH','JV1-澳雅','JV1-生产线','JV2-Hohhot','Shanghai','Shanghai Production line') THEN 1
			WHEN w.Org_Group IN ('RDC') THEN 2
			WHEN w.Org_Group IN ('2C/2B') THEN 3 ELSE 0 END AS Group_ID
		,CAST(sti.Date AS Date) AS Date
		,sti.Bill_Type AS Bill_Type
		,sti.Bill_No
		,'' Customer_Name
		,'' Sale_Dept
		,sti.Document_Status
		,'' Cancel_Status
		,'' Note
		,stie.Sequence_ID
		,stie.SKU_ID
		,stie.LOT
		,stie.Source_Stock
		,stie.Dest_Stock
		,CASE WHEN pu.To_Unit IS NULL THEN stie.Unit ELSE p.Produce_Unit END AS Unit
		,CASE WHEN pu.To_Unit IS NULL THEN stie.QTY ELSE stie.QTY*ISNULL(pu.Convert_Rate,1) END AS QTY  --Produce QTY
		,stie.Sale_Unit AS Sale_Unit
		,stie.Sale_QTY AS Sale_QTY
		--,CASE WHEN uc.To_Unit IS NULL THEN stie.Unit ELSE p.Sale_Unit END AS Sale_Unit
		--,CASE WHEN uc.To_Unit IS NULL THEN stie.QTY ELSE stie.QTY*ISNULL(uc.Convert_Rate,1) END AS Sale_QTY  --Sale QTY
	FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
	JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
	JOIN dm.Dim_Product p WITH(NOLOCK) ON stie.SKU_ID = p.SKU_ID
	LEFT JOIN dm.Dim_ERP_Unit_ConvertRate uc ON stie.Unit=uc.From_Unit and p.Sale_Unit=uc.To_Unit
	LEFT JOIN dm.Dim_ERP_Unit_ConvertRate pu ON stie.Unit=pu.From_Unit and p.Produce_Unit=pu.To_Unit
	LEFT JOIN dm.Dim_Warehouse w ON stie.Source_Stock = w.Warehouse_Name
	--WHERE STIE.SKU_ID='1120005'
	--select top 1000 * from dm.Dim_ERP_Unit_ConvertRate where from_unit='cls_c'
	--select top 1000 * from dm.Dim_ERP_Unit_ConvertRate where to_unit='cls_c'
	--SELECT * FROM DM.Dim_Product WHERE SKU_ID='1133007'
	--select * from  [dm].[Fct_ERP_Stock_TransferInEntry]  where SKU_ID='1120005'

	UNION

	--出库单
	SELECT 
	--TOP 100 
		CASE WHEN w.Org_Group IN ('JV1-Dongying','JV1-SH','JV1-澳雅','JV1-生产线','JV2-Hohhot','Shanghai','Shanghai Production line') THEN 1
			WHEN w.Org_Group IN ('RDC') THEN 2
			WHEN w.Org_Group IN ('2C/2B') THEN 3 ELSE 0 END AS Group_ID
		,CAST(os.Date AS Date) AS Date
		,os.Bill_Type
		,os.Bill_No
		,os.Customer_Name
		,os.Sale_Dept
		,os.Document_Status
		,os.Cancel_Status
		,os.Note
		,ose.Sequence_ID
		,ose.SKU_ID
		,ose.LOT
		,ose.Stock_Name AS Source_Stock
		,CASE WHEN os.Customer_Name='富友联合食品（中国）有限公司' THEN 'JV' ELSE os.Customer_Name END AS Dest_Stock
		--,ose.Unit
		--,ose.Real_QTY AS QTY
		,CASE WHEN pu.To_Unit IS NULL THEN ose.Unit ELSE p.Produce_Unit END AS Unit
		,CASE WHEN pu.To_Unit IS NULL THEN ose.Real_QTY ELSE ose.Real_QTY*ISNULL(pu.Convert_Rate,1) END AS QTY  --Produce QTY
		,ose.Sale_Unit AS Sale_Unit
		,cast(ose.Sale_Unit_QTY as int) AS Sale_QTY
		--,CASE WHEN uc.To_Unit IS NULL THEN ose.Unit ELSE p.Sale_Unit END AS Sale_Unit
		--,CASE WHEN uc.To_Unit IS NULL THEN ose.Real_QTY ELSE ose.Real_QTY*ISNULL(uc.Convert_Rate,1) END AS Sale_QTY
		--,
	FROM [dm].[Fct_ERP_Stock_OutStock] os WITH(NOLOCK)
	JOIN [dm].[Fct_ERP_Stock_OutStockEntry] ose WITH(NOLOCK) ON os.OutStock_ID=ose.OutStock_ID
	JOIN dm.Dim_Product p WITH(NOLOCK) ON ose.SKU_ID = p.SKU_ID
	LEFT JOIN dm.Dim_ERP_Unit_ConvertRate uc ON ose.Unit=uc.From_Unit and p.Sale_Unit=uc.To_Unit
	LEFT JOIN dm.Dim_ERP_Unit_ConvertRate pu ON ose.Unit=pu.From_Unit and p.Produce_Unit=pu.To_Unit
	LEFT JOIN dm.Dim_Warehouse w ON ose.Stock_Name = w.Warehouse_Name
	WHERE ose.SKU_ID='1120005'
	--WHERE lot='20190602D2002' and P.SKU_ID='1110001'
	--SELECT TOP 19 * FROM [dm].[Fct_ERP_Stock_OutStockEntry]
	--select top 100 * from dm.dim_warehouse where warehouse_name='成品冷藏-合格'
	--select top 100 * from [dm].[Fct_ERP_Stock_OutStock]
	--select top 100 * from [dm].[Fct_ERP_Stock_OutStockEntry] where SKU_ID='1120005'

	UNION 
	
	--入库单
	SELECT 
	--TOP 100 
		CASE WHEN w.Org_Group IN ('JV1-Dongying','JV1-SH','JV1-澳雅','JV1-生产线','JV2-Hohhot','Shanghai','Shanghai Production line') THEN 1
			WHEN w.Org_Group IN ('RDC') THEN 2
			WHEN w.Org_Group IN ('2C/2B') THEN 3 ELSE 0 END AS Group_ID
		,CAST(os.Date AS Date) AS Date
		,os.Bill_Type
		,os.Bill_No
		,os.Purchase_Org AS Customer_Name
		,'' AS Sale_Dept
		,os.Document_Status
		,'' AS Cancel_Status
		,'' AS Note
		,ose.Sequence_ID
		,ose.SKU_ID
		,ose.LOT
		,ISNULL(po.Bill_Type,'') AS Source_Stock
		,ose.Stock_Name AS Dest_Stock
		--,ose.Unit AS Unit
		--,ose.Real_QTY AS Real_QTY
		,CASE WHEN pu.To_Unit IS NULL THEN ose.Unit ELSE p.Produce_Unit END AS Unit
		,CASE WHEN pu.To_Unit IS NULL THEN ose.Real_QTY ELSE ose.Real_QTY*ISNULL(pu.Convert_Rate,1) END AS QTY  --Produce QTY
		,ose.Sale_Unit AS Sale_Unit
		,CAST(ose.Sale_Unit_QTY AS INT) AS Sale_QTY
	FROM [dm].[Fct_ERP_Stock_InStock] os
	JOIN [dm].[Fct_ERP_Stock_InStockEntry] ose ON os.InStock_ID=ose.InStock_ID
	JOIN dm.Dim_Product p WITH(NOLOCK) ON ose.SKU_ID = p.SKU_ID
	LEFT JOIN dm.Dim_ERP_Unit_ConvertRate pu ON ose.Unit=pu.From_Unit and p.Produce_Unit=pu.To_Unit
	LEFT JOIN dm.Dim_Warehouse w ON ose.Stock_Name = w.Warehouse_Name	
	LEFT JOIN [dm].[Fct_ERP_Stock_PurchaseOrder] po ON ose.SourceBillNo = po.Bill_No
	--WHERE os.Bill_No='10WE000193'
	--WHERE ose.SKU_ID='1120005'

	/*
	UNION
	--销售单
	SELECT 
	--TOP 100 
		4 AS Group_ID
		,CAST(os.Date AS Date) AS Date
		,os.Bill_Type
		,os.Bill_No
		,os.Customer_Name
		,os.Sale_Dept
		,os.Document_Status
		,os.Cancel_Status
		,os.Note
		,ose.Sequence_ID
		,ose.SKU_ID
		,ose.LOT
		,'' AS Source_Stock
		,os.Customer_Name AS Dest_Stock
		,ose.Unit AS Unit
		,ose.QTY AS QTY
		,ose.Sale_Unit AS Sale_Unit
		,ose.Sale_Unit_QTY AS Sale_QTY
	FROM [dm].[Fct_ERP_Sale_Order] os
	JOIN [dm].[Fct_ERP_Sale_OrderEntry] ose ON os.Sale_Order_ID=ose.Sale_Order_ID
	JOIN dm.Dim_Product p WITH(NOLOCK) ON ose.SKU_ID = p.SKU_ID
	--LEFT JOIN dm.Dim_Warehouse w ON ose.Stock_Name = w.Warehouse_Name
	--WHERE os.Bill_No='10WE000193'
	*/
)a
--WHERE lot='20190602D2002' and SKU_ID='1110001'
END


--SELECT TOP 100 * FROM [dm].[Fct_ERP_Stock_InStockEntry] where instock_id=101276 and sku_id='1110001'
--select top 10 * from [dm].[Fct_ERP_Stock_InStock] os where Bill_No='10WE000193'
--select * from dm.Dim_Warehouse where Warehouse_Name='成品常温-可用(SH)'
--select top 100 *from [dm].[Fct_ERP_Stock_InStock] where Bill_No='10WE000238'
--select top 100 *from [dm].[Fct_ERP_Stock_InStockEntry] where InStock_ID='100944'
--select top 1000 *from [dm].[Fct_ERP_Stock_InStockEntry] order by 1 desc

----select top 100 * from [dm].[Fct_ERP_Stock_TransferIn] where Bill_No='10PO001207'
----select top 100 * from [dm].[Fct_ERP_Stock_OutStock] where Bill_No='10PO001207'
--select top 100 * from [dm].[Fct_ERP_Sale_Order] where Bill_No='10PO001207'
--select top 100 * from [dm].[Fct_ERP_stock_purchaseorder] where Bill_No='10PO001207'
--select top 100 * from [dm].[Fct_ERP_stock_purchaseorderentry] where poorder_id='106007'

--select top 100 * from ods.[stg].[ERP_Stock_InStockEntry] order by 1 desc
--select top 100 * from ods.ods.[ERP_Stock_InStockEntry] order by 1 desc
--select top 100 *from [dm].[Fct_ERP_Stock_TransferIn] where Bill_No='10WE000238'

--select top 10 * from dm.Fct_ERP_Sale_Order 
--select top 10 * from dm.Fct_ERP_Sale_OrderEntry where SKU_ID='1120001' and LOT='20190731D2002'
GO
