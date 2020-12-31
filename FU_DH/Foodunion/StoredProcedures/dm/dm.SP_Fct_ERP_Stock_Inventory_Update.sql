USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dm].[SP_Fct_ERP_Stock_Inventory_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

		--[dm].[Dim_ERP_StockList]
		--DELETE 		p
		--FROM [dm].[Dim_ERP_StockList] p
		--JOIN ODS.[ods].[ERP_Stock_List] c
		--ON p.[Stock_ID] = c.[Stock_ID];

		UPDATE p
		SET p.[Stock_ID] = c.[Stock_ID]
           ,p.[Stock_Code] = c.[Stock_Code]
           ,p.[Allow_Lock] = c.[Allow_Lock]
           ,p.[Stock_Address] = c.[Stock_Address]
           ,p.[Stock_Name] = c.[Stock_Name]
		   ,p.[Stock_Name_EN] = CASE WHEN ISNULL(p.[Stock_Name_EN],'')='' THEN c.[Stock_Name_EN] ELSE p.[Stock_Name_EN] END
           ,p.[Use_Org] = c.[Use_Org]
		   ,p.[Stock_Desc] = c.[Stock_Desc]
		   ,p.[Status] = c.[Status]
		   ,p.[Property] = c.[Property]
		   ,p.[Stock_Group] = c.[Stock_Group]
		   ,p.[Stock_Group_Desc] = c.[Stock_Group_Desc]
           ,p.[Update_Time] = GETDATE()
           ,p.[Update_By] = @ProcName			
		FROM [dm].[Dim_ERP_StockList] p
		JOIN ODS.[ods].[ERP_Stock_List] c
		ON p.[Stock_ID] = c.[Stock_ID];
           
		INSERT INTO [dm].[Dim_ERP_StockList]
           ([Stock_ID]
           ,[Stock_Code]
           ,[Allow_Lock]
           ,[Stock_Address]
           ,[Stock_Name]
		   ,[Stock_Name_EN]
           ,[Use_Org]
		   ,[Stock_Desc]
		   ,[Status]
		   ,[Property]
		   ,[Stock_Group]
		   ,[Stock_Group_Desc]
		   --,[Stock_Org]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
		SELECT c.[Stock_ID]
           ,c.[Stock_Code]
           ,c.[Allow_Lock]
           ,c.[Stock_Address]
           ,c.[Stock_Name]
		   ,c.[Stock_Name_EN]
           ,c.[Use_Org]
		   ,c.[Stock_Desc]
		   ,c.[Status]
		   ,c.[Property]
		   ,c.[Stock_Group]
		   ,c.[Stock_Group_Desc]
           ,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Stock_List] c
		LEFT JOIN [dm].[Dim_ERP_StockList] p
		ON p.[Stock_ID] = c.[Stock_ID]
		WHERE p.[Stock_ID] IS NULL 
		AND c.Stock_ID NOT IN (231603);  -- o2o备用


		-- Update dm.Dim_Warehouse
		EXEC [dm].[SP_Dim_Warehouse_Update]

		--TRUNCATE TABLE [dm].[Fct_ERP_Stock_Inventory];

		--UPDATE p
		--SET p.[Datekey] = c.[Datekey]
		--	,p.[RDC] = c.[RDC]
		--	,p.[Stock_Status] = c.[StockStatus]
		--	,p.[SKU_ID] = c.[SKU_ID]
		--	,p.[SKU_Name] = c.[SKU_Name]
		--	,p.[Flot] = c.[Flot]
		--	,p.[Produce_Date] = c.[ProduceDate]
		--	,p.[Expiry_Date] = c.[ExpiryDate]
		--	,p.[Base_Unit] = c.[BaseUnit]
		--	,p.[Base_QTY] = c.[BaseQTY]
		--	,p.[Sale_Unit] = c.[SaleUnit]
		--	,p.[Sale_QTY] = c.[SaleQTY]
		--	,p.[Update_Time] = GETDATE() 
		--	,p.[Update_By] = @ProcName
		--FROM [dm].[Fct_ERP_Stock_Inventory] p
		--JOIN ODS.[ods].[ERP_Stock_Inventory] c
		--ON p.[Datekey] = c.[Datekey];

		--DELETE 		p
		--FROM [dm].[Fct_ERP_Stock_Inventory] p
		--JOIN ODS.[ods].[ERP_Stock_Inventory] c
		--ON p.[Datekey] = c.[Datekey] AND p.SKU_ID = c.SKU_ID;
	
		--Only the 1st version of Inventory to be keeped
		INSERT INTO [dm].[Fct_ERP_Stock_Inventory]
		([Datekey]
		  ,[Stock_ID]
		  ,[Stock_Name]
		  ,[Stock_Org]
		  ,[Stock_Status]
		  ,[SKU_ID]
		  ,[SKU_Name]
		  ,[SKU_Name_EN]
		  ,LOT
		  ,[Produce_Date]
		  ,[Expiry_Date]
		  ,Storaging_Date
		  ,[Stock_Unit]
		  ,[Stock_QTY]
		  ,[Lock_QTY]
		  ,[Base_Unit]
		  ,[Base_QTY]
		  ,[Sale_Unit]
		  ,[Sale_QTY]
		  ,[IsEffective]
		  ,[Create_Time]
		  ,[Create_By]
		  ,[Update_Time]
		  ,[Update_By]
			)
		SELECT 
			c.[Datekey]
			,isnull(sl.[Stock_ID],0)
			,c.[Stock_Name]
			,c.[Stock_Org]
			,c.[Stock_Status]
			,c.[SKU_ID]
			,c.[SKU_Name]
			,c.[SKU_Name_EN]
			,c.[Flot]
			,c.[Produce_Date]
			,c.[Expiry_Date]
			,c.Storaging_Date
			--,c.[Stock_Unit]
			,CASE WHEN ucs.Convert_Rate IS NULL THEN c.Base_Unit ELSE p.Produce_Unit END AS [Stock_Unit]  --如果转化失败，直接取base unit 
			,CASE WHEN ucs.Convert_Rate IS NULL THEN c.[Base_QTY]  ELSE c.[Base_QTY] * ucs.Convert_Rate END AS Stock_QTY  --如果转化失败，直接取base qty 
			--,c.[Stock_QTY]
			--,c.[Base_QTY] * ISNULL(ucs.Convert_Rate,1) AS Stock_QTY
			,c.[Lock_QTY]
			,c.[Base_Unit]
			,c.[Base_QTY]
			,CASE WHEN ucsa.Convert_Rate IS NULL THEN c.Base_Unit ELSE c.Sale_Unit END AS Sale_Unit  --如果转化失败，直接取base unit 
			,CASE WHEN ucsa.Convert_Rate IS NULL THEN c.[Base_QTY]  ELSE c.[Base_QTY] * ucsa.Convert_Rate END AS Sale_QTY  --如果转化失败，直接取base qty 
			--,c.[Sale_Unit]
			--,c.[Sale_QTY]
			--,c.[Base_QTY] * ISNULL(ucsa.Convert_Rate,1) AS Sale_QTY
			,c.[IsEffective]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Stock_Inventory] c		
		LEFT JOIN [dm].[Dim_Product] p ON c.SKU_ID = p.SKU_ID
		LEFT JOIN [dm].[Dim_ERP_StockList] sl ON c.Stock_Name = sl.Stock_Name AND c.Stock_Org=sl.Use_Org
		LEFT JOIN [dm].[Dim_ERP_Unit_ConvertRate] ucs ON ucs.From_Unit = c.[Base_Unit] AND ucs.To_Unit = p.Produce_Unit--c.[Stock_Unit]
		LEFT JOIN [dm].[Dim_ERP_Unit_ConvertRate] ucsa ON ucsa.From_Unit = c.[Base_Unit] AND ucsa.To_Unit = c.[Sale_Unit]
		LEFT JOIN [dm].[Fct_ERP_Stock_Inventory] fct
		ON fct.[Datekey] = c.[Datekey] AND fct.[Stock_Name] = c.[Stock_Name] AND fct.[SKU_ID] = c.[SKU_ID] AND fct.LOT = c.[Flot] AND c.Stock_Status = fct.[Stock_Status]
		WHERE fct.[Datekey] IS NULL AND c.Stock_Org = '富友联合食品（中国）有限公司'
		AND c.IsEffective >0
		AND c.[Produce_Date] IS NOT NULL  -- PRUDUTE DATE NULL NOT VALID
		AND c.Stock_Name IS NOT NULL
		

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
