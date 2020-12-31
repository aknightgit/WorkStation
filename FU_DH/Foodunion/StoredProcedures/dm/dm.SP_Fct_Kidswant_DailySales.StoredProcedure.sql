USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_Kidswant_DailySales]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROC  [dm].[SP_Fct_Kidswant_DailySales]
AS BEGIN


 DECLARE @errmsg nvarchar(max),
 @DatabaseName varchar(100) = DB_NAME(),
 @ProcName varchar(100) = OBJECT_NAME(@@PROCID);

 BEGIN TRY

TRUNCATE TABLE  [dm].[Fct_Kidswant_DailySales] 

INSERT INTO [dm].[Fct_Kidswant_DailySales](
	   [Datekey]
      ,[Bill_No]
      ,[SKU_ID]
	  ,SKU_Name
	  ,[Store_ID]
      ,[Store_Code]
      ,[Store_Name]
      ,[Goods_Status]
      ,[Delivery_Type]
      ,[InStock_Qty]
      ,[TransferIn_Qty]
      ,[TransferOut_Qty]
      ,[Return_Qty]
      ,[Sales_Qty]
      ,[Sales_AMT]
      ,[Ending_Qty]
      ,[Ending_AMT]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
)
SELECT CONVERT(VARCHAR(8),CAST(Date AS DATE),112) AS DATAKEY
      ,[Bill_No]
      ,prod.[SKU_ID]
	  ,sal.SKU_Name
	  ,st.Store_ID
      ,[Store_Code]
      ,st.[Store_Name]
      ,[Goods_Status]
      ,[Delivery_Type]
      ,CAST([InStock_Qty]		AS DECIMAL(20,10)) AS [InStock_Qty]		
      ,CAST([TransferIn_Qty]	AS DECIMAL(20,10)) AS [TransferIn_Qty]	
      ,CAST([TransferOut_Qty]	AS DECIMAL(20,10)) AS [TransferOut_Qty]	
      ,CAST([Return_Qty]		AS DECIMAL(20,10)) AS [Return_Qty]		
      ,CAST([Sales_Qty]			AS DECIMAL(20,10)) AS [Sales_Qty]			
      ,CAST([Sales_AMT]			AS DECIMAL(20,10)) AS [Sales_AMT]			
      ,CAST([Ending_Qty]		AS DECIMAL(20,10)) AS [Ending_Qty]		
      ,CAST([Ending_AMT]		AS DECIMAL(20,10)) AS [Ending_AMT]	
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
  FROM [ODS].[ODS].[File_Kidswant_DailySales] sal
  LEFT JOIN dm.Dim_Product prod ON sal.Bar_Code = prod.Bar_Code AND CASE WHEN sal.SKU_Name LIKE '%Ð¡Öí%' THEN 'PEPPA' WHEN sal.SKU_Name LIKE '%ÈðÆæ%' THEN 'RIKI' ELSE 'Others' END = CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'Others' END
  LEFT JOIN dm.Dim_Store st ON sal.[Store_Code] = st.Account_Store_Code AND st.Channel_Account = 'KW'
  WHERE store_id IS NOT NULL


END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
