USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_CRV_Inventory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [rpt].[SP_RPT_CRV_Inventory]
AS BEGIN 
SELECT 
       T.[venderid]
      ,T.[goodsid]
      ,T.[shopid]
      ,T.[qty]
      ,T.[grosscostvalue]
      ,T.[taxcostvalue]
      ,CONVERT(VARCHAR(8),T.[releasedate],112)[Date_ID] 
      ,T.[buname]
      ,T.[shopname]
      --,T.[goodsname]
	  ,REPLACE( T.[goodsname],'  ',' ') AS [goodsname]
      ,T.[barcode]
      ,T.[spec]
      ,T.[unitname]
      ,T.[Load_Source]
      ,T.[Load_DTM],
	  T1.Store_ID,
	  T2.SKU_ID
FROM 
ODS.ODS.[FILE_CRV_DAILYINVENTORY] T
LEFT JOIN  
  (SELECT * FROM [Foodunion].[dm].[Dim_Store] where Channel_Account='Vanguard') T1 ON T1.Account_Store_Code=T.shopid
  LEFT JOIN [dm].[Dim_Product] T2 ON T2.Bar_Code=T.barcode AND 
  CASE WHEN goodsname LIKE '%Ð¡Öí%' THEN 'PEPPA' WHEN goodsname LIKE '%ÈðÆæ%' THEN 'RIKI' ELSE 'PEPPA' END =  
  CASE WHEN T2.Brand_IP IN ('PEPPA','RIKI') THEN T2.Brand_IP ELSE 'PEPPA' END
  END 
GO
