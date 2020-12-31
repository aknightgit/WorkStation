USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_Inventory_Outstock_20190702]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dm].[SP_Fct_Inventory_Outstock_20190702]
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY

TRUNCATE TABLE [dm].[Fct_Inventory_Outstock]

INSERT INTO [dm].[Fct_Inventory_Outstock](
	   [Warehouse_ID]
      ,[Vendor_CD]
      ,[RDC_CD]
      ,[Warehouse_Type]
      ,[Outstock_DT]
      ,[Order_Type]
      ,[Cust_Order_CD]
      ,[Mail_Order_CD]
      ,[Delivery_CD]
      ,[Delivery_Type]
      ,[SKU_ID]
      ,[SKU_NM]
      ,[Batch_CD]
      ,[Order_QTY]
      ,[Actual_QTY]
      ,[Unit_Dsc]
      ,[Actual_Weight]
      ,[Brand_NM]
      ,[Dest_Province_NM]
      ,[Dest_City_NM]
      ,[Receiver_NM]
      ,[Contact_Inf]
      ,[Contact_Addr]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
)

SELECT T1.Warehouse_ID,
      [Vendor_CD]
      ,[RDC_CD]
      ,[Warehouse_Type]
      ,CONVERT(VARCHAR(8),CAST(Outstock_DT AS DATE),112)Outstock_DT
      ,[Order_Type]
      ,[Cust_Order_CD]
      ,[Mail_Order_CD]
      ,[Delivery_CD]
      ,[Delivery_Type]
      ,[SKU_ID]
      ,[SKU_NM]
      ,[Batch_CD]
      ,[Order_QTY]
      ,[Actual_QTY]
      ,[Unit_Dsc]
      ,CAST([Actual_Weight] AS decimal(18,6))/1000
      ,[Brand_NM]
      ,[Dest_Province_NM]
      ,[Dest_City_NM]
      ,[Receiver_NM]
      ,[Contact_Inf]
      ,[Contact_Addr]
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
  FROM [ODS].[ods].[File_Inventory_Outstock] T
  LEFT JOIN [Foodunion].[FU_EDW].[T_EDW_DIM_Warehouse] T1
  ON T.Vendor_CD+'_'+T.RDC_CD=T1.RDC_SNM and T.Warehouse_Type = T1.Inventory_Type_NM
  WHERE Order_Type NOT LIKE '%±¨·Ï%' AND [Receiver_NM] NOT LIKE '%±¨·Ï%' AND T1.Warehouse_ID IS NOT NULL

   END TRY
 BEGIN CATCH
 
 SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

 END CATCH

  END



  
GO
