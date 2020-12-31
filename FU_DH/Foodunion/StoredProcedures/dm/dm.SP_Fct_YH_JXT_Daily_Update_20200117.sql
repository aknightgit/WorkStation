USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dm].[SP_Fct_YH_JXT_Daily_Update_20200117]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY



		TRUNCATE TABLE [dm].[Fct_YH_JXT_Daily]
           
		INSERT INTO [dm].[Fct_YH_JXT_Daily]
           ([Datekey]
		   ,[Store_ID]
		   ,[SKU_ID]
		   ,[InStock_QTY]
		   ,[InStock_Amount]
		   ,[Sale_QTY]
		   ,[Sale_Amount]
		   ,[Promotion_Amount]
		   ,[Create_Time]
		   ,[Create_By]
		   ,[Update_Time]
		   ,[Update_By])
		SELECT dt.Date_ID AS DateKey
			  ,st.Store_ID
			  ,prod.SKU_ID
			  ,CAST(InStock_QTY AS DECIMAL(20,10)) AS InStock_QTY
			  ,CAST(InStock_Amount AS DECIMAL(20,10)) AS InStock_Amount
			  ,CAST([Sale_QTY] AS DECIMAL(20,10)) AS [Sale_QTY]
			  ,CAST([Sale_Amount] AS DECIMAL(20,10)) AS [Sale_Amount]
			  ,CAST([Promotion_Amount] AS DECIMAL(20,10)) AS [Promotion_Amount]
              ,GETDATE()
			  ,@ProcName
			  ,GETDATE()
			  ,@ProcName
		FROM ods.ods.[File_YH_DailySales] ds
		LEFT JOIN dm.Dim_Store st ON ds.Store_Code = st.Account_Store_Code AND st.Channel_Account = 'YH'
		LEFT JOIN dm.Dim_Product prod ON ds.Bar_Code=prod.Bar_Code AND CASE WHEN ds.SKU_Name LIKE '%小猪%' THEN 'PEPPA' WHEN ds.SKU_Name LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'PEPPA' END
		LEFT JOIN FU_EDW.Dim_Calendar dt ON ds.Date = dt.Date_NM
		WHERE InStock_QTY>0 OR InStock_Amount>0

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
