USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







create PROC  [dm].[SP_Fct_YH_Store_Flag_Daily_20191018]
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY

TRUNCATE TABLE   dm.Fct_YH_Store_Flag_Daily 

SELECT Calendar_DT
	  ,Store_ID
	  ,SUM(Sales_AMT) AS Sales_AMT
	  ,SUM(Sales_QTY) AS Sales_QTY
	  ,SUM(Sales_QTY*prod.Sale_Unit_Weight_KG) AS Sales_VOL
	  ,SUM(Inventory_LD_AMT) AS Inventory_AMT
	  ,SUM(Inventory_LD_QTY) AS  Inventory_QTY
	  ,SUM(Inventory_LD_QTY*prod.Sale_Unit_Weight_KG) AS  Inventory_VOL
	  ,COUNT(DISTINCT CASE WHEN inv.Inventory_LD_QTY>0 THEN inv.SKU_ID END) AS SKU_Count
	  INTO #YH_Sales_Inventory
FROM [dw].[Fct_YH_Sales_Inventory] inv
LEFT JOIN [dm].[Dim_Product] prod ON inv.SKU_ID = prod.SKU_ID
GROUP BY 
	  Calendar_DT
	 ,Store_ID

SELECT Calendar_DT
	  ,Store_ID
	  ,CASE WHEN SUM(sal.Sales_AMT)>0 THEN 1 ELSE 0 END AS IsActive
	  ,SUM(sal.Sales_AMT) AS Sales_AMT
	  ,SUM(sal.YH_Home_Sales_AMT) AS YH_Home_Sales_AMT
	  ,SUM(sal.JD_Home_Sales_AMT) AS JD_Home_Sales_AMT
	  ,COUNT(DISTINCT CASE WHEN sal.YH_Home_Sales_AMT>0 OR sal.JD_Home_Sales_AMT>0 THEN sal.SKU_ID END) AS SKU_Count
	  INTO #YH_Sales
FROM [dw].[Fct_YH_Sales_All] sal
LEFT JOIN [dm].[Dim_Product] prod ON sal.SKU_ID = prod.SKU_ID
--WHERE sal.YH_Home_Sales_AMT>0 OR sal.JD_Home_Sales_AMT>0 
GROUP BY 
	  Calendar_DT
	 ,Store_ID

SELECT dt.Date_NM
	  ,st.Account_Area_CN 
	  ,SUM(sal.Sales_AMT)/COUNT(DISTINCT st.Store_ID) PSD_By_Region
	  INTO #YH_Sales_By_Region
FROM [FU_EDW].[Dim_Calendar] dt
CROSS JOIN [dm].[Dim_Store] st
LEFT JOIN #YH_Sales AS sal ON dt.Date_ID = sal.Calendar_DT AND st.Store_ID = sal.Store_ID
WHERE dt.Date_ID>='20180801' AND dt.Date_NM<GETDATE() AND  Status = N'营运'  AND st.Channel_Account = 'YH'
GROUP BY dt.Date_NM
	  ,st.Account_Area_CN 


---daily sales by day
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
,YH_Home_Sales_AMT
,JD_Home_Sales_AMT
,[Inventory_AMT]
,[Inventory_QTY]
,[Inventory_Vol]
,[Inventory_SKU_Count]
,[Inventory_MA14_AMT]
,[Inventory_MA14_QTY]
,[Inventory_MA14_VOL]
,[Sales_MA7_AMT]
,[Sales_MA7_14_AMT]
,[Active_Days_MA7]
,[Sales_MA14_AMT]
,[Sales_MA14_QTY]
,[Sales_MA14_VOL]
,[Distribution]
,[Online_Distribution]
,[SKU_Distribution]
,Store_Count_Target
,[Sales_Store_AVG_AMT_REGION_MA7]
,[Sales_Store_AVG_AMT_REGION_MA14]
,[Sales_Store_AVG_AMT_REGION_MA7_14]
,Last_Order_DT
,Last2_Order_DT
,Date_Gap_Last1_2
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
SELECT dt.Date_ID
	  ,st.Store_ID 
	  ,SUM(sal.[Sales_AMT])		AS	[Sales_AMT]
	  ,SUM([Sales_QTY])		AS	[Sales_QTY]
	  ,SUM([Sales_Vol])		AS	[Sales_Vol]
	  ,SUM(sal.YH_Home_Sales_AMT) AS YH_Home_Sales_AMT
	  ,SUM(sal.JD_Home_Sales_AMT) AS JD_Home_Sales_AMT
	  ,SUM([Inventory_AMT])	AS	[Inventory_AMT]
	  ,SUM([Inventory_QTY])	AS	[Inventory_QTY]
	  ,SUM([Inventory_Vol])	AS	[Inventory_Vol]
	  ,SUM(si.SKU_Count) AS [Inventory_SKU_Count]
	  ,SUM(dist.[Inventory_MA14_AMT]) AS [Inventory_MA14_AMT]
	  ,SUM(dist.[Inventory_MA14_QTY]) AS [Inventory_MA14_QTY]
	  ,SUM(dist.[Inventory_MA14_VOL]) AS [Inventory_MA14_VOL]
	  ,SUM(salm7d.Sales_MA7_AMT) AS Sales_MA7_AMT
	  ,SUM(salm7_14d.Sales_MA7_14_AMT) AS Sales_MA7_14_AMT
	  ,SUM(salm7d.Active_Days_MA7) AS [Active_Days_MA7_QTY]
	  ,SUM(dist.[Sales_MA14_AMT]) AS [Sales_MA14_AMT]
	  ,SUM(dist.[Sales_MA14_QTY]) AS [Sales_MA14_QTY]
	  ,SUM(dist.[Sales_MA14_VOL]) AS [Sales_MA14_VOL]
	  ,MAX(dist.[Distribution]) AS [Distribution]
	  ,MAX(ondist.Online_Distribution) AS [Online_Distribution]
	  ,MAX(ssd.[SKU_Distribution]) AS [SKU_Distribution]
	  ,/*MAX(bm.[Target])*/0 AS Store_Count_Target
	  ,SUM(stavg7.[Sales_Store_AVG_AMT_REGION_MA7]) AS [Sales_Store_AVG_AMT_REGION_MA7]
	  ,SUM(stavg14.[Sales_Store_AVG_AMT_REGION_MA14]) AS [Sales_Store_AVG_AMT_REGION_MA14]
	  ,SUM(stavg7_14.[Sales_Store_AVG_AMT_REGION_MA7_14]) AS [Sales_Store_AVG_AMT_REGION_MA7_14]
	  ,MAX(InStockOrder.Last_Order_DT)	AS Last_Order_DT
	  ,MAX(InStockOrder.Last2_Order_DT)	AS Last2_Order_DT
	  ,DATEDIFF(DAY,MAX(InStockOrder.Last2_Order_DT),MAX(InStockOrder.Last_Order_DT))	AS Date_Gap_Last1_2
	  ,SUM(InStockOrder.Order_Qty_L7)	AS Order_Qty_L7
	  ,SUM(InStockOrder.Order_Amt_L7)	AS Order_Amt_L7
	  ,SUM(InStockOrder.Order_SKUCount_L7)	AS Order_SKUCount_L7
	  ,SUM(InStockOrderWeek.This_WK_Order_AMT) AS [This_WK_Order_AMT]
	  ,SUM(InStockOrder.Last_Order_AMT) AS Last_Order_AMT
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM [FU_EDW].[Dim_Calendar] dt
CROSS JOIN [dm].[Dim_Store] st
LEFT JOIN #YH_Sales_Inventory AS si ON dt.Date_ID = si.Calendar_DT  AND st.Store_ID = si.Store_ID
LEFT JOIN #YH_Sales AS sal ON dt.Date_ID = sal.Calendar_DT AND st.Store_ID = sal.Store_ID
LEFT JOIN 
(		SELECT dt.Date_ID
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
		FROM [FU_EDW].[Dim_Calendar] dt
		CROSS JOIN [dm].[Dim_Store] st
		LEFT JOIN #YH_Sales_Inventory AS si ON dt.Date_ID >= si.Calendar_DT AND DATEDIFF(DAY,CAST(si.Calendar_DT AS DATE),dt.Date_NM)<3 AND st.Store_ID = si.Store_ID
		WHERE dt.Date_ID>='20180801' AND dt.Date_NM<GETDATE() AND  Status = N'营运' AND st.Channel_Account = 'YH' --AND stf.FIRST_SALES_DATE IS NOT NULL -- AND dt.Date_ID NOT IN (SELECT DISTINCT sfd.Date_ID FROM FU_DM.T_DM_FCT_YH_Store_Flag_Daily sfd)-- AND Target_Store_FL=1 
		GROUP BY dt.Date_ID
				,dt.Date_NM
				,st.Account_Store_Type
				,st.Store_ID 
) AS ssd ON dt.Date_ID = ssd.Date_ID  AND st.Store_ID = ssd.Store_ID
LEFT JOIN 
(
		SELECT dt.Date_ID
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
			  ,SUM(si.Inventory_VOL)/14.0 AS [Inventory_MA14_VOL]
			  ,SUM(si.Sales_AMT)/14.0 AS [Sales_MA14_AMT]
			  ,SUM(si.Sales_QTY)/14.0 AS [Sales_MA14_QTY]
			  ,SUM(si.Sales_VOL)/14.0 AS [Sales_MA14_VOL]
		FROM [FU_EDW].[Dim_Calendar] dt
		CROSS JOIN [dm].[Dim_Store] st
		LEFT JOIN #YH_Sales_Inventory AS si ON dt.Date_ID >= si.Calendar_DT AND DATEDIFF(DAY,CAST(si.Calendar_DT AS DATE),dt.Date_NM)<14 AND st.Store_ID = si.Store_ID
		WHERE dt.Date_ID>='20180801' AND dt.Date_NM<GETDATE() AND  Status = N'营运' AND st.Channel_Account = 'YH' --AND stf.FIRST_SALES_DATE IS NOT NULL -- AND dt.Date_ID NOT IN (SELECT DISTINCT sfd.Date_ID FROM FU_DM.T_DM_FCT_YH_Store_Flag_Daily sfd)-- AND Target_Store_FL=1 
		GROUP BY dt.Date_ID
				,dt.Date_NM
				,st.Account_Store_Type
				,st.Store_ID 
) as dist ON st.Store_ID = dist.Store_ID AND dist.Date_ID = dt.Date_ID
LEFT JOIN 
(
		SELECT dt.Date_ID
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
		FROM [FU_EDW].[Dim_Calendar] dt
		CROSS JOIN [dm].[Dim_Store] st
		LEFT JOIN #YH_Sales AS sal ON dt.Date_ID >= sal.Calendar_DT AND DATEDIFF(DAY,CAST(sal.Calendar_DT AS DATE),dt.Date_NM)<14 AND st.Store_ID = sal.Store_ID
		WHERE dt.Date_ID>='20180801' AND dt.Date_NM<GETDATE() AND  Status = N'营运' AND st.Channel_Account = 'YH' --AND stf.FIRST_SALES_DATE IS NOT NULL -- AND dt.Date_ID NOT IN (SELECT DISTINCT sfd.Date_ID FROM FU_DM.T_DM_FCT_YH_Store_Flag_Daily sfd)-- AND Target_Store_FL=1 
		GROUP BY dt.Date_ID
				,dt.Date_NM
				,st.Account_Store_Type
				,st.Store_ID 
) as ondist ON st.Store_ID = ondist.Store_ID AND ondist.Date_ID = dt.Date_ID
LEFT JOIN 
(
		SELECT dt.Date_ID
			  ,st.Store_ID 
			  ,SUM(sal.Sales_AMT)/7.0 AS [Sales_MA7_AMT]
			  ,SUM(CAST(sal.IsActive AS FLOAT))/7 AS Active_Days_MA7
		FROM [FU_EDW].[Dim_Calendar] dt
		CROSS JOIN [dm].[Dim_Store] st
		LEFT JOIN #YH_Sales AS sal ON dt.Date_ID >= sal.Calendar_DT AND DATEDIFF(DAY,CAST(sal.Calendar_DT AS DATE),dt.Date_NM)<7 AND st.Store_ID = sal.Store_ID
		WHERE dt.Date_ID>='20180801' AND dt.Date_NM<GETDATE() AND  Status = N'营运' AND st.Channel_Account = 'YH' --AND stf.FIRST_SALES_DATE IS NOT NULL -- AND dt.Date_ID NOT IN (SELECT DISTINCT sfd.Date_ID FROM FU_DM.T_DM_FCT_YH_Store_Flag_Daily sfd)-- AND Target_Store_FL=1 
		GROUP BY dt.Date_ID
				,dt.Date_NM
				,st.Account_Store_Type
				,st.Store_ID 
) as salm7d ON st.Store_ID = salm7d.Store_ID AND salm7d.Date_ID = dt.Date_ID
LEFT JOIN 
(
		SELECT dt.Date_ID
			  ,st.Store_ID 
			  ,SUM(sal.Sales_AMT)/7.0 AS [Sales_MA7_14_AMT]
		FROM [FU_EDW].[Dim_Calendar] dt
		CROSS JOIN [dm].[Dim_Store] st
		LEFT JOIN #YH_Sales AS sal ON DATEDIFF(DAY,CAST(sal.Calendar_DT AS DATE),dt.Date_NM)>=7 AND DATEDIFF(DAY,CAST(sal.Calendar_DT AS DATE),dt.Date_NM)<14 AND st.Store_ID = sal.Store_ID
		WHERE dt.Date_ID>='20180801' AND dt.Date_NM<GETDATE() AND  Status = N'营运' AND st.Channel_Account = 'YH' --AND stf.FIRST_SALES_DATE IS NOT NULL -- AND dt.Date_ID NOT IN (SELECT DISTINCT sfd.Date_ID FROM FU_DM.T_DM_FCT_YH_Store_Flag_Daily sfd)-- AND Target_Store_FL=1 
		GROUP BY dt.Date_ID
				,dt.Date_NM
				,st.Account_Store_Type
				,st.Store_ID 
) as salm7_14d ON st.Store_ID = salm7_14d.Store_ID AND salm7_14d.Date_ID = dt.Date_ID
--LEFT JOIN [FU_EDW].[T_EDW_FCT_Distribution_Target_By_Business_Manager] bm ON dt.Date_ID>'20190101' AND dt.[Month] = bm.[Month] AND st.sr_level_1 = bm.Busniess_Manager_NM
--LEFT JOIN [dm].[Dim_Store_Flg] AS stf ON st.Store_ID = stf.Store_ID
LEFT JOIN 
(
		SELECT dt.Date_ID
			  ,sal.Account_Area_CN
			  ,SUM(sal.PSD_By_Region)/7 AS [Sales_Store_AVG_AMT_REGION_MA7]
		FROM [FU_EDW].[Dim_Calendar] dt
		LEFT JOIN #YH_Sales_By_Region AS sal ON dt.Date_NM >= sal.Date_NM AND DATEDIFF(DAY,CAST(sal.Date_NM AS DATE),dt.Date_NM)<7 
		WHERE dt.Date_ID>='20180801' AND dt.Date_NM<GETDATE() AND sal.Account_Area_CN IS NOT NULL
    	GROUP BY dt.Date_ID
			  ,sal.Account_Area_CN 

) as stavg7 ON st.Account_Area_CN = stavg7.Account_Area_CN AND stavg7.Date_ID = dt.Date_ID
LEFT JOIN 
(
 
		SELECT dt.Date_ID
			  ,sal.Account_Area_CN
			  ,SUM(sal.PSD_By_Region)/14 AS [Sales_Store_AVG_AMT_REGION_MA14]
		FROM [FU_EDW].[Dim_Calendar] dt
		LEFT JOIN #YH_Sales_By_Region AS sal ON dt.Date_NM >= sal.Date_NM AND DATEDIFF(DAY,CAST(sal.Date_NM AS DATE),dt.Date_NM)<14
		WHERE dt.Date_ID>='20180801' AND dt.Date_NM<GETDATE() AND sal.Account_Area_CN IS NOT NULL
    	GROUP BY dt.Date_ID
			  ,sal.Account_Area_CN 

) as stavg14 ON st.Account_Area_CN = stavg14.Account_Area_CN AND stavg14.Date_ID = dt.Date_ID
LEFT JOIN 
(
		SELECT dt.Date_ID
			  ,sal.Account_Area_CN
			  ,SUM(sal.PSD_By_Region)/7 AS [Sales_Store_AVG_AMT_REGION_MA7_14]
		FROM [FU_EDW].[Dim_Calendar] dt
		LEFT JOIN #YH_Sales_By_Region AS sal ON DATEDIFF(DAY,CAST(sal.Date_NM AS DATE),dt.Date_NM)>=7 AND DATEDIFF(DAY,CAST(sal.Date_NM AS DATE),dt.Date_NM)<14
		WHERE dt.Date_ID>='20180801' AND dt.Date_NM<GETDATE() AND sal.Account_Area_CN IS NOT NULL
    	GROUP BY dt.Date_ID
			  ,sal.Account_Area_CN 
) as stavg7_14 ON st.Account_Area_CN = stavg7_14.Account_Area_CN AND stavg7_14.Date_ID = dt.Date_ID
LEFT JOIN 
(
		SELECT dt.Date_ID
			  ,st.Store_ID
			  ,MAX(ds.Calendar_DT) AS Last_Order_DT
			  ,MAX(ds.InStock_Amount) AS Last_Order_AMT
 			  ,MAX(ds2.Calendar_DT) AS Last2_Order_DT
			  ,SUM(ds3.InStock_QTY) AS Order_Qty_L7
			  ,SUM(ds3.InStock_Amount) AS Order_Amt_L7
		      ,COUNT(DISTINCT SKU_ID) AS Order_SKUCount_L7
		FROM (SELECT * FROM [FU_EDW].[Dim_Calendar] WHERE Date_NM>(SELECT MIN(Calendar_DT) FROM #YH_DailySales)) dt
		CROSS JOIN (SELECT DISTINCT Store_ID FROM #YH_DailySales) st
		LEFT JOIN (SELECT Calendar_DT,Store_ID,SUM(InStock_Amount) AS InStock_Amount,ROW_NUMBER() OVER(PARTITION BY Store_ID ORDER BY Calendar_DT DESC) rn FROM #YH_DailySales GROUP BY Calendar_DT,Store_ID) ds ON ds.rn=1 AND st.Store_ID = ds.Store_ID AND dt.Date_NM>=ds.Calendar_DT 
		LEFT JOIN (SELECT Calendar_DT,Store_ID,ROW_NUMBER() OVER(PARTITION BY Store_ID ORDER BY Calendar_DT DESC) rn2 FROM #YH_DailySales GROUP BY Calendar_DT,Store_ID) ds2 ON ds2.rn2<=2 AND st.Store_ID = ds2.Store_ID AND ds.Calendar_DT >ds2.Calendar_DT 
		LEFT JOIN  #YH_DailySales ds3 ON  st.Store_ID = ds3.Store_ID AND dt.Date_NM <DATEADD(DAY,7,ds3.Calendar_DT) AND dt.Date_NM >=ds3.Calendar_DT
		WHERE dt.Day_Filter_Flag =1
		GROUP BY dt.Date_ID
			  ,st.Store_ID 
) as InStockOrder ON st.Store_ID = InStockOrder.Store_ID AND InStockOrder.Date_ID = dt.Date_ID
LEFT JOIN 
(
		SELECT dt.Date_ID
			  ,st.Store_ID
              ,SUM(ds4.InStock_Amount) AS [This_WK_Order_AMT]
		FROM (SELECT * FROM [FU_EDW].[Dim_Calendar] WHERE Date_NM>(SELECT MIN(Calendar_DT) FROM #YH_DailySales)) dt
		CROSS JOIN (SELECT DISTINCT Store_ID FROM #YH_DailySales) st
		LEFT JOIN (SELECT Calendar_DT,Store_ID,SUM(InStock_Amount) AS InStock_Amount FROM #YH_DailySales GROUP BY Calendar_DT,Store_ID ) ds4 ON  st.Store_ID = ds4.Store_ID AND dt.Date_NM <DATEADD(DAY,dt.Week_Day,ds4.Calendar_DT) AND dt.Date_NM >=ds4.Calendar_DT
		WHERE dt.Day_Filter_Flag =1
		GROUP BY dt.Date_ID
			  ,st.Store_ID
) as InStockOrderWeek ON st.Store_ID = InStockOrderWeek.Store_ID AND InStockOrderWeek.Date_ID = dt.Date_ID
WHERE dt.Date_ID>='20180801' AND CAST(dt.Date_NM AS DATE)<CAST(GETDATE() AS DATE) AND  Status = N'营运' AND st.Channel_Account = 'YH' AND Account_Store_Code NOT LIKE 'w%' AND Account_Store_Group NOT LIKE '%虚拟%' --AND stf.FIRST_SALES_DATE IS NOT NULL -- AND dt.Date_ID NOT IN (SELECT DISTINCT sfd.Date_ID FROM FU_DM.T_DM_FCT_YH_Store_Flag_Daily sfd)-- AND Target_Store_FL=1 
GROUP BY dt.Date_ID
		,dt.Date_NM
		,st.Account_Store_Type
	    ,st.Store_ID 


 
END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
