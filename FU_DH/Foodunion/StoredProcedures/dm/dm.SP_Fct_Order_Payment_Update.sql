USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dm].[SP_Fct_Order_Payment_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--TRUNCATE TABLE [dm].[Fct_Order_Payment]
	INSERT INTO [dm].[Fct_Order_Payment]
           ([Order_DateKey]
           ,[Order_Key]
           ,[Payment_ID]
           ,[SeqID]
           ,[Payment_Type]
           ,[Payment_Method]
           ,[Payment_Status]
           ,[Payment_Platform]
           ,[Payment_AccountID]
           ,[Payment_Time]
           ,[Received_Time]     
           ,[Goods_Amount]
           ,[Post_Fee]
		   ,[Adjust_Fee]
		   ,[Total_Amount]
           ,[Discount_Amount]
           ,[Order_Amount]
           ,[Payment_Amount]
           ,[Received_Amount]
           ,[Point_Awarded]
           ,[Point_Fee]
           ,[Invoice_ID]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
    SELECT fo.Order_DateKey
		,fo.Order_Key
		,oi.pay_sn AS [Payment_ID]
		,1 AS [SeqID]
		,oi.pay_name AS [Payment_Type]
		,oi.pay_code AS [Payment_Method]
		,CASE oi.pay_status WHEN 0 THEN '未付款' WHEN 1 THEN '付款中(部分付款)' WHEN 2 THEN '已付款' END AS [Payment_Status]
		,null AS [Payment_Platform]
		,null AS [Payment_AccountID]
		,oi.pay_time AS [Payment_Time]
		,null AS [Received_Time]		
		,oi.market_goods_amount AS [Goods_Amount]
		,oi.shipping_fee AS [Post_Fee]
		,NULL AS [Adjust_Fee]
		,oi.total_amount AS [Total_Amount]		
		,oi.discount_fee+oi.other_discount_fee AS [Discount_Amount]
		,oi.order_amount AS [Order_Amount]
		,oi.payment AS [Payment_Amount]
		,NULL AS [Received_Amount]
		,NULL AS [Point_Awarded]
		,NULL AS [Point_Fee]
		,NULL AS [Invoice_ID]
		,getdate() AS [Create_Time]
		,@ProcName AS [Create_By]
		,getdate() AS [Update_Time]
		,@ProcName AS [Update_By]
	FROM ODS.ods.OMS_Order_Info oi
	JOIN [dm].[Fct_Order] fo ON CAST(oi.order_id AS VARCHAR(200)) = fo.[Order_ID] --AND CASE WHEN oi.qd_id=1 THEN 18 ELSE 0 END = fo.[Channel_ID]
	LEFT JOIN [dm].[Fct_Order_Payment] fop ON fop.Order_Key = fo.Order_Key AND oi.pay_sn = fop.[Payment_ID]
	WHERE fop.Order_Key IS NULL
 	;

	UPDATE fop
	SET 
		[Payment_Type] = oi.pay_name 
		,[Payment_Method]=oi.pay_code  
		,[Payment_Status]=CASE oi.pay_status WHEN 0 THEN '未付款' WHEN 1 THEN '付款中(部分付款)' WHEN 2 THEN '已付款' END  
		,[Payment_Time]=oi.pay_time  
		--,null AS [Received_Time]
		,[Total_Amount]=oi.total_amount  
		--,NULL AS [Adjust_Fee]
		,[Post_Fee]=oi.shipping_fee  
		,[Discount_Amount]=oi.discount_fee+oi.other_discount_fee
		,[Order_Amount]=oi.order_amount  
		,[Payment_Amount]=oi.payment  
		,[Update_Time]=getdate()  
		,[Update_By]=@ProcName  
	FROM ODS.ods.OMS_Order_Info oi
	JOIN [dm].[Fct_Order] fo ON CAST(oi.order_id AS VARCHAR(200)) = fo.[Order_ID] --AND CASE WHEN oi.qd_id=1 THEN 18 ELSE 0 END = fo.[Channel_ID]
	JOIN [dm].[Fct_Order_Payment] fop ON fop.Order_Key = fo.Order_Key AND oi.pay_sn = fop.[Payment_ID]
	;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH


END
GO
