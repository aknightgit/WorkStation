USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [rpt].[SP_RPT_Sales_SLT_DPandSell]
AS BEGIN 

	
;WITH DemandPlanning AS(
	SELECT year*100+Month AS Monthkey,CASE WHEN dp.Channel='CP' THEN 'Distributor' ELSE dp.Channel END Channel,p.Product_Sort,sum(volume) AS DP_Vol  --CP改成Distributor  Justin 2020-05-07
	FROM dm.Fct_Production_DemandPlanning dp
	JOIN dm.Dim_Product p on dp.SKU_ID = p.SKU_ID
	--WHERE year*100+Month=201909
	WHERE dp.Item= CASE WHEN year*100+Month<CONVERT(VARCHAR(6),GETDATE(),112) THEN 'Sales Input' ELSE 'Adjusted demand' END  --历史月份，hilda会把DP数字保留在SalesInput上
	AND Channel IN ('CP','VG','YH','KW','Distributor')
	GROUP BY year*100+Month,dp.Channel,p.Product_Sort
	)
,monthlysellout AS(
	SELECT ka.Datekey/100 Monthkey,LEFT(ka.Store_ID,2) AS Channel,'Sell Out' AS Item, p.Product_Sort ,SUM(ka.Sales_Amt) AS Sales
	, SUM(Sales_Vol_KG) AS Sales_Vol_KG
	FROM dm.Fct_KAStore_DailySalesInventory ka with(nolock) 
	JOIN dm.Dim_Product p with(nolock) ON ka.SKU_ID=p.SKU_ID
	WHERE LEFT(ka.Store_ID,2) IN ('YH','VG','KW')
	GROUP BY Datekey/100,LEFT(Store_ID,2), p.Product_Sort
)
,monthlysellin AS(	

	SELECT Datekey/100 Monthkey,
		CASE WHEN ch.Channel_Name='YH' THEN 'YH'
		WHEN Channel_Name_Display='Vanguard' THEN 'VG'		
		WHEN Channel_Name_Display='Kidswant' THEN 'KW'
		WHEN Channel_Type = 'CP' THEN 'Distributor'                        --CP改成Distributor  Justin 2020-05-07
		WHEN Channel_Type = 'Distributor' THEN 'Distributor' 
		END AS Channel,
		'Sell In' AS Item,
		p.Product_Sort,
		SUM(Amount) AS Sales,
		SUM(Weight_KG) AS Sales_Vol_KG
	FROM [dm].[Fct_Sales_SellIn_ByChannel] si WITH(NOLOCK)
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
	ON si.Channel_ID=ch.Channel_ID AND ch.Monthkey = si.DateKey/100
	JOIN dm.Dim_Product p ON si.SKU_ID=p.SKU_ID
	WHERE ch.Team in ('Dragon Team','Offline','YH','MKT') AND Channel_Name_Display <> 'Kidswant'
	and datekey>=20190201
	GROUP BY Datekey/100 ,
		CASE WHEN ch.Channel_Name='YH' THEN 'YH'
		WHEN Channel_Name_Display='Vanguard' THEN 'VG'	
		WHEN Channel_Name_Display='Kidswant' THEN 'KW'
		WHEN Channel_Type = 'CP' THEN 'Distributor'                          --CP改成Distributor  Justin 2020-05-07
		WHEN Channel_Type = 'Distributor' THEN 'Distributor' END, 
		p.Product_Sort
	------------------孩子王寄售模式 使用调拨单计算sell in--------------------
	UNION ALL
	SELECT
	   [Datekey]/100 AS Monthkey
      ,'KW' AS Channel
	  ,'Sell In' AS Item
	  ,p.Product_Sort
      ,Sum(stie.Sale_QTY * isnull(pl.SKU_Price,p.Sale_Unit_RSP*0.85) ) AS [Actual_AMT]
	  ,sum(stie.Base_Unit_QTY * p.Base_Unit_Weight_KG) AS [Actual_VOL]
	FROM [dm].[Fct_ERP_Stock_TransferIn] sti WITH(NOLOCK)
	JOIN [dm].[Fct_ERP_Stock_TransferInEntry] stie WITH(NOLOCK) ON sti.TransID = stie.TransID
	JOIN [dm].[Dim_Product] p WITH(NOLOCK) ON stie.SKU_ID=p.SKU_ID
	JOIN [dm].[Dim_Channel_hist] ch WITH(NOLOCK)
		ON ch.Channel_Name='Kidswant' AND ch.Monthkey = sti.DateKey/100
	LEFT JOIN dm.Dim_Product_Pricelist pl WITH(NOLOCK) ON p.SKU_ID=pl.SKU_ID AND pl.Price_List_Name='统一供价' AND Is_Current=1
	WHERE stie.Dest_Stock like '%孩子王寄售仓%'
	--AND pl.SKU_ID IS NULL
	GROUP BY [Datekey]/100
	  ,p.Product_Sort
	  

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
	--SELECT Monthkey,
	--	CASE WHEN Region in ('Vanguard','YH') THEN 'KA'	ELSE 'CP' END AS Channel_Group,
	--	CASE WHEN Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
	--	WHEN Region='Vanguard' THEN 'VG'
	--	ELSE 'CP' END AS Channel,
	--	'Sell In' AS Item,
	--	SUM(Target_Amount) AS MonthlyTarget
	--FROM [dm].[Fct_Sales_SellInTarget] with(nolock)
	--WHERE Channel IN ('OFFLINE','YH','DRAGON TEAM')
	----AND Monthkey=201908
	--GROUP BY Monthkey,
	--	CASE WHEN Region in ('Vanguard','YH') THEN 'KA'	ELSE 'CP' END,
	--	CASE WHEN Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
	--	WHEN Region='Vanguard' THEN 'VG'
	--	ELSE 'CP' END 

	SELECT  
		Datekey/100 AS Monthkey
		,CASE WHEN Channel_Category in ('Vanguard','YH','Kidswant') THEN 'KA'	ELSE 'Distributor' END AS Channel_Group    --CP改成Distributor  Justin 2020-05-07
		,CASE WHEN Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
			WHEN Channel_Category='Vanguard' THEN 'VG'
			WHEN Channel_Category='Kidswant' THEN 'KW'
			ELSE 'Distributor' END AS Channel                                       --CP改成Distributor  Justin 2020-05-07
		,'Sell In' AS Item
		,SUM(Target_AMT) AS MonthlyTarget
	FROM [dm].[Fct_Sales_SellInTarget_ByChannel_hist]
	GROUP BY Datekey/100
		,CASE WHEN Channel_Category in ('Vanguard','YH','Kidswant') THEN 'KA'	ELSE 'Distributor' END   --CP改成Distributor  Justin 2020-05-07
		,CASE WHEN Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
			WHEN Channel_Category='Vanguard' THEN 'VG'
			WHEN Channel_Category='Kidswant' THEN 'KW'
			ELSE 'Distributor' END

	UNION
	SELECT  
		Monthkey
		,CASE WHEN Channel_Category_Name in ('Vanguard','YH','Kidswant') THEN 'KA'	ELSE 'Distributor' END AS Channel_Group   --CP改成Distributor  Justin 2020-05-07
		,CASE WHEN ERP_Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
			WHEN Channel_Category_Name='Vanguard' THEN 'VG'
			WHEN Channel_Category_Name='Kidswant' THEN 'KW'
		    WHEN Channel_Type = 'CP' THEN 'Distributor'                                       --CP改成Distributor  Justin 2020-05-07
			WHEN Channel_Type = 'Distributor' THEN 'Distributor'END AS Channel
		,'Sell In' AS Item
		,SUM(ISNULL(Target_Amt_KRMB,Category_Target_Amt_KRMB)) AS MonthlyTarget
	FROM [dm].[Fct_Sales_SellInTarget_ByChannel]
	WHERE MonthKey>=201910 AND Team in ('Dragon Team','Offline','YH','MKT')
	GROUP BY Monthkey
		,CASE WHEN Channel_Category_Name in ('Vanguard','YH','Kidswant') THEN 'KA'	ELSE 'Distributor' END    --CP改成Distributor  Justin 2020-05-07
		,CASE WHEN ERP_Customer_Name='富平云商供应链管理有限公司' THEN 'YH'
			WHEN Channel_Category_Name='Vanguard' THEN 'VG'
			WHEN Channel_Category_Name='Kidswant' THEN 'KW'
		    WHEN Channel_Type = 'CP' THEN 'Distributor'
			WHEN Channel_Type = 'Distributor' THEN 'Distributor'END 
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
