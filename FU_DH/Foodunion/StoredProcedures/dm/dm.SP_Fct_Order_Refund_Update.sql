USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dm].[SP_Fct_Order_Refund_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--SELECT COUNT(1) FROM  [dm].[Fct_Order_Refund]
	TRUNCATE TABLE [dm].[Fct_Order_Refund]
	INSERT INTO [dm].[Fct_Order_Refund]
           ([Order_DateKey]
           ,[Order_Key]
           ,[Refund_No]
           ,[Transaction_No]
           ,[Refund_CreateTime]
           ,[Refund_EndTime]
		   ,[Refund_Type]
           ,[Refund_Reason]
           ,[Refund_Status]
           ,[Refund_Via]
           ,[Is_Return]
           ,[Return_No]
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
	--taobao退款
	SELECT 
			m.[Order_DateKey] AS [Order_DateKey]
           ,m.[Order_Key] AS [Order_Key]
           ,ods.[refund_id] AS [Refund_No]
           ,ods.oid AS [Transaction_No]
           ,ods.created AS [Refund_CreateTime]
           ,ods.time_success AS [Refund_EndTime]
		   ,ods.refund_type AS [Refund_Type]
           ,ods.reason AS [Refund_Reason]
           ,ods.status AS [Refund_Status]
           ,NULL AS [Refund_Via]
           ,ods.has_good_return AS [Is_Return]
           ,NULL AS [Return_No]
           ,NULL AS [Return_Shipment_No]
           ,NULL AS [Logistics_Name]
           ,NULL AS [Refund_Goods_Amount]
           ,NULL AS [Refund_Post_Fee]
           ,NULL AS [Refund_Total_Amount]
           ,NULL AS [Refund_Discount_Amount]
           ,NULL AS [Refund_Order_Amount]
           ,ods.actual_refund_fee AS [Refund_Payment_Amount]
           ,ods.do_order_msg AS [Remarks]
           ,GETDATE() AS [Create_Time]
           ,'[OMS_Taobao_Refunds_Trade]' AS [Create_By]
           ,GETDATE() AS [Update_Time]
           ,'[OMS_Taobao_Refunds_Trade]' AS [Update_By]
		   --SELECT *
	FROM ODS.ods.[OMS_Taobao_Refunds_Trade] ods
	JOIN (SELECT foi.Transaction_No
		,MAX(fo.[Order_DateKey])  [Order_DateKey]
		,MAX(fo.[Order_Key]) [Order_Key]
	FROM dm.Fct_Order_Item foi WITH(NOLOCK) 
	JOIN dm.Fct_Order fo WITH(NOLOCK) ON foi.Order_Key=fo.Order_Key 
		AND foi.Order_DateKey=fo.Order_DateKey 
		AND fo.Is_Split=0
		AND foi.SeqID=1
		GROUP BY foi.Transaction_No
		--针对'890006272499962688' 这种异常拆单退款，只把退款记到最后一笔子交易号上
		)m	ON ods.oid=m.Transaction_No 

	UNION
	--pdd退款
	SELECT 
			fo.[Order_DateKey] AS [Order_DateKey]
           ,fo.[Order_Key] AS [Order_Key]
           ,ods.return_id AS [Refund_No]
           ,'' AS [Transaction_No]
           ,ods.create_time AS [Refund_CreateTime]
           --,ods.update_time AS [Refund_EndTime]
		   ,CASE WHEN ods.update_time <= ods.lastchanged THEN ods.update_time
				ELSE ods.lastchanged END AS [Refund_EndTime]
		   ,'refund' AS [Refund_Type]
           ,ods.reason AS [Refund_Reason]
           ,CASE ods.status WHEN 10 THEN 'Success' WHEN 11 THEN 'Closed' END AS [Refund_Status]
           ,NULL AS [Refund_Via]
           ,NULL AS [Is_Return]
           ,NULL AS [Return_No]
           ,NULL AS [Return_Shipment_No]
           ,NULL AS [Logistics_Name]
           ,NULL AS [Refund_Goods_Amount]
           ,NULL AS [Refund_Post_Fee]
           ,NULL AS [Refund_Total_Amount]
           ,ods.discount_amount AS [Refund_Discount_Amount]
           ,ods.order_amount AS [Refund_Order_Amount]
           ,ods.refund_amount AS [Refund_Payment_Amount]
           ,ods.error_msg AS [Remarks]
           ,GETDATE() AS [Create_Time]
           ,'[OMS_Pinduoduo_Refunds_Trade]' AS [Create_By]
           ,GETDATE() AS [Update_Time]
           ,'[OMS_Pinduoduo_Refunds_Trade]' AS [Update_By]
		   --SELECT *
	FROM ODS.ods.[OMS_Pinduoduo_Refunds_Trade] ods
	JOIN dm.Fct_Order fo WITH(NOLOCK) ON fo.Trans_No=ods.order_sn AND fo.Is_Split=0
	JOIN DM.Dim_Channel dc ON fo.Channel_ID=dc.Channel_ID AND Channel_Category='EC-PDD'
	WHERE ods.status = 10 
		;
	--WHERE ods.tid='874053347900839440'
	--WHERE foi.Transaction_No is null
	--ORDER BY 3
	--SELECT * FROM DM.Dim_Channel WHERE Channel_Category LIKE '%PDD%'
	--select * from ODS.ods.[OMS_Pinduoduo_Refunds_Trade] ods where order_sn='191205-336383509213727'
	--SELECT * FROM DM.FCT_ORDER WHERE Trans_No='191205-336383509213727'
	--SELECT * FROM DM.Fct_Order_Item WHERE Order_Key=447236

	--select order_sn from  ODS.ods.[OMS_Pinduoduo_Refunds_Trade] ods
	--where status=10
	--group by order_sn having(count(1)>1)
	--order by 3


	--UPDATE foi
	--SET foi.Refund_No = NULL,
	--	foi.Refund_Amount_Split = NULL
	--FROM dm.Fct_Order_Item foi ;

	UPDATE foi
	SET foi.Refund_No = r.Refund_No,
		foi.Refund_Amount_Split = 
			--CASE WHEN fo.Is_Cancelled=1 THEN Payment_Amount_Split ELSE 
			CASE WHEN ISNULL(pay.Payment,0)=0 THEN NULL ELSE r.Refund_Payment_Amount * foi.Payment_Amount_Split / pay.Payment END
			--END
			,
		foi.Return_Qty = CASE WHEN fo.Is_Cancelled=1 or foi.Payment_Amount_Split=(CASE WHEN ISNULL(pay.Payment,0)=0 THEN 0 ELSE r.Refund_Payment_Amount * foi.Payment_Amount_Split / pay.Payment END )THEN foi.Quantity
			ELSE 0 END, 
		foi.Refund_Status ='Success'
	 FROM dm.Fct_Order_Item foi 
	JOIN dm.Fct_Order fo ON foi.Order_Key = fo.Order_Key AND fo.Is_Split=0
	JOIN (SELECT Order_Key,Transaction_No,SUM(Payment_Amount_Split) Payment FROM dm.Fct_Order_Item 
	GROUP BY Order_Key,Transaction_No) pay ON foi.Order_Key=pay.Order_Key AND foi.Transaction_No=pay.Transaction_No
	JOIN [dm].[Fct_Order_Refund] r ON foi.Order_Key=r.Order_Key 
		AND foi.Transaction_No=r.Transaction_No
		AND r.Refund_Status='Success'
		--AND foi.SeqID=1   --无法拆分，更新到第一条记录
	WHERE foi.Is_Gift=0	
		--AND ISNULL(foi.Refund_No,'') <> r.Refund_No
		;

	UPDATE fo
		SET fo.Refund_Amount = r.Refund
		,Update_Time = getdate()
	FROM dm.Fct_Order fo
	JOIN (SELECT Order_Key,sum(Refund_Amount_Split) Refund FROM dm.Fct_Order_Item  
		GROUP BY Order_Key)r 
	ON fo.Order_Key=r.Order_Key 
	WHERE ISNULL(fo.Refund_Amount,0) <> ISNULL(r.Refund,0)
	--WHERE fo.Is_Split=0 AND fo.Copy_From=0

	--select * from ODS.ods.[OMS_Taobao_Refunds_Trade] ods where oid = '833982496399863823'
	--select * from dm.Fct_Order_Item foi where Transaction_No= '833982496399863823' and SeqID=1
	--select * from dm.

 --   SELECT 
	--	fo.Order_DateKey
	--	,fo.Order_Key
	--	,re.return_order_sn
	--	,re.refund_deal_code
	--	,re.add_time
	--	,re.confirm_time
	--	,re.return_reason
	--	,CASE re.return_order_status WHEN 0 THEN '未确定' WHEN 1 THEN '已确认' WHEN 3 THEN '无效' WHEN 10 THEN '已完成' END
	--	,re.return_pay_id
	--	,re.return_shipping_sn
	--	,re.return_shipping_name
	--	,re.return_market_goods_amount
	--	,re.return_shipping_fee
	--	,re.return_total_amount
	--	,re.return_discount_fee
	--	,re.return_order_amount
	--	,re.return_payment
	--	,re.return_order_msg
	--	,getdate() AS [Create_Time]
	--	,@ProcName AS [Create_By]
	--	,getdate() AS [Update_Time]
	--	,@ProcName AS [Update_By]
	--FROM ODS.ods.OMS_Order_return re
	--JOIN [dm].[Fct_Order] fo ON CAST(re.[relating_order_id] AS VARCHAR(200)) = fo.[Order_ID] --AND CASE WHEN oi.qd_id=1 THEN 18 ELSE 0 END = fo.[Channel_ID]
	--LEFT JOIN [dm].[Fct_Order_Refund] fre ON fre.Order_Key = fo.Order_Key AND re.return_order_sn = fre.[Refund_No] AND fre.[Transaction_No] = re.refund_deal_code
	--WHERE fre.Order_Key IS NULL
 --	;

	--UPDATE fre
	--SET 
	--	[Refund_CreateTime]=re.add_time
	--	,[Refund_EndTime]=re.confirm_time
	--	,[Refund_Reason]=re.return_reason
	--	,[Refund_Status]=CASE re.return_order_status WHEN 0 THEN '未确定' WHEN 1 THEN '已确认' WHEN 3 THEN '无效' WHEN 10 THEN '已完成' END
	--	,[Refund_Via]=re.return_pay_id
	--	,[Return_Shipment_No]=re.return_shipping_sn
	--	,[Logistics_Name]=re.return_shipping_name
	--	,[Refund_Goods_Amount]=re.return_market_goods_amount
	--	,[Refund_Post_Fee]=re.return_shipping_fee
	--	,[Refund_Total_Amount]=re.return_total_amount
	--	,[Refund_Discount_Amount]=re.return_discount_fee
	--	,[Refund_Order_Amount]=re.return_order_amount
	--	,[Refund_Payment_Amount]=re.return_payment
	--	,[Remarks]=re.return_order_msg
	--	,[Update_Time] = getdate()  
	--	,[Update_By] = @ProcName  
	--FROM ODS.ods.OMS_Order_return re
	--JOIN [dm].[Fct_Order] fo ON CAST(re.[relating_order_id] AS VARCHAR(200)) = fo.[Order_ID] --AND CASE WHEN oi.qd_id=1 THEN 18 ELSE 0 END = fo.[Channel_ID]
	--LEFT JOIN [dm].[Fct_Order_Refund] fre ON fre.Order_Key = fo.Order_Key AND re.return_order_sn = fre.[Refund_No]
	--;

	--UPDATE fo
	--	SET fo.[Refund_No] = fre.[Refund_No]
	--		,Is_Refund = 1
	--FROM [dm].[Fct_Order] fo
	--JOIN [dm].[Fct_Order_Refund] fre ON fo.Order_Key=fre.Order_Key 
	--;
	--UPDATE foi
	--	SET 
	--	foi.Return_Qty=rg.goods_number_return
	--	,foi.Refund_Amount_Split=rg.share_payment
	--	,foi.Refund_No=rg.return_order_sn
	--FROM dm.Fct_Order_Item foi
	--JOIN dm.Fct_Order fo ON foi.Order_Key=fo.Order_Key
	--JOIN ods.ods.OMS_Order_return_goods rg ON fo.Order_No=rg.order_sn AND foi.Transaction_No=rg.deal_code AND foi.SKU_ID=rg.goods_sn
	--;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
	

END
GO
