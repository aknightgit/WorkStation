USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_YH_Sales_Weight_Weekday]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE  [dm].[SP_Fct_YH_Sales_Weight_Weekday]
	-- Add the parameters for the stored procedure here
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY

TRUNCATE TABLE  dm.Fct_YH_Sales_Weight_Weekday

IF OBJECT_ID(N'TEMPDB..#Sales_AMT_L3M') IS NOT NULL
BEGIN
DROP TABLE #Sales_AMT_L3M
END

SELECT st.Store_City_EN
	  ,SUM(Sales_AMT) AS Sales_AMT_L3M
INTO #Sales_AMT_L3M
FROM dm.Fct_YH_Sales_Inventory sal
LEFT JOIN [FU_EDW].[Dim_Calendar] cal ON sal.Calendar_DT = cal.Date_ID
LEFT JOIN dm.Dim_Store st ON sal.Store_ID = st.Store_ID AND st.Channel_Account = 'YH'
WHERE cal.Date_NM >= (SELECT DATEADD(day,-91,MAX(cali.DATE_NM)) FROM [FU_EDW].[Dim_Calendar] cali WHERE cali.Day_Filter_Flag = 1)
GROUP BY st.Store_City_EN
HAVING SUM(Sales_AMT)>0
--------------------全国
INSERT INTO dm.Fct_YH_Sales_Weight_Weekday
	  (
	   Region
	  ,Week_Day
	  ,Week_Day_Weight
      ,[Create_Time]
	  ,[Create_By]
	  ,[Update_Time]
	  ,[Update_By])
SELECT
	   'China' AS Region
      ,cal.Week_Day
      ,CAST(SUM(Sales_AMT) AS DECIMAL)/CAST((SELECT SUM(Sales_AMT_L3M) FROM #Sales_AMT_L3M) AS DECIMAL)*7 AS Week_Day_Weight
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
	 FROM dm.Fct_YH_Sales_Inventory sal
LEFT JOIN [FU_EDW].[Dim_Calendar] cal on sal.Calendar_DT = cal.Date_ID
WHERE cal.Date_NM >= (SELECT DATEADD(day,-91,MAX(cali.DATE_NM)) FROM [FU_EDW].[Dim_Calendar] cali WHERE cali.Day_Filter_Flag = 1)
GROUP BY cal.Week_Day

--------------------城市
INSERT INTO dm.Fct_YH_Sales_Weight_Weekday
	  (
	   Region
	  ,Week_Day
	  ,Week_Day_Weight
      ,[Create_Time]
	  ,[Create_By]
	  ,[Update_Time]
	  ,[Update_By])
SELECT
	   st.Store_City_EN AS Region
      ,cal.Week_Day
      ,CAST(SUM(Sales_AMT) AS DECIMAL)/CAST(MAX(sa.Sales_AMT_L3M) AS DECIMAL)*7 AS Week_Day_Weight
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
	 FROM dm.Fct_YH_Sales_Inventory sal
LEFT JOIN [FU_EDW].[Dim_Calendar] cal on sal.Calendar_DT = cal.Date_ID
LEFT JOIN dm.Dim_Store st ON sal.Store_ID = st.Store_ID AND st.Channel_Account = 'YH'
LEFT JOIN #Sales_AMT_L3M sa ON st.Store_City_EN = sa.Store_City_EN
WHERE cal.Date_NM >= (SELECT DATEADD(day,-91,MAX(cali.DATE_NM)) FROM [FU_EDW].[Dim_Calendar] cali WHERE cali.Day_Filter_Flag = 1)
GROUP BY cal.Week_Day
		,st.Store_City_EN


END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
