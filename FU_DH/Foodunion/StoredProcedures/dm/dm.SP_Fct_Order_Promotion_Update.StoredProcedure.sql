USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_Order_Promotion_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dm].[SP_Fct_Order_Promotion_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY


	--DROP TABLE #orderPromotion
	SELECT * INTO #orderPromotion
	FROM (SELECT *,ROW_NUMBER() OVER(PARTITION BY [tid] ORDER BY Load_source DESC) AS RID 
		FROM ODS.ODS.[TP_Trade_Promotion]  WITH(NOLOCK)
		WHERE Load_DTM>=GETDATE()-3
		) oo
	WHERE RID = 1;


	--TRUNCATE TABLE [DM].[Fct_Order_Promotion];
	DELETE oi
	FROM [dm].[Fct_Order_Promotion] oi
	JOIN #orderPromotion i ON oi.[Promotion_ID]=i.[Promotion_ID] 
	AND i.sourcePlatformCode+ISNULL(i.[tid],'') = oi.Order_ID;

	INSERT INTO [dm].[Fct_Order_Promotion]
           ([Order_MonthKey]
           ,[Order_DateKey]
           ,[Order_ID]
		   ,[Transaction_ID]
           ,[Promotion_ID]		
           ,[Promotion_Name]
           ,[Promotion_Description]
           ,[Discount_Amount]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT 
		--TOP 10 *
		o.[Order_MonthKey] AS [Order_MonthKey],
		o.[Order_DateKey] AS [Order_DateKey],
		i.sourcePlatformCode+ISNULL(i.[tid],'') AS [Order_ID],
		i.[Transaction_ID],
		i.[promotion_id] AS [Promotion_ID],
		i.[promotion_name] AS [Promotion_Name],
		i.[promotion_desc] AS [Promotion_Description],
		i.[discountFee] AS [Discount_Amount],
		getdate(),
		@ProcName,
		getdate(),
		@ProcName
		--SELECT TOP 10 *
	FROM #orderPromotion i 
	JOIN dm.Dim_Order o WITH(NOLOCK) ON i.tid = SUBSTRING(o.Order_ID,3,100);

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
	--WHERE i.tid=237586831713768607
	--WHERE do.[Order_Number] is null
	--LEFT JOIN dm.Dim_Product p ON isnull(tc.sku_id,i.outer_sku_id)=p.sku_id;


--select order_id ,sum(Promotion_amount) from [dm].[Fct_Order_Promotion] group by order_id
--select Order_ID,payment_amount-received_amount,* from 	DM.Dim_Order
--where  order_id='TB209984543540148608'


--select * from DM.Dim_Order where ORDER_ID= 'TB'+'237586831713768607'
--select top 10 * from [dm].[Fct_Order_Item] where ORDER_ID= 'TB'+'243108103739070487'

--SELECT * FROM ODS.ODS.[TP_Promotion] where tid=371781441666282335
--select * from ODS.ODS.TP_TRADE_ITEM WHERE tid=371781441666282335
--select * from ODS.ODS.TP_TRADE_ORDER WHERE tid=371781441666282335
--select * from #orderPromotion where tid=237586831713768607
----SELECT tid FROM ODS.ODS.[TP_Promotion] group by tid having(count(Promotion_id)>1)
--select top 10 * from [dm].[Fct_Order_Item] where ORDER_ID= 'TB'+'237877869967961225'
--select top 10 * from dm.dim_order where order_id='TB'+'247106542432936203'

END
GO
