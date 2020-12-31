USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dm].[SP_Fct_Order_Shipment_Update]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	TRUNCATE TABLE [dm].[Fct_Order_Shipment]
	INSERT INTO [dm].[Fct_Order_Shipment]
           ([Order_DateKey]
           ,[Order_Key]
           ,[Shipment_No]
           ,[SeqID]
           ,[Is_Split]
           ,[SKU_ID]
           ,[Warehouse]
           ,[Shipment_Type]
           ,[Logistics_Code]
           ,[Logistics_Name]
           ,[Express_Code]
           ,[Shipment_Status]
           ,[Shipment_Time]
           ,[Shipment_ConfirmTime]
		   ,[Is_Sign]
           ,[Post_Fee]
           ,[Buyer_Nick]
           ,[Receiver_Name]
           ,[Receiver_Province]
           ,[Receiver_City]
           ,[Receiver_Area]
           ,[Receiver_Address]
           ,[Receiver_PostCode]
           ,[Receiver_Mobile]
           ,[Receiver_Email]
           ,[Weight]
           ,[NeedInvoice]
           ,[SourceDesc]
           ,[Remarks]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
    SELECT fo.Order_DateKey
		,fo.Order_Key
		,oi.shipping_sn AS [Shipment_No]
		,1 AS [SeqID]
		,CASE WHEN oi.split_orders IS NOT NULL THEN 1 ELSE 0 END AS [Is_Split]
		,0 as [SKU_ID]
		,CASE oi.fhck_id WHEN 4 THEN '低温北京' WHEN 3 THEN '低温上海' WHEN 2 THEN '常温上海' END AS [Warehouse]
		,oi.shipping_code AS [Shipment_Type]
		,oi.shipping_code AS [Logistics_Code]
		,oi.shipping_name AS [Logistics_Name]
		,oi.shipping_sn AS [Express_Code]
		,CASE oi.shipping_status WHEN 0 THEN '初始1-预分配缺货处理中' WHEN 2 THEN '已完成预分配' WHEN 3 THEN '已通知配货' 
				WHEN 4 THEN '拣货中(已分配拣货任务)' WHEN  5 THEN '已完成拣货' WHEN 6 THEN '已发货' WHEN 7 THEN '已出库' 
				WHEN 9 THEN '取消' END AS [Shipment_Status]
		,oi.shipping_time_fh AS [Shipment_Time]
		,oi.complete_time AS [Shipment_ConfirmTime]
		,null AS [Is_Sign]
		,oi.shipping_fee AS [Post_Fee]
		,oi.[buyers_name] AS [Buyer_Nick]
		,oi.receiver_name AS [Receiver_Name]           
		,isnull(clp.Province,oi.receiver_province) AS [Receiver_Province]
		,isnull(clc.City,oi.receiver_city) AS [Receiver_City]
		,isnull(cld.County,'') AS [Receiver_Area]
		,oi.receiver_address AS [Receiver_Address]
		,oi.receiver_zip AS [Receiver_PostCode]
		,oi.receiver_mobile AS [Receiver_Mobile]
		,oi.receiver_email AS [Receiver_Email]
		,oi.weigh AS [Weight]
		,NULL AS [NeedInvoice]
		,oi.source AS [SourceDesc]
		,oi.seller_msg AS [Remarks]
		,getdate() AS [Create_Time]
		,@ProcName AS [Create_By]
		,getdate() AS [Update_Time]
		,@ProcName AS [Update_By]
	FROM ODS.ods.OMS_Order_Info oi
	JOIN [dm].[Fct_Order] fo ON CAST(oi.order_id AS VARCHAR(200)) = fo.[Order_ID] --AND CASE WHEN oi.qd_id=1 THEN 18 ELSE 0 END = fo.[Channel_ID]
	--LEFT JOIN ODS.[ods].[OMS_Order_Logistics] ol ON oi.order_id =  ol.order_id 
	LEFT JOIN [dm].[Fct_Order_Shipment] fop ON fop.Order_Key = fo.Order_Key AND oi.shipping_sn = fop.[Shipment_No]
	LEFT JOIN  [dm].[Dim_CountyLocation] clp ON clp.CountyCode=oi.receiver_province
	LEFT JOIN  [dm].[Dim_CountyLocation] clc ON clc.CountyCode=oi.receiver_city
	LEFT JOIN  [dm].[Dim_CountyLocation] cld ON cld.CountyCode=oi.receiver_district
	WHERE fop.Order_Key IS NULL 
	AND ISNULL(oi.shipping_sn,'') <> ''
	ORDER BY oi.order_id
 	;

	UPDATE fop
	SET 
		--[Order_DateKey] = fo.Order_DateKey
		--,[Order_Key] = fo.Order_Key
		--,[Shipment_No] = oi.shipping_sn  
		--,1 AS [SeqID]
		[Is_Split] = CASE WHEN oi.split_orders IS NOT NULL THEN 1 ELSE 0 END 
		--,Null as [SKU_ID]
		,[Warehouse] = CASE oi.fhck_id WHEN 4 THEN '低温北京' WHEN 3 THEN '低温上海' WHEN 2 THEN '常温上海' END 
		,[Shipment_Type] = oi.shipping_code  
		,[Logistics_Code] = oi.shipping_code  
		,[Logistics_Name] = oi.shipping_name  
		,[Express_Code] = oi.shipping_sn  
		,[Shipment_Status] = CASE oi.shipping_status WHEN 0 THEN '初始1-预分配缺货处理中' WHEN 2 THEN '已完成预分配' WHEN 3 THEN '已通知配货' 
				WHEN 4 THEN '拣货中(已分配拣货任务)' WHEN  5 THEN '已完成拣货' WHEN 6 THEN '已发货' WHEN 7 THEN '已出库' 
				WHEN 9 THEN '取消' END  
		,[Shipment_Time] = oi.shipping_time_fh  
		,[Shipment_ConfirmTime] = oi.complete_time  
		--,[Is_Sign] = ol.is_sign  
		,[Post_Fee] = oi.shipping_fee 
		,[Buyer_Nick] = oi.[buyers_name]  
		,[Receiver_Name] = oi.receiver_name             
		,[Receiver_Province] = isnull(clp.Province,oi.receiver_province)  
		,[Receiver_City] = isnull(clc.City,oi.receiver_city)  
		,[Receiver_Area] = isnull(cld.County,'')  
		,[Receiver_Address] = oi.receiver_address  
		,[Receiver_PostCode] = oi.receiver_zip 
		,[Receiver_Mobile] = oi.receiver_mobile 
		,[Receiver_Email] = oi.receiver_email 
		,[Weight] = oi.weigh 
		--,NULL AS [NeedInvoice]
		,[SourceDesc] = oi.source 		
		,[Remarks] = oi.seller_msg 
		,[Update_Time] = getdate()  
		,[Update_By] = @ProcName  
	FROM ODS.ods.OMS_Order_Info oi
	JOIN [dm].[Fct_Order] fo ON CAST(oi.order_id AS VARCHAR(200)) = fo.[Order_ID] --AND CASE WHEN oi.qd_id=1 THEN 18 ELSE 0 END = fo.[Channel_ID]
	--LEFT JOIN ODS.[ods].[OMS_Order_Logistics] ol ON oi.order_id =  ol.order_id 
	JOIN [dm].[Fct_Order_Shipment] fop ON fop.Order_Key = fo.Order_Key AND oi.shipping_sn = fop.[Shipment_No]
	LEFT JOIN  [dm].[Dim_CountyLocation] clp ON clp.CountyCode=oi.receiver_province
	LEFT JOIN  [dm].[Dim_CountyLocation] clc ON clc.CountyCode=oi.receiver_city
	LEFT JOIN  [dm].[Dim_CountyLocation] cld ON cld.CountyCode=oi.receiver_district
	;

	

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END
GO
