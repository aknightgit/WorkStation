USE [Foodunion]
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
	TRUNCATE TABLE [DM].[Fct_Order_Item];
	--DECLARE @pName varchar(100) = '[dm].[SP_Fct_Order_Item_Update]';

	--DELETE oi
	--FROM [dm].[Fct_Order_Item] oi 
	--JOIN [dm].[Fct_Order] fo ON oi.Order_Key=fo.Order_Key 
	--LEFT JOIN ODS.ODS.OMS_Order_goods og ON CAST(og.order_id AS VARCHAR(200)) = fo.Order_ID AND og.sub_deal_code=oi.[Transaction_No] AND og.goods_sn=oi.SKU_ID
	--WHERE og.goods_sn IS NULL
	--;

	-- UPDATE oi
	-- SET
	--		oi.SeqID = ROW_NUMBER() OVER (PARTITION BY og.order_id,og.sub_deal_code ORDER BY og.goods_sn)
 --          ,oi.[SKU_ID] = og.goods_sn
 --          ,oi.[SKU_Name_CN] = og.goods_name
 --          ,oi.[SKU_Desc] = og.outer_goods_name
 --          ,oi.[Channel_SKU_ID] = og.outer_goods_sku_id
 --          ,oi.[Shipment_No] = og.shipping_sn
 --          ,oi.[Status] = og.order_status
 --          ,oi.[Quantity] = og.goods_number
 --          ,oi.[Unit_Price] = og.shop_price   --平台售价
 --          ,oi.[Goods_Amount_Split] = og.shop_price * og.goods_number
 --          ,oi.[Post_Fee_Split] = og.share_shipping_fee
 --          --,oi.[Adjust_Fee_Split]
 --          ,oi.[Total_Amount_Split] = og.shop_price * og.goods_number+og.share_shipping_fee
 --          ,oi.[Discount_Amount_Split] = og.share_discount_fee
 --          ,oi.[Order_Amount_Split] = (og.share_price * og.goods_number +og.share_shipping_fee)
 --          ,oi.[Payment_Amount_Split] = CASE WHEN fo.Payment_Amount = 0 THEN 0 
	--						ELSE og.share_payment+og.share_shipping_fee END
 --          --,oi.[Refund_Amount_Split]
 --          --,oi.[Refund_ID]
 --          --,oi.[Refund_Status]
	--	   ,oi.[Return_Qty] = og.return_num
 --          ,oi.[Is_Gift] = og.is_gift
 --          ,oi.[Express_Code] = og.shipping_sn
 --          ,oi.[Remark] = og.remark
 --          ,oi.[Update_Time] = getdate()
 --          ,oi.[Update_By] = @ProcName
	--	   --SELECT fo.order_no,oi.Transaction_No,oi.sku_id, oi.[Payment_Amount_Split] , og.share_payment 
	--FROM [dm].[Fct_Order_Item] oi 
	--JOIN [dm].[Fct_Order] fo ON oi.Order_Key=fo.Order_Key 
	--JOIN ODS.ODS.OMS_Order_goods og ON CAST(og.order_id AS VARCHAR(200)) = fo.Order_ID AND og.sub_deal_code=oi.[Transaction_No] AND og.goods_sn=oi.SKU_ID
	----WHERE fo.order_no='19120500006271'
	--;
	
	INSERT INTO [dm].[Fct_Order_Item]
           ([Order_DateKey]
           ,[Order_Key]
           ,[Order_Cannelled]
		   ,[Transaction_No]		   
           ,[SeqID]
           ,[SKU_ID]
           ,[SKU_Name_CN]
           ,[SKU_Desc]
           ,[SKU_RSP]
           ,[Channel_SKU_ID]
           ,[Shipment_No]
           ,[Promotion_ID]
           ,[Status]
           ,[Quantity]
           ,[Unit_Price]
           ,[Goods_Amount_Split]
           ,[Post_Fee_Split]
           ,[Adjust_Fee_Split]
           ,[Total_Amount_Split]
           ,[Discount_Amount_Split]
           ,[Order_Amount_Split]
           ,[Payment_Amount_Split]
           ,[Refund_Amount_Split]
           ,[Refund_No]
           ,[Refund_Status]
		   ,[Return_Qty]
           ,[Is_Gift]
           ,[Express_Code]
           ,[Warehouse]
           ,[Remark]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
     SELECT
		fo.Order_DateKey
		,fo.Order_Key
		,fo.Is_Cancelled
		,og.sub_deal_code
		,ROW_NUMBER() OVER (PARTITION BY og.order_id,og.sub_deal_code ORDER BY og.goods_sn)
		,og.goods_sn
		,og.goods_name
		,og.outer_goods_name
		,null AS [SKU_RSP]
		,og.outer_goods_sku_id
		,og.shipping_sn
		,null AS [Promotion_ID]
		,og.order_status AS [Status]
		,og.goods_number AS [Quantity]
		,og.shop_price AS [Unit_Price]
		,og.shop_price * og.goods_number AS [Goods_Amount_Split]
		,og.share_shipping_fee AS [Post_Fee_Split]
		,NULL AS [Adjust_Fee_Split]
		,og.shop_price * og.goods_number+og.share_shipping_fee AS [Total_Amount_Split]
		,og.share_discount_fee AS [Discount_Amount_Split]
		,(og.share_price * og.goods_number +og.share_shipping_fee) AS [Order_Amount_Split]
		,CASE WHEN fo.Payment_Amount = 0 THEN 0 ELSE og.share_payment+og.share_shipping_fee END AS [Payment_Amount_Split]
		,NULL AS [Refund_Amount_Split]
		,NULL AS [Refund_ID]
		,NULL AS [Refund_Status]
		,og.return_num AS [Return_Qty]
		,og.is_gift AS [Is_Gift]
		,og.shipping_sn AS [Express_Code]
        ,og.ckj AS [Warehouse]
        ,og.remark AS [Remark]
		,getdate() AS [Create_Time]
		,@ProcName AS [Create_By]
		,getdate() AS [Update_Time]
		,@ProcName AS [Update_By]
	 FROM ODS.ODS.OMS_Order_goods og
	 JOIN [dm].[Fct_Order] fo WITH(NOLOCK) ON CAST(og.order_id AS VARCHAR(200)) = fo.Order_ID
	 LEFT JOIN [dm].[Fct_Order_Item] oi WITH(NOLOCK) ON oi.Order_Key=fo.Order_Key 
			AND og.sub_deal_code=oi.[Transaction_No] 
			AND og.goods_sn=oi.SKU_ID
	 WHERE oi.Order_Key IS NULL;

	 --SELECT * FROM [dm].[Fct_Order_Item]

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
