USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dm].[SP_Dim_Store_SalesPerson_Monthly_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	TRUNCATE TABLE  [dm].[Dim_Store_SalesPerson_Monthly] ; 
	--SELECT *FROM [dm].[Dim_Store_SalesPerson_Monthly]

	INSERT INTO [dm].[Dim_Store_SalesPerson_Monthly]
        ([Monthkey]
        ,[Channel]
        ,[Store_ID]
        ,[Store_Code]
        ,[Sales_Person]
        ,[Create_Time]
        ,[Create_By]
        ,[Update_Time]
        ,[Update_By])
	SELECT DISTINCT 
		o.[Month]
		,'YH'
		,ISNULL(ds.[Store_ID],o.[StoreCode])
		,o.[StoreCode]
		,o.[SalesPerson]
		--,[StoreName]
		--,[SellIn]
		--,[SellOut]
		,GETDATE(),'[dm].[SP_Dim_Store_SalesPerson_Monthly_Update]'
		,GETDATE(),'[dm].[SP_Dim_Store_SalesPerson_Monthly_Update]'
	FROM ODS.[ods].[File_Sales_SellInOutTarget_byStore] o
	LEFT JOIN dm.Dim_Store ds ON o.StoreCode=ds.Account_Store_Code AND ds.Channel_Account='YH';


	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
