USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_Sales_SellIn_ByChannel_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE  [dm].[SP_Fct_Sales_SellIn_ByChannel_Update]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--增量抽取天数
	DECLARE @Ret_Days INT = 180;

	--Reload latest 7 days
	DELETE FROM [dm].[Fct_Sales_SellIn_ByChannel]
	WHERE Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112);
	

	INSERT INTO [dm].[Fct_Sales_SellIn_ByChannel]
           ([DateKey]
           ,[Channel_ID]
		   ,[Sale_Dept]
           ,[SKU_ID]
           ,[QTY]
		   ,[Stock_QTY]
           ,[Amount]
           ,[Discount_Amount]
           ,[Full_Amount]
           ,[Unit_Price]
           ,[Weight_KG]
           ,[Volume_L]
           ,[Status]
           ,[Create_time]
           ,[Create_By]
           ,[Update_time]
           ,[Update_By])
	SELECT 
		o.Datekey
		,ch.Channel_ID
		,o.[Sale_Dept]
		,o.SKU_ID
		--,o.Close_Status
	    ,SUM(O.Sale_Unit_QTY) Sale_Unit_QTY
		,SUM(o.Stock_QTY) AS Stock_QTY
	    --,O.BASE_UNIT
	    --,SUM(O.[Base_Unit_QTY])[Base_Unit_QTY]		
		,CASE WHEN o.Datekey>=20190301 THEN SUM(o.Amount) ELSE SUM(o.Full_Amount) END AS [Amount]   --3月之前除税，3月之后含税
		,null
		,SUM(O.Full_Amount) [Full_Amount]
		,null AS [Unit_Price]
		,SUM(o.Sale_Unit_QTY*p.Sale_Unit_Weight_KG) AS [Weight_KG]
		,SUM(o.Sale_Unit_QTY*p.Sale_Unit_Volumn_L) AS [Volume_L]
		--,CASE WHEN o.Datekey>=20190301 THEN (CASE WHEN o.Close_Status='已关闭' THEN SUM(o.Amount)/1000 ELSE 0 END)
		--	ELSE (CASE WHEN o.Close_Status='已关闭' THEN SUM(o.Full_Amount)/1000 ELSE 0 END)
		--	END AS Active_Order_Amt
		--,CASE WHEN o.Datekey>=20190301 THEN (CASE WHEN o.Close_Status='未关闭' THEN SUM(o.Amount)/1000 ELSE 0 END) 
		--	ELSE (CASE WHEN o.Close_Status='未关闭' THEN SUM(o.Full_Amount)/1000 ELSE 0 END)
		--	END AS Open_Order_AMT
		--,CASE WHEN o.Close_Status='已关闭' THEN SUM(o.Sale_Unit_QTY*p.Sale_Unit_Weight_KG)/1000 ELSE 0 END AS [Active_Order_Vol]
		--,CASE WHEN o.Close_Status='未关闭' THEN SUM(o.Sale_Unit_QTY*p.Sale_Unit_Weight_KG)/1000 ELSE 0 END AS [Open_Order_Vol]
		,o.Close_Status
		,GETDATE() [Create_time]   
		,@ProcName
		,GETDATE() [Update_time]   
		,@ProcName
	FROM (SELECT eso.Datekey,
		eso.Sale_Order_ID,
		eso.Close_Status,
		eso.[Customer_Name],
		eso.[Sale_Dept],
		oe.SKU_ID,
		oe.Sale_Unit,
		oe.Sale_Unit_QTY,
		oe.BASE_UNIT,
		oe.[Base_Unit_QTY],
		oe.Stock_Unit,
		oe.Stock_QTY,
		--eso.Customer_Name , cl.Customer_Name ,cl.IsActive,cl.Price_List_No,oe.SKU_ID , pl.SKU_ID ,
		pl.price_list_no,
		CASE WHEN ISNULL(oe.Full_Amount,0) > 0 AND eso.[Customer_Name] NOT IN ('北京京东世纪信息技术有限公司','蜜芽宝贝（天津）信息技术有限公司','苏宁红孩子','Rasa旗舰店','Lakto旗舰店','有赞商城') THEN oe.Full_Amount
			WHEN ISNULL(oe.Full_Amount,0) > 0 AND eso.[Customer_Name] IN ('北京京东世纪信息技术有限公司','蜜芽宝贝（天津）信息技术有限公司','苏宁红孩子','Rasa旗舰店','Lakto旗舰店','有赞商城') THEN oe.Full_Amount+oe.Discount_Amount		
			WHEN ISNULL(oe.Full_Amount,0) = 0 AND oe.IsFree=1 AND isnull(eso.FOC_Type,'') NOT IN ('货补费用-其他','货补费用-新品进店费') THEN 0  -- eliminate FOC fee
			ELSE pl.SKU_Base_Price*oe.Base_Unit_QTY*oe.Discount_Rate  END AS Full_Amount,--价税合计
		CASE WHEN ISNULL(oe.Amount,0) > 0 AND eso.[Customer_Name] NOT IN ('北京京东世纪信息技术有限公司','蜜芽宝贝（天津）信息技术有限公司','苏宁红孩子','Rasa旗舰店','Lakto旗舰店','有赞商城') THEN oe.Amount
			WHEN ISNULL(oe.Amount,0) > 0 AND eso.[Customer_Name] IN ('北京京东世纪信息技术有限公司','蜜芽宝贝（天津）信息技术有限公司','苏宁红孩子','Rasa旗舰店','Lakto旗舰店','有赞商城') THEN oe.Amount+oe.Discount_Amount/oe.Tax_Rate	
			WHEN ISNULL(oe.Amount,0) = 0 AND oe.IsFree=1 AND isnull(eso.FOC_Type,'') NOT IN ('货补费用-其他','货补费用-新品进店费') THEN 0  -- eliminate FOC fee
			ELSE pl.SKU_Base_Price*oe.Base_Unit_QTY*oe.Discount_Rate/oe.Tax_Rate END AS Amount--不含税合计
		FROM [dm].[Fct_ERP_Sale_Order] eso WITH(NOLOCK)
		JOIN [dm].[Fct_ERP_Sale_OrderEntry] oe WITH(NOLOCK) ON eso.Sale_Order_ID = oe.Sale_Order_ID
		--LEFT JOIN [dm].[Dim_ERP_Unit_ConvertRate] uc WITH(NOLOCK) ON uc.From_Unit = oe.Price_Unit AND uc.To_Unit = oe.Base_Unit
		LEFT JOIN [dm].[Dim_ERP_CustomerList] cl ON eso.Customer_Name = cl.Customer_Name  AND cl.IsActive = 1
		LEFT JOIN [dm].[Dim_Product_Pricelist] pl ON cl.Price_List_No = pl.Price_List_No  --Customer Price
			AND oe.SKU_ID = pl.SKU_ID 
			AND eso.Date BETWEEN pl.Effective_Date AND pl.Expiry_Date
		WHERE eso.Sale_Dept IN ('Marketing 市场部','Sales Operation 销售管理','O2O有赞','Logistics 物流') 
		--AND DATEKEY >='20191010' and eso.Customer_Name='苏果超市有限公司'
		)o  --SellIn订单详情
	LEFT JOIN dm.Dim_Product p WITH(NOLOCK) ON o.SKU_ID = p.SKU_ID
	LEFT JOIN dm.Dim_Channel_hist ch WITH(NOLOCK) ON o.[Customer_Name] = ch.ERP_Customer_Name AND LEFT(o.Datekey,6)=ch.Monthkey
	WHERE o.Datekey >= CONVERT(VARCHAR(8),GETDATE()-@Ret_Days,112)
	GROUP BY o.Datekey
		,ch.Channel_ID
		,o.[Sale_Dept]
		,o.SKU_ID
		,o.Close_Status



	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END



--select top 100 * from  [dm].[Fct_ERP_Sale_Order] 
--select top 100 * from  [dm].[Fct_ERP_Sale_Orderentry] 
--[dbo].[USP_Change_TableColumn] '[dm].[Fct_Sales_SellIn_ByChannel]','add','Sale_Dept VARCHAR(100)','Channel_ID',0
--[dbo].[USP_Change_TableColumn] '[dm].[Fct_Sales_SellIn_ByChannel]','add','Stock_QTY DECIMAL(18,9)','QTY',0
GO
