USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC  [dm].[SP_Fct_Qulouxia_Sales_Update] 
	@Ret_Days int = 15
AS BEGIN

	DECLARE @errmsg nvarchar(max),
	@DatabaseName varchar(100) = DB_NAME(),
	@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY
	--DECLARE @Ret_Days int = 30
	DELETE dm.Fct_Qulouxia_Sales WHERE Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112) AND Datekey>='20200701'

	INSERT INTO  dm.Fct_Qulouxia_Sales    --01富友商品订单列表
	(
	 [DATEKEY]
	,[Order_no]
	,[User_ID]
	,[Store_Id]
	,[Store_Code]
	,[Store_Name]
	,[Store_Type]
	,[Payment_Method]
	,[Order_Source]
	,[Order_Channel]
	,[Is_Member_Order]
	,[Order_Amount]
	,[Order_Create_Time]
	,[Order_Status]
	,SKU_ID
	,[Goods_ID]
	,[Goods_Name]
	,[Goods_Category]
	,[Goods_Price_AMT]
	,[Goods_Cost_AMT]
	,[Sales_Qty]
	,[Sales_AMT]
	,[Discount]
	,[Discount_AMT]
	,[Service_Fee]
	,[Payment]
	,[Refund_QTY]
	,[Refund_Type]
	,[Refund_AMT]
	,[Refund_Time]
	,[Take_Out_Order_ID]
	,[Create_Time]
	,[Create_By]
	,[Update_Time]
	,[Update_By]
	)
	SELECT DISTINCT --存在数据重复的情况
		   CONVERT(VARCHAR(8),qs.[Order_Create_Time],112) AS DATEKEY
		  ,qs.[Order_no]
		  ,qs.[User_ID]
		  ,st.Store_ID
		  ,qs.[Store_Code]
		  ,qs.[Store_Name]
		  ,CASE qs.[Store_Type] WHEN '社区店' THEN	'Compound store'
			WHEN '公寓' THEN 'Appartment'
			WHEN '写字楼' THEN 'Office'
			WHEN '校园店' THEN 'School'
			WHEN '工厂' THEN 'Factory'
			WHEN '社区' THEN 'Community Store'
			WHEN '医院' THEN 'Hospital'
			ELSE 'Blank' END
		  ,qs.[Payment_Method]
		  ,CASE qs.[Order_Source] WHEN '在楼下' THEN	'ZBox'
			WHEN '饿了么' THEN	'Ele.me'
			WHEN '百度外卖'	THEN 'BaiduWaimai' 
			ELSE qs.[Order_Source] END 
		  ,qs.[Order_Channel]
		  ,qs.[Is_Member_Order]
		  ,qs.[Order_Amount]
		  ,qs.[Order_Create_Time]
		  ,qs.[Order_Status]
		  --,prod.SKU_ID
		  ,acm.SKU_ID
		  ,qs.[Goods_ID]
		  ,qs.[Goods_Name]
		  ,qs.[Goods_Category]
		  ,qs.[Goods_Price_AMT]
		  ,qs.[Goods_Cost_AMT]
		  ,qs.[Sales_Qty]
		  ,qs.[Sales_AMT]
		  ,qs.[Discount]
		  ,qs.[Discount_AMT]
		  ,qs.[Service_Fee]
		  ,qs.[Payment]
		  ,qs.[Refund_QTY]
		  ,qs.[Refund_Type]
		  ,qs.[Refund_AMT]
		  ,CAST(
		  CASE WHEN qs.[Refund_Time] LIKE '%CST%' THEN
		  RIGHT(qs.[Refund_Time],4)+'-'+ CASE SUBSTRING(qs.[Refund_Time],5,3) WHEN 'Jan' THEN '01'
																			  WHEN 'Feb' THEN '02'
																			  WHEN 'Mar' THEN '03'
																			  WHEN 'Apr' THEN '04'
																			  WHEN 'May' THEN '05'
																			  WHEN 'Jun' THEN '06'
																			  WHEN 'Jul' THEN '07'
																			  WHEN 'Aug' THEN '08'
																			  WHEN 'Sep' THEN '09'
																			  WHEN 'Oct' THEN '10'
																			  WHEN 'Nov' THEN '11'
																			  WHEN 'Dec' THEN '12'
		  END +'-'+SUBSTRING(qs.[Refund_Time],9,2)
		  ELSE qs.[Refund_Time] END AS DATE) AS [Refund_Time]
		  ,qs.[Take_Out_Order_ID]
		  ,GETDATE()
		  ,@ProcName
		  ,GETDATE()
		  ,@ProcName
		  --select count(1)
	FROM [ODS].[ods].[File_Qulouxia_Sales] qs
	LEFT JOIN [dm].[Dim_Product_AccountCodeMapping] acm ON qs.[Goods_ID] = acm.SKU_Code AND acm.Account LIKE '%ZBox%'
	--LEFT JOIN dm.Dim_Product prod ON acm.Bar_Code = Prod.Bar_Code AND CASE WHEN qs.[Goods_Name] LIKE '%小猪%' THEN 'PEPPA' WHEN qs.[Goods_Name] LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'PEPPA' END
	LEFT JOIN dm.Dim_Store st ON qs.Store_Code = st.Account_Store_Code AND st.Channel_Account = 'ZBox'
	WHERE NOT EXISTS
	(SELECT 1 FROM dm.Fct_Qulouxia_Sales dqs WHERE qs.order_no = dqs.order_no AND qs.[Goods_ID] = dqs.[Goods_ID])
	AND CONVERT(VARCHAR(8),qs.[Order_Create_Time],112)>='20200701'    --SKU ID 1183001-->1183003,1183002-->1183004 只更新7月1日之后数据   Justin 2020-07-10


-------------------------------------update dm.Fct_Qulouxia_Sales   Is_Special_Promotion 20201113---------------------------------

	update dm.Fct_Qulouxia_Sales SET dm.Fct_Qulouxia_Sales.Is_Special_Promotion = 1 
	FROM dm.Fct_Qulouxia_Sales , [dm].[Fct_Qulouxia_Cost_Distribution] 
	WHERE  dm.Fct_Qulouxia_Sales.Order_no = [dm].[Fct_Qulouxia_Cost_Distribution].Order_no 
	and [dm].[Fct_Qulouxia_Cost_Distribution].promotion_type ='优惠券' 
	and [dm].[Fct_Qulouxia_Cost_Distribution].Promotion_ID in (855,856,857,861,862,863)
	and [dm].[Fct_Qulouxia_Cost_Distribution].Promotion_Price = 0.01  ;





END TRY
BEGIN CATCH

	SELECT @errmsg =  ERROR_MESSAGE();

	EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

	RAISERROR(@errmsg,16,1);

END CATCH

END



GO
