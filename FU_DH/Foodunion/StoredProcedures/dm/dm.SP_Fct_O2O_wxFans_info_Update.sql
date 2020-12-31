USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dm].[SP_Fct_O2O_wxFans_info_Update]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY
	TRUNCATE TABLE [dm].[Fct_O2O_wxFans_info]

	INSERT INTO [dm].[Fct_O2O_wxFans_info](
		   [id]
		  ,[mp_id]
		  ,[app_id]
		  ,[member_id]
		  ,[union_id]
		  ,[open_id]
		  ,[nick_name]
		  ,[head_img_url]
		  ,[gender]
		  ,[city]
		  ,[province]
		  ,[country]
		  ,[language]
		  ,[subscribe]
		  ,[subscribe_time]
		  ,[subscribe_scene]
		  ,[qr_scene]
		  ,[qr_scene_str]
		  ,[remark]
		  ,[group_id]
		  ,[tagid_list]
		  ,[whole_fans_info_str]
		  ,[scene_qrcode_id]
		  ,[create_time]
		  ,[update_time]
		  ,[Create_By]
		  ,[Update_By]
	)
	SELECT [id]
		  ,[mp_id]
		  ,[app_id]
		  ,[member_id]
		  ,[union_id]
		  ,[open_id]
		  ,[nick_name]
		  ,[head_img_url]
		  ,[gender]
		  ,[city]
		  ,[province]
		  ,[country]
		  ,[language]
		  ,[subscribe]
		  ,[subscribe_time]
		  ,[subscribe_scene]
		  ,[qr_scene]
		  ,[qr_scene_str]
		  ,[remark]
		  ,[group_id]
		  ,[tagid_list]
		  ,[whole_fans_info_str]
		  ,[scene_qrcode_id]
		  ,[create_time]
		  ,[update_time]
		  ,OBJECT_NAME(@@PROCID) AS [Create_By]
		  ,OBJECT_NAME(@@PROCID) AS [Update_By]
		  FROM [ods].[ods].[SCRM_wx_fans_info];

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END


GO
