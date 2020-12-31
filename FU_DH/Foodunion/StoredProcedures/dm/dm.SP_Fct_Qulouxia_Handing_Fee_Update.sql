USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dm].[SP_Fct_Qulouxia_Handing_Fee_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--TRUNCATE TABLE [dm].[Fct_Qulouxia_Handing_Fee];     --08富友商品加工费用
	INSERT INTO [dm].[Fct_Qulouxia_Handing_Fee]
		  ([Datekey]
      ,[SKU_ID]
	  ,[SKU_CODE]
      ,[SKU_Name]
      ,[Batch_Number]
      ,[Unit]
      ,[QTY]
      ,[Single_Fee]
      ,[Total_Fee]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
	SELECT CONVERT(VARCHAR(10),[Date],112)
      ,P.[SKU_ID]
	  ,O.SKU_ID AS CODE
      ,O.[SKU_Name]
      ,O.[Batch_Number]
      ,O.[Unit]
      ,O.[QTY]
      ,O.[Single_Fee]
      ,O.[Total_Fee]
		,GETDATE() AS [Create_Time]
		,'[dm].[SP_Fct_Handing_Fee_Update]' AS [Create_By]
		,GETDATE() AS [Update_Time]
		,'[dm].[SP_Fct_Handing_Fee_Update]' AS [Update_By]
	FROM [ODS].[ods].[File_Qulouxia_Handing_Fee] O
	LEFT JOIN (SELECT * FROM [Foodunion].[dm].[Dim_Product_AccountCodeMapping] WHERE [Account]='ZBox') P
    ON O.[SKU_ID]=P.SKU_Code
	LEFT JOIN [dm].[Fct_Qulouxia_Handing_Fee] D
	ON CONVERT(VARCHAR(10),[Date],112)=D.Datekey AND P.[SKU_ID]=D.SKU_ID AND O.SKU_ID=D.[SKU_CODE] AND O.[Batch_Number]=D.Batch_Number
	WHERE D.SKU_ID IS NULL AND D.[SKU_CODE] IS NULL;

	--TRUNCATE TABLE [dm].[Fct_Qulouxia_SMS_Massage_Fee];     --手工数据  信息费
	INSERT INTO [dm].[Fct_Qulouxia_SMS_Massage_Fee] 
			([Datekey]
			,[Message_Num]
			,[Comments]
			,[Single_SMS_fee]
			,[Total_Fee]
			,[Create_Time]
			,[Create_By]
			,[Update_Time]
			,[Update_By])
	  SELECT CONVERT(VARCHAR(10),O.[Date],112)
		    ,SUM(O.[Message_Num])
		    ,O.[Comments]
		    ,MAX(O.[Single_SMS_fee])
		    ,SUM(O.[Total_Fee] ) 
			,GETDATE() AS [Create_Time]
			,'[dm].[SP_Fct_Handing_Fee_Update]' AS [Create_By]
			,GETDATE() AS [Update_Time]
			,'[dm].[SP_Fct_Handing_Fee_Update]' AS [Update_By]
		FROM [ODS].[ods].[File_Qulouxia_SMS_Massage_Fee] O
		LEFT JOIN [dm].[Fct_Qulouxia_SMS_Massage_Fee] D
		ON CONVERT(VARCHAR(10),O.[Date],112)=D.Datekey AND O.[Comments]=D.[Comments]
		WHERE ISNULL([Date],'')<>'' AND ISNULL(O.[Comments],'')<>'' AND D.Datekey IS NULL
		GROUP BY  CONVERT(VARCHAR(10),O.[Date],112)		 
		    ,O.[Comments];

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
	

END
GO
