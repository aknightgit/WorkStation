﻿USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


































-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE VIEW  [rpt].[V_RPT_ERP_Inventory_20190710]
	-- Add the parameters for the stored procedure here
AS
	/****** Script for SelectTopNRows command from SSMS  ******/



---------除了猫武士的ERP数据
SELECT SKU_ID
	  ,CONVERT(VARCHAR(8),INVENTORY_DT,112) AS Datekey
	  ,MANUFACTURING_DT
	  ,EXPIRING_DT
	  ,Storaging_DT
	  ,SUM(INVENTORY_QTY) AS INVENTORY_QTY
	  ,SUM(WEIGHT_NBR) AS WEIGHT_NBR
	  ,WAREHOUSE_ID AS WHS_ID
	  ,FRESH_DAY
	  ,GUARANTEE_PERIOD
	  ,GUARANTEE_PERIOD_TYPE
	  ,FRESH_TYPE
	  ,GETDATE() AS Update_DTM
FROM(
	SELECT
	 T.SKU_ID,
	 Datekey AS INVENTORY_DT,
	 T.Produce_Date AS MANUFACTURING_DT,
	 T.Expiry_Date AS EXPIRING_DT,
	 T.Sale_QTY AS INVENTORY_QTY,
	 T.Sale_QTY*T1.Sale_Unit_Weight_KG/1000 AS WEIGHT_NBR,
	 T.Stock_ID AS WAREHOUSE_ID,
	 DATEDIFF(DAY,CAST(Datekey AS VARCHAR),DATEADD(DAY,CAST(T1.Shelf_Life_D AS INT),Produce_Date)) FRESH_DAY,
	 CAST(T1.Shelf_Life_D AS INT) [GUARANTEE_PERIOD],
	 CASE WHEN CAST(T1.Shelf_Life_D AS INT)<35 THEN 'D(S):<35 Days'
	      WHEN CAST(T1.Shelf_Life_D AS INT) BETWEEN 35  AND 100 THEN 'D:35~100 Days'
		  WHEN CAST(T1.Shelf_Life_D AS INT)> 100 THEN 'D(L):>100 Days'
		  ELSE '' END [GUARANTEE_PERIOD_TYPE],
	 CASE WHEN CAST(DATEDIFF(DAY,Produce_Date,CAST(Datekey AS VARCHAR))+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) <CAST(1 AS DECIMAL)/3 THEN '<1/3'
	      WHEN CAST(DATEDIFF(DAY,Produce_Date,CAST(Datekey AS VARCHAR))+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) BETWEEN 
	       CAST(1 AS DECIMAL)/3  AND  CAST(1 AS DECIMAL)/2   THEN '1/3~1/2'
	      WHEN CAST(DATEDIFF(DAY,Produce_Date,CAST(Datekey AS VARCHAR))+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) BETWEEN 
	       CAST(1 AS DECIMAL)/2  AND  CAST(2 AS DECIMAL)/3   THEN '1/2~2/3'
	     WHEN CAST(DATEDIFF(DAY,Produce_Date,CAST(Datekey AS VARCHAR))+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) >CAST(2 AS DECIMAL)/3  AND 
		   CAST(DATEDIFF(DAY,Produce_Date,CAST(Datekey AS VARCHAR))+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) <1 THEN '>2/3'
		WHEN CAST(DATEDIFF(DAY,Produce_Date,CAST(Datekey AS VARCHAR))+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) >=1
		     THEN 'Expired'
			 ELSE '' END [FRESH_TYPE],
	T.Storaging_Date AS Storaging_DT
	FROM [Foodunion].[dm].[Fct_ERP_Stock_Inventory] T
	LEFT JOIN [dm].[Dim_Product] T1 ON T1.SKU_ID=T.SKU_ID
	LEFT JOIN [dm].[Dim_Warehouse] T3 ON T.Stock_ID = T3.[WHS_ID]
	WHERE T1.SKU_ID IS NOT NULL AND CAST(T.Sale_QTY AS DECIMAL)>0 AND ISNULL(T3.[Warehouse_Name],'') NOT LIKE '%猫武士%'			
	UNION ALL
	-------------------猫武士的手工数据
	SELECT
	 T.SKU_ID,
	 CONVERT(varchar(100),T.INVENTORY_DT, 112) INVENTORY_DT,
	 T.MANUFACTURING_DT,
	 T.EXPIRING_DT,
	 T.INVENTORY_QTY,
	 T.Inventory_QTY*T1.Sale_Unit_Weight_KG/1000 WEIGHT_NBR,
	 T.WAREHOUSE_ID,
	 DATEDIFF(DAY,INVENTORY_DT,DATEADD(DAY,CAST(T1.Shelf_Life_D AS INT),MANUFACTURING_DT)) FRESH_DAY,
	 CAST(T1.Shelf_Life_D AS INT) [GUARANTEE_PERIOD],
	 CASE WHEN CAST(T1.Shelf_Life_D AS INT)<35 THEN 'D(S):<35 Days'
	      WHEN CAST(T1.Shelf_Life_D AS INT) BETWEEN 35  AND 100 THEN 'D:35~100 Days'
		  WHEN CAST(T1.Shelf_Life_D AS INT)> 100 THEN 'D(L):>100 Days'
		  ELSE '' END [GUARANTEE_PERIOD_TYPE],
	 CASE WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) <CAST(1 AS DECIMAL)/3 THEN '<1/3'
	      WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) BETWEEN 
	       CAST(1 AS DECIMAL)/3  AND  CAST(1 AS DECIMAL)/2   THEN '1/3~1/2'
	      WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) BETWEEN 
	       CAST(1 AS DECIMAL)/2  AND  CAST(2 AS DECIMAL)/3   THEN '1/2~2/3'
	     WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) >CAST(2 AS DECIMAL)/3  AND 
		   CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) <1 THEN '>2/3'
		WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) >=1
		     THEN 'Expired'
			 ELSE '' END [FRESH_TYPE],
	T.[Storaging_DT]
	FROM dw.Fct_Inventory T
	LEFT JOIN [dm].[Dim_Product] T1 ON T1.SKU_ID=T.SKU_ID
	WHERE T1.SKU_ID IS NOT NULL
) inv
GROUP BY
 SKU_ID
,INVENTORY_DT
,MANUFACTURING_DT
,EXPIRING_DT
,WAREHOUSE_ID
,FRESH_DAY
,GUARANTEE_PERIOD
,GUARANTEE_PERIOD_TYPE
,FRESH_TYPE
,Storaging_DT
GO
