USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC  [dm].[SP_Dim_O2O_Employee_Update]
AS BEGIN

	 DECLARE @errmsg nvarchar(max),
	 @DatabaseName varchar(100) = DB_NAME(),
	 @ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	TRUNCATE TABLE  [dm].[Dim_O2O_Employee] ;

	INSERT INTO [dm].[Dim_O2O_Employee]
           ([Employee_id]
			,[Employee_name]
			,[alias]
			,[english_name]
			,[employee_no]
			,[employee_type]
			,[mobile]
			,[gender]
			,[position]
			,[status]
			,[scene_qrcode_id]
			,[wx_work_user_id]
			,[org_name]
			,[wx_org_id]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])

	SELECT [employee_id]
			,[employee_name]
			,[alias]
			,[english_name]
			,[employee_no]
			,[employee_type]
			,[mobile]
			,[gender]
			,[position]
			,[status]
			,[scene_qrcode_id]
			,[wx_work_user_id]
			,[org_name]
			,[wx_org_id]
			,GETDATE(),@ProcName,GETDATE(),@ProcName
	FROM ODS.[ods].[SCRM_youzan_employee]
	;


END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
