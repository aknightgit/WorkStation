USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_ERP_Inventory_20190626]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




























-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROC  [rpt].[SP_RPT_ERP_Inventory_20190626]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	/****** Script for SelectTopNRows command from SSMS  ******/



---------����è��ʿ��ERP����
SELECT SKU_ID
	  ,INVENTORY_DT
	  ,MANUFACTURING_DT
	  ,EXPIRING_DT
	  ,SUM(INVENTORY_QTY) AS INVENTORY_QTY
	  ,SUM(WEIGHT_NBR) AS WEIGHT_NBR
	  ,WAREHOUSE_ID
	  ,FRESH_DAY
	  ,GUARANTEE_PERIOD
	  ,GUARANTEE_PERIOD_TYPE
	  ,FRESH_TYPE
	  ,Storaging_DT
	  ,Is_Damaged
	  ,Is_Expired
	  ,Storaging_Days
	  ,Best_Sales_DT
	  ,Best_Sales_Days
	  ,Expired_Flag
	  ,GETDATE() AS Update_DTM
	  INTO #Inventory
FROM(
	SELECT
	 T.SKU_ID,
	 convert(varchar(8),T.INVENTORY_DT,112) AS INVENTORY_DT,
	 T.MANUFACTURING_DT,
	 T.EXPIRING_DT,
	 T.INVENTORY_QTY,
	 T.Inventory_QTY*T1.Sale_Unit_Weight_KG/1000 WEIGHT_NBR,
	 T.WAREHOUSE_ID,
	 DATEDIFF(DAY,INVENTORY_DT,DATEADD(DAY,CAST(T1.Shelf_Life_D AS INT),MANUFACTURING_DT)) FRESH_DAY,
	 CAST(T1.Shelf_Life_D AS INT) [GUARANTEE_PERIOD],
	 CASE WHEN CAST(T1.Shelf_Life_D AS INT)<35 THEN 'D(S):<35 Days'
	      WHEN CAST(T1.Shelf_Life_D AS INT) BETWEEN 35  AND 100 THEN 'D:35~100 Days'
		  WHEN CAST(T1.Shelf_Life_D AS INT)> 100 THEN 'D(L):>100 Days'
		  ELSE '' END [GUARANTEE_PERIOD_TYPE],
	 CASE WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) <CAST(1 AS DECIMAL)/3 THEN '<1/3'
	      WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) BETWEEN 
	       CAST(1 AS DECIMAL)/3  AND  CAST(1 AS DECIMAL)/2   THEN '1/3~1/2'
	      WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) BETWEEN 
	       CAST(1 AS DECIMAL)/2  AND  CAST(2 AS DECIMAL)/3   THEN '1/2~2/3'
	     WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) >CAST(2 AS DECIMAL)/3  AND 
		   CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) <1 THEN '>2/3'
		WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) >=1
		     THEN 'Expired'
			 ELSE '' END [FRESH_TYPE],
	T.Storaging_DT,
	NULL AS Is_Damaged,
	NULL AS Is_Expired,
	(CASE WHEN DATEDIFF(DAY,T.Storaging_DT,T.Inventory_DT)<5 THEN '<5 Days' 
	     WHEN DATEDIFF(DAY,T.Storaging_DT,T.Inventory_DT)<=15 THEN '5~15 Days'
		 WHEN DATEDIFF(DAY,T.Storaging_DT,T.Inventory_DT)<=30 THEN '16~30 Days'
		 WHEN DATEDIFF(DAY,T.Storaging_DT,T.Inventory_DT)>30 THEN '>30 Days'
		 ELSE '' END) Storaging_Days,
	DATEADD(DAY,T1.Shelf_Life_D/3,MANUFACTURING_DT) AS Best_Sales_DT,
	DATEDIFF(DAY,CAST(T.Inventory_DT AS DATE),DATEADD(DAY,T1.Shelf_Life_D/3,MANUFACTURING_DT)) AS Best_Sales_Days,
	CASE WHEN (CAST(T.Inventory_DT AS DATE)=DATEADD(DAY,T1.Shelf_Life_D*2/3,MANUFACTURING_DT)) OR (CAST(T.Inventory_DT AS DATE)=CAST(T.Storaging_DT AS DATE) AND CAST(T.Storaging_DT AS DATE)>=DATEADD(DAY,T1.Shelf_Life_D*2/3,MANUFACTURING_DT)) THEN 1 ELSE 0 END AS Expired_Flag
	  FROM [FOODUNION].[FU_EDW].[T_EDW_FCT_INVENTORY_ERP_JIT_ALL] T
	  LEFT JOIN [dm].[Dim_Product] T1 ON T1.SKU_ID=T.SKU_ID
	 LEFT JOIN ( 
	 SELECT T2.FNUMBER,T1.FPRICE FROM [FU_ODS].[T_ODS_ERP_APPLYCUSTOMER] T
	LEFT JOIN (SELECT *,ROW_NUMBER() OVER(PARTITION BY FID,FMATERIALID ORDER BY FEFFECTIVEDATE) RN FROM [FU_ODS].[T_ODS_ERP_PRICELISTENTRY] WHERE FPRICEUNITID<>0) T1 ON T1.FID=T.FID AND T1.RN=1
	LEFT JOIN [FU_ODS].[T_ODS_ERP_MATERIAL] T2 ON T2.FMATERIALID=T1.FMATERIALID
	WHERE  FCUSTID IN (
	SELECT DISTINCT FCUSTID FROM [FU_ODS].[T_ODS_ERP_CUSTOMER_L]
	WHERE FNAME='��ƽ���̹�Ӧ���������޹�˾'
	)
	)T2 ON T2.FNUMBER=T1.SKU_ID
	LEFT JOIN FU_EDW.T_EDW_DIM_Warehouse T3 ON T.Warehouse_ID = T3.Warehouse_ID
	WHERE  T3.[3PL_SNM] IS NOT NULL AND T1.SKU_ID IS NOT NULL AND CAST(T.INVENTORY_QTY AS DECIMAL)>0 AND ISNULL(T3.[3PL_SNM],'')<>'MW'			
	UNION ALL
	-------------------è��ʿ���ֹ�����
	SELECT
	 T.SKU_ID,
	 CONVERT(varchar(100),T.INVENTORY_DT, 112) INVENTORY_DT,
	 T.MANUFACTURING_DT,
	 T.EXPIRING_DT,
	 T.INVENTORY_QTY,
	 T.Inventory_QTY*T1.Sale_Unit_Weight_KG/1000 WEIGHT_NBR,
	 T.WAREHOUSE_ID,
	 DATEDIFF(DAY,INVENTORY_DT,DATEADD(DAY,CAST(T1.Shelf_Life_D AS INT),MANUFACTURING_DT)) FRESH_DAY,
	 CAST(T1.Shelf_Life_D AS INT) [GUARANTEE_PERIOD],
	 CASE WHEN CAST(T1.Shelf_Life_D AS INT)<35 THEN 'D(S):<35 Days'
	      WHEN CAST(T1.Shelf_Life_D AS INT) BETWEEN 35  AND 100 THEN 'D:35~100 Days'
		  WHEN CAST(T1.Shelf_Life_D AS INT)> 100 THEN 'D(L):>100 Days'
		  ELSE '' END [GUARANTEE_PERIOD_TYPE],
	 CASE WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) <CAST(1 AS DECIMAL)/3 THEN '<1/3'
	      WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) BETWEEN 
	       CAST(1 AS DECIMAL)/3  AND  CAST(1 AS DECIMAL)/2   THEN '1/3~1/2'
	      WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) BETWEEN 
	       CAST(1 AS DECIMAL)/2  AND  CAST(2 AS DECIMAL)/3   THEN '1/2~2/3'
	     WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) >CAST(2 AS DECIMAL)/3  AND 
		   CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) <1 THEN '>2/3'
		WHEN CAST(DATEDIFF(DAY,MANUFACTURING_DT,INVENTORY_DT)+1 AS DECIMAL)/CAST(T1.Shelf_Life_D AS INT) >=1
		     THEN 'Expired'
			 ELSE '' END [FRESH_TYPE],
	T.[Storaging_DT],
	T.Is_Damaged,
	T.Is_Expired,
	(CASE WHEN DATEDIFF(DAY,T.Storaging_DT,T.Inventory_DT)<5 THEN '<5 Days' 
	     WHEN DATEDIFF(DAY,T.Storaging_DT,T.Inventory_DT)<=15 THEN '5~15 Days'
		 WHEN DATEDIFF(DAY,T.Storaging_DT,T.Inventory_DT)<=30 THEN '16~30 Days'
		 WHEN DATEDIFF(DAY,T.Storaging_DT,T.Inventory_DT)>30 THEN '>30 Days'
		 ELSE '' END) Storaging_Days,
	DATEADD(DAY,T1.Shelf_Life_D/3,MANUFACTURING_DT) AS Best_Sales_DT,
	DATEDIFF(DAY,CAST(T.Inventory_DT AS DATE),DATEADD(DAY,T1.Shelf_Life_D/3,MANUFACTURING_DT)) AS Best_Sales_Days,
	CASE WHEN (CAST(T.Inventory_DT AS DATE)=DATEADD(DAY,T1.Shelf_Life_D*2/3,MANUFACTURING_DT)) OR (CAST(T.Inventory_DT AS DATE)=CAST(T.Storaging_DT AS DATE) AND CAST(T.Storaging_DT AS DATE)>=DATEADD(DAY,T1.Shelf_Life_D*2/3,MANUFACTURING_DT)) THEN 1 ELSE 0 END AS Expired_Flag
	FROM [FOODUNION].[FU_EDW].[T_EDW_FCT_INVENTORY_ALL] T
	LEFT JOIN [dm].[Dim_Product] T1 ON T1.SKU_ID=T.SKU_ID
	LEFT JOIN FU_EDW.T_EDW_DIM_Warehouse wh ON T.Warehouse_ID = wh.Warehouse_ID
	WHERE T1.SKU_ID IS NOT NULL AND wh.[3PL_SNM]='MW'	
) inv
GROUP BY
 SKU_ID
,INVENTORY_DT
,MANUFACTURING_DT
,EXPIRING_DT
,WAREHOUSE_ID
,FRESH_DAY
,GUARANTEE_PERIOD
,GUARANTEE_PERIOD_TYPE
,FRESH_TYPE
,Storaging_DT
,Is_Damaged
,Is_Expired
,Storaging_Days
,Best_Sales_DT
,Best_Sales_Days
,Expired_Flag
-- outstock
SELECT 
		wh.Warehouse_ID
	   ,si.Datekey
	   ,si.Bill_Type
	   ,si.Bill_No
	   ,sie.SKU_ID
	   ,sie.LOT_Display AS Batch_CD
	   ,sie.Produce_Date AS [Manufacturing_DT]
	   ,sie.[Expiry_Date] AS [Expiring_DT]
	   ,Price_Unit_QTY AS [Order_QTY]
	   ,Price_Unit_QTY AS [Actual_QTY]
	   ,Price_Unit AS Unit_Dsc
	   ,sie.Base_Unit_QTY AS Base_Unit_QTY
	   ,sie.Base_Unit AS Base_Unit
	   ,Price_Unit_QTY*prod.Sale_Unit_Weight_KG/1000 AS [Weight]
	   ,sie.Update_Time AS [Update_Time]
	   INTO #Inventory_Outstock
FROM [dm].[Fct_ERP_Stock_OutStockEntry] sie
LEFT JOIN [dm].[Fct_ERP_Stock_OutStock] si ON sie.OutStock_ID = si.OutStock_ID
LEFT JOIN [FU_EDW].[T_EDW_DIM_Warehouse] wh ON sie.Stock_Name = wh.RDC_NM
LEFT JOIN dm.Dim_Product prod ON sie.SKU_ID = prod.SKU_ID
WHERE wh.Warehouse_ID IS NOT NULL
UNION ALL
SELECT 
		wh.Warehouse_ID
	   ,ti.Datekey
	   ,ti.Bill_Type
	   ,ti.Bill_No
	   ,tie.SKU_ID
	   ,tie.LOT_Display AS Batch_CD
	   ,tie.Produce_Date AS [Manufacturing_DT]
	   ,tie.[Exipry_Date] AS [Expiring_DT]
	   ,QTY AS [Order_QTY]
	   ,QTY AS [Actual_QTY]
	   ,Unit AS Unit_Dsc
	   ,tie.Base_Unit_QTY
	   ,tie.Base_Unit
	   ,QTY*prod.Sale_Unit_Weight_KG/1000 AS [Weight]
	   ,tie.Update_Time AS [Update_Time]
FROM [dm].[Fct_ERP_Stock_TransferOutEntry] tie
LEFT JOIN [dm].[Fct_ERP_Stock_TransferOut] ti ON tie.TransID = ti.TransID
LEFT JOIN [FU_EDW].[T_EDW_DIM_Warehouse] wh ON tie.Source_Stock = wh.RDC_NM
LEFT JOIN dm.Dim_Product prod ON tie.SKU_ID = prod.SKU_ID
WHERE wh.Warehouse_ID IS NOT NULL
UNION ALL
SELECT 
		wh.Warehouse_ID
	   ,mi.Datekey
	   ,mi.Bill_Type
	   ,mi.Bill_No
	   ,mie.SKU_ID
	   ,mie.LOT_Display AS Batch_CD
	   ,mie.Produce_Date AS [Manufacturing_DT]
	   ,mie.[Expiry_Date] AS [Expiring_DT]
	   ,CASE WHEN mie.Unit = sku.Sale_Unit THEN QTY ELSE QTY*cr.Convert_Rate END AS [Order_QTY]
	   ,CASE WHEN mie.Unit = sku.Sale_Unit THEN QTY ELSE QTY*cr.Convert_Rate END  AS [Actual_QTY]
	   ,sku.Sale_Unit AS Unit_Dsc
	   ,QTY AS Base_Unit_QTY
	   ,Unit AS Base_Unit
	   ,CASE WHEN mie.Unit = sku.Sale_Unit THEN QTY ELSE QTY*cr.Convert_Rate END*prod.Sale_Unit_Weight_KG/1000 AS [Weight]
	   ,mie.Update_Time AS [Update_Time]
FROM [dm].[Fct_ERP_Stock_MisdStockEntry] mie
LEFT JOIN [dm].[Fct_ERP_Stock_MisdStock] mi ON mie.MisdStock_ID = mi.MisdStock_ID
LEFT JOIN [FU_EDW].[T_EDW_DIM_Warehouse] wh ON mie.Stock_Name = wh.RDC_NM
LEFT JOIN dm.Dim_Product prod ON mie.SKU_ID = prod.SKU_ID
LEFT JOIN ods.[ods].[ERP_SKU_List] sku ON mie.SKU_ID = sku.SKU_ID
LEFT JOIN [dm].[Dim_ERP_Unit_ConvertRate] cr ON mie.Unit = cr.From_Unit AND sku.Sale_Unit = cr.To_Unit
WHERE wh.Warehouse_ID IS NOT NULL

--��ȡ��ȥ30��ƽ��ÿ�������
SELECT inv.INVENTORY_DT
      ,inv.Warehouse_ID
	  ,inv.SKU_ID
	  ,SUM(inv.INVENTORY_QTY) AS INVENTORY_QTY
	  ,SUM(iot.Actual_QTY)/30 AS Actual_QTY
	  INTO #OutstockMA30
FROM (
		SELECT INVENTORY_DT
			  ,WAREHOUSE_ID
			  ,SKU_ID
			  ,SUM(CAST(INVENTORY_QTY AS FLOAT)) AS INVENTORY_QTY
		FROM #Inventory 
		GROUP BY INVENTORY_DT
			    ,WAREHOUSE_ID
			    ,SKU_ID
) inv
LEFT JOIN (
		SELECT Datekey AS Outstock_DT
			  ,Warehouse_ID
			  ,SKU_ID
			  ,SUM(CAST(Actual_QTY AS DECIMAL)) AS Actual_QTY
		FROM #Inventory_OutStock T
		GROUP BY Datekey
			    ,Warehouse_ID
			    ,SKU_ID
) iot ON inv.Warehouse_ID = iot.Warehouse_ID AND inv.SKU_ID = iot.SKU_ID AND inv.INVENTORY_DT>=iot.Outstock_DT AND CAST(inv.INVENTORY_DT AS DATE)<DATEADD(DAY,30,CAST(iot.Outstock_DT AS VARCHAR))
GROUP BY inv.INVENTORY_DT
        ,inv.Warehouse_ID
	    ,inv.SKU_ID

--------------------------------��ȡfresh type <1/3�Ŀ��
IF OBJECT_ID(N'tempdb..#Inventory_Forecast') IS NOT NULL
BEGIN
DROP TABLE #Inventory_Forecast
END
SELECT inv.INVENTORY_DT
	  ,inv.WAREHOUSE_ID
	  ,inv.Manufacturing_DT
	  ,inv.SKU_ID
	  ,SUM(CAST(inv.INVENTORY_QTY AS FLOAT)) AS INVENTORY_QTY
	  ,Best_Sales_DT
	  ,DENSE_RANK() OVER(ORDER BY inv.INVENTORY_DT) DT_RN
	  ,DENSE_RANK() OVER(PARTITION BY inv.INVENTORY_DT ORDER BY inv.WAREHOUSE_ID) WH_RN
	  ,DENSE_RANK() OVER(PARTITION BY inv.INVENTORY_DT,inv.WAREHOUSE_ID ORDER BY inv.SKU_ID) SKU_RN
	  ,ROW_NUMBER() OVER(PARTITION BY inv.INVENTORY_DT,inv.WAREHOUSE_ID,inv.SKU_ID ORDER BY inv.Best_Sales_DT) Best_Sales_RN
	  ,om.Actual_QTY AS OutStock_QTY
	  ,SUM(CAST(inv.INVENTORY_QTY AS FLOAT))/om.Actual_QTY AS SellOutDays
	  ,CAST(DATEDIFF(DAY,CAST(inv.INVENTORY_DT AS DATE),Best_Sales_DT) AS DECIMAL) AS Expired_DAYS
	  INTO #Inventory_Forecast
FROM 
(
	SELECT INVENTORY_DT
	      ,WAREHOUSE_ID
	      ,SKU_ID
		  ,Manufacturing_DT
		  ,Best_Sales_DT
		  ,FRESH_TYPE
		  ,SUM(Inventory_QTY) AS INVENTORY_QTY
		  FROM #Inventory
		  GROUP BY INVENTORY_DT
	      ,WAREHOUSE_ID
	      ,SKU_ID
		  ,Manufacturing_DT
		  ,Best_Sales_DT
		  ,FRESH_TYPE
)inv
LEFT JOIN #OutstockMA30 om ON inv.INVENTORY_DT = om.INVENTORY_DT AND inv.Warehouse_ID = om.Warehouse_ID AND inv.SKU_ID = om.SKU_ID
WHERE FRESH_TYPE='<1/3'-- AND om.Actual_QTY>0
GROUP BY inv.INVENTORY_DT
	    ,inv.WAREHOUSE_ID
	    ,inv.SKU_ID
		,inv.Manufacturing_DT
		,inv.Best_Sales_DT
		,om.Actual_QTY


--�����
IF OBJECT_ID(N'tempdb..#Inventory_Result') IS NOT NULL
BEGIN
DROP TABLE #Inventory_Result
END
CREATE TABLE #Inventory_Result(
INVENTORY_DT			VARCHAR(100)
,WAREHOUSE_ID			INT
,Manufacturing_DT		DATE
,SKU_ID					NVARCHAR(200)
,INVENTORY_QTY			DECIMAL(20,10)
,Best_Sales_DT				DATE
,DT_RN					BIGINT
,WH_RN					BIGINT
,SKU_RN					BIGINT
,Best_Sales_RN				BIGINT
,OutStock_QTY			DECIMAL(20,10)
,SellOutDays			DECIMAL(20,10)
,Expired_DAYS			DECIMAL
,EXPIRED_QTY			DECIMAL(20,10)
,EXPIRED_DT				DATE
,Actual_Expired_Days	DECIMAL(20,10)
)

DECLARE @MAX_DT_RN	  AS INT
DECLARE @MAX_WH_RN	  AS INT
DECLARE @MAX_SKU_RN	  AS INT
DECLARE @MAX_Best_Sales_RN AS INT
DECLARE @MAX_DAYS AS INT

DECLARE @DT_RN	  AS INT
DECLARE @WH_RN	  AS INT
DECLARE @SKU_RN	  AS INT
DECLARE @Best_Sales_RN AS INT

SET @DT_RN = 1
SET @WH_RN = 1
SET @SKU_RN = 1

DECLARE @OutStock_QTY FLOAT


--��ȡ���ʱ����
SELECT @MAX_DT_RN = MAX(DT_RN) FROM #Inventory_Forecast
WHILE @DT_RN<=@MAX_DT_RN
BEGIN
	
		--��ȡ���ֿ���
	SELECT @MAX_WH_RN = MAX(WH_RN) FROM #Inventory_Forecast WHERE DT_RN = @DT_RN
	SET @WH_RN=1
	WHILE @WH_RN<=@MAX_WH_RN
	BEGIN
			--��ȡ���SKU��
		SELECT @MAX_SKU_RN = MAX(SKU_RN) FROM #Inventory_Forecast WHERE DT_RN = @DT_RN AND WH_RN = @WH_RN
		SET @SKU_RN=1
		WHILE @SKU_RN<=@MAX_SKU_RN
		BEGIN

			--�Ե�ǰSKU��״̬����ʱ��
			IF OBJECT_ID(N'tempdb..#Inventory_SKU') IS NOT NULL
			BEGIN
			DROP TABLE #Inventory_SKU
			END
			SELECT *,INVENTORY_QTY AS EXPIRED_QTY,CAST(INVENTORY_DT AS DATE) AS  EXPIRED_DT,SellOutDays AS Actual_Expired_Days
			INTO #Inventory_SKU
			FROM #Inventory_Forecast
			WHERE DT_RN = @DT_RN AND WH_RN = @WH_RN AND SKU_RN = @SKU_RN

			--ѭ������Ʒ����Ч�ڵ���һ��

			DECLARE @i INT
			SET @i = 1

			DECLARE @Mindays DECIMAL(18,6)
			SET @Mindays=0
			DECLARE @freshdays DECIMAL(18,6)
			SET @freshdays = 0
			DECLARE @freshdays2 DECIMAL(18,6)
			SET @freshdays2 = 0
			--��ȡ���Best_Sales_RN
			SELECT @MAX_Best_Sales_RN = MAX(Best_Sales_RN) FROM #Inventory_SKU 
			WHILE @i<=@MAX_Best_Sales_RN
			BEGIN

				SELECT @freshdays2 = CASE WHEN Expired_DAYS-@Mindays>SellOutDays THEN SellOutDays else Expired_DAYS-@Mindays END  FROM #Inventory_SKU WHERE Best_Sales_RN = @i
				UPDATE #Inventory_SKU 
				SET Actual_Expired_Days=CASE WHEN Expired_DAYS-@Mindays>SellOutDays THEN SellOutDays else Expired_DAYS-@Mindays END
				   ,EXPIRED_QTY = INVENTORY_QTY-(CASE WHEN Expired_DAYS-@Mindays>SellOutDays THEN SellOutDays else Expired_DAYS-@Mindays END)*OutStock_QTY
				   ,EXPIRED_DT = DATEADD(DAY,(CASE WHEN Expired_DAYS-@Mindays>SellOutDays THEN SellOutDays+@Mindays else Expired_DAYS END),CAST(INVENTORY_DT AS DATE))
				WHERE Best_Sales_RN=@i
				SET @freshdays = @freshdays2
				SET @i+=1
				SET @Mindays=@Mindays+@freshdays
			END
			INSERT INTO #Inventory_Result
			SELECT * FROM #Inventory_SKU 
			SET @SKU_RN+=1
		END
		SET @WH_RN+=1
	END
	SET @DT_RN+=1
END




SELECT
 [SKU_ID]
,[Inventory_DT]
,[Manufacturing_DT]
,[Expiring_DT]
,Inventory_QTY
,[Weight_NBR]
,[Warehouse_Id]
,[Fresh_Day]
,[Guarantee_period]
,[Guarantee_period_type]
,[Fresh_Type]
,[Storaging_DT]
,[Is_Damaged]
,[Is_Expired]
,[Storaging_Days]
,[Best_Sales_DT]
,[Best_Sales_Days]
,[Sell_out_QTY]
,[Estimated_Sales_DT]
,[Estimated_Sales_Days]
,[Estimated_Sales_Qty]
,[Estimated_Expired_Qty]
,CASE WHEN ROW_NUMBER() OVER(PARTITION BY [SKU_ID],[Inventory_DT],[Manufacturing_DT],[Warehouse_Id] ORDER BY [Storaging_Days]) = 1 THEN 1 ELSE 0 END AS Storaging_Flag
,CASE WHEN ROW_NUMBER() OVER(PARTITION BY [SKU_ID],[Inventory_DT],[Warehouse_Id] ORDER BY [Manufacturing_DT] DESC) = 1 THEN 1 ELSE 0 END AS Manufacturing_Flag
,Expired_Flag
,[Update_DTM]
FROM(
	SELECT
	 inv.[SKU_ID]
	,inv.[Inventory_DT]
	,inv.[Manufacturing_DT]
	,inv.[Expiring_DT]
	,inv.Inventory_QTY
	,inv.[Weight_NBR]
	,inv.[Warehouse_Id]
	,inv.[Fresh_Day]
	,inv.[Guarantee_period]
	,inv.[Guarantee_period_type]
	,inv.[Fresh_Type]
	,inv.[Storaging_DT]
	,inv.[Is_Damaged]
	,inv.[Is_Expired]
	,inv.[Storaging_Days]
	,inv.[Best_Sales_DT]
	,inv.[Best_Sales_Days]
	,om.Actual_QTY AS [Sell_out_QTY]
	,NULL AS [Estimated_Sales_DT]
	,NULL AS [Estimated_Sales_Days]
	,NULL AS [Estimated_Sales_Qty]
	,NULL AS [Estimated_Expired_Qty]
	,Expired_Flag
	,[Update_DTM]
	FROM #Inventory inv
	LEFT JOIN #OutstockMA30 om ON inv.INVENTORY_DT = om.INVENTORY_DT AND inv.Warehouse_ID = om.Warehouse_ID AND inv.SKU_ID = om.SKU_ID
	WHERE ISNULL([FRESH_TYPE],'')<>'<1/3'
	UNION ALL
	
	SELECT
	 inv.[SKU_ID]
	,inv.[Inventory_DT]
	,inv.[Manufacturing_DT]
	,inv.[Expiring_DT]
	,inv.Inventory_QTY
	,inv.[Weight_NBR]
	,inv.[Warehouse_Id]
	,inv.[Fresh_Day]
	,inv.[Guarantee_period]
	,inv.[Guarantee_period_type]
	,inv.[Fresh_Type]
	,inv.[Storaging_DT]
	,inv.[Is_Damaged]
	,inv.[Is_Expired]
	,inv.[Storaging_Days]
	,inv.[Best_Sales_DT]
	,inv.[Best_Sales_Days]
	,om.Actual_QTY AS [Sell_out_QTY]
	,result.EXPIRED_DT AS [Estimated_Sales_DT]
	,result.Actual_Expired_Days AS [Estimated_Sales_Days]
	,result.Inventory_QTY-result.EXPIRED_QTY AS [Estimated_Sales_Qty]
	,result.EXPIRED_QTY AS [Estimated_Expired_Qty]
	,Expired_Flag
	,[Update_DTM]
	FROM #Inventory inv
	LEFT JOIN #Inventory_Result result ON inv.SKU_ID = result.SKU_ID AND inv.INVENTORY_DT = result.INVENTORY_DT AND inv.Manufacturing_DT = result.Manufacturing_DT AND inv.Warehouse_ID = result.WAREHOUSE_ID
	LEFT JOIN #OutstockMA30 om ON inv.INVENTORY_DT = om.INVENTORY_DT AND inv.Warehouse_ID = om.Warehouse_ID AND inv.SKU_ID = om.SKU_ID
	WHERE ISNULL([FRESH_TYPE],'')='<1/3'
) AS BASE

END
GO
