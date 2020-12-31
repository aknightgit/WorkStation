﻿USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE PROCEDURE [rpt].[SP_RPT_Kidswant_Store_Flag_Daily]
AS
BEGIN 
/****** Script for SelectTopNRows command from SSMS  ******/

SELECT 
T2.Datekey,
T.Store_ID,
T1.SKU_ID,
ISNULL(T3.Sales_Qty,0) Sales_Qty,
ISNULL(T3.Sales_AMT,0)Sales_AMT,
ISNULL(T3.Ending_Qty,0)Ending_Qty,
ISNULL(T3.Ending_AMT,0)Ending_AMT
 INTO #TEMP
 FROM [dm].[Dim_Store] T
 CROSS JOIN 
 ---与SKU做笛卡尔积，目前只选取提供了铺货标准的9个SKU
 (SELECT DISTINCT SKU_ID FROM dm.Dim_Product_DISPLAY_Standard WHERE CHANNEL='KIDSWANT'
  ) T1
 ---与时间维表笛卡尔积，从最早孩子王有销售那天开始
 CROSS JOIN (SELECT DISTINCT Datekey FROM [dm].[Fct_Kidswant_DailySales])T2
 ---关联事实数据
LEFT JOIN (
SELECT 
Datekey,
STORE_ID,
SKU_ID,
SUM(CAST(Sales_Qty AS FLOAT)) Sales_Qty,
SUM(CAST(Sales_AMT AS FLOAT)) Sales_AMT,
SUM(CAST(Ending_Qty AS FLOAT)) Ending_Qty,
SUM(CAST(Ending_AMT AS FLOAT)) Ending_AMT
FROM [dm].[Fct_Kidswant_DailySales]
GROUP BY Datekey,STORE_ID,
SKU_ID
)T3 ON T3.SKU_ID=T1.SKU_ID AND T3.STORE_ID=T.Store_ID AND T3.Datekey=T2.Datekey
WHERE Channel_Account='KW' AND Channel_Type='OFFLINE'

SELECT T.Datekey,
T.Store_ID,
--RED_FLAG,
--YELLOW_FLAG,
(CASE WHEN RED_FLAG IS NOT NULL THEN 0 
     WHEN YELLOW_FLAG IS NOT NULL THEN 1 ELSE 2 END )Display_Inventory_Flag

FROM (
SELECT 
T.Datekey,
T.Store_ID,
--T.SKU_ID,
--T.Ending_Qty,
--T1.SUMX_SALES_AMT,
SUM(CASE WHEN T1.Datekey IS NOT NULL AND T.Ending_Qty<=0 THEN 1 ELSE NULL END ) RED_FLAG,
--T2.STANDARD_QTY,
SUM(CASE WHEN Ending_Qty<T2.STANDARD_QTY/2 THEN 1 ELSE NULL END) YELLOW_FLAG
 FROM #TEMP T
LEFT JOIN 
---计算出当前时间点最畅销的3款SKU
(
SELECT * FROM (
SELECT 
A.DATEKEY,
A.SKU_ID,
MAX(A.SALES_AMT) AS SALES_AMT,
SUM(B.SALES_AMT) SUMX_SALES_AMT,
ROW_NUMBER() OVER(PARTITION BY A.DATEKEY ORDER BY SUM(B.SALES_AMT) DESC) RN
FROM
  ( SELECT
 DATEKEY, SKU_ID,SUM(SALES_AMT) AS SALES_AMT
FROM [FOODUNION].[DM].[FCT_KIDSWANT_DAILYSALES]
GROUP BY DATEKEY, SKU_ID) A
  LEFT JOIN (
  SELECT
 DATEKEY, SKU_ID,SUM(SALES_AMT) AS SALES_AMT
FROM [FOODUNION].[DM].[FCT_KIDSWANT_DAILYSALES]
GROUP BY DATEKEY, SKU_ID) B 
ON A.DATEKEY >= B.DATEKEY AND A.SKU_ID = B.SKU_ID
  GROUP BY  A.DATEKEY,A.SKU_ID
  ) A WHERE RN<=3
) T1 ON T1.Datekey=T.Datekey AND T1.SKU_ID=T.SKU_ID
LEFT JOIN 
(SELECT * FROM dm.Dim_Product_DISPLAY_Standard WHERE CHANNEL='KIDSWANT')T2 ON T.SKU_ID=T2.SKU_ID
GROUP BY T.Datekey,
T.Store_ID
) T

END

GO
