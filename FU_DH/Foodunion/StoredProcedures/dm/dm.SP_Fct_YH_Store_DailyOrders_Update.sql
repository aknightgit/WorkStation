USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dm].[SP_Fct_YH_Store_DailyOrders_Update]   
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	INSERT INTO [dm].[Dim_Product_AccountCodeMapping]
	([Account]
      ,[SKU_ID]
      ,[SKU_Code]
      ,[Bar_Code]
      ,[Parent_Barcode]
      ,[Split_Number]
      ,[Retail_price_group]
      ,[Retail_price_bottle]
      ,[Update_By]
      ,[Update_Time])
	SELECT 'YH' AS Account, 
	       P.SKU_ID,
		   goodsid,
		   B.bar_code,
		   B.bar_code AS Parent_Barcode,
		   NULL,
		   NULL,
		   NULL,
		   'EDI',
		   GETDATE() 
	FROM 
	  (SELECT distinct  goodsid, goodsname FROM ods.[ods].[EDI_YH_StoreOrders]) A
	  LEFT JOIN ( select distinct bar_code,goods_name from ods.ods.EDI_YH_Inventory
	  union
	  select distinct bar_code,goods_name from ods.ods.EDI_YH_Sales) B
	  ON A.goodsname=B.goods_name
	  LEFT JOIN [Foodunion].[dm].[Dim_Product] P
	  ON B.bar_code=P.Bar_Code AND P.IsEnabled=1
	  LEFT JOIN [Foodunion].[dm].[Dim_Product_AccountCodeMapping] M
	  ON goodsid=SKU_Code AND (CASE b.Bar_Code WHEN '2100001364151' THEN '6970432020898' ELSE b.Bar_Code END)=m.Bar_Code  AND M.Account='YH'
	  

  WHERE M.SKU_ID IS NULL ;

	TRUNCATE TABLE [dm].[Fct_YH_Store_DailyOrders];
	INSERT INTO [dm].[Fct_YH_Store_DailyOrders]
      ([OrderID]
      ,[SeqID]
      ,[Purchase_Datekey]
      ,[Purchase_QTY]
      ,[PO_QTY]
      ,[Apply_Datekey]
      ,[Approve_QTY]
      ,[Receipt_Datekey]
      ,[Receipt_QTY]
      ,[Store_ID]
      ,[Store_Name]
      ,[SKU_ID]
      ,[Goods_Name]
      ,[Shipment_Type]
      ,[Scale]
      ,[Unit]
      ,[EDIUpdateTime]
	  ,[Create_Time]
      ,[Create_By]
	  ,[Update_Time]
      ,[Update_By])
	SELECT  
		purdocid,
		purdocitemid,
		purdocdate,
		purchaseqty,
		purorderqty,
		applydate,
		approveqty,
		receiptdate,
		receiptqty, 
		S.Store_ID ,
		shopname, 
		P.SKU_ID ,
		goodsname,
		ordertype,
		standard,
		unitname,
		ediupdateat,
		getdate(),
		'[dm].[SP_Fct_YH_Store_DailyOrders_Update]',
		getdate(),
		'[dm].[SP_Fct_YH_Store_DailyOrders_Update]'
	FROM ods.[ods].[EDI_YH_StoreOrders] O
	LEFT JOIN [dm].[Dim_Store] AS S
		ON O.shopid=S.[Account_Store_Code] AND s.Channel_Account='YH'
	LEFT JOIN (SELECT * FROM [dm].[Dim_Product_AccountCodeMapping] WHERE Account='YH') P
		ON O.goodsid=P.SKU_Code
	WHERE O.shipmentsdate<>'-' AND O.shipmentsqty<>'0.0'  --只取物流到店数据，排查‘直送’重复数据，以及退货订单
	;


	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END

GO
