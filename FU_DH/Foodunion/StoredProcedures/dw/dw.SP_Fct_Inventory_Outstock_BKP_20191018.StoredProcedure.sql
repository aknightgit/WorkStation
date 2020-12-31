USE [Foodunion]
GO
DROP PROCEDURE [dw].[SP_Fct_Inventory_Outstock_BKP_20191018]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dw].[SP_Fct_Inventory_Outstock_BKP_20191018]
AS
BEGIN

TRUNCATE TABLE [dw].[FCT_Inventory_Outstock]

INSERT INTO [dw].[FCT_Inventory_Outstock](
 [Warehouse_ID]
,[Outstock_DT]
,[SKU_ID]
,MANUFACTURING_DT
,[Order_QTY]
,[Actual_QTY]
,[Actual_Weight]
,[Create_Time]
,[Create_By]
,[Update_Time]
,[Update_By]
)
SELECT
 Warehouse_ID
,CONVERT(VARCHAR(8),CAST(Outstock_DT AS DATE),112) AS Outstock_DT
,SKU_ID
,CONVERT(VARCHAR(8),CAST([Batch_CD] AS DATE),112)
,SUM(CAST(Order_QTY AS DECIMAL)) AS Order_QTY
,SUM(CAST(Actual_QTY AS DECIMAL)) AS Actual_QTY
,SUM(CAST(Actual_Weight AS DECIMAL)) AS Actual_Weight
,GETDATE() AS [Create_Time]
,OBJECT_NAME(@@PROCID) AS [Create_By]
,GETDATE() AS [Update_Time]
,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM 
[ods].[ods].[File_Inventory_Outstock] os
LEFT JOIN [FU_EDW].[T_EDW_DIM_Warehouse] wh ON os.Vendor_CD+'_'+os.RDC_CD = wh.RDC_SNM AND os.Warehouse_Type = wh.Inventory_Type_NM
GROUP BY
 Warehouse_ID
,Outstock_DT
,SKU_ID
,[Batch_CD]


END
GO
