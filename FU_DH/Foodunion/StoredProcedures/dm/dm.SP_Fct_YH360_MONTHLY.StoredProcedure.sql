USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_YH360_MONTHLY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dm].[SP_Fct_YH360_MONTHLY]
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY 
  TRUNCATE TABLE dm.Fct_YH360_MONTHLY
   
   INSERT INTO dm.Fct_YH360_MONTHLY(
Year_Month,
MONTH_DAYS,
MONTH_DAYS_LM,
Store_ID,
YH_categroy,
SALES_AMT,
SALES_QTY,
VOLUME,
DISCOUNTSALES_AMT,
Sales_Target,
SALES_AMT_LM,
SALES_QTY_LM,
VOLUME_LM,
DISCOUNTSALES_AMT_LM,
ACTUAL_SALES_DAYS,
ACTUAL_SALES_DAYS_LM,
FIRST_SALES_DATE,
IF_DISTRIBUTION_FLG,
IF_DISTRIBUTION_FLG_LM,
ACTUAL_INVENTORY_DAYS,
ACTUAL_INVENTORY_DAYS_LM,
SALES_SKU_QTY,
SALES_SKU_QTY_LM,
INVENTORY_SKU_QTY,
INVENTORY_SKU_QTY_LM,
INVENTORY_VOLUME,
INVENTORY_VOLUME_LM,
[Create_Time],
[Create_By]	 ,
[Update_Time],
[Update_By]	
   )
   SELECT 
TRIM(CAST(T1.Year_Month AS CHAR))+'01',
CASE WHEN T1.Year_Month>T15.FIRST_SALES_YEAR_MONTH THEN T1.MONTH_DAYS
WHEN T1.Year_Month=T15.FIRST_SALES_YEAR_MONTH THEN T1.MONTH_DAYS-DAY( T8.FIRST_SALES_DATE)+1
ELSE  0 END MONTH_DAYS,
T1.MONTH_DAYS_LM,
T.Store_ID,
T2.Product_Sort,
T3.SALES_AMT,
T3.SALES_QTY,
T3.VOLUME,
T3.DISCOUNTSALES_AMT,
T4.Sales_Target,
T5.SALES_AMT_LM,
T5.SALES_QTY_LM,
T5.VOLUME_LM,
T5.DISCOUNTSALES_AMT_LM,
T6.ACTUAL_SALES_DAYS,
T7.ACTUAL_SALES_DAYS_LM,
T8.FIRST_SALES_DATE,
(CASE WHEN T8.FIRST_SALES_DATE IS NOT NULL THEN 1 ELSE 0 END) IF_DISTRIBUTION_FLG,
(CASE WHEN T9.FIRST_SALES_DATE IS NOT NULL THEN 1 ELSE 0 END) IF_DISTRIBUTION_FLG_LM,
T10.ACTUAL_INVENTORY_DAYS,
T11.ACTUAL_INVENTORY_DAYS_LM,
T3.SALES_SKU_QTY,
T5.SALES_SKU_QTY_LM,
T12.INVENTORY_SKU_QTY,
T13.INVENTORY_SKU_QTY_LM,
T12.INVENTORY_VOLUME,
T13.INVENTORY_VOLUME_LM
,GETDATE() AS [Create_Time]
,OBJECT_NAME(@@PROCID) AS [Create_By]
,GETDATE() AS [Update_Time]
,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM [dm].[Dim_Store] T
CROSS JOIN (SELECT 
DISTINCT Year_Month ,
day(dateadd(month, datediff(month, 0, dateadd(month, 1, date_nm)), -1)) MONTH_DAYS,
DAY(DATEADD(DAY,-DAY(Date_NM),Date_NM)) MONTH_DAYS_LM 
FROM [FU_EDW].[Dim_Calendar] WHERE Year_Month>='201808' AND CAST(Date_NM AS DATE)<CAST(GETDATE() AS DATE) ) T1 --与时间维表YearMonth笛卡尔积，并取出当月天数和上月天数
CROSS JOIN (SELECT DISTINCT Product_Sort FROM dm.Dim_Product WHERE Product_Sort IS NOT NULL)T2
LEFT JOIN (
--取销售金额By Month
SELECT
Store_ID,
YH_categroy,
LEFT(CALENDAR_DT,6) YEAR_MONTH,
SUM(SALES_AMT) SALES_AMT,
SUM(SALES_QTY) SALES_QTY,
SUM(DISCOUNTSALES_AMT) DISCOUNTSALES_AMT,
SUM(SC_Density_SKU_Ton_Num*Sales_QTY) VOLUME,
COUNT(DISTINCT SKU_ID) SALES_SKU_QTY 
FROM [dw].[Fct_YH_Sales_All] --WHERE Sales_AMT>0
GROUP BY Store_ID,
YH_categroy,
LEFT(CALENDAR_DT,6) 
)T3 ON T.Store_ID=T3.Store_ID AND T1.Year_Month=T3.YEAR_MONTH AND T2.Product_Sort=T3.YH_categroy
LEFT JOIN (
--取销售目标
SELECT
LEFT(PERIOD,6)Year_Month,
Store_ID, 
'Ambient' YH_categroy,
Ambient_Sales_Target Sales_Target 
FROM [dw].[Fct_YH_Target]
UNION ALL
SELECT
LEFT(PERIOD,6),
Store_ID, 
'Fresh' YH_categroy,
Fresh_Sales_Target Sales_Target 
FROM [dw].[Fct_YH_Target]
)T4 ON T.Store_ID=T4.Store_ID AND T1.Year_Month=T4.YEAR_MONTH AND T2.Product_Sort=T4.YH_categroy
LEFT JOIN (
--取上月销售金额
SELECT
Store_ID,
YH_categroy,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) YEAR_MONTH,
SUM(SALES_AMT) SALES_AMT_LM,
SUM(SALES_QTY) SALES_QTY_LM,
SUM(DISCOUNTSALES_AMT) DISCOUNTSALES_AMT_LM,
SUM(SC_Density_SKU_Ton_Num*SALES_QTY) VOLUME_LM,
COUNT(DISTINCT SKU_ID) SALES_SKU_QTY_LM  
FROM [dw].[Fct_YH_Sales_All] WHERE Sales_AMT>0
GROUP BY Store_ID,
YH_categroy,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT))
)T5 ON T.Store_ID=T5.Store_ID AND T1.Year_Month=T5.YEAR_MONTH AND T2.Product_Sort=T5.YH_categroy
LEFT JOIN (
--取实际销售天数
SELECT
Store_ID,
YH_categroy,
LEFT(CALENDAR_DT,6) YEAR_MONTH,
SUM(CASE WHEN SALES_AMT>0 THEN 1 ELSE 0 END) ACTUAL_SALES_DAYS
FROM (
SELECT
Store_ID,
YH_categroy,
CALENDAR_DT,
SUM(Sales_AMT) Sales_AMT
FROM [dw].[Fct_YH_Sales_All]
GROUP BY Store_ID,
YH_categroy,
CALENDAR_DT
) T
GROUP BY Store_ID,
YH_categroy,
LEFT(CALENDAR_DT,6)
)T6 ON T.Store_ID=T6.Store_ID AND T1.Year_Month=T6.YEAR_MONTH AND T2.Product_Sort=T6.YH_categroy
LEFT JOIN (
--取上月实际销售天数
SELECT
Store_ID,
YH_categroy,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) YEAR_MONTH,
SUM(CASE WHEN SALES_AMT>0 THEN 1 ELSE 0 END) ACTUAL_SALES_DAYS_LM
FROM (
SELECT
Store_ID,
YH_categroy,
CALENDAR_DT,
SUM(Sales_AMT) Sales_AMT
FROM [dw].[Fct_YH_Sales_All]
GROUP BY Store_ID,
YH_categroy,
CALENDAR_DT
) T
GROUP BY Store_ID,
YH_categroy,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) 
)T7 ON T.Store_ID=T7.Store_ID AND T1.Year_Month=T7.YEAR_MONTH AND T2.Product_Sort=T7.YH_categroy
LEFT JOIN (
--取门店的第一次销售时间
SELECT 
Store_ID,
YH_Store_CD,
YH_CATEGROY,
FIRST_SALES_DATE,
LEFT(FIRST_SALES_DATE,6) YEAR_MONTH
FROM (
SELECT 
Store_ID,
YH_Store_CD,
YH_CATEGROY,
MIN(Calendar_DT) FIRST_SALES_DATE
FROM [dw].[Fct_YH_Sales_All]
GROUP BY 
Store_ID,
YH_Store_CD,
YH_CATEGROY
)T
)T8 ON T.Store_ID=T8.Store_ID AND T1.Year_Month=T8.YEAR_MONTH AND T2.Product_Sort=T8.YH_categroy
LEFT JOIN (
--取上个月新推广的门店
SELECT 
Store_ID,
YH_Store_CD,
YH_CATEGROY,
FIRST_SALES_DATE,
YEAR(dateadd(MONTH,1,FIRST_SALES_DATE))*100+MONTH(dateadd(MONTH,1,FIRST_SALES_DATE)) YEAR_MONTH
FROM (
SELECT 
Store_ID,
YH_Store_CD,
YH_CATEGROY,
MIN(Calendar_DT) FIRST_SALES_DATE
FROM [dw].[Fct_YH_Sales_All]
GROUP BY 
Store_ID,
YH_Store_CD,
YH_CATEGROY
)T
)T9 ON T.Store_ID=T9.Store_ID AND T1.Year_Month=T9.YEAR_MONTH AND T2.Product_Sort=T9.YH_categroy
LEFT JOIN (
--取实际库存天数
SELECT 
Store_ID,
YEAR(Calendar_DT)*100+MONTH(Calendar_DT) YEAR_MONTH,
Product_Sort,
SUM(CASE WHEN Inventory_QTY>0 THEN 1 ELSE 0 END)ACTUAL_INVENTORY_DAYS
FROM (
SELECT 
T.Store_ID,
T.Calendar_DT,
T1.Product_Sort,
SUM(Inventory_QTY)Inventory_QTY
FROM 
[dw].[Fct_YH_Inventory] T
LEFT JOIN 
dm.Dim_Product T1 ON T1.SKU_ID=T.SKU_ID
GROUP BY T.Store_ID,
T.Calendar_DT,
T1.Product_Sort
)T
GROUP BY 
Store_ID,
YEAR(Calendar_DT)*100+MONTH(Calendar_DT),
Product_Sort
)T10 ON T.Store_ID=T10.Store_ID AND T1.Year_Month=T10.YEAR_MONTH AND T2.Product_Sort=T10.Product_Sort
LEFT JOIN (
--取上月实际库存天数
SELECT 
Store_ID,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) YEAR_MONTH,
Product_Sort,
SUM(CASE WHEN Inventory_QTY>0 THEN 1 ELSE 0 END)ACTUAL_INVENTORY_DAYS_LM
FROM (
SELECT 
T.Store_ID,
T.Calendar_DT,
T1.Product_Sort,
SUM(Inventory_QTY)Inventory_QTY
FROM 
[dw].[Fct_YH_Inventory] T
LEFT JOIN 
dm.Dim_Product T1 ON T1.SKU_ID=T.SKU_ID
GROUP BY T.Store_ID,
T.Calendar_DT,
T1.Product_Sort
)T
GROUP BY 
Store_ID,
Product_Sort,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) 
)T11 ON T.Store_ID=T11.Store_ID AND T1.Year_Month=T11.YEAR_MONTH AND T2.Product_Sort=T11.Product_Sort
LEFT JOIN (
--取有库存的SKU数
SELECT 
T.Store_ID,
YEAR(Calendar_DT)*100+MONTH(Calendar_DT) YEAR_MONTH,
T1.Product_Sort,
SUM(T.INVENTORY_QTY*T1.Sale_Unit_Weight_KG/1000)INVENTORY_VOLUME,
COUNT(DISTINCT T.SKU_ID) INVENTORY_SKU_QTY
FROM 
[dw].[Fct_YH_Inventory] T 
LEFT JOIN 
dm.Dim_Product T1 ON T1.SKU_ID=T.SKU_ID  WHERE Inventory_QTY>0
GROUP BY T.Store_ID,
YEAR(Calendar_DT)*100+MONTH(Calendar_DT),
T1.Product_Sort
)T12 ON T.Store_ID=T12.Store_ID AND T1.Year_Month=T12.YEAR_MONTH AND T2.Product_Sort=T12.Product_Sort
LEFT JOIN (
--取上月有库存的SKU数
SELECT 
T.Store_ID,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) YEAR_MONTH,
T1.Product_Sort,
SUM(T.INVENTORY_QTY*T1.Sale_Unit_Weight_KG/1000)INVENTORY_VOLUME_LM,
COUNT(DISTINCT T.SKU_ID) INVENTORY_SKU_QTY_LM
FROM 
[dw].[Fct_YH_Inventory] T 
LEFT JOIN 
dm.Dim_Product T1 ON T1.SKU_ID=T.SKU_ID  WHERE Inventory_QTY>0
GROUP BY T.Store_ID,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)),
T1.Product_Sort
)T13 ON T.Store_ID=T13.Store_ID AND T1.Year_Month=T13.YEAR_MONTH AND T2.Product_Sort=T13.Product_Sort
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
GROUP BY 
Store_ID,
YH_Store_CD,
YH_CATEGROY
)T
)T15 ON T.Store_ID=T15.Store_ID  AND T2.Product_Sort=T15.YH_categroy
WHERE T14.FIRST_SALES_DATE IS NOT NULL  AND T.Channel_Account = 'YH'

UNION ALL  --创建维度Total
SELECT 
TRIM(CAST(T1.Year_Month AS CHAR))+'01',
CASE WHEN T1.Year_Month>T15.FIRST_SALES_YEAR_MONTH THEN T1.MONTH_DAYS
WHEN T1.Year_Month=T15.FIRST_SALES_YEAR_MONTH THEN T1.MONTH_DAYS-DAY( T8.FIRST_SALES_DATE)+1
ELSE  0 END MONTH_DAYS,
T1.MONTH_DAYS_LM,
T.Store_ID,
'Total'YH_categroy,
T3.SALES_AMT,
T3.SALES_QTY,
T3.VOLUME,
T3.DISCOUNTSALES_AMT,
T4.Sales_Target,
T5.SALES_AMT_LM,
T5.SALES_QTY_LM,
T5.VOLUME_LM,
T5.DISCOUNTSALES_AMT_LM,
T6.ACTUAL_SALES_DAYS,
T7.ACTUAL_SALES_DAYS_LM,
T8.FIRST_SALES_DATE,
(CASE WHEN T8.FIRST_SALES_DATE IS NOT NULL THEN 1 ELSE 0 END) IF_DISTRIBUTION_FLG,
(CASE WHEN T9.FIRST_SALES_DATE IS NOT NULL THEN 1 ELSE 0 END) IF_DISTRIBUTION_FLG_LM,
T10.ACTUAL_INVENTORY_DAYS,
T11.ACTUAL_INVENTORY_DAYS_LM,
T3.SALES_SKU_QTY,
T5.SALES_SKU_QTY_LM,
T12.INVENTORY_SKU_QTY,
T13.INVENTORY_SKU_QTY_LM,
T12.INVENTORY_VOLUME,
T13.INVENTORY_VOLUME_LM
,GETDATE() AS [Create_Time]
,OBJECT_NAME(@@PROCID) AS [Create_By]
,GETDATE() AS [Update_Time]
,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM [dm].[Dim_Store] T
CROSS JOIN (SELECT 
DISTINCT Year_Month ,
day(dateadd(month, datediff(month, 0, dateadd(month, 1, date_nm)), -1)) MONTH_DAYS,
DAY(DATEADD(DAY,-DAY(Date_NM),Date_NM)) MONTH_DAYS_LM 
FROM [FU_EDW].[Dim_Calendar] WHERE Year_Month>='201808' AND CAST(Date_NM AS DATE)<CAST(GETDATE() AS DATE) ) T1 --与时间维表YearMonth笛卡尔积，并取出当月天数和上月天数
LEFT JOIN (
--取销售金额By Month
SELECT
Store_ID,
LEFT(CALENDAR_DT,6) YEAR_MONTH,
SUM(SALES_AMT) SALES_AMT,
SUM(SALES_QTY) SALES_QTY,
SUM(DISCOUNTSALES_AMT) DISCOUNTSALES_AMT,
SUM(SC_Density_SKU_Ton_Num*Sales_QTY) VOLUME,
COUNT(DISTINCT SKU_ID) SALES_SKU_QTY 
FROM [dw].[Fct_YH_Sales_All] --WHERE Sales_AMT>0
GROUP BY Store_ID,
LEFT(CALENDAR_DT,6) 
)T3 ON T.Store_ID=T3.Store_ID AND T1.Year_Month=T3.YEAR_MONTH
LEFT JOIN (
--取销售目标
SELECT
LEFT(PERIOD,6)Year_Month,
Store_ID, 
Sales_Target 
FROM [dw].[Fct_YH_Target]
)T4 ON T.Store_ID=T4.Store_ID AND T1.Year_Month=T4.YEAR_MONTH 
LEFT JOIN (
--取上月销售金额
SELECT
Store_ID,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) YEAR_MONTH,
SUM(SALES_AMT) SALES_AMT_LM,
SUM(SALES_QTY) SALES_QTY_LM,
SUM(DISCOUNTSALES_AMT) DISCOUNTSALES_AMT_LM,
SUM(SC_Density_SKU_Ton_Num*SALES_QTY) VOLUME_LM,
COUNT(DISTINCT SKU_ID) SALES_SKU_QTY_LM  
FROM [dw].[Fct_YH_Sales_All] WHERE Sales_AMT>0
GROUP BY Store_ID,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT))
)T5 ON T.Store_ID=T5.Store_ID AND T1.Year_Month=T5.YEAR_MONTH 
LEFT JOIN (
--取实际销售天数
SELECT
Store_ID,
LEFT(CALENDAR_DT,6) YEAR_MONTH,
SUM(CASE WHEN SALES_AMT>0 THEN 1 ELSE 0 END) ACTUAL_SALES_DAYS
FROM (
SELECT
Store_ID,
CALENDAR_DT,
SUM(Sales_AMT) Sales_AMT
FROM [dw].[Fct_YH_Sales_All]
GROUP BY Store_ID,
CALENDAR_DT
) T
GROUP BY Store_ID,
LEFT(CALENDAR_DT,6)
)T6 ON T.Store_ID=T6.Store_ID AND T1.Year_Month=T6.YEAR_MONTH 
LEFT JOIN (
--取上月实际销售天数
SELECT
Store_ID,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) YEAR_MONTH,
SUM(CASE WHEN SALES_AMT>0 THEN 1 ELSE 0 END) ACTUAL_SALES_DAYS_LM
FROM (
SELECT
Store_ID,
CALENDAR_DT,
SUM(Sales_AMT) Sales_AMT
FROM [dw].[Fct_YH_Sales_All]
GROUP BY Store_ID,
CALENDAR_DT
) T
GROUP BY Store_ID,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) 
)T7 ON T.Store_ID=T7.Store_ID AND T1.Year_Month=T7.YEAR_MONTH 
LEFT JOIN (
--取门店的第一次销售时间
SELECT 
Store_ID,
YH_Store_CD,
FIRST_SALES_DATE,
LEFT(FIRST_SALES_DATE,6) YEAR_MONTH
FROM (
SELECT 
Store_ID,
YH_Store_CD,
MIN(Calendar_DT) FIRST_SALES_DATE
FROM [dw].[Fct_YH_Sales_All]
GROUP BY 
Store_ID,
YH_Store_CD
)T
)T8 ON T.Store_ID=T8.Store_ID AND T1.Year_Month=T8.YEAR_MONTH
LEFT JOIN (
--取上个月新推广的门店
SELECT 
Store_ID,
YH_Store_CD,
FIRST_SALES_DATE,
YEAR(dateadd(MONTH,1,FIRST_SALES_DATE))*100+MONTH(dateadd(MONTH,1,FIRST_SALES_DATE)) YEAR_MONTH
FROM (
SELECT 
Store_ID,
YH_Store_CD,
MIN(Calendar_DT) FIRST_SALES_DATE
FROM [dw].[Fct_YH_Sales_All]
GROUP BY 
Store_ID,
YH_Store_CD
)T
)T9 ON T.Store_ID=T9.Store_ID AND T1.Year_Month=T9.YEAR_MONTH 
LEFT JOIN (
--取实际库存天数
SELECT 
Store_ID,
YEAR(Calendar_DT)*100+MONTH(Calendar_DT) YEAR_MONTH,
SUM(CASE WHEN Inventory_QTY>0 THEN 1 ELSE 0 END)ACTUAL_INVENTORY_DAYS
FROM (
SELECT 
T.Store_ID,
T.Calendar_DT,
SUM(Inventory_QTY)Inventory_QTY
FROM 
[dw].[Fct_YH_Inventory] T
LEFT JOIN 
[dm].[Dim_Product] T1 ON T1.SKU_ID=T.SKU_ID
GROUP BY T.Store_ID,
T.Calendar_DT
)T
GROUP BY 
Store_ID,
YEAR(Calendar_DT)*100+MONTH(Calendar_DT)
)T10 ON T.Store_ID=T10.Store_ID AND T1.Year_Month=T10.YEAR_MONTH 
LEFT JOIN (
--取上月实际库存天数
SELECT 
Store_ID,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) YEAR_MONTH,
SUM(CASE WHEN Inventory_QTY>0 THEN 1 ELSE 0 END)ACTUAL_INVENTORY_DAYS_LM
FROM (
SELECT 
T.Store_ID,
T.Calendar_DT,
SUM(Inventory_QTY)Inventory_QTY
FROM 
[dw].[Fct_YH_Inventory] T
LEFT JOIN 
[dm].[Dim_Product] T1 ON T1.SKU_ID=T.SKU_ID
GROUP BY T.Store_ID,
T.Calendar_DT
)T
GROUP BY 
Store_ID,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) 
)T11 ON T.Store_ID=T11.Store_ID AND T1.Year_Month=T11.YEAR_MONTH 
LEFT JOIN (
--取有库存的SKU数
SELECT 
T.Store_ID,
YEAR(Calendar_DT)*100+MONTH(Calendar_DT) YEAR_MONTH,
SUM(T.INVENTORY_QTY*T1.Sale_Unit_Weight_KG/1000)INVENTORY_VOLUME,
COUNT(DISTINCT T.SKU_ID) INVENTORY_SKU_QTY
FROM 
[dw].[Fct_YH_Inventory] T 
LEFT JOIN 
[dm].[Dim_Product] T1 ON T1.SKU_ID=T.SKU_ID  WHERE Inventory_QTY>0
GROUP BY T.Store_ID,
YEAR(Calendar_DT)*100+MONTH(Calendar_DT)
)T12 ON T.Store_ID=T12.Store_ID AND T1.Year_Month=T12.YEAR_MONTH
LEFT JOIN (
--取上月有库存的SKU数
SELECT 
T.Store_ID,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT)) YEAR_MONTH,
SUM(T.INVENTORY_QTY*T1.Sale_Unit_Weight_KG/1000)INVENTORY_VOLUME_LM,
COUNT(DISTINCT T.SKU_ID) INVENTORY_SKU_QTY_LM
FROM 
[dw].[Fct_YH_Inventory] T 
LEFT JOIN 
[dm].[Dim_Product] T1 ON T1.SKU_ID=T.SKU_ID  WHERE Inventory_QTY>0
GROUP BY T.Store_ID,
YEAR(dateadd(MONTH,1,Calendar_DT))*100+MONTH(dateadd(MONTH,1,Calendar_DT))
)T13 ON T.Store_ID=T13.Store_ID AND T1.Year_Month=T13.YEAR_MONTH 
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
GROUP BY 
Store_ID,
YH_Store_CD
)T
)T15 ON T.Store_ID=T15.Store_ID
WHERE T14.FIRST_SALES_DATE IS NOT NULL AND T.Channel_Account = 'YH'
   END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
