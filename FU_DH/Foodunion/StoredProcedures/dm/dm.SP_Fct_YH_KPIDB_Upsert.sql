USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE  [dm].[SP_Fct_YH_KPIDB_Upsert]
as
begin
	DECLARE @errmsg nvarchar(max),
	@DatabaseName varchar(100) = DB_NAME(),
	@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY
		DELETE D 
		FROM [dm].[Fct_YH_Promo_Period] D
		JOIN [ods].[ods].[File_YH_Promo_Period] O
		ON D.[Period]=O.[Period]

		INSERT INTO [dm].[Fct_YH_Promo_Period]
			  ([Period]
			  ,[Start_Date]
			  ,[End_Date]
			  ,[Create_Time]  
	          ,[Create_By]  
	          ,[Update_Time]  
	          ,[Update_By] )
		SELECT   [Period]
			  ,[Start_Date]
			  ,[End_Date]
			  ,GETDATE()
			  ,'[dm].[SP_Fct_YH_KPIDB_Upsert]'
			  ,GETDATE()
			  ,'[dm].[SP_Fct_YH_KPIDB_Upsert]'
		FROM  [ods].[ods].[File_YH_Promo_Period];


	
--------------------------------------------------------------------------
		TRUNCATE TABLE [dm].[Fct_YH_SKU_RSP];
		INSERT INTO [dm].[Fct_YH_SKU_RSP]
			  ([Channel]
			  ,[FU_SKU]
			  ,[YH_SKU_Code]
			  ,[SKU_Name_CN]
			  ,[SKU_Name_EN]
			  ,[A/F]
			  ,[FU_Sellin_Price_1]
			  ,[Store_Cost]
			  ,[RSP]
			  ,[VAT]
			  ,[VOL_KG]
			  ,[VIC]
			  ,[VLC]
			  ,[MACO]
			  ,[MACO%]
			  ,[Sellin_Price_W/O_Vat]
			  ,[Target_ASP_Max]
			  ,[Price_KG_Max]
			  ,[Target_ASP_Min]
			  ,[Price_KG_Min]
			  ,[MD_Min_Margin]
			  ,[Create_Time]  
	          ,[Create_By]  
	          ,[Update_Time]  
	          ,[Update_By])
		SELECT DISTINCT [Channel]
			  ,[FU_SKU]
			  ,[YH_SKU_Code]
			  ,[SKU_Name_CN]
			  ,[SKU_Name_EN]
			  ,[A/F]
			  ,[FU_Sellin_Price_1]
			  ,[Store_Cost]
			  ,[RSP]
			  ,[VAT]
			  ,[VOL_KG]
			  ,[VIC]
			  ,[VLC]
			  ,[MACO]
			  ,[MACO%]
			  ,[Sellin_Price_W/O_Vat]
			  ,[Target_ASP_Max]
			  ,[Price_KG_Max]
			  ,[Target_ASP_Min]
			  ,[Price_KG_Min]
			  ,[MD_Min_Margin]
			  ,GETDATE()
			  ,'[dm].[SP_Fct_YH_KPIDB_Upsert]'
			  ,GETDATE()
			  ,'[dm].[SP_Fct_YH_KPIDB_Upsert]'
		  FROM [ods].[ods].[File_YH_SKU_RSP];
--------------------------------------------------------------------------
		TRUNCATE TABLE [dm].[Fct_YH_Promo_Period_By_SKU];
		INSERT INTO [dm].[Fct_YH_Promo_Period_By_SKU]
			  ([Channel]
			  ,[FU_SKU]
			  ,[YH_SKU_Code]
			  ,[SKU_Name]
			  ,[A/F]
			  ,[FU_Sellin_Price_1]
			  ,[FU_Sellin_Price_2]
			  ,[Store_Cost]
			  ,[RSP]
			  ,[VAT]
			  ,[Promo_Price]
			  ,[Coeff]
			  ,[Coeff_Promo_Price]
			  ,[Promo_Deduct]
			  ,[Promo_Period]
			  ,[Soft_Promo_Description]
			  ,[Promo_Region]
			  ,[P1]
			  ,[P2]
			  ,[P3]
			  ,[P4]
			  ,[P5]
			  ,[P6]
			  ,[P7]
			  ,[P8]
			  ,[Q1]
			  ,[Q2]
			  ,[Q3]
			  ,[Q4]
			  ,[Q5]
			  ,[Q6]
			  ,[Q7]
			  ,[Q8]
			  ,[R1]
			  ,[R2]
			  ,[R3]
			  ,[R4]
			  ,[R5]
			  ,[R6]
			  ,[R7]
			  ,[R8]
			  ,[Create_Time]  
	          ,[Create_By]  
	          ,[Update_Time]  
	          ,[Update_By])
		SELECT DISTINCT [Channel]
			  ,[FU_SKU]
			  ,[YH_SKU_Code]
			  ,[SKU_Name]
			  ,[A/F]
			  ,[FU_Sellin_Price_1]
			  ,[FU_Sellin_Price_2]
			  ,[Store_Cost]
			  ,[RSP]
			  ,[VAT]
			  ,[Promo_Price]
			  ,[Coeff]
			  ,[Coeff_Promo_Price]
			  ,[Promo_Deduct]
			  ,[Promo_Period]
			  ,[Soft_Promo_Description]
			  ,[Promo_Region]
			  ,[P1]
			  ,[P2]
			  ,[P3]
			  ,[P4]
			  ,[P5]
			  ,[P6]
			  ,[P7]
			  ,[P8]
			  ,[Q1]
			  ,[Q2]
			  ,[Q3]
			  ,[Q4]
			  ,[Q5]
			  ,[Q6]
			  ,[Q7]
			  ,[Q8]
			  ,[R1]
			  ,[R2]
			  ,[R3]
			  ,[R4]
			  ,[R5]
			  ,[R6]
			  ,[R7]
			  ,[R8]
			  ,GETDATE()
			  ,'[dm].[SP_Fct_YH_KPIDB_Upsert]'
			  ,GETDATE()
			  ,'[dm].[SP_Fct_YH_KPIDB_Upsert]'
		  FROM [ods].[ods].[File_YH_Promo_Period_By_SKU];

END TRY

	BEGIN CATCH
	SELECT @errmsg =  ERROR_MESSAGE();
	EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;
	RAISERROR(@errmsg,16,1);
	END CATCH
END
GO
