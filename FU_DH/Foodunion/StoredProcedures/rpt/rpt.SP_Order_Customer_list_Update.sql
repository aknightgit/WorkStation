USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROC [rpt].[SP_Order_Customer_list_Update]
AS
BEGIN

	

	DROP TABLE IF EXISTS #tmpS;
	SELECT * INTO #tmp
	FROM(
		SELECT 
		--top 100 
		fo.Order_MonthKey AS '订单月份',
		dc.Date AS '订单日期',
		dc.Week_of_Year '周',
		CAST(fo.Order_No AS VARCHAR(200)) AS '订单号',	
		c.ERP_Customer_Name AS '订单渠道',
		c.Channel_ID AS '渠道ID',
		c.Channel_Name_Short AS '渠道简称',
		fo.Order_CreateTime AS '订单创建时间',
		fo.Order_PayTime AS '订单付款时间',
		fo.Order_CloseTime AS '订单关闭时间',
		op.Payment_Type AS '付款方式',
		fo.Order_Status AS '订单状态',
		fo.Total_Amount AS '订单金额',
		fo.Discount_Amount AS '折扣金额',
		fo.Payment_Amount AS '付款金额',
		null as '退款金额',
		fo.Buyer_Nick AS '买家昵称',
		NULL AS '买家手机号',
		NULL AS 'wx_openid',
		fo.Receiver_Name AS '收货人姓名',
		cast(fo.Receiver_Mobile AS VARCHAR(50)) AS '收货人手机号',
		fo.Receiver_Province AS '省份',
		fo.Receiver_City AS '城市',
		fo.Receiver_Area AS '区域',
		fo.Receiver_Address AS '收货地址',
		CAST(isnull(fo.Buyer_Mobile,fo.Receiver_Mobile) AS VARCHAR(50)) as '客户ID',
		0 as '新客户'
		--fo.Receiver_Postcode AS '邮编'
	FROM [dm].[Fct_Order] fo
	LEFT JOIN dm.Fct_Order_Payment op ON fo.Order_Key=op.Order_Key 
	JOIN dm.Dim_Calendar dc ON fo.Order_DateKey=dc.DateKey
	JOIN dm.Dim_Channel c ON fo.Channel_ID=c.Channel_ID
	--LEFT JOIN dm.Dim_Customer cs ON fo.Super_ID=cs.Super_ID
	WHERE Order_MonthKey>=201909
	AND Is_Cancelled=0
	AND Copy_From = 0
	AND fo.Channel_ID<>45

	UNION 

	--有赞
	SELECT 
		dc.Monthkey AS '订单月份',
		dc.Date AS '订单日期',
		dc.Week_of_Year '周',
		bi.Order_No AS '订单号',	
		bi.Order_Source AS '订单渠道',
		45 AS '渠道ID',
		'Youzan' AS '渠道简称',
		bi.Order_Create_Time,
		bi.Pay_Time,
		bi.Order_Close_Time,
		bi.Pay_Type_Str  AS '付款方式',
		bi.Order_Status_Str,
		bi.Order_Amount,
		bi.Order_Amount-bi.Pay_Amount,
		bi.Pay_Amount,
		bi.Refund_Amount,
		bi.Fans_Nickname AS Buyer_Nick,
		bi.Buyer_Mobile AS Buyer_Mobile,
		bi.Open_ID AS wx_openid,
		bi.Receiver_Name,
		bi.Receiver_Mobile,
		bi.Delivery_Province,
		bi.Delivery_City,
		bi.Delivery_District,
		bi.Delivery_Address,
		--NULL AS Postcode
		isnull(bi.Buyer_Mobile,bi.Receiver_Mobile) as '客户ID',
		0 as '新客户'
	FROM dm.Fct_O2O_Order_Base_info bi
	JOIN dm.Dim_Calendar dc ON bi.DateKey=dc.Datekey
	WHERE bi.Order_Status_Str<>'已关闭'

	UNION 
	SELECT
		--top 100 
		CONVERT(char(6),CAST(Creation_time AS DATETIME),112) AS '订单月份',
		cast(Creation_time as date) AS '订单日期',
		dc.Week_of_Year '周',
		Buyer_Order_ID AS '订单号',	
		'甩宝宝Shuaibaobao' AS '订单渠道',
		70 AS '渠道ID',
		'甩宝宝Shuaibaobao' AS '渠道简称',
		CAST(Creation_time AS DATETIME) AS '订单创建时间',
		null AS '订单付款时间',
		null AS '订单关闭时间',
		null AS '付款方式',
		null AS '订单状态',
		Terminal_Price AS '订单金额',
		null AS '折扣金额',
		Terminal_Price AS '付款金额',
		null as '退款金额',
		Full_Name AS '买家昵称',
		Telephone AS '买家手机号',
		NULL AS 'wx_openid',
		Full_Name AS '收货人姓名',
		Telephone AS '收货人手机号',
		Province AS '省份',
		City AS '城市',
		Area AS '区域',
		Detailed_Address AS '收货地址',
		Telephone as '客户ID',
		0 as '新客户'
		--fo.Receiver_Postcode AS '邮编'
	FROM ods.ods.File_Shuaibao_DailySales ods
	JOIN dm.Dim_Calendar dc on CONVERT(char(8),CAST(Creation_time AS DATETIME),112) =dc.Datekey

	UNION select 
	--top 100 
		CONVERT(char(6),CAST(Push_Time AS DATETIME),112) AS '订单月份',
		cast(Push_Time as date) AS '订单日期',
		dc.Week_of_Year '周',
		Main_Order_NO AS '订单号',	
		'有好东西' AS '订单渠道',
		120 AS '渠道ID',
		'有好东西' AS '渠道简称',
		Push_Time AS '订单创建时间',
		null AS '订单付款时间',
		null AS '订单关闭时间',
		Payment_Type AS '付款方式',
		null AS '订单状态',
		sum(cast(Original_Price as decimal(18,5))) AS '订单金额',
		sum(cast(Promotional_Price as decimal(18,5))) AS '折扣金额',
		sum(cast(Actual_Payment_Price as decimal(18,5))) AS '付款金额',
		null as '退款金额',
		Full_Name AS '买家昵称',
		Contact_Number AS '买家手机号',
		NULL AS 'wx_openid',
		Full_Name AS '收货人姓名',
		Contact_Number AS '收货人手机号',
		Province AS '省份',
		City AS '城市',
		Area AS '区域',
		Address AS '收货地址',
		Contact_Number as '客户ID',
		0 as '新客户'
		--fo.Receiver_Postcode AS '邮编'
	FROM ods.ods.File_hdx_DailySales ods
	JOIN dm.Dim_Calendar dc on CONVERT(char(8),CAST(Push_Time AS DATETIME),112) =dc.Datekey
	GROUP BY CONVERT(char(6),Push_Time,112),
		cast(Push_Time as date),
		dc.Week_of_Year,
		Main_Order_NO,
		Push_Time,
		Payment_Type,
		Full_Name,
		Contact_Number,
		Province,
		City,
		Area,
		Address
	
	)A

	UPDATE a
	SET a.[新客户]=1
	FROM #tmp a
	JOIN (
	SELECT [客户ID],[订单号],ROW_NUMBER() OVER(PARTITION BY [客户ID] ORDER BY [订单创建时间]) rid
	FROM #tmp)b ON a.[客户ID]=b.[客户ID] AND a.[订单号]=b.[订单号]
	AND b.rid=1

	--select distinct [客户ID]
	--from #tmp
	TRUNCATE TABLE [rpt].[Order_Customer_list];
	INSERT INTO  [rpt].[Order_Customer_list]
	SELECT *,GETDATE(),'[rpt].[Order_Customer_list_Update]'
	FROM #tmp order by 2;

   END
GO
