USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_CRV_DailySales]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [rpt].[SP_RPT_CRV_DailySales]
AS BEGIN 
SELECT T.[saletype]
      ,T.[venderid]
      ,T.[buname]
      ,CONVERT(VARCHAR(8),T.[sdate],112)[Date_ID]
      ,T.[goodsid]
      ,T.[shopid]
      ,T.[qty]
      ,T.[categoryid]
      ,T.[grosscostvalue]
      ,T.[netcostvalue]
      ,T.[grosssalevalue]
      ,T.[netsalevalue]
      ,T.[saletaxrate]
      ,T.[salecostrate]
      ,T.[touchtime]
      ,T.[toucher]
      ,T.[discticketvalue]
	  ,REPLACE( T.[goodsname],'  ',' ') AS [goodsname]
      ,T.[shopname]
      ,T.[barcode]
      ,T.[spec]
      ,T.[unitname]
      ,T.[categoryname]
      ,T.[Load_Source]
      ,T.[Load_DTM],
	  T1.Store_ID,
	  T2.SKU_ID
	  --select distinct T.[goodsname]
  FROM [ODS].[ods].[File_CRV_DailySales] T
  LEFT JOIN 
  (SELECT * FROM [Foodunion].[dm].[Dim_Store] where Channel_Account='Vanguard') T1 ON T1.Account_Store_Code=T.shopid
  LEFT JOIN [dm].[Dim_Product] T2 ON T2.Bar_Code=T.barcode AND 
  CASE WHEN goodsname LIKE '%Ð¡Öí%' THEN 'PEPPA' WHEN goodsname LIKE '%ÈðÆæ%' THEN 'RIKI' ELSE 'PEPPA' END =  
  CASE WHEN T2.Brand_IP IN ('PEPPA','RIKI') THEN T2.Brand_IP ELSE 'PEPPA' END
  END 


GO
