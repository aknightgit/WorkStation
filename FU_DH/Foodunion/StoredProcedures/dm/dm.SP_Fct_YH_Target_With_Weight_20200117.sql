USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC  [dm].[SP_Fct_YH_Target_With_Weight_20200117]
AS BEGIN


 DECLARE @errmsg nvarchar(max),
 @DatabaseName varchar(100) = DB_NAME(),
 @ProcName varchar(100) = OBJECT_NAME(@@PROCID);

 BEGIN TRY

SELECT Calendar_DT
	  ,Store_ID
	  ,SUM(sal.Sales_AMT) AS Sales_AMT
	  INTO #YH_Sales
FROM dm.Fct_YH_Sales_Inventory sal
LEFT JOIN [dm].[Dim_Product] prod ON sal.SKU_ID = prod.SKU_ID
--WHERE sal.YH_Home_Sales_AMT>0 OR sal.JD_Home_Sales_AMT>0 
GROUP BY 
	  Calendar_DT
	 ,Store_ID

SELECT Calendar_DT
	  ,Store_ID
	  ,prod.Product_Sort
	  ,SUM(sal.Sales_AMT) AS Sales_AMT
	  INTO #YH_Sales_Sort
FROM dm.Fct_YH_Sales_Inventory sal
LEFT JOIN [dm].[Dim_Product] prod ON sal.SKU_ID = prod.SKU_ID
--WHERE sal.YH_Home_Sales_AMT>0 OR sal.JD_Home_Sales_AMT>0 
GROUP BY 
	  Calendar_DT
	 ,Store_ID
	 ,prod.Product_Sort

DECLARE @LastCal int
SELECT @LastCal = MAX(Calendar_DT)  FROM #YH_Sales


TRUNCATE TABLE [dm].[Fct_YH_Target_With_Weight] 

INSERT INTO [dm].[Fct_YH_Target_With_Weight](
	   [period]
      ,[Store_ID]
      ,[Region]
      ,[Store_NM]
      ,[Sales_Target]
      ,[Ambient_Sales_Target]
      ,[Fresh_Sales_Target]
      --,[DSR]
	  ,Target_With_Weight
      ,[Target_Ambient_With_Weight]
      ,[Target_Fresh_With_Weight]
	  ,[Sales_Forecast_AMT]
	  ,[Sales_Forecast_Ambient_AMT]
	  ,[Sales_Forecast_Fresh_AMT]
      ,[Create_Time]
	  ,[Create_By]
	  ,[Update_Time]
	  ,[Update_By]
)
SELECT 
       cal.Date_ID AS [period]
      ,st.[Store_ID]
      ,si.[Region]
      ,si.[Store_NM]
      ,si.[Sales_Target]/DAY(DATEADD(ms,-3,DATEADD(m, DATEDIFF(m,0,cal.Date_NM)+1,0))) AS [Sales_Target]
      ,si.[Ambient_Sales_Target]/DAY(DATEADD(ms,-3,DATEADD(m, DATEDIFF(m,0,cal.Date_NM)+1,0))) AS [Ambient_Sales_Target]
      ,si.[Fresh_Sales_Target]/DAY(DATEADD(ms,-3,DATEADD(m, DATEDIFF(m,0,cal.Date_NM)+1,0))) AS [Fresh_Sales_Target]
      --,si.[DSR]
	  ,CAST(si.[Sales_Target]*wei.Week_Day_Weight AS DECIMAL)/(SELECT CAST(SUM(wei2.Week_Day_Weight) AS DECIMAL) FROM FU_EDW.Dim_Calendar cal2 LEFT JOIN (SELECT * FROM dm.Fct_YH_Sales_Weight_Weekday WHERE Region = 'China') wei2 ON cal2.Week_Day = wei2.Week_Day WHERE cal.Year_Month = cal2.Year_Month) AS Target_With_Weight
	  ,CAST(si.[Ambient_Sales_Target]*wei.Week_Day_Weight AS DECIMAL)/(SELECT CAST(SUM(wei2.Week_Day_Weight) AS DECIMAL) FROM FU_EDW.Dim_Calendar cal2 LEFT JOIN (SELECT * FROM dm.Fct_YH_Sales_Weight_Weekday WHERE Region = 'China') wei2 ON cal2.Week_Day = wei2.Week_Day WHERE cal.Year_Month = cal2.Year_Month) AS [Target_Ambient_With_Weight]
	  ,CAST(si.[Fresh_Sales_Target]*wei.Week_Day_Weight AS DECIMAL)/(SELECT CAST(SUM(wei2.Week_Day_Weight) AS DECIMAL) FROM FU_EDW.Dim_Calendar cal2 LEFT JOIN (SELECT * FROM dm.Fct_YH_Sales_Weight_Weekday WHERE Region = 'China') wei2 ON cal2.Week_Day = wei2.Week_Day WHERE cal.Year_Month = cal2.Year_Month) AS [Target_Fresh_With_Weight]
	  ,CASE WHEN cal.Date_ID<=@LastCal THEN sal.Sales_AMT ELSE
			(SELECT SUM(sal2.Sales_AMT) AS Sales_AMT FROM #YH_Sales sal2 WHERE CAST(sal2.Calendar_DT AS VARCHAR)>DATEADD(DAY,-14,CAST(@LastCal AS VARCHAR)) AND sal2.Store_ID = st.Store_ID)/14*wei.Week_Day_Weight
			END AS [Sales_Forecast_AMT]
	  ,CASE WHEN cal.Date_ID<=@LastCal THEN (SELECT SUM(sal3.Sales_AMT) FROM #YH_Sales_Sort sal3 WHERE sal3.Product_Sort='Ambient' AND sal3.Calendar_DT=cal.Date_ID AND sal3.Store_ID=st.Store_ID)ELSE
			(SELECT SUM(sal2.Sales_AMT) AS Sales_AMT FROM #YH_Sales_Sort sal2 WHERE sal2.Product_Sort='Ambient' AND CAST(sal2.Calendar_DT AS VARCHAR)>DATEADD(DAY,-14,CAST(@LastCal AS VARCHAR)) AND sal2.Store_ID = st.Store_ID)/14*wei.Week_Day_Weight
			END AS [Sales_Forecast_Ambient_AMT]
	  ,CASE WHEN cal.Date_ID<=@LastCal THEN (SELECT SUM(sal3.Sales_AMT) FROM #YH_Sales_Sort sal3 WHERE sal3.Product_Sort='Fresh' AND sal3.Calendar_DT=cal.Date_ID AND sal3.Store_ID=st.Store_ID)ELSE
			(SELECT SUM(sal2.Sales_AMT) AS Sales_AMT FROM #YH_Sales_Sort sal2 WHERE sal2.Product_Sort='Fresh' AND CAST(sal2.Calendar_DT AS VARCHAR)>DATEADD(DAY,-14,CAST(@LastCal AS VARCHAR)) AND sal2.Store_ID = st.Store_ID)/14*wei.Week_Day_Weight
			END AS [Sales_Forecast_Fresh_AMT]
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM 
FU_EDW.Dim_Calendar cal
CROSS JOIN (SELECT DISTINCT Store_ID FROM dm.Dim_Store WHERE Channel_Account = 'YH') st
LEFT JOIN [dm].[Fct_YH_Target] si ON  cal.Year_Month = LEFT(si.period,6) AND si.Store_ID = st.Store_ID AND si.Sales_Target>0
LEFT JOIN (SELECT * FROM dm.Fct_YH_Sales_Weight_Weekday WHERE Region = 'China') wei ON cal.Week_Day = wei.Week_Day
LEFT JOIN #YH_Sales sal ON cal.Date_ID = sal.Calendar_DT AND st.Store_ID = sal.Store_ID
WHERE ((cal.Date_NM>='2018-09-01' AND cal.Year_Month<LEFT(@LastCal,6)  AND (ISNULL(sal.Sales_AMT,0)<>0 OR ISNULL(si.Sales_Target,0)<>0)) OR cal.Year_Month=LEFT(@LastCal,6))


END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
