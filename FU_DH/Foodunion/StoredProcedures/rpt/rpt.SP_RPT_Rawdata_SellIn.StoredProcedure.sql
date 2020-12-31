USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_Rawdata_SellIn]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [rpt].[SP_RPT_Rawdata_SellIn]
AS
BEGIN

	SELECT c.Year
		,c.Month
		,c.Year_Month
		,c.Week_Year_NBR
		,o.Datekey
		--,o.Sale_Order_ID,
		,dc.ERP_Customer_Name AS Customer_Name
		,isnull(dc.Channel_Category,'Other') AS Customer_Name_EN
		,o.Sale_Dept
		,o.SKU_ID
		,p.SKU_Name
		,p.Product_Sort
		,p.Product_Category
		,p.Plan_Group
		,p.Produce_Unit AS Stock_Unit
		,o.Stock_QTY AS SaleQTY_by_StockUnit
		,p.Sale_Unit
		,o.QTY AS Sale_QTY
		,CAST(o.Amount AS decimal(18,2)) AS Amount
		,CAST(o.Weight_KG AS decimal(18,2)) AS Weight_KG
	FROM [dm].[Fct_Sales_SellIn_ByChannel] o with(NOLOCK)
	JOIN [dm].[Dim_Channel] dc  with(NOLOCK) ON o.Channel_ID=dc.Channel_ID
	JOIN [FU_EDW].[Dim_Calendar] c with(NOLOCK) ON o.DateKey=c.Date_ID
	JOIN [dm].[Dim_Product] p  with(NOLOCK) ON o.SKU_ID=p.SKU_ID
	--order by 1,2,4,5

END

GO
