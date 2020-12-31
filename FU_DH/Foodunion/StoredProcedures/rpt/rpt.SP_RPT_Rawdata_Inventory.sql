USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [rpt].[SP_RPT_Rawdata_Inventory]
AS
BEGIN

	SELECT 
		i.Datekey--,c.Year,c.Month,c.Week_Year_NBR,
		,w.Tag
		,i.Stock_Name
		,w.Warehouse_Name_EN AS Stock_Name_EN
		,w.Org_Group
		,i.SKU_ID
		,p.SKU_Name
		,p.SKU_Name_CN
		,p.Plant AS 'Prod Site'
		,'' AS 'Plan Group'
		,p.Product_Sort
		,p.Product_Category
		,p.Plan_Group
		,p.Brand_Name
		--,p.Product_Group
		--,CASE WHEN i.Stock_Status='可用' THEN 'Avai'
		,i.LOT AS Flot
		,convert(varchar(10),i.Produce_Date,111) Produce_Date
		,convert(varchar(10),i.Expiry_Date,111) Expiry_Date
		,CASE WHEN i.Expiry_Date>=GETDATE() THEN 'N' ELSE 'Y' END AS 'Expired'
		,cast(CASE WHEN datediff("d",getdate(),i.Expiry_Date) >0 THEN datediff("d",getdate(),i.Expiry_Date) ELSE 0 END as int) AS 'Days_to_Expire'
		,cast(CASE WHEN datediff("d",getdate(),i.Expiry_Date) >0 THEN datediff("d",getdate(),i.Expiry_Date)/7 ELSE 0 END as int) AS 'Weeks_to_Expire'
		,p.Shelf_Life_D AS 'Shelf_Life_D'
		,p.Shelf_Life_D/7 AS'Shelf_Life_Wk'
		,i.Stock_Unit
		,CAST(i.Stock_QTY AS DECIMAL(9,2)) AS Stock_Unit_QTY
		,CAST(Round(i.Sale_QTY * p.Sale_Unit_Weight_KG ,0) AS INT)  AS Weight_KG
		,CASE WHEN CAST(Round(i.Stock_QTY,0) AS INT)>0 THEN 'Stock Qty > 0' ELSE 'Stock Qty = 0' END AS NonZero
		,CASE WHEN i.Expiry_Date<=c.Date THEN 0 ELSE datediff("day",i.Produce_Date,c.Date) END AS 'Days Since Produced' 
		--,i.* 
	FROM [dm].[Fct_ERP_Stock_Inventory] i with(NOLOCK)
	JOIN dm.Dim_Product p with(NOLOCK) on i.SKU_ID=p.SKU_ID 
	JOIN dm.Dim_Warehouse w  with(NOLOCK) on i.Stock_ID=w.WHS_ID 
	LEFT JOIN dm.[Dim_Calendar] c with(NOLOCK) on i.Datekey = c.Datekey
	where i.Stock_Org='富友联合食品（中国）有限公司' AND Stock_Name NOT LIKE '%猫武士%'
	AND i.Datekey>=20200101 AND i.Datekey>=CONVERT(VARCHAR(10),DATEADD(DAY,-90,GETDATE()),112)
	--where (Stock_name like '%jv1%'
	--or Stock_name
	--in ('恒知北京仓'
	--,'恒知成都仓'
	--,'恒知福州仓'
	--,'恒知广州仓'
	--,'恒知合肥仓'
	--,'恒知上海仓'
	--,'恒知重庆仓'
	--,'猫武士北京低温仓'
	--,'猫武士广州低温仓'
	--,'猫武士上海常温仓'
	--,'猫武士上海低温仓'))
	--and i.Datekey=20190626
	--AND i.Stock_QTY >=1\
	UNION ALL
	SELECT 
		i.Inventory_DT AS Datekey
		,w.Tag
		,w.Warehouse_Name
		,w.Warehouse_Name_EN AS Stock_Name_EN
		,w.Org_Group
		,i.SKU_ID
		,p.SKU_Name
		,p.SKU_Name_CN
		,p.Plant AS 'Prod Site'
		,'' AS 'Plan Group'
		,p.Product_Sort
		,p.Product_Category
		,p.Plan_Group
		,p.Brand_Name
		--,p.Product_Group
		--,CASE WHEN i.Stock_Status='可用' THEN 'Avai'
		,i.Batch_CD
		,convert(varchar(10),i.Manufacturing_DT,111) Produce_Date
		,convert(varchar(10),i.Expiring_DT,111) Expiry_Date
		,CASE WHEN i.Expiring_DT>=GETDATE() THEN 'N' ELSE 'Y' END AS 'Expired'
		,cast(CASE WHEN datediff("d",getdate(),i.Expiring_DT) >0 THEN datediff("d",getdate(),i.Expiring_DT) ELSE 0 END as int) AS 'Days_to_Expire'
		,cast(CASE WHEN datediff("d",getdate(),i.Expiring_DT) >0 THEN datediff("d",getdate(),i.Expiring_DT)/7 ELSE 0 END as int) AS 'Weeks_to_Expire'
		,p.Shelf_Life_D AS 'Shelf_Life_D'
		,p.Shelf_Life_D/7 AS'Shelf_Life_Wk'
		,i.Measurement_Sales_DSC
		,CAST(Round(i.Inventory_QTY,0) AS INT) AS Stock_Unit_QTY
		,CAST(Round(i.Inventory_QTY * p.Sale_Unit_Weight_KG ,0) AS INT)  AS Weight_KG
		,CASE WHEN CAST(Round(i.Inventory_QTY,0) AS INT)>0 THEN 'Stock Qty > 0' ELSE 'Stock Qty = 0' END AS NonZero
		,CASE WHEN i.Expiring_DT<=c.Date THEN 0 ELSE datediff("day",i.Manufacturing_DT,c.Date) END AS 'Days Since Produced' 
		--,i.* 
	FROM (SELECT Inventory_DT,SKU_ID,Batch_CD,Manufacturing_DT,Expiring_DT,Measurement_Sales_DSC,Warehouse_ID,
			SUM(Inventory_QTY) AS Inventory_QTY
		FROM dm.[Fct_RDC_Inventory]  with(NOLOCK)
		GROUP BY Inventory_DT,SKU_ID,Batch_CD,Manufacturing_DT,Expiring_DT,Measurement_Sales_DSC,Warehouse_ID
		)i
	JOIN dm.Dim_Product p with(NOLOCK) on i.SKU_ID=p.SKU_ID 
	JOIN dm.Dim_Warehouse w  with(NOLOCK) on i.Warehouse_ID=w.WHS_ID 
	LEFT JOIN dm.[Dim_Calendar] c with(NOLOCK) on i.Inventory_DT = c.Datekey
	where w.Warehouse_Name LIKE '%猫武士%'
	AND i.Inventory_DT>=20200101 AND i.Inventory_DT>=CONVERT(VARCHAR(10),DATEADD(DAY,-90,GETDATE()),112)
	
	ORDER BY i.Datekey desc,Stock_Name,SKU_ID,LOT

END



--select top 100 * from  [dm].[Fct_ERP_Stock_Inventory]
--where stock_Name like '%质检%'
--order  by 1 desc
--select top 1000 * from dm.Dim_Warehouse order by 3
--DELETE FROM  dm.Dim_Warehouse WHERE Whs_id in (231603,146429)
--update dm.Dim_Warehouse  set warehouse_name_en='Semi' where WHS_ID=108927
--SELECT * FROM dm.Dim_Warehouse
GO
