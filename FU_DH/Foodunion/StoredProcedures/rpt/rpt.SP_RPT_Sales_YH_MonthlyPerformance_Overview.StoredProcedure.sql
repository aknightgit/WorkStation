USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_Sales_YH_MonthlyPerformance_Overview]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [rpt].[SP_RPT_Sales_YH_MonthlyPerformance_Overview]
AS BEGIN 



-------------------------------��ȡ��ʵ����ÿ�������һ��
DROP  TABLE IF EXISTS #LastDay
SELECT LEFT(Datekey,6) AS YearMonth
	  ,MAX(Datekey) AS LastDay
	  INTO #LastDay
FROM dm.Fct_KAStore_DailySalesInventory
WHERE Store_ID LIKE 'YH%'
AND Datekey<>CONVERT(VARCHAR(8),GETDATE(),112)
GROUP BY LEFT(Datekey,6)

 --------------------------Monthly sales
DROP TABLE IF EXISTS #dailysales;
SELECT  
	 CASE WHEN ds.Account_Area_CN NOT IN ('�������','�Ĵ�����','��������','��������','��������','���մ���') THEN '����' ELSE LEFT(ds.Account_Area_CN,2) END AS Account_Area_CN
	,LEFT(kds.Datekey,6) AS MonthKey
	,COUNT(DISTINCT Datekey) AS Days_Cnt
	,(SELECT SUM(cds2.Sales_AMT) FROM dm.Fct_KAStore_DailySalesInventory cds2 LEFT JOIN #LastDay ld ON LEFT(cds2.Datekey,6) = ld.YearMonth JOIN dm.Dim_Store ds2 ON ds2.Store_ID=cds2.Store_ID WHERE ds2.Channel_Account='YH' AND CASE WHEN ds.Account_Area_CN NOT IN ('�������','�Ĵ�����','��������','��������','��������','���մ���') THEN '����' ELSE LEFT(ds.Account_Area_CN,2) END
	 =CASE WHEN ds2.Account_Area_CN NOT IN ('�������','�Ĵ�����','��������','��������','��������','���մ���') THEN '����' ELSE LEFT(ds2.Account_Area_CN,2) END
	  AND cds2.Datekey = ld.LastDay AND LEFT(cds2.Datekey,6) = LEFT(kds.Datekey,6)) AS Sales_Amt_LD
	,SUM(Sales_AMT) AS Sales_AMT
INTO #dailysales
FROM dm.Fct_KAStore_DailySalesInventory kds WITH(NOLOCK)
JOIN dm.Dim_Store ds ON ds.Store_ID=kds.Store_ID
WHERE ds.Channel_Account='YH'-- AND kds.Datekey >= CONVERT(VARCHAR(8),DATEADD(DAY,1,Dateadd("MM",-3,EOMONTH(getdate()))),112)
GROUP BY  CASE WHEN ds.Account_Area_CN NOT IN ('�������','�Ĵ�����','��������','��������','��������','���մ���') THEN '����' ELSE LEFT(ds.Account_Area_CN,2) END
	     ,LEFT(kds.Datekey,6)
		 order by MonthKey

-----------------------------------------------Target

DROP TABLE IF EXISTS #Target
SELECT kds.Monthkey
	  ,CASE WHEN ds.Account_Area_CN NOT IN ('�������','�Ĵ�����','��������','��������','��������','���մ���') THEN '����' ELSE LEFT(ds.Account_Area_CN,2) END AS Account_Area_CN
	  ,SUM(Sales_Target) AS Sales_Target
INTO #Target
FROM dm.Fct_KAStore_SalesTarget_Monthly kds WITH(NOLOCK)
JOIN dm.Dim_Store ds WITH(NOLOCK) ON ds.Store_ID=kds.Store_ID
WHERE ds.Channel_Account='YH'
GROUP BY CASE WHEN ds.Account_Area_CN NOT IN ('�������','�Ĵ�����','��������','��������','��������','���մ���') THEN '����' ELSE LEFT(ds.Account_Area_CN,2) END	
		,kds.Monthkey

 --------------------------��ȡÿ�������һ��Ŀ��
DROP TABLE IF EXISTS #Inventory
SELECT  
	 CASE WHEN ds.Account_Area_CN NOT IN ('�������','�Ĵ�����','��������','��������','��������','���մ���') THEN '����' ELSE LEFT(ds.Account_Area_CN,2) END AS Account_Area_CN
	,LEFT(kds.Datekey,6) AS MonthKey
	,COUNT(DISTINCT Datekey) AS Days_Cnt
	,(SELECT SUM(CASE WHEN prod.Product_Sort='Ambient' THEN cds2.Inventory_Qty ELSE 0 END) FROM dm.Fct_KAStore_DailySalesInventory cds2 LEFT JOIN dm.Dim_Product prod ON cds2.SKU_ID = prod.SKU_ID LEFT JOIN #LastDay ld ON LEFT(cds2.Datekey,6) = ld.YearMonth JOIN dm.Dim_Store ds2 ON ds2.Store_ID=cds2.Store_ID WHERE ds2.Channel_Account='YH' AND CASE WHEN ds.Account_Area_CN NOT IN ('�������','�Ĵ�����','��������','��������','��������','���մ���') THEN '����' ELSE LEFT(ds.Account_Area_CN,2) END
	 =CASE WHEN ds2.Account_Area_CN NOT IN ('�������','�Ĵ�����','��������','��������','��������','���մ���') THEN '����' ELSE LEFT(ds2.Account_Area_CN,2) END
	  AND cds2.Datekey = ld.LastDay AND LEFT(cds2.Datekey,6) = LEFT(kds.Datekey,6)) AS Ambient_INV
	,(SELECT SUM(CASE WHEN prod.Product_Sort='Fresh' THEN cds2.Inventory_Qty ELSE 0 END) FROM dm.Fct_KAStore_DailySalesInventory cds2 LEFT JOIN dm.Dim_Product prod ON cds2.SKU_ID = prod.SKU_ID LEFT JOIN #LastDay ld ON LEFT(cds2.Datekey,6) = ld.YearMonth JOIN dm.Dim_Store ds2 ON ds2.Store_ID=cds2.Store_ID WHERE ds2.Channel_Account='YH' AND CASE WHEN ds.Account_Area_CN NOT IN ('�������','�Ĵ�����','��������','��������','��������','���մ���') THEN '����' ELSE LEFT(ds.Account_Area_CN,2) END
	 =CASE WHEN ds2.Account_Area_CN NOT IN ('�������','�Ĵ�����','��������','��������','��������','���մ���') THEN '����' ELSE LEFT(ds2.Account_Area_CN,2) END
	  AND cds2.Datekey = ld.LastDay AND LEFT(cds2.Datekey,6) = LEFT(kds.Datekey,6)) AS Fresh_INV
INTO #Inventory
FROM dm.Fct_KAStore_DailySalesInventory kds WITH(NOLOCK)
JOIN dm.Dim_Store ds ON ds.Store_ID=kds.Store_ID
WHERE ds.Channel_Account='YH'-- AND kds.Datekey > CONVERT(VARCHAR(8),Dateadd("MM",-2,EOMONTH(getdate())),112)
GROUP BY  CASE WHEN ds.Account_Area_CN NOT IN ('�������','�Ĵ�����','��������','��������','��������','���մ���') THEN '����' ELSE LEFT(ds.Account_Area_CN,2) END
	     ,LEFT(kds.Datekey,6)
		 order by MonthKey



SELECT 
		 ISNULL(tar.Monthkey,ds.MonthKey)  AS Yearmonth
		,ISNULL(tar.Account_Area_CN,ds.Account_Area_CN) AS Account_Area_CN
		,SUM(tar.Sales_Target) AS Sales_Target  --����ָ��
		,SUM(lm.Sales_AMT) AS LM_Sales  --��������
		,SUM(ds.Sales_AMT) AS TM_Sales	--��������
		,CASE WHEN SUM(dct.TMD)=0 THEN NULL ELSE (CAST((DATEPART(dd,CAST(CAST(MAX(ld.LastDay) AS VARCHAR) AS DATE)))AS decimal(20,10))/ MAX(dct.TMD)) END AS TimeBar  --ʱ�����
		,CASE WHEN SUM(tar.Sales_Target)>0 THEN MAX(ds.Sales_AMT)/SUM(tar.Sales_Target) ELSE NULL END AS Arch  --����
		,MAX((ds.Sales_AMT/ds.Days_Cnt) / (lm.Sales_AMT/lm.Days_Cnt) - 1) AS Grouth  --�վ�����
		,SUM(ds.Sales_Amt_LD) AS Latest_AMT
		,SUM(Fresh_INV) AS Fresh_INV
		,SUM(Ambient_INV) AS Ambient_INV
		,CAST(CAST(MAX(ld.LastDay)AS varchar) AS DATE) AS Latest_Date
		--SELECT *
	FROM #Target AS tar--����ָ��
	FULL OUTER JOIN #dailysales ds ON ds.Account_Area_CN=tar.Account_Area_CN AND ds.MonthKey = tar.Monthkey
	LEFT JOIN #DailySales lm ON lm.[MonthKey]+CASE WHEN lm.MonthKey%100=12 THEN 89 ELSE 1 END=ISNULL(tar.Monthkey,ds.MonthKey) AND ISNULL(tar.Account_Area_CN,ds.Account_Area_CN) = lm.Account_Area_CN
	LEFT JOIN (SELECT Year_Month,COUNT(1) TMD FROM FU_EDW.Dim_Calendar WITH(NOLOCK) GROUP BY Year_Month)dct ON ISNULL(tar.Monthkey,ds.MonthKey) = dct.Year_Month
	LEFT JOIN #Inventory inv ON inv.MonthKey=ISNULL(tar.Monthkey,ds.MonthKey) AND inv.Account_Area_CN = ISNULL(tar.Account_Area_CN,ds.Account_Area_CN)
	LEFT JOIN #LastDay ld ON ISNULL(tar.Monthkey,ds.MonthKey) = ld.YearMonth
	WHERE ISNULL(tar.Account_Area_CN,ds.Account_Area_CN) IS NOT NULL
	GROUP BY ISNULL(tar.Account_Area_CN,ds.Account_Area_CN)
		,ISNULL(tar.Monthkey,ds.MonthKey)


END
GO
