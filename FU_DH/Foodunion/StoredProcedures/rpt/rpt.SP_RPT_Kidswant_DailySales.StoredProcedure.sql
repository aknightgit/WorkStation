USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_Kidswant_DailySales]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [rpt].[SP_RPT_Kidswant_DailySales]
AS
BEGIN 
	--select sum([Ending_Weight]) from(
	SELECT ds.Datekey
		  ,ds.[Bill_No]
		  ,ds.[SKU_ID]
		  ,ds.[Store_ID]
		  ,CASE WHEN ds.[Store_Name] in ('孩子王电商') 
				THEN '孩子王电商' ELSE 'Store' END AS StoreType
		  ,ds.[Store_Code]
		  ,ds.[Store_Name]
		  ,ds.SKU_Name AS Account_SKU_Name
		  ,ds.[Goods_Status]
		  ,ds.[Delivery_Type]
		  ,ds.[InStock_Qty]
		  ,ds.[TransferIn_Qty]
		  ,ds.[TransferOut_Qty]
		  ,ds.[Return_Qty]
		  ,ds.[Sales_Qty]
		  ,ds.[Sales_AMT]
		  ,ds.Sales_Qty*prod.Sale_Unit_Weight_KG AS [Sales_Weight]
		  ,ds.[Ending_Qty]
		  ,ds.[Ending_AMT]
		  ,ds.Ending_Qty*prod.Sale_Unit_Weight_KG AS [Ending_Weight]
		  --,ds.[Create_Time]
		  --,ds.[Create_By]
		  ,ds.[Update_Time]
		  --,ds.[Update_By]
	  FROM [dm].[Fct_Kidswant_DailySales] ds  
	  LEFT JOIN dm.Dim_Product prod ON ds.SKU_ID = prod.SKU_ID
	  --LEFT JOIN ods.ods.File_Kidswant_DailySales ods ON ds.Bill_No=ods.Bill_No AND prod.Bar_Code=ods.Bar_Code
	  --where ds.Datekey=20190719
	  --)x
	  UNION 

  SELECT 
	  CONVERT(VARCHAR(8),cast(ods.Date as date),112)
      ,ods.[Bill_No]
      ,prod.[SKU_ID]
      ,'' AS [Store_ID]
	  ,CASE WHEN ods.[Store_Name] in ('南京电商3号仓','孩子王西南电商店','盐城中心仓电商') 
				THEN '孩子王电商' ELSE 'RDC' END AS StoreType
      ,ods.[Store_Code]
      ,ods.[Store_Name]
	  ,ods.SKU_Name AS Account_SKU_Name
      ,ods.[Goods_Status]
      ,ods.[Delivery_Type]
      ,ods.[InStock_Qty]
      ,ods.[TransferIn_Qty]
      ,ods.[TransferOut_Qty]
      ,ods.[Return_Qty]
      ,ods.[Sales_Qty]
      ,ods.[Sales_AMT]
	  ,ods.Sales_Qty*prod.Sale_Unit_Weight_KG AS [Sales_Weight]
      ,ods.[Ending_Qty]
      ,ods.[Ending_AMT]
	  ,ods.Ending_Qty*prod.Sale_Unit_Weight_KG AS [Ending_Weight]
	  ,ods.Load_DTM
	FROM ods.[ods].[File_Kidswant_DailySales] ods 
	LEFT JOIN dm.Dim_Product prod ON ods.Bar_Code = prod.Bar_Code AND CASE WHEN ods.SKU_Name LIKE '%小猪%' THEN 'PEPPA' WHEN ods.SKU_Name LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'PEPPA' END
	WHERE Store_Name not in (SELECT store_name FROM dm.Dim_Store WHERE Channel_Account='kw')
	AND Store_Name like '%仓'
	--AND CONVERT(VARCHAR(8),cast(ods.Date as date),112)=20190719	
	--)X
END

GO
