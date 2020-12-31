USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Dim_Order_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dm].[SP_Dim_Order_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY	
	--TRUNCATE TABLE [DM].[Dim_Order];
	--TRUNCATE TABLE DM.Fct_Order_Payment ;


	--TP Source 已经不用了

	--SELECT * INTO #orders
	--FROM 
	--(SELECT *,ROW_NUMBER() OVER(PARTITION BY TID ORDER BY modified DESC) AS RID 
	--	FROM ODS.ODS.[TP_Trade_Order] WITH(NOLOCK)
	--	WHERE Load_DTM>=GETDATE()-3
	--	) oo
	--WHERE oo.RID=1;

	--DECLARE @ProcName varchar(100) = '[dm].[SP_Dim_Order_Update]';

	--UPDATE do
	--SET	[Order_MonthKey] = CONVERT(VARCHAR(6),COALESCE(created,modified,paytime,'1900-1-1'),112) ,
	--	[Order_DateKey] = CONVERT(VARCHAR(8),COALESCE(created,modified,paytime,'1900-1-1'),112) ,
	--	[Order_Type_ID] = 1  , -- Online order
	--	[Super_ID] = 0  ,
	--	[Member_ID] = NULL,
	--	[Channel_ID]= ch.Channel_ID,
	--	[Platform_ID]= pf.[Platform_ID]  ,
	--	[Promotion_ID] = NULL  ,
	--	[Order_CreateTime] = o.[created] ,
	--	[Order_EndTime] = o.[end_time],
	--	[Promise_Delivery_Time] = NULL  ,
	--	[Order_Source] = CASE WHEN o.trade_from LIKE 'WAP%' THEN 'Mobile' ELSE o.trade_from END,
	--	[Order_Status] = o.trade_status ,
	--	[Is_Cancelled] = NULL,
	--	[Total_Amount] = o.total_fee,
	--	[Discount_Amount] = o.discount_fee,
	--	[Payment_Amount] = o.payment,
	--	[Received_Amount] = o.received_payment,
	--	[Item_Count] = NULL,
	--	[Total_Quantity] = NULL, 
	--	[Baoma_ID] = NULL,
	--	[Buyer_Nick] = o.buyer_nick,
	--	[Receiver_Name] = o.receiver_name,
	--	[Receiver_Mobile] = o.receiver_mobile,
	--	[Receiver_Province] = o.receiver_state,
	--	[Receiver_City] = o.receiver_city,
	--	[Receiver_Area] = o.receiver_district,
	--	[Receiver_Address] = o.receiver_address,
	--	[Receiver_Postcode] = o.receiver_zip,
	--	Update_time = getdate(),
	--	Update_by = @ProcName
	--FROM [dm].[Dim_Order] do
	--JOIN #orders o ON UPPER(sourcePlatformCode)+o.tid = do.[Order_ID]
	--LEFT JOIN DM.Dim_Platform pf ON pf.Platform_Name_CN = o.title
	--LEFT JOIN DM.Dim_Channel ch ON ch.Channel_Name_Short = CASE WHEN o.sourcePlatformCode='TB' THEN 'TM' ELSE o.sourcePlatformCode END
	--;

	--INSERT INTO [dm].[Dim_Order]
	--	([Order_MonthKey]
	--	,[Order_DateKey]
	--	,[Order_ID]
	--	,[Order_Type_ID]
	--	,[Super_ID]
	--	,[Member_ID]
	--	,[Channel_ID]
	--	,[Platform_ID]
	--	,[Promotion_ID]
	--	,[Order_CreateTime]
	--	,[Order_EndTime]
	--	,[Promise_Delivery_Time]
	--	,[Order_Source]
	--	,[Order_Status]
	--	,[Is_Cancelled]
	--	,[Total_Amount]
	--	,[Discount_Amount]
	--	,[Payment_Amount]
	--	,[Received_Amount]
	--	,[Item_Count]
	--	,[Total_Quantity]
	--	,[Baoma_ID]
	--	,[Buyer_Nick] 
	--	,[Receiver_Name]  
	--	,[Receiver_Mobile] 
	--	,[Receiver_Province]  
	--	,[Receiver_City]  
	--	,[Receiver_Area]  
	--	,[Receiver_Address]  
	--	,[Receiver_Postcode]  
	--	,[Create_Time]
	--	,[Create_By]
	--	,[Update_Time]
	--	,[Update_By])
	--SELECT 
	--	CONVERT(VARCHAR(6),COALESCE(created,modified,paytime,'1900-1-1'),112) AS [Order_MonthKey],
	--	CONVERT(VARCHAR(8),COALESCE(created,modified,paytime,'1900-1-1'),112) AS [Order_DateKey],
	--	UPPER(sourcePlatformCode)+o.tid AS [Order_ID] ,
	--	1 AS [Order_Type_ID],
	--	0 AS [Super_ID],
	--	NULL AS [Member_ID],
	--	ch.Channel_ID AS [Channel_ID],
	--	pf.[Platform_ID] AS [Platform_ID],
	--	NULL AS [Promotion_ID],
	--	o.[created] AS [Order_CreateTime],
	--	o.[end_time] as [Order_EndTime],
	--	NULL AS [Promise_Delivery_Time],
	--	CASE WHEN o.trade_from LIKE 'WAP%' THEN 'Mobile' ELSE o.trade_from END AS [Order_Source],
	--	o.trade_status AS [Order_Status],
	--	NULL AS [Is_Cancelled],
	--	o.total_fee AS [Total_Amount],
	--	o.discount_fee AS [Discount_Amount],
	--	o.payment AS [Payment_Amount],
	--	o.received_payment AS [Received_Amount],
	--	NULL AS [Item_Count],
	--	NULL AS [Total_Quantity], 
	--	NULL AS [Baoma_ID],
	--	o.buyer_nick,
	--	o.receiver_name,
	--	o.receiver_mobile,
	--	o.receiver_state,
	--	o.receiver_city,
	--	o.receiver_district,
	--	o.receiver_address,
	--	o.receiver_zip,
	--	getdate(),@ProcName,getdate(),@ProcName
	--FROM #orders o
	--LEFT JOIN [dm].[Dim_Order] do WITH(NOLOCK) ON UPPER(sourcePlatformCode)+o.tid = do.[Order_ID]
	--LEFT JOIN DM.Dim_Platform pf WITH(NOLOCK) ON pf.Platform_Name_CN = o.title
	--LEFT JOIN DM.Dim_Channel ch WITH(NOLOCK) ON ch.Channel_Name_Short = CASE WHEN o.sourcePlatformCode='TB' THEN 'TM' ELSE o.sourcePlatformCode END
	--WHERE do.[Order_ID] IS NULL
	----WHERE o.tid=237586831713768607
	----ORDER BY modified;


			
	----Payment	
	----TRUNCATE TABLE dm.Fct_Order_Payment;
	----DECLARE @ProcName varchar(100) = '[dm].[SP_Dim_Order_Update]';
	--UPDATE op
	--SET
	--	[Order_DateKey] = CONVERT(VARCHAR(8),COALESCE(o.created,o.modified,o.paytime,'1900-1-1'),112) 
	--	,[Payment_ID]   = UPPER(o.sourcePlatformCode)+isnull(o.alipay_no,o.tid+'P')
	--	--,[Order_Key]
	--	,[Order_ID] = UPPER(o.sourcePlatformCode)+o.tid
	--	,[Payment_Type] = CASE WHEN o.alipay_no IS NOT NULL THEN 'Alipay' ELSE NULL END 
	--	,[Payment_Time] = o.paytime
	--	,[Received_Time] = NULL
	--	,[Payment_Status] = NULL
	--	,[Payment_Platform] = o.sourcePlatformCode
	--	,[Payment_Account_ID] = o.alipay_ID
	--	,[Total_Amount] = o.total_fee
	--	,[Adjust_Fee] = o.adjust_fee
	--	,[Post_Fee] = o.post_fee
	--	,[Discount_Amount] = o.discount_fee
	--	,[Confirm_Amount] = o.available_confirm_fee
	--	,[Payment_Amount] = o.payment
	--	,[Received_Amount] = o.received_payment
	--	--,[Point_Awarded]
	--	,[Point_Fee] = o.point_fee
	--	,[Invoice_ID] = NULL
	--	,[Update_Time] =  getdate()
	--	,[Update_By] = @ProcName
	--FROM DM.Fct_Order_Payment op
	--JOIN #orders o ON op.[Order_ID] = UPPER(o.sourcePlatformCode)+o.tid ; --1 order 1 payment

	--INSERT INTO DM.Fct_Order_Payment
	--	(
	--	[Order_DateKey]
	--	,[Payment_ID]    
	--	--,[Order_Key]
	--	,[Order_ID]
	--	,[Payment_Type]
	--	,[Payment_Time]
	--	,[Received_Time]
	--	,[Payment_Status]
	--	,[Payment_Platform]
	--	,[Payment_Account_ID]
	--	,[Total_Amount]
	--	,[Adjust_Fee]
	--	,[Post_Fee]
	--	,[Discount_Amount]
	--	,[Confirm_Amount]
	--	,[Payment_Amount]
	--	,[Received_Amount]
	--	--,[Point_Awarded]
	--	,[Point_Fee]
	--	,[Invoice_ID]
	--	,[Create_Time]
	--	,[Create_By]
	--	,[Update_Time]
	--	,[Update_By])
	--SELECT 
	--	--CONVERT(VARCHAR(6),COALESCE(created,modified,paytime,'1900-1-1'),112) AS [Order_MonthKey],
	--	CONVERT(VARCHAR(8),COALESCE(o.created,o.modified,o.paytime,'1900-1-1'),112) AS [Order_DateKey],
	--	UPPER(o.sourcePlatformCode)+isnull(o.alipay_no,o.tid+'P') AS [Payment_ID],
	--	UPPER(o.sourcePlatformCode)+o.tid AS [Order_ID] ,
	--	CASE WHEN o.alipay_no IS NOT NULL THEN 'Alipay' ELSE NULL END  AS [Payment_Type],
	--	o.paytime AS [Payment_Time],
	--	NULL AS [Received_Time],
	--	NULL AS [Payment_Status],
	--	o.sourcePlatformCode AS [Payment_Platform],
	--	o.alipay_ID AS [Payment_Account_ID],
	--	o.total_fee AS [Total_Amount],
	--	o.adjust_fee AS [Adjust_Fee],
	--	o.post_fee AS [Post_Fee],		
	--	o.discount_fee AS [Discount_Amount],
	--	o.available_confirm_fee AS [Confirm_Amount],
	--	o.payment AS [Payment_Amount],
	--	o.received_payment AS [Received_Amount],
	--	--NULL AS [Point_Awarded],
	--	o.point_fee AS [Point_Fee],
	--	NULL AS [Invoice_ID],
	--	getdate(),@ProcName,
	--	getdate(),@ProcName
	--FROM #orders o
	--LEFT JOIN DM.Fct_Order_Payment op WITH(NOLOCK) ON op.[Order_ID] = UPPER(o.sourcePlatformCode)+o.tid 
	--WHERE op.[Payment_ID] IS NULL;


	

	UPDATE do
	SET	[Order_MonthKey] = CONVERT(VARCHAR(6),o.Order_CreateTime,112) ,
		[Order_DateKey] = CONVERT(VARCHAR(8),o.Order_CreateTime,112) ,
		[Order_Type_ID] = 1  , -- Online order
		[Super_ID] = 0  ,
		[Member_ID] = NULL,
		[Channel_ID]= ch.Channel_ID,
		[Platform_ID]= pf.[Platform_ID]  ,
		[Promotion_ID] = NULL  ,
		[Order_CreateTime] = o.Order_CreateTime ,
		Order_CloseTime = o.Order_CloseTime,
		[Order_EndTime] = NULL, --o.[end_time],	--ods.[ods].[File_Tmall_Monthly_Qianniu] 表中没有订单结束日期
		[Promise_Delivery_Time] = NULL  ,
		[Order_Source] = NULL, --CASE WHEN o.trade_from LIKE 'WAP%' THEN 'Mobile' ELSE o.trade_from END,
		[Order_Status] = o.Order_status ,
		[Is_Cancelled] = NULL,
		[Total_Amount] = o.Total_Amount,
		[Discount_Amount] =NULL,-- o.discount_fee, 	----ods.[ods].[File_Tmall_Monthly_Qianniu] 表中没有折扣信息
		[Payment_Amount] = o.Payment_Amount,
		[Received_Amount] = NULL, --o.received_payment, ----ods.[ods].[File_Tmall_Monthly_Qianniu] 表中没有received_payment
		[Item_Count] = SKU_Count,
		[Total_Quantity] = SKU_Qty, 
		[Baoma_ID] = NULL,
		[Buyer_Nick] = o.buyer_nick,
		[Receiver_Name] = o.receiver_name,
		[Receiver_Mobile] = o.receiver_mobile,
		[Receiver_Province] = NULL, --o.receiver_state,
		[Receiver_City] = NULL, --o.receiver_city,
		[Receiver_Area] = NULL, --o.receiver_district,
		[Receiver_Address] = NULL, -- o.receiver_address,
		[Receiver_Postcode] =  NULL, --o.receiver_zip,
		Update_time = getdate(),
		Update_by = OBJECT_NAME(@@PROCID)
	FROM [dm].[Dim_Order] do
	JOIN ods.[ods].[File_Tmall_Monthly_Qianniu] o ON 'TB'+o.Order_ID = do.[Order_ID]				--这张表里没有platform相关信息，就写死了
	LEFT JOIN DM.Dim_Platform pf ON pf.Platform_Name_CN = o.Store_Name
	LEFT JOIN DM.Dim_Channel ch ON ch.Channel_Name='Taobao'
	;

	INSERT INTO [dm].[Dim_Order]
		([Order_MonthKey]
		,[Order_DateKey]
		,[Order_ID]
		,[Order_Type_ID]
		,[Super_ID]
		,[Member_ID]
		,[Channel_ID]
		,[Platform_ID]
		,[Promotion_ID]
		,[Order_CreateTime]
		,Order_CloseTime
		,[Order_EndTime]
		,[Promise_Delivery_Time]
		,[Order_Source]
		,[Order_Status]
		,[Is_Cancelled]
		,[Total_Amount]
		,[Discount_Amount]
		,[Payment_Amount]
		,[Received_Amount]
		,[Item_Count]
		,[Total_Quantity]
		,[Baoma_ID]
		,[Buyer_Nick] 
		,[Receiver_Name]  
		,[Receiver_Mobile] 
		,[Receiver_Province]  
		,[Receiver_City]  
		,[Receiver_Area]  
		,[Receiver_Address]  
		,[Receiver_Postcode]  
		,[Create_Time]
		,[Create_By]
		,[Update_Time]
		,[Update_By]				)
	SELECT 
		 CONVERT(VARCHAR(6),o.Order_CreateTime,112)	AS	[Order_MonthKey]
		,CONVERT(VARCHAR(8),o.Order_CreateTime,112)	AS	[Order_DateKey]
		,'TB'+o.Order_ID									AS	[Order_ID]
		,1											AS	[Order_Type_ID]
		,0											AS	[Super_ID]
		,NULL										AS	[Member_ID]
		,ch.Channel_ID								AS	[Channel_ID]
		,pf.[Platform_ID]  							AS	[Platform_ID]
		,NULL  										AS	[Promotion_ID]
		,o.Order_CreateTime 						AS	[Order_CreateTime]
		,o.Order_CloseTime AS Order_CloseTime
		,NULL										AS	[Order_EndTime]
		,NULL  										AS	[Promise_Delivery_Time]
		,NULL 										AS	[Order_Source]
		,o.Order_status 							AS	[Order_Status]
		,NULL										AS	[Is_Cancelled]
		,o.Total_Amount								AS	[Total_Amount]
		,NULL										AS	[Discount_Amount]
		,o.Payment_Amount							AS	[Payment_Amount]
		,NULL 										AS	[Received_Amount]
		,SKU_Count									AS	[Item_Count]
		,SKU_Qty 									AS	[Total_Quantity]
		,NULL										AS	[Baoma_ID]
		,o.buyer_nick								AS	[Buyer_Nick] 
		,o.receiver_name							AS	[Receiver_Name]  
		,o.receiver_mobile							AS	[Receiver_Mobile] 
		,NULL										AS	[Receiver_Province]  
		,NULL										AS	[Receiver_City]  
		,NULL										AS	[Receiver_Area]  
		,NULL										AS	[Receiver_Address]  
		,NULL										AS	[Receiver_Postcode]  
		,getdate()									AS	[Create_Time]
		,OBJECT_NAME(@@PROCID)						AS	[Create_By]
		,getdate()									AS	[Update_Time]
		,OBJECT_NAME(@@PROCID)						AS	[Update_By]				
	FROM ods.[ods].[File_Tmall_Monthly_Qianniu] o
	LEFT JOIN [dm].[Dim_Order] do WITH(NOLOCK) ON 'TB'+o.Order_ID = do.[Order_ID]
	LEFT JOIN DM.Dim_Platform pf ON pf.Platform_Name_CN = o.Store_Name
	LEFT JOIN DM.Dim_Channel ch ON ch.Channel_Name='Taobao'
	WHERE do.[Order_ID] IS NULL
	--WHERE o.tid=237586831713768607
	--ORDER BY modified;


			
	--Payment	
	--TRUNCATE TABLE dm.Fct_Order_Payment;
	--DECLARE @ProcName varchar(100) = '[dm].[SP_Dim_Order_Update]';
	UPDATE op
	SET
		 [Order_DateKey] = CONVERT(VARCHAR(8),o.Order_CreateTime,112)
		,[Payment_ID]   = 'TB'+o.Payment_ID
		--,[Order_Key]
		,[Order_ID] = 'TB'+o.Order_ID
		,[Payment_Type] = CASE WHEN o.Alipay_AccountID IS NOT NULL THEN 'Alipay' ELSE NULL END 
		,[Payment_Time] = o.Payment_Time
		,[Received_Time] = Receive_Confirm_Time
		,[Payment_Status] = NULL
		,[Payment_Platform] = 'TB'
		,[Payment_Account_ID] = o.Alipay_AccountID
		,[Total_Amount] = o.Total_Amount
		,[Adjust_Fee] =NULL  -- o.adjust_fee
		,[Post_Fee] = o.post_fee
		,[Discount_Amount] = NULL -- o.discount_fee
		,[Confirm_Amount] = NULL -- o.available_confirm_fee
		,[Payment_Amount] = o.Payment_Amount
		,[Received_Amount] = NULL -- o.received_payment
		--,[Point_Awarded]
		,[Point_Fee] = o.point_fee
		,[Invoice_ID] = NULL
		,[Update_Time] =  getdate()
		,[Update_By] = OBJECT_NAME(@@PROCID)
	FROM DM.Fct_Order_Payment op
	JOIN ods.[ods].[File_Tmall_Monthly_Qianniu] o ON 'TB'+o.Order_ID = op.[Order_ID]	

	INSERT INTO DM.Fct_Order_Payment
		(
		 [Order_DateKey]
		,[Payment_ID]   
		,[Order_ID]
		,[Payment_Type]
		,[Payment_Time]
		,[Received_Time]
		,[Payment_Status]
		,[Payment_Platform]
		,[Payment_Account_ID]
		,[Total_Amount]
		,[Adjust_Fee]
		,[Post_Fee]
		,[Discount_Amount]
		,[Confirm_Amount]
		,[Payment_Amount]
		,[Received_Amount]
		,[Point_Fee]
		,[Invoice_ID]
		,[Create_Time]
		,[Create_By]
		,[Update_Time]
		,[Update_By])
	SELECT 
		--CONVERT(VARCHAR(6),COALESCE(created,modified,paytime,'1900-1-1'),112) AS [Order_MonthKey],
		CONVERT(VARCHAR(8),o.Order_CreateTime,112) AS [Order_DateKey],
		'TB'+o.Payment_ID AS [Payment_ID],
		'TB'+o.Order_ID AS [Order_ID] ,
		CASE WHEN o.Alipay_AccountID IS NOT NULL THEN 'Alipay' ELSE NULL END   AS [Payment_Type],
		o.Payment_Time AS [Payment_Time],
		o.Receive_Confirm_Time AS [Received_Time],
		NULL AS [Payment_Status],
		'TB' AS [Payment_Platform],
		o.Alipay_AccountID AS [Payment_Account_ID],
		o.Total_Amount AS [Total_Amount],
		NULL AS [Adjust_Fee],
		o.post_fee AS [Post_Fee],		
		NULL AS [Discount_Amount],
		NULL AS [Confirm_Amount],
		o.Payment_Amount AS [Payment_Amount],
		NULL AS [Received_Amount],
		--NULL AS [Point_Awarded],
		o.point_fee AS [Point_Fee],
		NULL AS [Invoice_ID],
		getdate(),OBJECT_NAME(@@PROCID),
		getdate(),OBJECT_NAME(@@PROCID)
	FROM ods.[ods].[File_Tmall_Monthly_Qianniu] o
	LEFT JOIN DM.Fct_Order_Payment op  ON 'TB'+o.Order_ID = op.[Order_ID]	
	WHERE op.[Payment_ID] IS NULL;




--select top 10 * from [dm].[Dim_Order]
--select top 100 * from DM.Fct_Order_Payment WHERE [Payment_Platform] LIKE 'tb'
--SELECT top 10 * FROM #orders WHERE tid='76759771806'
	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

	END
GO
