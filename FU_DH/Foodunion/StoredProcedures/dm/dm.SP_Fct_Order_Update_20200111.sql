﻿USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dm].[SP_Fct_Order_Update_20200111]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY


	/*  OMS Orders */
	--TRUNCATE table  [dm].[Fct_Order]
	INSERT INTO [dm].[Fct_Order]
           ([Order_MonthKey]
           ,[Order_DateKey]
           ,[Order_ID]
		   ,[Order_No]
		   ,[Trans_No]
           ,[Order_Type_ID]
           ,[Super_ID]
           ,[Member_ID]
           ,[Channel_ID]
           ,[Platform_ID]
           ,[Promotion_ID]
           ,[Order_CreateTime]
           ,[Order_PayTime]
           ,[Order_CloseTime]
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
           ,[Update_By])

	SELECT  CONVERT(VARCHAR(6),oi.add_time,112) AS [Order_MonthKey]
		,CONVERT(VARCHAR(8),oi.add_time,112) AS [Order_DateKey]
		,oi.order_id AS [Order_ID]
		,oi.order_sn AS [Order_No]
		,oi.deal_code AS [Trans_No]
		,1 AS [Order_Type_ID]
		,0 AS [Super_ID]
		,NULL AS [Member_ID]
		,CASE WHEN oi.sd_id=5 THEN 71		--拼多多
			WHEN oi.sd_id=4 THEN 18				--Lakto旗舰店
			WHEN oi.sd_id=8 THEN 97				--拼多多（乐味可富友联合专卖店）
			WHEN oi.sd_id=9 THEN 45				--有赞微商城
			WHEN oi.sd_id in (6,7) THEN 91				--拼多多_蓝堡臻旗舰店 + 拼多多_乐味可旗舰店
			ELSE 0 END AS [Channel_ID]
		,0 AS [Platform_ID]
		,0 AS [Promotion_ID]
		,oi.add_time AS [Order_CreateTime]
		,oi.pay_time AS [Order_PayTime]
		,ISNULL(oi.complete_time,oi.zf_time) AS [Order_CloseTime]
		,NULL AS [Promise_Delivery_Time]
		,oi.source +' '+ oi.order_from AS [Order_Source]
		,CASE oi.order_status WHEN 0 THEN '未确认' WHEN 1 THEN '已确认' WHEN 3 THEN '已作废' WHEN 5 THEN '已完成' END AS [Order_Status]
		,CASE WHEN oi.zf_time IS NOT NULL THEN 1 ELSE 0 END AS [Is_Cancelled]
		,oi.total_amount AS [Total_Amount]
		,oi.discount_fee AS [Discount_Amount]
		,oi.payment AS [Payment_Amount]	--支付金额
		,oi.sj_payment AS [Received_Amount]  --实际支付
		,oi.goods_count AS [Item_Count]
		,oi.sku_count AS [Total_Quantity]
		,NULL AS [Baoma_ID]
		,oi.[user_name] AS [Buyer_Nick]
		,oi.receiver_name AS [Receiver_Name]
		,oi.receiver_mobile AS [Receiver_Mobile]
		,isnull(clp.Province,oi.receiver_province) AS [Receiver_Province]
		,isnull(clc.City,oi.receiver_city) AS [Receiver_City]
		,isnull(cld.County,'') AS [Receiver_Area]
		,oi.receiver_address AS [Receiver_Address]
		,oi.receiver_zip AS [Receiver_Postcode]
		,getdate() AS [Create_Time]
		,@ProcName AS [Create_By]
		,getdate() AS [Update_Time]
		,@ProcName AS [Update_By]
	FROM ODS.ods.OMS_Order_Info oi
	LEFT JOIN  [dm].[Dim_CountyLocation] clp ON clp.CountyCode=oi.receiver_province
	LEFT JOIN  [dm].[Dim_CountyLocation] clc ON clc.CountyCode=oi.receiver_city
	LEFT JOIN  [dm].[Dim_CountyLocation] cld ON cld.CountyCode=oi.receiver_district
	LEFT JOIN  [dm].[Fct_Order] fo ON CAST(oi.order_id AS VARCHAR(200))=fo.[Order_ID] 
		AND	CASE WHEN oi.sd_id=5 THEN 71		--拼多多
			WHEN oi.sd_id=4 THEN 18				--Lakto旗舰店
			WHEN oi.sd_id=8 THEN 97				--拼多多（乐味可富友联合专卖店）
			WHEN oi.sd_id=9 THEN 45				--有赞微商城
			WHEN oi.sd_id in (6,7) THEN 91				--拼多多_蓝堡臻旗舰店 + 拼多多_乐味可旗舰店
			ELSE 0 END = fo.[Channel_ID]
	WHERE fo.Order_ID IS NULL 
	AND oi.add_time IS NOT NULL
	ORDER BY oi.order_id
 	;

	--select * from dm.Dim_Channel where Channel_Name_Short like '%拼多多%'

	UPDATE fo
	SET 
		--CONVERT(VARCHAR(6),add_time,112)
		--,CONVERT(VARCHAR(8),add_time,112)
		--[Order_ID] = oi.order_id 
		[Order_No] = oi.order_sn
		,[Trans_No] = oi.deal_code
		--,1 AS [Order_Type_ID]
		--,0 AS [Super_ID]
		--,NULL AS [Member_ID]
		--,CASE WHEN qd_id=1 THEN 18 ELSE 0 END AS [Channel_ID]
		--,0 AS [Platform_ID]
		--,0 AS [Promotion_ID]
		,[Order_CreateTime] = add_time  
		,[Order_PayTime] = pay_time  
		,[Order_CloseTime] = ISNULL(oi.complete_time,oi.zf_time)  
		--,NULL AS [Promise_Delivery_Time]
		,[Order_Source] = oi.source +' '+ oi.order_from  
		,[Order_Status] = CASE oi.order_status WHEN 0 THEN '未确认' WHEN 1 THEN '已确认' WHEN 3 THEN '已作废' WHEN 5 THEN '已完成' END  
		,[Is_Cancelled] = CASE WHEN oi.zf_time IS NOT NULL THEN 1 ELSE 0 END
		,[Total_Amount] = oi.total_amount  
		,[Discount_Amount] = discount_fee  
		,[Payment_Amount] = payment  	--支付金额
		,[Received_Amount] = sj_payment    --实际支付
		--,NULL AS [Item_Count]
		--,NULL AS [Total_Quantity]
		--,NULL AS [Baoma_ID]
		,[Buyer_Nick] = oi.[user_name] --buyers_name  
		,[Receiver_Name] = oi.receiver_name  
		,[Receiver_Mobile] = oi.receiver_mobile  
		,[Receiver_Province] = isnull(clp.Province,oi.receiver_province)  
		,[Receiver_City] = isnull(clc.City,oi.receiver_city)  
		,[Receiver_Area] = isnull(cld.County,'')  
		,[Receiver_Address] = oi.receiver_address  
		,[Receiver_Postcode] = receiver_zip  
		,[Update_Time] = getdate()  
		,[Update_By] = @ProcName  
	FROM [dm].[Fct_Order] fo
	JOIN ODS.ods.OMS_Order_Info oi ON CAST(oi.order_id AS VARCHAR(200))=fo.[Order_id] 
		AND CASE WHEN oi.sd_id=5 THEN 71		--拼多多
			WHEN oi.sd_id=4 THEN 18				--Lakto旗舰店
			WHEN oi.sd_id=8 THEN 97				--拼多多（乐味可富友联合专卖店）
			WHEN oi.sd_id=9 THEN 45				--有赞微商城
			WHEN oi.sd_id in (6,7) THEN 91				--拼多多_蓝堡臻旗舰店 + 拼多多_乐味可旗舰店
			ELSE 0 END = fo.[Channel_ID] 
		AND fo.Order_DateKey=CONVERT(VARCHAR(8),add_time,112)
	LEFT JOIN  [dm].[Dim_CountyLocation] clp ON clp.CountyCode=oi.receiver_province
	LEFT JOIN  [dm].[Dim_CountyLocation] clc ON clc.CountyCode=oi.receiver_city
	LEFT JOIN  [dm].[Dim_CountyLocation] cld ON cld.CountyCode=oi.receiver_district


	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH


END


--select * from  [dm].[Fct_Order]
GO
