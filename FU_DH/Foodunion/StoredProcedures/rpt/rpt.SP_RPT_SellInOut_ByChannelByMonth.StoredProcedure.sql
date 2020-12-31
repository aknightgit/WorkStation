USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_SellInOut_ByChannelByMonth]
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
	
	--ÓÃ [dm].[Fct_Sales_SellIn_ByChannel] ´úÌæ [rpt].[ERP_Sales_Order] 
	SELECT Datekey,
		CASE WHEN ch.Channel_Name='YH' THEN 'YH'
		WHEN Channel_Name_Display='Vanguard' THEN 'VG'
		WHEN Channel_Name='KidsWant' THEN 'KW'
		ELSE 'Distributors' END AS Channel,
		'Sell In' AS Item,
		SUM(Amount) AS Sales,
		SUM(Volume_L) AS Sales_VOL
	FROM [dm].[Fct_Sales_SellIn_ByChannel] si WITH(NOLOCK)
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
	ON si.Channel_ID=ch.Channel_ID AND ch.Monthkey = si.DateKey/100
	WHERE ch.Team in ('Dragon Team','Offline','MKT','YH')
	and datekey>=20190201
	GROUP BY Datekey,
		CASE WHEN ch.Channel_Name='YH' THEN 'YH'
		WHEN Channel_Name_Display='Vanguard' THEN 'VG'
		WHEN Channel_Name='KidsWant' THEN 'KW'
		ELSE 'Distributors' END
		--ORDER BY 1,2, 3


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
