USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [rpt].[SP_RPT_Qulouxia_SalesInventory]
AS
BEGIN

WITH A AS(
SELECT [Datekey],[SKU_ID],[Shelf_Life],SUM(INV_QTY) AS INV_QTY FROM (
SELECT DCI.[Datekey]
      ,P.[SKU_ID]    
	  ,CASE WHEN [Remain_Days]<=0 THEN 'Expired'
	        WHEN [Remain_Days]/CAST(P.Shelf_Life_D AS FLOAT)<1.00/3 THEN '<1/3'
	        WHEN [Remain_Days]/CAST(P.Shelf_Life_D AS FLOAT)>=1.00/3 AND [Remain_Days]/CAST(P.Shelf_Life_D AS FLOAT)<1.00/2  THEN '1/3-<1/2'
			WHEN [Remain_Days]/CAST(P.Shelf_Life_D AS FLOAT)>=1.00/2 THEN '>1/2'
			ELSE  'OTHERS' END Shelf_Life      
	  ,CASE WHEN LEN(DCI.SKU_ID)>7 THEN [Inventory_QTY]/P.Qty_BaseInSale ELSE [Inventory_QTY] END AS INV_QTY 
  FROM [Foodunion].[dm].[Fct_Qulouxia_DCInventory_Daily] DCI
  LEFT JOIN [dm].[Dim_Product] P
  ON REPLACE(DCI.SKU_ID,'_0','')=P.SKU_ID
  LEFT JOIN [dm].[Dim_Calendar] C
  ON DCI.DATEKEY=C.Datekey
  WHERE C.Day_of_Week=7)T
  GROUP BY [Datekey],[SKU_ID],[Shelf_Life])
 ,B AS (
SELECT PVT.[Datekey],PVT.SKU_ID,PVT.[<1/3],PVT.[1/3-<1/2],PVT.[>1/2],PVT.[Expired]
FROM A
  PIVOT(MAX(INV_QTY) FOR Shelf_Life IN([<1/3],[1/3-<1/2],[>1/2],[Expired])) AS PVT)
,C AS (SELECT S.DATEKEY
      ,P.[SKU_ID]   
      ,SUM(CASE WHEN LEN(S.SKU_ID)>7 THEN [Sales_Qty]/P.Qty_BaseInSale ELSE [Sales_Qty] END) AS QTY
     
  FROM [Foodunion].[dm].[Fct_Qulouxia_Sales] S
  LEFT JOIN [dm].[Dim_Calendar] C
  ON S.DATEKEY=C.Datekey
  LEFT JOIN [dm].[Dim_Product] P
  ON REPLACE(S.SKU_ID,'_0','')=P.SKU_ID
  WHERE Order_Status='已完成' AND Week_of_Year=28
  GROUP BY S.DATEKEY 
      ,P.[SKU_ID])
  

  SELECT [Datekey],[SKU_ID],SUM([<1/3]) [<1/3],SUM([1/3-<1/2]) [1/3-<1/2],SUM([>1/2]) [>1/2],SUM([Expired]) [Expired],SUM([QTY]) AS Sales_QTY
  FROM (
  SELECT [Datekey],[SKU_ID],ISNULL([<1/3],0) AS [<1/3],ISNULL([1/3-<1/2],0) AS [1/3-<1/2],ISNULL([>1/2],0) AS [>1/2],ISNULL([Expired],0) AS [Expired],0 AS [QTY] FROM B
  UNION
  SELECT [DATEKEY],[SKU_ID],0,0,0,0,QTY FROM C) T
  GROUP BY [Datekey],[SKU_ID]
  

END

GO
