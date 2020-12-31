USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_InventoryFLow_End2End]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [rpt].[SP_RPT_InventoryFLow_End2End]
AS
BEGIN

	
	SELECT 
		inv.Datekey
		,CASE 
			WHEN w.Warehouse_Name LIKE '%质检仓%' THEN 0
			WHEN w.Org_Group IN ('JV1-Dongying','JV1-SH','JV1-澳雅','JV1-生产线','JV2-Hohhot','Shanghai','Shanghai Production line') THEN 1
			WHEN w.Org_Group IN ('RDC') THEN 2
			WHEN w.Org_Group IN ('2C/2B') THEN 3 END AS Group_ID
		,w.Org_Group AS Warehouse_Group
		,w.Warehouse_Name
		,p.SKU_ID
		,p.SKU_Name_CN
		,inv.LOT
		,inv.Stock_Unit
		,inv.Stock_QTY
		,inv.Sale_Unit
		,inv.Sale_QTY
		,inv.Sale_QTY * p.Sale_Unit_Weight_KG/1000 AS Volume_MT
		,ISNULL(inbill.Sale_QTY,0) AS In_QTY
		,ISNULL(outbill.Sale_QTY,0) AS Out_QTY
		,CAST(inv.Produce_Date AS DATE) Produce_Date
		,CAST(inv.Expiry_Date AS DATE) Expiry_Date
		,CASE WHEN GETDATE()>=inv.Expiry_Date THEN 'Y' ELSE 'N' END AS Expired
		,CASE WHEN CAST(DATEDIFF("DAY",inv.Produce_Date,GETDATE())*1.0/DATEDIFF("DAY",inv.Produce_Date,inv.Expiry_Date) AS DECIMAL(9,2)) <=0.333 THEN '<1/3' 
			WHEN CAST(DATEDIFF("DAY",inv.Produce_Date,GETDATE())*1.0/DATEDIFF("DAY",inv.Produce_Date,inv.Expiry_Date) AS DECIMAL(9,2)) BETWEEN 0.333 AND 0.5 THEN '1/3~1/2'
			WHEN CAST(DATEDIFF("DAY",inv.Produce_Date,GETDATE())*1.0/DATEDIFF("DAY",inv.Produce_Date,inv.Expiry_Date) AS DECIMAL(9,2)) BETWEEN 0.5 AND 0.667 THEN '1/2~2/3'
			WHEN CAST(DATEDIFF("DAY",inv.Produce_Date,GETDATE())*1.0/DATEDIFF("DAY",inv.Produce_Date,inv.Expiry_Date) AS DECIMAL(9,2)) BETWEEN 0.667 AND 1 THEN '>2/3'
			ELSE 'Expired'
			END AS 'Effetive_Tag'
	FROM dm.Fct_ERP_Stock_Inventory inv WITH(NOLOCK)
	JOIN dm.Dim_Product p WITH(NOLOCK) ON inv.SKU_ID = p.SKU_ID
	JOIN dm.Dim_Warehouse w WITH(NOLOCK) ON inv.Stock_ID = w.WHS_ID	
	LEFT JOIN ( ----IN 进货
		SELECT  Stock_Name 
			,SKU_ID
			,LOT
			,MAX(Sale_Unit) AS Sale_Unit
			,SUM(Sale_QTY) AS Sale_QTY
		FROM(
			SELECT ose.Stock_Name 
				,ose.SKU_ID
				,ose.LOT
				,MAX(ose.Sale_Unit) AS Sale_Unit
				,SUM(ose.Sale_Unit_QTY) AS Sale_QTY
			FROM [dm].[Fct_ERP_Stock_InStock] os
			JOIN [dm].[Fct_ERP_Stock_InStockEntry] ose ON os.InStock_ID=ose.InStock_ID
			WHERE os.Bill_Type='委外入库单'
				GROUP BY ose.Stock_Name
				,ose.SKU_ID
				,ose.LOT		
			UNION
			SELECT stie.Dest_Stock
				,stie.SKU_ID
				,stie.LOT
				,MAX(stie.Sale_Unit) AS Sale_Unit
				,SUM(stie.Sale_QTY) AS Sale_QTY
			FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
			JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
			WHERE sti.Bill_Type='质检调拨单'
			GROUP BY  stie.Dest_Stock
				,stie.SKU_ID
				,stie.LOT
			UNION
			SELECT stie.Dest_Stock
				,stie.SKU_ID
				,stie.LOT
				,MAX(stie.Sale_Unit) AS Sale_Unit
				,SUM(stie.Sale_QTY) AS Sale_QTY
			FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
			JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
			WHERE sti.Bill_Type IN ('标准直接调拨单','标准分步式调入单')
			GROUP BY  stie.Dest_Stock
				,stie.SKU_ID
				,stie.LOT
			)a GROUP BY  Stock_Name 
			,SKU_ID
			,LOT
		)inbill ON inv.SKU_ID=inbill.SKU_ID AND inv.LOT=inbill.LOT AND inv.Stock_Name=inbill.Stock_Name	

	LEFT JOIN (   --OUT 出货
		SELECT  Stock_Name 
			,SKU_ID
			,LOT
			,MAX(Sale_Unit) AS Sale_Unit
			,SUM(Sale_QTY) AS Sale_QTY
		FROM(
			SELECT stie.Source_Stock AS Stock_Name
				,stie.SKU_ID
				,stie.LOT
				,MAX(stie.Sale_Unit) AS Sale_Unit
				,SUM(stie.Sale_QTY) AS Sale_QTY
			FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
			JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
			WHERE sti.Bill_Type IN('质检调拨单','标准直接调拨单')
			GROUP BY  stie.Source_Stock
				,stie.SKU_ID
				,stie.LOT
			UNION
			SELECT ose.Stock_Name
				,ose.SKU_ID
				,ose.LOT
				,MAX(p.Sale_Unit) AS Sale_Unit
				,SUM(ose.Real_QTY*ISNULL(uc.Convert_Rate,1)) AS Sale_QTY
			FROM [dm].[Fct_ERP_Stock_OutStock] os WITH(NOLOCK)
			JOIN [dm].[Fct_ERP_Stock_OutStockEntry] ose WITH(NOLOCK) ON os.OutStock_ID=ose.OutStock_ID	
			JOIN dm.Dim_Product p WITH(NOLOCK) ON ose.SKU_ID = p.SKU_ID
			LEFT JOIN dm.Dim_ERP_Unit_ConvertRate uc ON ose.Unit=uc.From_Unit and p.Sale_Unit=uc.To_Unit
			WHERE os.Bill_Type='标准销售出库单'
			GROUP BY ose.Stock_Name
				,ose.SKU_ID
				,ose.LOT	
		)b GROUP BY   Stock_Name 
			,SKU_ID
			,LOT
		) outbill ON  inv.SKU_ID=outbill.SKU_ID AND inv.LOT=outbill.LOT AND inv.Stock_Name=outbill.Stock_Name
	WHERE inv.Datekey = (SELECT MAX(Datekey) FROM dm.Fct_ERP_Stock_Inventory WITH(NOLOCK))
	AND inv.Stock_QTY>0
	AND inv.Stock_Name NOT LIKE '%猫武士%'  --猫武士仍然采用手工上传数据
	--AND inv.SKU_ID='1120005'
	--AND Warehouse_Name='恒知上海仓'
	--ORDER BY 1

	UNION 
	
	--猫武士数据
	SELECT 
		i.Inventory_DT AS Datekey
		,2 AS Group_ID
		,w.Org_Group AS Warehouse_Group
		,w.Warehouse_Name
		,p.SKU_ID
		,p.SKU_Name_CN
		,i.Batch_CD AS LOT
		,'Tray' AS Stock_Unit
		,i.Inventory_QTY / p.Qty_SaleInTray AS Stock_QTY
		,p.Sale_Unit AS Sale_Unit
		,i.Inventory_QTY AS Sale_QTY
		,i.Inventory_QTY * p.Sale_Unit_Weight_KG/1000 AS Volume_MT
		,i.Inventory_QTY AS In_QTY
		,0 AS Out_QTY
		,CAST(i.Manufacturing_DT AS DATE) Produce_Date
		,CAST(i.Expiring_DT AS DATE) Expiry_Date
		,CASE WHEN GETDATE()>=i.Expiring_DT THEN 'Y' ELSE 'N' END AS Expired
		,CASE WHEN CAST(DATEDIFF("DAY",i.Manufacturing_DT,GETDATE())*1.0/DATEDIFF("DAY",i.Manufacturing_DT,i.Expiring_DT) AS DECIMAL(9,2)) <=0.333 THEN '<1/3' 
			WHEN CAST(DATEDIFF("DAY",i.Manufacturing_DT,GETDATE())*1.0/DATEDIFF("DAY",i.Manufacturing_DT,i.Expiring_DT) AS DECIMAL(9,2)) BETWEEN 0.333 AND 0.5 THEN '1/3~1/2'
			WHEN CAST(DATEDIFF("DAY",i.Manufacturing_DT,GETDATE())*1.0/DATEDIFF("DAY",i.Manufacturing_DT,i.Expiring_DT) AS DECIMAL(9,2)) BETWEEN 0.5 AND 0.667 THEN '1/2~2/3'
			WHEN CAST(DATEDIFF("DAY",i.Manufacturing_DT,GETDATE())*1.0/DATEDIFF("DAY",i.Manufacturing_DT,i.Expiring_DT) AS DECIMAL(9,2)) BETWEEN 0.667 AND 1 THEN '>2/3'
			ELSE 'Expired'
			END AS 'Effetive_Tag'
	FROM dm.[Fct_Inventory] i with(NOLOCK)
	JOIN dm.Dim_Product p with(NOLOCK) on i.SKU_ID=p.SKU_ID 
	JOIN dm.Dim_Warehouse w  with(NOLOCK) on i.Warehouse_ID=w.WHS_ID 
	WHERE i.Inventory_DT = (SELECT MAX(Datekey) FROM dm.Fct_ERP_Stock_Inventory WITH(NOLOCK))
	AND w.Warehouse_Name LIKE '%猫武士%'


	UNION
	--YH/VG

	--YH/VG/KW数据
	SELECT 
		ka.Datekey AS Datekey
		,4 AS Group_ID
		,'KA' AS Warehouse_Group
		,s.Channel_Account AS Warehouse_Name
		,p.SKU_ID
		,p.SKU_Name_CN
		,'Unknown' AS LOT
		,'Tray' AS Stock_Unit
		,ka.Inventory_QTY / p.Qty_SaleInTray AS Stock_QTY
		,p.Sale_Unit AS Sale_Unit
		,ka.Inventory_QTY AS Sale_QTY
		,ka.Inventory_QTY * p.Sale_Unit_Weight_KG/1000 AS Volume_MT
		,ka.Inventory_QTY AS In_QTY   --KA, 以库存数量为入库，出库=0
		,0 AS Out_QTY
		,NULL AS Produce_Date
		,NULL AS Expiry_Date
		,'Unknown' AS Expired
		,'Unknown' AS 'Effetive_Tag'
	FROM dm.Fct_KAStore_DailySalesInventory ka with(NOLOCK)
	JOIN dm.Dim_Product p with(NOLOCK) on ka.SKU_ID=p.SKU_ID 
	JOIN dm.Dim_Store s with(NOLOCK) on ka.Store_ID=s.Store_ID  
	WHERE ka.Datekey = (SELECT MAX(Datekey) FROM dm.Fct_ERP_Stock_Inventory WITH(NOLOCK))
	AND CHARINDEX('_',ka.SKU_ID) =0  --不要类似 2100001-0这种SKU


END



--select top 100 * from  [dm].[Fct_ERP_Stock_Inventory]
--where stock_Name like '%质检%'
--order  by 1 desc
--select top 1000 * from dm.Dim_Warehouse order by 3
--DELETE FROM  dm.Dim_Warehouse WHERE Whs_id in (231603,146429)
--update dm.Dim_Warehouse  set warehouse_name_en='Semi' where WHS_ID=108927
--SELECT * FROM dm.Dim_Warehouse
--select top 100 * from dm.Dim_Product

--SELECT TOP 100 * FROM DM.Fct_KAStore_DailySalesInventory
--WHERE Datekey=20190825

--SELECT * FROM dm.Fct_KAStore_DailySalesInventory ka with(NOLOCK)
--WHERE SKU_ID='1110002'
--AND Datekey=20190825
--AND Store_ID LIKE 'KW%'
GO
