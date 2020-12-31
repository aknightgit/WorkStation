USE [Foodunion]
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
	SET d.[Price_List_Name] = ISNULL(o.[Price_List_Name],d.[Price_List_Name])
        ,d.[Sale_ORG_Name] = ISNULL(o.[Sale_ORG_Name],d.[Sale_ORG_Name])
        ,d.[Sale_Unit] = ISNULL(o.[Sale_Unit],d.[Sale_Unit])
        ,d.[SKU_Price] = ISNULL(CASE WHEN ISNULL(o.Include_Tax,1)=1 AND d.Price_List_No<>'XSJMB0085' THEN isnull(o.[SKU_Price],o.[SKU_Base_Price])/(1+CAST(p.Tax_Rate/100 AS decimal(18,5)))
			ELSE isnull(o.[SKU_Price],o.[SKU_Base_Price]) END
			,d.[SKU_Price])
		,d.[SKU_Price_withTax] = ISNULL(CASE WHEN ISNULL(o.Include_Tax,1)=1 AND d.Price_List_No<>'XSJMB0085' THEN isnull(o.[SKU_Price],o.[SKU_Base_Price])
			ELSE isnull(o.[SKU_Price],o.[SKU_Base_Price])*(1+CAST(p.Tax_Rate/100 AS decimal(18,5))) END
			,d.[SKU_Price_withTax])
        ,d.[Base_Unit] = ISNULL(o.[Base_Unit],d.[Base_Unit])
        ,d.[SKU_Base_Price] = ISNULL( CASE WHEN ISNULL(o.Include_Tax,1)=1 AND d.Price_List_No<>'XSJMB0085' THEN o.[SKU_Base_Price]/(1+CAST(p.Tax_Rate/100 AS decimal(18,5)))
			ELSE o.[SKU_Base_Price] END
			,d.[SKU_Base_Price])
		,d.[Base_Price_withTax] = ISNULL(CASE WHEN ISNULL(o.Include_Tax,1)=1 AND d.Price_List_No<>'XSJMB0085' THEN o.[SKU_Base_Price]
			ELSE o.[SKU_Base_Price]*(1+CAST(p.Tax_Rate/100 AS decimal(18,5))) END
			,d.[Base_Price_withTax])
        ,d.[Effective_Date] = ISNULL(o.[Effective_Date],d.[Effective_Date])
        ,d.[Expiry_Date] = ISNULL(o.[Expiry_Date],d.[Expiry_Date])
		,d.Is_Current = CASE WHEN ISNULL(o.[Expiry_Date],d.[Expiry_Date])<GETDATE() THEN 0 ELSE 1 END
		,d.Update_Time = GETDATE()
		,d.Update_By = OBJECT_NAME(@@PROCID)
	FROM [dm].[Dim_Product_Pricelist] d
	LEFT JOIN ODS.[ods].[ERP_SKU_Pricelist] o ON o.Price_List_No=d.Price_List_No and o.SKU_ID=d.SKU_ID	
	JOIN ODS.ods.ERP_SKU_List p ON d.SKU_ID = p.SKU_ID;

	INSERT INTO [dm].[Dim_Product_Pricelist]
           ([Price_List_No]
           ,[Price_List_Name]
           ,[Sale_ORG_Name]
           ,[Sale_Unit]
           ,[SKU_ID]
           ,[SKU_Price]
		   ,[SKU_Price_withTax]
           ,[Base_Unit]
           ,[SKU_Base_Price]
		   ,[Base_Price_withTax]
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
		,CASE WHEN o.Include_Tax=1 THEN isnull(o.[SKU_Price],o.[SKU_Base_Price])
			ELSE isnull(o.[SKU_Price],o.[SKU_Base_Price])*(1+p.Tax_Rate/100) END
        ,o.[Base_Unit]
        ,o.[SKU_Base_Price]
		, CASE WHEN o.Include_Tax=1 THEN o.[SKU_Base_Price]
			ELSE o.[SKU_Base_Price]/(1+p.Tax_Rate*100) END
        ,o.[Effective_Date]
        ,o.[Expiry_Date]
		,CASE WHEN o.[Expiry_Date]<GETDATE() THEN 0 ELSE 1 END
		,GETDATE()
		,OBJECT_NAME(@@PROCID)
		,GETDATE()
		,OBJECT_NAME(@@PROCID)
	FROM ODS.[ods].[ERP_SKU_Pricelist] o
	LEFT JOIN [dm].[Dim_Product_Pricelist] d ON o.Price_List_No=d.Price_List_No and o.SKU_ID=d.SKU_ID	
	JOIN ODS.ods.ERP_SKU_List p ON o.SKU_ID = p.SKU_ID
	WHERE d.Price_List_No is null	;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END
GO
