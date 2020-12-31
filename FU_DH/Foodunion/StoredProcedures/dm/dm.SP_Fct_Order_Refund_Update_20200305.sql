USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dm].[SP_Fct_Order_Refund_Update_20200305]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--TRUNCATE TABLE [dm].[Fct_Order_Payment]

	INSERT INTO [dm].[Fct_Order_Refund]
           ([Order_DateKey]
           ,[Order_Key]
           ,[Refund_No]
           ,[Transaction_No]
           ,[Refund_CreateTime]
           ,[Refund_EndTime]
           ,[Refund_Reason]
           ,[Refund_Status]
           ,[Refund_Via]
           ,[Return_Shipment_No]
           ,[Logistics_Name]
           ,[Refund_Goods_Amount]
           ,[Refund_Post_Fee]
           ,[Refund_Total_Amount]
           ,[Refund_Discount_Amount]
           ,[Refund_Order_Amount]
           ,[Refund_Payment_Amount]
           ,[Remarks]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
    SELECT 
		fo.Order_DateKey
		,fo.Order_Key
		,re.return_order_sn
		,re.refund_deal_code
		,re.add_time
		,re.confirm_time
		,re.return_reason
		,CASE re.return_order_status WHEN 0 THEN '未确定' WHEN 1 THEN '已确认' WHEN 3 THEN '无效' WHEN 10 THEN '已完成' END
		,re.return_pay_id
		,re.return_shipping_sn
		,re.return_shipping_name
		,re.return_market_goods_amount
		,re.return_shipping_fee
		,re.return_total_amount
		,re.return_discount_fee
		,re.return_order_amount
		,re.return_payment
		,re.return_order_msg
		,getdate() AS [Create_Time]
		,@ProcName AS [Create_By]
		,getdate() AS [Update_Time]
		,@ProcName AS [Update_By]
	FROM ODS.ods.OMS_Order_return re
	JOIN [dm].[Fct_Order] fo ON CAST(re.[relating_order_id] AS VARCHAR(200)) = fo.[Order_ID] --AND CASE WHEN oi.qd_id=1 THEN 18 ELSE 0 END = fo.[Channel_ID]
	LEFT JOIN [dm].[Fct_Order_Refund] fre ON fre.Order_Key = fo.Order_Key AND re.return_order_sn = fre.[Refund_No] AND fre.[Transaction_No] = re.refund_deal_code
	WHERE fre.Order_Key IS NULL
 	;

	UPDATE fre
	SET 
		[Refund_CreateTime]=re.add_time
		,[Refund_EndTime]=re.confirm_time
		,[Refund_Reason]=re.return_reason
		,[Refund_Status]=CASE re.return_order_status WHEN 0 THEN '未确定' WHEN 1 THEN '已确认' WHEN 3 THEN '无效' WHEN 10 THEN '已完成' END
		,[Refund_Via]=re.return_pay_id
		,[Return_Shipment_No]=re.return_shipping_sn
		,[Logistics_Name]=re.return_shipping_name
		,[Refund_Goods_Amount]=re.return_market_goods_amount
		,[Refund_Post_Fee]=re.return_shipping_fee
		,[Refund_Total_Amount]=re.return_total_amount
		,[Refund_Discount_Amount]=re.return_discount_fee
		,[Refund_Order_Amount]=re.return_order_amount
		,[Refund_Payment_Amount]=re.return_payment
		,[Remarks]=re.return_order_msg
		,[Update_Time] = getdate()  
		,[Update_By] = @ProcName  
	FROM ODS.ods.OMS_Order_return re
	JOIN [dm].[Fct_Order] fo ON CAST(re.[relating_order_id] AS VARCHAR(200)) = fo.[Order_ID] --AND CASE WHEN oi.qd_id=1 THEN 18 ELSE 0 END = fo.[Channel_ID]
	LEFT JOIN [dm].[Fct_Order_Refund] fre ON fre.Order_Key = fo.Order_Key AND re.return_order_sn = fre.[Refund_No]
	;

	UPDATE fo
		SET fo.[Refund_No] = fre.[Refund_No]
			,Is_Refund = 1
	FROM [dm].[Fct_Order] fo
	JOIN [dm].[Fct_Order_Refund] fre ON fo.Order_Key=fre.Order_Key 
	;
	UPDATE foi
		SET 
		foi.Return_Qty=rg.goods_number_return
		,foi.Refund_Amount_Split=rg.share_payment
		,foi.Refund_No=rg.return_order_sn
	FROM dm.Fct_Order_Item foi
	JOIN dm.Fct_Order fo ON foi.Order_Key=fo.Order_Key
	JOIN ods.ods.OMS_Order_return_goods rg ON fo.Order_No=rg.order_sn AND foi.Transaction_No=rg.deal_code AND foi.SKU_ID=rg.goods_sn
	;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
	

END
GO
