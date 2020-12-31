USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Dim_Product_Pricelist_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dm].[SP_Dim_Product_Pricelist_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY	
	-- Update Price list from ERP_SKU_PriceList

	--Table [dm].[Dim_Product_Pricelist] should not be truncate or delete.

	UPDATE d
	SET d.[Price_List_Name] = o.[Price_List_Name]
        ,d.[Sale_ORG_Name] = o.[Sale_ORG_Name]
        ,d.[Sale_Unit] = o.[Sale_Unit]
        ,d.[SKU_Price] = isnull(o.[SKU_Price],o.[SKU_Base_Price])
        ,d.[Base_Unit] = o.[Base_Unit]
        ,d.[SKU_Base_Price] = o.[SKU_Base_Price]
        ,d.[Effective_Date] = o.[Effective_Date]
        ,d.[Expiry_Date] = o.[Expiry_Date]
		,d.Is_Current = CASE WHEN o.[Expiry_Date]<GETDATE() THEN 0 ELSE 1 END
		,d.Update_Time = GETDATE()
		,d.Update_By = OBJECT_NAME(@@PROCID)
	FROM [dm].[Dim_Product_Pricelist] d
	JOIN ODS.[ods].[ERP_SKU_Pricelist] o ON o.Price_List_No=d.Price_List_No and o.SKU_ID=d.SKU_ID	;
	
	INSERT INTO [dm].[Dim_Product_Pricelist]
           ([Price_List_No]
           ,[Price_List_Name]
           ,[Sale_ORG_Name]
           ,[Sale_Unit]
           ,[SKU_ID]
           ,[SKU_Price]
           ,[Base_Unit]
           ,[SKU_Base_Price]
           ,[Effective_Date]
           ,[Expiry_Date]
           ,[Is_Current]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT 
		o.[Price_List_No]
        ,o.[Price_List_Name]
        ,o.[Sale_ORG_Name]
        ,o.[Sale_Unit]
        ,o.[SKU_ID]
        ,isnull(o.[SKU_Price],o.[SKU_Base_Price])
        ,o.[Base_Unit]
        ,o.[SKU_Base_Price]
        ,o.[Effective_Date]
        ,o.[Expiry_Date]
		,CASE WHEN o.[Expiry_Date]<GETDATE() THEN 0 ELSE 1 END
		,GETDATE()
		,OBJECT_NAME(@@PROCID)
		,GETDATE()
		,OBJECT_NAME(@@PROCID)
	FROM ODS.[ods].[ERP_SKU_Pricelist] o
	LEFT JOIN [dm].[Dim_Product_Pricelist] d ON o.Price_List_No=d.Price_List_No and o.SKU_ID=d.SKU_ID	
	WHERE d.Price_List_No is null	;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END
GO
