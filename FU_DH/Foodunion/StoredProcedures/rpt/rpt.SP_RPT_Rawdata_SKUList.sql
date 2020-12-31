USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [rpt].[SP_RPT_Rawdata_SKUList]
AS
BEGIN

	SELECT 
		p.SKU_ID
		,CASE WHEN CHARINDEX('_',p.SKU_ID)>0 THEN REPLACE(p.SKU_ID,'_0','') ELSE NULL END AS Parent_SKU_ID
		,p.SKU_Name
		,p.SKU_Name_CN
		,p.Product_Sort
		,p.Product_Group
		,p.Product_Category
		,p.Plan_Group
		,p.Bar_Code
		,p.Unified_Code
		,p.Brand_Name
		,p.Brand_Name_CN
		,p.Brand_IP
		,p.Sale_Scale
		,p.Sale_Unit
		,p.Sale_Unit_Weight_KG
		,p.Sale_Unit_Volumn_L
		,p.Base_Unit
		,p.Base_Unit_Weight_KG
		,p.Qty_BaseInSale 
		,p.Qty_BaseInTray
		,p.Flavor_Group
		,p.Flavor
		,p.Shelf_Life_D
		,p.Plant as JV
		,p.Plant
		,ISNULL(p.Produce_Unit,o.Produce_Unit) AS  Produce_Unit
		--,o.Stock_Weight as Product_Unit_Weight_KG
		,p.Base_Unit_Weight_KG*p.Qty_BaseInTray as Product_Unit_Weight_KG
		--,o.Volumn as Volume
		,p.Status as SKUStatus		
		--,Case o.IsActive WHEN 1 THEN 'Active' ELSE 'Inactive' END as SKUStatus
	FROM dm.Dim_Product p with(nolock)
	LEFT JOIN ODS.[ods].[ERP_SKU_List] o with(nolock) ON p.SKU_ID=o.SKU_ID
	;

END

--select top 100 * from ODS.[ods].[ERP_SKU_List]
--select top 100 * from dm.Dim_Product
--SELECT *FROM ODS.[ods].[ERP_SKU_List]
GO
