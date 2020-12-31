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

  
---------------------����������ʱ��
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


-----------------------------��ȡYHEDI��SKU_Name
DROP TABLE IF EXISTS #SKU_NAME
SELECT DISTINCT bar_code,goods_name 
INTO #SKU_NAME
FROM ods.ods.EDI_YH_Sales 
WHERE goods_name like '%���%' OR goods_name LIKE '%Ȥ��%'




  DROP TABLE IF EXISTS #Sales_By_Day
  SELECT 
		CASE WHEN ISNULL(st.Account_Area_CN,'����') NOT IN ('�������','�Ĵ�����','��������','��������','��������','���մ���') THEN '����' ELSE LEFT(st.Account_Area_CN,2) END AS [����]
	   ,cal.Year_Month
	   ,sn.goods_name AS SKU
	   ,CAST(SUM(Sales_QTY) AS INT) AS [MTD ��������]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 1 THEN Sales_QTY ELSE 0 END) AS INT) AS [1��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 2 THEN Sales_QTY ELSE 0 END) AS INT) AS [2��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 3 THEN Sales_QTY ELSE 0 END) AS INT) AS [3��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 4 THEN Sales_QTY ELSE 0 END) AS INT) AS [4��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 5 THEN Sales_QTY ELSE 0 END) AS INT) AS [5��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 6 THEN Sales_QTY ELSE 0 END) AS INT) AS [6��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 7 THEN Sales_QTY ELSE 0 END) AS INT) AS [7��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 8 THEN Sales_QTY ELSE 0 END) AS INT) AS [8��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 9 THEN Sales_QTY ELSE 0 END) AS INT) AS [9��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 10 THEN Sales_QTY ELSE 0 END) AS INT) AS [10��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 11 THEN Sales_QTY ELSE 0 END) AS INT) AS [11��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 12 THEN Sales_QTY ELSE 0 END) AS INT) AS [12��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 13 THEN Sales_QTY ELSE 0 END) AS INT) AS [13��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 14 THEN Sales_QTY ELSE 0 END) AS INT) AS [14��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 15 THEN Sales_QTY ELSE 0 END) AS INT) AS [15��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 16 THEN Sales_QTY ELSE 0 END) AS INT) AS [16��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 17 THEN Sales_QTY ELSE 0 END) AS INT) AS [17��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 18 THEN Sales_QTY ELSE 0 END) AS INT) AS [18��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 19 THEN Sales_QTY ELSE 0 END) AS INT) AS [19��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 20 THEN Sales_QTY ELSE 0 END) AS INT) AS [20��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 21 THEN Sales_QTY ELSE 0 END) AS INT) AS [21��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 22 THEN Sales_QTY ELSE 0 END) AS INT) AS [22��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 23 THEN Sales_QTY ELSE 0 END) AS INT) AS [23��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 24 THEN Sales_QTY ELSE 0 END) AS INT) AS [24��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 25 THEN Sales_QTY ELSE 0 END) AS INT) AS [25��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 26 THEN Sales_QTY ELSE 0 END) AS INT) AS [26��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 27 THEN Sales_QTY ELSE 0 END) AS INT) AS [27��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 28 THEN Sales_QTY ELSE 0 END) AS INT) AS [28��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 29 THEN Sales_QTY ELSE 0 END) AS INT) AS [29��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 30 THEN Sales_QTY ELSE 0 END) AS INT) AS [30��]
	   ,CAST(SUM(CASE WHEN DAY(cal.Date_NM) = 31 THEN Sales_QTY ELSE 0 END) AS INT) AS [31��]
  INTO #Sales_By_Day
  FROM dm.Fct_YH_Sales_Inventory sal
  LEFT JOIN dm.Dim_Product prod ON sal.SKU_ID = prod.SKU_ID
  LEFT JOIN dm.Dim_Store st ON sal.Store_ID = st.Store_ID
  LEFT JOIN FU_EDW.Dim_Calendar cal ON sal.Calendar_DT = cal.Date_ID
  INNER JOIN #SKU_NAME sn ON prod.Bar_Code = sn.bar_code
  WHERE YEAR(DATEADD(DAY,-1,GETDATE())) = cal.[Year] AND MONTH(DATEADD(DAY,-1,GETDATE())) = cal.[Month]-- AND (prod.SKU_Name_CN LIKE '%���%' OR prod.SKU_Name_CN LIKE '%Ȥ��%')
  GROUP BY  CASE WHEN ISNULL(st.Account_Area_CN,'����') NOT IN ('�������','�Ĵ�����','��������','��������','��������','���մ���') THEN '����' ELSE LEFT(st.Account_Area_CN,2) END 
		   ,cal.Year_Month
		   ,sn.goods_name



DROP TABLE IF EXISTS #Sales_Group
SELECT 
	  '����' AS [����]
	 ,SKU AS SKU
	 ,SUM([MTD ��������]) AS [MTD ��������]
	 ,SUM([1��]) AS [1��]
	 ,SUM([2��]) AS [2��]
	 ,SUM([3��]) AS [3��]
	 ,SUM([4��]) AS [4��]
	 ,SUM([5��]) AS [5��]
	 ,SUM([6��]) AS [6��]
	 ,SUM([7��]) AS [7��]
	 ,SUM([8��]) AS [8��]
	 ,SUM([9��]) AS [9��]
	 ,SUM([10��]) AS [10��]
	 ,SUM([11��]) AS [11��]
	 ,SUM([12��]) AS [12��]
	 ,SUM([13��]) AS [13��]
	 ,SUM([14��]) AS [14��]
	 ,SUM([15��]) AS [15��]
	 ,SUM([16��]) AS [16��]
	 ,SUM([17��]) AS [17��]
	 ,SUM([18��]) AS [18��]
	 ,SUM([19��]) AS [19��]
	 ,SUM([20��]) AS [20��]
	 ,SUM([21��]) AS [21��]
	 ,SUM([22��]) AS [22��]
	 ,SUM([23��]) AS [23��]
	 ,SUM([24��]) AS [24��]
	 ,SUM([25��]) AS [25��]
	 ,SUM([26��]) AS [26��]
	 ,SUM([27��]) AS [27��]
	 ,SUM([28��]) AS [28��]
	 ,SUM([29��]) AS [29��]
	 ,SUM([30��]) AS [30��]
	 ,SUM([31��]) AS [31��]
INTO #Sales_Group
FROM #Sales_By_Day
GROUP BY SKU

SELECT 
		CASE nb.id WHEN 1 THEN '����' WHEN 3 THEN sg.[����] ELSE sbd.[����] END AS [����]
	   ,CASE nb.id WHEN 1 THEN 'SKU' ELSE sbd.SKU END AS SKU     
	   ,CASE nb.id WHEN 1 THEN 'MTD ��������' WHEN 3 THEN CAST(sg.[MTD ��������] AS VARCHAR) ELSE CAST(sbd.[MTD ��������] AS VARCHAR) END AS [MTD ��������]
	   ,CASE nb.id WHEN 1 THEN '1��' WHEN 3 THEN CAST(sg.[1��] AS VARCHAR) ELSE CAST(sbd.[1��] AS VARCHAR) END AS [1��]
	   ,CASE nb.id WHEN 1 THEN '2��' WHEN 3 THEN CAST(sg.[2��] AS VARCHAR) ELSE CAST(sbd.[2��] AS VARCHAR) END AS [2��]
	   ,CASE nb.id WHEN 1 THEN '3��' WHEN 3 THEN CAST(sg.[3��] AS VARCHAR) ELSE CAST(sbd.[3��] AS VARCHAR) END AS [3��]
	   ,CASE nb.id WHEN 1 THEN '4��' WHEN 3 THEN CAST(sg.[4��] AS VARCHAR) ELSE CAST(sbd.[4��] AS VARCHAR) END AS [4��]
	   ,CASE nb.id WHEN 1 THEN '5��' WHEN 3 THEN CAST(sg.[5��] AS VARCHAR) ELSE CAST(sbd.[5��] AS VARCHAR) END AS [5��]
	   ,CASE nb.id WHEN 1 THEN '6��' WHEN 3 THEN CAST(sg.[6��] AS VARCHAR) ELSE CAST(sbd.[6��] AS VARCHAR) END AS [6��]
	   ,CASE nb.id WHEN 1 THEN '7��' WHEN 3 THEN CAST(sg.[7��] AS VARCHAR) ELSE CAST(sbd.[7��] AS VARCHAR) END AS [7��]
	   ,CASE nb.id WHEN 1 THEN '8��' WHEN 3 THEN CAST(sg.[8��] AS VARCHAR) ELSE CAST(sbd.[8��] AS VARCHAR) END AS [8��]
	   ,CASE nb.id WHEN 1 THEN '9��' WHEN 3 THEN CAST(sg.[9��] AS VARCHAR) ELSE CAST(sbd.[9��] AS VARCHAR) END AS [9��]
	   ,CASE nb.id WHEN 1 THEN '10��' WHEN 3 THEN CAST(sg.[10��] AS VARCHAR) ELSE CAST(sbd.[10��] AS VARCHAR) END AS [10��]
	   ,CASE nb.id WHEN 1 THEN '11��' WHEN 3 THEN CAST(sg.[11��] AS VARCHAR) ELSE CAST(sbd.[11��] AS VARCHAR) END AS [11��]
	   ,CASE nb.id WHEN 1 THEN '12��' WHEN 3 THEN CAST(sg.[12��] AS VARCHAR) ELSE CAST(sbd.[12��] AS VARCHAR) END AS [12��]
	   ,CASE nb.id WHEN 1 THEN '13��' WHEN 3 THEN CAST(sg.[13��] AS VARCHAR) ELSE CAST(sbd.[13��] AS VARCHAR) END AS [13��]
	   ,CASE nb.id WHEN 1 THEN '14��' WHEN 3 THEN CAST(sg.[14��] AS VARCHAR) ELSE CAST(sbd.[14��] AS VARCHAR) END AS [14��]
	   ,CASE nb.id WHEN 1 THEN '15��' WHEN 3 THEN CAST(sg.[15��] AS VARCHAR) ELSE CAST(sbd.[15��] AS VARCHAR) END AS [15��]
	   ,CASE nb.id WHEN 1 THEN '16��' WHEN 3 THEN CAST(sg.[16��] AS VARCHAR) ELSE CAST(sbd.[16��] AS VARCHAR) END AS [16��]
	   ,CASE nb.id WHEN 1 THEN '17��' WHEN 3 THEN CAST(sg.[17��] AS VARCHAR) ELSE CAST(sbd.[17��] AS VARCHAR) END AS [17��]
	   ,CASE nb.id WHEN 1 THEN '18��' WHEN 3 THEN CAST(sg.[18��] AS VARCHAR) ELSE CAST(sbd.[18��] AS VARCHAR) END AS [18��]
	   ,CASE nb.id WHEN 1 THEN '19��' WHEN 3 THEN CAST(sg.[19��] AS VARCHAR) ELSE CAST(sbd.[19��] AS VARCHAR) END AS [19��]
	   ,CASE nb.id WHEN 1 THEN '20��' WHEN 3 THEN CAST(sg.[20��] AS VARCHAR) ELSE CAST(sbd.[20��] AS VARCHAR) END AS [20��]
	   ,CASE nb.id WHEN 1 THEN '21��' WHEN 3 THEN CAST(sg.[21��] AS VARCHAR) ELSE CAST(sbd.[21��] AS VARCHAR) END AS [21��]
	   ,CASE nb.id WHEN 1 THEN '22��' WHEN 3 THEN CAST(sg.[22��] AS VARCHAR) ELSE CAST(sbd.[22��] AS VARCHAR) END AS [22��]
	   ,CASE nb.id WHEN 1 THEN '23��' WHEN 3 THEN CAST(sg.[23��] AS VARCHAR) ELSE CAST(sbd.[23��] AS VARCHAR) END AS [23��]
	   ,CASE nb.id WHEN 1 THEN '24��' WHEN 3 THEN CAST(sg.[24��] AS VARCHAR) ELSE CAST(sbd.[24��] AS VARCHAR) END AS [24��]
	   ,CASE nb.id WHEN 1 THEN '25��' WHEN 3 THEN CAST(sg.[25��] AS VARCHAR) ELSE CAST(sbd.[25��] AS VARCHAR) END AS [25��]
	   ,CASE nb.id WHEN 1 THEN '26��' WHEN 3 THEN CAST(sg.[26��] AS VARCHAR) ELSE CAST(sbd.[26��] AS VARCHAR) END AS [26��]
	   ,CASE nb.id WHEN 1 THEN '27��' WHEN 3 THEN CAST(sg.[27��] AS VARCHAR) ELSE CAST(sbd.[27��] AS VARCHAR) END AS [27��]
	   ,CASE nb.id WHEN 1 THEN '28��' WHEN 3 THEN CAST(sg.[28��] AS VARCHAR) ELSE CAST(sbd.[28��] AS VARCHAR) END AS [28��]
	   ,CASE nb.id WHEN 1 THEN '29��' WHEN 3 THEN CAST(sg.[29��] AS VARCHAR) ELSE CAST(sbd.[29��] AS VARCHAR) END AS [29��]
	   ,CASE nb.id WHEN 1 THEN '30��' WHEN 3 THEN CAST(sg.[30��] AS VARCHAR) ELSE CAST(sbd.[30��] AS VARCHAR) END AS [30��]
	   ,CASE nb.id WHEN 1 THEN '31��' WHEN 3 THEN CAST(sg.[31��] AS VARCHAR) ELSE CAST(sbd.[31��] AS VARCHAR) END AS [31��]
FROM #Sales_Group sg
LEFT JOIN #Number nb ON nb.id <=5
LEFT JOIN #Sales_By_Day sbd ON sg.SKU = sbd.SKU AND nb.id = 2


END
GO
