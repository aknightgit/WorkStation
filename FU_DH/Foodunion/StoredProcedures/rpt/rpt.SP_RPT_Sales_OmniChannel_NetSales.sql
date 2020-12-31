USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [rpt].[SP_RPT_Sales_OmniChannel_NetSales]
AS BEGIN 

	--Online,  POS wo Tax
	 
	SELECT CONVERT(char(8),fo.Order_PayTime,112) AS DateKey  --使用付款成功时间
			,fo.Channel_ID
			,foi.SKU_ID
			,SUM(--拼多多 多多牧场零元购订单折算
				CASE WHEN fo.Channel_ID IN (71) AND foi.Payment_Amount_Split=0 AND foi.SKU_ID IN ('1181001') THEN 11.95 * foi.Quantity
				WHEN fo.Channel_ID IN (71) AND foi.Payment_Amount_Split=0 AND foi.SKU_ID IN ('1120003') THEN 14.95 * foi.Quantity
				ELSE foi.Payment_Amount_Split END) / (1 + isnull(p.Tax_Rate,0)) AS Net_Sales
			,SUM(--拼多多 多多牧场零元购订单折算
				CASE WHEN fo.Channel_ID IN (71) AND foi.Payment_Amount_Split=0 AND foi.SKU_ID IN ('1181001') THEN 11.95 * foi.Quantity
				WHEN fo.Channel_ID IN (71) AND foi.Payment_Amount_Split=0 AND foi.SKU_ID IN ('1120003') THEN 14.95 * foi.Quantity
				ELSE foi.Payment_Amount_Split END) AS Net_Sales_wTax 
			,SUM(foi.Quantity * p.Sale_Unit_Weight_KG)/1000 AS Sales_Vol_MT
		FROM dm.Fct_Order fo WITH(NOLOCK) 
		JOIN dm.Fct_Order_Item foi WITH(NOLOCK) ON fo.Order_Key=foi.Order_Key
		JOIN dm.Dim_Product p ON foi.SKU_ID=p.SKU_ID
		WHERE (
			fo.Is_Cancelled=0			--无效单  
			--1=1  --之前增加这个条件原因不明，现取消   Justin 20200902
			OR fo.Order_Key IN (SELECT Order_Key FROM  dm.Fct_Order_Refund WHERE Refund_Status='WAIT_SELLER_AGREE'))  --退款中，待确认
		AND fo.Is_Split=0		--去掉被拆分单
		AND fo.Copy_From=0		--复制单	，只看原生单
		GROUP BY fo.Channel_ID
			,CONVERT(char(8),fo.Order_PayTime,112)
			,foi.SKU_ID,p.Tax_Rate

	UNION ALL
	--Offline, OUTStock wo Tax

	SELECT sos.[Datekey],
		sos.Channel_ID,
		ose.SKU_ID,
		SUM(ose.Amount) AS Net_Sales,	
		SUM(ose.Full_Amount) AS Net_Sales_wTax,
		SUM(ose.Net_Weight/1000) AS Sales_Vol_MT
    FROM [dm].[Fct_ERP_Stock_OutStock] sos WITH(NOLOCK)
	LEFT JOIN [dm].[Fct_ERP_Stock_OutStockEntry] ose WITH(NOLOCK) ON sos.[OutStock_ID] = ose.[OutStock_ID]
	JOIN [dm].[Dim_Channel] cl ON sos.[Customer_ID] = cl.ERP_Customer_ID  	 
	WHERE sos.Sale_Org='富友联合食品（中国）有限公司'	
		AND cl.Team='Offline'
	GROUP BY 	sos.[Datekey],
		sos.Channel_ID,ose.SKU_ID		;

end



--SELECT distinct Channel_FIN FROM [dm].[Dim_Channel] where Channel_FIN

--SELECT* FROM [dm].[Dim_Channel] where SubChannel_FIN='online-other'
--SELECT* FROM [dm].[Dim_Channel] where team not in ('ONLINE','Offline')

--update [dm].[Dim_Channel] set Team='',Team_Handler='' where team not in ('ONLINE','Offline')
--select * from dm.Fct_Qulouxia_Sales 
--where DATEKEY>=20201106
--order by DATEKEY desc


--UPDATE  [dm].[Dim_Channel]  SET Team='Offline' WHERE Channel_FIN IN ('AFH','NKA','Indirect','RETAIL')
--UPDATE  [dm].[Dim_Channel]  SET Team='Online' WHERE Channel_FIN IN ('ONLINE')

--select *from dm.Dim_Employee
--select top 100 *from dm.Dim_Product
GO
