USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_Rawdata_SellOut]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [rpt].[SP_RPT_Rawdata_SellOut]
AS
BEGIN


SELECT 
	LEFT(sc.Datekey,4) AS Year,
	RIGHT(LEFT(sc.Datekey,6),2) AS Month,
	sc.Datekey AS Date,
	c.Channel_Name_Display AS Customer,
	sc.SKU_ID AS SKU_ID,
	p.SKU_Name,
	p.Brand_Name,
	p.Product_Sort,
	p.Product_Category,
	p.Plan_Group,
	sc.QTY AS Sale_QTY,
	sc.Amount AS Sale_Amount,
	sc.QTY * p.Sale_Unit_Weight_KG AS Weight_kg
FROM [dm].[Fct_Sales_SellOut_ByChannel] sc WITH(NOLOCK)
JOIN dm.Dim_Channel c WITH(NOLOCK) ON sc.Channel_ID = c.Channel_ID
JOIN dm.Dim_Product p WITH(NOLOCK) ON sc.SKU_ID = p.SKU_ID
ORDER BY Date DESC,SKU_ID;

END
GO
