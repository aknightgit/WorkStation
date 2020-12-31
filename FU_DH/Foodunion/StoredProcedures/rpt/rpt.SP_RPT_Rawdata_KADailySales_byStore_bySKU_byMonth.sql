USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [rpt].[SP_RPT_Rawdata_KADailySales_byStore_bySKU_byMonth]

AS
BEGIN


	SELECT  
		dc.Year --AS '年'
		,dc.MonthKey --AS '月'
		,dc.Month_Name_Short --AS '月份'
		--,dc.Week_of_Year --AS '周'
		--,dc.Week_Nature_Str --AS '自然周'
		--,ka.Datekey --AS '日'
		--,dc.Date
		--,dc.Week_Day_Name
		--,dc.Date
		,s.Channel_Account AS 'Channel'
		--,s.Account_Area_CN AS 'Region'
		,s.Store_Province_EN AS 'Province'
		,s.Store_Province AS 'Province_CN'
		,s.Store_City_EN AS 'City'
		,s.Store_City AS 'City_CN'
		--,REPLACE(REPLACE(s.Store_Province,'省',''),'市','') AS 'Sales_Area'
		--,s.Sales_Area_CN AS 'Sales_Area'	
		--,s.Store_Type
		,s.Account_Store_Code
		,s.Store_Name
		,p.Brand_Name --AS '品牌'
		,p.Plant --AS '工厂'
		,p.Product_Sort --AS '常低温'
		,p.Product_Category --AS '品类'
		,p.Plan_Group 
		,p.SKU_ID 
		,p.SKU_Name
		,p.SKU_Name_CN
		,p.Sale_Unit
		,SUM(ka.Sales_Qty) AS Sales_Qty
		,SUM(ka.Sales_AMT) AS Sales_AMT
		,SUM(ka.Sales_Qty * p.Sale_Unit_Weight_KG) AS Sales_Vol_KG
		--,SUM(ka.Inventory_Qty) AS Inventory_Qty
		--,SUM(ka.Inventory_Qty * p.Sale_Unit_Weight_KG) AS Inventory_Vol_KG
	FROM dm.Fct_KAStore_DailySalesInventory ka WITH(NOLOCK)
	JOIN dm.Dim_Store s WITH(NOLOCK) on ka.Store_ID=s.Store_ID
	JOIN dm.Dim_Product p WITH(NOLOCK) on ka.SKU_ID=p.sku_id
	JOIN dm.Dim_Calendar dc WITH(NOLOCK) on ka.Datekey=dc.Datekey
	WHERE dc.Monthkey>=202001
		AND s.Channel_Account in ('Vanguard','YH','Huaguan','CenturyMart')
	GROUP BY dc.Year --AS '年'
		,dc.MonthKey --AS '月'
		,dc.Month_Name_Short --AS '月份'
		--,dc.Week_of_Year --AS '周'
		--,dc.Week_Nature_Str --AS '自然周'
		--,ka.Datekey --AS '日'
		--,dc.Date
		--,dc.Week_Day_Name
		--,dc.Date
		,s.Channel_Account 
		,s.Account_Area_CN 
		,s.Store_Province_EN 
		,s.Store_Province
		,s.Store_City_EN
		,s.Store_City
		--,REPLACE(REPLACE(s.Store_Province,'省',''),'市','') AS 'Sales_Area'
		--,s.Sales_Area_CN AS 'Sales_Area'	
		--,s.Store_Type
		,s.Account_Store_Code
		,s.Store_Name
		,p.Brand_Name --AS '品牌'
		,p.Plant --AS '工厂'
		,p.Product_Sort --AS '常低温'
		,p.Product_Category --AS '品类'
		,p.Plan_Group
		,p.SKU_ID 
		,p.SKU_Name
		,p.SKU_Name_CN
		,p.Sale_Unit

	UNION
	SELECT  
		dc.Year --AS '年'
		,dc.MonthKey --AS '月'
		,dc.Month_Name_Short --AS '月份'
		--,dc.Week_of_Year --AS '周'
		--,dc.Week_Nature_Str --AS '自然周'
		--,ka.Datekey --AS '日'
		--,dc.Date
		--,dc.Week_Day_Name
		--,dc.Date
		,s.Channel_Account AS 'Channel'
		--,s.Account_Area_CN AS 'Region'
		,s.Store_Province_EN AS 'Province'
		,s.Store_Province AS 'Province_CN'
		,s.Store_City_EN AS 'City'
		,s.Store_City AS 'City_CN'
		--,REPLACE(REPLACE(s.Store_Province,'省',''),'市','') AS 'Sales_Area'
		--,s.Sales_Area_CN AS 'Sales_Area'	
		--,s.Store_Type
		,s.Account_Store_Code
		,s.Store_Name
		,p.Brand_Name --AS '品牌'
		,p.Plant --AS '工厂'
		,p.Product_Sort --AS '常低温'
		,p.Product_Category --AS '品类'
		,p.Plan_Group 
		,p.SKU_ID 
		,p.SKU_Name
		,p.SKU_Name_CN
		,p.Sale_Unit
		,SUM(ka.Sales_Qty) AS Sales_Qty
		,SUM(ka.Sales_AMT) AS Sales_AMT
		,SUM(ka.Sales_Qty * p.Sale_Unit_Weight_KG) AS Sales_Vol_KG
		--,SUM(ka.Inventory_Qty) AS Inventory_Qty
		--,SUM(ka.Inventory_Qty * p.Sale_Unit_Weight_KG) AS Inventory_Vol_KG
	FROM dm.Fct_Qulouxia_Sales ka WITH(NOLOCK)
	JOIN dm.Dim_Store s WITH(NOLOCK) on ka.Store_ID=s.Store_ID
	JOIN dm.Dim_Product p WITH(NOLOCK) on ka.SKU_ID=p.sku_id
	JOIN dm.Dim_Calendar dc WITH(NOLOCK) on ka.Datekey=dc.Datekey
	WHERE dc.Monthkey>=202001
	GROUP BY dc.Year --AS '年'
		,dc.MonthKey --AS '月'
		,dc.Month_Name_Short --AS '月份'
		--,dc.Week_of_Year --AS '周'
		--,dc.Week_Nature_Str --AS '自然周'
		--,ka.Datekey --AS '日'
		--,dc.Date
		--,dc.Week_Day_Name
		--,dc.Date
		,s.Channel_Account 
		,s.Account_Area_CN 
		,s.Store_Province_EN 
		,s.Store_Province
		,s.Store_City_EN
		,s.Store_City
		--,REPLACE(REPLACE(s.Store_Province,'省',''),'市','') AS 'Sales_Area'
		--,s.Sales_Area_CN AS 'Sales_Area'	
		--,s.Store_Type
		,s.Account_Store_Code
		,s.Store_Name
		,p.Brand_Name --AS '品牌'
		,p.Plant --AS '工厂'
		,p.Product_Sort --AS '常低温'
		,p.Product_Category --AS '品类'
		,p.Plan_Group
		,p.SKU_ID 
		,p.SKU_Name
		,p.SKU_Name_CN
		,p.Sale_Unit

END

GO
