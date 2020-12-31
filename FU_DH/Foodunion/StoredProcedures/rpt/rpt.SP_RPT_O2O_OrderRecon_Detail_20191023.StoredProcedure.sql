USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_O2O_OrderRecon_Detail_20191023]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [rpt].[SP_RPT_O2O_OrderRecon_Detail_20191023]
AS
BEGIN
/*
	DROP TABLE IF EXISTS #orderdetail;
	-- 有赞对账
	SELECT 
		yr.Period AS [入账期间]
		
		,c.Month_SNM AS [月份]
		,ob.Order_Create_Time AS [订单创建时间]
		,ob.Order_Close_Time AS [交易成功时间]
		,yr.Order_No AS [订单号]
		,yr.Order_No AS [唯一值]
		,od.Product_Name AS [商品名称]
		,CASE WHEN ob.Express_Type='无需发货（虚拟商品订单）' THEN '虚拟商品'
			WHEN ob.is_cycle=1 THEN '周期购商品' ELSE '普通类型商品' END AS [商品类型]

		,CASE WHEN ob.is_cycle=0 THEN 1 WHEN ob.Order_Status <>'TRADE_CLOSED' THEN od.delivery_cnt ELSE NULL END AS [期数]
		,CASE WHEN ob.Order_Status <>'TRADE_CLOSED' THEN od.pcs_cnt * od.QTY ELSE NULL END  AS [每次数量]
		,CASE WHEN ob.is_cycle=0 THEN CAST(od.payment AS DECIMAL(18,2)) WHEN ob.Order_Status <>'TRADE_CLOSED' THEN CAST(CAST(od.payment AS DECIMAL(18,2))/od.delivery_cnt AS DECIMAL(18,2)) ELSE NULL END AS [每次金额]
		,CASE WHEN ob.is_cycle=0 THEN 1 WHEN ob.Order_Status <>'TRADE_CLOSED' THEN yr.Delivery_Cnt ELSE NULL END AS [期间内配送次数]
		,CASE WHEN ISNULL(od.SKU_ID,'') IN ('','寄生单') OR ob.Order_Status = 'TRADE_CLOSED' THEN NULL ELSE yr.Delivery_Cnt * od.pcs_cnt * od.QTY END AS [期间内配送数量]
		,CAST(yr.Income_Amount AS DECIMAL(18,2)) AS [入账金额]	
		,CASE WHEN ob.Express_Type='无需发货（虚拟商品订单）' OR ob.Order_Status = 'TRADE_CLOSED' THEN NULL
			WHEN ob.is_cycle=1 THEN CAST(CAST(od.payment AS DECIMAL(18,2))/od.delivery_cnt * yr.Delivery_Cnt AS DECIMAL(18,2)) 
			ELSE CAST(od.payment AS DECIMAL(18,2)) END AS [期间内配送金额]
		,cast(0 AS decimal(9,2)) AS [期间运费]

		,CASE WHEN ob.pay_type in ('礼品卡支付','组合支付') THEN 'Y' ELSE NULL END AS [礼品卡]
		,CASE WHEN ISNULL(od.SKU_ID,'') IN ('','寄生单') THEN yr.Order_No ELSE NULL END AS [无SKU的订单]	
		,ISNULL(ob.Shipping_Amount,0) AS [运费] --运费	
		,od.Product_ID AS [规格编码]
		,CASE WHEN ISNULL(od.SKU_ID,'寄生单') ='寄生单' THEN '间接物料' ELSE TRIM(od.SKU_ID) END AS [商品编码]
		,CAST(pl.SKU_Price AS DECIMAL(9,2)) AS [020渠道的进货价]
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
			ELSE op.KolName END AS [发货员工]
		,od.QTY * od.pcs_cnt AS [商品数量]
		,CAST(od.payment AS DECIMAL(18,2)) AS [商品实际成交金额]	
		,ISNULL(ob.Refund_Amount,0) AS [商品已退款金额]  
		,ob.Receiver_Name AS [收货人/提货人]
		,ob.Receiver_Mobile AS [收货人手机号/提货人手机号]
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
			WHEN ob.[is_cycle]+od.[delivery_cnt] > 1 AND ISNULL(od.[SKU_ID],'') NOT in ('1180004','1180003') THEN 'Subscription-Non-Fresh Milk' ELSE 'Normal' END AS [订单类型]
		,ISNULL(fx.KolName,'') AS [分销员]
		,CAST(yr.Recon_Date AS DATETIME) AS [本期首次入账日期]
		,CAST(NULL AS INT) AS [当前累计配送次数]
		,'' AS [订阅已过期]
		,'' AS [订阅即将过期]
		,ROW_NUMBER() OVER (PARTITION BY yr.Order_No ORDER BY od.Product_Name,od.SKU_ID) AS SeqID

	INTO #orderdetail
	FROM (
		SELECT Order_No
			,MIN(Recon_Date) AS Recon_Date
			,CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',1) AS DATE),112)+'-'+CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',2) AS DATE),112) AS [Period]
			--,CASE WHEN Recon_DateKey BETWEEN 20190927 and 20190930 THEN '20190927-20190930' 
			--	ELSE CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',1) AS DATE),112)+'-'+CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',2) AS DATE),112) END AS [Period]
			,COUNT(CASE WHEN Recon_Type='订单入账' THEN 1 ELSE NULL END) AS Delivery_Cnt 
			,SUM(CASE WHEN Recon_Type='订单入账' THEN Amount ELSE 0 END + CASE WHEN Recon_Type='退款' THEN Amount ELSE 0 END) AS Income_Amount
		FROM [dm].[Fct_Youzan_Recon] WITH(NOLOCK) 
		--WHERE Recon_DateKey BETWEEN 20190927 and 20190930 
		--AND Order_No='E20190929180819029900045'
		GROUP BY Order_No
			,CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',1) AS DATE),112)+'-'+CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',2) AS DATE),112)
			--,CASE WHEN Recon_DateKey BETWEEN 20190927 and 20190930 THEN '20190927-20190930' 
			--	ELSE CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',1) AS DATE),112)+'-'+CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',2) AS DATE),112) END
		)yr
	INNER JOIN [dm].[Fct_O2O_Order_Base_info] ob WITH(NOLOCK) ON yr.Order_No=ob.Order_No
	INNER JOIN [dm].[Fct_O2O_Order_Detail_info] od WITH(NOLOCK) ON ob.Order_ID=od.Order_ID
	LEFT JOIN (
		SELECT DISTINCT Year_Month,Month_EN_NM,Month_SNM
		FROM FU_EDW.Dim_Calendar
		)c ON CONVERT(VARCHAR(6),CAST(dbo.split(yr.Period,'-',1) AS DATE),112)=C.Year_Month
	LEFT JOIN [dm].[Dim_Product_Pricelist] pl ON pl.Price_List_Name='统一供价' AND pl.SKU_ID=od.SKU_ID
	LEFT JOIN [dm].[Dim_O2O_KOL] op ON ob.Operator_Employee_id=op.KOL_Employee_ID
	LEFT JOIN [dm].[Dim_O2O_KOL] fx ON ob.Fenxiao_Employee_id=fx.KOL_Employee_ID
	ORDER BY yr.Period,yr.Order_No,od.Product_Name,od.SKU_ID
	;

	--------------------------------
	--SELECT SUM(期间内配送次数) OVER(PARTITION BY [订单号] ORDER BY [入账期间]),* FROM #orderdetail WHERE 期数=13 ORDER BY [订单号],[入账期间] ;
	--更新周期购订单 截止当前配送次数
	UPDATE tmp
		SET tmp.[当前累计配送次数] = y.[当前累计配送次数]
	FROM #orderdetail tmp
	JOIN( 
		SELECT *,SUM([期间内配送次数]) OVER(PARTITION BY [订单号] ORDER BY [入账期间]) AS [当前累计配送次数] FROM (
		SELECT DISTINCT [入账期间],[订单号],[期间内配送次数]	FROM #orderdetail WHERE [商品类型]='周期购商品'
		)x )y ON tmp.[入账期间]=y.[入账期间] AND tmp.[订单号]=y.[订单号];

	--select top 10 * from #orderdetail
	--判断配送结束的订单，是否是最后一笔周期购订单
	UPDATE tmp
		SET [订阅已过期] = 'Y'
	FROM #orderdetail tmp
	JOIN (	
		SELECT [收货人手机号/提货人手机号] ,MAX([订单号]) AS [订单号],MAX([入账期间]) AS [入账期间]
		FROM #orderdetail tmp 
		WHERE [当前累计配送次数]=[期数]
		GROUP BY [收货人手机号/提货人手机号]
		)z ON tmp.[订单号]=z.[订单号] AND tmp.[入账期间]=z.[入账期间]
	LEFT JOIN #orderdetail t2
		ON  z.[收货人手机号/提货人手机号]=t2.[收货人手机号/提货人手机号]
		AND t2.[订单类型]<>'Normal'
		AND t2.[订单号]>z.[订单号]   -- 期满后不存在新周期购单
	WHERE t2.[订单号] IS NULL;

	--判断配送即将结束(倒数第二期)的订单，是否是最后一笔周期购订单
	UPDATE tmp
		SET [订阅即将过期] = 'Y'
	FROM #orderdetail tmp
	JOIN (	
		SELECT [收货人手机号/提货人手机号] ,MAX([订单号]) AS [订单号],MAX([入账期间]) AS [入账期间]
		FROM #orderdetail tmp 
		WHERE [当前累计配送次数]=[期数]-1
		GROUP BY [收货人手机号/提货人手机号]
		)z ON tmp.[订单号]=z.[订单号] AND tmp.[入账期间]=z.[入账期间]
	LEFT JOIN #orderdetail t2
		ON  z.[收货人手机号/提货人手机号]=t2.[收货人手机号/提货人手机号]
		AND t2.[订单类型]<>'Normal'
		AND (t2.[订单号]>z.[订单号] OR (t2.[订单号]=tmp.[订单号] AND t2.[当前累计配送次数]=tmp.[期数]))   -- 不存在新周期购单, 且不是已完结订单
	WHERE t2.[订单号] IS NULL;


	--select * from #orderdetail where [订单号]=	'E20190502121021049700037';
	--------------------------------


	--需要拆分的订单
	DROP TABLE IF EXISTS #order2split;
	SELECT [入账期间],[订单号],MAX(SeqID) SeqID 
	INTO #order2split
	FROM #orderdetail 
	WHERE SeqID>1
	GROUP BY [入账期间],[订单号];
	
	--拆分订单，用 [商品实际成交金额] 来 拆分 [入账金额]；为了汇总金额最后一致，最后一条记录，用扣减法得出；
	UPDATE tmp
		SET tmp.[入账金额] = CASE WHEN tol.[商品实际成交金额]=0 THEN 0 ELSE CAST(tmp.[入账金额] * tmp.[商品实际成交金额] / tol.[商品实际成交金额] AS DECIMAL(18,2)) END
		,tmp.[商品已退款金额] = 0  
		,tmp.[运费] = 0 
	FROM #orderdetail tmp
	JOIN #order2split x  -- 需要拆分的订单
		ON tmp.[入账期间]=x.[入账期间] AND tmp.[订单号]=x.[订单号]
		AND tmp.SeqID <> x.SeqID  --先不计算最后一笔金额
	JOIN (
		SELECT [入账期间],[订单号],SUM(商品实际成交金额) AS [商品实际成交金额]
		FROM #orderdetail
		GROUP BY [入账期间],[订单号]
		) tol ON tmp.[入账期间]=tol.[入账期间] AND tmp.[订单号]=tol.[订单号] --该订单总金额
	
	UPDATE	tmp
		SET tmp.[入账金额] = tmp.[入账金额] - spl.[已分摊入账金额]
		--,tmp.[期间运费] = tmp.[入账金额] - spl.[已分摊入账金额] - tmp.[期间内配送金额]
    FROM #orderdetail tmp
	JOIN #order2split x  
		ON tmp.[入账期间]=x.[入账期间] AND tmp.[订单号]=x.[订单号]
		AND tmp.SeqID = x.SeqID  --扣除法 计算最后一笔金额
	JOIN(
		SELECT tmp.[入账期间],tmp.[订单号],SUM(tmp.[入账金额]) AS [已分摊入账金额]
		FROM #orderdetail tmp
		JOIN #order2split x  
		ON tmp.[入账期间]=x.[入账期间] AND tmp.[订单号]=x.[订单号]
		AND tmp.SeqID <> x.SeqID
		GROUP BY tmp.[入账期间],tmp.[订单号]
		) spl
		ON tmp.[入账期间]=spl.[入账期间] AND tmp.[订单号]=spl.[订单号]
		;

	
	UPDATE	tmp
		SET tmp.[唯一值] = NULL
    FROM #orderdetail tmp
	WHERE SeqID <> 1;
	
	UPDATE	tmp
		SET tmp.[期间运费] = cast([入账金额] as decimal(18,2))-cast(isnull([期间内配送金额],0) as decimal(18,2))
    FROM #orderdetail tmp	;

	ALTER TABLE #orderdetail DROP COLUMN SeqID;
	SELECT * FROM #orderdetail ORDER BY [入账期间],[订单号],[商品名称],[商品编码]
	--WHERE [订单号]='E20190731123136006900015'
	;
*/

	SELECT [入账期间]
      ,[月份]
      ,[订单创建时间]
      ,[交易成功时间]
      ,[订单号]
      ,[唯一值]
      ,[商品名称]
      ,[商品类型]
      ,[期数]
      ,[每次数量]
      ,[每次金额]
      ,[期间内配送次数]
      ,[期间内配送数量]
      ,[入账金额]
      ,[期间内配送金额]
      ,[期间运费]
      ,[礼品卡]
      ,[无SKU的订单]
      ,[运费]
      ,[规格编码]
      ,[商品编码]
      ,[020渠道的进货价]
      ,[RSP*数量]
      ,[折扣]
      ,[发货仓库]
      ,[发货员工]
      ,[商品数量]
      ,[商品实际成交金额]
      ,[商品已退款金额]
      ,[收货人/提货人]
      ,[收货人手机号/提货人手机号]
      ,[详细收货地址/提货地址]
      ,[下单网点]
      ,[商家订单备注]
      ,[商品发货状态]
      ,[商品发货方式]
      ,[商品发货时间]
      ,[商品退款状态]
      ,[周期购信息]
      ,[订单类型]
      ,[分销员]
      ,[本期首次入账日期]
      ,[当前累计配送次数]
      ,[当前活跃订阅单]
      ,[订阅已过期]
      ,[订阅即将过期]
	FROM [rpt].[O2O_OrderRecon_Detail]


END

--select cast([入账金额] as decimal(9,2))-cast([期间内配送金额] as decimal(9,2)) from #orderdetail

--select cast([期间内配送金额] as decimal(9,2)) from #orderdetail
--select * from  #orderdetail order by '订单号'
-- select * from  #orderdetail  where '订单号'='E20190927140035040600071'
--select top 100 * from [dm].[Fct_Youzan_Recon] 
----where Recon_DateKey BETWEEN 20190927 and 20190930 
--order by order_no 

--SELECT CASE WHEN Recon_DateKey BETWEEN 20190927 and 20190930 THEN '20190927-20190930' 
--		ELSE CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',1) AS DATE),112)+'-'+CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',2) AS DATE),112) END AS [Period]
--	,Order_No
--	,ROW_NUMBER() OVER (PARTITION BY Order_No ORDER BY CASE WHEN ISNULL(od.SKU_ID,'寄生单') ='寄生单' THEN '' END) AS SID
--FROM [dm].[Fct_Youzan_Recon] WITH(NOLOCK) 
--WHERE Recon_Type='订单入账'
--AND Recon_DateKey BETWEEN 20190927 and 20190930 
----AND Order_No='E20190920105523098700056'
--GROUP BY Order_No
--	,CASE WHEN Recon_DateKey BETWEEN 20190927 and 20190930 THEN '20190927-20190930' 
--		ELSE CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',1) AS DATE),112)+'-'+CONVERT(VARCHAR(8),CAST(dbo.split(Period,'-',2) AS DATE),112) END


--select * from dm.Fct_O2O_Order_Base_info where order_no='E20190923142350062500004'
--select * from dm.Fct_O2O_Order_Detail_info where Order_ID='373518436619390976'
--select * from dm.Fct_Youzan_Recon where Order_No='E20190927140035040600071'

--select * from ods.ods.File_Youzan_Order_MonthlyRecon where Order_No='E20190929180819029900045'


--		运费/退款 明细 放第一条；
--		入账金额 =net
GO
