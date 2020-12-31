USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dm].[SP_Fct_Sales_SellInOutTarget_byStore_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY	

	TRUNCATE TABLE [dm].[Fct_Sales_SellInOutTarget_byStore];
	INSERT INTO [dm].[Fct_Sales_SellInOutTarget_byStore]
           ([Monthkey]
           ,[SalesPerson]
           ,[Mobile]
           ,[Store_ID]
           ,[Store_Code]
           ,[SellIn_TGT]
           ,[SellOut_TGT]
           ,[SellOut_TGT_A]
           ,[SellOut_TGT_F]
           ,[SellOut_TGTSKU_A]
           ,[SellOut_TGTSKU_F]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT ods.[Month]
		,ods.[Store_Rep]
		,NULL
		,s.Store_ID
		,ods.[Store_Code]
		,st.SellIn
		,ods.[TGT_POS]
		,ods.[TGT_POS_A]
		,ods.[TGT_POS_F]
		,ods.[TGT_SKUCnt_A]
		,ods.[TGT_SKUCnt_F]
		,GETDATE()
		,@ProcName
		,GETDATE()
		,@ProcName 
	FROM ODS.[ods].[File_Sales_SellOutTargetPOS_byStore] ods
	LEFT JOIN dm.dim_Store s ON ods.[Store_Code]=s.[Account_Store_Code] 
	AND s.Channel_Account=CASE WHEN ods.Channel='永辉' THEN 'YH' ELSE ods.Channel END
	LEFT JOIN ODS.ods.File_Sales_SellInOutTarget_byStore st ON ods.[Month]=st.[Month] AND ods.Store_Code=st.StoreCode
	  ;



	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END

--select top 10 *from ODS.[ods].[File_Sales_SellOutTargetPOS_byStore] ods
--SELECT TOP 100 * FROM [dm].[Fct_Sales_SellInOutTarget_byStore];
--SELECT TOP 100 *FROM ODS.ods.File_Sales_SellInOutTarget_byStore
GO
