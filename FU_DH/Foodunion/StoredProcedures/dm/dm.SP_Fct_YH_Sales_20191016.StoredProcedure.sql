USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_YH_Sales_20191016]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dm].[SP_Fct_YH_Sales_20191016]
	-- Add the parameters for the stored procedure here
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY
	/****** Script for SelectTopNRows command from SSMS  ******/
TRUNCATE TABLE [dm].[Fct_YH_Sales]


 DECLARE @Maxdate DATE
 SELECT @Maxdate=MAX(Calendar_DT) FROM [dw].[Fct_YH_Sales_All]

INSERT INTO [dm].[Fct_YH_Sales](
[POS_DT]
,[SKU_ID]
,[Store_ID]
,[Sales_AMT]
,[Sales_QTY]
,[Sales_VOL]
,[Sales_Ambient_AVG_AMT]
,[Sales_Chilled_AVG_AMT]
,[DiscountSales_AMT]
,[DiscountSales_QTY]
,[WithTax_SalesCost_AMT]
,[WithTax_Discount_AMT]
,[LY_Sales_AMT]
,[LY_Sales_QTY]
,[LM_Sales_AMT]
,[LM_Sales_QTY]
,[Sales_AVG_BY_STORE_LM_AMT]
,[Sales_AVG_BY_STORE_CM_AMT]
,[Sales_BY_Store_LM_AMT]
,[Sales_BY_Store_CM_AMT]
,YH_Home_Sales_AMT
,JD_Home_Sales_AMT
,[Create_Time]
,[Create_By]
,[Update_Time]
,[Update_By]
)
SELECT
[POS_DT]
,[SKU_ID]
,[Store_ID]
,SUM([Sales_AMT]					 )
,SUM([Sales_QTY]					 )
,SUM([Sales_VOL]					 )
,SUM([Sales_Ambient_AVG_AMT]		 )
,SUM([Sales_Chilled_AVG_AMT]		 )
,SUM([DiscountSales_AMT]			 )
,SUM([DiscountSales_QTY]			 )
,SUM([WithTax_SalesCost_AMT]		 )
,SUM([WithTax_Discount_AMT]			 )
,SUM([LY_Sales_AMT]					 )
,SUM([LY_Sales_QTY]					 )
,SUM([LM_Sales_AMT]					 )
,SUM([LM_Sales_QTY]					 )
,SUM([Sales_AVG_BY_STORE_LM_AMT]	 )
,SUM([Sales_AVG_BY_STORE_CM_AMT]	 )
,SUM([Sales_BY_Store_LM_AMT]		 )
,SUM([Sales_BY_Store_CM_AMT]		 )
,SUM(YH_Home_Sales_AMT		 )
,SUM(JD_Home_Sales_AMT		 )
,GETDATE() AS [Create_Time]
,OBJECT_NAME(@@PROCID) AS [Create_By]
,GETDATE() AS [Update_Time]
,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM(
SELECT 
 CU.[Calendar_DT] AS [POS_DT]
,CU.[SKU_ID]
,CU.[Store_ID]
,CU.[Sales_AMT]
,CU.[Sales_QTY]
,CU.[SC_Density_SKU_Ton_Num]*CU.[Sales_QTY] AS [Sales_VOL]
,[AVG].Sales_Ambient_AVG_AMT
,[AVG].Sales_Chilled_AVG_AMT
,CU.[DiscountSales_AMT]
,CU.[DiscountSales_QTY]
,CU.[WithTax_SalesCost_AMT]
,CU.[WithTax_Discount_AMT]
,0 AS [LY_Sales_AMT]
,0 AS [LY_Sales_QTY]
,0 AS [LM_Sales_AMT]
,0 AS [LM_Sales_QTY]
,0 AS [Sales_AVG_BY_STORE_LM_AMT]
,0 AS [Sales_AVG_BY_STORE_CM_AMT]
,(SELECT SUM(ASLM.Sales_AMT)/(COUNT(DISTINCT ASLM.Store_ID)) AS [Sales_AVG_7D_AMT] FROM [Foodunion].[dw].[Fct_YH_Sales_All] ASLM WHERE YEAR(ASLM.Calendar_DT)=YEAR(DATEADD(MONTH,-1,CU.Calendar_DT)) AND MONTH(ASLM.Calendar_DT)=MONTH(DATEADD(MONTH,-1,CU.Calendar_DT))) AS [Sales_BY_Store_LM_AMT]
,(SELECT SUM(ASCM.Sales_AMT)/(COUNT(DISTINCT ASCM.Store_ID)) AS [Sales_AVG_7D_AMT] FROM [Foodunion].[dw].[Fct_YH_Sales_All] ASCM WHERE YEAR(ASCM.Calendar_DT)=YEAR(CU.Calendar_DT) AND MONTH(ASCM.Calendar_DT)=MONTH(CU.Calendar_DT)) AS [Sales_BY_Store_CM_AMT]
,CU.YH_Home_Sales_AMT
,CU.JD_Home_Sales_AMT
,getdate() AS [Update_DTM]
 FROM [Foodunion].[dw].[Fct_YH_Sales_All] CU
  --LEFT JOIN [Foodunion].[dw].[Fct_YH_Sales_All] LM ON CU.[Calendar_DT] = DATEADD(MM,1,LM.[Calendar_DT]) AND CU.[SKU_ID] = LM.[SKU_ID] AND CU.[Store_ID] = LM.[Store_ID]
  --LEFT JOIN [Foodunion].[dw].[Fct_YH_Sales_All] LY ON CU.[Calendar_DT] = DATEADD(YY,1,LY.[Calendar_DT])  AND CU.[SKU_ID] = LY.[SKU_ID] AND CU.[Store_ID] = LY.[Store_ID]
  LEFT JOIN (SELECT Calendar_DT,
SUM(CASE YH_categroy WHEN 'Ambient' THEN Sales_AMT END )/SUM(CASE YH_categroy WHEN 'Ambient' THEN [SC_Density_SKU_Ton_Num]*[Sales_QTY] END )/1000 AS [Sales_Ambient_AVG_AMT],
SUM(CASE YH_categroy WHEN 'Fresh' THEN Sales_AMT WHEN 'Chilled' THEN Sales_AMT END )/SUM(CASE YH_categroy WHEN 'Fresh' THEN [SC_Density_SKU_Ton_Num]*[Sales_QTY] WHEN 'Chilled' THEN [SC_Density_SKU_Ton_Num]*[Sales_QTY] END )/1000 AS [Sales_Chilled_AVG_AMT]
 FROM [dw].[Fct_YH_Sales_All]  GROUP BY Calendar_DT) AS [AVG] ON CU.Calendar_DT = [AVG].Calendar_DT


 --------------------------LM
UNION ALL
SELECT 
 convert(varchar(8),DATEADD(MONTH,1,CU.[Calendar_DT]),112) AS [POS_DT]
,CU.[SKU_ID]
,CU.[Store_ID]
,0 AS [Sales_AMT]
,0 AS [Sales_QTY]
,0 AS [Sales_VOL]
,0 AS Sales_Ambient_AVG_AMT
,0 AS Sales_Chilled_AVG_AMT
,0 AS [DiscountSales_AMT]
,0 AS [DiscountSales_QTY]
,0 AS [WithTax_SalesCost_AMT]
,0 AS [WithTax_Discount_AMT]
,0 AS [LY_Sales_AMT]
,0 AS [LY_Sales_QTY]
,CU.[Sales_AMT] AS [LM_Sales_AMT]
,CU.[Sales_QTY] AS [LM_Sales_QTY]
,0 --(SELECT SUM(ALM.Sales_AMT)/COUNT(DISTINCT ALM.Store_ID) AS [Sales_AVG_7D_AMT] FROM [Foodunion].[dw].[Fct_YH_Sales_All] ALM WHERE MONTH(DATEADD(MONTH,-1,CU.Calendar_DT))=MONTH(ALM.Calendar_DT) AND YEAR(DATEADD(MONTH,-1,CU.Calendar_DT))=YEAR(ALM.Calendar_DT)/(SELECT COUNT(*) AS [Sales_AVG_7D_AMT] FROM [Foodunion].[dw].[Fct_YH_Sales_All] B7D WHERE B7D.Calendar_DT = CU.Calendar_DT AND B7D.Store_ID = CU.Store_ID) AS [Sales_AVG_BY_STORE_LM_AMT]
,0
,0 --(SELECT SUM(ASLM.Sales_AMT)/(COUNT(DISTINCT ASLM.Store_ID)) AS [Sales_AVG_7D_AMT] FROM [Foodunion].[dw].[Fct_YH_Sales_All] ASLM WHERE YEAR(ASLM.Calendar_DT)=YEAR(DATEADD(MONTH,-1,CU.Calendar_DT)) AND MONTH(ASLM.Calendar_DT)=MONTH(DATEADD(MONTH,-1,CU.Calendar_DT)))
,0 --(SELECT SUM(ASCM.Sales_AMT)/(COUNT(DISTINCT ASCM.Store_ID)) AS [Sales_AVG_7D_AMT] FROM [Foodunion].[dw].[Fct_YH_Sales_All] ASCM WHERE YEAR(ASCM.Calendar_DT)=YEAR(CU.Calendar_DT) AND MONTH(ASCM.Calendar_DT)=MONTH(CU.Calendar_DT))
,0
,0
,getdate() AS [Update_DTM]
 FROM [Foodunion].[dw].[Fct_YH_Sales_All] CU
  --LEFT JOIN [Foodunion].[dw].[Fct_YH_Sales_All] LM ON CU.[Calendar_DT] = DATEADD(MM,1,LM.[Calendar_DT]) AND CU.[SKU_ID] = LM.[SKU_ID] AND CU.[Store_ID] = LM.[Store_ID]
  --LEFT JOIN [Foodunion].[dw].[Fct_YH_Sales_All] LY ON CU.[Calendar_DT] = DATEADD(YY,1,LY.[Calendar_DT])  AND CU.[SKU_ID] = LY.[SKU_ID] AND CU.[Store_ID] = LY.[Store_ID]
  LEFT JOIN (SELECT Calendar_DT,
SUM(CASE YH_categroy WHEN 'Ambient' THEN Sales_AMT END )/SUM(CASE YH_categroy WHEN 'Ambient' THEN [SC_Density_SKU_Ton_Num]*[Sales_QTY] END )/1000 AS [Sales_Ambient_AVG_AMT],
SUM(CASE YH_categroy WHEN 'Fresh' THEN Sales_AMT WHEN 'Chilled' THEN Sales_AMT END )/SUM(CASE YH_categroy WHEN 'Fresh' THEN [SC_Density_SKU_Ton_Num]*[Sales_QTY] WHEN 'Chilled' THEN [SC_Density_SKU_Ton_Num]*[Sales_QTY] END )/1000 AS [Sales_Chilled_AVG_AMT]
 FROM [dw].[Fct_YH_Sales_All]  GROUP BY Calendar_DT) AS [AVG] ON CU.Calendar_DT = [AVG].Calendar_DT
 WHERE DATEADD(MONTH,1,CU.[Calendar_DT])<= @Maxdate
 ) base
 GROUP BY 
 [POS_DT]
,[SKU_ID]
,[Store_ID]

END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
