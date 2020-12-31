USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dm].[SP_Fct_O2O_Order_Delivery_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--[dm].[Fct_O2O_Order_Delivery];
	TRUNCATE TABLE [dm].[Fct_O2O_Order_Delivery];
	INSERT INTO [dm].[Fct_O2O_Order_Delivery]
           ([ID]
           ,[Delivery_No]
           ,[Order_No]
           ,[kdtId]
           ,[Delivery_PointId]
           ,[Status]
           ,[Dist_Type]
           ,[Extend]
           ,[Delivery_CreateTime]
           ,[Delivery_UpdateTime]
           ,[Delivery_Fee]
           ,[Delivery_Fee_Real]
           ,[Remark]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
    SELECT [id]
		  ,[deliveryNo]
		  ,[orderNo]
		  ,[kdtId]
		  ,[deliveryPointId]
		  ,[status]
		  ,[distType]
		  ,[extend]
		  ,[createTime]
		  ,[updateTime]
		  ,[deliveryFee]
		  ,[realDeliveryFee]
		  ,[remark]
		  ,GETDATE(),@ProcName
		  ,GETDATE(),@ProcName
	FROM ods.[ods].[SCRM_order_delivery];
	
	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END
GO
