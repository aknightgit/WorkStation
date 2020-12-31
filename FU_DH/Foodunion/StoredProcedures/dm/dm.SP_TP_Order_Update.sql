USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dm].[SP_TP_Order_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY
	--CombinItem
	EXEC [dm].[SP_Dim_Order_CombineItem_Update];

	--Dim Order
	EXEC [dm].[SP_Dim_Order_Update];
	
	--Refund
	EXEC [dm].[SP_Fct_Order_Refund_Update];

	--Item breakdown
	EXEC [dm].[SP_Fct_Order_Item_Update];

	--Shipment
	EXEC [dm].[SP_Fct_Order_Shipment_Update];

	--Promotion
	EXEC [dm].[SP_Fct_Order_Promotion_Update];




	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END
GO
