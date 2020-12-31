USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [rpt].[SP_RPT_SellInOut_ByChannelByMonth]
AS BEGIN 


 ;WITH dailysales AS(
	SELECT s.Datekey, 'VG' AS Channel,'Sell Out' AS Item,SUM(s.Gross_Sale_Value) AS Sales, SUM(s.Sale_Qty*p.Sale_Unit_Weight_KG) AS Sales_VOL
	FROM dm.Fct_CRV_DailySales s with(nolock) 
	JOIN dm.Dim_Product p with(nolock) ON s.SKU_ID=p.SKU_ID
	GROUP BY s.Datekey
	UNION
	SELECT s.Calendar_DT, 'YH' AS Channel,'Sell Out' AS Item,SUM(Sales_Amt) AS Sales ,SUM(s.Sales_QTY*p.Sale_Unit_Weight_KG) AS Sales_VOL
	FROM [dm].[Fct_YH_Sales_Inventory] s with(nolock) 
	JOIN dm.Dim_Product p with(nolock) ON s.SKU_ID=p.SKU_ID
	GROUP BY s.Calendar_DT
	UNION 
	SELECT s.Datekey, 'KW' AS Channel,'Sell Out' AS Item,SUM(Sales_Amt) AS Sales,SUM(s.Sales_QTY*p.Sale_Unit_Weight_KG) AS Sales_VOL
	FROM [dm].[Fct_Kidswant_DailySales] s with(nolock) 
	JOIN dm.Dim_Product p with(nolock) ON s.SKU_ID=p.SKU_ID 
	GROUP BY s.Datekey
	UNION 
	
	--用 [dm].[Fct_Sales_SellIn_ByChannel] 代替 [rpt].[ERP_Sales_Order] 
	SELECT Datekey,
		CASE WHEN ch.Channel_Name='YH' THEN 'YH'
		WHEN Channel_Name_Display='Vanguard' THEN 'VG'
		WHEN Channel_Name='KidsWant' THEN 'KW'
		ELSE 'Distributor' END AS Channel,
		'Sell In' AS Item,
		SUM(Amount) AS Sales,
		SUM(Weight_KG) AS Sales_VOL
	FROM [dm].[Fct_Sales_SellIn_ByChannel] si WITH(NOLOCK)
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
	ON si.Channel_ID=ch.Channel_ID AND ch.Monthkey = si.DateKey/100
	WHERE ch.Team in ('Dragon Team','Offline','MKT','YH')
	and datekey>=20190201
	GROUP BY Datekey,
		CASE WHEN ch.Channel_Name='YH' THEN 'YH'
		WHEN Channel_Name_Display='Vanguard' THEN 'VG'
		WHEN Channel_Name='KidsWant' THEN 'KW'
		ELSE 'Distributor' END
		--ORDER BY 1,2, 3

	UNION
	--孩子王寄售模式，用调拨单数据
	  SELECT  
	  [Datekey]
	  ,'KW' AS Channel
	  ,'Sell In 调拨单' AS Item
      ,Sum(stie.Sale_QTY * isnull(pl.SKU_Price,p.Sale_Unit_RSP*0.85)) AS Sales
      ,sum(stie.Base_Unit_QTY * p.Base_Unit_Weight_KG) AS Sales_VOL
	FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
	JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
	JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON stie.SKU_ID=p.SKU_ID
	LEFT JOIN dm.Dim_Product_Pricelist pl WITH(NOLOCK) ON p.SKU_ID=pl.SKU_ID AND pl.Price_List_Name='统一供价' AND Is_Current=1
	WHERE stie.Dest_Stock like '%孩子王寄售仓%'
	--AND pl.SKU_ID IS NULL
	GROUP BY [Datekey]


	/*
	SELECT Datekey, CASE Channel WHEN  'Vanguard' THEN 'VG' 
		WHEN 'YH' THEN 'YH' 
		WHEN 'MKT' THEN 'KW'
		ELSE 'Distributors' END AS Channel, 'Sell In' AS Item
		, SUM(Actual_AMT)*1000 AS Sales
		, SUM(Actual_Vol)*1000 AS Sales_VOL
	FROM [rpt].[ERP_Sales_Order] 
	WHERE On_Off_Line in ('Offline','YH','MKT','Dragon Team')
	GROUP BY Datekey, CASE Channel WHEN  'Vanguard' THEN 'VG' 
		WHEN 'YH' THEN 'YH' 
		WHEN 'MKT' THEN 'KW'
		ELSE 'Distributors' END
		ORDER BY 1,2,3
		*/
	)
SELECT Datekey/100 AS Monthkey, CAST(SUBSTRING(CAST(Datekey AS VARCHAR(8)),1,4)+'-'+SUBSTRING(CAST(Datekey AS VARCHAR(8)),5,2)+'-01' AS DATE) MonthDate
, Channel,Item
,SUM(Sales) AS MonthlySales 
,SUM(Sales_VOL) AS MonthlyVol
FROM dailysales 
GROUP BY Datekey/100, CAST(SUBSTRING(CAST(Datekey AS VARCHAR(8)),1,4)+'-'+SUBSTRING(CAST(Datekey AS VARCHAR(8)),5,2)+'-01' AS DATE),Channel,Item
ORDER BY 1 DESC

end
GO
