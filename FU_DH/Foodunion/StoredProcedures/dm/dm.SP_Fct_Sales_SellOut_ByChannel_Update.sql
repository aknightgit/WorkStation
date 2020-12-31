USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE  [dm].[SP_Fct_Sales_SellOut_ByChannel_Update] 
	@Ret_Days INT = 90
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--增量抽取天数

	--Reload latest 7 days
	DELETE FROM [dm].[Fct_Sales_SellOut_ByChannel]
	WHERE Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112);


	INSERT INTO [dm].[Fct_Sales_SellOut_ByChannel]
           ([DateKey]
           ,[Channel_ID]
           ,[SKU_ID]
           ,[QTY]
           ,[Amount]
		   ,[Amount_woTax]
           ,[Discount_Amount]
           ,[Unit_Price]
           ,[Weight_KG]
           ,[Volume_L]
           ,[Create_time]
           ,[Create_By]
           ,[Update_time]
           ,[Update_By])
	SELECT 
		r.DateKey,
		r.Channel_ID,
		r.SKU_ID,
		SUM(r.Sale_QTY),
		SUM(r.Sale_AMT),
		SUM(r.Sale_AMT) / (1+isnull(p.Tax_Rate,0)),
		NULL,
		NULL,
		SUM(r.Weight_KG),
		SUM(r.Volume_L),
		GETDATE(),
		'[dm].[Fct_Sales_SellOut_byChannel_byRegion]',
		GETDATE(),
		'[dm].[Fct_Sales_SellOut_byChannel_byRegion]'
	FROM [dm].[Fct_Sales_SellOut_byChannel_byRegion] r
	LEFT JOIN dm.Dim_Product p on r.SKU_ID=p.SKU_ID
	WHERE DateKey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
	GROUP BY r.[DateKey]
           ,r.[Channel_ID]
           ,r.[SKU_ID]
		   ,isnull(p.Tax_Rate,0)

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END



--[dbo].[USP_Change_TableColumn] '[dm].[Fct_Sales_SellOut_ByChannel]','add','Amount_woTax decimal(18,2)','Amount',0
GO
