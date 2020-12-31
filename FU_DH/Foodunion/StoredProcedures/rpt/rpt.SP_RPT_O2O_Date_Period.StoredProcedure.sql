USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_O2O_Date_Period]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE PROC [rpt].[SP_RPT_O2O_Date_Period]
AS
BEGIN



-------------------------------获取期间数据并进行排序
DROP TABLE IF EXISTS #Period_Rank

SELECT [Period]
	  ,sp_year_max+'/'+LEFT([period],CHARINDEX('-',[period])-1) AS Begin_DT
	  ,sp_year_min+'/'+RIGHT([period],LEN([period])-CHARINDEX('-',[period])) AS End_DT
	  ,DENSE_RANK() OVER(ORDER BY sp_year_max+'/'+LEFT([period],CHARINDEX('-',[period])-1)) AS Period_Rank
	  ,[Date]
	--  INTO #Period_Rank
FROM 
(SELECT  MAX(LEFT(sp_num,4)) AS sp_year_max,MIN(LEFT(sp_num,4)) AS sp_year_min,RIGHT(v,[dbo].[IndexOfChR](v)) AS [Period],MIN(v) AS [Date] FROM [DM].[FCT_O2O_WX_APPLYDATA] WHERE v LIKE '%期间%' GROUP BY RIGHT(v,[dbo].[IndexOfChR](v))) AS per
UNION ALL
SELECT '7/27-7/31','2019-07-27','2019-07-31',0,'7月期间7/27-7/31'






   END
GO
