USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [rpt].[SP_RPT_Sales_ByChannel_BySKU_ByWeek] 
	
AS
BEGIN

	--Part1 ： KA Sales
	SELECT CASE s.Channel_Account WHEN 'Vanguard' THEN 'CRV' ELSE s.Channel_Account END AS Channel
		,REPLACE(REPLACE(s.Store_Province,'省',''),'市','') AS Region
		,c.Week_Nature_Str AS 'Week'
		--,c.Week_of_Year AS Week_No
		,p.Brand_Name AS Brand
		,p.Product_Sort AS Sort
		,p.Product_Category AS Category
		,ka.SKU_ID 
		,p.SKU_Name
		,p.SKU_Name_CN		
		,p.Sale_Scale
		--,p.Sale_Unit_RSP AS RSP
		,SUM(ka.Sales_AMT) AS 'Net_Sales(RMB)'
		,SUM(ka.Sales_Qty) AS [QTY]
		,CAST(CASE WHEN SUM(ka.Sales_Qty) =0 THEN NULL ELSE SUM(ka.Sales_AMT)/SUM(ka.Sales_Qty) END AS DECIMAL(10,2)) AS 'ASP'
		,p.Sale_Unit_Weight_KG * 1000 AS 'SKU(g)'
		,CAST(SUM(ka.Sales_Qty * p.Sale_Unit_Weight_KG)/1000 AS DECIMAL(10,5)) as  [Volume(MT)]
		,COUNT(DISTINCT CASE WHEN s.Channel_Account='YH' AND s.Account_Store_Type='永辉超市' AND ka.Sales_Qty>0 THEN ka.Store_ID 
			WHEN s.Channel_Account<>'YH' AND ka.Sales_Qty>0 THEN ka.Store_ID 
			ELSE NULL END) AS '当周有销售门店数'
		,COUNT(DISTINCT CASE WHEN ka.Inventory_Qty>0 THEN ka.Store_ID ELSE NULL END) AS '当周有库存门店数'
		--,MAX(pre.PreInv_Store_Count) AS '上周有库存门店数'
	FROM [dm].[Fct_KAStore_DailySalesInventory] ka WITH(NOLOCK)
	JOIN [dm].[Dim_Calendar] c WITH(NOLOCK) on ka.[DateKey] = C.Datekey
	JOIN [dm].[Dim_Product] p WITH(NOLOCK)  on ka.SKU_ID = p.SKU_ID	
	JOIN [dm].[Dim_Store] s WITH(NOLOCK) ON ka.Store_ID = s.Store_ID
	--LEFT JOIN (	
	--	SELECT s1.Channel_Account
	--		,ka1.SKU_ID,c2.Week_Nature_Str, 
	--		Count(DISTINCT CASE WHEN ka1.Inventory_Qty>0 THEN s1.Store_ID ELSE NULL END) PreInv_Store_Count
	--	FROM [dm].[Fct_KAStore_DailySalesInventory] ka1 WITH(NOLOCK)
	--	JOIN dm.Dim_Store s1 ON ka1.Store_ID=s1.Store_ID
	--	JOIN dm.Dim_Calendar c2 ON ka1.Datekey=c2.Previous_Week
	--	GROUP BY s1.Channel_Account
	--		,ka1.SKU_ID,c2.Week_Nature_Str
	--	)pre ON s.Channel_Account=pre.Channel_Account AND ka.SKU_ID=pre.SKU_ID AND c.Week_Nature_Str=pre.Week_Nature_Str
	WHERE ka.Datekey>=20190701 
	AND ka.Datekey <= CONVERT(CHAR(8),DATEADD(DAY,- DATEPART(WEEKDAY,GETDATE())+1,GETDATE()),112)
	AND S.Channel_Account IN ('Vanguard','KW','YH')
	--AND ka.Sales_Qty>0
	GROUP BY CASE s.Channel_Account WHEN 'Vanguard' THEN 'CRV' ELSE s.Channel_Account END
		,REPLACE(REPLACE(s.Store_Province,'省',''),'市','')
		,p.Brand_Name
		,p.Product_Sort 
		,p.Product_Category 
		,ka.SKU_ID 
		,p.SKU_Name
		,p.SKU_Name_CN
		,c.Week_Nature_Str
		--,c.Week_of_Year 
		,p.Sale_Unit_Weight_KG
		,p.Sale_Scale
		--,p.Sale_Unit_RSP 

	--Part2: Online Sales
	

/*  --2020/3/18   修改zbox从dm.Fct_Sales_SellOut_ByChannel表走
	SELECT 'Zbox' AS Channel
		,isnull(sal.Week_Nature_Str,refund.Week_Nature_Str) AS 'Week'
		,p.Brand_Name AS Brand
		,p.Product_Sort AS Sort
		,p.Product_Category AS Category
		,ISNULL(sal.SKU_ID,refund.SKU_ID)
		,p.SKU_Name
		,p.SKU_Name_CN		
		,p.Sale_Scale
		--,p.Sale_Unit_RSP AS RSP
		,SUM(ISNULL(sal.Sales_AMT,0)-ISNULL(refund.Refund_AMT,0)) AS 'Net_Sales(RMB)'
		,SUM(ISNULL(sal.Sales_Qty,0)-ISNULL(refund.Refund_QTY,0)) AS [QTY]
		,CAST(CASE WHEN SUM(ISNULL(sal.Sales_Qty,0)-ISNULL(refund.Refund_QTY,0)) =0 THEN NULL 
			ELSE SUM(ISNULL(sal.Sales_AMT,0)-ISNULL(refund.Refund_AMT,0))/SUM(ISNULL(sal.Sales_Qty,0)-ISNULL(refund.Refund_QTY,0)) END AS DECIMAL(10,2)) AS 'ASP'
		,(p.Sale_Unit_Weight_KG * 1000) AS 'SKU(g)'
		,CAST((SUM(ISNULL(sal.Sales_Qty,0)-ISNULL(refund.Refund_QTY,0)) * p.Sale_Unit_Weight_KG)/1000 AS DECIMAL(10,5)) as  [Volume(MT)]
		,NULL AS '当周有销售门店数'
		,NULL AS '当周有库存门店数'
	FROM (
		SELECT c.Week_Nature_Str,qs.SKU_ID, SUM(Sales_Qty) as Sales_Qty,SUM(Payment) AS Sales_AMT	
		FROM  [dm].[Fct_Qulouxia_Sales] qs WITH(NOLOCK)
		JOIN dm.Dim_Product p WITH(NOLOCK) ON qs.SKU_ID = p.SKU_ID
		JOIN [dm].[Dim_Calendar] c WITH(NOLOCK) on qs.[DateKey] = c.Datekey
		WHERE qs.Order_Status = '已完成'
		--AND qs.DATEKEY BETWEEN 20200224 AND 20200301
		GROUP BY c.Week_Nature_Str,qs.SKU_ID) sal
	FULL JOIN (
		SELECT c.Week_Nature_Str,qs.SKU_ID, SUM(Refund_QTY) as Refund_QTY,SUM(Refund_AMT) AS Refund_AMT	
		FROM  [dm].[Fct_Qulouxia_Sales] qs WITH(NOLOCK)
		JOIN dm.Dim_Product p WITH(NOLOCK) ON qs.SKU_ID = p.SKU_ID
		JOIN [dm].[Dim_Calendar] c WITH(NOLOCK) on REPLACE(qs.Refund_Time,'-','') = c.Datekey
		WHERE qs.Order_Status = '已完成'
		--AND qs.DATEKEY BETWEEN 20200224 AND 20200301
		--AND REPLACE(qs.Refund_Time,'-','') BETWEEN 20200224 AND 20200301
		GROUP BY c.Week_Nature_Str,qs.SKU_ID)refund
	ON sal.Week_Nature_Str=refund.Week_Nature_Str AND sal.SKU_ID=refund.SKU_ID
	LEFT JOIN dm.Dim_Product p ON ISNULL(sal.SKU_ID,refund.SKU_ID)=p.SKU_ID
	GROUP BY isnull(sal.Week_Nature_Str,refund.Week_Nature_Str) 
		,p.Brand_Name 
		,p.Product_Sort 
		,p.Product_Category
		,ISNULL(sal.SKU_ID,refund.SKU_ID)
		,p.SKU_Name
		,p.SKU_Name_CN		
		,p.Sale_Scale
		,p.Sale_Unit_Weight_KG
*/
	---------------Tmall 和pinduoduo ZBOX
	UNION ALL

	SELECT 
		c.Channel_Name_Display AS Channel
		,'' AS Region
		,dc.Week_Nature_Str AS 'Week'
		,p.Brand_Name AS Brand
		,p.Product_Sort AS Sort
		,p.Product_Category AS Category
		,ss.SKU_ID 
		,p.SKU_Name
		,p.SKU_Name_CN		
		,p.Sale_Scale
		--,p.Sale_Unit_RSP AS RSP
		,SUM(ss.Amount) AS 'Net_Sales(RMB)'
		,SUM(ss.QTY) AS [QTY]
		,CAST(CASE WHEN SUM(ss.QTY)=0 THEN NULL ELSE SUM(ss.Amount)/SUM(ss.QTY) END AS DECIMAL(10,2)) AS 'ASP'
		,(p.Sale_Unit_Weight_KG * 1000) AS 'SKU(g)'
		,SUM(ss.Weight_KG*1000) as  [Volume(MT)]
		,NULL AS '当周有销售门店数'
		,NULL AS '当周有库存门店数'
	FROM dm.Fct_Sales_SellOut_ByChannel ss
	JOIN dm.Dim_Calendar dc on ss.DateKey=dc.Datekey
	JOIN dm.Dim_Channel c on ss.Channel_ID=c.Channel_ID
	JOIN dm.Dim_Product p on ss.SKU_ID=p.SKU_ID
	WHERE ss.Datekey>=20190701 
	AND c.Channel_Category in ('EC-PDD','EC-Tmall','Zbox','DTC')
	GROUP BY c.Channel_Name_Display
		,dc.Week_Nature_Str
		,p.Brand_Name
		,p.Product_Sort
		,p.Product_Category
		,ss.SKU_ID 
		,p.SKU_Name
		,p.SKU_Name_CN		
		,p.Sale_Scale
		,p.Sale_Unit_Weight_KG


	ORDER BY 1 , 2 DESC,7

END

	

	--select top 100 * from dm.Fct_Sales_SellOut_ByChannel ss
	--select top 100 * from dm.Fct_Sales_SellOut_byChannel_byRegion where Channel_ID=71
GO
