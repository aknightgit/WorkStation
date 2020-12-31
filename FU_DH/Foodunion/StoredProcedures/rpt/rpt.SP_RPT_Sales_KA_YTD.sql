﻿USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










  CREATE PROCEDURE [rpt].[SP_RPT_Sales_KA_YTD]

  AS
  BEGIN
  
select 
 dc.Year
 ,dc.Monthkey AS Year_Month
 ,dc.Week_of_Year AS Week_Year_NBR
 ,ka.Datekey
 ,dc.Date_Str AS Date_NM
 ,DC.Week_Nature_Str
 ,s.Channel_Account
 ,p.SKU_ID
 ,p.SKU_Name_CN 
 ,p.Brand_Name
 ,p.Product_Sort
 ,p.Product_Category
 ,P.Plant
 ,s.Store_Province
 ,s.Store_City
 ,s.Store_Name
 ,S.Sales_Region
 ,S.Account_Area_CN
 ,p.Sale_Unit
 ,ka.Sales_Qty
 ,ka.Sales_AMT
 ,ka.Inventory_Qty
from dm.Fct_KAStore_DailySalesInventory ka
join dm.dim_store s on ka.Store_ID=s.Store_ID
join dm.Dim_Product p on ka.SKU_ID=p.sku_id
join dm.Dim_Calendar dc on ka.datekey=dc.datekey
and LEFT(dc.Monthkey,4) =YEAR(GETDATE())
and ka.Sales_Qty>0
order by 1,3,5


END


GO
