USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [rpt].[SP_Youzan_Revenue_Detail_Update_20200225]
AS
BEGIN

	--1. 有赞对账, 来源于有赞的对账文件有两个订单号字段，优先用 Linked_Order_No 作为订单号
	--            对 Linked_Order_No 字段不在 order base表里的数据行，使用 Order_No 作为订单号
	DROP TABLE IF EXISTS #youzan;

	SELECT  Order_No
	       ,Revenue_Time
		   ,Revenue_Name
		   ,Revenue_Type
		   ,Delivery_Cnt
		   ,Income_Amount
	INTO #youzan
	FROM (
	    --Linked_Order_No 在dm.[Fct_O2O_Order_Base_info]表的字段Order_No里
		SELECT --Order_No
			 Linked_Order_No as Order_No
			,Revenue_Time
			,Revenue_Name
			,Revenue_Type
			,COUNT(CASE WHEN Revenue_Type='订单入账' THEN 1 ELSE NULL END) AS Delivery_Cnt 
			,SUM(CASE WHEN Revenue_Type='订单入账' THEN Income_Amount ELSE 0 END + CASE WHEN Revenue_Type='退款' THEN -Pay_Amount ELSE 0 END) AS Income_Amount
		FROM [dm].[Fct_Youzan_Revenue_Details] WITH(NOLOCK) 
		WHERE Linked_Order_No in (select Order_No from [dm].[Fct_O2O_Order_Base_info] where Order_No is not null)
		GROUP BY Linked_Order_No
			,Revenue_Time
			,Revenue_Name
			,Revenue_Type

		--Linked_Order_No 不在 dm.[Fct_O2O_Order_Base_info]表的字段 Order_No 里，用 Order_No
		union all
		SELECT --Order_No
			 Order_No
			,Revenue_Time
			,Revenue_Name
			,Revenue_Type
			,COUNT(CASE WHEN Revenue_Type='订单入账' THEN 1 ELSE NULL END) AS Delivery_Cnt 
			,SUM(CASE WHEN Revenue_Type='订单入账' THEN Income_Amount ELSE 0 END + CASE WHEN Revenue_Type='退款' THEN -Pay_Amount ELSE 0 END) AS Income_Amount
		FROM [dm].[Fct_Youzan_Revenue_Details] WITH(NOLOCK)
		WHERE Linked_Order_No not in (select Order_No from [dm].[Fct_O2O_Order_Base_info] where Order_No is not null)
		GROUP BY Order_No
			,Revenue_Time
			,Revenue_Name
			,Revenue_Type
        ) youzan_revenue


	-- 2.1 有赞对账与ORDER_BASE和ORDER_DEDETAIL关联，找出需要的 order 字段
	-- 2.2 对订单中有商品名没有SKU_ID的数据行，通过 手工 SKU mapping表找出 SKU_ID
	-- 2.3 找出 操作员和分销员的字段
	DROP TABLE IF EXISTS #orderdetail1;
	SELECT 
		 yr.Revenue_Time
		,yr.Revenue_Type
		,yr.Income_Amount
		,yr.Order_No
		,yr.Revenue_Name
		,c.Month_SNM

		,ob.Order_Create_Time
		,ob.Order_Close_Time
		,ob.Order_Status
		,ob.is_cycle
		,ob.Express_Type
		,ob.pay_type
		,ob.Shipping_Amount
		,ob.Order_Amount
		,ob.Refund_Amount
		,ob.Delivery_Province
		,ob.Delivery_City
		,ob.Delivery_District
		,ob.Delivery_Address
		,ob.Receiver_Name
		,ob.Receiver_Mobile
		,ob.Consign_Store
		,ob.Consign_Time
		,ob.Refund_State
		,ob.Remark

		,od.SKU_ID
		,od.Product_ID
		,od.Product_Name
		,od.SubscriptionType
		,od.delivery_cnt
		,od.pcs_cnt
		,od.QTY
		,od.payment

		,op.KolName AS OP_KOL_NAME
		,fx.KolName AS FX_KOL_NAME
		
		--显示在报表上的SKU_ID, 在不影响SKU_ID原始数据的情况下，新建MAPPING_SKU_ID专用于数据MAPPING: 
		-- (1)用来找手工补上有赞商城订单里，有商品名称，没有商品编号的数据, 
		-- (2)找到编号以后，再找 Sale_Unit 和 SKU_Price
		,IsNull(mp.manual_sku_id,
		        CASE WHEN LEFT(od.SKU_ID,1)='Y' THEN SUBSTRING(od.SKU_ID,2,LEN(od.SKU_ID)) ELSE od.SKU_ID END
			   ) AS MAPPING_SKU_ID
		,IsNull(mp.manual_sku_id,
		        CASE WHEN LEFT(od.SKU_ID,1)='Y' THEN SUBSTRING(od.SKU_ID,2,LEN(od.SKU_ID)) ELSE od.SKU_ID END
			   ) AS REPORT_SKU_ID
	INTO #orderdetail1
	FROM #youzan yr
	LEFT JOIN [dm].[Fct_O2O_Order_Base_info] ob WITH(NOLOCK) ON yr.Order_No=ob.Order_No
	LEFT JOIN [dm].[Fct_O2O_Order_Detail_info] od WITH(NOLOCK) ON ob.Order_ID=od.Order_ID
	LEFT JOIN (
		SELECT DISTINCT Monthkey as Year_Month,Month_Name as Month_EN_NM,Month_Name_Short as Month_SNM	FROM [dm].[Dim_Calendar] WITH(NOLOCK)
		)c ON CONVERT(VARCHAR(6),CAST(Revenue_Time AS DATE),112)=C.Year_Month
	LEFT JOIN (select KOL_Employee_ID,max(KolName) AS KolName from [dm].[Dim_O2O_KOL] group by KOL_Employee_ID) op ON ob.Operator_Employee_id=op.KOL_Employee_ID
	LEFT JOIN (select KOL_Employee_ID,max(KolName) AS KolName from [dm].[Dim_O2O_KOL] group by KOL_Employee_ID) fx ON ob.Fenxiao_Employee_id=fx.KOL_Employee_ID
	LEFT JOIN [dm].[Dim_SKU_Mapping_Youzan] mp
	on od.Product_Name=mp.[sku_name]
	ORDER BY yr.Revenue_Time,yr.Order_No,od.Product_Name,od.SKU_ID
	;

	--对SKU_ID=1180004*4这种编号，取星号前的字符
	update #orderdetail1
	set MAPPING_SKU_ID = LEFT(MAPPING_SKU_ID,CHARINDEX('*',MAPPING_SKU_ID)-1)
	where CHARINDEX('*',MAPPING_SKU_ID) > 0

	--对SKU_ID=1180004-1这种编号，取横线符号前的字符
	update #orderdetail1
	set MAPPING_SKU_ID = LEFT(MAPPING_SKU_ID,CHARINDEX('-',MAPPING_SKU_ID)-1)
	where CHARINDEX('-',MAPPING_SKU_ID) > 0


	DROP TABLE IF EXISTS #orderdetail;
	SELECT od.Revenue_Time AS [Revenue Date]
	      ,od.Revenue_Type as [Revenue Type]
		  ,od.Month_SNM AS [Month]
		  ,od.Order_Create_Time AS [Created date]
		  ,od.Order_Close_Time AS [交易成功时间]
		  ,od.Order_No AS [Order Number]
		  ,od.Order_No AS [唯一值]
		  ,od.Product_Name AS [Product Name]
		  ,CASE WHEN od.Express_Type='无需发货（虚拟商品订单）' THEN '虚拟商品'
			    WHEN od.is_cycle=1 THEN '周期购商品' ELSE '普通类型商品' END AS [商品类型]
		  ,prod.sale_unit as [Sales unit]
		  ,od.Order_Status AS [Order Status]
		  ,CASE WHEN od.is_cycle=0 THEN 1 WHEN od.Order_Status <>'TRADE_CLOSED' THEN od.delivery_cnt ELSE NULL END AS [Length of Subsrciption, week]
		  ,CASE WHEN od.Order_Status <>'TRADE_CLOSED' THEN od.pcs_cnt * od.QTY ELSE NULL END AS [每次数量]
		  ,CASE WHEN od.is_cycle=0 THEN CAST(od.payment AS DECIMAL(18,2)) WHEN od.Order_Status <>'TRADE_CLOSED' THEN CAST(CAST(od.payment AS DECIMAL(18,2))/od.delivery_cnt AS DECIMAL(18,2)) ELSE NULL END AS [每次金额]
		  ,CASE WHEN ISNULL(od.MAPPING_SKU_ID,'') IN ('','寄生单') OR od.Order_Status = 'TRADE_CLOSED' THEN NULL ELSE od.pcs_cnt * od.QTY END AS [Qty, sales unit]
		  ,CAST(od.Income_Amount AS DECIMAL(18,2)) AS [Actual Order amount]
          ,CASE WHEN od.Express_Type='无需发货（虚拟商品订单）' OR od.Order_Status = 'TRADE_CLOSED' THEN NULL
			    WHEN od.is_cycle=1 THEN CAST(CAST(od.payment AS DECIMAL(18,2))/od.delivery_cnt AS DECIMAL(18,2)) 
			    ELSE CAST(od.payment AS DECIMAL(18,2)) END AS [期间内配送金额]
		  ,CASE WHEN od.pay_type in ('礼品卡支付','组合支付') THEN 'Y' ELSE NULL END AS [礼品卡]
		  ,ISNULL(od.Shipping_Amount,0) AS [运费]
		  ,od.SKU_ID
		  ,CASE WHEN CHARINDEX('寄生',od.Product_Name) > 0 THEN '寄生单'
		        WHEN CHARINDEX('券包',od.Product_Name) > 0 THEN 'C999'
                ELSE od.REPORT_SKU_ID END REPORT_SKU_ID
		  ,od.Revenue_Name
		  ,CAST(pl.SKU_Price AS DECIMAL(9,2)) AS [RSP per sales unit]
		  ,CASE WHEN od.Order_Status <>'TRADE_CLOSED' THEN CAST(od.QTY * od.pcs_cnt * pl.SKU_Price AS DECIMAL(9,2)) ELSE NULL END AS [RSP*数量]
		  ,CAST(od.QTY * od.pcs_cnt * pl.SKU_Price AS DECIMAL(9,2))
			- CASE WHEN od.Express_Type='无需发货（虚拟商品订单）' OR od.Order_Status = 'TRADE_CLOSED' THEN NULL
			       WHEN od.is_cycle=1 THEN CAST(CAST(od.payment AS DECIMAL(18,2))/od.delivery_cnt AS DECIMAL(18,2)) 
			       ELSE CAST(od.payment AS DECIMAL(18,2)) END AS [折扣]	
		  ,CASE WHEN od.OP_KOL_NAME in('陈静茹') AND od.Express_Type='快递发货' THEN 'O2O在途'
			    WHEN od.OP_KOL_NAME='陈静茹' AND od.Express_Type='同城配送' THEN '待分配'
			    ELSE 'O2O.03' END AS [发货仓库]
		  ,CASE WHEN od.Consign_Store='富友中国' AND od.Remark is null THEN '陈静茹' 
			    WHEN od.Consign_Store='富友中国' AND od.Remark is NOT null THEN '待分配'
			    ELSE od.OP_KOL_NAME END AS [Operator]
		  ,od.QTY * od.pcs_cnt AS [商品数量]
		  ,CAST(od.payment AS DECIMAL(18,2)) AS [商品实际成交金额]
		  ,od.Receiver_Name AS [Consignee]
		  ,od.Receiver_Mobile AS [Consignee's cellphone#]
		  ,od.Consign_Store AS [下单网点]
		  ,od.Remark AS [商家订单备注]
		  ,CASE WHEN od.Express_Type='无需发货（虚拟商品订单）' THEN '-' ELSE '已发货' END AS [商品发货状态]
		  ,od.Express_Type AS [商品发货方式]
		  ,CASE WHEN od.[is_cycle]+od.[delivery_cnt] > 1 AND ISNULL(od.[SKU_ID],'') in ('1180004','1180003') THEN 'Subscription-Fresh Milk' 
			    WHEN od.[is_cycle]+od.[delivery_cnt] > 1 AND ISNULL(od.[SKU_ID],'') NOT in ('1180004','1180003') THEN 'Subscription-Non-Fresh Milk'
				ELSE 'Normal' END AS [Order Type]
		  ,ISNULL(od.FX_KOL_NAME,'No KOL') AS [KOL]
		  ,ROW_NUMBER() OVER (PARTITION BY od.Order_No,od.Revenue_Type ORDER BY od.Product_Name,od.MAPPING_SKU_ID) AS SeqID
		  ,CASE WHEN ISNULL(od.Order_Amount,0) <> 0 THEN 1 ELSE 0 END AS [Delivery time in the period per week]
		  ,CASE WHEN CHARINDEX('寄生',od.Product_Name) > 0 THEN 'Y' ELSE NULL END AS [是否寄生单]
	into #orderdetail
	FROM #orderdetail1 od
	LEFT JOIN [dm].[Dim_Product_Pricelist] pl ON pl.Price_List_Name='统一供价' AND od.MAPPING_SKU_ID=pl.SKU_ID
	LEFT JOIN dm.Dim_Product prod ON od.MAPPING_SKU_ID = prod.SKU_ID


	--需要拆分的订单
	DROP TABLE IF EXISTS #order2split;
	SELECT [Revenue Date],[Order Number],[Revenue Type],MAX(SeqID) SeqID 
	INTO #order2split
	FROM #orderdetail 
	WHERE SeqID>1
	GROUP BY [Revenue Date],[Order Number],[Revenue Type];
	
	--拆分订单，用 [商品实际成交金额] 来 拆分 [Actual Order amount]；为了汇总金额最后一致，最后一条记录，用扣减法得出；
	UPDATE tmp
		SET tmp.[Actual Order amount] = CASE WHEN tol.[商品实际成交金额]=0 THEN 0 ELSE CAST(tmp.[Actual Order amount] * tmp.[商品实际成交金额] / tol.[商品实际成交金额] AS DECIMAL(18,2)) END
		,tmp.[运费] = 0 
	FROM #orderdetail tmp
	JOIN #order2split x  -- 需要拆分的订单
		ON tmp.[Revenue Date]=x.[Revenue Date] AND tmp.[Order Number]=x.[Order Number] AND tmp.[Revenue Type]=x.[Revenue Type]
		AND tmp.SeqID <> x.SeqID  --先不计算最后一笔金额
	JOIN (
		SELECT [Revenue Date],[Order Number],[Revenue Type],SUM(商品实际成交金额) AS [商品实际成交金额]
		FROM #orderdetail
		GROUP BY [Revenue Date],[Order Number],[Revenue Type]
		) tol ON tmp.[Revenue Date]=tol.[Revenue Date] AND tmp.[Order Number]=tol.[Order Number] AND tmp.[Revenue Type]=tol.[Revenue Type] --该订单总金额
	
	UPDATE	tmp
		SET tmp.[Actual Order amount] = tmp.[Actual Order amount] - spl.[已分摊入账金额]
		--,tmp.[期间运费] = tmp.[Actual Order amount] - spl.[已分摊入账金额] - tmp.[期间内配送金额]
    FROM #orderdetail tmp
	JOIN #order2split x  
		ON tmp.[Revenue Date]=x.[Revenue Date] AND tmp.[Order Number]=x.[Order Number] AND tmp.[Revenue Type]=x.[Revenue Type]
		AND tmp.SeqID = x.SeqID  --扣除法 计算最后一笔金额
	JOIN(
		SELECT tmp.[Revenue Date],tmp.[Order Number],tmp.[Revenue Type],SUM(tmp.[Actual Order amount]) AS [已分摊入账金额]
		FROM #orderdetail tmp
		JOIN #order2split x  
		ON tmp.[Revenue Date]=x.[Revenue Date] AND tmp.[Order Number]=x.[Order Number] AND tmp.[Revenue Type]=x.[Revenue Type]
		AND tmp.SeqID <> x.SeqID
		GROUP BY tmp.[Revenue Date],tmp.[Order Number],tmp.[Revenue Type]
		) spl
		ON tmp.[Revenue Date]=spl.[Revenue Date] AND tmp.[Order Number]=spl.[Order Number] AND tmp.[Revenue Type]=spl.[Revenue Type]
		;



	ALTER TABLE #orderdetail DROP COLUMN SeqID;


	SELECT od.[Revenue Date]
		  ,od.[Created date]
		  ,od.[Actual Order amount]
		  --,CASE WHEN od.MAPPING_SKU_ID IN ('寄生单','C999') THEN od.MAPPING_SKU_ID ELSE IsNull(od.SKU_ID,od.MAPPING_SKU_ID) END as [SKU ID]
		  ,CASE WHEN od.REPORT_SKU_ID = '寄生单' THEN '99999999'
		        WHEN od.REPORT_SKU_ID = 'C999' THEN od.REPORT_SKU_ID
				ELSE IsNull(od.SKU_ID,od.REPORT_SKU_ID) END as [SKU ID]
		  --
		  ,od.[Revenue_Name] AS [Revenue Name]
		  ,od.[Product Name]
		  ,CASE WHEN od.[Revenue Type] = '退款' THEN NULL
		        ELSE od.[Qty, sales unit]
				END AS [Qty, sales unit]
		  ,od.[Sales unit]
		  ,od.[Length of Subsrciption, week]
		  ,od.[Delivery time in the period per week]
		  ,od.[Consignee]
		  ,od.[Consignee's cellphone#]
		  ,od.[Order Type]
		  ,od.[KOL]
		  ,od.[Order Number]
		  ,od.[RSP per sales unit]
		  ,od.[Month]
		  ,od.[Operator]
		  ,od.[Order Status]
		  --1. 在订单明细表里，有些SKU_ID为寄生单的数据，product name并不包含寄生的文字，而是同城快递或者别的描述.
		  --2. 有些SKU_ID为空的订单行，通过PRODUCT_NAME在有赞SKU MAPPING表里可以找到SKU编号=寄生单
		  ,CASE WHEN od.[是否寄生单]='Y' OR od.SKU_ID='寄生单' OR od.REPORT_SKU_ID='寄生单' THEN 'Y'
			    ELSE NULL END AS [是否寄生单]
		  ,CASE WHEN LEFT(TRIM(ISNULL(od.SKU_ID,'')),1) = 'Y' THEN 'Y' ELSE NULL END AS [是否Yellow Code]
		  ,CASE WHEN od.REPORT_SKU_ID='C999' OR od.SKU_ID='C999' THEN od.[Actual Order amount]
				ELSE NULL END AS [券包金额]
		  ,od.[礼品卡]
		  ,CASE WHEN od.[是否寄生单]='Y' OR od.SKU_ID='寄生单' OR od.REPORT_SKU_ID='寄生单' THEN od.[Actual Order amount]
				ELSE NULL END AS [寄生单金额]
		  ,od.[Revenue Type] AS [入账类别]
		  ,od.[运费] AS [显示运费]
		  ,od.[发货仓库]
		  ,od.[Operator] AS [发货员工]
		  ,od.[下单网点]
		  ,od.[商品发货方式]
		  ,od.[商品发货状态]
		  ,od.[商家订单备注]
		  ,od.[期间内配送金额]
		  ,od.[RSP*数量]
		  ,od.[折扣]
	FROM #orderdetail od




END


GO
