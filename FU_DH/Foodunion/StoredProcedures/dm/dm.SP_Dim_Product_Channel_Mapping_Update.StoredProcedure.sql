USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Dim_Product_Channel_Mapping_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dm].[SP_Dim_Product_Channel_Mapping_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY		
	--DM.DIM_Product_Channel_Mapping
	--DECLARE @pName varchar(100) = '[DM].[SP_DIM_Product_Channel_Mapping_Update]'
	
	INSERT INTO DM.DIM_Product_Channel_Mapping
	SELECT 
		c.Channel_Name,
		c.SKU_ID,
		getdate(),
		@ProcName,
		getdate(),
		@ProcName
	FROM (
		SELECT DISTINCT 'YH' AS [Channel_Name], SKU_ID  FROM [dm].[Fct_Sales_Plan]
  where SALES_FCST_VOL is not null
  UNION
  SELECT DISTINCT 'YH' AS [Channel_Name],SKU_ID FROM [dm].[Fct_YH_Sales_Inventory]
		WHERE SKU_ID IS NOT NULL
		)c
	LEFT JOIN DM.DIM_Product_Channel_Mapping m
	ON c.Channel_Name = m.Channel_Name AND c.SKU_ID = m.SKU_ID 
	WHERE m.Channel_Name IS NULL;
	
	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END
GO
