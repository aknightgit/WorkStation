USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dm].[SP_Dim_Product_Leadtime_Update]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--TRUNCATE TABLE [dm].[Dim_Product_Leadtime];
	DELETE p
	FROM [dm].[Dim_Product_Leadtime] p
	JOIN ODS.stg.File_Product_Leadtime s ON p.[SKU_ID]=s.[SKU_ID];

	INSERT INTO [dm].[Dim_Product_Leadtime]
           ([SKU_ID]
           ,[SKU_Name]
           ,[SKU_Name_CN]
		   ,[Product_Category] 
		   ,[Shelf_Life_D]
           ,[LongestRawMaterialLeadtime]
           ,[DaysProductionLeadtimeIncludingQFS]
           ,[ProductionCycle]
           ,[DeliveryLeadtime]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
     
	SELECT SKU_ID,
		SKUName,
		CNDescription,
		Category,
		Shelflife,
		[LongestRawMaterialLeadtime],
        [DaysProductionLeadtimeIncludingQFS],
        [ProductionCycle],
        [DeliveryLeadtime],
		GETDATE(),@ProcName,
		GETDATE(),@ProcName
	FROM ODS.stg.File_Product_Leadtime
	WHERE Status='Active';
	--SELECT * FROM ODS.stg.File_Product_Leadtime
	
	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END
GO
