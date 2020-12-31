USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC  [dm].[SP_Fct_YH_Store_Flag_Daily_Update]
@Total INT = 0
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
	@DatabaseName varchar(100) = DB_NAME(),
	@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY


	IF @Total = 1 
	BEGIN

	DELETE dm.Fct_YH_Store_Flag_Daily WHERE Date_ID>='20190707'
	END
	ELSE
	BEGIN
	------------------------------------------------以过去30天的数据做增量
	DELETE dm.Fct_YH_Store_Flag_Daily WHERE Date_ID>CONVERT(VARCHAR(8),DATEADD(DAY,-30,GETDATE()),112)
	END
	------------------------------------------------获取现在表中最大的时间
	DECLARE @MAX_CAL VARCHAR(8) = (SELECT ISNULL(MAX(Date_ID),'19900101') FROM [dm].Fct_YH_Store_Flag_Daily)


	-----------------------------YH sales inventory
	DROP TABLE IF EXISTS #YH_Sales_Inventory
	SELECT Calendar_DT
		  ,Store_ID
		  ,SUM(Sales_AMT) AS Sales_AMT
		  ,SUM(Sales_QTY) AS Sales_QTY
		  ,SUM(Sales_QTY*prod.Sale_Unit_Weight_KG) AS Sales_VOL
		  ,SUM(Inventory_LD_AMT) AS Inventory_AMT
		  ,SUM(Inventory_LD_QTY) AS  Inventory_QTY
		  ,SUM(Inventory_LD_QTY*prod.Sale_Unit_Weight_KG) AS  Inventory_VOL
		  ,COUNT(DISTINCT CASE WHEN inv.Inventory_LD_QTY>0 THEN inv.SKU_ID END) AS SKU_Count
		  ,CASE WHEN SUM(Sales_AMT)>0 THEN 1 ELSE 0 END AS IsActive
		  INTO #YH_Sales_Inventory
	FROM dm.[Fct_YH_Sales_Inventory] inv
	LEFT JOIN [dm].[Dim_Product] prod ON inv.SKU_ID = prod.SKU_ID
	GROUP BY 
		  Calendar_DT
		 ,Store_ID

	--------------------创建#YH_Sales_Inventory索引
	CREATE CLUSTERED INDEX [#ix_c_YH_Sales_Inv_Cal] ON #YH_Sales_Inventory
	(
		[Calendar_DT] DESC
	)

	DROP TABLE IF EXISTS #YH_Sales_By_Region
	SELECT dt.[Date]
		  ,st.Account_Area_CN 
		  ,SUM(sal.Sales_AMT)/COUNT(DISTINCT st.Store_ID) PSD_By_Region
		  INTO #YH_Sales_By_Region
	FROM [dm].[Dim_Calendar] dt
	CROSS JOIN [dm].[Dim_Store] st
	LEFT JOIN #YH_Sales_Inventory AS sal ON dt.Datekey = sal.Calendar_DT AND st.Store_ID = sal.Store_ID
	WHERE dt.Datekey>='20180801' AND dt.[Date]<GETDATE() AND  Status = N'营运'  AND st.Channel_Account = 'YH'
	GROUP BY dt.[Date]
		  ,st.Account_Area_CN 


	---daily sales by day
	DROP TABLE IF EXISTS #YH_DailySales
	SELECT ds.Date AS Calendar_DT
		  ,st.Store_ID
		  ,prod.SKU_ID
		  ,SUM(InStock_QTY) AS InStock_QTY
		  ,SUM(InStock_Amount) AS InStock_Amount
		  INTO #YH_DailySales
	FROM ods.ods.[File_YH_DailySales] ds
	LEFT JOIN dm.Dim_Store st ON ds.Store_Code = st.Account_Store_Code AND st.Channel_Account = 'YH'
	LEFT JOIN dm.Dim_Product prod ON ds.Bar_Code=prod.Bar_Code AND CASE WHEN ds.SKU_Name LIKE '%小猪%' THEN 'PEPPA' WHEN ds.SKU_Name LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'PEPPA' END
	WHERE InStock_QTY>0 OR InStock_Amount>0
	GROUP BY ds.Date
			,st.Store_ID
			,prod.SKU_ID



	INSERT INTO  dm.Fct_YH_Store_Flag_Daily 
	(
	 Date_ID
	,Store_ID
	,[Sales_AMT]
	,[Sales_QTY]
	,[Sales_Vol]
	,[Inventory_AMT]
	,[Inventory_QTY]
	,[Inventory_Vol]
	,[Inventory_SKU_Count]
	,[Inventory_MA14_AMT]
	,[Inventory_MA14_QTY]
	,[Sales_MA7_AMT]
	,[Sales_MA7_14_AMT]
	,[Sales_MA14_AMT]
	,[Sales_MA14_QTY]
	,[Sales_MA14_VOL]
	,[Distribution]
	,[Online_Distribution]
	,[SKU_Distribution]
	,Last_Order_DT
	,Order_Qty_L7
	,Order_Amt_L7
	,Order_SKUCount_L7
	,[This_WK_Order_AMT]
	,[Last_Order_AMT]
	,[Create_Time]
	,[Create_By]
	,[Update_Time]
	,[Update_By]
	)
	SELECT dt.Datekey
		  ,st.Store_ID 
		  ,SUM(si.[Sales_AMT])		AS	[Sales_AMT]
		  ,SUM([Sales_QTY])		AS	[Sales_QTY]
		  ,SUM([Sales_Vol])		AS	[Sales_Vol]
		  ,SUM([Inventory_AMT])	AS	[Inventory_AMT]
		  ,SUM([Inventory_QTY])	AS	[Inventory_QTY]
		  ,SUM([Inventory_Vol])	AS	[Inventory_Vol]
		  ,SUM(si.SKU_Count) AS [Inventory_SKU_Count]
		  ,SUM(dist.[Inventory_MA14_AMT]) AS [Inventory_MA14_AMT]
		  ,SUM(dist.[Inventory_MA14_QTY]) AS [Inventory_MA14_QTY]
		  ,SUM(salm7d.Sales_MA7_AMT) AS Sales_MA7_AMT
		  ,SUM(salm7_14d.Sales_MA7_14_AMT) AS Sales_MA7_14_AMT
		  ,SUM(dist.[Sales_MA14_AMT]) AS [Sales_MA14_AMT]
		  ,SUM(dist.[Sales_MA14_QTY]) AS [Sales_MA14_QTY]
		  ,SUM(dist.[Sales_MA14_VOL]) AS [Sales_MA14_VOL]
		  ,MAX(dist.[Distribution]) AS [Distribution]
		  ,MAX(ondist.Online_Distribution) AS [Online_Distribution]
		  ,MAX(ssd.[SKU_Distribution]) AS [SKU_Distribution]
		  ,MAX(InStockOrder.Last_Order_DT)	AS Last_Order_DT
		  ,SUM(InStockOrder.Order_Qty_L7)	AS Order_Qty_L7
		  ,SUM(InStockOrder.Order_Amt_L7)	AS Order_Amt_L7
		  ,SUM(InStockOrder.Order_SKUCount_L7)	AS Order_SKUCount_L7
		  ,SUM(InStockOrderWeek.This_WK_Order_AMT) AS [This_WK_Order_AMT]
		  ,SUM(InStockOrder.Last_Order_AMT) AS Last_Order_AMT
		  ,GETDATE() AS [Create_Time]
		  ,OBJECT_NAME(@@PROCID) AS [Create_By]
		  ,GETDATE() AS [Update_Time]
		  ,OBJECT_NAME(@@PROCID) AS [Update_By]
	FROM [dm].[Dim_Calendar] dt
	CROSS JOIN [dm].[Dim_Store] st
	LEFT JOIN #YH_Sales_Inventory AS si ON dt.Datekey = si.Calendar_DT  AND st.Store_ID = si.Store_ID
	LEFT JOIN 
	(		SELECT dt.Datekey
				  ,st.Store_ID 
				  ,CASE WHEN st.Account_Store_Type='永辉超市' AND MAX(ISNULL([Inventory_QTY],0))<= 0 THEN '库存为0门店'
						WHEN st.Account_Store_Type='永辉超市' AND MAX([Inventory_QTY])>0 and  MAX([Inventory_QTY]) <120  THEN '库存不足'
						WHEN st.Account_Store_Type='永辉超市' AND MAX([Inventory_QTY])>=120 and  MAX([Sales_QTY]) <=5 THEN '库存滞销'
						WHEN st.Account_Store_Type='永辉超市' THEN '正常门店' 
					
						WHEN st.Account_Store_Type='永辉生活' AND MAX(ISNULL([Inventory_QTY],0))<=0 THEN '库存为0门店'
						WHEN st.Account_Store_Type='永辉生活' AND MAX([Inventory_QTY])>0 and  MAX([Inventory_QTY]) <20  THEN '库存不足'
						WHEN st.Account_Store_Type='永辉生活' AND MAX([Inventory_QTY])>=20 and  MAX([Sales_QTY]) <=1 THEN '库存滞销'
						WHEN st.Account_Store_Type='永辉生活' THEN '正常门店' 
					
 						WHEN st.Account_Store_Type='超级物种' AND MAX(ISNULL([Inventory_QTY],0))<=0 THEN '库存为0门店'
						WHEN st.Account_Store_Type='超级物种' AND MAX([Inventory_QTY])>0 and  MAX([Inventory_QTY]) <120  THEN '库存不足'
						WHEN st.Account_Store_Type='超级物种' AND MAX([Inventory_QTY])>=120 and  MAX([Sales_QTY]) <=5 THEN '库存滞销'
						WHEN st.Account_Store_Type='超级物种' THEN '正常门店' 
					
						WHEN st.Account_Store_Type='Mini' AND MAX(ISNULL([Inventory_QTY],0))<=0 THEN '库存为0门店'
						WHEN st.Account_Store_Type='Mini' AND MAX([Inventory_QTY])>0 and  MAX([Inventory_QTY]) <20  THEN '库存不足'
						WHEN st.Account_Store_Type='Mini' AND MAX([Inventory_QTY])>=20 and  MAX([Sales_QTY]) <=1 THEN '库存滞销'
						WHEN st.Account_Store_Type='Mini' THEN '正常门店' 

						WHEN  MAX(ISNULL([Inventory_QTY],0))<= 0 THEN '库存为0门店'
						WHEN  MAX([Inventory_QTY])>0 and  MAX([Inventory_QTY]) <20  THEN '库存不足'
						WHEN  MAX([Inventory_QTY])>=20 and  MAX([Sales_QTY]) <=3 THEN '库存滞销'
						ELSE '正常门店' 


						END AS [SKU_Distribution]
			FROM [dm].[Dim_Calendar] dt
			CROSS JOIN [dm].[Dim_Store] st
			LEFT JOIN #YH_Sales_Inventory AS si ON dt.Datekey >= si.Calendar_DT 
			AND DATEDIFF(DAY,CAST(si.Calendar_DT AS VARCHAR),dt.[Date])<3 AND st.Store_ID = si.Store_ID
			WHERE dt.Datekey>@MAX_CAL AND dt.[Date]<GETDATE() AND  Status = N'营运' AND st.Channel_Account = 'YH' --AND stf.FIRST_SALES_DATE IS NOT NULL -- AND dt.Datekey NOT IN (SELECT DISTINCT sfd.Datekey FROM FU_DM.T_DM_FCT_YH_Store_Flag_Daily sfd)-- AND Target_Store_FL=1 
			GROUP BY dt.Datekey
					,dt.[Date]
					,st.Account_Store_Type
					,st.Store_ID 
	) AS ssd ON dt.Datekey = ssd.Datekey  AND st.Store_ID = ssd.Store_ID
	LEFT JOIN 
	(
			SELECT dt.Datekey
				  ,st.Store_ID 
				  ,CASE WHEN st.Account_Store_Type='永辉超市' AND MAX(SKU_Count)>=10 AND MAX(si.Inventory_QTY)>=276 THEN 'Standard PoS'
						WHEN st.Account_Store_Type='永辉超市' AND MAX(SKU_Count)>0 THEN 'NON-Standard PoS'
						WHEN st.Account_Store_Type='永辉超市' THEN 'TBD PoS' 
						WHEN st.Account_Store_Type='永辉生活' AND MAX(SKU_Count)>=4 AND MAX(si.Inventory_QTY)>=40 THEN 'Standard PoS'
						WHEN st.Account_Store_Type='永辉生活' AND MAX(SKU_Count)>0 THEN 'NON-Standard PoS'
						WHEN st.Account_Store_Type='永辉生活' THEN 'TBD PoS'  
						WHEN st.Account_Store_Type='超级物种' AND MAX(SKU_Count)>=4 AND MAX(si.Inventory_QTY)>=40 THEN 'Standard PoS'
						WHEN st.Account_Store_Type='超级物种' AND MAX(SKU_Count)>0 THEN 'NON-Standard PoS'
						WHEN st.Account_Store_Type='超级物种' THEN 'TBD PoS' 
						WHEN st.Account_Store_Type='Mini' AND MAX(SKU_Count)>=4 AND MAX(si.Inventory_QTY)>=40 THEN 'Standard PoS'
						WHEN st.Account_Store_Type='Mini' AND MAX(SKU_Count)>0 THEN 'NON-Standard PoS'
						WHEN st.Account_Store_Type='Mini' THEN 'TBD PoS'
						WHEN MAX(SKU_Count)>=10 THEN 'Standard PoS'
						WHEN MAX(SKU_Count)>0 THEN 'NON-Standard PoS'
						ELSE 'TBD PoS' 
						END AS [Distribution]
				  ,SUM(si.Inventory_AMT)/14.0 AS [Inventory_MA14_AMT]
				  ,SUM(si.Inventory_QTY)/14.0 AS [Inventory_MA14_QTY]
				  ,SUM(si.Sales_AMT)/14.0 AS [Sales_MA14_AMT]
				  ,SUM(si.Sales_QTY)/14.0 AS [Sales_MA14_QTY]
				  ,SUM(si.Sales_VOL)/14.0 AS [Sales_MA14_VOL]
			FROM [dm].[Dim_Calendar] dt
			CROSS JOIN [dm].[Dim_Store] st
			LEFT JOIN #YH_Sales_Inventory AS si ON dt.Datekey >= si.Calendar_DT AND DATEDIFF(DAY,CAST(si.Calendar_DT AS VARCHAR),dt.[Date])<14 AND st.Store_ID = si.Store_ID
			WHERE dt.Datekey>@MAX_CAL AND dt.[Date]<GETDATE() AND  Status = N'营运' AND st.Channel_Account = 'YH' --AND stf.FIRST_SALES_DATE IS NOT NULL -- AND dt.Datekey NOT IN (SELECT DISTINCT sfd.Datekey FROM FU_DM.T_DM_FCT_YH_Store_Flag_Daily sfd)-- AND Target_Store_FL=1 
			GROUP BY dt.Datekey
					,dt.[Date]
					,st.Account_Store_Type
					,st.Store_ID 
	) as dist ON st.Store_ID = dist.Store_ID AND dist.Datekey = dt.Datekey
	LEFT JOIN 
	(
			SELECT dt.Datekey
				  ,st.Store_ID 
				  ,CASE WHEN st.Account_Store_Type='永辉超市' AND MAX(SKU_Count)>=10 THEN 'Standard PoS'
						WHEN st.Account_Store_Type='永辉超市' AND MAX(SKU_Count)>0 THEN 'NON-Standard PoS'
						WHEN st.Account_Store_Type='永辉超市' THEN 'TBD PoS' 
						WHEN st.Account_Store_Type='永辉生活' AND MAX(SKU_Count)>=4 THEN 'Standard PoS'
						WHEN st.Account_Store_Type='永辉生活' AND MAX(SKU_Count)>0 THEN 'NON-Standard PoS'
						WHEN st.Account_Store_Type='永辉生活' THEN 'TBD PoS'  
						WHEN st.Account_Store_Type='超级物种' AND MAX(SKU_Count)>=4 THEN 'Standard PoS'
						WHEN st.Account_Store_Type='超级物种' AND MAX(SKU_Count)>0 THEN 'NON-Standard PoS'
						WHEN st.Account_Store_Type='超级物种' THEN 'TBD PoS' 
						WHEN st.Account_Store_Type='Mini' AND MAX(SKU_Count)>=4 THEN 'Standard PoS'
						WHEN st.Account_Store_Type='Mini' AND MAX(SKU_Count)>0 THEN 'NON-Standard PoS'
						WHEN st.Account_Store_Type='Mini' THEN 'TBD PoS'
						WHEN MAX(SKU_Count)>=10 THEN 'Standard PoS'
						WHEN MAX(SKU_Count)>0 THEN 'NON-Standard PoS'
						ELSE 'TBD PoS' 
						END AS [Online_Distribution]
			FROM [dm].[Dim_Calendar] dt
			CROSS JOIN [dm].[Dim_Store] st
			LEFT JOIN #YH_Sales_Inventory AS sal ON dt.Datekey >= sal.Calendar_DT AND DATEDIFF(DAY,CAST(sal.Calendar_DT AS VARCHAR),dt.[Date])<14 AND st.Store_ID = sal.Store_ID
			WHERE dt.Datekey>@MAX_CAL AND dt.[Date]<GETDATE() AND  Status = N'营运' AND st.Channel_Account = 'YH' --AND stf.FIRST_SALES_DATE IS NOT NULL -- AND dt.Datekey NOT IN (SELECT DISTINCT sfd.Datekey FROM FU_DM.T_DM_FCT_YH_Store_Flag_Daily sfd)-- AND Target_Store_FL=1 
			GROUP BY dt.Datekey
					,dt.[Date]
					,st.Account_Store_Type
					,st.Store_ID 
	) as ondist ON st.Store_ID = ondist.Store_ID AND ondist.Datekey = dt.Datekey
	LEFT JOIN 
	(
			SELECT dt.Datekey
				  ,st.Store_ID 
				  ,SUM(sal.Sales_AMT)/7.0 AS [Sales_MA7_AMT]
			FROM [dm].[Dim_Calendar] dt
			CROSS JOIN [dm].[Dim_Store] st
			LEFT JOIN #YH_Sales_Inventory AS sal ON dt.Datekey >= sal.Calendar_DT AND DATEDIFF(DAY,CAST(sal.Calendar_DT AS VARCHAR),dt.[Date])<7 AND st.Store_ID = sal.Store_ID
			WHERE dt.Datekey>@MAX_CAL AND dt.[Date]<GETDATE() AND  Status = N'营运' AND st.Channel_Account = 'YH' --AND stf.FIRST_SALES_DATE IS NOT NULL -- AND dt.Datekey NOT IN (SELECT DISTINCT sfd.Datekey FROM FU_DM.T_DM_FCT_YH_Store_Flag_Daily sfd)-- AND Target_Store_FL=1 
			GROUP BY dt.Datekey
					,dt.[Date]
					,st.Account_Store_Type
					,st.Store_ID 
	) as salm7d ON st.Store_ID = salm7d.Store_ID AND salm7d.Datekey = dt.Datekey
	LEFT JOIN 
	(
			SELECT dt.Datekey
				  ,st.Store_ID 
				  ,SUM(sal.Sales_AMT)/7.0 AS [Sales_MA7_14_AMT]
			FROM [dm].[Dim_Calendar] dt
			CROSS JOIN [dm].[Dim_Store] st
			LEFT JOIN #YH_Sales_Inventory AS sal ON DATEDIFF(DAY,CAST(sal.Calendar_DT AS VARCHAR),dt.[Date])>=7 AND DATEDIFF(DAY,CAST(sal.Calendar_DT AS VARCHAR),dt.[Date])<14 AND st.Store_ID = sal.Store_ID
			WHERE dt.Datekey>@MAX_CAL AND dt.[Date]<GETDATE() AND  Status = N'营运' AND st.Channel_Account = 'YH' --AND stf.FIRST_SALES_DATE IS NOT NULL -- AND dt.Datekey NOT IN (SELECT DISTINCT sfd.Datekey FROM FU_DM.T_DM_FCT_YH_Store_Flag_Daily sfd)-- AND Target_Store_FL=1 
			GROUP BY dt.Datekey
					,dt.[Date]
					,st.Account_Store_Type
					,st.Store_ID 
	) as salm7_14d ON st.Store_ID = salm7_14d.Store_ID AND salm7_14d.Datekey = dt.Datekey
	LEFT JOIN 
	(
			SELECT dt.Datekey
				  ,st.Store_ID
				  ,MAX(ds.Calendar_DT) AS Last_Order_DT
				  ,MAX(ds.InStock_Amount) AS Last_Order_AMT
 				  ,MAX(ds2.Calendar_DT) AS Last2_Order_DT
				  ,SUM(ds3.InStock_QTY) AS Order_Qty_L7
				  ,SUM(ds3.InStock_Amount) AS Order_Amt_L7
				  ,COUNT(DISTINCT SKU_ID) AS Order_SKUCount_L7
			FROM (SELECT * FROM [dm].[Dim_Calendar] WHERE [Date]>(SELECT MIN(Calendar_DT) FROM #YH_DailySales)) dt
			CROSS JOIN (SELECT DISTINCT Store_ID FROM #YH_DailySales) st
			LEFT JOIN (SELECT Calendar_DT,Store_ID,SUM(InStock_Amount) AS InStock_Amount,ROW_NUMBER() OVER(PARTITION BY Store_ID ORDER BY Calendar_DT DESC) rn FROM #YH_DailySales GROUP BY Calendar_DT,Store_ID) ds ON ds.rn=1 AND st.Store_ID = ds.Store_ID AND dt.[Date]>=ds.Calendar_DT 
			LEFT JOIN (SELECT Calendar_DT,Store_ID,ROW_NUMBER() OVER(PARTITION BY Store_ID ORDER BY Calendar_DT DESC) rn2 FROM #YH_DailySales GROUP BY Calendar_DT,Store_ID) ds2 ON ds2.rn2<=2 AND st.Store_ID = ds2.Store_ID AND ds.Calendar_DT >ds2.Calendar_DT 
			LEFT JOIN  #YH_DailySales ds3 ON  st.Store_ID = ds3.Store_ID AND dt.[Date] <DATEADD(DAY,7,ds3.Calendar_DT) AND dt.[Date] >=ds3.Calendar_DT
			WHERE dt.Datekey>@MAX_CAL AND dt.Is_Past =1
			GROUP BY dt.Datekey
				  ,st.Store_ID 
	) as InStockOrder ON st.Store_ID = InStockOrder.Store_ID AND InStockOrder.Datekey = dt.Datekey
	LEFT JOIN 
	(
			SELECT dt.Datekey
				  ,st.Store_ID
				  ,SUM(ds4.InStock_Amount) AS [This_WK_Order_AMT]
			FROM (SELECT * FROM [dm].[Dim_Calendar] WHERE [Date]>(SELECT MIN(Calendar_DT) FROM #YH_DailySales)) dt
			CROSS JOIN (SELECT DISTINCT Store_ID FROM #YH_DailySales) st
			LEFT JOIN (SELECT Calendar_DT,Store_ID,SUM(InStock_Amount) AS InStock_Amount FROM #YH_DailySales GROUP BY Calendar_DT,Store_ID ) ds4 ON  st.Store_ID = ds4.Store_ID 
			AND dt.[Date] <DATEADD(DAY,dt.Day_of_Week,ds4.Calendar_DT) AND dt.[Date] >=ds4.Calendar_DT
			WHERE dt.Datekey>@MAX_CAL AND dt.Is_Past=1
			GROUP BY dt.Datekey
				  ,st.Store_ID
	) as InStockOrderWeek ON st.Store_ID = InStockOrderWeek.Store_ID AND InStockOrderWeek.Datekey = dt.Datekey
	WHERE dt.Datekey>@MAX_CAL AND CAST(dt.[Date] AS DATE)<CAST(GETDATE() AS DATE) AND /* Status = N'营运' AND*/ st.Channel_Account = 'YH' AND Account_Store_Code NOT LIKE 'w%' AND Account_Store_Group NOT LIKE '%虚拟%' --AND stf.FIRST_SALES_DATE IS NOT NULL -- AND dt.Datekey NOT IN (SELECT DISTINCT sfd.Datekey FROM FU_DM.T_DM_FCT_YH_Store_Flag_Daily sfd)-- AND Target_Store_FL=1 
	GROUP BY dt.Datekey
			,dt.[Date]
			,st.Account_Store_Type
			,st.Store_ID 

	-------------------删除索引
	DROP INDEX IF EXISTS [#ix_c_YH_Sales_Inv_Cal] ON #YH_Sales_Inventory
 
END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
