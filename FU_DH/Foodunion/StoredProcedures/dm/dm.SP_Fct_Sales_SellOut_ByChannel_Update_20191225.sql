USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE  [dm].[SP_Fct_Sales_SellOut_ByChannel_Update_20191225] 
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--增量抽取天数
	DECLARE @Ret_Days INT = 90;

	--Reload latest 7 days
	DELETE FROM [dm].[Fct_Sales_SellOut_ByChannel]
	WHERE Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112);

	--获取O2O每个order_no的payment
	DROP TABLE IF EXISTS #payment
	SELECT bi.Order_No,SUM(di.payment) AS payment
	INTO #payment
 	FROM  [dm].[Fct_O2O_Order_Base_info] bi WITH(NOLOCK) 
	LEFT JOIN [dm].[Fct_O2O_Order_Detail_info] di WITH(NOLOCK) ON bi.Order_ID=di.Order_ID
	GROUP BY bi.Order_No

	INSERT INTO [dm].[Fct_Sales_SellOut_ByChannel]
           ([DateKey]
           ,[Channel_ID]
           ,[SKU_ID]
           ,[QTY]
           ,[Amount]
           ,[Discount_Amount]
           ,[Unit_Price]
           ,[Weight_KG]
           ,[Volume_L]
           ,[Create_time]
           ,[Create_By]
           ,[Update_time]
           ,[Update_By])
	------------YH:5  YH sellout
	SELECT 
		k.Calendar_DT  
		,dc.Channel_ID
		,k.SKU_ID 
		,SUM(k.Sales_Qty)
		,SUM(k.Sales_AMT)
		,null
		,null
		,SUM(k.Sales_Qty * p.Sale_Unit_Weight_KG) as  [Weight_KG]
		,SUM(k.Sales_Qty * p.Sale_Unit_Volumn_L) as  [Volume_L]
		,getdate(),'[dm].[Fct_YH_Sales_Inventory]'
		,getdate(),'[dm].[Fct_YH_Sales_Inventory]'
	FROM [dm].[Fct_YH_Sales_Inventory] k WITH(NOLOCK) 
	LEFT JOIN [dm].[Dim_Product] p WITH(NOLOCK)  on k.SKU_ID=p.SKU_ID
	LEFT JOIN [FU_EDW].[Dim_Calendar] C on k.Calendar_DT = C.Date_ID
	JOIN [dm].[Dim_Channel] dc WITH(NOLOCK) ON dc.Channel_Name='YH'
	WHERE k.Calendar_DT >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
	--WHERE k.Calendar_DT >= CONVERT(VARCHAR(8),GETDATE()-7,112)
	GROUP BY k.Calendar_DT  
			,dc.Channel_ID
			,k.SKU_ID 
	-------------Kidswant:16
	UNION ALL
	SELECT 
		k.Datekey  
		,dc.Channel_ID
		,k.SKU_ID
		,SUM(k.Sales_Qty)
		,SUM(k.Sales_AMT)
		,null
		,null
		,SUM(k.Sales_Qty * p.Sale_Unit_Weight_KG) as  [Weight_KG]
		,SUM(k.Sales_Qty * p.Sale_Unit_Volumn_L) as  [Volume_L]
		,getdate(),'[dm].[Fct_Kidswant_DailySales]'
		,getdate(),'[dm].[Fct_Kidswant_DailySales]'
	FROM [dm].[Fct_Kidswant_DailySales] k  WITH(NOLOCK) 
	LEFT JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON k.SKU_ID=p.SKU_ID
	JOIN [dm].[Dim_Channel] dc WITH(NOLOCK) ON dc.Channel_Name='KidsWant'
	WHERE k.Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
	--WHERE k.Datekey >= CONVERT(VARCHAR(8),GETDATE()-7,112)
	GROUP BY k.Datekey  
		,dc.Channel_ID
		,k.SKU_ID 	
	-------------Vanguard:15
	UNION ALL
	SELECT 
		k.Datekey  
		,dc.Channel_ID
		,k.SKU_ID 
		,SUM(k.Sale_Qty)
		,SUM(k.Gross_Sale_Value)
		,null
		,null
		,SUM(k.Sale_Qty * p.Sale_Unit_Weight_KG) as  [Weight_KG]
		,SUM(k.Sale_Qty * p.Sale_Unit_Volumn_L) as  [Volume_L]
		,getdate(),'[dm].[Fct_CRV_DailySales]'
		,getdate(),'[dm].[Fct_CRV_DailySales]'
	FROM [dm].[Fct_CRV_DailySales] k  WITH(NOLOCK) 
	LEFT JOIN dm.Dim_Product p WITH(NOLOCK) ON k.SKU_ID=p.SKU_ID
	JOIN [dm].[Dim_Channel] dc WITH(NOLOCK) ON dc.Channel_Name='Vanguard'
	WHERE k.Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
	--WHERE k.Datekey >= CONVERT(VARCHAR(8),GETDATE()-7,112)
	GROUP BY k.Datekey  
		,dc.Channel_ID
		,k.SKU_ID 
	------------------(⊙o⊙)？O2O： Youzan
	UNION ALL
	SELECT 
		   bi.Datekey AS Datekey 
		  ,dc.Channel_ID
		  ,isnull(REPLACE(di.sku_id,'Y',''),'00000000') AS SKU_ID
		  ,SUM(di.QTY*di.pcs_cnt) AS qty
		  ,SUM(CASE WHEN pm.payment is null THEN bi.Pay_Amount ELSE di.payment END +CASE WHEN pm.payment = 0 THEN bi.Shipping_Amount ELSE bi.Shipping_Amount*di.payment/pm.payment END/* -ISNULL(CASE WHEN ISNULL(bi.Order_Amount,0) = 0 THEN bi.Refund_Amount ELSE bi.Refund_Amount*di.payment/bi.Order_Amount END,0)*/) AS [Amount]
		  ,null
		  ,null
		  ,SUM(di.QTY*di.pcs_cnt*delivery_cnt*p.Sale_Unit_Weight_KG) AS [Weight_KG]
		  ,SUM(di.QTY*di.pcs_cnt*delivery_cnt*p.Sale_Unit_Volumn_L) AS [Volume_L]
		  ,getdate(),'[dm].[Fct_O2O_Order_Detail_info]'
		  ,getdate(),'[dm].[Fct_O2O_Order_Detail_info]'
 	FROM  [dm].[Fct_O2O_Order_Base_info] bi WITH(NOLOCK) 
	LEFT JOIN [dm].[Fct_O2O_Order_Detail_info] di WITH(NOLOCK) ON bi.Order_ID=di.Order_ID
	LEFT JOIN #payment pm ON bi.Order_No = pm.Order_No
	LEFT JOIN [dm].[Dim_Channel] dc WITH(NOLOCK) ON dc.Channel_Name='Youzan'
	LEFT JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON CASE WHEN LEFT(di.SKU_ID,1) = 'Y' THEN REPLACE(di.SKU_ID,'Y','') ELSE di.SKU_ID END=p.SKU_ID
 	WHERE bi.Order_Status <> 'TRADE_CLOSED'
		AND bi.Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112) and bi.Pay_Time IS NOT NULL --AND p.SKU_ID IS NOT NULL
	GROUP BY bi.Datekey 
		,dc.Channel_ID
		,isnull(REPLACE(di.sku_id,'Y',''),'00000000')
    --有赞社区店--
	UNION ALL
	--SELECT 
	--	   20191201 AS Datekey 
	--	  ,58 AS Channel_ID  --社区店
	--	  ,'00000000' AS SKU_ID
	--	  ,NULL AS qty
	--	  ,14469 AS [Amount]
	--	  ,null
	--	  ,null
	--	  ,null AS [Weight_KG]
	--	  ,null AS [Volume_L]
	--	  ,getdate(),'Mannual Input'
	--	  ,getdate(),'Mannual Input'
	SELECT                                                                    -----------------------------增加有赞社区销售额，直接取ODS的数据  -- Justin 20191218
		   CONVERT(VARCHAR(10),[Order_Creation_Time],112) AS Datekey 
		  ,58 AS Channel_ID  --社区店
		  ,'00000000' AS SKU_ID
		  ,NULL AS qty
		  ,SUM([Order_Paid_Amount]-[Order_Refunded_Amount]) AS [Amount]
		  ,null
		  ,null
		  ,null AS [Weight_KG]
		  ,null AS [Volume_L]
		  ,getdate(),'[ods].[File_Youzan_CommStoreOrder]'
		  ,getdate(),'[ods].[File_Youzan_CommStoreOrder]'
   FROM [ODS].[ods].[File_Youzan_CommStoreOrder]
   WHERE [Order_Status] IN ('已发货','待发货','交易完成') 
         AND CONVERT(VARCHAR(10),[Order_Creation_Time],112)>= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
   GROUP BY CONVERT(VARCHAR(10),[Order_Creation_Time],112)

	------------------Qulouxia
	UNION ALL
	SELECT 
		   qs.Datekey 
		  ,48 AS Channel_ID
		  ,qs.SKU_ID
		  ,SUM(qs.Sales_Qty-qs.Refund_QTY)
		  ,SUM(qs.Payment-qs.Refund_AMT)
		  ,null
		  ,null
		  --,SUM((qs.Sales_Qty-qs.Refund_QTY)*prod.Sale_Unit_Weight_KG /ISNULL(mp.Split_Number,1)) AS [Weight_KG]  --这里对zbox拆分处理的 数量做特殊处理，sales qty不是实际的销售单位
		  --,SUM((qs.Sales_Qty-qs.Refund_QTY)*prod.Sale_Unit_Volumn_L /ISNULL(mp.Split_Number,1)) AS [Volume_L]
		  ,SUM((qs.Sales_Qty-qs.Refund_QTY) * prod.Sale_Unit_Weight_KG) AS [Weight_KG]
		  ,SUM((qs.Sales_Qty-qs.Refund_QTY) * prod.Sale_Unit_Volumn_L) AS [Volume_L]
		  ,getdate(),'[dm].[Fct_Qulouxia_Sales]'
		  ,getdate(),'[dm].[Fct_Qulouxia_Sales]'
 	FROM  [dm].[Fct_Qulouxia_Sales] qs
	LEFT JOIN dm.Dim_Product prod ON qs.SKU_ID = prod.SKU_ID
	--LEFT JOIN (SELECT SKU_ID,Split_Number FROM [dm].[Dim_Product_AccountCodeMapping]
	--             WHERE  Account = 'Qulouxia (去楼下)') mp ON qs.SKU_ID = mp.SKU_ID
	WHERE qs.Datekey  >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112) AND qs.Order_Status = '已完成'
	GROUP BY qs.Datekey,qs.SKU_ID
	------------------CenturyMart
	UNION ALL
	SELECT 
		   cd.Datekey 
		  ,87 AS Channel_ID
		  ,cd.SKU_ID
		  ,SUM(cd.Sale_Qty)
		  ,SUM(cd.Sale_Amt)
		  ,null
		  ,null
		  ,SUM(cd.Sale_Qty * prod.Sale_Unit_Weight_KG) AS [Weight_KG]
		  ,SUM(cd.Sale_Qty * prod.Sale_Unit_Volumn_L) AS [Volume_L]
		  ,getdate(),'[dm].[Fct_Qulouxia_Sales]'
		  ,getdate(),'[dm].[Fct_Qulouxia_Sales]'
 	FROM  [dm].Fct_CenturyMart_DailySales cd
	LEFT JOIN dm.Dim_Product prod ON cd.SKU_ID = prod.SKU_ID
	WHERE cd.Datekey  >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
	GROUP BY cd.Datekey,cd.SKU_ID


	----------------------KA POS
	UNION ALL
	SELECT CONVERT(varchar(8),CAST([DATE] AS DATE),112)
		   ,CASE Customer_NM WHEN '易初东区' THEN '14'
							 WHEN '易初南区' THEN '14'
							 WHEN '欧尚'	 THEN '11'
							 WHEN '华冠'	 THEN '12'
			END AS Channel_ID
			,kp.SKU_ID
			,SUM(CAST(ISNULL(Sales_QTY,0) AS FLOAT)) AS qty 
			,SUM(CAST(ISNULL(Sales_With_Tax_AMT,0) AS FLOAT)) AS POS
			,null
			,null
			,SUM(Sales_QTY * p.Sale_Unit_Weight_KG) as  [Weight_KG]
			,SUM(Sales_QTY * p.Sale_Unit_Volumn_L) as  [Volume_L]
			,getdate(),'[ODS].[ods].[File_Sales_KA_POS]'
			,getdate(),'[ODS].[ods].[File_Sales_KA_POS]'
	FROM [ODS].[ods].[File_Sales_KA_POS] kp
	LEFT JOIN dm.Dim_Product p WITH(NOLOCK) ON kp.SKU_ID=p.SKU_ID
	WHERE CONVERT(varchar(8),CAST([DATE] AS DATE),112) >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
	GROUP BY CONVERT(varchar(8),CAST([DATE] AS DATE),112)
		,CASE Customer_NM WHEN '易初东区' THEN '14'
							 WHEN '易初南区' THEN '14'
							 WHEN '欧尚'	 THEN '11'
							 WHEN '华冠'	 THEN '12'
			END
		,kp.SKU_ID 
	-------------------------CP拿不到sellout 数据， 用sellin 代替
	UNION ALL
	SELECT 
		o.Datekey
		,ch.Channel_ID
		,o.SKU_ID
		--,o.Close_Status
	    ,SUM(O.Sale_Unit_QTY) AS qty
		,CASE WHEN o.Datekey>=20190301 THEN SUM(o.Amount) ELSE SUM(o.Full_Amount) END AS POS   --3月之前除税，3月之后含税
		,null
		,null
		,SUM(o.Sale_Unit_QTY*p.Sale_Unit_Weight_KG) AS [Weight_KG]
		,SUM(o.Sale_Unit_QTY*p.Sale_Unit_Volumn_L) AS [Volume_L]
		,getdate(),'[dm].[Fct_ERP_Sale_Order]'
		,getdate(),'[dm].[Fct_ERP_Sale_Order]'
	FROM (SELECT eso.Datekey,
		eso.Sale_Order_ID,
		eso.Close_Status,
		eso.[Customer_Name],
		eso.[Sale_Dept],
		oe.SKU_ID,
		oe.Sale_Unit,
		CASE WHEN oe.IsFree=1 AND isnull(eso.FOC_Type,'') NOT IN ('货补费用-其他','货补费用-新品进店费') THEN 0 ELSE oe.[Sale_Unit_QTY] END AS [Sale_Unit_QTY],
		oe.BASE_UNIT,
		CASE WHEN oe.IsFree=1 AND isnull(eso.FOC_Type,'') NOT IN ('货补费用-其他','货补费用-新品进店费') THEN 0 ELSE oe.[Base_Unit_QTY] END AS [Base_Unit_QTY],
		oe.Stock_Unit,
		oe.Stock_QTY,
		--eso.Customer_Name , cl.Customer_Name ,cl.IsActive,cl.Price_List_No,oe.SKU_ID , pl.SKU_ID ,
		pl.price_list_no,
		CASE WHEN ISNULL(oe.Full_Amount,0) > 0 AND eso.[Customer_Name] NOT IN ('北京京东世纪信息技术有限公司','蜜芽宝贝（天津）信息技术有限公司','苏宁红孩子','Rasa旗舰店','Lakto旗舰店','有赞商城') THEN oe.Full_Amount
			WHEN ISNULL(oe.Full_Amount,0) > 0 AND eso.[Customer_Name] IN ('北京京东世纪信息技术有限公司','蜜芽宝贝（天津）信息技术有限公司','苏宁红孩子','Rasa旗舰店','Lakto旗舰店','有赞商城') THEN oe.Full_Amount+oe.Discount_Amount		
			WHEN ISNULL(oe.Full_Amount,0) = 0 AND oe.IsFree=1 AND isnull(eso.FOC_Type,'') NOT IN ('货补费用-其他','货补费用-新品进店费') THEN 0  -- eliminate FOC fee
			ELSE pl.SKU_Base_Price*oe.Base_Unit_QTY*oe.Discount_Rate  END AS Full_Amount,--价税合计
		CASE WHEN ISNULL(oe.Amount,0) > 0 AND eso.[Customer_Name] NOT IN ('北京京东世纪信息技术有限公司','蜜芽宝贝（天津）信息技术有限公司','苏宁红孩子','Rasa旗舰店','Lakto旗舰店','有赞商城') THEN oe.Amount
			WHEN ISNULL(oe.Amount,0) > 0 AND eso.[Customer_Name] IN ('北京京东世纪信息技术有限公司','蜜芽宝贝（天津）信息技术有限公司','苏宁红孩子','Rasa旗舰店','Lakto旗舰店','有赞商城') THEN oe.Amount+oe.Discount_Amount/oe.Tax_Rate	
			WHEN ISNULL(oe.Amount,0) = 0 AND oe.IsFree=1 AND isnull(eso.FOC_Type,'') NOT IN ('货补费用-其他','货补费用-新品进店费') THEN 0  -- eliminate FOC fee
			ELSE pl.SKU_Base_Price*oe.Base_Unit_QTY*oe.Discount_Rate/oe.Tax_Rate END AS Amount--不含税合计
		FROM [dm].[Fct_ERP_Sale_Order] eso WITH(NOLOCK)
		JOIN [dm].[Fct_ERP_Sale_OrderEntry] oe WITH(NOLOCK) ON eso.Sale_Order_ID = oe.Sale_Order_ID
		--LEFT JOIN [dm].[Dim_ERP_Unit_ConvertRate] uc WITH(NOLOCK) ON uc.From_Unit = oe.Price_Unit AND uc.To_Unit = oe.Base_Unit
		LEFT JOIN [dm].[Dim_ERP_CustomerList] cl ON eso.Customer_Name = cl.Customer_Name  AND cl.IsActive = 1
		LEFT JOIN [dm].[Dim_Product_Pricelist] pl ON cl.Price_List_No = pl.Price_List_No  --Customer Price
			AND oe.SKU_ID = pl.SKU_ID 
			AND eso.Date BETWEEN pl.Effective_Date AND pl.Expiry_Date
		WHERE eso.Sale_Org='富友联合食品（中国）有限公司'
		--AND DATEKEY >='20191010' and eso.Customer_Name='苏果超市有限公司'
		)o  --SellIn订单详情
	LEFT JOIN dm.Dim_Product p WITH(NOLOCK) ON o.SKU_ID = p.SKU_ID
	LEFT JOIN dm.Dim_Channel_hist ch WITH(NOLOCK) ON o.[Customer_Name] = ch.ERP_Customer_Name AND LEFT(o.Datekey,6)=ch.Monthkey
	LEFT JOIN dm.Dim_Channel dc WITH(NOLOCK) ON ch.Channel_ID = dc.Channel_ID
	WHERE o.Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112) AND dc.Channel_Type = 'CP'
	GROUP BY o.Datekey
		,ch.Channel_ID
		,o.SKU_ID
	---------------lakto和pinduoduo
	--10月起，Lokto数据用OMS订单数据
	UNION ALL

	SELECT   
		o.Order_DateKey AS Datekey
		,o.Channel_ID
		,oi.SKU_ID
	    ,SUM(oi.Quantity) AS Sale_Unit_QTY
		,SUM(oi.Payment_Amount_Split) AS [Amount]  
		,NULL AS [Discount_Amount]
		,NULL AS [Unit_Price]
		,SUM(oi.Quantity*p.Sale_Unit_Weight_KG) AS [Weight_KG]
		,SUM(oi.Quantity*p.Sale_Unit_Volumn_L) AS [Volume_L]
		,GETDATE() AS [Create_time]   
		,'dm.Fct_Order Lakto'
		,GETDATE() AS [Update_time]   
		,'dm.Fct_Order Lakto'
	From dm.Fct_Order o 
	JOIN dm.Fct_Order_Item oi ON o.Order_Key=oi.Order_Key
	LEFT JOIN dm.DIm_Product p ON oi.SKU_ID = p.SKU_ID
	LEFT JOIN dm.Dim_Product_PriceList pl ON pl.Price_List_Name='统一供价' AND oi.SKU_ID = pl.SKU_ID
	WHERE o.Channel_ID in (18 ,71)
		AND o.Is_Cancelled <> 1
		AND o.Order_DateKey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112) 
	GROUP BY o.Order_DateKey,o.Channel_ID,oi.SKU_ID

	--------- Others
	--UNION 
	--SELECT Year,replace(Period,'.','') Period,Customer,Channel_ID,Store_NM,SKU,t.[SKU_NM],Brand,category,rsp,qty,gs_price,pos,GETDATE() AS [Create_Time],OBJECT_NAME(@@PROCID) AS [Create_By],GETDATE() AS [Update_Time],OBJECT_NAME(@@PROCID) AS [Update_By]
	--FROM (
	--SELECT left(Period,4) year,Period,Customer,'7' Channel_ID,area as Store_NM,SKU,null SKU_NM,Brand,category,rsp,qty,gs_price,pos
	--FROM [ODS].[ods].[File_Sales_Beequick]
	--UNION ALL
	--SELECT left(Period,4) year,Period,Customer,'8' Channel_ID,Area,SKU,null SKU_NM,Brand,category,rsp,qty,gs_price,pos
	--FROM [ODS].[ods].[File_Sales_Missfresh]
	--UNION ALL
	--SELECT left(Period,4) year,Period,Customer,'9' Channel_ID,Area,SKU,null SKU_NM,Brand,category,rsp,qty,gs_price,pos
	--FROM [ODS].[ods].[File_Sales_Ourhours]
	--UNION ALL
	--SELECT left(Period,4) year,Period,Customer,'10' Channel_ID,Area,SKU,null SKU_NM,Brand,category,rsp,qty,gs_price,pos
	--FROM [ODS].[ods].[File_Sales_Icoffee]
	--UNION ALL
	--SELECT  left(Period,4) year,Period,'Mia' Customer,'13' Channel_ID,null Store_NM,SKU_ID,[SKU_NM],null Brand,null category,rsp,qty ,Order_GS,pay_split
	--FROM [ODS].[ods].[File_Sales_Mia]
	--UNION ALL
	--SELECT left(Period,4) year,Period,'Wechat' Customer,'3' Channel_ID,null Store_NM,SKU_ID,[SKU_NM],null Brand,null category,rsp,qty ,Order_GS,pay_split 
	--FROM [ODS].[ods].[File_Sales_Wechat]
	--UNION ALL 
	


	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
