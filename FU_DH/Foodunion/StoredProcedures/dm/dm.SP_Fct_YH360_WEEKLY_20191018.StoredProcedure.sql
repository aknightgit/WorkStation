USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_YH360_WEEKLY_20191018]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE  [dm].[SP_Fct_YH360_WEEKLY_20191018]
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY 
  TRUNCATE TABLE dm.Fct_YH360_WEEKLY
   
   INSERT INTO dm.Fct_YH360_WEEKLY(
	[Year]
   ,[Week_NM]
   ,[Store_ID]
   ,[YH_categroy]
   ,[SALES_AMT]
   ,[SALES_QTY]
   ,[VOLUME]
   ,[DISCOUNTSALES_AMT]
   ,[Sales_Target]
   ,[SALES_AMT_LW]
   ,[SALES_QTY_LW]
   ,[VOLUME_LW]
   ,[DISCOUNTSALES_AMT_LW]
   ,[ACTUAL_SALES_DAYS]
   ,[ACTUAL_SALES_DAYS_LW]
   ,[FIRST_SALES_DATE]
   ,[IF_DISTRIBUTION_FLG]
   ,[IF_DISTRIBUTION_FLG_LW]
   ,[ACTUAL_INVENTORY_DAYS]
   ,[ACTUAL_INVENTORY_DAYS_LW]
   ,[SALES_SKU_QTY]
   ,[SALES_SKU_QTY_LW]
   ,[INVENTORY_SKU_QTY]
   ,[INVENTORY_SKU_QTY_LW]
   ,[INVENTORY_VOLUME]
   ,[INVENTORY_VOLUME_LW]
   ,[Create_Time]
,[Create_By]
,[Update_Time]
,[Update_By]
   ,[Week_Date_Period_end]
   )
   SELECT 
T1.Year,
T1.Week_NM,
T.Store_ID,
T2.YH_categroy,
T3.SALES_AMT,
T3.SALES_QTY,
T3.VOLUME,
T3.DISCOUNTSALES_AMT,
NULl AS Sales_Target,
T5.SALES_AMT_LW,
T5.SALES_QTY_LW,
T5.VOLUME_LW,
T5.DISCOUNTSALES_AMT_LW,
T6.ACTUAL_SALES_DAYS,
NULL AS ACTUAL_SALES_DAYS_LM,
T8.FIRST_SALES_DATE,
(CASE WHEN T8.FIRST_SALES_DATE IS NOT NULL THEN 1 ELSE 0 END) IF_DISTRIBUTION_FLG,
NULL AS  IF_DISTRIBUTION_FLG_LM,
T10.ACTUAL_INVENTORY_DAYS,
NULL AS ACTUAL_INVENTORY_DAYS_LM,
T3.SALES_SKU_QTY,
NULL AS SALES_SKU_QTY_LM,
T12.INVENTORY_SKU_QTY,
NULL AS INVENTORY_SKU_QTY_LM,
T12.INVENTORY_VOLUME,
NULL AS INVENTORY_VOLUME_LM
,GETDATE() AS [Create_Time]
,OBJECT_NAME(@@PROCID) AS [Create_By]
,GETDATE() AS [Update_Time]
,OBJECT_NAME(@@PROCID) AS [Update_By],
T16.Week_Date_Period_end
FROM [dm].[Dim_Store] T
CROSS JOIN (SELECT 
DISTINCT Year,Week_NM
FROM [FU_EDW].[Dim_Calendar] WHERE Year_Month>='201808' AND CAST(Date_NM AS DATE)<CAST(GETDATE() AS DATE) ) T1 --与时间维表YearMonth笛卡尔积，并取出当月天数和上月天数
CROSS JOIN (SELECT DISTINCT YH_categroy FROM [FU_EDW].[T_EDW_DIM_Product] WHERE YH_categroy IS NOT NULL)T2
LEFT JOIN (
--取销售金额By Month
SELECT
Store_ID,
YH_categroy,
[YEAR],
Week_NM,
SUM(SALES_AMT) SALES_AMT,
SUM(SALES_QTY) SALES_QTY,
SUM(DISCOUNTSALES_AMT) DISCOUNTSALES_AMT,
SUM(SC_Density_SKU_Ton_Num*Sales_QTY) VOLUME,
COUNT(DISTINCT SKU_ID) SALES_SKU_QTY 
FROM [dw].[Fct_YH_Sales_All]
LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
WHERE Sales_AMT>0
GROUP BY Store_ID,
YH_categroy,
[YEAR],
Week_NM
)T3 ON T.Store_ID=T3.Store_ID AND T1.[Year]=T3.[Year] AND T1.Week_NM = T3.Week_NM AND T2.YH_categroy=T3.YH_categroy
--LEFT JOIN (
----取销售目标
--SELECT
--LEFT(PERIOD,6)Year_Month,
--Store_ID, 
--'Ambient' YH_categroy,
--Ambient_Sales_Target Sales_Target 
--FROM [dw].[Fct_YH_Target]
--UNION ALL
--SELECT
--LEFT(PERIOD,6),
--Store_ID, 
--'Fresh' YH_categroy,
--Fresh_Sales_Target Sales_Target 
--select * FROM [dw].[Fct_YH_Target]
--)T4 ON T.Store_ID=T4.Store_ID AND T1.[Year]=T4.[Year] AND T1.Week_NM = T4.Week_NM AND T2.YH_categroy=T4.YH_categroy
LEFT JOIN (
--取上月销售金额
SELECT
Store_ID,
YH_categroy,
[YEAR],
Week_NM,
SUM(SALES_AMT) SALES_AMT_LW,
SUM(SALES_QTY) SALES_QTY_LW,
SUM(DISCOUNTSALES_AMT) DISCOUNTSALES_AMT_LW,
SUM(SC_Density_SKU_Ton_Num*SALES_QTY) VOLUME_LW,
COUNT(DISTINCT SKU_ID) SALES_SKU_QTY_LM  
FROM [dw].[Fct_YH_Sales_All]
LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(DATEADD(WEEK,1,Calendar_DT)  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
 WHERE Sales_AMT>0
GROUP BY Store_ID,
YH_categroy,
[YEAR],
Week_NM
)T5 ON T.Store_ID=T5.Store_ID AND T1.[Year]=T5.[Year] AND T1.Week_NM = T5.Week_NM AND T2.YH_categroy=T5.YH_categroy

LEFT JOIN (
--取实际销售天数
SELECT
Store_ID,
YH_categroy,
[YEAR],
Week_NM,
SUM(CASE WHEN SALES_AMT>0 THEN 1 ELSE 0 END) ACTUAL_SALES_DAYS
FROM (
SELECT
Store_ID,
YH_categroy,
[YEAR],
Week_NM,
SUM(Sales_AMT) Sales_AMT
FROM [dw].[Fct_YH_Sales_All]
LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)

GROUP BY Store_ID,
YH_categroy,
[YEAR],
Week_NM
) T
GROUP BY Store_ID,
YH_categroy,
[YEAR],
Week_NM
)T6 ON T.Store_ID=T6.Store_ID AND T1.[Year]=T6.[Year] AND T1.Week_NM = T6.Week_NM AND T2.YH_categroy=T6.YH_categroy
--LEFT JOIN (
----取上月实际销售天数
--SELECT
--Store_ID,
--YH_categroy,
--YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) YEAR_MONTH,
--SUM(CASE WHEN SALES_AMT>0 THEN 1 ELSE 0 END) ACTUAL_SALES_DAYS_LM
--FROM (
--SELECT
--Store_ID,
--YH_categroy,
--CALENDAR_DT,
--SUM(Sales_AMT) Sales_AMT
--FROM [dw].[Fct_YH_Sales_All]
--LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)

--GROUP BY Store_ID,
--YH_categroy,
--CALENDAR_DT
--) T
--GROUP BY Store_ID,
--YH_categroy,
--YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) 
--)T7 ON T.Store_ID=T7.Store_ID AND T1.[Year]=T7.[Year] AND T1.Week_NM = T7.Week_NM AND T2.YH_categroy=T7.YH_categroy
LEFT JOIN (
--取门店的第一次销售时间
SELECT 
Store_ID,
YH_Store_CD,
YH_CATEGROY,
FIRST_SALES_DATE,
(SELECT [YEAR] FROM FU_EDW.Dim_Calendar WHERE Date_ID = FIRST_SALES_DATE) AS [YEAR],
(SELECT [Week_NM] FROM FU_EDW.Dim_Calendar WHERE Date_ID = FIRST_SALES_DATE) AS [Week_NM]
FROM (
SELECT 
Store_ID,
YH_Store_CD,
YH_CATEGROY,
MIN(Calendar_DT) FIRST_SALES_DATE
FROM [dw].[Fct_YH_Sales_All]
WHERE Store_ID IS NOT NULL
GROUP BY 
Store_ID,
YH_Store_CD,
YH_CATEGROY
)T-- order by Store_ID
)T8 ON T.Store_ID=T8.Store_ID AND T1.[Year]=T8.[Year] AND T1.Week_NM = T8.Week_NM AND T2.YH_categroy=T8.YH_categroy
--LEFT JOIN (
----取上个月新推广的门店
--SELECT 
--Store_ID,
--YH_Store_CD,
--YH_CATEGROY,
--FIRST_SALES_DATE,
--YEAR(dateadd(MONTH,1,FIRST_SALES_DATE))*100+MONTH(dateadd(MONTH,1,FIRST_SALES_DATE)) YEAR_MONTH
--FROM (
--SELECT 
--Store_ID,
--YH_Store_CD,
--YH_CATEGROY,
--MIN(Calendar_DT) FIRST_SALES_DATE
--FROM [dw].[Fct_YH_Sales_All]
--LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
--GROUP BY 
--Store_ID,
--YH_Store_CD,
--YH_CATEGROY
--)T
--)T9 ON T.Store_ID=T9.Store_ID AND T1.[Year]=T9.[Year] AND T1.Week_NM = T9.Week_NM AND T2.YH_categroy=T9.YH_categroy
LEFT JOIN (
--取实际库存天数
SELECT 
Store_ID,
[YEAR],
Week_NM,
YH_categroy,
SUM(CASE WHEN Inventory_QTY>0 THEN 1 ELSE 0 END)ACTUAL_INVENTORY_DAYS
FROM (
SELECT 
T.Store_ID,
[YEAR],
Week_NM,
T1.YH_categroy,
SUM(Inventory_QTY)Inventory_QTY
FROM 
[dw].[Fct_YH_Inventory] T
LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
LEFT JOIN 
[FU_EDW].[T_EDW_DIM_Product] T1 ON T1.SKU_ID=T.SKU_ID
GROUP BY T.Store_ID,
[YEAR],
Week_NM,
T1.YH_categroy
)T
GROUP BY 
Store_ID,
[YEAR],
Week_NM,
YH_categroy
)T10 ON T.Store_ID=T10.Store_ID AND T1.[Year]=T10.[Year] AND T1.Week_NM = T10.Week_NM AND T2.YH_categroy=T10.YH_categroy
--LEFT JOIN (
----取上月实际库存天数
--SELECT 
--Store_ID,
--YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) YEAR_MONTH,
--YH_categroy,
--SUM(CASE WHEN Inventory_QTY>0 THEN 1 ELSE 0 END)ACTUAL_INVENTORY_DAYS_LM
--FROM (
--SELECT 
--T.Store_ID,
--T.Calendar_DT,
--T1.YH_categroy,
--SUM(Inventory_QTY)Inventory_QTY
--FROM 
--[dw].[Fct_YH_Inventory] T
--LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
--LEFT JOIN 
--[FU_EDW].[T_EDW_DIM_Product] T1 ON T1.SKU_ID=T.SKU_ID
--GROUP BY T.Store_ID,
--T.Calendar_DT,
--T1.YH_categroy
--)T
--GROUP BY 
--Store_ID,
--YH_categroy,
--YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) 
--)T11 ON T.Store_ID=T11.Store_ID AND T1.[Year]=T11.[Year] AND T1.Week_NM = T11.Week_NM AND T2.YH_categroy=T11.YH_categroy
LEFT JOIN (
--取有库存的SKU数
SELECT 
T.Store_ID,
[YEAR],
Week_NM,
T1.YH_categroy,
SUM(T.INVENTORY_QTY*T1.[Density_SKU_Ton_Num])INVENTORY_VOLUME,
COUNT(DISTINCT T.SKU_ID) INVENTORY_SKU_QTY
FROM 
[dw].[Fct_YH_Inventory] T 
LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
LEFT JOIN 
[FU_EDW].[T_EDW_DIM_Product] T1 ON T1.SKU_ID=T.SKU_ID  WHERE Inventory_QTY>0
GROUP BY T.Store_ID,
[YEAR],
Week_NM,
T1.YH_categroy
)T12 ON T.Store_ID=T12.Store_ID AND T1.[Year]=T12.[Year] AND T1.Week_NM = T12.Week_NM AND T2.YH_categroy=T12.YH_categroy
--LEFT JOIN (
----取上月有库存的SKU数
--SELECT 
--T.Store_ID,
--YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) YEAR_MONTH,
--T1.YH_categroy,
--SUM(T.INVENTORY_QTY*T1.[Density_SKU_Ton_Num])INVENTORY_VOLUME_LM,
--COUNT(DISTINCT T.SKU_ID) INVENTORY_SKU_QTY_LM
--FROM 
--[dw].[Fct_YH_Inventory] T 
--LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
--LEFT JOIN 
--[FU_EDW].[T_EDW_DIM_Product] T1 ON T1.SKU_ID=T.SKU_ID  WHERE Inventory_QTY>0
--GROUP BY T.Store_ID,
--YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)),
--T1.YH_categroy
--)T13 ON T.Store_ID=T13.Store_ID AND T1.[Year]=T13.[Year] AND T1.Week_NM = T13.Week_NM AND T2.YH_categroy=T13.YH_categroy
LEFT JOIN [dm].[Dim_Store_Flg] T14 ON T14.Store_ID=T.Store_ID
LEFT JOIN (
--取每家门店的第一次销售时间，分布到每月，用来计算从什么时候开始有销售。
SELECT 
Store_ID,
YH_Store_CD,
YH_CATEGROY,
FIRST_SALES_DATE,
LEFT(FIRST_SALES_DATE,6) FIRST_SALES_YEAR_MONTH
FROM (
SELECT 
Store_ID,
YH_Store_CD,
YH_CATEGROY,
MIN(Calendar_DT) FIRST_SALES_DATE
FROM [dw].[Fct_YH_Sales_All]
LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
GROUP BY 
Store_ID,
YH_Store_CD,
YH_CATEGROY
)T
)T15 ON T.Store_ID=T15.Store_ID  AND T2.YH_categroy=T15.YH_categroy
LEFT JOIN (
--取每周的周日
SELECT distinct year,Week_NM,Week_Date_Period_end
  FROM [Foodunion].[FU_EDW].[Dim_Calendar]
)T16 ON T16.Year=T1.Year AND T16.Week_NM=T1.Week_NM
WHERE T14.FIRST_SALES_DATE IS NOT NULL AND T.Channel_Account = 'YH'

UNION ALL  --创建维度Total
SELECT 
T1.Year,
T1.Week_NM,
T.Store_ID,
'Total'YH_categroy,
T3.SALES_AMT,
T3.SALES_QTY,
T3.VOLUME,
T3.DISCOUNTSALES_AMT,
NULL AS Sales_Target,
T5.SALES_AMT_LW,
T5.SALES_QTY_LW,
T5.VOLUME_LW,
T5.DISCOUNTSALES_AMT_LW,
T6.ACTUAL_SALES_DAYS,
NULL AS ACTUAL_SALES_DAYS_LM,
T8.FIRST_SALES_DATE,
(CASE WHEN T8.FIRST_SALES_DATE IS NOT NULL THEN 1 ELSE 0 END) IF_DISTRIBUTION_FLG,
NULL AS  IF_DISTRIBUTION_FLG_LM,
T10.ACTUAL_INVENTORY_DAYS,
NULL AS ACTUAL_INVENTORY_DAYS_LM,
T3.SALES_SKU_QTY,
NULL AS SALES_SKU_QTY_LM,
T12.INVENTORY_SKU_QTY,
NULL AS INVENTORY_SKU_QTY_LM,
T12.INVENTORY_VOLUME,
NULL AS INVENTORY_VOLUME_LM
,GETDATE() AS [Create_Time]
,OBJECT_NAME(@@PROCID) AS [Create_By]
,GETDATE() AS [Update_Time]
,OBJECT_NAME(@@PROCID) AS [Update_By],
T16.Week_Date_Period_end
FROM [dm].[Dim_Store] T
CROSS JOIN (SELECT 
DISTINCT Year,Week_NM
FROM [FU_EDW].[Dim_Calendar] WHERE Year_Month>='201808'AND CAST(Date_NM AS DATE)<CAST(GETDATE() AS DATE)) T1 --与时间维表YearMonth笛卡尔积，并取出当月天数和上月天数
LEFT JOIN (
--取销售金额By Month
SELECT
Store_ID,
[YEAR],
Week_NM,
SUM(SALES_AMT) SALES_AMT,
SUM(SALES_QTY) SALES_QTY,
SUM(DISCOUNTSALES_AMT) DISCOUNTSALES_AMT,
SUM(SC_Density_SKU_Ton_Num*Sales_QTY) VOLUME,
COUNT(DISTINCT SKU_ID) SALES_SKU_QTY 
FROM [dw].[Fct_YH_Sales_All] 
LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE) WHERE Sales_AMT>0
GROUP BY Store_ID,
[YEAR],
Week_NM
)T3 ON T.Store_ID=T3.Store_ID AND T1.[Year]=T3.[Year] AND T1.Week_NM = T3.Week_NM
--LEFT JOIN (
----取销售目标
--SELECT
--LEFT(PERIOD,6)Year_Month,
--Store_ID, 
--Sales_Target 
--FROM [dw].[Fct_YH_Target]
--)T4 ON T.Store_ID=T4.Store_ID AND T1.[Year]=T4.[Year] AND T1.Week_NM = T4.Week_NM
LEFT JOIN (
--取上月销售金额
SELECT
Store_ID,
[YEAR],
Week_NM,
SUM(SALES_AMT) SALES_AMT_LW,
SUM(SALES_QTY) SALES_QTY_LW,
SUM(DISCOUNTSALES_AMT) DISCOUNTSALES_AMT_LW,
SUM(SC_Density_SKU_Ton_Num*SALES_QTY) VOLUME_LW,
COUNT(DISTINCT SKU_ID) SALES_SKU_QTY_LM  
FROM [dw].[Fct_YH_Sales_All]
LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(DATEADD(WEEK,1,Calendar_DT)  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE) WHERE Sales_AMT>0
GROUP BY Store_ID,
[YEAR],
Week_NM
)T5 ON T.Store_ID=T5.Store_ID AND T1.[Year]=T5.[Year] AND T1.Week_NM = T5.Week_NM
LEFT JOIN (
--取实际销售天数
SELECT
Store_ID,
[YEAR],
Week_NM,
SUM(CASE WHEN SALES_AMT>0 THEN 1 ELSE 0 END) ACTUAL_SALES_DAYS
FROM (
SELECT
Store_ID,
[YEAR],
Week_NM,
SUM(Sales_AMT) Sales_AMT
FROM [dw].[Fct_YH_Sales_All]
LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
GROUP BY Store_ID,
[YEAR],
Week_NM
) T
GROUP BY Store_ID,
[YEAR],
Week_NM
)T6 ON T.Store_ID=T6.Store_ID AND T1.[Year]=T6.[Year] AND T1.Week_NM = T6.Week_NM
--LEFT JOIN (
----取上月实际销售天数
--SELECT
--Store_ID,
--YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) YEAR_MONTH,
--SUM(CASE WHEN SALES_AMT>0 THEN 1 ELSE 0 END) ACTUAL_SALES_DAYS_LM
--FROM (
--SELECT
--Store_ID,
--CALENDAR_DT,
--SUM(Sales_AMT) Sales_AMT
--FROM [dw].[Fct_YH_Sales_All]
--LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
--GROUP BY Store_ID,
--CALENDAR_DT
--) T
--GROUP BY Store_ID,
--YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) 
--)T7 ON T.Store_ID=T7.Store_ID AND T1.[Year]=T7.[Year] AND T1.Week_NM = T7.Week_NM
LEFT JOIN (
--取门店的第一次销售时间
SELECT 
Store_ID,
YH_Store_CD,
FIRST_SALES_DATE,
(SELECT [YEAR] FROM FU_EDW.Dim_Calendar WHERE Date_ID = FIRST_SALES_DATE) AS [YEAR],
(SELECT [Week_NM] FROM FU_EDW.Dim_Calendar WHERE Date_ID = FIRST_SALES_DATE) AS [Week_NM]
--LEFT(FIRST_SALES_DATE,6) YEAR_MONTH
FROM (
SELECT 
Store_ID,
YH_Store_CD,
MIN(Calendar_DT) FIRST_SALES_DATE
FROM [dw].[Fct_YH_Sales_All]
LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
GROUP BY 
Store_ID,
YH_Store_CD
)T
)T8 ON T.Store_ID=T8.Store_ID-- AND T1.[Year]=T8.[Year] AND T1.Week_NM = T8.Week_NM
--LEFT JOIN (
----取上个月新推广的门店
--SELECT 
--Store_ID,
--YH_Store_CD,
--FIRST_SALES_DATE,
--YEAR(dateadd(MONTH,1,FIRST_SALES_DATE))*100+MONTH(dateadd(MONTH,1,FIRST_SALES_DATE)) YEAR_MONTH
--FROM (
--SELECT 
--Store_ID,
--YH_Store_CD,
--MIN(Calendar_DT) FIRST_SALES_DATE
--FROM [dw].[Fct_YH_Sales_All]
--LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
--GROUP BY 
--Store_ID,
--YH_Store_CD
--)T
--)T9 ON T.Store_ID=T9.Store_ID AND T1.[Year]=T9.[Year] AND T1.Week_NM = T9.Week_NM
LEFT JOIN (
--取实际库存天数
SELECT 
Store_ID,
[YEAR],
Week_NM,
SUM(CASE WHEN Inventory_QTY>0 THEN 1 ELSE 0 END)ACTUAL_INVENTORY_DAYS
FROM (
SELECT 
T.Store_ID,
[YEAR],
Week_NM,
SUM(Inventory_QTY)Inventory_QTY
FROM 
[dw].[Fct_YH_Inventory] T
LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
LEFT JOIN 
[FU_EDW].[T_EDW_DIM_Product] T1 ON T1.SKU_ID=T.SKU_ID
GROUP BY T.Store_ID,
[YEAR],
Week_NM
)T
GROUP BY 
Store_ID,
[YEAR],
Week_NM
)T10 ON T.Store_ID=T10.Store_ID AND T1.[Year]=T10.[Year] AND T1.Week_NM = T10.Week_NM
--LEFT JOIN (
----取上月实际库存天数
--SELECT 
--Store_ID,
--YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) YEAR_MONTH,
--SUM(CASE WHEN Inventory_QTY>0 THEN 1 ELSE 0 END)ACTUAL_INVENTORY_DAYS_LM
--FROM (
--SELECT 
--T.Store_ID,
--T.Calendar_DT,
--SUM(Inventory_QTY)Inventory_QTY
--FROM 
--[dw].[Fct_YH_Inventory] T
--LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
--LEFT JOIN 
--[FU_EDW].[T_EDW_DIM_Product] T1 ON T1.SKU_ID=T.SKU_ID
--GROUP BY T.Store_ID,
--T.Calendar_DT
--)T
--GROUP BY 
--Store_ID,
--YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) 
--)T11 ON T.Store_ID=T11.Store_ID AND T1.[Year]=T11.[Year] AND T1.Week_NM = T11.Week_NM
LEFT JOIN (
--取有库存的SKU数
SELECT 
T.Store_ID,
[YEAR],
Week_NM,
SUM(T.INVENTORY_QTY*T1.[Density_SKU_Ton_Num])INVENTORY_VOLUME,
COUNT(DISTINCT T.SKU_ID) INVENTORY_SKU_QTY
FROM 
[dw].[Fct_YH_Inventory] T 
LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
LEFT JOIN 
[FU_EDW].[T_EDW_DIM_Product] T1 ON T1.SKU_ID=T.SKU_ID  WHERE Inventory_QTY>0
GROUP BY T.Store_ID,
[YEAR],
Week_NM
)T12 ON T.Store_ID=T12.Store_ID AND T1.[Year]=T12.[Year] AND T1.Week_NM = T12.Week_NM
--LEFT JOIN (
----取上月有库存的SKU数
--SELECT 
--T.Store_ID,
--YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) YEAR_MONTH,
--SUM(T.INVENTORY_QTY*T1.[Density_SKU_Ton_Num])INVENTORY_VOLUME_LM,
--COUNT(DISTINCT T.SKU_ID) INVENTORY_SKU_QTY_LM
--FROM 
--[dw].[Fct_YH_Inventory] T 
--LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
--LEFT JOIN 
--[FU_EDW].[T_EDW_DIM_Product] T1 ON T1.SKU_ID=T.SKU_ID  WHERE Inventory_QTY>0
--GROUP BY T.Store_ID,
--YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT))
--)T13 ON T.Store_ID=T13.Store_ID AND T1.[Year]=T13.[Year] AND T1.Week_NM = T13.Week_NM
LEFT JOIN [dm].[Dim_Store_Flg] T14 ON T14.Store_ID=T.Store_ID
LEFT JOIN (
--取每家门店的第一次销售时间，分布到每月，用来计算从什么时候开始有销售。
SELECT 
Store_ID,
YH_Store_CD,
FIRST_SALES_DATE,
LEFT(FIRST_SALES_DATE,6) FIRST_SALES_YEAR_MONTH
FROM (
SELECT 
Store_ID,
YH_Store_CD,
MIN(Calendar_DT) FIRST_SALES_DATE
FROM [dw].[Fct_YH_Sales_All]
LEFT JOIN [FU_EDW].[Dim_Calendar] ON CAST(Calendar_DT  AS DATE) = CAST(CAST(Date_ID AS VARCHAR) AS DATE)
GROUP BY 
Store_ID,
YH_Store_CD
)T
)T15 ON T.Store_ID=T15.Store_ID
LEFT JOIN (
--取每周的周日
SELECT distinct year,Week_NM,Week_Date_Period_end
  FROM [Foodunion].[FU_EDW].[Dim_Calendar]
)T16 ON T16.Year=T1.Year AND T16.Week_NM=T1.Week_NM
WHERE T14.FIRST_SALES_DATE IS NOT NULL AND T.Channel_Account = 'YH'
   END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
