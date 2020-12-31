USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [rpt].[SP_RPT_ERP_PurchaseOrder]
as

SELECT 
	--TOP 100 
	po.[POOrder_ID]
	,po.[Datekey]
	,dc.Date_Str AS Date
	,po.[Bill_Type]
	,po.Bill_No
	,po.[Puchase_Dept]
	,CASE po.[Purchase_Org] WHEN '富友联合食品（中国）有限公司' THEN 'Shanghai' WHEN '富友联合圣牧乳品有限公司' THEN 'JV2' WHEN '富友联合澳亚乳业有限公司' THEN 'JV1' END AS [Purchase_Org]
	--,po.[Purchase_Org]
	,CASE po.[Close_Status] WHEN '未关闭' THEN 'Open' ELSE 'Closed' END AS [Close_Status]
	,po.[Cancel_Status]
	,po.[Confirm_Status]
	,po.[Close_Date]
	,po.[Remarks]
	,poe.Sequence_ID
	,poe.SKU_ID
	,rm.SKU_Name
	,rm.SKU_Name_EN
	,CASE rm.Group_Name WHEN '包材' THEN 'PM 包材' WHEN '原料' THEN 'RM 原料' WHEN '半成品' THEN 'Semi 半成品' END AS Group_Name
	,rm.Category
	,poe.Unit
	,poe.QTY
	,poe.Rec_QTY
	,poe.Stock_Unit
	,poe.Stock_QTY
	,poe.Note
	,poe.Amount
	,poe.Tax_Amount
	,poe.All_Amount
	,poe.[Remain_RecQTY]
	,poe.[Remain_StkQTY]
FROM dm.Fct_ERP_STOCK_PurchaseOrder po
JOIN [dm].[Fct_ERP_Stock_PurchaseOrderEntry] poe ON po.[POOrder_ID]=poe.[POOrder_ID]  
JOIN [dm].[Dim_ERP_RawMaterial] rm ON poe.SKU_ID=rm.SKU_ID
JOIN dm.Dim_Calendar dc ON po.Datekey=dc.Datekey
WHERE po.Bill_Type='标准采购订单' 
AND po.close_status<>'已关闭' 
AND poe.remain_recqty>0
--and po.purchase_org='富友联合食品（中国）有限公司'
and poe.Rec_QTY=0
order by 1 desc

--select * from [dm].[Dim_ERP_RawMaterial] 
--select top 100 * from dm.Fct_ERP_Stock_InStockentry where sourcebillno='12PO000616'
--select top 10 * from [dm].[Fct_ERP_Stock_PurchaseOrderEntry] 
GO
