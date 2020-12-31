USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_KA_SalesInventory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [rpt].[SP_RPT_KA_SalesInventory]
AS
BEGIN

	
	SELECT 'KW' as KA
		,datekey as Date_ID
		,C.Date_NM  as Date_NM
		,k.SKU_ID 
		,Store_ID
		--Store_Code,Store_Name,p.Brand_Name,p.Product_Group,p.Product_Category,p.Product_Sort,
		,Sales_Qty
		,Sales_AMT
		,k.Sales_Qty * p.Sale_Unit_Weight_KG/1000.0 as  Sales_Vol
		,Ending_Qty as  Invent_Qty
		,Ending_AMT as Invent_Amt 
		,k.Ending_Qty * p.Sale_Unit_Weight_KG/1000.0 as  Invent_Vol
	FROM [dm].[Fct_Kidswant_DailySales] k  WITH(NOLOCK) 
	LEFT JOIN dm.Dim_Product p WITH(NOLOCK)  on k.SKU_ID=p.SKU_ID
	LEFT JOIN [FU_EDW].[Dim_Calendar] C on k.Datekey = C.Date_ID

	UNION all

	SELECT 'YH' as KA
		,Calendar_DT as Date_ID
		,C.Date_NM  as Date_NM
		,k.SKU_ID 
		,Store_ID --Store_Code,Store_Name,p.Brand_Name,p.Product_Group,p.Product_Category,p.Product_Sort,
		,Sales_Qty
		,Sales_AMT
		,k.Sales_Qty * p.Sale_Unit_Weight_KG/1000.0 as  Sales_Vol
		,k.Inventory_QTY as  Invent_Qty
		,k.Inventory_AMT as Invent_Amt 
		,k.Inventory_QTY * p.Sale_Unit_Weight_KG/1000.0 as  Invent_Vol
	FROM [dw].[Fct_YH_Sales_Inventory] k WITH(NOLOCK) 
	LEFT JOIN dm.Dim_Product p WITH(NOLOCK)  on k.SKU_ID=p.SKU_ID
	LEFT JOIN [FU_EDW].[Dim_Calendar] C on k.Calendar_DT = C.Date_ID

	UNION all

	SELECT 'VG' as KA
		,k.Datekey as Date_ID 
		,C.Date_NM  as Date_NM
		,k.SKU_ID ,k.Store_ID --Store_Code,Store_Name,p.Brand_Name,p.Product_Group,p.Product_Category,p.Product_Sort,
		,Sale_Qty as Sales_Qty
		,Gross_Sale_Value as Sales_AMT
		,k.Sale_Qty * p.Sale_Unit_Weight_KG/1000.0 as  Sales_Vol
		,Qty as  Invent_Qty
		,q.Gross_Cost_Value as Invent_Amt 
		,QTY * p.Sale_Unit_Weight_KG/1000.0 as  Invent_Vol
	FROM  [dm].[Fct_CRV_DailySales] k   WITH(NOLOCK)  
	LEFT JOIN dm.Dim_Product p on k.SKU_ID=p.SKU_ID
	LEFT JOIN [dm].[Fct_CRV_DailyInventory] q WITH(NOLOCK)  on k.Datekey = q.Datekey and k.Store_ID = q.Store_ID and k.SKU_ID =q.SKU_ID  
	LEFT JOIN [FU_EDW].[Dim_Calendar] C on  k.Datekey = C.Date_ID
	;
END
GO
