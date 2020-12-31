USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dm].[SP_Dim_ERP_RawMaterial_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY	
	-- Update Price list from ERP_SKU_PriceList

	--Table [dm].[Dim_ERP_RawMaterial] should not be truncate or delete.

	UPDATE d
	SET d.[SKU_Name] = o.[SKU_Name]
		  ,d.[SKU_Name_EN] = o.[SKU_Name_EN]
		  ,d.[Group_Name] = o.[Group_Name]
		  ,d.[UseOrg] = o.[UseOrg]
		  ,d.[CreateOrg] = o.[CreateOrg]
		  ,d.[CGLB1] = o.[CGLB1]
		  --,d.[CGLB2] = o.[CGLB2]
		  ,d.[LifeTime] = o.[LifeTime]
		  ,d.[Unit_Cost] = cast(o.[Unit_Cost] as decimal(19,10))
		  ,d.[IsActive] = o.[IsActive]
		,d.Update_Time = GETDATE()
		,d.Update_By = OBJECT_NAME(@@PROCID)
	FROM [dm].[Dim_ERP_RawMaterial] d
	JOIN ODS.[ods].[ERP_RawMaterial_List] o ON o.SKU_ID=d.SKU_ID	;
	
	INSERT INTO [dm].[Dim_ERP_RawMaterial]
           ( [SKU_ID]
		  ,[SKU_Name]
		  ,[SKU_Name_EN]
		  ,[Group_Name]
		  ,[UseOrg]
		  ,[CreateOrg]
		  ,[CGLB1]
		  ,[Category]
		  ,[LifeTime]
		  ,[Unit_Cost]
		  ,[IsActive]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT 
		o.[SKU_ID]
		  ,o.[SKU_Name]
		  ,o.[SKU_Name_EN]
		  ,o.[Group_Name]
		  ,o.[UseOrg]
		  ,o.[CreateOrg]
		  ,o.[CGLB1]
		  --,o.[CGLB2]
		  ,null		  
		  ,o.[LifeTime]
		  ,o.[Unit_Cost]
		  ,o.[IsActive]
		,GETDATE()
		,OBJECT_NAME(@@PROCID)
		,GETDATE()
		,OBJECT_NAME(@@PROCID)
	FROM ODS.[ods].[ERP_RawMaterial_List] o
	LEFT JOIN [dm].[Dim_ERP_RawMaterial] d ON o.[SKU_ID]=d.[SKU_ID] 
	WHERE d.[SKU_ID] is null;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END


--select top 100 * from [dm].[Fct_ERP_Stock_InStockEntry] 
GO
