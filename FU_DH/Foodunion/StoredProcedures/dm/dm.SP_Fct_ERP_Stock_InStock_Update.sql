USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dm].[SP_Fct_ERP_Stock_InStock_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

		--[dm].[Fct_ERP_Stock_InStock]
		--UPDATE p
		--SET p.[InStock_ID] = c.[InStock_ID]
		--,p.[Datekey] = convert(varchar(8),c.Date,112)
  --         ,p.[Bill_Type] = c.[Bill_Type]
  --         ,p.[Bill_No] = c.[Bill_No]
  --         ,p.[Date] = c.[Date]
  --         ,p.[Stock_Org] = c.[Stock_Org]
  --         ,p.[Purchase_Org] = c.[Purchase_Org]
  --         ,p.[Stock_Dept] = c.[Stock_Dept]
  --         ,p.[Document_Status] = c.[Document_Status]
  --         ,p.[Confirm_Status] = c.[Confirm_Status]
  --         ,p.[Business_Type] = c.[Business_Type]
		--	,p.[Update_Time] = GETDATE() 
		--	,p.[Update_By] = @ProcName
		--FROM [dm].[Fct_ERP_Stock_InStock] p
		--JOIN ODS.[ods].[ERP_Stock_InStock] c ON p.[InStock_ID] = c.[InStock_ID]
		--;
		TRUNCATE TABLE [dm].[Fct_ERP_Stock_InStock]
	
		INSERT INTO [dm].[Fct_ERP_Stock_InStock]
           ([InStock_ID]
		   ,[Datekey]
           ,[Bill_Type]
           ,[Bill_No]
           ,[Date]
           ,[Stock_Org]
           ,[Purchase_Org]
           ,[Stock_Dept]
           ,[Document_Status]
           ,[Confirm_Status]
           ,[Business_Type]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
		SELECT 
			c.[InStock_ID]
			,convert(varchar(8),c.Date,112)
           ,c.[Bill_Type]
           ,c.[Bill_No]
           ,c.[Date]
           ,c.[Stock_Org]
           ,c.[Purchase_Org]
           ,c.[Stock_Dept]
           ,c.[Document_Status]
           ,c.[Confirm_Status]
           ,c.[Business_Type]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Stock_InStock] c
		LEFT JOIN [dm].[Fct_ERP_Stock_InStock] p	ON p.[InStock_ID] = c.[InStock_ID]
		WHERE p.[InStock_ID] IS NULL;
		
		--[dm].[Fct_ERP_Stock_InStockEntry]
		--UPDATE p
		--SET p.[InStock_ID] = c.[InStock_ID]
  --         ,p.[Order_No] = c.[Order_No]
  --         ,p.[Sequence_ID] = c.[Sequence_ID]
  --         ,p.[SKU_ID] = c.[SKU_ID]
  --         ,p.[Stock_Name] = c.[Stock_Name]
  --         ,p.[Stock_Status] = c.[Stock_Status]
  --         ,p.[Must_QTY] = c.[Must_QTY]
  --         ,p.[Real_QTY] = c.[Real_QTY]
  --         ,p.[Produce_Date] = c.[Produce_Date]
  --         ,p.[Expiry_Date] = c.[Expiry_Date]
  --         ,p.[LOT] = c.[LOT]
  --         ,p.[LOT_Display] = c.[LOT_Display]
  --         ,p.[Base_Unit] = c.[Base_Unit]
  --         ,p.[Base_Unit_QTY] = c.[Base_Unit_QTY]
  --         ,p.[Base_Unit_Price] = c.[Base_Unit_Price]
  --         ,p.[Price] = c.[Price]
  --         ,p.[TaxPrice] = c.[TaxPrice]
  --         ,p.[Price_Unit] = c.[Price_Unit]
  --         ,p.[Price_Unit_QTY] = c.[Price_Unit_QTY]
  --         ,p.[Tax_Rate] = c.[Tax_Rate]
  --         ,p.[Discount_Rate] = c.[Discount_Rate]
  --         ,p.[IsFree] = c.[IsFree]
  --         ,p.[Tax_Amount] = c.[Tax_Amount]
  --         ,p.[Discount_Amount] = c.[Discount_Amount]
  --         ,p.[Amount] = c.[Amount]
  --         ,p.[Full_Amount] = c.[Full_Amount]
  --         ,p.[Cost_Price] = c.[Cost_Price]
  --         ,p.[Cost_Amount] = c.[Cost_Amount]
  --         ,p.[Gross_Weight] = c.[Gross_Weight]
  --         ,p.[Net_Weight] = c.[Net_Weight]
  --         ,p.[Note] = c.[Note]
  --         ,p.[Remain_InStock_Base_QTY] = c.[Remain_InStock_Base_QTY]
		--	,p.[Update_Time] = GETDATE() 
		--	,p.[Update_By] = @ProcName
		--FROM [dm].[Fct_ERP_Stock_InStockEntry] p
		--JOIN ODS.[ods].[ERP_Stock_InStockEntry] c ON p.[InStock_ID] = c.[InStock_ID] AND p.[Sequence_ID] = c.[Sequence_ID]
		--;
		TRUNCATE TABLE [dm].[Fct_ERP_Stock_InStockEntry]

		INSERT INTO [dm].[Fct_ERP_Stock_InStockEntry]
           ([InStock_ID]
           ,[SourceBillNo]
           ,[Sequence_ID]
           ,[SKU_ID]
           ,[Stock_Name]
           ,[Stock_Status]
		   ,[Unit]
           ,[Must_QTY]
           ,[Real_QTY]
           ,[Produce_Date]
           ,[Expiry_Date]
           ,[LOT]
           ,[LOT_Display]
           ,[Base_Unit]
           ,[Base_Unit_QTY]
           ,[Base_Unit_Price]
		   ,Sale_Unit
		   ,Sale_Unit_QTY
           ,[Price]
           ,[TaxPrice]
           ,[Price_Unit]
           ,[Price_Unit_QTY]
           ,[Tax_Rate]
           ,[Discount_Rate]
           ,[IsFree]
           ,[Tax_Amount]
           ,[Discount_Amount]
           ,[Amount]
           ,[Full_Amount]
           ,[Cost_Price]
           ,[Cost_Amount]
           ,[Gross_Weight]
           ,[Net_Weight]
           ,[Note]
           ,[Remain_InStock_Base_QTY]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
		SELECT 
			c.[InStock_ID]
           ,c.[SourceBillNo]
           ,c.[Sequence_ID]
           ,c.[SKU_ID]
           ,c.[Stock_Name]
           ,c.[Stock_Status]
		   ,c.[Unit]
           ,c.[Must_QTY]
           ,c.[Real_QTY]
           ,c.[Produce_Date]
           ,c.[Expiry_Date]
           ,c.[LOT]
           ,c.[LOT_Display]
           ,c.[Base_Unit]
           ,c.[Base_Unit_QTY]
           ,c.[Base_Unit_Price]
		   ,ISNULL(prod.Sale_Unit_CN,c.[Price_Unit]) AS [Sale_Unit]
		   ,ISNULL(CASE WHEN c.Base_Unit = prod.Sale_Unit_CN THEN c.Base_Unit_QTY ELSE c.Base_Unit_QTY*cr.Convert_Rate END,C.[Price_Unit_QTY]) AS Sale_Unit_QTY
           ,c.[Price]
           ,c.[TaxPrice]
           ,c.[Price_Unit]
           ,c.[Price_Unit_QTY]
           ,c.[Tax_Rate]
           ,c.[Discount_Rate]
           ,c.[IsFree]
           ,c.[Tax_Amount]
           ,c.[Discount_Amount]
           ,c.[Amount]
           ,c.[Full_Amount]
           ,c.[Cost_Price]
           ,c.[Cost_Amount]
           ,c.[Gross_Weight]
           ,c.[Net_Weight]
           ,c.[Note]
           ,c.[Remain_InStock_Base_QTY]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Stock_InStockEntry] c
		LEFT JOIN [dm].[Fct_ERP_Stock_InStockEntry] p	ON p.[InStock_ID] = c.[InStock_ID] and  p.[Sequence_ID] = c.[Sequence_ID]
		LEFT JOIN [dm].Dim_Product prod ON prod.SKU_ID = c.SKU_ID 
		LEFT JOIN dm.Dim_ERP_Unit_ConvertRate cr ON cr.From_Unit = c.Base_Unit AND cr.To_Unit = prod.Sale_Unit_CN
		WHERE p.[InStock_ID] IS NULL;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
