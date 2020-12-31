USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [rpt].[SP_RPT_Rawdata_SellOut_20191018]
AS
BEGIN


SELECT 
	LEFT(sc.Datekey,4) AS Year,
	RIGHT(LEFT(sc.Datekey,6),2) AS Month,
	sc.Datekey AS Date,
	sc.Customer AS Customer,
	sc.SKU AS SKU_ID,
	p.SKU_Name,
	p.Brand_Name,
	p.Product_Sort,
	p.Product_Category,
	p.Plan_Group,
	sc.QTY AS Sale_QTY,
	sc.POS AS Sale_Amount,
	sc.QTY * p.Sale_Unit_Weight_KG AS Weight_kg
FROM [dm].[Fct_Sales_Channel] sc WITH(NOLOCK)
JOIN dm.Dim_Channel c WITH(NOLOCK) ON sc.Channel_ID = c.Channel_ID
JOIN dm.Dim_Product p WITH(NOLOCK) ON sc.SKU = p.SKU_ID
ORDER BY Date DESC,SKU_ID;

END
GO
