USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [dm].[SP_Fct_ERP_Stock_OutStock_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

		--[dm].[Fct_ERP_Stock_OutStock]
		--UPDATE p
		--SET p.[OutStock_ID] = c.[OutStock_ID]
  --         ,p.[Datekey] = convert(varchar(8),c.Date,112)
  --         ,p.[Bill_Type] = c.[Bill_Type]
  --         ,p.[Bill_No] = c.[Bill_No]
  --         ,p.[Date] = c.[Date]
  --         ,p.[Customer_ID] = c.[Customer_ID]
  --         ,p.[Customer_Name] = c.[Customer_Name]
  --         ,p.[Stock_Org] = c.[Stock_Org]
  --         ,p.[Delivery_Dept] = c.[Delivery_Dept]
  --         ,p.[Sale_Org] = c.[Sale_Org]
  --         ,p.[Sale_Dept] = c.[Sale_Dept]
  --         ,p.[Carriage_No] = c.[Carriage_No]
  --         ,p.[Document_Status] = c.[Document_Status]
  --         ,p.[Cancel_Status] = c.[Cancel_Status]
  --         ,p.[Business_Type] = c.[Business_Type]
  --         ,p.[Receive_Contact] = c.[Receive_Contact]
  --         ,p.[Receive_Address] = c.[Receive_Address]
  --         ,p.[Transfer_Biz_Type] = c.[Transfer_Biz_Type]
  --         ,p.[Credit_Check_Result] = c.[Credit_Check_Result]
  --         ,p.[Plan_Receive_Address] = c.[Plan_Receive_Address]
  --         ,p.[Note] = c.[Note]
		--	,p.[Update_Time] = GETDATE() 
		--	,p.[Update_By] = @ProcName
		--FROM [dm].[Fct_ERP_Stock_OutStock] p
		--JOIN ODS.[ods].[ERP_Stock_OutStock] c ON p.[OutStock_ID] = c.[OutStock_ID]
		TRUNCATE TABLE [dm].[Fct_ERP_Stock_OutStock]
	
		INSERT INTO [dm].[Fct_ERP_Stock_OutStock]
           ([OutStock_ID]
           ,[Datekey]
           ,[Bill_Type]
           ,[Bill_No]
           ,[Date]
           ,[Customer_ID]
		   ,[Channel_ID]
           ,[Customer_Name]
           ,[Stock_Org]
           ,[Delivery_Dept]
           ,[Sale_Org]
           ,[Sale_Dept]
           ,[Carriage_No]
           ,[Document_Status]
           ,[Cancel_Status]
           ,[Business_Type]
		   ,[Ship_to]
           ,[Receive_Contact]
           ,[Receive_Address]
           ,[Transfer_Biz_Type]
           ,[Credit_Check_Result]
           ,[Plan_Receive_Address]
           ,[Note]
		   ,[Sales_Man]
		   ,[SourceBillNo]
		   ,[SaleOrderNo]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
		SELECT 
			c.[OutStock_ID]
			,convert(varchar(8),c.Date,112)
           ,c.[Bill_Type]
           ,c.[Bill_No]
           ,c.[Date]
           ,c.[Customer_ID]
		   ,dc.[Channel_ID]
           ,c.[Customer_Name]
           ,c.[Stock_Org]
           ,c.[Delivery_Dept]
           ,c.[Sale_Org]
           ,c.[Sale_Dept]
           ,c.[Carriage_No]
           ,c.[Document_Status]
           ,c.[Cancel_Status]
           ,c.[Business_Type]
		   ,c.[Ship_to]
           ,c.[Receive_Contact]
           ,c.[Receive_Address]
           ,c.[Transfer_Biz_Type]
           ,c.[Credit_Check_Result]
           ,c.[Plan_Receive_Address]
           ,c.[Note]		   
		   ,c.[Sales_Man]
		   ,c.[Source_Bill_No]
		   ,c.[SaleOrder_No]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Stock_OutStock] c
		LEFT JOIN [dm].[Fct_ERP_Stock_OutStock] p	ON p.[OutStock_ID] = c.[OutStock_ID]
		LEFT JOIN (SELECT ERP_Customer_Name,MAX(Channel_ID) AS Channel_ID FROM dm.Dim_Channel GROUP BY ERP_Customer_Name) dc 
			ON ISNULL(c.[Customer_Name],'') = dc.ERP_Customer_Name
		WHERE p.[OutStock_ID] IS NULL;
		
		--[dm].[Fct_ERP_Stock_OutStockEntry]
		--UPDATE p
		--SET   p.[SKU_ID] = c.[SKU_ID]
		--  ,p.[Unit] = c.[Unit]
		--  ,p.[Must_QTY] = c.[Must_QTY]
		--  ,p.[Real_QTY] = c.[Real_QTY]
		--  ,p.[Stock_Name] = c.[Stock_Name]
		--  ,p.[Stock_Status] = c.[Stock_Status]
		--  ,p.[LOT] = c.[LOT]
		--  ,p.[LOT_Display] = c.[LOT_Display]
		--  ,p.[Gross_Weight] = c.[Gross_Weight]
		--  ,p.[Net_Weight] = c.[Net_Weight]
		--  ,p.[Note] = c.[Note]
		--  ,p.[Produce_Date] = c.[Produce_Date]
		--  ,p.[Expiry_Date] = c.[Expiry_Date]
		--  ,p.[Arrival_Status] = c.[Arrival_Status]
		--  ,p.[Arrival_Date] = c.[Arrival_Date]
		--  ,p.[Is_Repair] = c.[Is_Repair]
		--  ,p.[Repair_QTY] = c.[Repair_QTY]
		--  ,p.[Refuse_QTY] = c.[Refuse_QTY]
		--  ,p.[Return_QTY] = c.[Return_QTY]
		--  ,p.[Actual_QTY] = c.[Actual_QTY]
		--  ,p.[Price] = c.[Price]
		--  ,p.[Tax_Price] = c.[Tax_Price]
		--  ,p.[Price_Unit] = c.[Price_Unit]
		--  ,p.[Price_Unit_QTY] = c.[Price_Unit_QTY]
		--  ,p.[Base_Unit] = c.[Base_Unit]
		--  ,p.[Base_Unit_QTY] = c.[Base_Unit_QTY]
		--  ,p.[Sale_Unit] = prod.Sale_Unit_CN
		--  ,p.Sale_Unit_QTY = CASE WHEN prod.Base_Unit_CN = prod.Sale_Unit_CN THEN c.Base_Unit_QTY ELSE c.Base_Unit_QTY*cr.Convert_Rate END 
		--  ,p.[Tax_Rate] = c.[Tax_Rate]
		--  ,p.[Discount_Rate] = c.[Discount_Rate]
		--  ,p.[Tax_Amount] = c.[Tax_Amount]
		--  ,p.[Discount_Amount] = c.[Discount_Amount]
		--  ,p.[Amount] = c.[Amount]
		--  ,p.[Full_Amount] = c.[Full_Amount]
		--  ,p.[Cost_Price] = c.[Cost_Price]
		--  ,p.[Cost_Amount] = c.[Cost_Amount]
		--  ,p.[IsFree] = c.[IsFree]
		--	,p.[Update_Time] = GETDATE() 
		--	,p.[Update_By] = @ProcName
		--FROM [dm].[Fct_ERP_Stock_OutStockEntry] p
		--JOIN ODS.[ods].[ERP_Stock_OutStockEntry] c ON p.[OutStock_ID] = c.[OutStock_ID] AND p.[Sequence_ID] = c.[Sequence_ID]
		--LEFT JOIN [dm].Dim_Product prod ON prod.SKU_ID = c.SKU_ID 
		--LEFT JOIN dm.Dim_ERP_Unit_ConvertRate cr ON cr.From_Unit = prod.Base_Unit_CN AND cr.To_Unit = prod.Sale_Unit_CN
		TRUNCATE TABLE [dm].[Fct_ERP_Stock_OutStockEntry]
	
		INSERT INTO [dm].[Fct_ERP_Stock_OutStockEntry]
			([OutStock_ID]
			,[Sequence_ID]
			,[SKU_ID]
			,[Unit]
			,[Must_QTY]
			,[Real_QTY]
			,[Stock_Name]
			,[Stock_Status]
			,[LOT]
			,[LOT_Display]
			,[Gross_Weight]
			,[Net_Weight]
			,[Note]
			,[Produce_Date]
			,[Expiry_Date]
			,[Arrival_Status]
			,[Arrival_Date]
			,[Is_Repair]
			,[Repair_QTY]
			,[Refuse_QTY]
			,[Return_QTY]
			,[Actual_QTY]
			,[Price]
			,[Tax_Price]
			,[Price_Unit]
			,[Price_Unit_QTY]
			,[Base_Unit]
			,[Base_Unit_QTY]
			,[Sale_Unit]
			,[Sale_Unit_QTY]
			,[Tax_Rate]
			,[Discount_Rate]
			,[Tax_Amount]
			,[Discount_Amount]
			,[Amount]
			,[Full_Amount]
			,[Cost_Price]
			,[Cost_Amount]
			,[Goods_Value]
			,[Full_Goods_Value]
			,[IsFree]
			--,[IsSKU]
			,[Create_Time]
			,[Create_By]
			,[Update_Time]
			,[Update_By])
		SELECT 
			c.[OutStock_ID]
			,c.[Sequence_ID]
			,c.[SKU_ID]
			,c.[Unit]
			,c.[Must_QTY]
			,c.[Real_QTY]
			,c.[Stock_Name]
			,c.[Stock_Status]
			,c.[LOT]
			,c.[LOT_Display]
			,c.[Gross_Weight]
			--,c.[Net_Weight]
			,ISNULL(CASE WHEN c.Base_Unit = prod.Sale_Unit_CN THEN c.Base_Unit_QTY ELSE c.Base_Unit_QTY*cr.Convert_Rate END,C.Sale_Unit_QTY)
				* prod.Sale_Unit_Weight_KG
			,c.[Note]
			,c.[Produce_Date]
			,c.[Expiry_Date]
			,c.[Arrival_Status]
			,c.[Arrival_Date]
			,c.[Is_Repair]
			,c.[Repair_QTY]
			,c.[Refuse_QTY]
			,c.[Return_QTY]
			,c.[Actual_QTY]
			,c.[Price]
			,c.[Tax_Price]
			,c.[Price_Unit]
			,c.[Price_Unit_QTY]
			,c.[Base_Unit]
			,c.[Base_Unit_QTY]
			,ISNULL(prod.Sale_Unit_CN,c.Sale_Unit) AS [Sale_Unit]
			,ISNULL(CASE WHEN c.Base_Unit = prod.Sale_Unit_CN THEN c.Base_Unit_QTY ELSE c.Base_Unit_QTY*cr.Convert_Rate END,C.Sale_Unit_QTY) AS Sale_Unit_QTY
			,c.[Tax_Rate]
			,c.[Discount_Rate]
			,c.[Tax_Amount]
			,c.[Discount_Amount]
			,c.[Amount]
			,c.[Full_Amount]
			,c.[Cost_Price]
			,c.[Cost_Amount]
			,CASE WHEN c.[Full_Amount] = 0.00 THEN ISNULL(CASE WHEN c.Base_Unit = prod.Sale_Unit_CN THEN c.Base_Unit_QTY ELSE c.Base_Unit_QTY*cr.Convert_Rate END,C.Sale_Unit_QTY) * ISNULL(pl.SKU_Price ,pl2.SKU_Price)
				ELSE 0 END
			,CASE WHEN c.[Full_Amount] = 0.00 THEN ISNULL(CASE WHEN c.Base_Unit = prod.Sale_Unit_CN THEN c.Base_Unit_QTY ELSE c.Base_Unit_QTY*cr.Convert_Rate END,C.Sale_Unit_QTY) * ISNULL(pl.SKU_Price_withTax,pl2.SKU_Price_withTax)
				ELSE 0 END
			,c.[IsFree]
			--,CASE WHEN  pl.SKU_ID IS NULL AND PP.Price_List_No IS NOT NULL THEN 1 ELSE 0 END IS_SKU
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
			--select count(1)
		FROM ODS.[ods].[ERP_Stock_OutStockEntry] c
		LEFT JOIN [dm].[Fct_ERP_Stock_OutStockEntry] p ON p.[OutStock_ID] = c.[OutStock_ID] and  p.[Sequence_ID] = c.[Sequence_ID]
		LEFT JOIN [dm].Dim_Product prod WITH(NOLOCK) ON prod.SKU_ID = c.SKU_ID 
		LEFT JOIN [dm].[Fct_ERP_Stock_OutStock] os WITH(NOLOCK) ON c.OutStock_ID=os.OutStock_ID
		LEFT JOIN [dm].[Dim_ERP_CustomerList] ecl WITH(NOLOCK) ON os.Customer_ID=ecl.Customer_ID
		LEFT JOIN [dm].Dim_Product_Pricelist pl WITH(NOLOCK) ON pl.Is_Current=1 AND prod.SKU_ID = pl.SKU_ID AND ecl.Price_List_No=pl.Price_List_No
		LEFT JOIN dm.Dim_ERP_Unit_ConvertRate cr WITH(NOLOCK) ON cr.From_Unit = c.Base_Unit AND cr.To_Unit = prod.Sale_Unit_CN
		--LEFT JOIN (SELECT DISTINCT Price_List_No FROM [dm].Dim_Product_Pricelist) PP ON ecl.Price_List_No=pp.Price_List_No
		LEFT JOIN [Foodunion].[dm].[Dim_Channel] CC
		ON OS.Channel_ID=CC.Channel_ID
		LEFT JOIN (SELECT * FROM [dm].Dim_Product_Pricelist WHERE Price_List_No IN('XSJMB0081','XSJMB0078')) AS pl2  
		ON pl2.Is_Current=1 AND prod.SKU_ID = pl2.SKU_ID   AND CC.Channel_Type='CP'
		WHERE p.[OutStock_ID] IS NULL;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
