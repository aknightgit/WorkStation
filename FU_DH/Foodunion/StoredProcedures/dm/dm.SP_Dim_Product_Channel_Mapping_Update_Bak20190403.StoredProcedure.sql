USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Dim_Product_Channel_Mapping_Update_Bak20190403]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dm].[SP_Dim_Product_Channel_Mapping_Update_Bak20190403]
AS
BEGIN		
	--DM.DIM_Product_Channel_Mapping
	DECLARE @pName varchar(100) = '[DM].[SP_DIM_Product_Channel_Mapping_Update]'
	
	INSERT INTO DM.DIM_Product_Channel_Mapping
	SELECT 
		c.Channel_Name,
		c.SKU_ID,
		getdate(),
		@pName,
		getdate(),
		@pName
	FROM (
		SELECT DISTINCT 'YH' AS [Channel_Name],SKU_ID FROM [FU_DM].[T_DM_FCT_YH_Sales]
		WHERE SKU_ID IS NOT NULL
		)c
	LEFT JOIN DM.DIM_Product_Channel_Mapping m
	ON c.Channel_Name = m.Channel_Name AND c.SKU_ID = m.SKU_ID 
	WHERE m.Channel_Name IS NULL;

END
GO
