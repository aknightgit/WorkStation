USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dm].[SP_Dim_Product_VICVLC_Update]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--TRUNCATE TABLE [dm].[Dim_Product_VICVLC];
	--select * from dm.Dim_Channel where Channel_Name='yh'

	INSERT INTO [dm].[Dim_Product_VICVLC]
           (
		   [Channel]
		   ,[SKU_ID]
		   ,[Channel_SKU]
           ,VIC_KG
           ,VLC_KG
		   ,BeginDate 
		   ,EndDate
           ,IsCurrent
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])     
	SELECT 'YH'
			,ods.SKU_ID
			,'5_'+ods.[SKU_ID]
            ,ods.VIC
            ,ods.VLC
		    ,ods.BeginDate 
		    ,ods.EndDate
            ,0
			,GETDATE(),@ProcName,
			GETDATE(),@ProcName
	FROM ODS.ods.File_Product_VICVLC ods
	LEFT JOIN [dm].[Dim_Product_VICVLC] dm ON ods.[SKU_ID]=dm.[SKU_ID] AND ods.BeginDate=dm.BeginDate AND dm.[Channel]='YH'
	WHERE dm.[SKU_ID] IS NULL;
	

	UPDATE t
	SET t.IsCurrent = ISNULL(r.rn,0)
	FROM [dm].[Dim_Product_VICVLC] t
	LEFT JOIN (	SELECT [Channel],SKU_ID,BeginDate,ROW_NUMBER() OVER(PARTITION BY SKU_ID ORDER BY BeginDate DESC) rn FROM [dm].[Dim_Product_VICVLC] )r 
		ON t.SKU_ID = r.SKU_ID 
		AND t.[Channel] = r.[Channel]
		AND t.BeginDate = r.BeginDate
		AND r.rn=1;
	--SELECT * FROM [dm].[Dim_Product_VICVLC]
	--SELECT *FROM ods.ods.File_Product_VICVLC
	--select * from [ODS].[ods].[File_KA_Product_List] O

	UPDATE T
	SET T.Channel=O.Channel
	  ,t.Channel_SKU = o.Channel+'_'+o.SKU_ID
	  ,T.[VOL_KG]=O.[VOL_KG]
      ,T.[VAT]=O.[VAT]
      ,T.[RSP]=O.[RSP]
      ,T.[FU_sellin_price_W_VAT]=O.[FU_sellin_price_W_VAT]
      ,T.[FU_sellin_price_W/O_VAT]=O.[FU_sellin_price_W/O_VAT]
      ,T.[Store_cost_W_VAT]=O.[Store_cost_W_VAT]
      ,T.[Store_cost_W/O_VAT]=O.[Store_cost_W/O_VAT]
      ,T.[VIC_KG]=O.[VIC_KG]
      ,T.[VIC]=O.[VIC]
      ,T.[VLC_KG]=O.[VLC_KG]
      ,T.[VLC]=O.[VLC]
	  ,t.Update_Time=GETDATE()
	  ,T.Update_By=@ProcName
	FROM [dm].[Dim_Product_VICVLC] t
	JOIN [ODS].[ods].[File_KA_Product_List] O
	ON T.Channel=O.Channel AND T.SKU_ID=O.SKU_ID;

	INSERT INTO [dm].[Dim_Product_VICVLC]
	( [Channel]
      ,[SKU_ID]
      ,[Barcode]
      ,[Channel_SKU]
	  ,[External_SKU]
      ,[VOL_KG]
      ,[VAT]
      ,[RSP]
      ,[FU_sellin_price_W_VAT]
      ,[FU_sellin_price_W/O_VAT]
      ,[Store_cost_W_VAT]
      ,[Store_cost_W/O_VAT]
      ,[VIC_KG]
      ,[VIC]
      ,[VLC_KG]
      ,[VLC]
	  ,IsCurrent
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
	SELECT O.[Channel]
      ,O.[SKU_ID]
      ,O.[Barcode]
	  ,o.Channel+'_'+o.SKU_ID
      ,O.[Channel_SKU]
      ,O.[VOL_KG]
      ,O.[VAT]
      ,O.[RSP]
      ,O.[FU_sellin_price_W_VAT]
      ,O.[FU_sellin_price_W/O_VAT]
      ,O.[Store_cost_W_VAT]
      ,O.[Store_cost_W/O_VAT]
      ,O.[VIC_KG]
      ,O.[VIC]
      ,O.[VLC_KG]
      ,O.[VLC]
      ,1
      ,GETDATE() [Create_Time]
      ,@ProcName [Create_By]
      ,GETDATE() [Update_Time]
      ,@ProcName [Update_By]
  FROM [ODS].[ods].[File_KA_Product_List] O
  LEFT JOIN [dm].[Dim_Product_VICVLC] T
  ON T.Channel=O.Channel AND T.SKU_ID=O.SKU_ID
  WHERE T.[SKU_ID] IS NULL;



	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END

--select *from  [dm].[Dim_Product_VICVLC]

--UPDATE  [dm].[Dim_Product_VICVLC]
--SET Channel_SKU=Channel+'_'+SKU_ID
GO
