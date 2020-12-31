USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_ERP_Stock_Inventory_Material_20190717]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















create   PROC  [dm].[SP_Fct_ERP_Stock_Inventory_Material_20190717] 
AS 
BEGIN


 DECLARE @errmsg nvarchar(max),
 @DatabaseName varchar(100) = DB_NAME(),
 @ProcName varchar(100) = OBJECT_NAME(@@PROCID);

 BEGIN TRY


TRUNCATE TABLE [dm].[Fct_ERP_Stock_Inventory_Material]

INSERT INTO [dm].[Fct_ERP_Stock_Inventory_Material]
(  [Material_Group_NM]
 ,[Material_NM]
 ,[Warehouse_NM]
 ,[Inventory_DT]
 ,[SKU_ID]
 ,[SKU_NM]
 ,[Unit_DSC]
 ,[Inventory_QTY]
 ,[Batch_CD]
 ,[Manufacturing_DT]
 ,[Expiring_DT]
 ,[Storaging_DT]
 ,[Create_Time]
 ,[Create_By]
 ,[Update_Time]
 ,[Update_By]
 )

	SELECT 
	   mgl.FNAME AS Material_Group_NM
	  ,mal.FNAME AS Material_NM
	  ,stl.fname AS Warehouse_NM
	  ,CAST(DATEADD(DAY,-1,iste.Load_DTM) AS DATE) AS Inventory_DT
	  ,ma.FNUMBER AS SKU_ID
	  ,mal.FNAME AS SKU_NM
	  ,ut.FNAME AS Unit_DSC
	  ,iste.FBASEQTY AS Inventory_QTY
	  ,lm.FNUMBER AS Batch_CD
	  ,CAST(lm.FPRODUCEDATE AS DATE) AS Manufacturing_DT
	  ,CAST(lm.FEXPIRYDATE AS DATE) AS Expiring_DT
	  ,CAST(lm.FINSTOCKDATE AS DATE) AS Storaging_DT
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM [FU_ODS].[T_ODS_ERP_INVENTORY] iste
LEFT JOIN [FU_ODS].[T_ODS_ERP_MATERIAL] ma ON iste.FMATERIALID = ma.FMATERIALID 
LEFT JOIN [FU_ODS].[T_ODS_ERP_MATERIAL_L] mal ON ma.fmaterialid = mal.fmaterialid
LEFT JOIN [FU_ODS].[T_ODS_ERP_Unit_L] ut ON iste.FBASEUNITID = ut.FUNITID
LEFT JOIN [FU_ODS].[T_ODS_ERP_STOCK_L] stl ON iste.FSTOCKID = stl.FSTOCKID
LEFT JOIN [FU_ODS].[T_ODS_ERP_MATERIALGROUP_L] mgl ON ma.FMATERIALGROUP = mgl.FID AND mgl.FLOCALEID = 2052
LEFT JOIN [FU_ODS].[T_ODS_ERP_LOTMASTER] lm ON iste.FLOT = lm.FLOTID
WHERE  mal.FLOCALEID = 2052 AND stl.FLOCALEID = 2052 AND ut.FLOCALEID = 2052 AND mgl.FLOCALEID = 2052 AND mgl.FNAME = '‘≠¡œ' -- AND Warehouse_ID IS NOT NULL


END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
