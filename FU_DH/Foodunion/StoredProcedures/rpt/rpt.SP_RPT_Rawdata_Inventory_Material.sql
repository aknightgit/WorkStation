USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [rpt].[SP_RPT_Rawdata_Inventory_Material]
AS
BEGIN

	SELECT 
		si.Datekey
		--,si.Stock_ID
		,si.Stock_Name as Warehouse_Name
		,CASE si.Stock_Name WHEN '上海东营仓' THEN 'Shanghai-Dongying' ELSE sl.Stock_Name_EN END AS Warehouse_Name_EN
		,si.Stock_Org as Stock_Org
		--,CASE si.Stock_Org WHEN '富友联合澳亚乳业有限公司' THEN 'JV1'
		--	WHEN '富友联合圣牧乳品有限公司' THEN 'JV2'
		--	WHEN '富友联合食品（中国）有限公司' THEN 'FUN'
		--	END AS Stock_Org_EN
		,sl.Stock_Org AS Stock_Org_s
		--,sl.Use_Org as Stock_Org2
		--,rm.UseOrg as Stock_Org_EN
		,si.SKU_ID
		,rm.SKU_Name
		,rm.SKU_Name_EN
		,rm.Group_Name	
		,CASE rm.Group_Name WHEN '包材' THEN 'PM' WHEN '原料' THEN 'RM' WHEN '半成品' THEN 'Semi' ELSE rm.Group_Name END AS Group_Name_EN
		,rm.Category
		,si.Flot
		,convert(varchar(10),si.Produce_Date,111) Produce_Date
		,convert(varchar(10),si.Expiry_Date,111) Expiry_Date
		,si.Stock_Unit
		,si.[Base_QTY] * ISNULL(ucs.Convert_Rate,1) AS Stock_QTY
		,si.Base_Unit
		,si.Base_QTY
		,si.Sale_Unit
		,si.[Base_QTY] * ISNULL(ucsa.Convert_Rate,1) AS Sale_QTY
		--,rm.CGLB1 as Group_Name2
		,cast(cast(rm.LifeTime as float) as int) as Shelf_Life_D
		,cast(cast(rm.LifeTime as float)/7 as int) as Shelf_Life_Weeks
		,CASE WHEN datediff("day",getdate(),si.Expiry_Date) <0 
			THEN 0 ELSE datediff("day",getdate(),si.Expiry_Date)
			END AS Days_to_Expiry
		,CASE WHEN datediff("day",getdate(),si.Expiry_Date)/7 <0
			THEN 0 ELSE datediff("day",getdate(),si.Expiry_Date)/7
			END AS Weeks_to_Expiry
		,rm.Unit_Cost
		,rm.Unit_Cost * si.[Base_QTY] * ISNULL(ucs.Convert_Rate,1) AS Stock_Value
		,rm.IsActive 	 
	  FROM ODS.[ods].[ERP_Stock_Inventory] si WITH(NOLOCK)
	  JOIN [dm].[Dim_ERP_RawMaterial] rm  WITH(NOLOCK) ON si.SKU_ID = rm.SKU_ID
	  JOIN [dm].[Dim_ERP_StockList] sl WITH(NOLOCK) ON si.Stock_Name = sl.Stock_Name 
	  LEFT JOIN [dm].[Dim_ERP_Unit_ConvertRate] ucs ON ucs.From_Unit = si.[Base_Unit] AND ucs.To_Unit = si.[Stock_Unit]
	  LEFT JOIN [dm].[Dim_ERP_Unit_ConvertRate] ucsa ON ucsa.From_Unit = si.[Base_Unit] AND ucsa.To_Unit = si.[Sale_Unit]
		 
	  WHERE sl.Stock_Org IN ('JV1-Dongying','Shanghai','Shanghai Production line','JV2-Hohhot')  
	  AND si.Datekey>=20200101
	  --and si.SKU_ID='1215003' 
	  --AND si.Stock_Name='半成品'
	  AND si.[Base_QTY]>0
	  ORDER BY si.SKU_ID,si.Stock_Name
	  

  END

  --select * from [dm].[Dim_ERP_RawMaterial]
  --select * from [dm].[Fct_ERP_Stock_Inventory] where datekey=20190627 AND SKU_ID='1340001' and Stock_QTY>0
  --select * from [dm].[Dim_ERP_StockList] where stock_name in ('原料常温','原料常温-限制(SH)')
  --select * from [dm].[Dim_ERP_StockList] where stock_id in (103704,163495)
  --select * from [dm].[Dim_ERP_RawMaterial] order by 1
  --update [dm].[Dim_ERP_StockList] set Stock_Org='JV1-Dongying' where stock_org='JV1';
  --update [dm].[Dim_ERP_StockList] set Stock_Org='Shanghai' where stock_org='SH';
  --update [dm].[Dim_ERP_StockList] set Stock_Org='JV2-Hohhot' where stock_org='JV2-Holhot';
  --update [dm].[Dim_ERP_StockList] set Stock_Org='Shanghai Production line' where stock_org='SH-生产线';

  --select distinct * into [dm].[Dim_ERP_RawMaterial_20190628] from [dm].[Dim_ERP_RawMaterial] order by 1
  --truncate table [dm].[Dim_ERP_RawMaterial]
  --insert into [dm].[Dim_ERP_RawMaterial] select * from [dm].[Dim_ERP_RawMaterial_20190628] 
GO
