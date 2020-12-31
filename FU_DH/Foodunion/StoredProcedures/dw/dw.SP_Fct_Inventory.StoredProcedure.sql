USE [Foodunion]
GO
DROP PROCEDURE [dw].[SP_Fct_Inventory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO































CREATE PROCEDURE  [dw].[SP_Fct_Inventory]
AS
BEGIN
DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY 


	TRUNCATE TABLE dw.[Fct_Inventory]

	INSERT INTO dw.[Fct_Inventory]
	(  [Warehouse_ID]
      ,[Vendor_CD]
      ,[RDC_CD]
      ,[Inventory_DT]
      ,[SKU_ID]
      ,[SKU_NM]
      ,[SKU_EN_NM]
      ,[UPC_CD]
      ,[Brand_NM]
      ,[SKU_Category_NM]
      ,[Density_NUM]
      ,[Measurement_Standard_DSC]
      ,[Measurement_Sales_DSC]
      ,[Inventory_QTY]
      ,[Assigned_QTY]
      ,[Freezing_QTY]
      ,[Avaliable_QTY]
      ,[Manufacturing_DT]
      ,[Expiring_DT]
      ,[Storaging_DT]
	  ,Batch_CD
      ,[Is_Damaged]
      ,[Is_Expired]
      ,[Inventory_Type]
      ,[Create_Time]
	  ,[Create_By]  
	  ,[Update_Time]
	  ,[Update_By]  
	  )
SELECT [Warehouse_ID]
      ,NULL AS [Vendor_CD]
      ,NULL AS [RDC_CD]
      ,CONVERT(VARCHAR(8),CAST([Inventory_DT] AS DATE),112) as date
      ,[SKU_ID]
      ,[SKU_NM]
      ,[SKU_EN_NM]
      ,[UPC_CD]
      ,[Brand_NM]
      ,[SKU_Category_NM]
      ,[Density_NUM]
      ,[Measurement_Standard_DSC]
      ,[Measurement_Sales_DSC]
      ,SUM([Inventory_QTY])		AS	[Inventory_QTY]
      ,SUM([Assigned_QTY])		AS	[Assigned_QTY]
      ,SUM([Freezing_QTY])		AS	[Freezing_QTY]
      ,SUM([Avaliable_QTY])		AS	[Avaliable_QTY]
      ,[Manufacturing_DT]
      ,[Expiring_DT]
      ,[Storaging_DT]
	  ,Batch_CD
      ,[Is_Damaged]
      ,[Is_Expired]
      ,[Inventory_Type]
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
	  FROM(
			SELECT 
			   CASE WHEN Load_Source LIKE '%上海常温%' THEN '216359'
			        WHEN Load_Source LIKE '%上海低温%' THEN '216360'
			        WHEN Load_Source LIKE '%北京低温%' THEN '216361'
			        WHEN Load_Source LIKE '%广州低温%' THEN '216364' END AS [Warehouse_ID]
			  ,NULL  AS [Vendor_CD]
		      ,NULL 	 AS [RDC_CD]
		      ,BL.[Date_DT]																							 AS [Inventory_DT]
		      ,BL.[SKU_ID]																							 AS [SKU_ID]
		      ,PROD.SKU_Name_CN																						 AS [SKU_NM]
		      ,PROD.SKU_Name																						 AS [SKU_EN_NM]
		      ,PROD.Bar_Code																						 AS [UPC_CD]
		      ,PROD.Brand_Name																						 AS [Brand_NM]
		      ,PROD.Brand_Name																						 AS [SKU_Category_NM]
		      ,PROD.Sale_Unit_Weight_KG/1000																		 AS [Density_NUM]
		      ,NULL																									 AS [Measurement_Standard_DSC]
		      ,PROD.Sale_Unit_CN																					 AS [Measurement_Sales_DSC]
		      ,CAST(BL.[Inventory_QTY] AS DECIMAL)																	 AS [Inventory_QTY]
		      ,CAST(CASE WHEN BL.[Assigned_QTY]  LIKE '%-%' THEN NULL ELSE BL.[Assigned_QTY] END AS DECIMAL)		 AS [Assigned_QTY]
		      ,CAST(CASE WHEN BL.[Freezing_QTY]  LIKE '%-%' THEN NULL ELSE BL.[Freezing_QTY] END AS DECIMAL)		 AS [Freezing_QTY]
		      ,CAST(CASE WHEN BL.[Avaliable_QTY] LIKE '%-%' THEN NULL ELSE BL.[Avaliable_QTY]END  AS DECIMAL)		 AS [Avaliable_QTY]
		      ,BL.[Manufacturing_DT]																				 AS [Manufacturing_DT]
		      ,BL.[Expiring_DT]																						 AS [Expiring_DT]
		      ,CAST(BL.[Storaging_DT] AS DATE)																		 AS [Storaging_DT]
			  ,BL.Batch_CD
		      ,BL.[Is_Damaged]																						 AS [Is_Damaged]
		      ,BL.[Is_Expired]																						 AS [Is_Expired]
		      ,NULL																					 AS [Inventory_Type]
		  FROM [ODS].[ods].[File_Inventory] BL
		  LEFT JOIN [dm].[Dim_Product] PROD ON BL.SKU_ID=PROD.SKU_ID
		  --WHERE PROD.SKU_ID IS NOT NULL AND  WH.Warehouse_ID IS NOT NULL AND PROD.Shelflife IS NOT NULL
	 ) base
	 WHERE Warehouse_ID IS NOT NULL
GROUP BY [Warehouse_ID]
		 ,[Vendor_CD]
		 ,[RDC_CD]
		 ,[Inventory_DT]
		 ,[SKU_ID]
		 ,[SKU_NM]
		 ,[SKU_EN_NM]
		 ,[UPC_CD]
		 ,[Brand_NM]
		 ,[SKU_Category_NM]
		 ,[Density_NUM]
		 ,[Measurement_Standard_DSC]
		 ,[Measurement_Sales_DSC]
		 ,[Manufacturing_DT]
		 ,[Expiring_DT]
		 ,[Storaging_DT]
		 ,Batch_CD
		 ,[Is_Damaged]
		 ,[Is_Expired]
		 ,[Inventory_Type]
		 order by date desc


   END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

   END
   




GO
