USE [Foodunion]
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
	--dm.DIM_Product_Channel_Mapping
	--DECLARE @pName varchar(100) = '[DM].[SP_DIM_Product_Channel_Mapping_Update]'
	
	INSERT INTO dm.DIM_Product_Channel_Mapping
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
		AND SKU_ID IS NOT NULL
		UNION
		SELECT DISTINCT 'YH' AS [Channel_Name],SKU_ID FROM [dm].[Fct_YH_Sales_Inventory]
		WHERE SKU_ID IS NOT NULL
		--UNION
		--SELECT DISTINCT dc.Channel_Name,sc.SKU_ID FROM [dm].[Fct_Sales_SellOut_ByChannel] sc
		--JOIN dm.Dim_Channel dc ON sc.Channel_ID=dc.Channel_ID
		--WHERE sc.SKU_ID IS NOT NULL
		)c
	LEFT JOIN dm.DIM_Product_Channel_Mapping m
	ON c.Channel_Name = m.Channel_Name AND c.SKU_ID = m.SKU_ID 
	WHERE m.Channel_Name IS NULL;
	
	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END


--truncate table dm.DIM_Product_Channel_Mapping
GO
