USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [rpt].[SP_RTP_Sales_ByStoreByDay_YHCRV] 
	
AS
BEGIN

	--Part1 ： KA Sales
	SELECT CASE s.Channel_Account WHEN 'Vanguard' THEN 'CRV' ELSE s.Channel_Account END AS Channel
		,REPLACE(REPLACE(s.Store_Province,'省',''),'市','') AS Region
		,c.Week_Nature_Str AS 'Week'
		,c.Week_of_Year AS Week_No
		,ka.Datekey
		,c.Date_Str AS 'Date_Str'
		,s.Account_Store_Code AS Store_Code
		,s.Store_Name AS Store_Name
		--,p.Brand_Name AS Brand
		--,p.Product_Sort AS Sort
		--,p.Product_Category AS Category
		--,ka.SKU_ID 
		--,p.SKU_Name
		--,p.SKU_Name_CN		
		--,p.Sale_Scale
		--,p.Sale_Unit_RSP AS RSP
		,SUM(ka.Sales_AMT) AS 'Sales_AMT'
		,SUM(ka.Sales_Qty) AS 'Sales_QTY'
	FROM [dm].[Fct_KAStore_DailySalesInventory] ka WITH(NOLOCK)
	JOIN [dm].[Dim_Calendar] c WITH(NOLOCK) on ka.[DateKey] = C.Datekey
	JOIN [dm].[Dim_Product] p WITH(NOLOCK)  on ka.SKU_ID = p.SKU_ID	
	JOIN [dm].[Dim_Store] s WITH(NOLOCK) ON ka.Store_ID = s.Store_ID
	WHERE ka.Datekey>=20191230
	AND S.Channel_Account IN ('Vanguard','YH')
	AND ka.Sales_Qty>0
	GROUP BY CASE s.Channel_Account WHEN 'Vanguard' THEN 'CRV' ELSE s.Channel_Account END 
		,REPLACE(REPLACE(s.Store_Province,'省',''),'市','')
		,c.Week_Nature_Str
		,c.Week_of_Year 
		,ka.Datekey
		,c.Date_Str 
		,s.Account_Store_Code
		,s.Store_Name ;
END

	

	--select top 100 * from dm.Fct_Sales_SellOut_ByChannel ss
	--select top 100 * from dm.Fct_Sales_SellOut_byChannel_byRegion where Channel_ID=71
GO
