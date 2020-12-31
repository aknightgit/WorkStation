USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_YH_Sales]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dm].[SP_Fct_YH_Sales]
	-- Add the parameters for the stored procedure here
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY
	/****** Script for SelectTopNRows command from SSMS  ******/
TRUNCATE TABLE [dm].[Fct_YH_Sales]

INSERT INTO [dm].[Fct_YH_Sales](
[POS_DT]
,[SKU_ID]
,[Store_ID]
,[Sales_AMT]
,[Sales_QTY]
,[Sales_VOL]
,[DiscountSales_AMT]
,[DiscountSales_QTY]
,[WithTax_SalesCost_AMT]
,[WithTax_Discount_AMT]
,[Create_Time]
,[Create_By]
,[Update_Time]
,[Update_By]
)
SELECT
[POS_DT]
,[SKU_ID]
,[Store_ID]
,SUM([Sales_AMT]					 )
,SUM([Sales_QTY]					 )
,SUM([Sales_VOL]					 )
,SUM([DiscountSales_AMT]			 )
,SUM([DiscountSales_QTY]			 )
,SUM([WithTax_SalesCost_AMT]		 )
,SUM([WithTax_Discount_AMT]			 )
,GETDATE() AS [Create_Time]
,OBJECT_NAME(@@PROCID) AS [Create_By]
,GETDATE() AS [Update_Time]
,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM(
SELECT 
 CU.[Calendar_DT] AS [POS_DT]
,CU.[SKU_ID]
,CU.[Store_ID]
,CU.[Sales_AMT]
,CU.[Sales_QTY]
,CU.[SC_Density_SKU_Ton_Num]*CU.[Sales_QTY] AS [Sales_VOL]
,CU.[DiscountSales_AMT]
,CU.[DiscountSales_QTY]
,CU.[WithTax_SalesCost_AMT]
,CU.[WithTax_Discount_AMT]
,getdate() AS [Update_DTM]
 FROM [Foodunion].[dw].[Fct_YH_Sales_All] CU



 ) base
 GROUP BY 
 [POS_DT]
,[SKU_ID]
,[Store_ID]

END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
