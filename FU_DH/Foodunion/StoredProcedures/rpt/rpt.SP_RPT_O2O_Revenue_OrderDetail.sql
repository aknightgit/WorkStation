USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [rpt].[SP_RPT_O2O_Revenue_OrderDetail]
AS
BEGIN

	DROP TABLE IF EXISTS #SKUM;
	SELECT P.*,ISNULL(PP.Sale_Unit_RSP,0) AS RSP,
        CASE WHEN SUM(ISNULL(PP.Sale_Unit_RSP,0)*QTY)OVER(PARTITION BY P.PRODUCT_ID)=0 THEN 0 
		ELSE ISNULL(PP.Sale_Unit_RSP,0)*QTY/SUM(ISNULL(PP.Sale_Unit_RSP,0)*QTY)OVER(PARTITION BY P.PRODUCT_ID) END AS RATIO 
		INTO #SKUM
	FROM (
		SELECT REPLACE(PRODUCT_ID,'B#T','BXT') AS PRODUCT_ID
			,REPLACE(SKU_ID,'B#T','BXT') AS SKU_ID
			,QTY
		FROM (SELECT DISTINCT REPLACE(PRODUCT_ID,'BXT','B#T') AS PRODUCT_ID FROM [dm].[Fct_O2O_Order_Detail_info] OD
		LEFT JOIN (SELECT DISTINCT [OutSKUID] FROM [Foodunion].[dm].[Dim_Product_OutSKUMapping]) om
		ON ISNULL(od.Product_ID,'')=om.[OutSKUID]
		WHERE om.[OutSKUID] IS NULL) A
			CROSS APPLY [dbo].[Split_Product](a.product_id)
			WHERE (LEN(product_id) - LEN(REPLACE(product_id, 'X', '')))>1) P
 LEFT JOIN [dm].[Dim_Product] PP
 ON P.SKU_ID=PP.SKU_ID;
	
	
	SELECT
	bi.Order_Create_Time AS 'Create Date'
	,D.Month_Name_Short AS [Month]
	,D.Week_of_Year AS [Week]
	--,BI.Order_Status AS [订单状态]
	,bi.Order_No AS 'Order Number'
	,CASE WHEN bi.is_cycle = 1 THEN 'Subscription' ELSE 'Normal' END AS 'Order Type'
	,bi.Open_id AS 'Buyer Open ID'
	--,CASE WHEN om.[OutSKUID] IS NOT NULL THEN CAST(di.payment *ISNULL(om.[PriceRatio],1) AS decimal(16,4)) else CAST(di.payment  AS decimal(9,2))end  AS 'Actual Payment'   --增加福袋拆分 --Justin 2020-02-24
	,CASE WHEN om.[OutSKUID] IS NOT NULL THEN CAST((CASE WHEN bi.Pay_Amount<di.payment THEN bi.Pay_Amount ELSE di.payment END) *ISNULL(om.[PriceRatio],1) AS decimal(16,4)) else CAST((CASE WHEN bi.Pay_Amount<di.payment THEN bi.Pay_Amount ELSE di.payment END) AS decimal(9,2))end  AS 'Actual Payment'   --增加福袋拆分 --Justin 2020-02-24
	,CAST(PM.Retail_price_group AS decimal(9,2))  AS [商城单价]
	,CAST(P.[Net_Weight_KG]*1000 AS decimal(9,1)) AS VOLLUMN
	,DI.Product_ID,DI.Product_SKU_ID
	,CASE WHEN om.SKU_ID IS NOT NULL THEN om.SKU_ID ELSE di.SKU_ID END AS 'SKU ID'   --增加福袋拆分 --Justin 2020-02-24
	,di.Product_Name AS 'Product Name'
	--,( CASE WHEN om.SKU_ID IS NOT NULL THEN om.QTY*di.QTY ELSE di.QTY END)*di.pcs_cnt AS 'QTY'   --增加福袋拆分 --Justin 2020-02-24
	,(CASE WHEN om.SKU_ID IS NOT NULL THEN om.QTY*di.QTY ELSE di.QTY*di.pcs_cnt END)*di.delivery_cnt AS 'QTY'

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

LEFT JOIN (SELECT DISTINCT [OutSKUID],[SKU_ID],[PriceRatio],[QTY] FROM [Foodunion].[dm].[Dim_Product_OutSKUMapping]
           UNION
	       SELECT DISTINCT PRODUCT_ID,SKU_ID,RATIO,QTY FROM #SKUM
		   ) om ON (CASE WHEN ISNULL(di.Product_SKU_ID,'')=''THEN di.Product_ID ELSE di.Product_SKU_ID END)=om.[OutSKUID]
LEFT JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON (CASE WHEN om.SKU_ID IS NOT NULL THEN om.SKU_ID ELSE di.SKU_ID END)=p.SKU_ID
LEFT JOIN [dm].[Dim_Calendar] D ON CONVERT(VARCHAR(10),bi.Order_Create_Time,112)=D.Datekey
LEFT JOIN (SELECT * FROM [dm].[Dim_Product_AccountCodeMapping] WHERE Account='Youzan') PM ON (CASE WHEN om.SKU_ID IS NOT NULL THEN om.SKU_ID ELSE di.SKU_ID END)=PM.SKU_ID
WHERE 
bi.Order_Status<>'TRADE_CLOSED'
--AND bi.Order_No='E20200813012411004004125'
--AND di.Product_Name LIKE '%强身%'
ORDER BY bi.Order_Create_Time DESC

END



GO
