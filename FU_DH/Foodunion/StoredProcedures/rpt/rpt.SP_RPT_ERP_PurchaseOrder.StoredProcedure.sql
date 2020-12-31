USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_ERP_PurchaseOrder]
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
	,dc.Date_NM AS Date
	,po.[Bill_Type]
	,po.Bill_No
	,po.[Puchase_Dept]
	,CASE po.[Purchase_Org] WHEN '��������ʳƷ���й������޹�˾' THEN 'Shanghai' WHEN '��������ʥ����Ʒ���޹�˾' THEN 'JV2' WHEN '�������ϰ�����ҵ���޹�˾' THEN 'JV1' END AS [Purchase_Org]
	--,po.[Purchase_Org]
	,CASE po.[Close_Status] WHEN 'δ�ر�' THEN 'Open' ELSE 'Closed' END AS [Close_Status]
	,po.[Cancel_Status]
	,po.[Confirm_Status]
	,po.[Close_Date]
	,po.[Remarks]
	,poe.Sequence_ID
	,poe.SKU_ID
	,rm.SKU_Name
	,rm.SKU_Name_EN
	,CASE rm.Group_Name WHEN '����' THEN 'PM ����' WHEN 'ԭ��' THEN 'RM ԭ��' WHEN '���Ʒ' THEN 'Semi ���Ʒ' END AS Group_Name
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
JOIN FU_EDW.Dim_Calendar dc ON po.Datekey=dc.Date_ID
WHERE po.Bill_Type='��׼�ɹ�����' 
AND po.close_status<>'�ѹر�' 
AND poe.remain_recqty>0
--and po.purchase_org='��������ʳƷ���й������޹�˾'
and poe.Rec_QTY=0
order by 1 desc

--select * from [dm].[Dim_ERP_RawMaterial] 
--select top 100 * from dm.Fct_ERP_Stock_InStockentry where sourcebillno='12PO000616'
--select top 10 * from [dm].[Fct_ERP_Stock_PurchaseOrderEntry] 
GO
