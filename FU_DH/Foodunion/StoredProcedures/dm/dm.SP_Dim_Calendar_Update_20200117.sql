USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dm].[SP_Dim_Calendar_Update_20200117]
	@Start_Date DATE,
	@End_Date DATE
AS
BEGIN

	--exec [dm].[SP_Dim_Calendar_Update] '2018-1-1','2030-1-1'

	SET NOCOUNT ON;
	
	IF @Start_Date IS NULL OR @End_Date IS NULL
	BEGIN
		SELECT 'Start and end dates MUST be provided in order for this stored procedure to work.';
		RETURN;
	END
 
	IF @Start_Date > @End_Date
	BEGIN
		SELECT 'Start date must be less than or equal to the end date.';
		RETURN;
	END

	DELETE FROM dm.Dim_Calendar	WHERE [Date] BETWEEN CAST(@Start_Date AS DATE) AND CAST(@End_Date AS DATE);
	
	DECLARE @Date DATE = CAST(@Start_Date AS DATE);

	--declare @date date='2020-2-16'
	--DECLARE @Day_of_Week TINYINT = DATEPART(WEEKDAY,DATEADD(DAY,-1,@Date));  --用自然周

	DECLARE @Day_of_Week TINYINT;
	DECLARE @Year SMALLINT;
	DECLARE @Month TINYINT;
	DECLARE @Is_Leap_Year BIT;
	DECLARE @Days_in_Month TINYINT;

	

	WHILE(@Date <= @End_Date)
	BEGIN

	SET @Day_of_Week  = DATEPART(WEEKDAY,DATEADD(DAY,-1,@Date));
	SET @Year  = DATEPART(YEAR,@Date);
	SET @Month  = DATEPART(MONTH,@Date);

	SELECT @Is_Leap_Year = CASE
						WHEN @Year % 4 <> 0 THEN 0
						WHEN @Year % 100 <> 0 THEN 1
						WHEN @Year % 400 <> 0 THEN 0
						ELSE 1
					END;
 
	SELECT @Days_in_Month = CASE
						WHEN @Month IN (4, 6, 9, 11) THEN 30				
											WHEN @Month IN (1, 3, 5, 7, 8, 10, 12) THEN 31
						WHEN @Month = 2 AND @Is_Leap_Year = 1 THEN 29
						ELSE 28
					END;
	
	INSERT INTO [dm].[Dim_Calendar]
           ([Datekey]
           ,[Date]
           ,[Date_Str]
           ,[Year]
           ,[Month]
           ,[Monthkey]
           ,[Quarter]
           ,[Day_of_Year]
           ,[Day_of_Month]
           ,[Day_of_Week]
           ,[Week_Day_Name]
           ,[Week_Day_Name_CN]
           ,[Week_of_Month]
           ,[Week_of_Quarter]
           ,[Week_of_Year]
		   ,[Week_of_Year_Str]
           ,[Week_Nature_Str]
           ,[Start_of_Week]
           ,[End_of_Week]
           ,[Month_Name]
           ,[Month_Name_Short]
           ,[Start_of_Month]
           ,[End_of_Month]
           ,[Start_of_Quarter]
           ,[End_of_Quarter]
           ,[Start_of_Year]
           ,[End_of_Year]
           ,[Is_Holiday]
           ,[Is_Weekend]
           ,[Is_Past]
           ,[Days_in_Month]
           ,[Previous_Month]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])		   
	SELECT 
			CONVERT(VARCHAR(8),@Date,112) AS [Datekey]
           ,CAST(@Date AS DATETIME) AS [Date]
           ,CONVERT(VARCHAR(10),@Date,121) AS [Date_Str]
           ,@Year AS [Year]
           ,@Month AS [Month]
           ,CONVERT(VARCHAR(6),@Date,112) AS [Monthkey]
           ,DATEPART(QUARTER,@Date) AS [Quarter]
           ,DATEPART(DAYOFYEAR,@Date) AS [Day_of_Year]
           ,DATEPART(DAY,@Date) AS [Day_of_Month]
           ,@Day_of_Week AS [Day_of_Week]   
           ,CASE DATEPART(WEEKDAY,@Date) 
						WHEN 1 THEN 'Sunday'
						WHEN 2 THEN 'Monday'
						WHEN 3 THEN 'Tuesday'
						WHEN 4 THEN 'Wednesday'
						WHEN 5 THEN 'Thursday'
						WHEN 6 THEN 'Friday'
						WHEN 7 THEN 'Saturday'
					END AS [Week_Day_Name]
           ,CASE DATEPART(WEEKDAY,@Date) 
						WHEN 1 THEN '星期日'
						WHEN 2 THEN '星期一'
						WHEN 3 THEN '星期二'
						WHEN 4 THEN '星期三'
						WHEN 5 THEN '星期四'
						WHEN 6 THEN '星期五'
						WHEN 7 THEN '星期六'
					END AS [Week_Day_Name_CN]
           ,DATEDIFF(WEEK, DATEADD(WEEK, DATEDIFF(WEEK, 0, DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(DAY,-1,@Date)), 0)), 0), DATEADD(DAY,-1,@Date) ) + 1 AS [Week_of_Month]
           ,DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, DATEADD(DAY,-1,@Date)), 0), DATEADD(DAY,-1,@Date))/7 + 1 AS [Week_of_Quarter]
           ,CASE WHEN DATEPART(DAYOFYEAR,@Date)=1 THEN 1 ELSE DATEPART(WEEK, DATEADD(DAY,-1,@Date)) END AS [Week_of_Year]
		   ,'Week '+ CAST(CASE WHEN DATEPART(DAYOFYEAR,@Date)=1 THEN 1 ELSE DATEPART(WEEK, DATEADD(DAY,-1,@Date)) END AS VARCHAR(2)) AS [Week_of_Year_Str]
           ,CONVERT(VARCHAR(8),DATEADD(DAY, -1 * @Day_of_Week + 1, @Date),112)
			+'-'+CONVERT(VARCHAR(8),DATEADD(DAY, 1 * (7 - @Day_of_Week), @Date),112) AS [Week_Nature_Str]
           ,DATEADD(DAY, -1 * @Day_of_Week + 1, @Date) AS [Start_of_Week]
           ,DATEADD(DAY, 1 * (7 - @Day_of_Week), @Date) AS [End_of_Week]
           ,CASE @Month
						WHEN 1 THEN 'January'
						WHEN 2 THEN 'February'
						WHEN 3 THEN 'March'
						WHEN 4 THEN 'April'
						WHEN 5 THEN 'May'
						WHEN 6 THEN 'June'
						WHEN 7 THEN 'July'
						WHEN 8 THEN 'August'
						WHEN 9 THEN 'September'
						WHEN 10 THEN 'October'
						WHEN 11 THEN 'November'
						WHEN 12 THEN 'December'
					END AS [Month_Name]
           ,CASE @Month
						WHEN 1 THEN 'Jan'
						WHEN 2 THEN 'Feb'
						WHEN 3 THEN 'Mar'
						WHEN 4 THEN 'Apr'
						WHEN 5 THEN 'May'
						WHEN 6 THEN 'Jun'
						WHEN 7 THEN 'Jul'
						WHEN 8 THEN 'Aug'
						WHEN 9 THEN 'Sep'
						WHEN 10 THEN 'Oct'
						WHEN 11 THEN 'Nov'
						WHEN 12 THEN 'Dec'
					END AS [Month_Name_Short]
           ,DATEADD(DAY, -1 * DATEPART(DAY, @Date) + 1, @Date) AS [Start_of_Month]
           ,EOMONTH(@Date) AS [End_of_Month]
           ,CONVERT(VARCHAR(10),DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @Date), 0),121) AS [Start_of_Quarter]
           ,CONVERT(VARCHAR(10),DATEADD (DAY, -1, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @Date) + 1, 0)),121) AS [End_of_Quarter]
           ,CONVERT(VARCHAR(10),DATEADD(YEAR, DATEDIFF(YEAR, 0, @Date), 0),121) AS [Start_of_Year]
           ,CONVERT(VARCHAR(10),DATEADD(DAY, -1, DATEADD(YEAR, DATEDIFF(YEAR, 0, @Date) + 1, 0)),121) AS [End_of_Year]
           ,0 AS [Is_Holiday]
           ,CASE WHEN @Day_of_Week IN (1, 7)
				THEN 1 ELSE 0
				END AS [Is_Weekend]
           ,CASE WHEN @Date <= GETDATE()
				THEN 1 ELSE 0
				END AS [Is_Past]
           ,@Days_in_Month AS [Days_in_Month]
           ,CONVERT(VARCHAR(6),DATEADD(MONTH,-1,@Date),112) AS [Previous_Month]
           ,GETDATE() AS [Create_Time]
           ,'SP_Dim_Calendar_Update' AS [Create_By]
           ,GETDATE() AS [Update_Time]
           ,'SP_Dim_Calendar_Update' AS [Update_By]
			;

		SELECT @Date = DATEADD(DAY,1,@Date);
	END

END
GO
