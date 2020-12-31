USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [rpt].[SP_RPT_Fxxk_SKUList_UpdateInsert]
AS
BEGIN

	--更新部分
	
	SELECT  ods._id AS ID,
		p.SKU_ID,
		ods.spu_id,
		ods.barcode,
		CASE p.Bar_Code WHEN '' THEN '0' ELSE p.Bar_Code END as new_bar_code,	
		ods.name,
		p.SKU_Name_S as new_name,
		ods.sku_name_en,
		p.SKU_Name as new_name_en,
		ods.price,
		isnull(p.Sale_Unit_RSP,ods.price) as new_price,
		ods.brand,
		ods.category,
		ods.unit,
		ods.product_status,
		case WHEN p.Status ='Active' THEN 1 ELSE 2 END AS new_product_status,
		ods.shelf_life,
		p.Shelf_Life_D AS new_shelf_life,
		ods.life_status,
		p.SKU_Name_CN,		
		p.Status,		
		'Update' as Operation
	FROM dm.Dim_Product p WITH(NOLOCK)
	JOIN ODS.ODS.Fxxk_SKUList ods
	ON p.SKU_ID=ods.product_code
	WHERE ods.product_status=1
	AND (
		ods.barcode <> CASE p.Bar_Code WHEN '' THEN '0' ELSE p.Bar_Code END
		OR 
		isnull(ods.sku_name_en,'') <> p.SKU_NAME
		OR 
		ods.product_status <> CASE WHEN p.Status ='Active' THEN 1 ELSE 2 END
		--OR 
		--isnull(ods.name,'') <> p.SKU_Name_S
		)
	--AND SKU_ID='1184001'

	--新增部分
	--UNION ALL
	--SELECT ods._id AS ID,
	--	p.SKU_ID,
	--	ods.spu_id,
	--	ods.barcode,
	--	CASE p.Bar_Code WHEN '' THEN '0' ELSE p.Bar_Code END as new_bar_code,	
	--	ods.name,
	--	p.SKU_Name_S as new_name,
	--	ods.sku_name_en,
	--	p.SKU_Name as new_name_en,
	--	ods.price,
	--	isnull(p.Sale_Unit_RSP,ods.price) as new_price,
	--	ods.brand,
	--	ods.category,
	--	ods.unit,
	--	ods.product_status,
	--	case WHEN p.Status ='Active' THEN 1 ELSE 2 END AS new_product_status,
	--	ods.shelf_life,
	--	p.Shelf_Life_D AS new_shelf_life,
	--	ods.life_status,
	--	p.SKU_Name_CN,		
	--	p.Status,		
	--	'Insert' as Operation
	--FROM dm.Dim_Product p WITH(NOLOCK)
	--LEFT JOIN ODS.ODS.Fxxk_SKUList ods
	--ON p.SKU_ID=ods.product_code AND ods.product_status=1
	--WHERE p.[Status] = 'Active' AND p.IsEnabled=1 AND p.SKU_Name_S IS NOT NULL
	----AND 
	--AND ods.product_code IS NULL

	--;

END

--select *from ODS.ODS.Fxxk_SKUList ods
--where product_code='1182004'

--SELECT  * from dm.dim_product where SKU_ID like '1182004%'


--1122001
GO
