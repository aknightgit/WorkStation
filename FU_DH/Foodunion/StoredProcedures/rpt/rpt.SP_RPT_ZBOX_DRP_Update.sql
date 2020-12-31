USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [rpt].[SP_RPT_ZBOX_DRP_Update]
AS
BEGIN

	/****** SSMS 的 SelectTopNRows 命令的脚本  ******/
--计算Forecast WeekName
  DROP TABLE IF EXISTS #YEARWEEK;
  SELECT [Year]    
      ,[Week_of_Year]
      ,[Week_of_Year_Str]
	  ,Year_Week
      ,LEAD(CAST([Year] AS NVARCHAR)+[Week_of_Year_Str],1)OVER(ORDER BY YEAR,WEEK_OF_YEAR) AS Year_Week_1
	  ,LEAD(CAST([Year] AS NVARCHAR)+[Week_of_Year_Str],2)OVER(ORDER BY YEAR,WEEK_OF_YEAR) AS Year_Week_2
	  ,LEAD(CAST([Year] AS NVARCHAR)+[Week_of_Year_Str],3)OVER(ORDER BY YEAR,WEEK_OF_YEAR) AS Year_Week_3

	  INTO #YEARWEEK
FROM (
SELECT DISTINCT [Year]    
      ,[Week_of_Year]
      ,[Week_of_Year_Str]
      ,CAST([Year] AS NVARCHAR)+[Week_of_Year_Str] AS Year_Week	 
  FROM [Foodunion].[dm].[Dim_Calendar]) T

  --计算SKU 周累计销售
  DROP TABLE IF EXISTS #Sales1;
  SELECT LEFT(SKU_ID,7) AS SKU_ID,Week_Nature_Str,Week_of_Year,SUM(Sales_Qty) AS Sales_Qty  INTO #Sales1
  FROM (
  SELECT S.SKU_ID,P.[Qty_BaseInSale],C.Week_Nature_Str,C.Week_of_Year,
         CASE WHEN LEN(S.SKU_ID)>7 THEN Sales_Qty/P.[Qty_BaseInSale] ELSE Sales_Qty END AS Sales_Qty
  FROM [Foodunion].[dm].[Fct_Qulouxia_Sales] S
  LEFT JOIN [dm].[Dim_Calendar] C
  ON S.DATEKEY=C.Datekey
  LEFT JOIN (SELECT * FROM [dm].[Dim_Product] WHERE LEN(SKU_ID)=7) P
  ON LEFT(S.SKU_ID,7)=P.SKU_ID
  WHERE [Order_Status]<>'已取消' AND LEFT(S.DATEKEY,4)=YEAR(GETDATE())  
  ) T
  GROUP BY LEFT(SKU_ID,7),Week_Nature_Str,Week_of_Year

  --计算SKU 前4周平均销售
  DROP TABLE IF EXISTS #Sales2;
  SELECT S1.SKU_ID,S1.Week_Nature_Str,S1.Week_of_Year,SUM(S2.Sales_Qty)/4 AS Sales_Qty INTO #Sales2
  FROM #Sales1 AS S1 
  LEFT JOIN #Sales1 AS S2
  ON S1.SKU_ID=S2.SKU_ID AND S1.Week_of_Year>S2.Week_of_Year AND S1.Week_of_Year<=S2.Week_of_Year+4
  GROUP BY S1.SKU_ID,S1.Week_Nature_Str,S1.Week_of_Year
  ORDER BY 1,2,3


 --计算最后一个周日库存数量
DROP TABLE IF EXISTS #INV1;
SELECT INV.[Datekey]
      ,C.Week_Nature_Str
	  ,C.Week_of_Year_Str
	  ,C.Week_of_Year
      ,INV.[SKU_ID]
	  ,P1.SKU_Name
	  ,P1.SKU_Name_CN
	  ,P.Plant
	  ,LEFT(P.Product_Sort,1) AS [F/A]
	  ,P.Product_Category	      
	  ,CASE WHEN LEN(INV.SKU_ID)>7 THEN 'C' ELSE 'P' END AS [P/C SKU]
	  ,LEFT(INV.SKU_ID,7) AS P_SKU
	  ,P.Shelf_Life_D
	  ,CASE WHEN P.Product_Sort='Ambient' THEN 45 WHEN P.Product_Sort='Fresh' THEN 12 ELSE 0 END AS Max_Days
	  ,CASE WHEN P.Product_Sort='Ambient' THEN 14 WHEN P.Product_Sort='Fresh' THEN 3 ELSE 0 END AS Min_Days
      ,[Inventory_QTY]
	  ,CASE WHEN LEN(INV.SKU_ID)>7 THEN P1.Qty_BaseInSale ELSE 1 END AS Units_per_Parent
	  ,[Inventory_QTY]/(CASE WHEN LEN(INV.SKU_ID)>7 THEN P1.Qty_BaseInSale ELSE 1 END) AS PE
      INTO #INV1
  FROM [Foodunion].[dm].[Fct_Qulouxia_DCInventory_Daily] AS INV
  LEFT JOIN [dm].[Dim_Calendar] C
  ON INV.Datekey=C.Datekey
  LEFT JOIN [dm].[Dim_Product] P
  ON INV.SKU_ID=P.SKU_ID
  LEFT JOIN (SELECT * FROM [dm].[Dim_Product] WHERE LEN(SKU_ID)=7) P1
  ON LEFT(INV.SKU_ID,7)=P1.SKU_ID
  WHERE INV.Datekey=(SELECT MAX(INV.DATEKEY) FROM [dm].[Fct_Qulouxia_DCInventory_Daily] INV LEFT JOIN [dm].[Dim_Calendar] C ON INV.Datekey=C.Datekey WHERE C.[Week_Day_Name]='Sunday')

  --计算Parent SKU 总销量
  DROP TABLE IF EXISTS #INV2;
  SELECT *,
         CASE WHEN [P/C SKU]='P' THEN SUM(PE)OVER(PARTITION BY DATEKEY,P_SKU) ELSE NULL END AS POS 
		 INTO #INV2
  FROM (
  SELECT [Datekey]
      ,Week_Nature_Str
	  ,Week_of_Year_Str
	  ,Week_of_Year
      ,LEFT([SKU_ID],7) AS [SKU_ID]
	  ,SKU_Name
	  ,SKU_Name_CN
	  ,Plant
	  ,[F/A]
	  ,Product_Category	      
	  ,'P'[P/C SKU]
	  ,P_SKU
	  ,Shelf_Life_D
	  ,Max_Days
	  ,Min_Days
      ,SUM([Inventory_QTY]) [Inventory_QTY]
	  ,1 Units_per_Parent
	  ,SUM(PE) PE	  
   FROM #INV1
   GROUP BY [Datekey]
      ,Week_Nature_Str
	  ,Week_of_Year_Str
	  ,Week_of_Year
      ,LEFT([SKU_ID],7)
	  ,SKU_Name
	  ,SKU_Name_CN
	  ,Plant
	  ,[F/A]
	  ,Product_Category	      
	  --,[P/C SKU]
	  ,P_SKU
	  ,Shelf_Life_D
	  ,Max_Days
	  ,Min_Days       
	  --,Units_per_Parent
	  ) T


	  SELECT [Datekey],
			 INV.Week_Nature_Str,			
			 INV.[SKU_ID],
			 SKU_Name,
			 SKU_Name_CN,
			 Plant,
			 [F/A],
			 Product_Category AS PlanGroup,      
			 [P/C SKU],
			 P_SKU,
			 Shelf_Life_D,
			 Max_Days,
			 Min_Days,   
			 [Inventory_QTY] AS OpeningStock,
			 YW.Year_Week,
			 Units_per_Parent,
			 PE,
			 POS,
			 YW.Year_Week_1,
			 S2.Sales_Qty AS Forecast_1,
			 INV.Inventory_QTY-S2.Sales_Qty AS PCS_1,
			 (INV.Inventory_QTY-S2.Sales_Qty)/S2.Sales_Qty AS PDC_1,
			 YW.Year_Week_2,
			 S2.Sales_Qty AS Forecast_2,
			 INV.Inventory_QTY-S2.Sales_Qty*2 AS PCS_2,
			 (INV.Inventory_QTY-S2.Sales_Qty*2)/S2.Sales_Qty AS PDC_2,
			 YW.Year_Week_3,
			 S2.Sales_Qty AS Forecast_3,
			 INV.Inventory_QTY-S2.Sales_Qty*3 AS PCS_3,
			 (INV.Inventory_QTY-S2.Sales_Qty*3)/S2.Sales_Qty AS PDC_3
	  FROM #INV2 AS INV
	  LEFT JOIN #Sales2 AS S2
	  ON INV.SKU_ID=S2.SKU_ID AND INV.Week_Nature_Str=S2.Week_Nature_Str
	  LEFT JOIN #YEARWEEK AS YW
	  ON LEFT(INV.Datekey,4)=YW.Year AND INV.Week_of_Year=YW.Week_of_Year
	  ORDER BY 3
	  ;



END
GO
