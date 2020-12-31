USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dm].[SP_Fct_YH_Store_Score_Card_20200308]
	-- Add the parameters for the stored procedure here
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY

TRUNCATE TABLE [dm].[Fct_YH_Store_Score_Card]


SELECT sl.Store_ID
      ,sl.YH_Store_CD
	  ,sl.Calendar_DT+'01' as Calendar_DT
	  ,CASE WHEN sl.[Sales_AMT] = 0 THEN NULL ELSE sl.[Sales_AMT] END AS [Sales_AMT]
      ,CASE WHEN sl.[Sales_QTY] = 0 THEN NULL ELSE sl.[Sales_QTY] END AS [Sales_QTY]
      ,sl.[DiscountSales_AMT]
      ,sl.[DiscountSales_QTY]
	  ,cp.[Sales_AMT]					AS	[Competitive_Sales_AMT]
	  ,GETDATE() as [Update_DTM]
 	  INTO #BaseData
	  FROM 
	  (		SELECT st.Store_ID
				,st.Account_Store_Code AS YH_Store_CD
				,dt.Year_Month AS Calendar_DT
				,SUM(CAST([Sales_AMT] AS FLOAT)				)	  AS [Sales_AMT]				
				,SUM(CAST([Sales_QTY] AS FLOAT)				)	  AS [Sales_QTY]				
				,SUM([DiscountSales_AMT]		)	  AS [DiscountSales_AMT]		
				,SUM([DiscountSales_QTY]		)	  AS [DiscountSales_QTY]	
				FROM [dm].Dim_Store st
			CROSS JOIN (
				SELECT DISTINCT TRIM(CAST(Year_Month AS CHAR)) AS Year_Month FROM FU_EDW.Dim_Calendar WHERE DATE_NM<GETDATE()
			) AS dt
			LEFT JOIN [dm].[Fct_YH_Sales_Inventory] Sal ON Sal.Store_ID = st.Store_ID AND dt.Year_Month = LEFT(Sal.Calendar_DT,6)
			WHERE st.Target_Store_FL = 1  AND st.Channel_Account = 'YH'
			 GROUP BY st.Store_ID,st.Account_Store_Code,Year_Month
		) sl 
	  LEFT JOIN (
	  
		  SELECT
		     LEFT(Calendar_DT,6) AS Calendar_DT
			,YH_Store_CD
			,SUM(CAST([Sales_AMT]				AS FLOAT)  )  AS [Sales_AMT]					
		  FROM dm.[Fct_YH_Sales_Competitive_Product] WHERE YH_Store_CD IS NOT NULL AND YH_Store_CD <> ''
		  GROUP BY LEFT(Calendar_DT,6)
				  ,YH_Store_CD

		 UNION ALL
		 SELECT
		    LEFT(calday,6)
		   ,shop_id
		   ,SUM(CAST(sales_amt AS FLOAT)/CASE WHEN CAST(sales_ratio AS FLOAT)<> 0 THEN CAST(sales_ratio AS FLOAT) END)  AS [Sales_AMT]
	     FROM ods.[ods].[EDI_YH_SalesRatio]
		 GROUP BY 
		    LEFT(calday,6)
		   ,shop_id
	  ) CP ON sl.YH_Store_CD = cp.YH_Store_CD and sl.Calendar_DT = LEFT(cp.Calendar_DT,6)




INSERT INTO [dm].[Fct_YH_Store_Score_Card](
	   [Calendar_DT]
      ,[Store_ID]
      ,[YH_Store_CD]
      ,[Sales_AMT]
      ,[Sales_QTY]
      ,[Sales_AMT_LM]
      ,[Sales_QTY_LM]
      ,[Ranking_AMT_NBR]
      ,[GR_MOM_AMT_PC]
      ,[GR_MOM_Qty_PC]
      ,[Ranking_GR_NBR]
      ,[YH_Dairy_AMT]
      ,[BM_Share_PC]
      ,[Ranking_Share_NBR]
      ,[SALES_AMT_Score]
      ,[GR_Score]
      ,[Ranking_Share_Score]
      ,[Total_Score]
	  ,[Total_Ranking]
      ,[Create_Time]
	  ,[Create_By]
	  ,[Update_Time]
	  ,[Update_By]
)
SELECT [Calendar_DT]
      ,[Store_ID]
      ,[YH_Store_CD]
      ,[Sales_AMT]
      ,[Sales_QTY]
      ,[Sales_AMT_LM]
      ,[Sales_QTY_LM]
      ,[Ranking_AMT_NBR]
      ,[GR_MOM_AMT_PC]
      ,[GR_MOM_Qty_PC]
      ,[Ranking_GR_NBR]
      ,[YH_Dairy_AMT]
      ,[BM_Share_PC]
      ,[Ranking_Share_NBR]
      ,[SALES_AMT_Score]
      ,[GR_Score]
      ,[Ranking_Share_Score]
      ,[SALES_AMT_Score]*0.6+[GR_Score]*0.15+[Ranking_Share_Score]*0.25 AS [Total_Score]
	  ,RANK() OVER(PARTITION BY [Calendar_DT],Account_Store_Type ORDER BY [SALES_AMT_Score]*0.6+[GR_Score]*0.15+[Ranking_Share_Score]*0.25 DESC) AS [Total_Ranking]
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
	   FROM
		   (
		   SELECT RDCM.Calendar_DT
		   	     ,RDCM.Store_ID
		   	     ,RDCM.YH_Store_CD
				 ,ST.Account_Store_Type
		   	     ,RDCM.Sales_AMT
		   	     ,RDCM.Sales_QTY
		   	     ,RDLM.Sales_AMT AS Sales_AMT_LM
		   	     ,RDLM.Sales_QTY AS Sales_QTY_LM
		   	     ,RANK() OVER(PARTITION BY RDCM.Calendar_DT,ST.Account_Store_Type ORDER BY RDCM.Sales_AMT DESC) AS [Ranking_AMT_NBR]
		   	     ,(RDCM.Sales_AMT-RDLM.Sales_AMT)/RDLM.Sales_AMT AS [GR_MOM_AMT_PC]
		   	     ,(RDCM.Sales_Qty-RDLM.Sales_Qty)/RDLM.Sales_Qty AS [GR_MOM_Qty_PC]
		   	     ,RANK() OVER(PARTITION BY RDCM.Calendar_DT,ST.Account_Store_Type ORDER BY (RDCM.Sales_AMT-RDLM.Sales_AMT)/RDLM.Sales_AMT DESC) AS [Ranking_GR_NBR]
		   	     ,RDCM.[Competitive_Sales_AMT] AS [YH_Dairy_AMT]
		   	     ,RDCM.Sales_AMT/RDCM.[Competitive_Sales_AMT] AS [BM_Share_PC]
		   	     ,RANK() OVER(PARTITION BY RDCM.Calendar_DT,ST.Account_Store_Type ORDER BY RDCM.Sales_AMT/RDCM.[Competitive_Sales_AMT] DESC) AS [Ranking_Share_NBR]
				  ,sc.store_count
				 ,CASE WHEN ISNULL(RDCM.Sales_AMT,0) = 0 THEN 0 ELSE CAST((sc.store_count-RANK() OVER(PARTITION BY RDCM.Calendar_DT,ST.Account_Store_Type ORDER BY RDCM.Sales_AMT DESC)+1) AS FLOAT)/sc.store_count*100.0 END AS [SALES_AMT_Score]					--如果当月销量为0那么就是0分
				 ,CASE WHEN ISNULL(RDCM.Sales_AMT,0) = 0 THEN 0 ELSE CAST((sc.store_count-RANK() OVER(PARTITION BY RDCM.Calendar_DT,ST.Account_Store_Type ORDER BY (RDCM.Sales_AMT-RDLM.Sales_AMT)/RDLM.Sales_AMT DESC)+1) AS FLOAT)/sc.store_count*100.0 END AS [GR_Score]
				 ,CASE WHEN ISNULL(RDCM.Sales_AMT,0) = 0 THEN 0 ELSE CAST((sc.store_count-RANK() OVER(PARTITION BY RDCM.Calendar_DT,ST.Account_Store_Type ORDER BY RDCM.Sales_AMT/RDCM.[Competitive_Sales_AMT] DESC)+1) AS FLOAT)/sc.store_count*100.0 END AS [Ranking_Share_Score]
		   	     FROM #BaseData RDCM
		   	     LEFT JOIN #BaseData RDLM ON RDCM.Store_ID = RDLM.Store_ID AND RDCM.Calendar_DT = DATEADD(MONTH,1,RDLM.Calendar_DT)												--因为只看当月活跃门店的排名，如果当月不活跃，上个月的数据也没有意义了
		   	     LEFT JOIN DM.Dim_Store ST ON RDCM.Store_ID = ST.Store_ID AND st.Channel_Account = 'YH'
				 LEFT JOIN (SELECT Calendar_DT,COUNT(DISTINCT Store_ID) AS store_count FROM #BaseData GROUP BY Calendar_DT) AS  sc ON RDCM.Calendar_DT = sc.Calendar_DT
		   ) PER

END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
