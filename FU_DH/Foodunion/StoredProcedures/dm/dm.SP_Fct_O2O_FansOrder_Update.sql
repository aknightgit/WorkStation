USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dm].[SP_Fct_O2O_FansOrder_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--Update Dim
	EXEC [dm].[SP_Dim_O2O_Employee_Update];	
	EXEC [dm].[SP_Dim_O2O_KOL_Update];
	EXEC [dm].[SP_Dim_O2O_Fans_Update];

	--Update Fct
	--EXEC [dm].[SP_Fct_O2O_Order_Base_info_Update];  -- SCRM 数据停止更新，暂停SP    Justin 20200902
	--EXEC [dm].[SP_Fct_O2O_Order_Detail_info_Update];  -- SCRM 数据停止更新，暂停SP    Justin 20200902
	EXEC [dm].[SP_Fct_O2O_StoreOrder_Update];  --暂时从系统下载文件，再上传到数据库    Justin 20200902
	EXEC [dm].[SP_Fct_O2O_StoreOrder_Detail_Update];   --暂时从系统下载文件，再上传到数据库    Justin 20200902
	EXEC [dm].[SP_Fct_O2O_wxFans_info_Update];
	EXEC [dm].[SP_Fct_O2O_wxFans_event_record_Update];
	EXEC [dm].[SP_Fct_O2O_Order_Delivery_Update];
	EXEC [dm].[SP_Fct_O2O_Order_Delivery_Detail_Update];

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END
GO
