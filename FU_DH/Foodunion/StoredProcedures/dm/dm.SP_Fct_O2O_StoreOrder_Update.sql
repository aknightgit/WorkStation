USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dm].[SP_Fct_O2O_StoreOrder_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

/*
*/
	DROP TABLE IF EXISTS #Fans_Order_cnt
	SELECT outer_user_id
		  ,COUNT(DISTINCT order_no) AS Fans_Orders_Cnt
	INTO #Fans_Order_cnt
	FROM ODS.ods.SCRM_order_base_info
	WHERE ISNULL(outer_user_id,'') <> ''
	GROUP BY outer_user_id


	--new table [dm].[Fct_O2O_Order_Base_info];
	DELETE FROM  [dm].[Fct_O2O_Order_Base_info] WHERE [Datekey]>=20200801;
	INSERT INTO [dm].[Fct_O2O_Order_Base_info]
           ([Datekey]
           ,[Order_ID]
           ,[Order_No]
           ,[Order_Source]
           ,[Order_Type]
           ,[Fan_id]
           ,[KOL]
           ,[Fans_Nickname]
           ,[Open_id]
		   ,[Fans_Orders_Cnt]
		   ,[Fans_Order_Cnt_Grp]
           ,[Union_id]
           ,[is_cycle]
           ,[Order_Status]
           ,[Order_Status_Str]
           ,[Pay_Status]
           ,[Pay_Type_Str]
           ,[Pay_Type]
           ,[Order_Amount]
           ,[Shipping_Amount]
           ,[Pay_Amount]
           ,[Refund_Amount]
           ,[Order_Create_Time]
		   ,[Order_Close_Time]
           ,[Expired_Time]
           ,[Pay_Time]
           ,[Refund_Time]
           ,[Refund_State]
           ,[Close_Type]
           ,[Express_Type]
           ,[Consign_Time]
           ,[Offline_id]
           ,[Consign_Store]
           ,[Buyer_Mobile]
           ,[Receiver_Name]
           ,[Receiver_Mobile]
           ,[Delivery_Province]
           ,[Delivery_City]
           ,[Delivery_District]
           ,[Delivery_Address]
           ,[Fenxiao_Employee_id]
           ,[Fenxiao_Mobile]
           ,[Operator_Employee_id]
           ,[Remark]
           ,[is_deleted]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
    SELECT 
		CAST(CONVERT(VARCHAR(8),i.[Order_Creation_Time],112) AS INT) AS Datekey,
		i.[Order_Number] as Order_ID,
		i.[Order_Number] as Order_No,
		--CASE i.source WHEN 1 THEN '有赞商城' WHEN 2 THEN '微商城' WHEN 3 THEN '天猫' WHEN 4 THEN '京东' 
		--	WHEN 5 THEN '分销商城小程序' WHEN 6 THEN '有赞商城' WHEN 7 THEN '零售通' WHEN 8 THEN '拼多多' END as Order_Source,
		'有赞商城' as Order_Source,
		--CASE i.type 
		-- WHEN 0 THEN '普通订单' WHEN 1 THEN '送礼订单' WHEN 2 THEN '代付' WHEN 3 THEN '分销采购单' WHEN 4 THEN '赠品' WHEN 5 THEN '心愿单' 
		-- WHEN 6 THEN '二维码订单' WHEN 7 THEN '合并付货款' WHEN 8 THEN '1分钱实名认证' WHEN 9 THEN '品鉴' WHEN 10 THEN '拼团' WHEN 15 THEN '返利' 
		-- WHEN 35 THEN '酒店' WHEN 40 THEN '外卖' WHEN 41 THEN '堂食点餐' WHEN 46 THEN '外卖买单' WHEN 51 THEN '全员开店' WHEN 61 THEN '线下收银台订单' 
		-- WHEN 71 THEN '美业预约单' WHEN 72 THEN '美业服务单' WHEN 75 THEN '知识付费' WHEN 81 THEN '礼品卡' WHEN 100 THEN '批发' END as Order_Type,	
		Order_Type,
		NULL Fan_id,
		NULL KOL,
		i.[Buyer_Name] AS Fans_Nickname,
		null as Open_id,
		NULL Fans_Orders_Cnt,
		--CASE WHEN foc.Fans_Orders_Cnt < 3 THEN '0~2 Orders Totally' 
		--	WHEN foc.Fans_Orders_Cnt >= 3 THEN '>=3 Orders Totally' 
		--	ELSE 'Unidentified' END AS Fans_Order_Cnt_Grp,
		NULL AS Fans_Order_Cnt_Grp,
		NULL as Union_id,
		--CASE WHEN cy.order_id IS NULL AND i.cycle = 0 THEN 0 ELSE 1 END as is_cycle,
		CASE WHEN Order_Type = '周期购订单' THEN 1 ELSE 0 END as is_cycle,
		--i.order_status as Order_Status,
		CASE [Order_Status] WHEN '交易完成' THEN 'TRADE_SUCCESS'
		                    WHEN '交易关闭' THEN 'TRADE_CLOSED'
							WHEN '已发货' THEN 'WAIT_BUYER_CONFIRM_GOODS'
							WHEN '待发货' THEN 'WAIT_SELLER_SEND_GOODS'
							WHEN '待支付' THEN 'WAIT_BUYER_PAY'  END as Order_Status,
		i.[Order_Status] as Order_Status_Str,
		--CASE  i.pay_status WHEN 1 THEN '待付款' WHEN 2 THEN '已支付' END as Pay_Status,
		CASE WHEN ISNULL([Payment_Method],'')<>'' THEN '已支付' ELSE '待付款' END AS Pay_Status,
		NULL Pay_Type_Str,
		--CASE i.pay_type 
		-- WHEN 0 THEN '未支付' WHEN 1 THEN '微信自有支付' WHEN 2 THEN '支付宝wap' WHEN 3 THEN '支付宝wap' WHEN 5 THEN '财付通' 
		-- WHEN 7 THEN '代付' WHEN 8 THEN '联动优势' WHEN 9 THEN '货到付款' WHEN 10 THEN '大账号代销' WHEN 11 THEN '受理模式' 
		-- WHEN 12 THEN '百付宝' WHEN 13 THEN 'sdk支付' WHEN 14 THEN '合并付货款' WHEN 15 THEN '赠品' WHEN 16 THEN '优惠兑换' 
		-- WHEN 17 THEN '自动付货款' WHEN 18 THEN '爱学贷' WHEN 19 THEN '微信wap' WHEN 20 THEN '微信红包支付' WHEN 21 THEN '返利' 
		-- WHEN 22 THEN 'ump红包' WHEN 24 THEN '易宝支付' WHEN 25 THEN '储值卡' WHEN 27 THEN 'qq支付' WHEN 28 THEN '有赞E卡支付' 
		-- WHEN 29 THEN '微信条码' WHEN 30 THEN '支付宝条码' WHEN 33 THEN '礼品卡支付' WHEN 35 THEN '会员余额' WHEN 72 THEN '微信扫码二维码支付' 
		-- WHEN 100 THEN '代收账户' WHEN 300 THEN '储值账户' WHEN 400 THEN '保证金账户' WHEN 101 THEN '收款码' WHEN 102 THEN '微信' 
		-- WHEN 103 THEN '支付宝' WHEN 104 THEN '刷卡' WHEN 105 THEN '二维码台卡' WHEN 106 THEN '储值卡' WHEN 107 THEN '有赞E卡' WHEN 110 THEN '标记收款-自有微信支付' 
		-- WHEN 111 THEN '标记收款-自有支付宝' WHEN 112 THEN '标记收款-自有POS刷卡' WHEN 113 THEN '通联刷卡支付' WHEN 200 THEN '记账账户' WHEN 201 THEN '现金' 
		-- WHEN 202 THEN '组合支付' WHEN 203 THEN '外部支付' WHEN 40 THEN '分期支付' END as Pay_Type,
		ISNULL([Payment_Method],'未支付') as Pay_Type,
		i.[Total_Amount] as Order_Amount,
		i.[Freight] as Shipping_Amount,
		i.[Order_Amount_Receivable] as Pay_Amount,
		i.[Order_Refunded_Amount] as Refund_Amount,
		i.[Order_Creation_Time] as Order_Create_Time,
		i.[Transaction_Success_Time] as [Order_Close_Time],
		NULL as Expired_Time,
		i.[Buyer_Payment_Time] as Pay_Time,
		NULL as Refund_Time,
		--CASE i.refund_state WHEN 0 THEN '未退款' WHEN 1 THEN '部分退款中' WHEN 2 THEN '部分退款成功' WHEN 11 THEN '全额退款中' WHEN 12 THEN '全额退款成功' END as Refund_State,
		[Order_Refund_Status] as Refund_State,
		--CASE i.close_type WHEN 0 THEN '未关闭' WHEN 1 THEN '过期关闭' WHEN 2 THEN '标记退款' WHEN 3 THEN '订单取消' WHEN 4 THEN '买家取消' WHEN 5 THEN '卖家取消' 
		--	WHEN 6 THEN '部分退款' WHEN 10 THEN '无法联系上买家' WHEN 11 THEN '买家误拍或重拍了' WHEN 12 THEN '买家无诚意完成交易' WHEN 13 THEN '已通过银行线下汇款' 
		--	WHEN 14 THEN '已通过同城见面交易' WHEN 15 THEN '已通过货到付款交易' WHEN 16 THEN '已通过网上银行直接汇款' WHEN 17 THEN '已经缺货无法交易' END AS Close_Type,
		NULL AS Close_Type,
		[Order_Delivery_Method] AS Express_Type,
		NULL as Consign_Time,
		NULL Offline_id,
		[Single_Outlet] as Consign_Store,
		i.[Buyer_Mobile_Number] AS Buyer_Mobile,
		i.[Receiver_Name],
		i.[Receiver_Mobile_Number] AS Receiver_Mobile,
		i.[Consignee_Province],
		i.[Consignee_City],
		i.[Consignee_Region],
		i.[Receiving_Delivery_Address],
		--coalesce(i.Fenxiao_Employee_id,i.Fenxiao_Mobile,'00000000000'), --同KOL中逻辑，无fenxiao员EmployeeID就拿分销员手机号。
		NULL,
		NULL Fenxiao_Mobile,
		NULL Operator_Employee_id,
		NULL Remark,
		0 as is_deleted,
		getdate()
		,@ProcName AS [Create_By]
		,getdate()
		,@ProcName AS [Update_By]	
	FROM [ODS].[ods].[File_Youzan_StoreOrder] i  
	--LEFT JOIN (SELECT DISTINCT Order_id FROM ODS.ods.SCRM_order_detail_info WHERE (product_name LIKE '%计划%' OR product_name LIKE '%订阅%' OR  product_name LIKE '%订购%') AND 
	--	product_name NOT LIKE '%订购计划单品，隐藏%') cy ON i.id = cy.order_id
	--LEFT JOIN dm.Dim_O2O_KOL k  WITH(NOLOCK) ON CAST(i.offline_id AS VARCHAR(20))= k.offline_id
	--LEFT JOIN ods.ods.SCRM_youzan_store k WITH(NOLOCK) ON CAST(i.offline_id AS VARCHAR(20))= k.yz_id
	--LEFT JOIN dm.Dim_O2O_Fans fu WITH(NOLOCK) ON i.wx_union_id = fu.union_id
	--LEFT JOIN #Fans_Order_cnt foc ON isnull(i.outer_user_id,'') = foc.outer_user_id
	--where i.fans_nickname='特困??生'
	WHERE CONVERT(VARCHAR(8),i.[Order_Creation_Time],112)>='20200801' 

;

	UPDATE bi
	SET bi.Refund_Success_Time = r.Refund_Success_Time
		,bi.Update_Time = GETDATE()
	FROM [dm].[Fct_O2O_Order_Base_info] bi
	JOIN (SELECT tid AS Order_No, MAX(modified) AS Refund_Success_Time
		FROM ods.ods.OMS_Youzan_Refunds_Trade
		WHERE Status='SUCCESS'
		GROUP BY tid)r ON bi.Order_No=r.Order_No
	WHERE isnull(bi.Refund_Success_Time,'1900-01-01') <> r.Refund_Success_Time;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END

--select * from ODS.ods.SCRM_order_base_info i WITH(NOLOCK)
--where id=356916542119743488
--select * from dm.Dim_O2O_KOL  where offline_id=58815656
--select * from dm.Dim_O2O_KOL  where KolName='刘方'




GO
