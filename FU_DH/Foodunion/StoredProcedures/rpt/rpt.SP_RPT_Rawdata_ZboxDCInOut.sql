USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROC [rpt].[SP_RPT_Rawdata_ZboxDCInOut]
AS
BEGIN


	--------------------------------------------------------------------------------------------------

	DROP TABLE IF EXISTS #InventoryDates;
	;WITH InventoryDates AS
	(SELECT DISTINCT Datekey,DENSE_RANK() OVER(Order by Datekey DESC) RID FROM [dm].[Fct_Qulouxia_DCInventory_Daily])
	SELECT CONCAT(a.Datekey,'-',b.Datekey) AS 'Period',a.Datekey AS StartDate,b.Datekey AS EndDate,b.RID
	INTO #InventoryDates
	FROM InventoryDates a
	JOIN InventoryDates b ON a.RID=b.RID+1;

	--SELECT *FROM #InventoryDates;
	SELECT 
		[Period]
		,CAST(a.StartDate AS VARCHAR(20)) AS [Header]
		,inv1.SKU_ID
		,p.SKU_Name
		,CONVERT(VARCHAR(10),inv1.Produce_Date,111) AS Produce_Date
		--,inv1.Expiry_Date
		,SUM(inv1.Inventory_QTY) AS [Value]
	FROM  #InventoryDates a
	JOIN [dm].[Fct_Qulouxia_DCInventory_Daily] inv1 ON a.StartDate = inv1.Datekey
	JOIN dm.Dim_Product p on inv1.SKU_ID=p.SKU_ID
	GROUP BY [Period]
		,CAST(a.StartDate AS VARCHAR(20)) 
		,inv1.SKU_ID,p.SKU_Name
		,inv1.Produce_Date
	UNION
	SELECT 
		[Period]
		,CAST(a.EndDate AS VARCHAR(20)) AS [Header]
		,inv2.SKU_ID
		,p.SKU_Name
		,CONVERT(VARCHAR(10),inv2.Produce_Date,111)
		--,inv2.Expiry_Date
		,SUM(inv2.Inventory_QTY) AS [Value]
	FROM  #InventoryDates a
	LEFT JOIN [dm].[Fct_Qulouxia_DCInventory_Daily] inv2 ON a.EndDate = inv2.Datekey
	JOIN dm.Dim_Product p on inv2.SKU_ID=p.SKU_ID
	GROUP BY [Period]
		,CAST(a.EndDate AS VARCHAR(20)) 
		,inv2.SKU_ID,p.SKU_Name
		,inv2.Produce_Date
	UNION
	SELECT 
		[Period]
		,'DC2Box' AS [Header]
		,d2b.SKU_ID
		,p.SKU_Name
		,CONVERT(VARCHAR(10),d2b.Prod_Date,111)
		--,inv2.Expiry_Date
		,SUM(d2b.Send_Num) AS [Value]
	FROM  #InventoryDates a
	JOIN [dm].[Fct_Qulouxia_DC2Box] d2b WITH(NOLOCK) ON Convert(varchar(8),d2b.Create_Date,112) > a.StartDate AND Convert(varchar(8),d2b.Create_Date,112) <= a.EndDate
	JOIN dm.Dim_Product p on d2b.SKU_ID=p.SKU_ID
	GROUP BY [Period]
		,d2b.SKU_ID,p.SKU_Name
		,d2b.Prod_Date

	--UNION
	--SELECT 
	--	[Period]
	--	,'FU2DC' AS [Header]
	--	,ose.SKU_ID AS SKU_ID
	--	,ose.Produce_Date 
	--	--,inv2.Expiry_Date
	--	,SUM(cast(ose.Sale_Unit_QTY as int)) AS [Value]
	--FROM #InventoryDates inv
	--LEFT JOIN dm.Fct_ERP_Stock_OutStock os ON os.Datekey>inv.StartDate AND os.Datekey<=inv.EndDate AND os.Bill_Type='标准销售出库单'
	--LEFT JOIN dm.Fct_ERP_Stock_OutStockEntry ose on os.OutStock_ID=ose.OutStock_ID AND ose.Stock_Name='去楼下寄售仓'
	--GROUP BY [Period]
	--	,ose.SKU_ID 
	--	,ose.Produce_Date 
	UNION
	SELECT 
		[Period]
		,'Return2DC' AS [Header]
		,NULL AS SKU_ID
		,NULL
		,NULL AS Prod_Date
		--,inv2.Expiry_Date
		,NULL AS [Value]
	FROM #InventoryDates
	UNION
	SELECT 
		[Period]
		,'FU2DC' AS [Header]
		,NULL AS SKU_ID
		,NULL
		,NULL AS Prod_Date
		--,inv2.Expiry_Date
		,NULL AS [Value]
	FROM #InventoryDates
	--------------------------------------------------------------------------------------------------

END
GO
