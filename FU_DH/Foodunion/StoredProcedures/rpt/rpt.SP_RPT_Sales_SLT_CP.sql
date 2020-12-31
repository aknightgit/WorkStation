USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [rpt].[SP_RPT_Sales_SLT_CP]
AS BEGIN 
                                                                                   -- 修改规则： 上传指标 由金额变成吨数 ，逻辑修改增加吨数计算字段 --Justin 2020-01-02
 WITH A AS (
 SELECT MonthKey,
       ERP_Customer_Name,
	   Customer_Handler,
	   Channel_Category,
	   Channel_Handler,
	   SUM([Amount])/1000 AS [Amount] ,
	   SUM(Vol_MT) AS Vol_MT,
	   SUM([Target_Amt_KRMB]) AS [Target_Amt_KRMB],
	   SUM([Target_Vol_MT]) AS [Target_Vol_MT],
	   SUM([Category_Target_Amt_KRMB]) AS [Category_Target_Amt_KRMB],
	   SUM([Category_Target_Vol_MT]) AS [Category_Target_Vol_MT]
FROM(
SELECT LEFT([DateKey],6) AS MonthKey
	  ,C.[ERP_Customer_Name]
	  ,ISNULL(CH.Customer_Handler,C.Channel_Handler) AS Customer_Handler
	  ,C.Channel_Category
	  ,C.Channel_Handler    
      ,SUM([Amount]) AS [Amount]  
	  ,SUM(Weight_KG)/1000 Vol_MT
	  ,0 AS [Target_Amt_KRMB]
	  ,0 AS [Target_Vol_MT]
	  ,0 AS [Category_Target_Amt_KRMB]
	  ,0 AS [Category_Target_Vol_MT]
  FROM [dm].[Fct_Sales_SellIn_ByChannel] SS
  LEFT JOIN [dm].[Dim_Channel] C
  ON SS.Channel_ID=C.Channel_ID
  LEFT JOIN (SELECT DISTINCT  MONTHKEY,ISNULL(B.[Customer_Name],A.[Region_Name_EN]) AS [Customer_Name], ISNULL(A.Manager,A.CP_Manager) AS Customer_Handler  
		 FROM [ODS].[ods].[File_CP_ManagerTarget] A
		 LEFT JOIN [dm].[Dim_ERP_CustomerList] B
		 ON  B.ERP_Code=A.[ERP_Customer_Code]) CH
  ON C.[ERP_Customer_Name]=CH.Customer_Name AND LEFT(SS.[DateKey],6) =CH.MonthKey
  WHERE C.Channel_Type='Distributor'                             --将Channel_Type 中 CP改成Distributor   Justin 2020-05-07
  GROUP BY LEFT([DateKey],6) 
	  ,C.[ERP_Customer_Name]
	  ,ISNULL(CH.Customer_Handler,C.Channel_Handler)
	  ,C.Channel_Category
	  ,C.Channel_Handler   

UNION ALL
SELECT [MonthKey]
      ,ST.[ERP_Customer_Name]
	  ,ISNULL(ST.Customer_Handler,ISNULL(ST.Channel_Handler, C.Channel_Handler)) AS Customer_Handler
	  ,ISNULL(ST.Channel_Category_Name, C.Channel_Category) AS Channel_Category
	  ,ISNULL(ST.Channel_Handler, C.Channel_Handler) AS Channel_Handler
	  ,0 AS Amount
	  ,0 AS Vol_MT
	  ,SUM([Target_Amt_KRMB]) AS [Target_Amt_KRMB]
	  ,SUM([Target_Vol_MT]) AS [Target_Vol_MT]
      ,SUM([Category_Target_Amt_KRMB]) AS [Category_Target_Amt_KRMB]
	  ,SUM([Category_Target_Vol_MT]) AS [Category_Target_Vol_MT]
  FROM [dm].[Fct_Sales_SellInTarget_ByChannel] ST
  LEFT JOIN [dm].[Dim_Channel] C
  ON ST.ERP_Customer_Name=C.[ERP_Customer_Name]
  WHERE ST.[Channel_Type]='Distributor'                            --将Channel_Type 中 CP改成Distributor   Justin 2020-05-07
  GROUP BY  [MonthKey]
      ,ST.[ERP_Customer_Name]
	  ,ISNULL(ST.Customer_Handler,ISNULL(ST.Channel_Handler, C.Channel_Handler))
	  ,ISNULL(ST.Channel_Category_Name, C.Channel_Category)
	  ,ISNULL(ST.Channel_Handler, C.Channel_Handler)  ) T
	  WHERE Customer_Handler IS NOT NULL
	  GROUP BY MonthKey,ERP_Customer_Name,Customer_Handler,Channel_Category,Channel_Handler)

,Total_H as (
SELECT MonthKey,
       Customer_Handler,
	   Channel_Category,
	   CAST(CAST(SUM(ISNULL([Amount],0)) AS decimal(38, 1)) AS CHAR) AS [Amount],
	   CAST(CAST(SUM(ISNULL([Target_Amt_KRMB],0)) AS decimal(38, 1)) AS CHAR) AS [Target_Amt_KRMB],
	   REPLACE(CAST(CAST(CASE WHEN SUM(ISNULL([Target_Amt_KRMB],0))=0 THEN 0 ELSE SUM(ISNULL([Amount],0))/SUM(ISNULL([Target_Amt_KRMB],0))*100 END AS decimal(38, 0)) AS CHAR)+'%',' ','') Ratio,
	   CAST(CAST(SUM(ISNULL(Vol_MT,0)) AS decimal(38, 1)) AS CHAR) AS Vol_MT,
	   CAST(CAST(SUM(ISNULL([Target_Vol_MT],0)) AS decimal(38, 1)) AS CHAR) AS [Target_Vol_MT],
	   REPLACE(CAST(CAST(CASE WHEN SUM(ISNULL([Target_Vol_MT],0))=0 THEN 0 ELSE SUM(ISNULL(Vol_MT,0))/SUM(ISNULL([Target_Vol_MT],0))*100 END AS decimal(38, 0)) AS CHAR)+'%',' ','') Ratio_MT
	   FROM A
GROUP BY MonthKey,Customer_Handler,Channel_Category)

,Total_C as (
SELECT MonthKey,
       ' Subtotal' as Customer_Handler,
	   Channel_Category,
	   CAST(CAST(SUM(ISNULL([Amount],0)) AS decimal(38, 1)) AS CHAR) AS [Amount],
	   CAST(CAST(SUM(ISNULL([Category_Target_Amt_KRMB],0)) AS decimal(38, 1)) AS CHAR) AS [Category_Target_Amt_KRMB],
	   REPLACE(CAST(CAST(CASE WHEN SUM(ISNULL([Category_Target_Amt_KRMB],0))=0 THEN 0 ELSE SUM(ISNULL([Amount],0))/SUM(ISNULL([Category_Target_Amt_KRMB],0))*100 END AS decimal(38, 0)) AS CHAR)+'%',' ','') Ratio,
	   CAST(SUM(ISNULL([Amount],0)) AS decimal(38, 1)) AS [Amount_S],
	   CAST(CAST(SUM(ISNULL(Vol_MT,0)) AS decimal(38, 1)) AS CHAR) AS Vol_MT,
	   CAST(CAST(SUM(ISNULL([Category_Target_Vol_MT],0)) AS decimal(38, 1)) AS CHAR) AS [Category_Target_Vol_MT],
	   REPLACE(CAST(CAST(CASE WHEN SUM(ISNULL([Category_Target_Vol_MT],0))=0 THEN 0 ELSE SUM(ISNULL(Vol_MT,0))/SUM(ISNULL([Category_Target_Vol_MT],0))*100 END AS decimal(38, 0)) AS CHAR)+'%',' ','') Ratio_MT,
	   CAST(SUM(ISNULL(Vol_MT,0)) AS decimal(38, 1)) AS [Vol_MT_S]
	   FROM A
GROUP BY MonthKey,Channel_Category )

,Total as (
SELECT MonthKey,
       '' as Customer_Handler,
	   'Total' as Channel_Category,
	   CAST(CAST(SUM(ISNULL([Amount],0)) AS decimal(38, 1)) AS CHAR) AS [Amount],
	   CAST(CAST(SUM(ISNULL([Category_Target_Amt_KRMB],0)) AS decimal(38, 1)) AS CHAR) AS [Target_Amt_KRMB],
	   REPLACE(CAST(CAST(CASE WHEN SUM(ISNULL([Category_Target_Amt_KRMB],0))=0 THEN 0 ELSE SUM(ISNULL([Amount],0))/SUM(ISNULL([Category_Target_Amt_KRMB],0))*100 END AS decimal(38, 0)) AS CHAR)+'%',' ','') AS Ratio,
	   CAST(SUM(ISNULL([Amount],0)) AS decimal(38, 1)) AS [Amount_T],
	   CAST(CAST(SUM(ISNULL(Vol_MT,0)) AS decimal(38, 1)) AS CHAR) AS Vol_MT,
	   CAST(CAST(SUM(ISNULL([Category_Target_Vol_MT],0)) AS decimal(38, 1)) AS CHAR) AS [Category_Target_Vol_MT],
	   REPLACE(CAST(CAST(CASE WHEN SUM(ISNULL([Category_Target_Vol_MT],0))=0 THEN 0 ELSE SUM(ISNULL(Vol_MT,0))/SUM(ISNULL([Category_Target_Vol_MT],0))*100 END AS decimal(38, 0)) AS CHAR)+'%',' ','') AS Ratio_MT,
	   CAST(SUM(ISNULL(Vol_MT,0)) AS decimal(38, 1)) AS [Vol_MT_T]
	   FROM A
GROUP BY MonthKey )

SELECT A.MonthKey,
      [ERP_Customer_Name],
	  A.Customer_Handler,
	  A.Channel_Category,
	  Total_H.[Amount] AS Amount_H,
	  Total_H.Target_Amt_KRMB,
	  CASE WHEN Total_H.Ratio='0%' THEN '' ELSE Total_H.Ratio END AS Ratio,
	  CAST(A.Amount AS decimal(38, 1)) AS Amount ,
	  Total_H.Vol_MT AS Vol_MT_H,
	  Total_H.[Target_Vol_MT] AS Target_Vol_MT_H,
	  CASE WHEN Total_H.Ratio_MT='0%' THEN '' ELSE Total_H.Ratio_MT END AS Ratio_MT,
	  CAST(A.Vol_MT AS decimal(38, 1)) AS Vol_MT 
FROM A
LEFT JOIN Total_H 
ON A.Customer_Handler=Total_H.Customer_Handler AND A.MonthKey=Total_H.MonthKey
WHERE A.Vol_MT<>0 
      --OR cast(Total_H.Target_Amt_KRMB as decimal(38, 1)) <>0 
      OR ([ERP_Customer_Name]  LIKE '%CP%')
UNION ALL
SELECT MonthKey,
       ''AS [ERP_Customer_Name],
	   Customer_Handler,
	   Channel_Category,
	   [Amount],
	   [Category_Target_Amt_KRMB],
	   Ratio,
	   [Amount_S],
	   Vol_MT,
	   [Category_Target_Vol_MT],
	   Ratio_MT,
	   [Vol_MT_S]
	   FROM Total_C
UNION ALL
SELECT MonthKey,
       ''AS [ERP_Customer_Name],
	   Customer_Handler,
	   Channel_Category,
	   [Amount],
	   [Target_Amt_KRMB],
	   Ratio,
	   [Amount_T],
	   Vol_MT,
	   [Category_Target_Vol_MT],
	   Ratio_MT,
	   [Vol_MT_T]
	   FROM Total


END



GO
