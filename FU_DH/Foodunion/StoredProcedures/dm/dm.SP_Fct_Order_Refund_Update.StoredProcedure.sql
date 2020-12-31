USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_Order_Refund_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dm].[SP_Fct_Order_Refund_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--DECLARE @pName varchar(100) = '[dm].[SP_Fct_Order_Refund]';

	--DROP TABLE #orderrefund
	SELECT * INTO #orderrefund
	FROM (SELECT *,ROW_NUMBER() OVER(PARTITION BY refund_id ORDER BY Load_source DESC) AS RID 
		FROM ODS.ODS.[TP_Refund]  WITH(NOLOCK)
		WHERE Load_DTM>=GETDATE()-3
		) oo
	WHERE RID = 1;


	--TRUNCATE TABLE [DM].[Fct_Order_Refund];
	DELETE oi
	FROM [dm].[Fct_Order_Refund] oi
	JOIN #orderrefund i ON oi.[Refund_ID]=i.[Refund_ID];

	INSERT INTO [dm].[Fct_Order_Refund]
       ([Order_MonthKey]
      ,[Order_DateKey]
	  ,[Refund_ID]  
	  ,[Order_ID]
	  ,[Transaction_ID]       --child order
	  ,[Platform_Name_CN]
      --,[SKU_ID]
      ,[Refund_Quantity]      
      ,[Refund_CreateTime]
      ,[Refund_EndTime]
      ,[Refund_Reason]
      ,[Refund_Status]
      ,[Refund_Via]
      ,[Refund_PayNo]
      ,[Refund_Amount]
      ,[Refund_Point]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
	SELECT 
		--TOP 10 *
		o.[Order_MonthKey] AS [Order_MonthKey],
		o.[Order_DateKey] AS [Order_DateKey],
		i.Refund_ID AS [Refund_ID],
		o.order_id AS [Order_ID],
		oi.[Transaction_ID] AS [Transaction_ID],	
		i.seller_nick AS [Platform_Name_CN],
		--oi.Channel_SKU_ID AS [SKU_ID],
		NULL AS [Refund_Quantity],
		[created] AS [Refund_CreateTime],
		NULL AS [Refund_EndTime],
		i.reason AS [Refund_Reason],
		i.status AS [Refund_Status],
		'AliPay' AS [Refund_Via],
		i.alipay_no AS [Refund_PayNo],
		i.refund_fee AS [Refund_Amount],
		NULL AS [Refund_Point],
		getdate(),
		@ProcName,
		getdate(),
		@ProcName
		--SELECT TOP 10 *
	FROM #orderrefund i 
	JOIN DM.Dim_Order o WITH(NOLOCK) ON i.tid = SUBSTRING(o.Order_ID,3,100)
	JOIN (SELECT MAX(oid_str) Transaction_ID, Refund_ID 
		FROM ODS.ODS.[TP_Trade_Item] WITH(NOLOCK)  WHERE Refund_ID IS NOT NULL GROUP BY Refund_ID) oi 
		ON i.Refund_ID = oi.Refund_ID;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
	--WHERE i.tid=237586831713768607
	--WHERE do.[Order_Number] is null
	--LEFT JOIN dm.Dim_Product p ON isnull(tc.sku_id,i.outer_sku_id)=p.sku_id;


--select order_id ,sum(refund_amount) from [dm].[Fct_Order_Refund] group by order_id
--select Order_ID,payment_amount-received_amount,* from 	DM.Dim_Order
--where  order_id='TB209984543540148608'


--select * from DM.Dim_Order where ORDER_ID= 'TB'+'237586831713768607'
--select top 10 * from [dm].[Fct_Order_Item] where ORDER_ID= 'TB'+'243108103739070487'

--SELECT * FROM ODS.ODS.[TP_Refund] where tid=371781441666282335
--select * from ODS.ODS.TP_TRADE_ITEM WHERE tid=371781441666282335
--select * from ODS.ODS.TP_TRADE_ORDER WHERE tid=371781441666282335
--select * from #orderrefund where tid=237586831713768607
----SELECT tid FROM ODS.ODS.[TP_Refund] group by tid having(count(refund_id)>1)
--select top 10 * from [dm].[Fct_Order_Item] where ORDER_ID= 'TB'+'237877869967961225'
--select top 10 * from dm.dim_order where order_id='TB'+'247106542432936203'

END
GO
