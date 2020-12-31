USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [rpt].[SP_RPT_O2O_OrderIncomeRecon_20191012]
AS
BEGIN


	SELECT 
		--LEFT(ob.[Datekey],6) AS [Month]
		CONVERT(VARCHAR(8),CAST(dbo.split(yr.Period,'-',1) AS DATE),112)+'-'+CONVERT(VARCHAR(8),CAST(dbo.split(yr.Period,'-',2) AS DATE),112) AS Period
		,C.Month_EN_NM
		,ob.[Datekey] AS Order_Datekey
		,ob.[Order_No]
		,ob.[Order_Source]
		--,ob.[is_cycle]
		,CASE WHEN ob.[is_cycle]+od.[delivery_cnt] > 1 AND ISNULL(od.[SKU_ID],'') in ('1180004','1180003') THEN 'Subscription-Fresh Milk' 
			WHEN ob.[is_cycle]+od.[delivery_cnt] > 1 AND ISNULL(od.[SKU_ID],'') NOT in ('1180004','1180003') THEN 'Subscription-Non-Fresh Milk' ELSE 'Normal' END AS [Order_Type]
		,k.[KOLName] AS Fenxiao_KOLName
		,ob.[Order_Status]
		,ob.[Order_Create_Time]
		,ob.[Order_Close_Time]
		,ob.[Express_Type]
		,ob.[Fans_Nickname] AS 'Buyer_Nick'
		,ob.[Buyer_Mobile]
		,CASE WHEN ISNULL(ob.[Open_id],'') = '' THEN 'UNKNOWN' ELSE ob.[Open_id] END AS Open_id
		,ob.[Union_id]
		,ob.[Receiver_Name]
		,ob.[Receiver_Mobile]
		,ob.[Delivery_Province]
		,ob.[Delivery_City]
		,od.[Sub_Order] AS [Sub_Order_No]
		,od.[SeqID]
		,od.[Product_Name]
		,od.[SKU_ID]
		,od.[SKU_Name_CN]
		,p.[SKU_Name]
		,od.[QTY]
		,od.[Unit_Price]
		,od.[Total_Price] AS 'Total_Amount'
		,od.[payment]  AS 'Payment_Amount'
		,CAST(od.[Total_Price]-od.[payment] AS DECIMAL(9,2)) AS 'Discount_Amount'
		,od.[Unit_Weight_g]	
		,p.[Sale_Unit]
		,od.[SubscriptionType]  AS 'Subscription_Type'  
		,od.[Scale]
		,od.[delivery_cnt] AS 'Cycle_Count'
		--,od.[pcs_cnt]*od.qty AS 'Pcs_Count'
		,yr.Delivery_Cnt AS 'Delivery_Count'
		,yr.Delivery_Cnt*od.[pcs_cnt]*od.qty AS 'Pcs_Count'
		,CASE WHEN ob.[is_cycle]+od.[delivery_cnt] > 1 THEN yr.Income_Amount ELSE od.[payment]  END AS Income_Amount
	FROM (SELECT Order_No,Period,COUNT(1) Delivery_Cnt ,SUM(Income_Amount) AS Income_Amount
		FROM [dm].[Fct_Youzan_Recon] yr
		WHERE Recon_Date>='2019-06-01'
		AND CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',2) AS DATE),112)<=CONVERT(VARCHAR(8),GETDATE(),112)
		GROUP BY Order_No,Period) yr
	JOIN [dm].[Fct_O2O_Order_Base_info] ob ON ob.Order_No = yr.Order_No
	JOIN [dm].[Fct_O2O_Order_Detail_info] od ON od.order_id = ob.order_id
	LEFT JOIN [dm].[Dim_Product] p ON od.SKU_ID = p.SKU_ID
	LEFT JOIN [dm].[Dim_O2O_KOL] k ON ob.Fenxiao_Employee_id=k.KOL_Employee_ID
	LEFT JOIN (
		select distinct Year_Month,Month_EN_NM
		from FU_EDW.Dim_Calendar)c ON CONVERT(VARCHAR(6),CAST(dbo.split(yr.Period,'-',1) AS DATE),112)=C.Year_Month
	WHERE od.Product_Name NOT LIKE '%寄生%'
		AND od.Product_Name NOT LIKE '%周边%'
		AND od.Product_Name NOT LIKE '%会员专享%'
		AND od.Product_Name NOT LIKE '%福袋%'
		AND od.Product_Name NOT LIKE '%赠品%'
		AND ob.Order_Status <> 'TRADE_CLOSED'
		AND ob.Order_Type ='普通订单'
	--AND yr.Order_No='E20190727171651010900015'
	ORDER BY 1 ,4


   END


GO
