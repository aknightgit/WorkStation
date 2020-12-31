USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dm].[SP_Fct_Order_Shipment_Update_20191101]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--TRUNCATE TABLE [DM].[Fct_Order_Shipment];
	--DECLARE @pName varchar(100) = '[dm].[SP_Fct_Order_Shipment]';

	--DROP TABLE #orderShipment
	--select count(1) from #orderShipment
	SELECT DISTINCT * INTO #orderShipment
	FROM (SELECT [deliveryOrderCode]
      ,[preDeliveryOrderId]
      ,[sourceOrderCode]
      ,[itemCode]
      ,[orderFrom]
      ,[warehouseCode]
      ,[warehouseName]
      ,[orderFlag]
      ,[sourcePlatformCode]
      ,[sourcePlatformName]
      ,[createTime]
      ,[placeOrderTime]
      ,[payTime]
      ,[payNo]
      ,[operatorCode]
      ,[operatorName]
      ,[operateTime]
      ,[shopNick]
      ,[sellerNick]
      ,[buyerNick]
      ,[totalAmount]
      ,[itemAmount]
      ,[discountAmount]
      ,[freight]
      ,[arAmount]
      ,[gotAmount]
      ,[serviceFee]
      ,[logisticsCode]
      ,[logisticsName]
      ,[expressCode]
      ,[storeCode]
      ,[isUrgency]
      ,[invoiceFlag]
      ,[insuranceFlag]
      ,[buyerMessage]
      ,[remark]
      ,[company]
      ,[name]
      ,[zipCode]
      ,[mobile]
      ,[idType]
      ,[idNumber]
      ,[email]
      ,[countryCode]
      ,[province]
      ,[city]
      ,[area]
      ,[town]
      ,[detailAddress]
      ,[deliveryType],Dense_rank() OVER(PARTITION BY SourceOrderCode ORDER BY Load_source DESC) AS RID 
		FROM ODS.ODS.[TP_Shipment] WITH(NOLOCK)
		WHERE Load_DTM >= GETDATE()-3
		) oo
	WHERE RID = 1;
	
	DELETE oi
	FROM [dm].[Fct_Order_Shipment] oi
	JOIN #orderShipment i ON oi.[Shipment_No]=i.deliveryOrderCode;

	INSERT INTO [dm].[Fct_Order_Shipment]
       ([Order_DateKey]
      ,[Order_ID]
      ,[Shipment_No]
      ,[Is_Split]
      ,[Sequence_ID]
	  ,[SKU_ID]
      ,[Warehouse]
      ,[Shipment_Type]
      ,[Logistics_Code]
      ,[Logistics_Name]
      ,[Express_Code]
      ,[Shipment_Status]
      ,[Shipment_CreateTime]
      ,[Shipment_ReceiveTime]
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
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
	SELECT 
		Convert(varchar(8),s.placeOrderTime,112) AS [Order_DateKey]
		,CASE s.sourcePlatformName WHEN '淘宝' THEN 'TB' WHEN '京东' THEN 'JD' WHEN '富友微商城' THEN 'FU' END+ISNULL(sourceOrderCode,'') AS [Order_ID]
		,s.deliveryOrderCode AS [Shipment_No]
		,NULL AS [Is_Split]
		,ROW_NUMBER() OVER(PARTITION BY s.sourceOrderCode ORDER BY s.deliveryOrderCode) AS [Sequence_ID]
		,s.[itemCode] AS SKU_ID
		,s.warehouseName AS [Warehouse]
		,s.[deliveryType] AS [Shipment_Type]
		,s.logisticsCode AS [Logistics_Code]
		,s.logisticsName AS [Logistics_Name]
		,s.[expressCode] AS [Express_Code]
		,NULL AS [Shipment_Status]
		,s.createTime AS [Shipment_CreateTime]
		,NULL AS [Shipment_ReceiveTime]
		,NULL AS [Post_Fee]
		,s.[buyerNick] AS [Buyer_Nick]
		,s.name AS [Receiver_Name]
		,s.Province AS [Receiver_Province]
		,s.City AS [Receiver_City]
		,s.Area AS [Receiver_Area]
		,s.detailAddress AS [Receiver_Address]
		,s.zipCode AS [Receiver_PostCode]
		,s.mobile AS [Receiver_Mobile]
		,s.email AS [Receiver_Email]
		,NULL AS [Weight]
		,NULL AS [NeedInvoice]
		,CASE orderFrom WHEN 1 THEN '系统新建' WHEN 2 THEN '渠道同步' WHEN 3 THEN '外部导入' WHEN 4 THEN '换货订单' WHEN 5 THEN '合并订单' WHEN 6 THEN '漏发补发' WHEN 7 THEN '礼品补发' WHEN 8 THEN '其他' END AS [SourceDesc]
		,getdate()
		,@ProcName
		,getdate()
		,@ProcName
		--SELECT TOP 10 *
	FROM #orderShipment s 
	WHERE s.sourceOrderCode IS NOT NULL
	;
	--WHERE i.tid=237586831713768607
	--WHERE do.[Order_Number] is null
	--LEFT JOIN dm.Dim_Product p ON isnull(tc.sku_id,i.outer_sku_id)=p.sku_id;

	UPDATE o
	SET o.Buyer_Nick = os.buyerNick,
		o.Receiver_Name =  os.name,
		o.Receiver_Mobile = os.mobile,
		o.Receiver_Address = os.detailAddress
	FROM dm.Dim_Order o
	JOIN #orderShipment os
	ON o.Order_ID = (CASE os.sourcePlatformName WHEN '淘宝' THEN 'TB' WHEN '京东' THEN 'JD' WHEN '富友微商城' THEN 'FU' END+ISNULL(sourceOrderCode,''));

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END

--SELECT *FROM  #orderShipment
--SELECT TOP 10 *FROM ods.ods.[TP_Shipment]
--select distinct sourcePlatformName FROM ods.ods.[TP_Shipment]
--SELECT deliveryOrderCode
--FROM ODS.ODS.[TP_Shipment] 
--GROUP BY deliveryOrderCode
--HAVING(COUNT(1))>1
--SELECT *FROM ODS.ODS.[TP_Shipment] WHERE deliveryOrderCode='D0000000093781'
--SELECT TOP 100 *FROM [dm].[Fct_Order_Shipment]
--ORDER BY Create_Time DESC
GO
