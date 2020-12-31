USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dm].[SP_Fct_ERP_Stock_PurchaseOrder_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

		--[dm].[Fct_ERP_Stock_PurchaseOrder]

		TRUNCATE TABLE [dm].[Fct_ERP_Stock_PurchaseOrder];	
		INSERT INTO [dm].[Fct_ERP_Stock_PurchaseOrder]
			([Datekey]
			,[POOrder_ID]
			,[Bill_No]
			,[Bill_Type]
			,[Purchase_Org]
			,[Puchase_Dept]
			,[Document_Status]
			,[Close_Status]
			,[Cancel_Status]
			,[Confirm_Status]
			,[Close_Date]
			,[Business_Type]
			,[Remarks]
			,[Create_Time]
			,[Create_By]
			,[Update_Time]
			,[Update_By])
		
		SELECT CONVERT(VARCHAR(8),[Date],112)
			,[POOrderID]
			,[BillNo]
			,[BillType]
			,[PurchaseOrg]
			,[PuchaseDept]
			,[DocumentStatus]
			,[CloseStatus]
			,[CancelStatus]
			,[ConfirmStatus]
			,[CloseDate]
			,[BusinessType]
			,[Remarks]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Stock_PurchaseOrder]
		;
		
		--[dm].[Fct_ERP_Stock_PurchaseOrderEntry]
		
		TRUNCATE TABLE [dm].[Fct_ERP_Stock_PurchaseOrderEntry];
		INSERT INTO [dm].[Fct_ERP_Stock_PurchaseOrderEntry]
			([POOrder_ID]
			,[Sequence_ID]
			,[SourceBillNo]
			,[SKU_ID]
			,[Unit]
			,[QTY]
			,[Stock_Unit]
			,[Stock_QTY]
			,[Note]
			,[Is_Stock]
			,[Delivery_Date]
			,[Price_Unit]
			,[Price_QTY]
			,[Price]
			,[Tax_Rate]
			,[Tax_Price]
			,[Amount]
			,[Tax_Amount]
			,[All_Amount]
			,[Discount_Amount]
			,[Rec_QTY]
			,[Stk_QTY]
			,[Remain_RecQTY]
			,[Remain_StkQTY]
			,[Create_Time]
			,[Create_By]
			,[Update_Time]
			,[Update_By])
		SELECT [POOrderID]
			,[SequenceID]
			,[SourceBillNo]
			,[SKU_ID]
			,[Unit]
			,[QTY]
			,[StockUnit]
			,[StockQTY]
			,[Note]
			,[IsStock]
			,[DeliveryDate]
			,[PriceUnit]
			,[PriceQTY]
			,[Price]
			,[TaxRate]
			,[TaxPrice]			
			,[Amount]
			,[TaxAmount]
			,[AllAmount]
			,[DiscountAmount]			
			,[RecQTY]
			,[StkQTY]
			,[RemainRecQTY]
			,[RemainStkQTY]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName			
		FROM ODS.[ods].[ERP_Stock_PurchaseOrderEntry]
		;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
