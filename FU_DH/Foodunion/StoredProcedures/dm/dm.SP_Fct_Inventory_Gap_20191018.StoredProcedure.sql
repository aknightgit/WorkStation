USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_Inventory_Gap_20191018]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC  [dm].[SP_Fct_Inventory_Gap_20191018]
AS BEGIN


 DECLARE @errmsg nvarchar(max),
 @DatabaseName varchar(100) = DB_NAME(),
 @ProcName varchar(100) = OBJECT_NAME(@@PROCID);

 BEGIN TRY

TRUNCATE TABLE [dm].[Fct_Inventory_Gap]
INSERT INTO [dm].[Fct_Inventory_Gap](
	   [Inventory_DT]
      ,[Warehouse_ID]
      ,[SKU_ID]
      ,[Manufacturing_DT]
      ,[Manual_Inventory_QTY]
      ,[ERP_Inventory_QTY]
      ,[GAP]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
)
SELECT 
       [Inventory_DT]
      ,[Warehouse_ID]
      ,[SKU_ID]
      ,[Manufacturing_DT]
      ,SUM(CAST([Manual_Inventory_QTY]	AS DECIMAL)) AS [Manual_Inventory_QTY]
      ,SUM(CAST([ERP_Inventory_QTY]		AS DECIMAL)) AS [ERP_Inventory_QTY]
      ,SUM(CAST([Manual_Inventory_QTY]	AS DECIMAL))-SUM(CAST([ERP_Inventory_QTY]	AS DECIMAL)) AS [GAP]
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM( 
SELECT convert(varchar(8),CAST(minv.Inventory_DT AS DATE),112) AS   Inventory_DT	 
	  ,minv.Warehouse_ID
	  ,minv.SKU_ID		
	  ,minv.Manufacturing_DT
	  ,CAST(minv.Inventory_QTY AS DECIMAL) AS Manual_Inventory_QTY
	  ,0 AS ERP_Inventory_QTY
FROM [FU_EDW].[T_EDW_FCT_Inventory_All] minv
LEFT JOIN [Foodunion].[dm].[Dim_Warehouse] wh ON minv.Warehouse_ID	= wh.WHS_ID
WHERE wh.Warehouse_Name LIKE '%ºãÖª%' AND ISNULL(CAST(minv.Inventory_QTY AS DECIMAL),0) >0.000 
UNION ALL
SELECT convert(varchar(8),CAST(einv.Datekey AS VARCHAR),112) AS   Inventory_DT	 
	  ,wh.WHS_ID
	  ,einv.SKU_ID		
	  ,einv.Produce_Date
	  ,0 AS Manual_Inventory_QTY
	  ,CAST(einv.Sale_QTY AS DECIMAL) AS ERP_Inventory_QTY
FROM dm.Fct_ERP_Stock_Inventory einv
LEFT JOIN [Foodunion].[dm].[Dim_Warehouse] wh ON REPLACE(REPLACE(einv.Stock_Name,'³£ÎÂ',''),'Àä²Ø','')	= wh.Warehouse_Name
WHERE wh.Warehouse_Name LIKE '%ºãÖª%' AND ISNULL(CAST(einv.Sale_QTY AS DECIMAL),0) >0.000 
) base
GROUP BY
       [Inventory_DT]
      ,[Warehouse_ID]
      ,[SKU_ID]
	  ,[Manufacturing_DT]

END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
