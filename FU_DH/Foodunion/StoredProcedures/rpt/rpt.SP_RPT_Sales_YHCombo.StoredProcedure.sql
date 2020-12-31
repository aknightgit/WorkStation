USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_Sales_YHCombo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







  CREATE PROCEDURE [rpt].[SP_RPT_Sales_YHCombo]
  AS
  BEGIN

  
---------------------创建数字临时表
DROP TABLE IF EXISTS #Number
CREATE TABLE #Number
(id INT)

DECLARE @Number INT
SET @Number = 1
WHILE (@Number<1000)
BEGIN

INSERT INTO #Number
SELECT @Number

SET @Number+=1

END


-----------------------------获取YHEDI的SKU_Name
DROP TABLE IF EXISTS #SKU_NAME
SELECT DISTINCT bar_code,goods_name 
INTO #SKU_NAME
FROM ods.ods.EDI_YH_Sales 
WHERE goods_name like '%礼盒%' OR goods_name LIKE '%趣杯%'




  DROP TABLE IF EXISTS #Sales_By_Day
  SELECT 
		CASE WHEN ISNULL(st.Account_Area_CN,'其他') NOT IN ('重庆大区','四川大区','北京大区','福建大区','华东大区','安徽大区') THEN '其他' ELSE LEFT(st.Account_Area_CN,2) END AS [区域]
	   ,cal.Year_Month
	   ,sn.goods_name AS SKU
	   ,CAST(SUM(Sales_QTY) AS INT) AS [MTD 销售数量]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 1 THEN Sales_QTY ELSE 0 END) AS INT) AS [1日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 2 THEN Sales_QTY ELSE 0 END) AS INT) AS [2日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 3 THEN Sales_QTY ELSE 0 END) AS INT) AS [3日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 4 THEN Sales_QTY ELSE 0 END) AS INT) AS [4日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 5 THEN Sales_QTY ELSE 0 END) AS INT) AS [5日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 6 THEN Sales_QTY ELSE 0 END) AS INT) AS [6日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 7 THEN Sales_QTY ELSE 0 END) AS INT) AS [7日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 8 THEN Sales_QTY ELSE 0 END) AS INT) AS [8日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 9 THEN Sales_QTY ELSE 0 END) AS INT) AS [9日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 10 THEN Sales_QTY ELSE 0 END) AS INT) AS [10日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 11 THEN Sales_QTY ELSE 0 END) AS INT) AS [11日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 12 THEN Sales_QTY ELSE 0 END) AS INT) AS [12日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 13 THEN Sales_QTY ELSE 0 END) AS INT) AS [13日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 14 THEN Sales_QTY ELSE 0 END) AS INT) AS [14日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 15 THEN Sales_QTY ELSE 0 END) AS INT) AS [15日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 16 THEN Sales_QTY ELSE 0 END) AS INT) AS [16日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 17 THEN Sales_QTY ELSE 0 END) AS INT) AS [17日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 18 THEN Sales_QTY ELSE 0 END) AS INT) AS [18日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 19 THEN Sales_QTY ELSE 0 END) AS INT) AS [19日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 20 THEN Sales_QTY ELSE 0 END) AS INT) AS [20日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 21 THEN Sales_QTY ELSE 0 END) AS INT) AS [21日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 22 THEN Sales_QTY ELSE 0 END) AS INT) AS [22日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 23 THEN Sales_QTY ELSE 0 END) AS INT) AS [23日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 24 THEN Sales_QTY ELSE 0 END) AS INT) AS [24日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 25 THEN Sales_QTY ELSE 0 END) AS INT) AS [25日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 26 THEN Sales_QTY ELSE 0 END) AS INT) AS [26日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 27 THEN Sales_QTY ELSE 0 END) AS INT) AS [27日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 28 THEN Sales_QTY ELSE 0 END) AS INT) AS [28日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 29 THEN Sales_QTY ELSE 0 END) AS INT) AS [29日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 30 THEN Sales_QTY ELSE 0 END) AS INT) AS [30日]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 31 THEN Sales_QTY ELSE 0 END) AS INT) AS [31日]
  INTO #Sales_By_Day
  FROM dm.Fct_YH_Sales_Inventory sal
  LEFT JOIN dm.Dim_Product prod ON sal.SKU_ID = prod.SKU_ID
  LEFT JOIN dm.Dim_Store st ON sal.Store_ID = st.Store_ID
  LEFT JOIN FU_EDW.Dim_Calendar cal ON sal.Calendar_DT = cal.Date_ID
  INNER JOIN #SKU_NAME sn ON prod.Bar_Code = sn.bar_code
  WHERE YEAR(DATEADD(DAY,-1,GETDATE())) = cal.[Year] AND MONTH(DATEADD(DAY,-1,GETDATE())) = cal.[Month]-- AND (prod.SKU_Name_CN LIKE '%礼盒%' OR prod.SKU_Name_CN LIKE '%趣杯%')
  GROUP BY  CASE WHEN ISNULL(st.Account_Area_CN,'其他') NOT IN ('重庆大区','四川大区','北京大区','福建大区','华东大区','安徽大区') THEN '其他' ELSE LEFT(st.Account_Area_CN,2) END 
		   ,cal.Year_Month
		   ,sn.goods_name



DROP TABLE IF EXISTS #Sales_Group
SELECT 
	  '汇总' AS [区域]
	 ,SKU AS SKU
	 ,SUM([MTD 销售数量]) AS [MTD 销售数量]
	 ,SUM([1日]) AS [1日]
	 ,SUM([2日]) AS [2日]
	 ,SUM([3日]) AS [3日]
	 ,SUM([4日]) AS [4日]
	 ,SUM([5日]) AS [5日]
	 ,SUM([6日]) AS [6日]
	 ,SUM([7日]) AS [7日]
	 ,SUM([8日]) AS [8日]
	 ,SUM([9日]) AS [9日]
	 ,SUM([10日]) AS [10日]
	 ,SUM([11日]) AS [11日]
	 ,SUM([12日]) AS [12日]
	 ,SUM([13日]) AS [13日]
	 ,SUM([14日]) AS [14日]
	 ,SUM([15日]) AS [15日]
	 ,SUM([16日]) AS [16日]
	 ,SUM([17日]) AS [17日]
	 ,SUM([18日]) AS [18日]
	 ,SUM([19日]) AS [19日]
	 ,SUM([20日]) AS [20日]
	 ,SUM([21日]) AS [21日]
	 ,SUM([22日]) AS [22日]
	 ,SUM([23日]) AS [23日]
	 ,SUM([24日]) AS [24日]
	 ,SUM([25日]) AS [25日]
	 ,SUM([26日]) AS [26日]
	 ,SUM([27日]) AS [27日]
	 ,SUM([28日]) AS [28日]
	 ,SUM([29日]) AS [29日]
	 ,SUM([30日]) AS [30日]
	 ,SUM([31日]) AS [31日]
INTO #Sales_Group
FROM #Sales_By_Day
GROUP BY SKU

SELECT 
		CASE nb.id WHEN 1 THEN '区域' WHEN 3 THEN sg.[区域] ELSE sbd.[区域] END AS [区域]
	   ,CASE nb.id WHEN 1 THEN 'SKU' ELSE sbd.SKU END AS SKU     
	   ,CASE nb.id WHEN 1 THEN 'MTD 销售数量' WHEN 3 THEN CAST(sg.[MTD 销售数量] AS VARCHAR) ELSE CAST(sbd.[MTD 销售数量] AS VARCHAR) END AS [MTD 销售数量]
	   ,CASE nb.id WHEN 1 THEN '1日' WHEN 3 THEN CAST(sg.[1日] AS VARCHAR) ELSE CAST(sbd.[1日] AS VARCHAR) END AS [1日]
	   ,CASE nb.id WHEN 1 THEN '2日' WHEN 3 THEN CAST(sg.[2日] AS VARCHAR) ELSE CAST(sbd.[2日] AS VARCHAR) END AS [2日]
	   ,CASE nb.id WHEN 1 THEN '3日' WHEN 3 THEN CAST(sg.[3日] AS VARCHAR) ELSE CAST(sbd.[3日] AS VARCHAR) END AS [3日]
	   ,CASE nb.id WHEN 1 THEN '4日' WHEN 3 THEN CAST(sg.[4日] AS VARCHAR) ELSE CAST(sbd.[4日] AS VARCHAR) END AS [4日]
	   ,CASE nb.id WHEN 1 THEN '5日' WHEN 3 THEN CAST(sg.[5日] AS VARCHAR) ELSE CAST(sbd.[5日] AS VARCHAR) END AS [5日]
	   ,CASE nb.id WHEN 1 THEN '6日' WHEN 3 THEN CAST(sg.[6日] AS VARCHAR) ELSE CAST(sbd.[6日] AS VARCHAR) END AS [6日]
	   ,CASE nb.id WHEN 1 THEN '7日' WHEN 3 THEN CAST(sg.[7日] AS VARCHAR) ELSE CAST(sbd.[7日] AS VARCHAR) END AS [7日]
	   ,CASE nb.id WHEN 1 THEN '8日' WHEN 3 THEN CAST(sg.[8日] AS VARCHAR) ELSE CAST(sbd.[8日] AS VARCHAR) END AS [8日]
	   ,CASE nb.id WHEN 1 THEN '9日' WHEN 3 THEN CAST(sg.[9日] AS VARCHAR) ELSE CAST(sbd.[9日] AS VARCHAR) END AS [9日]
	   ,CASE nb.id WHEN 1 THEN '10日' WHEN 3 THEN CAST(sg.[10日] AS VARCHAR) ELSE CAST(sbd.[10日] AS VARCHAR) END AS [10日]
	   ,CASE nb.id WHEN 1 THEN '11日' WHEN 3 THEN CAST(sg.[11日] AS VARCHAR) ELSE CAST(sbd.[11日] AS VARCHAR) END AS [11日]
	   ,CASE nb.id WHEN 1 THEN '12日' WHEN 3 THEN CAST(sg.[12日] AS VARCHAR) ELSE CAST(sbd.[12日] AS VARCHAR) END AS [12日]
	   ,CASE nb.id WHEN 1 THEN '13日' WHEN 3 THEN CAST(sg.[13日] AS VARCHAR) ELSE CAST(sbd.[13日] AS VARCHAR) END AS [13日]
	   ,CASE nb.id WHEN 1 THEN '14日' WHEN 3 THEN CAST(sg.[14日] AS VARCHAR) ELSE CAST(sbd.[14日] AS VARCHAR) END AS [14日]
	   ,CASE nb.id WHEN 1 THEN '15日' WHEN 3 THEN CAST(sg.[15日] AS VARCHAR) ELSE CAST(sbd.[15日] AS VARCHAR) END AS [15日]
	   ,CASE nb.id WHEN 1 THEN '16日' WHEN 3 THEN CAST(sg.[16日] AS VARCHAR) ELSE CAST(sbd.[16日] AS VARCHAR) END AS [16日]
	   ,CASE nb.id WHEN 1 THEN '17日' WHEN 3 THEN CAST(sg.[17日] AS VARCHAR) ELSE CAST(sbd.[17日] AS VARCHAR) END AS [17日]
	   ,CASE nb.id WHEN 1 THEN '18日' WHEN 3 THEN CAST(sg.[18日] AS VARCHAR) ELSE CAST(sbd.[18日] AS VARCHAR) END AS [18日]
	   ,CASE nb.id WHEN 1 THEN '19日' WHEN 3 THEN CAST(sg.[19日] AS VARCHAR) ELSE CAST(sbd.[19日] AS VARCHAR) END AS [19日]
	   ,CASE nb.id WHEN 1 THEN '20日' WHEN 3 THEN CAST(sg.[20日] AS VARCHAR) ELSE CAST(sbd.[20日] AS VARCHAR) END AS [20日]
	   ,CASE nb.id WHEN 1 THEN '21日' WHEN 3 THEN CAST(sg.[21日] AS VARCHAR) ELSE CAST(sbd.[21日] AS VARCHAR) END AS [21日]
	   ,CASE nb.id WHEN 1 THEN '22日' WHEN 3 THEN CAST(sg.[22日] AS VARCHAR) ELSE CAST(sbd.[22日] AS VARCHAR) END AS [22日]
	   ,CASE nb.id WHEN 1 THEN '23日' WHEN 3 THEN CAST(sg.[23日] AS VARCHAR) ELSE CAST(sbd.[23日] AS VARCHAR) END AS [23日]
	   ,CASE nb.id WHEN 1 THEN '24日' WHEN 3 THEN CAST(sg.[24日] AS VARCHAR) ELSE CAST(sbd.[24日] AS VARCHAR) END AS [24日]
	   ,CASE nb.id WHEN 1 THEN '25日' WHEN 3 THEN CAST(sg.[25日] AS VARCHAR) ELSE CAST(sbd.[25日] AS VARCHAR) END AS [25日]
	   ,CASE nb.id WHEN 1 THEN '26日' WHEN 3 THEN CAST(sg.[26日] AS VARCHAR) ELSE CAST(sbd.[26日] AS VARCHAR) END AS [26日]
	   ,CASE nb.id WHEN 1 THEN '27日' WHEN 3 THEN CAST(sg.[27日] AS VARCHAR) ELSE CAST(sbd.[27日] AS VARCHAR) END AS [27日]
	   ,CASE nb.id WHEN 1 THEN '28日' WHEN 3 THEN CAST(sg.[28日] AS VARCHAR) ELSE CAST(sbd.[28日] AS VARCHAR) END AS [28日]
	   ,CASE nb.id WHEN 1 THEN '29日' WHEN 3 THEN CAST(sg.[29日] AS VARCHAR) ELSE CAST(sbd.[29日] AS VARCHAR) END AS [29日]
	   ,CASE nb.id WHEN 1 THEN '30日' WHEN 3 THEN CAST(sg.[30日] AS VARCHAR) ELSE CAST(sbd.[30日] AS VARCHAR) END AS [30日]
	   ,CASE nb.id WHEN 1 THEN '31日' WHEN 3 THEN CAST(sg.[31日] AS VARCHAR) ELSE CAST(sbd.[31日] AS VARCHAR) END AS [31日]
FROM #Sales_Group sg
LEFT JOIN #Number nb ON nb.id <=5
LEFT JOIN #Sales_By_Day sbd ON sg.SKU = sbd.SKU AND nb.id = 2


END
GO
