USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC  [dm].[SP_Fct_O2O_wxFans_event_record_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY
	TRUNCATE TABLE [dm].[Fct_O2O_wxFans_event_record]

	INSERT INTO [dm].[Fct_O2O_wxFans_event_record](
		   [id]
		  ,[mp_id]
		  ,[app_id]
		  ,[open_id]
		  ,[event_name]
		  ,[event_key]
		  ,[event_msg]
		  ,[event_create_time]
		  ,[in_day]
		  ,[create_time]
		  ,[Create_By]
		  ,[Update_By]
	)
	SELECT [id]
		  ,[mp_id]
		  ,[app_id]
		  ,[open_id]
		  ,[event_name]
		  ,[event_key]
		  ,[event_msg]
		  ,[event_create_time]
		  ,[in_day]
		  ,[create_time]
		  ,OBJECT_NAME(@@PROCID) AS [Create_By]
		  ,OBJECT_NAME(@@PROCID) AS [Update_By]
		  FROM [ods].[ods].[SCRM_wx_fans_event_record];
	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END


GO
