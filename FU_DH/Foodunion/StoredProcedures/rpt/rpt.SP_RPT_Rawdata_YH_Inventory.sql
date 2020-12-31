USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [rpt].[SP_RPT_Rawdata_YH_Inventory]
AS
BEGIN

	select 
		inv.Calendar_DT AS Datekey,
		CASE WHEN s.Account_Store_Code like 'W%' THEN 'YH RDC' ELSE 'YH Store' END AS Stock,
		s.Store_Province_EN AS Province,
		s.Account_Store_Code,
		s.Store_Name,
		p.Plant,
		p.Brand_Name,
		p.Product_Sort,
		p.Product_Category,
		p.SKU_ID,
		p.SKU_Name,
		sum(Inventory_QTY) AS QTY,
		sum(Inventory_QTY * p.Sale_Unit_Weight_KG) AS Weight_KG
	from [dm].[Fct_YH_Sales_Inventory] inv WITH(NOLOCK)
	join [dm].[Dim_Store] s WITH(NOLOCK) on inv.Store_ID=s.Store_ID AND s.Channel_Account = 'YH'
	join [dm].[Dim_Product] p WITH(NOLOCK) on inv.SKU_ID = p.SKU_ID
	--where inv.Calendar_DT=20190627
	WHERE inv.Calendar_DT >= CONVERT(VARCHAR(8),GETDATE()-90,112)
	group by inv.Calendar_DT ,
		CASE WHEN s.Account_Store_Code like 'W%' THEN 'YH RDC' ELSE 'YH Store' END,
		s.Store_Province_EN ,
		s.Account_Store_Code,
		s.Store_Name,
		p.Plant,
		p.Brand_Name,
		p.Product_Sort,
		p.Product_Category,
		p.SKU_ID,
		p.SKU_Name
	order by Datekey DESC,Stock,Province,Product_Sort,Product_Category

END
GO
