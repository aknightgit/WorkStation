USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Dim_ERP_CustomerList_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dm].[SP_Dim_ERP_CustomerList_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY
		
		--[dm].[Dim_ERP_CustomerList]
		UPDATE p
		SET p.[Customer_Name] = c.[CustomerName]
			,p.[Customer_Name_EN] = c.[CustomerName_EN]
			,p.[Short_Name] = c.[ShortName]
			,p.[ERP_Code] = c.[ERPCode]
			,p.[Customer_Address] = c.[CustomerAddress]
			,p.[ZIP] = c.[ZIP]
			,p.[TEL] = c.[TEL]
			,p.[FAX] = c.[FAX]
			,p.[Is_Credit_Check] = c.[IsCreditCheck]
			,p.[Tax_Rate] = c.[TaxRate]
			,p.[Price_List_No] = c.[PriceListNo]
			,p.[Discount_List_No] = c.[DiscountListNo]
			,p.[Use_Org] = c.[UseOrg]
			,p.[IsActive] = c.[IsActive]
			,p.[Update_Time] = GETDATE() 
			,p.[Update_By] = @ProcName
		FROM [dm].[Dim_ERP_CustomerList] p
		JOIN ODS.[ods].[ERP_Customer_List] c
		ON p.Customer_ID = c.CustomerID;
	
		INSERT INTO [dm].[Dim_ERP_CustomerList]
			([Customer_ID]
           ,[Customer_Name]
           ,[Customer_Name_EN]
           ,[Short_Name]
           ,[ERP_Code]
           ,[Customer_Address]
           ,[ZIP]
           ,[TEL]
           ,[FAX]
           ,[Is_Credit_Check]
           ,[Tax_Rate]
           ,[Price_List_No]
           ,[Discount_List_No]
           ,[Use_Org]
		   ,[IsActive]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By]
			)
		SELECT 
			c.[CustomerID]
           ,c.[CustomerName]
           ,c.[CustomerName_EN]
           ,c.[ShortName]
           ,c.[ERPCode]
           ,c.[CustomerAddress]
           ,c.[ZIP]
           ,c.[TEL]
           ,c.[FAX]
           ,c.[IsCreditCheck]
           ,c.[TaxRate]
           ,c.[PriceListNo]
           ,c.[DiscountListNo]
           ,c.[UseOrg]
		   ,c.[IsActive]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Customer_List] c
		LEFT JOIN [dm].[Dim_ERP_CustomerList] p
		ON p.Customer_ID = c.CustomerID
		WHERE p.Customer_ID IS NULL;
		

		--[dm].[Dim_ERP_Customer_Shipto]
		DELETE p
		FROM [dm].[Dim_ERP_Customer_Shipto] p
		JOIN ODS.[ods].[ERP_Customer_Shipto] c
		ON p.[Customer_ID] = c.[Customer_ID];

		INSERT INTO [dm].[Dim_ERP_Customer_Shipto]
           ([Customer_ID]
           ,[Customer_Name]
           ,[Sequence_ID]
           ,[Ship_To]
           ,[Ship_To_Desc]
           ,[Address]
           ,[TEL]
           ,[IsActive]
           ,[Start_Date]
           ,[End_Date]
           ,[Country]
           ,[Mobile]
           ,[Default_Stock_ID]
           ,[Default_Stock_Name]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
		SELECT c.[Customer_ID]
           ,c.[Customer_Name]
           ,c.[Sequence_ID]
           ,c.[Ship_To]
           ,c.[Ship_To_Desc]
           ,c.[Address]
           ,c.[TEL]
           ,c.[IsActive]
           ,c.[Start_Date]
           ,c.[End_Date]
           ,c.[Country]
           ,c.[Mobile]
           ,c.[Default_Stock_ID]
           ,c.[Default_Stock_Name]
           ,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Customer_Shipto] c
		LEFT JOIN [dm].[Dim_ERP_Customer_Shipto] p
		ON p.[Customer_ID] = c.[Customer_ID]
		WHERE p.[Customer_ID] IS NULL;


	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
