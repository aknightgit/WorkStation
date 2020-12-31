USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_Order_Item_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dm].[SP_Fct_Order_Item_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
	@DatabaseName varchar(100) = DB_NAME(),
	@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY 	
	--TRUNCATE TABLE [DM].[Fct_Order_Item];
	--DECLARE @pName varchar(100) = '[dm].[SP_Fct_Order_Item_Update]';

	--DROP TABLE #orderitems
	--SELECT * INTO #orderitems
	--FROM (SELECT *,DENSE_RANK() OVER(PARTITION BY tid ORDER BY modified DESC) AS RID 
	--	FROM ODS.ODS.[TP_Trade_Item]  WITH(NOLOCK)
	--	--WHERE Load_DTM >= GETDATE()-3
	--	) oo
	--WHERE oo.RID=1;

	
	--DELETE oi
	--FROM [dm].[Fct_Order_Item] oi
	--JOIN #orderitems i ON UPPER(i.sourcePlatformCode)+i.tid = oi.Order_ID;

	--INSERT INTO [dm].[Fct_Order_Item]
	--	([Order_Key]
 --          ,[Order_MonthKey]
 --          ,[Order_DateKey]
 --          ,[Order_ID]
 --          ,[Transaction_ID]
 --          ,[Sequence_ID]
 --          ,[SKU_ID]
 --          ,[SKU_Name_CN]
 --          ,[SKU_Desc]
 --          ,[SKU_RSP]
 --          ,[Channel_SKU_ID]
 --          ,[Brand_ID]
 --          ,[Promotion_ID]
 --          ,[Quantity]
 --          ,[Unit_Price]
 --          ,[Total_Amount]
 --          ,[Discount_Amount]
 --          ,[Payment_Amount]
 --          ,[Received_Amount]
 --          ,[Refund_Amount]
 --          ,[Refund_ID]
 --          ,[Refund_Status]
 --          ,[Status]
 --          ,[Is_Gift]
 --          ,[Create_Time]
 --          ,[Create_By]
 --          ,[Update_Time]
 --          ,[Update_By])
	--SELECT 
	--	--TOP 10 *
	--	do.[Order_Key] AS [Order_Key],
	--	do.[Order_MonthKey] AS [Order_MonthKey],
	--	do.[Order_DateKey] AS [Order_DateKey],		
	--	do.[Order_ID] AS [Order_ID],
	--	i.oid_str AS [Transaction_ID],  --  order item Sub ID
	--	row_number() over (partition by i.tid order by i.oid_str,COALESCE(tc.sku_id,i.outer_sku_id,i.outer_iid)) AS [Sequence_ID], 		
	--	COALESCE(tc.sku_id,i.outer_sku_id,i.outer_iid) AS [SKU_ID],
	--	p.SKU_Name_CN AS [SKU_Name_CN],
	--	i.sku_properties_name AS [SKU_Desc],
	--	rsp.[SKU_Price] AS [SKU_RSP],									 -- B2C RSP Price list
	--	isnull(i.outer_sku_id,i.outer_iid) AS [Channel_SKU_ID],  -- Platform Order level SKU ID
	--	b.Brand_ID AS [Brand_ID],
	--	NULL AS [Promotion_ID],
	--	ISNULL(tc.quantity,1)*i.num AS [Quantity], 
	--	--NULL [Quantity_Cancelled],
	--	i.price AS [Unit_Price]	,
	--	NULL [Total_Amount],
	--	NULL [Discount_Amount],
	--	NULL [Payment_Amount],
	--	NULL [Received_Amount],
	--	NULL [Refund_Amount],
	--	i.Refund_ID AS [Refund_ID] ,
	--	i.Refund_Status,
	--	i.[Status],
	--	CASE WHEN i.total_fee = 0 THEN 1 ELSE 0 END [Is_Gift],  --赠品
	--	getdate(),
	--	@ProcName,
	--	getdate(),
	--	@ProcName
	--	--SELECT TOP 10 *
	--FROM #orderitems i 
	--LEFT JOIN [dm].[Dim_Order] do WITH(NOLOCK) ON UPPER(i.sourcePlatformCode)+i.tid = do.[Order_ID]
	--LEFT JOIN [dm].[Dim_Order_CombineItem] tc WITH(NOLOCK) ON isnull(i.outer_sku_id,i.outer_iid) = tc.outer_sku_id 
	--		AND do.[Order_DateKey] BETWEEN Begin_Date AND End_Date
	--LEFT JOIN dm.Dim_Product p WITH(NOLOCK) ON COALESCE(tc.sku_id,i.outer_sku_id,i.outer_iid)=p.sku_id
	--LEFT JOIN dm.Dim_Brand b WITH(NOLOCK) ON p.Brand_Name=b.Brand_Name
	--LEFT JOIN [dm].[Dim_Product_Pricelist] rsp WITH(NOLOCK) ON p.SKU_ID = rsp.SKU_ID AND rsp.Is_Current=1 AND rsp.Price_List_Name=
	--	(CASE WHEN do.Order_Monthkey<= 201902 THEN 'RSP'
	--	WHEN do.Order_Monthkey = 201903 THEN 'B2C'
	--	WHEN do.Order_Monthkey >= 201904 THEN 'B2C新税率' END)
	--WHERE  isnull(i.outer_sku_id,i.outer_iid) IS NOT NULL     -- 去掉优惠券等情况：
	----and  i.tid='265315684123845888'
	--	;

	--;WITH  AMT_Split AS (
	--	SELECT DISTINCT o.[Order_ID], oi.Sequence_ID ,oi.[Quantity],oi.[SKU_RSP], 
	--			op.Total_Amount,
	--			op.Payment_Amount - op.Post_Fee AS Payment_Amount, -- 扣除运费
	--			op.Discount_Amount,
	--			CASE WHEN op.Received_Amount>0 THEN op.Received_Amount - op.Post_Fee 
	--				ELSE op.Received_Amount END AS Received_Amount, --扣除运费
	--			f.Refund_Amount
	--	FROM [dm].[Fct_Order_Item] oi WITH(NOLOCK)
	--	JOIN [dm].[Dim_Order] o WITH(NOLOCK) ON o.Order_Datekey = oi.Order_Datekey AND o.Order_ID = oi.Order_ID
	--	JOIN [dm].[Fct_Order_Payment] op WITH(NOLOCK) ON o.Order_Datekey = op.Order_Datekey AND o.Order_ID = op.Order_ID
	--	LEFT JOIN (SELECT SUM(Refund_Amount) Refund_Amount,Order_ID FROM [dm].[Fct_Order_Refund]  WITH(NOLOCK)
	--			WHERE Refund_Status = 'SUCCESS'
	--			GROUP BY Order_ID) f 
	--			ON o.Order_ID = f.Order_ID
	--	JOIN #orderitems i ON UPPER(i.sourcePlatformCode)+i.tid = oi.[Order_ID] AND oi.Transaction_ID = i.oid_str		
	--	LEFT JOIN [dm].[Fct_Order_Refund] rf WITH(NOLOCK) ON i.refund_id = rf.refund_id
	--	WHERE oi.[Is_Gift] <> 1 --AND oi.[Total_Amount] <> 0							--去除赠品分摊
	--		--AND o.Order_ID='TB265315684123845888'
	--		AND oi.[SKU_RSP]<>0															--去除特殊产品
	--		AND isnull(rf.Refund_Reason,'') NOT IN ('多拍/拍错/不想要','不喜欢/不想要')	-- 不计算退货部分
	--	)
	--,AMT_TT AS	(SELECT Order_ID,SUM(SKU_RSP*[Quantity]) GS
	--	FROM AMT_Split
	--	GROUP BY Order_ID)
	----select * from AMT_TT where gs=0
	----SELECT  s.Order_ID,s.Sequence_ID,s.[SKU_RSP],s.Total_Amount * s.[SKU_RSP]/t.GS
	--UPDATE i
	--	SET i.Total_Amount = s.Total_Amount * s.[SKU_RSP] * s.[Quantity]/ t.GS,
	--	i.Payment_Amount = s.Payment_Amount * s.[SKU_RSP] * s.[Quantity]/ t.GS,
	--	i.Discount_Amount = s.Discount_Amount * s.[SKU_RSP] * s.[Quantity]/ t.GS,
	--	i.Received_Amount = s.Received_Amount * s.[SKU_RSP] * s.[Quantity]/ t.GS,
	--	i.Refund_Amount = s.Refund_Amount * s.[SKU_RSP] * s.[Quantity]/ t.GS
	--FROM [dm].[Fct_Order_Item] i
	--JOIN AMT_Split s ON s.[Order_ID] = i.[Order_ID]  AND i.Sequence_ID = s.Sequence_ID
	--JOIN AMT_TT t ON s.[Order_ID] = t.[Order_ID]  ;


	
IF OBJECT_ID('TEMPDB..#orderitems') IS NOT NULL
BEGIN
DROP TABLE #orderitems
END
	SELECT 
		'TB'+qn.Order_ID AS Order_ID
	   ,CONVERT(VARCHAR(6),qn.Order_CreateTime,112) AS Order_MonthKey 
	   ,CONVERT(VARCHAR(8),qn.Order_CreateTime,112) AS Order_DateKey 
	   ,qn.Order_ID AS [Transaction_ID]
	   ,qn.Buyer_Nick
	   ,qn.Alipay_AccountID
	   ,qn.Payment_ID
	   ,qn.Payment_Desc
	   ,qn.Order_Status
	   ,qn.Receiver_Name
	   ,qn.Receiver_Address
	   ,qn.Shipment_Type
	   ,qn.Receiver_Mobile
	   ,qn.Order_CreateTime
	   ,qn.Payment_Time
	   ,qn.SKU_Count
	   ,cnt.RowCnt AS OrderRowCnt
	   ,qn.Store_Name
	   ,qn.Close_Reason
	   ,qn.Refund_Amount AS QN_Order_Refund_Amount
	   ,qn.Total_Amount AS QN_Order_Total_Amount
	   ,qn.Payment_Amount AS QN_Order_payment_Amount
	   ,qn.Receive_Confirm_Time
	   ,qn.Post_Fee AS QN_Order_Post_Fee
	   ,oms.Trade_ID
	   ,oms.Express_Code
	   ,oms.Order_Type
	   ,oms.Warehouse
	   ,oms.Shipment_Status
	   ,oms.Shipment_No
	   ,oms.Payment_Status
	   ,oms.Receiver_Province
	   ,oms.Receiver_City
	   ,oms.Receiver_Area
	   ,oms.SKU_ID
	   ,oms.SKU_Name_CN
	   ,oms.Scale
	   ,oms.Quantity
	   ,oms.Unit_Price
	   ,oms.Amount
	   ,oms.Is_Gift
	   ,oms.Post_Fee
	   ,oms.Remark
	   ,rsp.[SKU_Price] AS [SKU_RSP]
	   INTO #orderitems
	FROM ods.[ods].[File_Tmall_Monthly_Qianniu] qn
	INNER JOIN  ods.[ods].[File_Tmall_Monthly_OMS] oms ON qn.Order_ID=oms.Order_ID	
	LEFT JOIN (SELECT Order_ID,COUNT(1) RowCnt FROM ods.[ods].[File_Tmall_Monthly_OMS] GROUP BY Order_ID)cnt ON oms.Order_ID=cnt.Order_ID
	LEFT JOIN [dm].[Dim_Product_Pricelist] rsp WITH(NOLOCK) ON OMS.SKU_ID = rsp.SKU_ID AND rsp.Is_Current=1 AND rsp.Price_List_Name='B2C20190422'
	





--	ALTER TABLE [dm].[Fct_Order_Item] ADD WHS_ID VARCHAR(50),Receiver_Province nvarchar(50),Receiver_City nvarchar(50),Receiver_Area nvarchar(50)
	
	DELETE oi
	FROM [dm].[Fct_Order_Item] oi
	JOIN #orderitems i ON i.Order_ID = oi.Order_ID;
	

	INSERT INTO [dm].[Fct_Order_Item]
		   ([Order_Key]
           ,[Order_MonthKey]
           ,[Order_DateKey]
           ,[Order_ID]
           ,[Transaction_ID]
		   ,[Trade_ID]
		   ,Express_Code
		   ,WHS_ID
		   ,Warehouse
		   ,Shipment_No
		   ,Shipment_Status
		   ,Order_Type
		   ,Receiver_Address
		   ,Receiver_Province
		   ,Receiver_City
		   ,Receiver_Area
           ,[Sequence_ID]
           ,[SKU_ID]
           ,[SKU_Name_CN]
           ,[SKU_Desc]
           ,[SKU_RSP]
           ,[Channel_SKU_ID]
           ,[Brand_ID]
           ,[Promotion_ID]
           ,[Quantity]
           ,[Unit_Price]
           ,[Total_Amount]
		   ,[Order_Amount_Split]
           ,[Discount_Amount]
           ,[Payment_Amount]
		   ,[Payment_Amount_Split]
           ,[Received_Amount]
           ,[Refund_Amount]
		   ,[Refund_Amount_Split]
           ,[Refund_ID]
           ,[Refund_Status]
           ,[Status]
           ,[Is_Gift]
		   ,[Payment_Status]
		   ,Remark
		   ,OrderRowCnt
		   ,Buyer_Nick
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT 
		do.[Order_Key] AS [Order_Key],
		i.[Order_MonthKey] AS [Order_MonthKey],
		i.[Order_DateKey] AS [Order_DateKey],		
		i.[Order_ID] AS [Order_ID],
		i.[Transaction_ID] AS [Transaction_ID], 
		i.Trade_ID ,
	    Express_Code,
		wh.WHS_ID,
		Warehouse,
	    Shipment_No,
	    Shipment_Status,
		Order_Type,
		i.Receiver_Address,
		i.Receiver_Province,
		i.Receiver_City,
		i.Receiver_Area,
		row_number() over (partition by i.[Order_ID] order by i.SKU_ID) AS [Sequence_ID], 		
		i.SKU_ID AS [SKU_ID],
		p.SKU_Name_CN AS [SKU_Name_CN],
		i.Scale AS [SKU_Desc],
		i.[SKU_RSP] AS [SKU_RSP],									 -- B2C RSP Price list
		NULL AS [Channel_SKU_ID],  -- Platform Order level SKU ID
		NULL AS [Brand_ID],
		NULL AS [Promotion_ID],
		i.Quantity AS [Quantity], 
		--NULL [Quantity_Cancelled],
		i.Unit_Price AS [Unit_Price],
		QN_Order_Total_Amount AS [Total_Amount],
		CASE Is_Gift WHEN '否' THEN i.QN_Order_Total_Amount*i.[SKU_RSP]/i2.ORDER_GS*Quantity-i.Post_Fee*i.[SKU_RSP]/i2.ORDER_GS*Quantity END AS [Order_Amount_Split],
		NULL [Discount_Amount],
		i.QN_Order_Payment_Amount AS [Payment_Amount],
		CASE Is_Gift WHEN '否' THEN i.QN_Order_Payment_Amount*i.[SKU_RSP]/i2.ORDER_GS*Quantity-i.Post_Fee*i.[SKU_RSP]/i2.ORDER_GS*Quantity END AS [Payment_Amount_Split],
		NULL [Received_Amount],
		-1*i.QN_Order_Refund_Amount AS [Refund_Amount],
		-1*CASE Is_Gift WHEN '否' THEN i.QN_Order_Refund_Amount*i.[SKU_RSP]/i2.ORDER_GS*Quantity END AS [Refund_Amount_Split],
		NULL AS [Refund_ID] ,
		NULL AS Refund_Status,
		i.Order_Status AS [Status],
		CASE WHEN i.Is_Gift = '否' THEN 0 ELSE 1 END [Is_Gift],  --赠品
		i.Payment_Status,
		i.Remark,
		i.OrderRowCnt,
		i.Buyer_Nick,
		getdate(),
		OBJECT_NAME(@@PROCID),
		getdate(),
		OBJECT_NAME(@@PROCID)
	FROM #orderitems i 
	LEFT JOIN [dm].[Dim_Order] do WITH(NOLOCK) ON i.[Order_ID] = do.[Order_ID]
	LEFT JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON i.SKU_ID=p.sku_id
	LEFT JOIN (SELECT ORDER_ID,SUM([SKU_RSP]*Quantity) AS ORDER_GS FROM #orderitems WHERE Is_Gift = '否' GROUP BY ORDER_ID) i2 ON i.Order_ID = i2.Order_ID
	LEFT JOIN dm.dim_warehouse wh ON CASE i.Warehouse WHEN '猫武士-广州仓' THEN '猫武士广州低温仓'
													WHEN '猫武士-房山冷链仓' THEN '猫武士北京低温仓'
													WHEN '猫武士-车墩仓' THEN '猫武士上海低温仓'
													WHEN '猫武士-川沙仓' THEN '猫武士上海常温仓'
													END = wh.Warehouse_Name
	WHERE  i.SKU_ID IS NOT NULL 

	DELETE oi
	FROM [dm].[Fct_Order_Item] oi
	JOIN  ods.[ods].[File_Tmall_Monthly_OMS] oms ON oms.Trade_ID = oi.Trade_ID
	WHERE oms.Order_Type IN ('系统新建','补发订单')
	
		INSERT INTO [dm].[Fct_Order_Item]
		   (Order_Key
		   ,Order_ID
		   ,Sequence_ID
		   ,[Order_MonthKey]
           ,[Order_DateKey]
		   ,[Trade_ID]
		   ,Express_Code
		   ,WHS_ID
		   ,Warehouse
		   ,Shipment_No
		   ,Shipment_Status
		   ,Order_Type
		   ,Receiver_Address
		   ,Receiver_Province
		   ,Receiver_City
		   ,Receiver_Area
           ,[SKU_ID]
           ,[SKU_Name_CN]
           ,[SKU_RSP]
           ,[Quantity]
           ,[Status]
           ,[Is_Gift]
		   ,[Payment_Status]
		   ,Remark
		   ,Buyer_Nick
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
		SELECT
			  RIGHT(Trade_ID,12)+CAST(ROW_NUMBER() OVER(PARTITION BY Trade_ID ORDER BY Trade_ID) AS VARCHAR) AS Order_Key 
			 ,RIGHT(Trade_ID,12)+CAST(ROW_NUMBER() OVER(PARTITION BY Trade_ID ORDER BY Trade_ID) AS VARCHAR) AS Order_ID
			 ,CAST(ROW_NUMBER() OVER(PARTITION BY Trade_ID ORDER BY Trade_ID) AS VARCHAR) AS Sequence_ID
			 ,CONVERT(VARCHAR(6),oms.Order_CreateTime,112) AS Order_MonthKey 
			 ,CONVERT(VARCHAR(8),oms.Order_CreateTime,112) AS Order_DateKey 
			 ,oms.Trade_ID
			 ,oms.Express_Code
			 ,wh.WHS_ID
			 ,Warehouse
		     ,Shipment_No
		     ,Shipment_Status
			 ,Order_Type
			 ,Receiver_Address
			 ,Receiver_Province
			 ,Receiver_City
			 ,Receiver_Area
			 ,oms.SKU_ID
			 ,oms.SKU_Name_CN
			 ,rsp.[SKU_Price] AS [SKU_RSP]
			 ,Quantity
			 ,NULL AS Status
			 ,CASE WHEN oms.Is_Gift = '否' THEN 0 ELSE 1 END AS [Is_Gift]
			 ,[Payment_Status]
			 ,Remark
			 ,Buyer_Nick
			 ,getdate(),
			  OBJECT_NAME(@@PROCID),
			  getdate(),
			  OBJECT_NAME(@@PROCID)
		FROM ods.[ods].[File_Tmall_Monthly_OMS] oms	
		LEFT JOIN [dm].[Dim_Product_Pricelist] rsp WITH(NOLOCK) ON OMS.SKU_ID = rsp.SKU_ID AND rsp.Is_Current=1 AND rsp.Price_List_Name='B2C20190422'
		LEFT JOIN dm.dim_warehouse wh ON CASE oms.Warehouse WHEN '猫武士-广州仓' THEN '猫武士广州低温仓'
													WHEN '猫武士-房山冷链仓' THEN '猫武士北京低温仓'
													WHEN '猫武士-车墩仓' THEN '猫武士上海低温仓'
													WHEN '猫武士-川沙仓' THEN '猫武士上海常温仓'
													END = wh.Warehouse_Name
		WHERE oms.Order_Type IN ('系统新建','补发订单')

		

	--;WITH  AMT_Split AS (
	--	SELECT DISTINCT o.[Order_ID], oi.Sequence_ID ,oi.[Quantity],oi.[SKU_RSP], 
	--			op.Total_Amount,
	--			op.Payment_Amount - op.Post_Fee AS Payment_Amount, -- 扣除运费
	--			op.Discount_Amount,
	--			CASE WHEN op.Received_Amount>0 THEN op.Received_Amount - op.Post_Fee 
	--				ELSE op.Received_Amount END AS Received_Amount, --扣除运费
	--			f.Refund_Amount
	--	FROM [dm].[Fct_Order_Item] oi WITH(NOLOCK)
	--	JOIN [dm].[Dim_Order] o WITH(NOLOCK) ON o.Order_Datekey = oi.Order_Datekey AND o.Order_ID = oi.Order_ID
	--	JOIN [dm].[Fct_Order_Payment] op WITH(NOLOCK) ON o.Order_Datekey = op.Order_Datekey AND o.Order_ID = op.Order_ID
	--	LEFT JOIN (SELECT SUM(Refund_Amount) Refund_Amount,Order_ID FROM [dm].[Fct_Order_Refund]  WITH(NOLOCK)
	--			WHERE Refund_Status = 'SUCCESS'
	--			GROUP BY Order_ID) f 
	--			ON o.Order_ID = f.Order_ID
	--	JOIN #orderitems i ON UPPER(i.sourcePlatformCode)+i.tid = oi.[Order_ID] AND oi.Transaction_ID = i.oid_str		
	--	LEFT JOIN [dm].[Fct_Order_Refund] rf WITH(NOLOCK) ON i.refund_id = rf.refund_id
	--	WHERE oi.[Is_Gift] <> 1 --AND oi.[Total_Amount] <> 0							--去除赠品分摊
	--		--AND o.Order_ID='TB265315684123845888'
	--		AND oi.[SKU_RSP]<>0															--去除特殊产品
	--		AND isnull(rf.Refund_Reason,'') NOT IN ('多拍/拍错/不想要','不喜欢/不想要')	-- 不计算退货部分
	--	)
	--,AMT_TT AS	(SELECT Order_ID,SUM(SKU_RSP*[Quantity]) GS
	--	FROM AMT_Split
	--	GROUP BY Order_ID)
	----select * from AMT_TT where gs=0
	----SELECT  s.Order_ID,s.Sequence_ID,s.[SKU_RSP],s.Total_Amount * s.[SKU_RSP]/t.GS
	--UPDATE i
	--	SET i.Total_Amount = s.Total_Amount * s.[SKU_RSP] * s.[Quantity]/ t.GS,
	--	i.Payment_Amount = s.Payment_Amount * s.[SKU_RSP] * s.[Quantity]/ t.GS,
	--	i.Discount_Amount = s.Discount_Amount * s.[SKU_RSP] * s.[Quantity]/ t.GS,
	--	i.Received_Amount = s.Received_Amount * s.[SKU_RSP] * s.[Quantity]/ t.GS,
	--	i.Refund_Amount = s.Refund_Amount * s.[SKU_RSP] * s.[Quantity]/ t.GS
	--FROM [dm].[Fct_Order_Item] i
	--JOIN AMT_Split s ON s.[Order_ID] = i.[Order_ID]  AND i.Sequence_ID = s.Sequence_ID
	--JOIN AMT_TT t ON s.[Order_ID] = t.[Order_ID]  ;


	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
--SELECT COUNT(1) FROM [dm].[Fct_Order_Item] i
--JOIN  [dm].[Dim_Order] o ON i.Order_ID=o.Order_ID
--WHERE o.ORDER_DAtekey between 20181024 and 20181228		
--and o.Platform_ID=2
--select count(distinct order_id) from [dm].[Dim_Order] 
--select top 10 * from [dm].[Dim_Order]  where Order_ID='TB'+'265406144787055658'
--select  top 10 * from [dm].[fct_order_item]  where Order_ID='TB'+'265406144787055658'
--SELECT * FROM #orderitems where tid='265406144787055658'
--select top 10 * from ods.ods.tp_refund where refund_id=15271842322055856

--select order_id,count(refund_id) from dm.fct_order_refund group by order_id having(count(refund_id)>1)

--select sum(payment_amount),sum(received_amount),count(1)
--from  [dm].[Dim_Order] 
--where order_datekey between 20181201 and 20181228
--and Platform_ID=2
--select * from DM.Dim_Platform
--select top 10 * from [dm].[Fct_Order_Item]
--where order_id='tb258078694753198677'
--order by sequence_id desc
--SELECT TOP 10 *	FROM #orderitems i WHERE i.outer_sku_id is null
--SELECT  *	FROM #orderitems where tid='242949414794986373'
--SELECT  *	FROM ODS.stg.[TP_Trade_Item] where tid='265401824662036030'
--SELECT  *	FROM ODS.ODS.[TP_Trade_Item] where tid='265401824662036030'
--order by load_source
--SELECT * FROM ODS.ODS.[TP_Trade_Order] where alipay_no is null
--WHERE tid='280440556043464104'

--select * FROM #orderitems i 
--		LEFT JOIN [dm].[Dim_Order] do ON UPPER(i.sourcePlatformCode)+i.tid = do.[Order_ID]
--		where do.[Order_ID] is null
--SELECT * FROM #orderitems where title like '%赠品%'

END
GO
