USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [rpt].[SP_RPT_OnlineSales_Monthly_Report]
AS
	BEGIN
	--SELECT --DISTINCT 
	--	o.Order_Datekey,
	--	Cast(SUBSTRING(cast(o.Order_Datekey AS CHAR(8)),1,4)+'/'+SUBSTRING(cast(o.Order_Datekey AS CHAR(8)),5,2)+'/'+SUBSTRING(cast(o.Order_Datekey AS CHAR(8)),7,2) as Date)  AS OrderDate,
	--	o.Order_ID,
	--	dc.Channel_Name_CN,
	--	pf.Platform_Name_CN,
	--	oi.Sequence_ID,
	--	isnull(os.Buyer_Nick,o.Buyer_Nick) AS Buyer_Nick, --from shipment
	--	--OrderType
	--	o.Receiver_Province AS Province,
	--	o.Receiver_City AS City,
	--	CASE WHEN os.[Express_Code] IS NULL AND o.Order_Status NOT IN ('TRADE_FINISHED','WAIT_BUYER_CONFIRM_GOODS') THEN '未发货' 
	--		ELSE '已发货' END AS Shipment_Status,
	--	os.[Shipment_No]  AS [Shipment_No],
	--	os.[Warehouse],
	--	os.[Logistics_Code],
	--	os.[Logistics_Name],
	--	os.[Shipment_Type],
	--	os.[Express_Code],
	--	os.SourceDesc,
	--	--Payment_Status,
	--	--Shipment_status,
	--	CASE o.Order_Status WHEN 'PAID_FORBID_CONSIGN' THEN '已付款但禁止发货' 
	--		WHEN 'TRADE_ACTIVE' THEN '交易进行中'
	--		WHEN 'TRADE_CLOSED' THEN '退款成功，交易自动关闭'
	--		WHEN 'TRADE_CLOSED_BY_TAOBAO' THEN '卖家或买家主动关闭交易'
	--		WHEN 'TRADE_FINISHED' THEN '交易成功'
	--		WHEN 'TRADE_NO_CREATE_PAY' THEN '没有创建支付宝交易'
	--		WHEN 'WAIT_BUYER_CONFIRM_GOODS' THEN '等待买家确认收货'
	--		WHEN 'WAIT_BUYER_PAY' THEN '等待买家付款'
	--		WHEN 'WAIT_SELLER_SEND_GOODS' THEN '等待卖家发货' END AS Order_Status,
	--	--ShipmentID,
	--	o.Order_CreateTime,
	--	op.Payment_Time,
	--	oi.SKU_ID,
	--	ISNULL(p.SKU_Name_CN,'') AS SKU_Name_CN,
	--	oi.[SKU_RSP],
	--	oi.[Quantity],
	--	CASE WHEN oi.Is_Gift = 1 THEN 0 ELSE oi.[SKU_RSP]*oi.[Quantity] END AS OrderGS,
	--	op.payment_amount-op.Post_Fee AS Payment_Amount,
	--	CASE WHEN op.Received_Amount>0 THEN op.Received_Amount-op.Post_Fee ELSE op.Received_Amount END AS Received_Amount,
	--	isnull(f.Refund_Amount,0) AS Refund_Amount,
	--	oi.Payment_Amount AS Payment_Amount_Split,
	--	--oi.Received_Amount AS Received_Amount_Split,	
	--	oi.Payment_Amount-isnull(oi.Refund_Amount,0) AS Received_Amount_Split,
	--	isnull(oi.Refund_Amount*-1,0) AS Refund_Amount_Split,
	--	CAST(oi.Refund_Amount/oi.Payment_Amount * oi.[Quantity] AS INT)*-1 AS Return_Qty,
	--	CASE WHEN isnull(f.Refund_Amount,0)=0 THEN '' ELSE isnull(rf.Refund_Reason,'') END AS Refund_Reason,
	--	CASE WHEN oi.Payment_Amount - oi.[SKU_RSP]*oi.[Quantity] >0 THEN 0 ELSE oi.Payment_Amount - oi.[SKU_RSP]*oi.[Quantity] END AS 'Sale Cost',
	--	CAST(oi.Payment_Amount / oi.[Quantity] AS DECIMAL(10,2)) AS 'Unit Price',
	--	(CASE WHEN oi.Payment_Amount - oi.[SKU_RSP]*oi.[Quantity] >0 THEN 0 ELSE oi.Payment_Amount - oi.[SKU_RSP]*oi.[Quantity] END)* oi.Refund_Amount/oi.Payment_Amount *-1 AS '退货销售费用冲减',
	--	seq.Sequence_ID AS 'ItemCount',
	--	CASE WHEN oi.Is_Gift = 1 THEN '是' ELSE '否' END Is_Gift
	--	--into #orderdetail
	--FROM [dm].[Dim_Order] o with(nolock)
	--INNER JOIN [dm].[Fct_Order_Item] oi with(nolock) ON o.Order_ID = oi.Order_ID
	--INNER JOIN [dm].[Fct_Order_Payment] op with(nolock) ON o.Order_ID = op.Order_ID AND op.Payment_Time IS NOT NULL
	--LEFT JOIN (select Order_ID,MAX(Sequence_ID) Sequence_ID FROM [dm].[Fct_Order_Item] oi with(nolock) GROUP BY Order_ID) seq ON o.Order_ID = seq.Order_ID
	--LEFT JOIN [dm].[Fct_Order_Refund] rf with(nolock) ON oi.Refund_ID = rf.Refund_ID
	--LEFT JOIN (SELECT SUM(Refund_Amount) Refund_Amount,Order_ID FROM [dm].[Fct_Order_Refund] with(nolock) 
	--	WHERE Refund_Status = 'SUCCESS'		
	--	GROUP BY Order_ID) f ON o.Order_ID = f.Order_ID  --ONLY Success Refund
	--LEFT JOIN [dm].[Dim_Product] p with(nolock) on  oi.SKU_ID = p.SKU_ID
	--LEFT JOIN [dm].[Dim_Platform] pf with(nolock) ON o.Platform_ID = pf.Platform_ID
	--LEFT JOIN [dm].[Dim_Channel] dc with(nolock) ON o.Channel_ID = dc.Channel_ID
	--LEFT JOIN [dm].[Fct_Order_Shipment] os with(nolock) ON o.Order_ID = os.Order_ID 
	--	AND oi.SKU_ID = os.SKU_ID
	--	--AND os.[Express_Code] IS NOT NULL
	--	--AND os.Sequence_ID=1 
	--WHERE o.Order_Status in ('TRADE_FINISHED','WAIT_BUYER_CONFIRM_GOODS','WAIT_SELLER_SEND_GOODS')
	--AND (CASE WHEN isnull(f.Refund_Amount,0)=0 THEN '' ELSE isnull(rf.Refund_Reason,'') END 
	--		NOT IN ('多拍/拍错/不想要','不喜欢/不想要','缺货','未按约定时间发货'))
	--	--(NOT 
	--	--	(o.Order_Status IN ('TRADE_CLOSED_BY_TAOBAO') 
	--	--		OR (o.Order_Status IN ('TRADE_CLOSED') AND 
	--	--		(CASE WHEN isnull(f.Refund_Amount,0)=0 THEN '' 
	--	--			ELSE rf.Refund_Reason END IN ('多拍/拍错/不想要','不喜欢/不想要','缺货','未按约定时间发货')) --有退款
	--	--	)))

	----AND ISNULL(os.[Shipment_No],'') <> ''  --has delivery record
	----WHERE 
	----o.Order_Datekey >= 20190320
	----and
	----o.Order_ID='TB'+'375223489032111280'
	--ORDER BY o.Order_ID,oi.Transaction_ID,oi.Sequence_ID;

	SELECT 
		it.Buyer_Nick
	   ,od.Order_CloseTime
	   ,it.*
	FROM [dm].[Fct_Order_Item] it 
	LEFT JOIN dm.Dim_Order od ON it.Order_ID = od.Order_ID
	WHERE CAST(it.Order_DateKey AS VARCHAR) > DATEADD(MONTH,-3,GETDATE()) 


END

--select top 10 *from  [dm].[Fct_Order_Refund]
GO
