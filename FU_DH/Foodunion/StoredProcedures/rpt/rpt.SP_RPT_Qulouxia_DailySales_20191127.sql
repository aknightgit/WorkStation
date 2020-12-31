USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [rpt].[SP_RPT_Qulouxia_DailySales_20191127]
AS
BEGIN


	DECLARE @MAX_DateKey VARCHAR(8) = (SELECT MAX(DATEKEY) FROM [dm].[Fct_Qulouxia_Sales])


	DROP TABLE IF EXISTS #Mapping
	SELECT cal.Date_ID
		  ,st.store_id
		  ,acm.SKU_ID
	INTO #Mapping
	FROM ODS.ods.[File_Qulouxia_Store_SKU_Mapping] skm
	LEFT JOIN [dm].[Dim_Product_AccountCodeMapping] acm ON skm.SKU_Code = acm.SKU_Code AND Account LIKE '%Qulouxia%'
	LEFT JOIN dm.Dim_Store st ON skm.Store_Code = st.Account_Store_Code AND st.Channel_Account = 'Zbox'
	CROSS JOIN FU_EDW.Dim_Calendar cal 
	where CAL.Date_ID BETWEEN skm.Begin_Date AND ISNULL(skm.End_Date,@MAX_DateKey) AND st.store_id IS NOT NULL

    --Step1: 已取消订单不计入复购标签(老客)计算
    DROP TABLE IF EXISTS #paid_order	
    select distinct						
           datekey,						
           order_no,
           user_id					    
    into #paid_order				    
    from [dm].[Fct_Qulouxia_Sales]	    
    where IsNull(order_status,'') <> '已取消'

    --Step2: 给复购客户打标签
    DROP TABLE IF EXISTS #repeat_buyer
    select datekey,
           order_no,
           user_id,
           case when count(order_no) over(partition by user_id order by datekey asc)>=2 then 1 else 0 end as repeat_buyer_flag
    into #repeat_buyer
    from #paid_order


	---------------------------------------------------------去掉行中sku payment < 1的情况
	--Exclude Special Step1: 已取消订单不计入复购标签(老客)计算
    DROP TABLE IF EXISTS #paid_order_es
    select distinct
           datekey,
           order_no,
           user_id
    into #paid_order_es
    from [dm].[Fct_Qulouxia_Sales]
    where IsNull(order_status,'') <> '已取消' AND (Payment > 1 OR Payment<0)

    --Exclude Special Step2: 给复购客户打标签
    DROP TABLE IF EXISTS #repeat_buyer_es
    select datekey,
           order_no,
           user_id,
           case when count(order_no) over(partition by user_id order by datekey asc)>=2 then 1 else 0 end as repeat_buyer_flag
    into #repeat_buyer_es
    from #paid_order_es 

    --Step3: Power BI 报表数据
    SELECT ISNULL(sales.[DATEKEY],map.Date_ID) AS [DATEKEY]
          ,sales.[Order_no]
          ,sales.[User_ID]
		  ,ISNULL(sales.Store_ID,map.Store_ID) AS Store_ID
          ,sales.[Store_Code]
          ,sales.[Store_Name]
          ,sales.[Store_Type]
          ,sales.[Payment_Method]
          ,sales.[Order_Source]
          ,sales.[Order_Channel]
          ,sales.[Is_Member_Order]
          ,sales.[Order_Amount]
          ,sales.[Order_Create_Time]
          ,sales.[Order_Status]
          ,ISNULL(sales.[SKU_ID],map.SKU_ID) AS SKU_ID
          ,sales.[Goods_ID]
          ,sales.[Goods_Name]
          ,sales.[Goods_Category]
          ,sales.[Goods_Price_AMT]
          ,sales.[Goods_Cost_AMT]
          ,sales.[Sales_Qty] / CAST(IsNull(MP.Split_Number,1) AS DECIMAL(18,2)) AS [Sales_Qty]
          ,sales.[Sales_Qty]*prod.Sale_Unit_Weight_KG / CAST(IsNull(MP.Split_Number,1) AS DECIMAL(18,2)) AS [Sales_Weight]
          ,sales.[Sales_AMT]
          ,sales.[Discount]
          ,sales.[Discount_AMT]
          ,sales.[Service_Fee]
          ,sales.[Payment]
          ,sales.[Refund_QTY] / CAST(IsNull(MP.Split_Number,1) AS DECIMAL(18,2)) AS [Refund_QTY]
          ,sales.[Refund_QTY]*prod.Sale_Unit_Weight_KG / CAST(IsNull(MP.Split_Number,1) AS DECIMAL(18,2)) AS [Refund_Weight]
          ,sales.[Refund_Type]
          ,sales.[Refund_AMT]
          ,sales.[Refund_Time]
          ,sales.[Take_Out_Order_ID]
          ,sales.[Update_Time]
          ,rb.repeat_buyer_flag
		  ,'Y' AS Include_Special_Promotion
		  ,CASE WHEN map.SKU_ID IS NOT NULL THEN 'Y' ELSE 'N' END AS 'Issales'
      FROM [dm].[Fct_Qulouxia_Sales] sales
      LEFT JOIN dm.Dim_Product prod ON sales.SKU_ID = prod.SKU_ID
      LEFT JOIN #repeat_buyer rb ON sales.[Order_no] = rb.[Order_no]
	  LEFT JOIN (SELECT SKU_ID,Split_Number FROM [dm].[Dim_Product_AccountCodeMapping]
	             WHERE  Account = 'Qulouxia (去楼下)') mp ON sales.SKU_ID = mp.SKU_ID
	  FULL OUTER JOIN #Mapping map ON sales.DATEKEY = map.Date_ID AND sales.SKU_ID = map.SKU_ID AND map.Store_ID = sales.Store_ID

	  UNION ALL
    --Exclude Special Step3: Power BI 报表数据
    SELECT sales.[DATEKEY]
          ,sales.[Order_no]
          ,sales.[User_ID]
		  ,sales.Store_ID
          ,sales.[Store_Code]
          ,sales.[Store_Name]
          ,sales.[Store_Type]
          ,sales.[Payment_Method]
          ,sales.[Order_Source]
          ,sales.[Order_Channel]
          ,sales.[Is_Member_Order]
          ,sales.[Order_Amount]
          ,sales.[Order_Create_Time]
          ,sales.[Order_Status]
          ,sales.[SKU_ID]
          ,sales.[Goods_ID]
          ,sales.[Goods_Name]
          ,sales.[Goods_Category]
          ,sales.[Goods_Price_AMT]
          ,sales.[Goods_Cost_AMT]
          ,sales.[Sales_Qty] / CAST(IsNull(MP.Split_Number,1) AS DECIMAL(18,2)) AS [Sales_Qty]
          ,sales.[Sales_Qty]*prod.Sale_Unit_Weight_KG / CAST(IsNull(MP.Split_Number,1) AS DECIMAL(18,2)) AS [Sales_Weight]
          ,sales.[Sales_AMT]
          ,sales.[Discount]
          ,sales.[Discount_AMT]
          ,sales.[Service_Fee]
          ,sales.[Payment]
          ,sales.[Refund_QTY] / CAST(IsNull(MP.Split_Number,1) AS DECIMAL(18,2)) AS [Refund_QTY]
          ,sales.[Refund_QTY]*prod.Sale_Unit_Weight_KG / CAST(IsNull(MP.Split_Number,1) AS DECIMAL(18,2)) AS [Refund_Weight]
          ,sales.[Refund_Type]
          ,sales.[Refund_AMT]
          ,sales.[Refund_Time]
          ,sales.[Take_Out_Order_ID]
          ,sales.[Update_Time]
          ,rb.repeat_buyer_flag
		  ,'N' AS Include_Special_Promotion
		  ,'N' AS Issales
      FROM [dm].[Fct_Qulouxia_Sales] sales
      LEFT JOIN dm.Dim_Product prod ON sales.SKU_ID = prod.SKU_ID
      LEFT JOIN #repeat_buyer_es rb ON sales.[Order_no] = rb.[Order_no]
	  LEFT JOIN (SELECT SKU_ID,Split_Number FROM [dm].[Dim_Product_AccountCodeMapping]
	             WHERE  Account = 'Qulouxia (去楼下)') mp ON sales.SKU_ID = mp.SKU_ID
		WHERE sales.Payment>1 OR sales.Payment<0
END

GO
