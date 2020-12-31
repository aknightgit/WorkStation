USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_Youzan_Revenue_Detail_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [rpt].[SP_Youzan_Revenue_Detail_Update]
AS
BEGIN

	DROP TABLE IF EXISTS #orderdetail;
	-- 有赞对账
	SELECT 
		 yr.Revenue_Time AS [Revenue Date]
		,c.Month_SNM AS [Month]
		,ob.Order_Create_Time AS [Created date]
		,ob.Order_Close_Time AS [交易成功时间]
		,yr.Order_No AS [Order Number]
		,yr.Order_No AS [唯一值]
		,od.Product_Name AS [Product Name]
		,CASE WHEN ob.Express_Type='无需发货（虚拟商品订单）' THEN '虚拟商品'
			WHEN ob.is_cycle=1 THEN '周期购商品' ELSE '普通类型商品' END AS [商品类型]
		,prod.Sale_Unit_CN AS [Sales unit]
		,ob.Order_Status AS [Order Status]
		,CASE WHEN ob.is_cycle=0 THEN 1 WHEN ob.Order_Status <>'TRADE_CLOSED' THEN od.delivery_cnt ELSE NULL END AS [Length of Subsrciption, week]
		,CASE WHEN ob.Order_Status <>'TRADE_CLOSED' THEN od.pcs_cnt * od.QTY ELSE NULL END  AS [每次数量]
		,CASE WHEN ob.is_cycle=0 THEN CAST(od.payment AS DECIMAL(18,2)) WHEN ob.Order_Status <>'TRADE_CLOSED' THEN CAST(CAST(od.payment AS DECIMAL(18,2))/od.delivery_cnt AS DECIMAL(18,2)) ELSE NULL END AS [每次金额]
		,CASE WHEN ob.is_cycle=0 THEN 1 WHEN ob.Order_Status <>'TRADE_CLOSED' THEN yr.Delivery_Cnt ELSE NULL END AS [期间内配送次数]
		,CASE WHEN ISNULL(od.SKU_ID,'') IN ('','寄生单') OR ob.Order_Status = 'TRADE_CLOSED' THEN NULL ELSE yr.Delivery_Cnt * od.pcs_cnt * od.QTY END AS [Qty, sales unit]
		,CAST(yr.Income_Amount AS DECIMAL(18,2)) AS [Actual Order amount]	
		,CASE WHEN ob.Express_Type='无需发货（虚拟商品订单）' OR ob.Order_Status = 'TRADE_CLOSED' THEN NULL
			WHEN ob.is_cycle=1 THEN CAST(CAST(od.payment AS DECIMAL(18,2))/od.delivery_cnt * yr.Delivery_Cnt AS DECIMAL(18,2)) 
			ELSE CAST(od.payment AS DECIMAL(18,2)) END AS [期间内配送金额]
		,cast(0 AS decimal(9,2)) AS [期间运费]

		,CASE WHEN ob.pay_type in ('礼品卡支付','组合支付') THEN 'Y' ELSE NULL END AS [礼品卡]
		,CASE WHEN ISNULL(od.SKU_ID,'') IN ('','寄生单') THEN yr.Order_No ELSE NULL END AS [无SKU的订单]	
		,ISNULL(ob.Shipping_Amount,0) AS [运费] --运费	
		,od.Product_ID AS [规格编码]
		,CASE WHEN ISNULL(od.SKU_ID,'寄生单') ='寄生单' THEN '间接物料' ELSE TRIM(od.SKU_ID) END AS [SKU ID]
		,yr.Revenue_Name
		,CAST(pl.SKU_Price AS DECIMAL(9,2)) AS [RSP per sales unit]
		,CASE WHEN ob.Order_Status <>'TRADE_CLOSED' THEN CAST(yr.Delivery_Cnt * od.pcs_cnt * od.QTY * pl.SKU_Price AS DECIMAL(9,2)) ELSE NULL END AS [RSP*数量]
		,CAST(yr.Delivery_Cnt * od.pcs_cnt * od.QTY * pl.SKU_Price AS DECIMAL(9,2)) 
			- CASE WHEN ob.Express_Type='无需发货（虚拟商品订单）' OR ob.Order_Status = 'TRADE_CLOSED' THEN NULL
			WHEN ob.is_cycle=1 THEN CAST(CAST(od.payment AS DECIMAL(18,2))/od.delivery_cnt * yr.Delivery_Cnt AS DECIMAL(18,2)) 
			ELSE CAST(od.payment AS DECIMAL(18,2)) END AS [折扣]	
		,CASE WHEN op.KolName in('陈静茹') AND ob.Express_Type='快递发货' THEN 'O2O在途'
			WHEN op.KolName='陈静茹' AND ob.Express_Type='同城配送' THEN '待分配'
			ELSE 'O2O.03' END AS [发货仓库] --1）发货员工=kol，直接=020.03  2）如果发货员工=yuki的，且订单配送=快递的，就是020在途。3）发货员工=yuki，订单类别=同城，看备注，标为待分配
		,CASE WHEN ob.Consign_Store='富友中国' AND ob.Remark is null THEN '陈静茹' 
			WHEN  ob.Consign_Store='富友中国' AND ob.Remark is NOT null THEN '待分配'
			ELSE op.KolName END AS [Operator]
		,od.QTY * od.pcs_cnt AS [商品数量]
		,CAST(od.payment AS DECIMAL(18,2)) AS [商品实际成交金额]	
		,ISNULL(ob.Refund_Amount,0) AS [商品已退款金额]  
		,ob.Receiver_Name AS [Consignee]
		,ob.Receiver_Mobile AS [Consignee's cellphone#]
		,isnull(ob.Delivery_Province,'')+isnull(ob.Delivery_City,'')+isnull(Delivery_District,'')+ob.Delivery_Address AS [详细收货地址/提货地址]
		,ob.Consign_Store AS [下单网点]
		,ob.Remark AS [商家订单备注]
		,CASE WHEN ob.Express_Type='无需发货（虚拟商品订单）' THEN '-' ELSE '已发货' END AS [商品发货状态]
		,ob.Express_Type AS [商品发货方式]
		,ob.Consign_Time AS [商品发货时间]
		,ob.Refund_State AS [商品退款状态] 	
		,CASE WHEN ob.is_cycle=1 THEN od.SubscriptionType ELSE NULL END AS [周期购信息]	
		--,null AS [买家备注]
		--分销买家单订单号
		--同城送达时间/提货时间
		--买家收货信息	
		--商品发货物流公司	
		--核销时间	
		--分销买家单商品实付金额	
		,CASE WHEN ob.[is_cycle]+od.[delivery_cnt] > 1 AND ISNULL(od.[SKU_ID],'') in ('1180004','1180003') THEN 'Subscription-Fresh Milk' 
			WHEN ob.[is_cycle]+od.[delivery_cnt] > 1 AND ISNULL(od.[SKU_ID],'') NOT in ('1180004','1180003') THEN 'Subscription-Non-Fresh Milk' ELSE 'Normal' END AS [Order Type]
		,ISNULL(fx.KolName,'') AS [KOL]
		,CAST(yr.Revenue_Time AS DATETIME) AS [本期首次入账日期]
		,CAST(NULL AS INT) AS [当前累计配送次数]
		,'' AS [当前活跃订阅单]
		,'' AS [订阅已过期]
		,'' AS [订阅即将过期]
		,ROW_NUMBER() OVER (PARTITION BY yr.Order_No ORDER BY od.Product_Name,od.SKU_ID) AS SeqID
		,CASE WHEN ISNULL(ob.Order_Amount,0) <> 0 THEN 1 ELSE 0 END AS [Delivery time in the period per week]
	INTO #orderdetail
	FROM (
		SELECT Order_No
			,Revenue_Time
			,Revenue_Name
			,COUNT(CASE WHEN Revenue_Type='订单入账' THEN 1 ELSE NULL END) AS Delivery_Cnt 
			,SUM(CASE WHEN Revenue_Type='订单入账' THEN Income_Amount ELSE 0 END + CASE WHEN Revenue_Type='退款' THEN Income_Amount ELSE 0 END) AS Income_Amount
		FROM [dm].[Fct_Youzan_Revenue_Details] WITH(NOLOCK) 
		GROUP BY Order_No
			,Revenue_Time
			,Revenue_Name
		)yr
	INNER JOIN [dm].[Fct_O2O_Order_Base_info] ob WITH(NOLOCK) ON yr.Order_No=ob.Order_No
	INNER JOIN [dm].[Fct_O2O_Order_Detail_info] od WITH(NOLOCK) ON ob.Order_ID=od.Order_ID
	LEFT JOIN (
		SELECT DISTINCT Year_Month,Month_EN_NM,Month_SNM
		FROM FU_EDW.Dim_Calendar
		)c ON CONVERT(VARCHAR(6),CAST(Revenue_Time AS DATE),112)=C.Year_Month
	LEFT JOIN [dm].[Dim_Product_Pricelist] pl ON pl.Price_List_Name='统一供价' AND pl.SKU_ID=od.SKU_ID
	LEFT JOIN dm.Dim_Product prod ON od.SKU_ID = prod.SKU_ID
	LEFT JOIN [dm].[Dim_O2O_KOL] op ON ob.Operator_Employee_id=op.KOL_Employee_ID
	LEFT JOIN [dm].[Dim_O2O_KOL] fx ON ob.Fenxiao_Employee_id=fx.KOL_Employee_ID
	ORDER BY yr.Revenue_Time,yr.Order_No,od.Product_Name,od.SKU_ID
	;

	--------------------------------
	--SELECT SUM(期间内配送次数) OVER(PARTITION BY [Order Number] ORDER BY [Revenue Date]),* FROM #orderdetail WHERE 期数=13 ORDER BY [Order Number],[Revenue Date] ;
	--更新周期购订单 截止当前配送次数
	UPDATE tmp
		SET tmp.[当前累计配送次数] = y.[当前累计配送次数]
	FROM #orderdetail tmp
	JOIN( 
		SELECT *,SUM([期间内配送次数]) OVER(PARTITION BY [Order Number] ORDER BY [Revenue Date]) AS [当前累计配送次数] FROM (
		SELECT DISTINCT [Revenue Date],[Order Number],[期间内配送次数]	FROM #orderdetail WHERE [商品类型]='周期购商品'
		)x )y ON tmp.[Revenue Date]=y.[Revenue Date] AND tmp.[Order Number]=y.[Order Number];

	--select top 10 * from #orderdetail
	--判断配送结束的订单，是否是最后一笔周期购订单
	UPDATE tmp
		SET [订阅已过期] = 'Y'
	FROM #orderdetail tmp
	JOIN (	
		SELECT [Consignee's cellphone#] ,MAX([Order Number]) AS [Order Number],MAX([Revenue Date]) AS [Revenue Date]
		FROM #orderdetail tmp 
		WHERE [当前累计配送次数]=[Length of Subsrciption, week]
		GROUP BY [Consignee's cellphone#]
		)z ON tmp.[Order Number]=z.[Order Number] AND tmp.[Revenue Date]=z.[Revenue Date]
	LEFT JOIN #orderdetail t2
		ON  z.[Consignee's cellphone#]=t2.[Consignee's cellphone#]
		AND t2.[Order Type]<>'Normal'
		AND t2.[Order Number]>z.[Order Number]   -- 期满后不存在新周期购单
	WHERE t2.[Order Number] IS NULL;

	--判断配送即将结束(倒数第二期)的订单，是否是最后一笔周期购订单
	UPDATE tmp
		SET [订阅即将过期] = 'Y'
	FROM #orderdetail tmp
	JOIN (	
		SELECT [Consignee's cellphone#] ,MAX([Order Number]) AS [Order Number],MAX([Revenue Date]) AS [Revenue Date]
		FROM #orderdetail tmp 
		WHERE [当前累计配送次数]=[Length of Subsrciption, week]-1
		GROUP BY [Consignee's cellphone#]
		)z ON tmp.[Order Number]=z.[Order Number] AND tmp.[Revenue Date]=z.[Revenue Date]
	LEFT JOIN #orderdetail t2
		ON  z.[Consignee's cellphone#]=t2.[Consignee's cellphone#]
		AND t2.[Order Type]<>'Normal'
		AND (t2.[Order Number]>z.[Order Number] OR (t2.[Order Number]=tmp.[Order Number] AND t2.[当前累计配送次数]=tmp.[Length of Subsrciption, week]))   -- 不存在新周期购单, 且不是已完结订单
	WHERE t2.[Order Number] IS NULL AND tmp.[交易成功时间] IS NULL;

	--判断是否非关闭的，未发完货的周期购订单
	UPDATE tmp
		SET tmp.[当前活跃订阅单] = 'Y'
	FROM #orderdetail tmp
	JOIN (
		SELECT [Order Number],MAX([当前累计配送次数]) AS [当前累计配送次数]
		FROM #orderdetail  
		WHERE [Order Type]<>'Normal'
		GROUP BY [Order Number]
		)t3 ON tmp.[Order Number]=t3.[Order Number] AND tmp.[Length of Subsrciption, week]>t3.[当前累计配送次数] AND tmp.[交易成功时间] IS NULL;

	--select * from #orderdetail where [Order Number]=	'E20190502121021049700037';
	--------------------------------


	--需要拆分的订单
	DROP TABLE IF EXISTS #order2split;
	SELECT [Revenue Date],[Order Number],MAX(SeqID) SeqID 
	INTO #order2split
	FROM #orderdetail 
	WHERE SeqID>1
	GROUP BY [Revenue Date],[Order Number];
	
	--拆分订单，用 [商品实际成交金额] 来 拆分 [Actual Order amount]；为了汇总金额最后一致，最后一条记录，用扣减法得出；
	UPDATE tmp
		SET tmp.[Actual Order amount] = CASE WHEN tol.[商品实际成交金额]=0 THEN 0 ELSE CAST(tmp.[Actual Order amount] * tmp.[商品实际成交金额] / tol.[商品实际成交金额] AS DECIMAL(18,2)) END
		,tmp.[商品已退款金额] = 0  
		,tmp.[运费] = 0 
	FROM #orderdetail tmp
	JOIN #order2split x  -- 需要拆分的订单
		ON tmp.[Revenue Date]=x.[Revenue Date] AND tmp.[Order Number]=x.[Order Number]
		AND tmp.SeqID <> x.SeqID  --先不计算最后一笔金额
	JOIN (
		SELECT [Revenue Date],[Order Number],SUM(商品实际成交金额) AS [商品实际成交金额]
		FROM #orderdetail
		GROUP BY [Revenue Date],[Order Number]
		) tol ON tmp.[Revenue Date]=tol.[Revenue Date] AND tmp.[Order Number]=tol.[Order Number] --该订单总金额
	
	UPDATE	tmp
		SET tmp.[Actual Order amount] = tmp.[Actual Order amount] - spl.[已分摊入账金额]
		--,tmp.[期间运费] = tmp.[Actual Order amount] - spl.[已分摊入账金额] - tmp.[期间内配送金额]
    FROM #orderdetail tmp
	JOIN #order2split x  
		ON tmp.[Revenue Date]=x.[Revenue Date] AND tmp.[Order Number]=x.[Order Number]
		AND tmp.SeqID = x.SeqID  --扣除法 计算最后一笔金额
	JOIN(
		SELECT tmp.[Revenue Date],tmp.[Order Number],SUM(tmp.[Actual Order amount]) AS [已分摊入账金额]
		FROM #orderdetail tmp
		JOIN #order2split x  
		ON tmp.[Revenue Date]=x.[Revenue Date] AND tmp.[Order Number]=x.[Order Number]
		AND tmp.SeqID <> x.SeqID
		GROUP BY tmp.[Revenue Date],tmp.[Order Number]
		) spl
		ON tmp.[Revenue Date]=spl.[Revenue Date] AND tmp.[Order Number]=spl.[Order Number]
		;

	
	UPDATE	tmp
		SET tmp.[唯一值] = NULL
    FROM #orderdetail tmp
	WHERE SeqID <> 1;
	
	UPDATE	tmp
		SET tmp.[期间运费] = cast([Actual Order amount] as decimal(18,2))-cast(isnull([期间内配送金额],0) as decimal(18,2))
    FROM #orderdetail tmp	;

	ALTER TABLE #orderdetail DROP COLUMN SeqID;

	--DROP TABLE IF EXISTS rpt.O2O_OrderRecon_Detail;
	--SELECT * 
	--	,getdate() AS [Update_Time]
 --       ,'[rpt].[SP_Youzan_Revenue_Detail_Update]' as [Update_By]
	--INTO rpt.O2O_OrderRecon_Detail FROM #orderdetail ORDER BY [Revenue Date],[Order Number],[Product Name],[SKU ID]

	----WHERE [Order Number]='E20190731123136006900015'
	--CREATE CLUSTERED index inx_O2O_OrderRecon_Detail on rpt.O2O_OrderRecon_Detail([Revenue Date],[Order Number],[Product Name],[SKU ID])
	--;
	SELECT [Revenue Date]
		  ,[Created date]
		  ,[Actual Order amount]
		  ,[SKU ID]
		  ,[Revenue_Name] AS [Revenue Name]
		  ,[Product Name]
		  ,[Qty, sales unit]
		  ,[Sales unit]
		  ,[Length of Subsrciption, week]
		  ,[Delivery time in the period per week]
		  ,[Consignee]
		  ,[Consignee's cellphone#]
		  ,[Order Type]
		  ,[KOL]
		  ,[Order Number]
		  ,[RSP per sales unit]
		  ,[Month]
		  ,[Operator]
		  ,[Order Status]
	FROM #orderdetail




END


GO
