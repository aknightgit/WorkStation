USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



	  
CREATE PROCEDURE  [dm].[SP_Fct_YH_Order_Satisfaction_Rate]
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY 

TRUNCATE TABLE dm.[Fct_YH_Store_Covered];

 INSERT INTO [dm].[Fct_YH_Store_Covered]
      ([Store_ID]
      ,[Channel_Account]
      ,[Account_Short]
      ,[Account_Store_Code]
      ,[Store_Province]
      ,[Store_Province_EN]
      ,[Province_Short]
      ,[Store_City]
      ,[Manager]
      ,[Account_Store_Code_bak]
      ,[Status]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
  SELECT [Store_ID]
      ,[Channel_Account]
      ,[Account_Short]
      ,[Account_Store_Code]
      ,[Store_Province]
      ,[Store_Province_EN]
      ,[Province_Short]
      ,[Store_City]
      ,[Manager]
      ,[Account_Store_Code_bak]
      ,[Status]
      ,GETDATE() [Create_Time]
      ,@ProcName [Create_By]
      ,GETDATE() [Update_Time]
      ,@ProcName [Update_By]
  FROM [ODS].[ods].[File_YH_Store_Covered];


  TRUNCATE TABLE [dm].[Fct_YH_Order_Satisfaction_Rate];
  INSERT INTO [dm].[Fct_YH_Order_Satisfaction_Rate]
     ( [Purchase_Datekey]
      ,[Apply_Datekey]
      ,[Region_code]
      ,[Region_Name]
      ,[Store_ID]
      ,[Store_code]
      ,[Store_Name]
      ,[SKU_ID]
      ,[SKU_code]
      ,[Goods_Name]
      ,[Purchase_QTY]
      ,[Receipt_QTY]
      ,[Satisfaction_Rate]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
  SELECT  [Purchase_Datekey]
      ,[Apply_Datekey]
      ,[Region_code]
      ,[Region_Name]
	  ,S.Store_ID
      ,O.[Store_code]
      ,O.[Store_Name]
	  ,PM.SKU_ID
      ,O.[SKU_code]
      ,O.[Goods_Name]
      ,[Purchase_QTY]
      ,[Receipt_QTY]
      ,[Satisfaction_Rate]
     ,GETDATE() [Create_Time]
      ,@ProcName [Create_By]
      ,GETDATE() [Update_Time]
      ,@ProcName [Update_By]
  FROM [ODS].[ods].[File_YH_Order_Satisfaction_Rate] O
  LEFT JOIN dm.Dim_Store s
  ON O.[Store_code]=s.[Account_Store_Code] 
  LEFT JOIN (SELECT * FROM [dm].[Dim_Product_AccountCodeMapping] WHERE Account='YH') PM
  ON O.[SKU_code]=PM.SKU_Code;
 


   END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
