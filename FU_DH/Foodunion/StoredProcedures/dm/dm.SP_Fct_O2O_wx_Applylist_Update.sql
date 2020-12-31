USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	  
CREATE PROCEDURE  [dm].[SP_Fct_O2O_wx_Applylist_Update]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
	@DatabaseName varchar(100) = DB_NAME(),
	@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY 

	TRUNCATE TABLE [dm].[Fct_O2O_wx_Applylist];

	INSERT INTO [dm].[Fct_O2O_wx_Applylist]
			([sp_num]
			,[spname]
			,[apply_name]
			,[apply_org]
			,[approval_name]
			,[notify_name]
			,[sp_status]
			,[mediaids]
			,[apply_time]
			,[apply_user_id]
			,[Create_time]
			,[Create_By]
			,[Update_time]
			,[Update_By])
	SELECT [sp_num]
			,[spname]
			,[apply_name]
			,[apply_org]
			,[approval_name]
			,[notify_name]
			,[sp_status]
			,[mediaids]
			,[apply_time]
			,[apply_user_id]
		,GETDATE() AS [Create_Time]
		,OBJECT_NAME(@@PROCID) AS [Create_By]
		,GETDATE() AS [Update_Time]
		,OBJECT_NAME(@@PROCID) AS [Update_By]
	FROM ods.ods.SCRM_wx_applylist;

   END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
