USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dm].[SP_Fct_Qulouxia_DC2Box_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	   --TRUNCATE TABLE [dm].[Fct_Qulouxia_DC2Box];   --12每日订货出库明细
 INSERT INTO [dm].[Fct_Qulouxia_DC2Box]
   ( Datekey,[Store_ID]
      ,[SKU_ID]
      ,[SKU_Code]
      ,[SKU_Name]
      ,[Send_NUM]
      ,[Prod_Date]
      ,[Order_Date]
      ,[Dealer_Code]
      ,[Dealer_Name]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
 SELECT CONVERT(VARCHAR(10),[Create_Date],112),S.Store_ID,P.SKU_ID, QLX.[sku_id] AS SKU_Code
      ,QLX.[SKU_Name] 
      ,QLX.[Send_NUM]
      ,QLX.[Prod_Date]
      ,QLX.[Create_Date]
      ,QLX.[Dealer_Code]
      ,QLX.[Dealer_Name]
      ,getdate() AS [Create_Time]
      ,'[dm].[Fct_Qulouxia_DC2Box]' AS [Create_By]
      ,getdate() AS [Update_Time]
      ,'[dm].[Fct_Qulouxia_DC2Box]' AS [Update_By]   
  FROM [ODS].[ods].[File_Qulouxia_DC2Box] QLX
  LEFT JOIN [Foodunion].[dm].[Dim_Store] S
  ON QLX.dealer_code=S.Account_Store_Code
  LEFT JOIN ( SELECT * FROM [Foodunion].[dm].[Dim_Product_AccountCodeMapping] WHERE [Account]='ZBOX') P
  ON QLX.[sku_id]=P.SKU_Code 
  LEFT JOIN [dm].[Fct_Qulouxia_DC2Box] D
  ON S.Store_ID=D.Store_ID AND P.SKU_ID=D.SKU_ID AND QLX.[sku_id]=D.SKU_Code AND QLX.[Create_Date]=D.Order_Date
  WHERE D.Store_ID IS NULL;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
	

END
GO
