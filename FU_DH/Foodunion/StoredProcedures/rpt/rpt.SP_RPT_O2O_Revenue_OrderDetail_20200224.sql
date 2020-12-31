USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [rpt].[SP_RPT_O2O_Revenue_OrderDetail_20200224]
AS
BEGIN

	SELECT
	bi.Order_Create_Time AS 'Create Date'
	,bi.Order_No AS 'Order Number'
	,CASE WHEN bi.is_cycle = 1 THEN 'Subscription' ELSE 'Normal' END AS 'Order Type'
	,bi.Open_id AS 'Buyer Open ID'
	,CAST(di.payment AS decimal(9,2)) AS 'Actual Payment'
	,di.SKU_ID AS 'SKU ID'
	,di.Product_Name AS 'Product Name'
	,di.QTY*di.pcs_cnt AS 'QTY'
	,p.Sale_Unit AS 'Unit'
	,di.delivery_cnt AS 'Length of Subscription, Week'
	,bi.Consign_Store AS 'Consign Store'
	,emp.Employee_name AS 'Consignee'
	,emp.mobile AS 'Consignee Mobile'
	,bi.Buyer_Mobile AS 'Buyer Mobile'
	,bi.Receiver_Name AS 'Receiver Name'
	,bi.Receiver_Mobile AS 'Receiver Mobile'
	,bi.Order_Status AS 'Order Status'
	,bi.Express_Type AS 'Express Type'
FROM [dm].[Fct_O2O_Order_Detail_info] di WITH(NOLOCK)
JOIN [dm].[Fct_O2O_Order_Base_info] bi WITH(NOLOCK) ON di.Order_ID=bi.Order_ID
LEFT JOIN [dm].[Dim_O2O_Employee] emp WITH(NOLOCK) ON bi.Operator_Employee_id=emp.Employee_id
LEFT JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON di.SKU_ID=p.SKU_ID
WHERE 
bi.Order_Status<>'TRADE_CLOSED'
--AND bi.Order_No='E20190923114748098700017'
ORDER BY bi.Order_Create_Time DESC

END


GO
