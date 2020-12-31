﻿USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dm].[SP_Fct_Sales_SellOut_byChannel_byRegion_Update_20200117] --400
	@Ret_Days INT = 90
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--增量抽取天数
	--DECLARE @Ret_Days INT = 90;

	--TRUNCATE TABLE [dm].[Fct_Sales_SellOut_byChannel_byRegion];
	--Reload latest 7 days
	DELETE FROM [dm].[Fct_Sales_SellOut_byChannel_byRegion]
	WHERE Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112);

	--INSERT
	INSERT INTO [dm].[Fct_Sales_SellOut_byChannel_byRegion]
           ([DateKey],
			[Channel_ID],
			[Sale_Area],
			[Sale_Territory],
			[SKU_ID],
			[Sale_QTY],
			[Sale_AMT],
			[Sale_AMT_Krmb],
			[Weight_KG],
			[Weight_MT],
			[Volume_L],
			[Create_time],
			[Create_By],
			[Update_time],
			[Update_By])

	--Part1 ： Read KA Sales from [dm].[Fct_KAStore_DailySalesInventory] 
	------------YH:			5  
	------------Vanguard:	15
	------------Kidswant:	16
	------------CenturyMart：87
	SELECT ka.[DateKey]  AS [DateKey]
		--,dc.Channel_ID
		,CASE s.Channel_Account WHEN 'YH' THEN 5 
			WHEN  'KW' THEN 16 
			WHEN  'Vanguard' THEN 15 
			WHEN  'CenturyMart' THEN 87
			WHEN  'Huaguan' THEN 20
			ELSE 0 	END AS Channel_ID
		,ISNULL(CASE WHEN s.Channel_Account ='YH' THEN s.Account_Area_CN ELSE s.Sales_Area_CN END,'') AS [Sale_Area]		--YH看 glzx大区
		,ISNULL(stm.SalesTerritory,'') AS [Sale_Territory]
		,ka.SKU_ID 
		,SUM(ka.Sales_Qty) AS [Sale_QTY]
		,SUM(ka.Sales_AMT) AS [Sale_AMT]
		,SUM(ka.Sales_AMT)/1000 AS [Sale_AMT_Krmb]
		,SUM(ka.Sales_Qty * p.Sale_Unit_Weight_KG) as  [Weight_KG]
		,SUM(ka.Sales_Qty * p.Sale_Unit_Weight_KG)/1000 as  [Weight_MT]
		,SUM(ka.Sales_Qty * p.Sale_Unit_Volumn_L) as  [Volume_L]
		,GETDATE(),'[dm].[Fct_KAStore_DailySalesInventory]'
		,GETDATE(),'[dm].[Fct_KAStore_DailySalesInventory]'
	FROM [dm].[Fct_KAStore_DailySalesInventory] ka WITH(NOLOCK)
	LEFT JOIN [FU_EDW].[Dim_Calendar] C on ka.[DateKey] = C.Date_ID
	JOIN [dm].[Dim_Product] p WITH(NOLOCK)  on ka.SKU_ID = p.SKU_ID	
	JOIN [dm].[Dim_Store] s WITH(NOLOCK) ON ka.Store_ID = s.Store_ID
	LEFT JOIN [dm].[Dim_SalesTerritoryMapping] stm WITH(NOLOCK) ON CHARINDEX(stm.Province_Short,s.Store_Province)>0
	WHERE  ka.Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112) 
	GROUP BY ka.Datekey  
			,CASE s.Channel_Account WHEN 'YH' THEN 5 
				WHEN  'KW' THEN 16 
				WHEN  'Vanguard' THEN 15 
				WHEN  'CenturyMart' THEN 87
				WHEN  'Huaguan' THEN 20
				ELSE 0 	END
			,ka.SKU_ID 
			,ISNULL(CASE WHEN s.Channel_Account ='YH' THEN s.Account_Area_CN ELSE s.Sales_Area_CN END,'')
			,ISNULL(stm.SalesTerritory,'')
	
	--Part2 ： O2O/社区店/Zbox/Tmall/PDD
	------------------O2O： Youzan 45
	UNION ALL
	SELECT 
		   bi.Datekey AS Datekey 
		  ,ISNULL(dc.Channel_ID,45) AS Channel_ID
		  ,'' AS [Sale_Area]		
		  ,'' AS [Sale_Territory]
		  ,ISNULL(REPLACE(CASE di.sku_id WHEN '寄生单' THEN '00000000' ELSE di.sku_id END,'Y',''),'00000000') AS SKU_ID
		  ,SUM(di.QTY*di.pcs_cnt) AS qty
		  ,SUM(CASE WHEN pm.payment is null THEN bi.Pay_Amount ELSE di.payment END 
				+CASE WHEN pm.payment = 0 THEN bi.Shipping_Amount ELSE bi.Shipping_Amount*di.payment/pm.payment END
				/*-ISNULL(CASE WHEN ISNULL(bi.Order_Amount,0) = 0 THEN bi.Refund_Amount ELSE bi.Refund_Amount*di.payment/bi.Order_Amount END,0)*/
				) AS [Sale_AMT]
		  ,SUM(CASE WHEN pm.payment is null THEN bi.Pay_Amount ELSE di.payment END 
				+CASE WHEN pm.payment = 0 THEN bi.Shipping_Amount ELSE bi.Shipping_Amount*di.payment/pm.payment END
				/*-ISNULL(CASE WHEN ISNULL(bi.Order_Amount,0) = 0 THEN bi.Refund_Amount ELSE bi.Refund_Amount*di.payment/bi.Order_Amount END,0)*/
				)/1000 AS [Sale_AMT_Krmb]
		  ,SUM(di.QTY*di.pcs_cnt*delivery_cnt*p.Sale_Unit_Weight_KG) AS [Weight_KG]
		  ,SUM(di.QTY*di.pcs_cnt*delivery_cnt*p.Sale_Unit_Weight_KG)/1000 AS [Weight_MT]
		  ,SUM(di.QTY*di.pcs_cnt*delivery_cnt*p.Sale_Unit_Volumn_L) AS [Volume_L]
		  ,getdate(),'[dm].[Fct_O2O_Order_Detail_info]'
		  ,getdate(),'[dm].[Fct_O2O_Order_Detail_info]'
 	FROM  [dm].[Fct_O2O_Order_Base_info] bi WITH(NOLOCK) 
	LEFT JOIN [dm].[Fct_O2O_Order_Detail_info] di WITH(NOLOCK) ON bi.Order_ID=di.Order_ID
	LEFT JOIN (	--获取O2O每个order_no的payment
		SELECT bi.Order_No,SUM(di.payment) AS payment
 		FROM  [dm].[Fct_O2O_Order_Base_info] bi WITH(NOLOCK) 
		LEFT JOIN [dm].[Fct_O2O_Order_Detail_info] di WITH(NOLOCK) ON bi.Order_ID=di.Order_ID
		GROUP BY bi.Order_No) pm ON bi.Order_No = pm.Order_No
	LEFT JOIN [dm].[Dim_Channel] dc WITH(NOLOCK) ON dc.Channel_Name='Youzan'
	LEFT JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON CASE WHEN LEFT(di.SKU_ID,1) = 'Y' THEN REPLACE(di.SKU_ID,'Y','') ELSE di.SKU_ID END=p.SKU_ID
 	WHERE bi.Order_Status <> 'TRADE_CLOSED'
		AND bi.Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112) 
		--AND bi.Datekey >= 20191201 
		AND bi.Pay_Time IS NOT NULL 
		AND di.SKU_ID NOT LIKE 'POP%'
		--AND p.SKU_ID IS NOT NULL
	GROUP BY bi.Datekey 
		,dc.Channel_ID
		,ISNULL(REPLACE(CASE di.sku_id WHEN '寄生单' THEN '00000000' ELSE di.sku_id END,'Y',''),'00000000')

    ------------------有赞社区店：	58
	UNION ALL	 
	--SELECT                                                                    
	--	   CONVERT(VARCHAR(10),[Order_Creation_Time],112) AS Datekey 
	--	  ,58 AS Channel_ID  
	--	  ,'' AS [Sale_Area]		
	--	  ,'' AS [Sale_Territory]
	--	  ,'00000000' AS SKU_ID
	--	  ,NULL AS qty
	--	  ,SUM([Order_Paid_Amount]-[Order_Refunded_Amount]) AS [Amount]
	--	  ,SUM([Order_Paid_Amount]-[Order_Refunded_Amount])/1000 AS [Amount_krmb]
	--	  ,null AS [Weight_KG]			--不能拆分到sku，故无重量
	--	  ,null AS [Weight_MT] 
	--	  ,null AS [Volume_L]
	--	  ,getdate(),'[ods].[File_Youzan_CommStoreOrder]'
	--	  ,getdate(),'[ods].[File_Youzan_CommStoreOrder]'
 --  FROM [ODS].[ods].[File_Youzan_CommStoreOrder] WITH(NOLOCK)
 --  WHERE [Order_Status] IN ('已发货','待发货','交易完成') 
 --        AND CONVERT(VARCHAR(10),[Order_Creation_Time],112)>= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
 --  GROUP BY CONVERT(VARCHAR(10),[Order_Creation_Time],112)
  ------------------------------------------------根据明细拆分SKU-------------------------------------------Justin 2020-01-08
 	SELECT CONVERT(VARCHAR(10),[Order_Creation_Time],112) AS Datekey 
		  ,58 AS Channel_ID  
		  ,'' AS [Sale_Area]		
		  ,'' AS [Sale_Territory]
		  ,ISNULL(DD.SKU_ID,'00000000') AS SKU_ID       --SKU ID 不能为Null
		  ,SUM(DD.QTY) AS qty
		  ,ISNULL(SUM([Order_Paid_Amount]-[Order_Refunded_Amount])*MAX(DD.AMONT_RATE) , SUM([Order_Paid_Amount]-[Order_Refunded_Amount]))AS [Amount]
		  ,ISNULL(SUM([Order_Paid_Amount]-[Order_Refunded_Amount])*MAX(DD.AMONT_RATE)/1000,SUM([Order_Paid_Amount]-[Order_Refunded_Amount])/1000) AS [Amount_krmb]
		  ,SUM(Sale_Unit_Weight_KG) AS [Weight_KG]			
		  ,SUM(Sale_Unit_Weight_MT) AS [Weight_MT] 
		  ,SUM(Sale_Unit_Volumn_L) AS [Volume_L]
		  ,getdate(),'[ods].[File_Youzan_CommStoreOrder]'
		  ,getdate(),'[ods].[File_Youzan_CommStoreOrder]'
   FROM [ODS].[ods].[File_Youzan_CommStoreOrder] AS H WITH(NOLOCK)
   LEFT JOIN
   (SELECT D.[Order_Number],D.SKU_ID,D.QTY,SP.SKU_Price,(D.QTY*SP.Sale_Unit_Weight_KG) AS Sale_Unit_Weight_KG,(D.QTY*SP.Sale_Unit_Weight_KG)/1000 AS Sale_Unit_Weight_MT,
           (D.QTY*SP.Sale_Unit_Volumn_L) AS Sale_Unit_Volumn_L,(D.QTY*SP.SKU_Price)/SUM((D.QTY*SP.SKU_Price))OVER(PARTITION BY D.[Order_Number]) AS AMONT_RATE FROM
	(SELECT T.[Order_Number],S.SKU_ID,S.QTY 
	FROM [ODS].[ods].[File_Youzan_CommStoreOrderDetails] T 
	OUTER APPLY [dbo].[Split_Product](T.[Specification_Code]) S) AS D     --根据提供商品代码拆分数据，产品销售金额按照价格比例计算
	LEFT JOIN
	( SELECT  P.SKU_ID,P.Sale_Unit_Weight_KG,P.Sale_Unit_Volumn_L,ISNULL(PP.SKU_Price,PM.SKU_Price) AS SKU_Price FROM [dm].[Dim_Product] P   --获取产品价格，重量，体积
	 LEFT JOIN (SELECT * FROM  [dm].[Dim_Product_Pricelist] WHERE Price_List_Name='统一供价') PP  --优先使用'统一供价'
	 ON P.SKU_ID=PP.SKU_ID
	 LEFT JOIN (SELECT SKU_ID,MAX(SKU_Price) AS SKU_Price FROM  [dm].[Dim_Product_Pricelist] GROUP BY SKU_ID) PM  --没有'统一供价'，使用最高价
	 ON P.SKU_ID=PM.SKU_ID
	 WHERE ISNULL(PP.SKU_Price,PM.SKU_Price) IS NOT NULL) AS SP
	 ON D.SKU_ID=SP.SKU_ID) DD
   ON H.Order_Number=DD.[Order_Number]
   WHERE [Order_Status] IN ('已发货','待发货','交易完成') 
         AND CONVERT(VARCHAR(10),[Order_Creation_Time],112)>= CONVERT(VARCHAR(8),GETDATE()-90,112)
   GROUP BY CONVERT(VARCHAR(10),[Order_Creation_Time],112),DD.SKU_ID

	------------------Zbox：  48
	UNION ALL
	SELECT 
		   qs.Datekey 
		  ,48 AS Channel_ID
		  ,''
		  ,''
		  ,qs.SKU_ID
		  ,SUM(qs.Sales_Qty-qs.Refund_QTY)
		  ,SUM(qs.Payment-qs.Refund_AMT)
		  ,SUM(qs.Payment-qs.Refund_AMT)/1000
		  ,SUM((qs.Sales_Qty-qs.Refund_QTY) * prod.Sale_Unit_Weight_KG) AS [Weight_KG]
		  ,SUM((qs.Sales_Qty-qs.Refund_QTY) * prod.Sale_Unit_Weight_KG)/1000 AS [Weight_MT]
		  ,SUM((qs.Sales_Qty-qs.Refund_QTY) * prod.Sale_Unit_Volumn_L) AS [Volume_L]
		  ,getdate(),'[dm].[Fct_Qulouxia_Sales]'
		  ,getdate(),'[dm].[Fct_Qulouxia_Sales]'
 	FROM  [dm].[Fct_Qulouxia_Sales] qs WITH(NOLOCK)
	JOIN dm.Dim_Product prod ON qs.SKU_ID = prod.SKU_ID
	WHERE qs.Order_Status = '已完成'
		AND qs.Datekey  >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112) 
	GROUP BY qs.Datekey,qs.SKU_ID
	
	---------------Tmall lakto和pinduoduo
	--10月起，Lokto数据用OMS订单数据
	UNION ALL
	SELECT   
		o.Order_DateKey AS Datekey
		,o.Channel_ID
		,'' AS [Sale_Area]		
		,'' AS [Sale_Territory]
		,oi.SKU_ID
	    ,SUM(oi.Quantity) AS Sale_Unit_QTY
		,SUM(oi.Payment_Amount_Split) AS [Amount]  
		,SUM(oi.Payment_Amount_Split)/1000 AS [Amount_krmb]  
		,SUM(oi.Quantity*p.Sale_Unit_Weight_KG) AS [Weight_KG]
		,SUM(oi.Quantity*p.Sale_Unit_Weight_KG)/1000 AS [Weight_MT]
		,SUM(oi.Quantity*p.Sale_Unit_Volumn_L) AS [Volume_L]
		,GETDATE() AS [Create_time]   
		,'dm.Fct_Order'
		,GETDATE() AS [Update_time]   
		,'dm.Fct_Order'
	FROM dm.Fct_Order o WITH(NOLOCK)
	JOIN dm.Fct_Order_Item oi WITH(NOLOCK) ON o.Order_Key=oi.Order_Key
	JOIN dm.DIm_Product p WITH(NOLOCK) ON oi.SKU_ID = p.SKU_ID
	LEFT JOIN dm.Dim_Product_PriceList pl WITH(NOLOCK) ON pl.Price_List_Name='统一供价' AND oi.SKU_ID = pl.SKU_ID
	WHERE o.Channel_ID in (18,71,97,108,109)
		AND o.Is_Cancelled <> 1
		AND o.Order_DateKey >= 20191001  --10月起，Lokto数据用OMS订单数据
		AND o.Order_DateKey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112) 
	GROUP BY o.Order_DateKey
		,o.Channel_ID
		,oi.SKU_ID


	-------------------------CP拿不到sellout 数据， 用sellin 代替
	-------------------------EKA也取Sellin作为Sellout
	UNION ALL
	
	SELECT si.Datekey
		,si.Channel_ID
		,'' AS [Sale_Area]		
		,ISNULL(stm.SalesTerritory,'') AS [Sale_Territory]
		,si.SKU_ID
	    ,SUM(si.QTY) AS qty
		,SUM(si.Amount) AS Amount   
		,SUM(si.Amount)/1000 AS Amount_krmb   
		,SUM(si.Weight_KG) AS [Weight_KG]
		,SUM(si.Weight_KG)/1000 AS [Weight_MT]
		,SUM(si.Volume_L) AS [Volume_L]
		,getdate(),'[dm].[Fct_Sales_SellIn_ByChannel]'
		,getdate(),'[dm].[Fct_Sales_SellIn_ByChannel]'
	FROM [dm].[Fct_Sales_SellIn_ByChannel] si WITH(NOLOCK)
	JOIN dm.Dim_Channel dc WITH(NOLOCK) ON si.Channel_ID = dc.Channel_ID 
		AND (dc.Channel_Type = 'CP' OR dc.Channel_Name_Display = '深圳微之家' )
		AND dc.Channel_ID NOT IN (5			--YH
			,16				--Vanguard
			,15				--KidsWant
			,87				--Huaguan
			,20)			--世纪联华   这些在KA Sales里面都有了
	LEFT JOIN [dm].[Dim_SalesTerritoryMapping] stm WITH(NOLOCK) ON CHARINDEX(stm.Province_Short,dc.Province)>0
	WHERE si.Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112) 
	GROUP BY si.Datekey
		,si.Channel_ID
		,si.SKU_ID
		,ISNULL(stm.SalesTerritory,'')

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END

SELECT * FROM dm.Dim_Channel where Channel_ID  IN (5 
			,16 
			,15 
			,87
			,20)

 /*
	SELECT 
		o.Datekey
		,ch.Channel_ID
		,'' AS [Sale_Area]		
		,'' AS [Sale_Territory]
		,o.SKU_ID
	    ,SUM(O.Sale_Unit_QTY) AS qty
		,CASE WHEN o.Datekey>=20190301 THEN SUM(o.Amount) ELSE SUM(o.Full_Amount) END AS Amount   
		,(CASE WHEN o.Datekey>=20190301 THEN SUM(o.Amount) ELSE SUM(o.Full_Amount) END)/1000 AS Amount_krmb   
		,SUM(o.Sale_Unit_QTY*p.Sale_Unit_Weight_KG) AS [Weight_KG]
		,SUM(o.Sale_Unit_QTY*p.Sale_Unit_Weight_KG)/1000 AS [Weight_MT]
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
		LEFT JOIN [dm].[Dim_ERP_CustomerList] cl ON eso.Customer_Name = cl.Customer_Name  AND cl.IsActive = 1
		LEFT JOIN [dm].[Dim_Product_Pricelist] pl ON cl.Price_List_No = pl.Price_List_No  --Customer Price
			AND oe.SKU_ID = pl.SKU_ID 
			AND eso.Date BETWEEN pl.Effective_Date AND pl.Expiry_Date
		WHERE eso.Sale_Org='富友联合食品（中国）有限公司'
		)o  --SellIn订单详情
	LEFT JOIN dm.Dim_Product p WITH(NOLOCK) ON o.SKU_ID = p.SKU_ID
	LEFT JOIN dm.Dim_Channel_hist ch WITH(NOLOCK) ON o.[Customer_Name] = ch.ERP_Customer_Name AND LEFT(o.Datekey,6)=ch.Monthkey
	LEFT JOIN dm.Dim_Channel dc WITH(NOLOCK) ON ch.Channel_ID = dc.Channel_ID
	WHERE  dc.Channel_Type = 'CP' 
		AND	o.Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112) 
	GROUP BY o.Datekey
		,ch.Channel_ID
		,o.SKU_ID
		*/
/*
	SELECT 
		k.Calendar_DT  AS [DateKey]
		,dc.Channel_ID
		,ISNULL(s.Account_Area_CN,'') AS [Sale_Area]		--YH看 glzx大区
		,ISNULL(stm.SalesTerritory,'') AS [Sale_Territory]
		,k.SKU_ID 
		,SUM(k.Sales_Qty) AS [Sale_QTY]
		,SUM(k.Sales_AMT) AS [Sale_AMT]
		,SUM(k.Sales_AMT)/1000 AS [Sale_AMT_Krmb]
		,SUM(k.Sales_Qty * p.Sale_Unit_Weight_KG) as  [Weight_KG]
		,SUM(k.Sales_Qty * p.Sale_Unit_Weight_KG)/1000 as  [Weight_MT]
		,SUM(k.Sales_Qty * p.Sale_Unit_Volumn_L) as  [Volume_L]
		,getdate(),'[dm].[Fct_YH_Sales_Inventory]'
		,getdate(),'[dm].[Fct_YH_Sales_Inventory]'
	FROM [dm].[Fct_YH_Sales_Inventory] k WITH(NOLOCK) 
	LEFT JOIN [FU_EDW].[Dim_Calendar] C on k.Calendar_DT = C.Date_ID
	LEFT JOIN [dm].[Dim_Product] p WITH(NOLOCK)  on k.SKU_ID=p.SKU_ID	
	LEFT JOIN [dm].[Dim_Channel] dc WITH(NOLOCK) ON dc.Channel_Name='YH'
	LEFT JOIN [dm].[Dim_Store] s WITH(NOLOCK) ON k.Store_ID = s.Store_ID
	LEFT JOIN [dm].[Dim_SalesTerritoryMapping] stm WITH(NOLOCK) ON CHARINDEX(stm.Province_Short,s.Store_Province)>0
	--WHERE k.Calendar_DT >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
	--WHERE k.Calendar_DT >= 20191201
	GROUP BY k.Calendar_DT  
			,dc.Channel_ID
			,k.SKU_ID 
			,ISNULL(s.Account_Area_CN,'')
			,ISNULL(stm.SalesTerritory,'')
*/
	-------------Kidswant:16
/*
	UNION ALL
	SELECT 
		k.Datekey  AS [DateKey]
		,dc.Channel_ID
		,ISNULL(s.Sales_Area_CN,'') AS [Sale_Area]
		,ISNULL(stm.SalesTerritory,'') AS [Sale_Territory]
		,k.SKU_ID 
		,SUM(k.Sales_Qty) AS [Sale_QTY]
		,SUM(k.Sales_AMT) AS [Sale_AMT]
		,SUM(k.Sales_AMT)/1000 AS [Sale_AMT_Krmb]
		,SUM(k.Sales_Qty * p.Sale_Unit_Weight_KG) as  [Weight_KG]
		,SUM(k.Sales_Qty * p.Sale_Unit_Weight_KG)/1000 as  [Weight_MT]
		,SUM(k.Sales_Qty * p.Sale_Unit_Volumn_L) as  [Volume_L]
		,getdate(),'[dm].[Fct_Kidswant_DailySales]'
		,getdate(),'[dm].[Fct_Kidswant_DailySales]'
	FROM [dm].[Fct_Kidswant_DailySales] k  WITH(NOLOCK) 
	LEFT JOIN [FU_EDW].[Dim_Calendar] C on k.Datekey = C.Date_ID
	LEFT JOIN [dm].[Dim_Product] p WITH(NOLOCK)  on k.SKU_ID=p.SKU_ID	
	LEFT JOIN [dm].[Dim_Channel] dc WITH(NOLOCK) ON dc.Channel_Name='KidsWant'
	LEFT JOIN [dm].[Dim_Store] s WITH(NOLOCK) ON k.Store_ID = s.Store_ID
	LEFT JOIN [dm].[Dim_SalesTerritoryMapping] stm WITH(NOLOCK) ON CHARINDEX(stm.Province_Short,s.Store_Province)>0
	--WHERE k.Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
	--WHERE k.Datekey >= 20191201
	GROUP BY k.Datekey  
			,dc.Channel_ID
			,k.SKU_ID 
			,ISNULL(s.Sales_Area_CN,'')
			,ISNULL(stm.SalesTerritory,'')
*/
	-------------Vanguard:15

/*	UNION ALL
	SELECT 
		k.Datekey  AS [DateKey]
		,dc.Channel_ID
		,ISNULL(s.Sales_Area_CN,'') AS [Sale_Area]
		,ISNULL(stm.SalesTerritory,'') AS [Sale_Territory]
		,k.SKU_ID 
		,SUM(k.Sale_Qty) AS [Sale_QTY]
		,SUM(k.Gross_Sale_Value) AS [Sale_AMT]
		,SUM(k.Gross_Sale_Value)/1000 AS [Sale_AMT_Krmb]
		,SUM(k.Sale_Qty * p.Sale_Unit_Weight_KG) as  [Weight_KG]
		,SUM(k.Sale_Qty * p.Sale_Unit_Weight_KG)/1000 as  [Weight_MT]
		,SUM(k.Sale_Qty * p.Sale_Unit_Volumn_L) as  [Volume_L]
		,getdate(),'[dm].[Fct_CRV_DailySales]'
		,getdate(),'[dm].[Fct_CRV_DailySales]'
	FROM [dm].[Fct_CRV_DailySales] k  WITH(NOLOCK) 
	LEFT JOIN [FU_EDW].[Dim_Calendar] C on k.Datekey = C.Date_ID
	LEFT JOIN [dm].[Dim_Product] p WITH(NOLOCK)  on k.SKU_ID=p.SKU_ID	
	LEFT JOIN [dm].[Dim_Channel] dc WITH(NOLOCK) ON dc.Channel_Name='Vanguard'
	LEFT JOIN [dm].[Dim_Store] s WITH(NOLOCK) ON k.Store_ID = s.Store_ID
	LEFT JOIN [dm].[Dim_SalesTerritoryMapping] stm WITH(NOLOCK) ON CHARINDEX(stm.Province_Short,s.Store_Province)>0
	--WHERE k.Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
	WHERE k.Datekey >= 20191201
	GROUP BY k.Datekey  
			,dc.Channel_ID
			,k.SKU_ID 
			,ISNULL(s.Sales_Area_CN,'')
			,ISNULL(stm.SalesTerritory,'')

*/
/*------------------CenturyMart
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
	*/


	
	/*
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

		*/
GO
