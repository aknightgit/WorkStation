USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_ERP_Sales_Order_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC  [rpt].[SP_ERP_Sales_Order_Update]
AS
BEGIN

  	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY	

	TRUNCATE TABLE rpt.ERP_SALES_ORDER;
	INSERT INTO rpt.ERP_SALES_ORDER
	(
	[Datekey]
      ,[On_Off_Line]
      ,[Channel]
      ,[Customer_Name]
      ,[Account]
      ,[Handler]
      ,[Channel_Handler]
	  ,Close_Status
      ,[SKU_ID]
	  ,Sale_Unit
	  ,Sale_Unit_QTY
	  ,BASE_UNIT
	  ,[Base_Unit_QTY]
      ,Full_Amount
      ,[Actual_AMT]
      ,[Actual_VOL]
      ,[Active_Order_Amt]
      ,[Open_Order_AMT]
      ,[Active_Order_Vol]
      ,[Open_Order_Vol]
      ,[UPDATE_DTM]
	)
	
	SELECT o.Datekey
		,coalesce(am1.[Channel],'Unknown') AS [On_Off_Line]
		,coalesce(am1.Region,'Unknown') AS [Channel]
		,o.Customer_Name
		,coalesce(am1.Account_Display_Name,'Unknown') AS Account
		,coalesce(am1.Handler,'Unknown') AS [Handler]
		,ISNULL(ecm.[Channel_Handler] ,'Unknown') AS [Channel_Handler]
		,O.Close_Status
		,O.SKU_ID
		,O.Sale_Unit
	    ,SUM(O.Sale_Unit_QTY)Sale_Unit_QTY
	    ,O.BASE_UNIT
	    ,SUM(O.[Base_Unit_QTY])[Base_Unit_QTY]
		,SUM(O.Full_Amount)/1000 Full_Amount
		,CASE WHEN o.Datekey>=20190301 THEN SUM(o.Amount)/1000 ELSE SUM(o.Full_Amount)/1000 END AS Actual_AMT
		,SUM(o.Sale_Unit_QTY*p.Sale_Unit_Weight_KG)/1000 AS [Actual_VOL]
		,CASE WHEN o.Datekey>=20190301 THEN (CASE WHEN o.Close_Status='已关闭' THEN SUM(o.Amount)/1000 ELSE 0 END)
			ELSE (CASE WHEN o.Close_Status='已关闭' THEN SUM(o.Full_Amount)/1000 ELSE 0 END)
			END AS Active_Order_Amt
		,CASE WHEN o.Datekey>=20190301 THEN (CASE WHEN o.Close_Status='未关闭' THEN SUM(o.Amount)/1000 ELSE 0 END) 
			ELSE (CASE WHEN o.Close_Status='未关闭' THEN SUM(o.Full_Amount)/1000 ELSE 0 END)
			END AS Open_Order_AMT
		,CASE WHEN o.Close_Status='已关闭' THEN SUM(o.Sale_Unit_QTY*p.Sale_Unit_Weight_KG)/1000 ELSE 0 END AS [Active_Order_Vol]
		,CASE WHEN o.Close_Status='未关闭' THEN SUM(o.Sale_Unit_QTY*p.Sale_Unit_Weight_KG)/1000 ELSE 0 END AS [Open_Order_Vol]
		 ,GETDATE() UPDATE_DTM   
	FROM (SELECT eso.Datekey,eso.Sale_Order_ID,eso.Close_Status,eso.[Customer_Name],oe.SKU_ID,
	OE.Sale_Unit,
	oe.Sale_Unit_QTY,
	OE.BASE_UNIT,
	oe.[Base_Unit_QTY],
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
		WHERE eso.Sale_Dept IN ('Marketing 市场部','Sales Operation 销售管理','O2O有赞','Logistics 物流') --AND DATEKEY >='20190201'
		)o  --SellIn订单详情
	LEFT JOIN dm.Dim_Product p WITH(NOLOCK) ON o.SKU_ID = p.SKU_ID
	LEFT JOIN (SELECT DISTINCT [Customer_Name],[Account_Display_Name],[Channel],[Region],[Handler],[Channel_Handler],[Begin_Date],[End_Date] 
			FROM [dm].[Dim_ERP_CustomerMapping] WITH(NOLOCK))  am1 
		ON ISNULL(am1.Customer_Name,'Unknown') = o.Customer_Name 
		AND CAST(o.Datekey AS VARCHAR) BETWEEN am1.[Begin_Date] AND am1.[End_Date]
   LEFT JOIN (SELECT DISTINCT [Channel],[Begin_Date],[End_Date],[Channel_Handler] FROM [dm].[Dim_ERP_CustomerMapping]) ecm 
	   ON ISNULL(am1.Channel,'Unknown') = ecm.[Channel] 
	   AND CAST(o.Datekey AS VARCHAR) BETWEEN ecm.[Begin_Date] AND ecm.[End_Date]
	WHERE o.Datekey <> convert(varchar(8),getdate(),112)
	GROUP BY Datekey,am1.Account_Display_Name,am1.Channel,am1.Region,o.Customer_Name 
		,ECM.[Channel_Handler]
		,o.Close_Status,am1.Handler,O.SKU_ID,O.Sale_Unit,O.BASE_UNIT,O.Close_Status

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH	


END
GO
