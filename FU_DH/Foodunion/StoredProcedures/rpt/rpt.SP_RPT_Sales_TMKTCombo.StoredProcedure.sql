USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_Sales_TMKTCombo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





  CREATE PROCEDURE [rpt].[SP_RPT_Sales_TMKTCombo]
  AS
  BEGIN




------------------------------Sales From KA BY DATE,STORE
DROP TABLE IF EXISTS #KA_Sales_Day
SELECT Datekey
	  ,ds.Account_Store_Code
	  ,ds.Channel_Account
	  ,CAST(SUM(Sales_AMT) AS DECIMAL(18,2)) AS Sales_AMT
INTO #KA_Sales_Day
FROM dm.Fct_KAStore_DailySalesInventory kasi
LEFT JOIN dm.Dim_Store ds ON kasi.Store_ID = ds.Store_ID
GROUP BY Datekey
	  ,ds.Account_Store_Code
	  ,ds.Channel_Account

------------------------------Sales From KA BY MONTH,STORE
DROP TABLE IF EXISTS #KA_Sales_Month
SELECT Datekey/100 AS MonthKey
	  ,Account_Store_Code
	  ,Channel_Account
	  ,SUM(Sales_AMT) AS Sales_AMT
INTO #KA_Sales_Month
FROM #KA_Sales_Day kasi
GROUP BY Datekey/100
	    ,Account_Store_Code
	    ,Channel_Account

SELECT * FROM (
SELECT '���' AS [Seq]
      ,'�·�' AS [Year_Month]
      ,'����' AS [Region]
      ,'ʡ' AS [Province]
      ,'����' AS [City]
      ,'����' AS [District]
      ,'�ŵ��������' AS [Store_Region_Type]
      ,'�ŵ꼶��' AS [Store_Level]
      ,'�ͻ�����' AS [Customer_Name]
      ,'�ŵ�����' AS [Store_Type]
      ,'�ŵ���' AS [Store_Code]
      ,'�ŵ�����' AS [Store_Name]
      ,'MD HC' AS [MD_HC]
      ,'MD_R HC' AS [MD_R_HC]
      ,'MD_S HC' AS [MD_S_HC]
      ,'�ٴ� HC' AS [Temporary_promotion_HC]
      ,'�˼�' AS [End_frame]
      ,'���γ���' AS [Display2]
      ,'���Գ�' AS [Test_Eat]
      ,'ִ�й�˾' AS [Executive_company]
      ,'��������' AS [Sales_AMT_LM]
      ,'����Ŀ��' AS [Sales_Target_CM]
      ,'��������MTD' AS [Sales_MTD]
      ,'1��' AS [Day_1]
      ,'2��' AS [Day_2]
      ,'3��' AS [Day_3]
      ,'4��' AS [Day_4]
      ,'5��' AS [Day_5]
      ,'6��' AS [Day_6]
      ,'7��' AS [Day_7]
      ,'8��' AS [Day_8]
      ,'9��' AS [Day_9]
      ,'10��' AS [Day_10]
      ,'11��' AS [Day_11]
      ,'12��' AS [Day_12]
      ,'13��' AS [Day_13]
      ,'14��' AS [Day_14]
      ,'15��' AS [Day_15]
      ,'16��' AS [Day_16]
      ,'17��' AS [Day_17]
      ,'18��' AS [Day_18]
      ,'19��' AS [Day_19]
      ,'20��' AS [Day_20]
      ,'21��' AS [Day_21]
      ,'22��' AS [Day_22]
      ,'23��' AS [Day_23]
      ,'24��' AS [Day_24]
      ,'25��' AS [Day_25]
      ,'26��' AS [Day_26]
      ,'27��' AS [Day_27]
      ,'28��' AS [Day_28]
      ,'29��' AS [Day_29]
      ,'30��' AS [Day_30]
      ,'31��' AS [Day_31]
UNION ALL
SELECT tmkt.[Seq]
      ,tmkt.[Year_Month]
      ,tmkt.[Region]
      ,tmkt.[Province]
      ,tmkt.[City]
      ,tmkt.[District]
      ,tmkt.[Store_Region_Type]
      ,tmkt.[Store_Level]
      ,tmkt.[Customer_Name]
      ,tmkt.[Store_Type]
      ,tmkt.[Store_Code]
      ,tmkt.[Store_Name]
      ,tmkt.[MD_HC]
      ,tmkt.[MD_R_HC]
      ,tmkt.[MD_S_HC]
      ,tmkt.[Temporary_promotion_HC]
      ,tmkt.[End_frame]
      ,tmkt.[Display2]
      ,tmkt.[Test_Eat]
      ,tmkt.[Executive_company]
      ,CAST(MAX(kasm.Sales_AMT) AS VARCHAR) AS [Sales_AMT_LM]
      ,NULL AS [Sales_Target_CM]
      ,CAST(SUM(kasd.Sales_AMT) AS VARCHAR) [Sales_MTD]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='01' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_1]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='02' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_2]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='03' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_3]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='04' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_4]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='05' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_5]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='06' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_6]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='07' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_7]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='08' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_8]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='09' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_9]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='10' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_10]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='11' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_11]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='12' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_12]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='13' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_13]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='14' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_14]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='15' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_15]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='16' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_16]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='17' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_17]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='18' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_18]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='19' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_19]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='20' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_20]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='21' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_21]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='22' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_22]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='23' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_23]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='24' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_24]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='25' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_25]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='26' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_26]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='27' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_27]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='28' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_28]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='29' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_29]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='30' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_30]
      ,CAST(SUM(CASE WHEN RIGHT(kasd.DateKey,2)='31' THEN kasd.Sales_AMT ELSE NULL END) AS VARCHAR) AS [Day_31] 
FROM ODS.ods.File_TMKT_MD tmkt
LEFT JOIN #KA_Sales_Day kasd ON tmkt.Store_Code = kasd.Account_Store_Code AND tmkt.Year_Month = LEFT(kasd.Datekey,6)
LEFT JOIN #KA_Sales_Month kasm ON tmkt.Store_Code = kasm.Account_Store_Code AND kasm.[MonthKey]+CASE WHEN kasm.MonthKey%100=12 THEN 89 ELSE 1 END=tmkt.Year_Month
WHERE tmkt.Year_Month = LEFT(CONVERT(VARCHAR(8),GETDATE(),112),6)
GROUP BY tmkt.[Seq]
      ,tmkt.[Year_Month]
      ,tmkt.[Region]
      ,tmkt.[Province]
      ,tmkt.[City]
      ,tmkt.[District]
      ,tmkt.[Store_Region_Type]
      ,tmkt.[Store_Level]
      ,tmkt.[Customer_Name]
      ,tmkt.[Store_Type]
      ,tmkt.[Store_Code]
      ,tmkt.[Store_Name]
      ,tmkt.[MD_HC]
      ,tmkt.[MD_R_HC]
      ,tmkt.[MD_S_HC]
      ,tmkt.[Temporary_promotion_HC]
      ,tmkt.[End_frame]
      ,tmkt.[Display2]
      ,tmkt.[Test_Eat]
      ,tmkt.[Executive_company]
) ORD ORDER BY CAST(CASE WHEN ISNUMERIC(Seq) = 0 THEN 0 ELSE Seq END AS INT)


END
GO
