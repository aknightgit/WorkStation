USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_ERP_Sale_OrderEntry_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE PROCEDURE [dm].[SP_Fct_ERP_Sale_OrderEntry_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY
		TRUNCATE TABLE  [dm].[Fct_ERP_Sale_OrderEntry] ;  -- ERP delete records
		--UPDATE p
		--SET p.[Sale_Order_ID] = c.[SaleOrderID]
		--  ,p.[Sequence_ID] = c.[SequenceID]
		--  ,p.[SKU_ID] = c.[SKU_ID]
		--  ,p.[Unit] = c.[Unit]
		--  ,p.[QTY] = c.[QTY]
		--  ,p.[Sale_Unit] = c.[SaleUnit]
		--  ,p.[Sale_Unit_QTY] = c.[BaseUnitQTY] * isnull(uc.ConvertRate,1)
		--  ,p.[Base_Unit] = c.[BaseUnit]
		--  ,p.[Base_Unit_QTY] = c.[BaseUnitQTY]
		--  ,p.[Price_Unit] = c.[PriceUnit]
		--  ,p.[Price] = c.[Price]
		--  ,p.[Tax_Rate] = c.[TaxRate]
		--  ,p.[Tax_Price] = c.[TaxPrice]
		--  ,p.[Discount_Rate] = c.[DiscountRate]
		--  ,p.[Amount] = c.[Amount]
		--  ,p.[Tax_Amount] = c.[TaxAmount]
		--  ,p.[Full_Amount] = c.[FullAmount]
		--  ,p.[Discount_Amount] = c.[DiscountAmount]
		--  ,p.[IsFree] = c.[IsFree]
		--  ,p.[Stock_Unit] = c.[StockUnit]
		--  ,p.[Stock_QTY] = c.[StockQTY]
		--  ,p.[MPRClose_Status] = c.[MPRCloseStatus]
		--  ,p.[Terminate_Status] = c.[TerminateStatus]
		--  ,p.[Lock_QTY] = c.[LockQTY]
		--  ,p.[Lock_Flag] = c.[LockFlag]
		--  ,p.[Plan_Delivery_Date] = c.[PlanDeliveryDate]
		--	,p.[Update_Time] = GETDATE() 
		--	,p.[Update_By] = @ProcName
		--FROM [dm].[Fct_ERP_Sale_OrderEntry] p
		--JOIN ODS.[ods].[ERP_Sale_OrderEntry] c ON p.[Order_Entry_ID] = c.[OrderEntryID]
		--LEFT JOIN [ODS].[ods].[ERP_Unit_ConvertRate] uc ON c.[BaseUnit] = uc.FromUnit AND c.[SaleUnit] = uc.ToUnit
		;
	
		INSERT INTO [dm].[Fct_ERP_Sale_OrderEntry]
		( [Order_Entry_ID]
		  ,[Sale_Order_ID]
		  ,[Sequence_ID]
		  ,[SKU_ID]
		  ,[Unit]
		  ,[QTY]
		  ,[Sale_Unit]
		  ,[Sale_Unit_QTY]
		  ,[Base_Unit]
		  ,[Base_Unit_QTY]
		  ,[Price_Unit]
		  ,[Price]
		  ,[Tax_Rate]
		  ,[Tax_Price]
		  ,[Discount_Rate]
		  ,[Amount]
		  ,[Tax_Amount]
		  ,[Full_Amount]
		  ,[Discount_Amount]
		  ,[IsFree]
		  ,[Stock_Unit]
		  ,[Stock_QTY]
		  ,[MPRClose_Status]
		  ,[Terminate_Status]
		  ,[Lock_QTY]
		  ,[Lock_Flag]
		  ,[Plan_Delivery_Date]
		  ,LOT
		  ,produce_date
		  ,[Create_Time]
		  ,[Create_By]
		  ,[Update_Time]
		  ,[Update_By]
			)
		SELECT 
			c.[OrderEntryID]
			,c.[SaleOrderID]
			,c.[SequenceID]
			,c.[SKU_ID]
			,c.[Unit]
			,c.[QTY]
			,ISNULL(c.[SaleUnit],prod.Sale_Unit) AS [SaleUnit]
			,CASE WHEN c.Unit = ISNULL(c.[SaleUnit],prod.Sale_Unit) THEN c.[QTY] ELSE c.[BaseUnitQTY] * isnull(uc.ConvertRate,1) END AS SaleUnitQTY
			,c.[BaseUnit]
			,c.[BaseUnitQTY]
			,c.[PriceUnit]
			,c.[Price]
			,c.[TaxRate]
			,c.[TaxPrice]
			,c.[DiscountRate]
			,c.[Amount]
			,c.[TaxAmount]
			,c.[FullAmount]
			,c.[DiscountAmount]
			,c.[IsFree]
			,c.[StockUnit]
			,c.[StockQTY]
			,c.[MPRCloseStatus]
			,c.[TerminateStatus]
			,c.[LockQTY]
			,c.[LockFlag]
			,c.[PlanDeliveryDate]
		    ,c.[Batch]
			,c.produce_date
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Sale_OrderEntry] c
		LEFT JOIN [dm].[Fct_ERP_Sale_OrderEntry] p	ON p.[Order_Entry_ID] = c.[OrderEntryID]
		LEFT JOIN dm.Dim_Product prod ON c.SKU_ID = prod.SKU_ID
		LEFT JOIN [ODS].[ods].[ERP_Unit_ConvertRate] uc ON c.[BaseUnit] = uc.FromUnit AND c.[SaleUnit] = uc.ToUnit
		WHERE p.[Order_Entry_ID] IS NULL;
		

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
