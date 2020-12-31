USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dm].[SP_Fct_Order_ALLin1_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	EXEC [dm].[SP_Fct_Order_Update];
	EXEC [dm].[SP_Fct_Order_Payment_Update];
	EXEC [dm].[SP_Fct_Order_Shipment_Update];
	EXEC [dm].[SP_Fct_Order_Item_Update];

	--退款
	EXEC [dm].[SP_Fct_Order_Refund_Update];




	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH


END
GO
