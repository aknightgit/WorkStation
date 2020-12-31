USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_OnlineSales_Tmall_Daily]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [rpt].[SP_RPT_OnlineSales_Tmall_Daily]
AS
BEGIN 
	
	--select * from ODS.[ods].[File_Tmall_DailyinAll]
	SELECT CAST([统计日期] AS date) Date,
		CONVERT(VARCHAR(8),cast([统计日期] as date),112) [统计日期],
		[旗舰店],
		[支付父订单数],
		CAST(REPLACE([下单金额],',','') AS decimal(18,9)) [下单金额],
		CAST(REPLACE([支付金额],',','') AS decimal(18,9)) [支付金额],
		CAST(REPLACE([成功退款金额],',','') AS decimal(18,9)) [成功退款金额],
		CAST(REPLACE([支付子订单数],',','') AS decimal(18,9)) [支付子订单数],
		CAST(REPLACE([下单件数],',','') AS decimal(18,9)) [下单件数],
		CAST(REPLACE([支付件数],',','') AS decimal(18,9)) [支付件数],
		CAST(REPLACE([客单价],',','') AS decimal(18,9)) [客单价],
		CAST(REPLACE([支付商品数],',','') AS decimal(18,9)) [支付商品数],
		[访客数]
		,[浏览量]
		,[商品浏览量]
		,[平均停留时长]
		,[商品收藏买家数]
		,[加购人数]
		,[支付买家数]
		,[下单转化率]
		,[支付转化率]
		,[老访客数]
		,[新访客数]
		,[支付老买家数]
		,[直通车消耗]
		,[钻石展位消耗]
		,[评价数]
		,[揽收包裹数]
		,[发货包裹数]
		,[派送包裹数]
		,[签收成功包裹数]
		,[平均支付_签收时长(秒)]
		,[下单-支付转化率]
		,[店铺收藏买家数]
	FROM ODS.[ods].[File_Tmall_DailyinAll]
	WHERE [统计日期]>='2019-05-25'

	UNION

	SELECT [Payment_Date]
	,CONVERT(VARCHAR(8),[Payment_Date],112) Datekey
      ,[Platform_Name]
      ,[Order_Count]
      ,CAST(REPLACE([Order_Amount],',','') AS decimal(18,9)) [Order_Amount]
      ,CAST(REPLACE([Payment_Amount],',','') AS decimal(18,9)) [Payment_Amount]
      ,CAST(REPLACE([Refund_Amount],',','') AS decimal(18,9)) [Refund_Amount]
      ,[SubOrder_Count]
      ,[Orderitem_Qty]
      ,[Payitem_Qty]
      ,CAST(REPLACE([PerOrderAmount],',','') AS decimal(18,9)) [PerOrderAmount]
      ,[SkuCount]
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	  ,null
	FROM ODS.[ods].[File_TmallFlag_DailyPayment]
	where [Payment_Date]<='2019-05-24'
	ORDER by 1;

END

GO
