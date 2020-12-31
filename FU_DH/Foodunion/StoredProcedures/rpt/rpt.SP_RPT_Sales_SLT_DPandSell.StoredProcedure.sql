USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_Sales_SLT_DPandSell]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [rpt].[SP_RPT_Sales_SLT_DPandSell]
AS BEGIN 

	
;WITH DemandPlanning AS(
	SELECT year*100+Month AS Monthkey,dp.Channel,p.Product_Sort,sum(volume) AS DP_Vol
	FROM dm.Fct_Production_DemandPlanning dp
	JOIN dm.Dim_Product p on dp.SKU_ID = p.SKU_ID
	--WHERE year*100+Month=201909
	WHERE dp.Item= CASE WHEN year*100+Month<CONVERT(VARCHAR(6),GETDATE(),112) THEN 'Sales Input' ELSE 'Adjusted demand' END  --历史月份，hilda会把DP数字保留在SalesInput上
	AND Channel IN ('CP','VG','YH')
	GROUP BY year*100+Month,dp.Channel,p.Product_Sort
	)
,monthlysellout AS(
	SELECT ka.Datekey/100 Monthkey,LEFT(ka.Store_ID,2) AS Channel,'Sell Out' AS Item, p.Product_Sort ,SUM(ka.Sales_Amt) AS Sales
	, SUM(Sales_Vol_KG) AS Sales_Vol_KG
	FROM dm.Fct_KAStore_DailySalesInventory ka with(nolock) 
	JOIN dm.Dim_Product p with(nolock) ON ka.SKU_ID=p.SKU_ID
	WHERE LEFT(ka.Store_ID,2) IN ('YH','VG')
	GROUP BY Datekey/100,LEFT(Store_ID,2), p.Product_Sort
)
,monthlysellin AS(	

	SELECT Datekey/100 Monthkey,
		CASE WHEN ch.Channel_Name='YH' THEN 'YH'
		WHEN Channel_Name_Display='Vanguard' THEN 'VG'
		ELSE 'CP' END AS Channel,
		'Sell In' AS Item,
		p.Product_Sort,
		SUM(Amount) AS Sales,
		SUM(Weight_KG) AS Sales_Vol_KG
	FROM [dm].[Fct_Sales_SellIn_ByChannel] si WITH(NOLOCK)
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
	ON si.Channel_ID=ch.Channel_ID AND ch.Monthkey = si.DateKey/100
	JOIN dm.Dim_Product p ON si.SKU_ID=p.SKU_ID
	WHERE ch.Team in ('Dragon Team','Offline','YH')
	and datekey>=20190201
	GROUP BY Datekey/100 ,
		CASE WHEN ch.Channel_Name='YH' THEN 'YH'
		WHEN Channel_Name_Display='Vanguard' THEN 'VG'
		ELSE 'CP' END ,
		p.Product_Sort
		/*
	SELECT so.Datekey/100 Monthkey, CASE so.Channel WHEN  'Vanguard' THEN 'VG' WHEN 'YH' THEN 'YH' ELSE 'CP' END AS Channel, 'Sell In' AS Item
		, p.Product_Sort
		, SUM(so.Actual_AMT)*1000 AS Sales
		, SUM(Actual_VOL)*1000 AS Sales_Vol_KG
	FROM [rpt].[ERP_Sales_Order] so
	JOIN dm.Dim_Product p ON so.SKU_ID=p.SKU_ID
	WHERE On_Off_Line IN ('Offline','YH','DRAGON TEAM') --Channel in ('Vanguard','YH')
	GROUP BY so.Datekey/100, CASE Channel WHEN  'Vanguard' THEN 'VG' WHEN 'YH' THEN 'YH'  ELSE 'CP' END , p.Product_Sort
	*/
	)
,monthlytargetsellout AS (
	SELECT  Monthkey,'KA' AS Channel_Group,Channel,'Sell Out' AS Item,SUM(Sales_Target)/1000 AS MonthlyTarget
	FROM [dm].[Fct_KAStore_SalesTarget_Monthly] with(nolock)
	GROUP BY Monthkey,Channel
)
,monthlytargetsellin AS (	
	SELECT Monthkey,
		CASE WHEN Region in ('Vanguard','YH') THEN 'KA'	ELSE 'CP' END AS Channel_Group,
		CASE WHEN Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
		WHEN Region='Vanguard' THEN 'VG'
		ELSE 'CP' END AS Channel,
		'Sell In' AS Item,
		SUM(Target_Amount) AS MonthlyTarget
	FROM [dm].[Fct_Sales_SellInTarget] with(nolock)
	WHERE Channel IN ('OFFLINE','YH','DRAGON TEAM')
	--AND Monthkey=201908
	GROUP BY Monthkey,
		CASE WHEN Region in ('Vanguard','YH') THEN 'KA'	ELSE 'CP' END,
		CASE WHEN Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
		WHEN Region='Vanguard' THEN 'VG'
		ELSE 'CP' END 
	)
SELECT dp.Monthkey AS Monthkey	
	,dp.Channel
	,dp.Product_Sort
	,dp.DP_Vol
	--,m1.Item AS Item
	,soi.MonthlyTarget AS MonthlyTarget_SellIn
	,si.Sales/1000 AS MonthlyAmount_SellIn
	--,CASE WHEN ISNULL(soi.MonthlyTarget,0)=0 THEN NULL ELSE si.Sales/1000/soi.MonthlyTarget END AS MonthlyAmtArch_SellIn	
	,si.Sales_Vol_KG/1000 AS MonthlyVol_SellIn
	--,CASE WHEN ISNULL(dp.DP_Vol,0)=0 THEN NULL ELSE si.Sales_Vol_KG/1000/dp.DP_Vol END AS MonthlyVolArch_SellIn

	,sot.MonthlyTarget AS MonthlyTarget_SellOut
	,so.Sales/1000 AS MonthlyAmount_SellOut
	--,CASE WHEN ISNULL(sot.MonthlyTarget,0)=0 THEN NULL ELSE so.Sales/1000/sot.MonthlyTarget END AS MonthlyAmtArch_SellOut	
	,so.Sales_Vol_KG/1000 AS MonthlyVol_SellOut
	--,CASE WHEN ISNULL(dp.DP_Vol,0)=0 THEN NULL ELSE so.Sales_Vol_KG/1000/dp.DP_Vol END AS MonthlyVolArch_SellOut	

	,CASE WHEN dp.Product_Sort='Fresh' THEN '#FFFFFF' END AS FontColour
	,'Vol 完成比' AS 'DPVolArcHead'
	,'Sell-in Amt 完成比' AS 'SellInArcHead'
	,'Sell-out Amt 完成比' AS 'SellOutArcHead'

FROM DemandPlanning dp 
LEFT JOIN monthlysellin si ON si.Monthkey=dp.Monthkey AND si.Channel=dp.Channel AND si.Product_Sort=dp.Product_Sort
LEFT JOIN monthlysellout so ON si.Monthkey=so.Monthkey AND si.Channel=so.Channel AND si.Product_Sort=so.Product_Sort
LEFT JOIN monthlytargetsellout sot ON si.Monthkey=sot.Monthkey AND si.Channel=sot.Channel AND si.Product_Sort='Fresh' 
LEFT JOIN monthlytargetsellin soi ON si.Monthkey=soi.Monthkey AND si.Channel=soi.Channel AND si.Product_Sort='Fresh'  --拆分不了 ，写在Fresh上

--LEFT JOIN monthlysales m1 ON m1.Monthkey=dp.Monthkey AND m1.Channel=dp.Channel AND m1.Product_Sort=dp.Product_Sort
--LEFT JOIN monthlytarget mt ON m1.Monthkey=mt.Monthkey AND m1.Channel=mt.Channel AND m1.Item=mt.Item
--WHERE dp.Monthkey=201909
--AND wt.Week_Year_NBR=31

ORDER BY 1,2,4,6

END
GO
