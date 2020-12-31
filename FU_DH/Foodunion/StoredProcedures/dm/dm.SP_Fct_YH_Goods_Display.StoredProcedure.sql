USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_YH_Goods_Display]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROC [dm].[SP_Fct_YH_Goods_Display]
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY

TRUNCATE TABLE [dm].[Fct_YH_Goods_Display]

INSERT INTO [dm].[Fct_YH_Goods_Display](
 Calendar_DT    
,[YH_City]			
,[YH_Store_CD]		
,[YH_Store_NM]		
,YH_TYPE			
,SKU_ID	
,SKU_QTY			
,SKU_KG_Vol			
,Inventory_QTY		
,Inventory_KG_Vol
,[Create_Time]
,[Create_By]
,[Update_Time]
,[Update_By]    
)
SELECT 
 Calendar_DT         
,[YH_City]			
,[YH_Store_CD]		
,[YH_Store_NM]		
,YH_TYPE			
,SKU_ID	
,SKU_QTY			
,SKU_KG_Vol			
,Inventory_QTY		
,Inventory_KG_Vol
,GETDATE() AS [Create_Time]
,OBJECT_NAME(@@PROCID) AS [Create_By]
,GETDATE() AS [Update_Time]
,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM [dw].[Fct_YH_Goods_Display]

END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
