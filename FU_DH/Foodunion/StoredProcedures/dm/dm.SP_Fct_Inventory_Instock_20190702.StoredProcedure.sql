USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_Inventory_Instock_20190702]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC  [dm].[SP_Fct_Inventory_Instock_20190702]
AS BEGIN


 DECLARE @errmsg nvarchar(max),
 @DatabaseName varchar(100) = DB_NAME(),
 @ProcName varchar(100) = OBJECT_NAME(@@PROCID);

 BEGIN TRY

TRUNCATE TABLE [dm].[Fct_Inventory_Instock]

INSERT INTO [dm].[Fct_Inventory_Instock](
	   [Warehouse_ID]
      ,[Vendor_CD]
      ,[RDC_CD]
      ,[Warehouse_Type]
      ,[Instock_DT]
      ,[Instock_CD]
      ,[SKU_ID]
      ,[SKU_NM]
      ,[Batch_CD]
      ,[Manufacturing_DT]
      ,[Expiring_DT]
      ,[Order_QTY]
      ,[Actual_QTY]
      ,[Unit_Dsc]
      ,[Is_Damaged]
      ,[Order_Type]
      ,[Brand_NM]
      ,[Weight]
      ,[Comment_Dsc]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
)
SELECT T1.Warehouse_ID,
      [Vendor_CD]
      ,[RDC_CD]
      ,[Warehouse_Type]
      ,CONVERT(VARCHAR(8),CAST(Instock_DT AS DATE),112)[Instock_DT]
      ,[Instock_CD]
      ,[SKU_ID]
      ,[SKU_NM]
      ,[Batch_CD]
      ,[Manufacturing_DT]
      ,[Expiring_DT]
      ,[Order_QTY]
      ,[Actual_QTY]
      ,[Unit_Dsc]
      ,[Is_Damaged]
      ,[Order_Type]
      ,[Brand_NM]
      ,CAST([Weight] AS decimal(18,6))/1000
      ,[Comment_Dsc]
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
  FROM [ODS].[ods].[File_Inventory_Instock] T 
  LEFT JOIN [Foodunion].[FU_EDW].[T_EDW_DIM_Warehouse] T1
  ON T.Vendor_CD+'_'+T.RDC_CD=T1.RDC_SNM and T.Warehouse_Type = T1.Inventory_Type_NM
  WHERE T1.Warehouse_ID IS NOT NULL

END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
