USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_Production_DemandPlanning_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dm].[SP_Fct_Production_DemandPlanning_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	DELETE t
	FROM [dm].[Fct_Production_DemandPlanning] t
	JOIN ODS.ods.File_Production_DemandPlanning s ON t.Year=s.Year AND t.Month=s.Month;
	
	INSERT INTO [dm].[Fct_Production_DemandPlanning]
           ([Year]
           ,[Month]
           ,[Month_Str]
           ,[Channel]
           ,[SKU_ID]
           ,[SKU_Name]
           ,[Item]
           ,[volume]
           ,[NetWeight]
           ,[Price]
           ,[Value]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT [Year]
			   ,[Month]
			   ,[Month_Str]
			   ,[Channel]
			   ,[SKU_ID]
			   ,[SKU_Name]
			   ,[Item]
			   ,[volume]
			   ,[NetWeight]
			   ,[Price]
			   ,[Value]
			   ,getdate(),'ods.File_Production_DemandPlanning'
			   ,getdate(),'ods.File_Production_DemandPlanning'
	FROM ODS.ods.File_Production_DemandPlanning 

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
--SELECT *FROM [dm].[Dim_Store]


	END


	--select *  FROM [dm].[Dim_Store] ds 
GO
