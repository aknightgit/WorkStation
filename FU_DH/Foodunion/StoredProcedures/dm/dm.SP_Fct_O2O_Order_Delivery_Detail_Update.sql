USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dm].[SP_Fct_O2O_Order_Delivery_Detail_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--[dm].[[Fct_O2O_Order_Delivery_Detail]];
	TRUNCATE TABLE [dm].[Fct_O2O_Order_Delivery_Detail];
	INSERT INTO [dm].[Fct_O2O_Order_Delivery_Detail]
           ([id]
           ,[Delivery_No]
           ,[Order_No]
           ,[kdtId]
           ,[Item_Id]
           ,[Num]
           ,[Weight]
           ,[Delivery_Status]
           ,[Delivery_Status_Desc]
           ,[noNeed_Delivery_Reason]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT [id]
		,[deliveryNo]
		,[orderNo]
		,[kdtId]
		,[itemId]
		,[num]
		,[weight]
		,[deliveryStatus]
		,[deliveryStatusDesc]
		,[noNeedDeliveryReason]
		,GETDATE(),@ProcName
		,GETDATE(),@ProcName
	 FROM ODS.[ods].[SCRM_order_delivery_detail];
	
	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END
GO
