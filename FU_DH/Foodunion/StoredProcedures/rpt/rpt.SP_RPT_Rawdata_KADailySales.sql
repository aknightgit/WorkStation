USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [rpt].[SP_RPT_Rawdata_KADailySales]

AS
BEGIN

	SELECT  
		dc.Year --AS '年'
		,dc.MonthKey --AS '月'
		,dc.Month_Name_Short --AS '月份'
		,dc.Week_of_Year --AS '周'
		,ka.Datekey --AS '日'
		,dc.Week_Day_Name
		--,dc.Date
		,s.Channel_Account AS 'Channel'
		,s.Account_Area_CN AS 'Region'
		,s.Store_Province AS 'Province'
		,s.Sales_Area_CN AS 'Sales_Area'	
		,p.Brand_Name --AS '品牌'
		,p.Plant --AS '工厂'
		,p.Product_Sort --AS '常低温'
		,p.Product_Category --AS '品类'
		,p.SKU_ID 
		,p.SKU_Name
		,p.SKU_Name_CN
		--,s.Store_Name
		,p.Sale_Unit
		,SUM(ka.Sales_Qty) AS Sales_Qty
		,SUM(ka.Sales_AMT) AS Sales_AMT
		,SUM(ka.Sales_Qty * p.Sale_Unit_Weight_KG) AS Sales_Vol_KG
		,SUM(ka.Inventory_Qty) AS Inventory_Qty
		,SUM(ka.Inventory_Qty * p.Sale_Unit_Weight_KG) AS Inventory_Vol_KG
	FROM dm.Fct_KAStore_DailySalesInventory ka WITH(NOLOCK)
	JOIN dm.Dim_Store s WITH(NOLOCK) on ka.Store_ID=s.Store_ID
	JOIN dm.Dim_Product p WITH(NOLOCK) on ka.SKU_ID=p.sku_id
	JOIN dm.Dim_Calendar dc WITH(NOLOCK) on ka.Datekey=dc.Datekey
	GROUP BY dc.Year
		,dc.MonthKey
		,dc.Month_Name_Short
		,dc.Week_of_Year
		,ka.Datekey 
		,dc.Week_Day_Name
		--,dc.Date
		,s.Channel_Account 
		,s.Account_Area_CN 
		,s.Store_Province 
		,s.Sales_Area_CN 	
		,p.Brand_Name 
		,p.Plant
		,p.Product_Sort 
		,p.Product_Category
		,p.SKU_ID 
		,p.SKU_Name
		,p.SKU_Name_CN
		,p.Sale_Unit

END
GO
