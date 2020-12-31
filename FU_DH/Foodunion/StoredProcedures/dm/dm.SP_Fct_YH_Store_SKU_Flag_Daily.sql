USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC   [dm].[SP_Fct_YH_Store_SKU_Flag_Daily]
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY

TRUNCATE TABLE dm.Fct_YH_Store_SKU_Flag_Daily

SELECT Calendar_DT
	  ,Store_ID
	  ,SKU_ID
	  ,SUM(Sales_AMT) AS Sales_AMT
	  ,SUM(Sales_QTY) AS Sales_QTY
	  ,SUM(Inventory_LD_AMT) AS Inventory_AMT
	  ,SUM(Inventory_LD_QTY) AS  Inventory_QTY
	  INTO #YH_Sales_Inventory
FROM [dw].[Fct_YH_Sales_Inventory]
GROUP BY 
	  Calendar_DT
	 ,Store_ID
	 ,SKU_ID

INSERT INTO dm.Fct_YH_Store_SKU_Flag_Daily(
[Date_ID]
      ,[Store_ID]
      ,[SKU_ID]
      ,[Sales_AMT]
      ,[Sales_QTY]
      ,[Sales_Vol]
      ,[Inventory_AMT]
      ,[Inventory_QTY]
      ,[Inventory_Vol]
      ,[Min_Inv_Qty_In_Last_3_Day_Is_0]
      ,[Min_Inv_Qty_In_Last_3_Day_GT_0]
      ,[Min_Inv_Qty_In_Last_3_Day_GT_5]
      ,[Min_Inv_Qty_In_Last_3_Day_GT_10]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]

)
SELECT [Date_ID]
      ,[Store_ID]
      ,[SKU_ID]
      ,[Sales_AMT]
      ,[Sales_QTY]
      ,[Sales_Vol]
      ,[Inventory_AMT]
      ,[Inventory_QTY]
      ,[Inventory_Vol]
      ,[Min_Inv_Qty_In_Last_3_Day_Is_0]
      ,[Min_Inv_Qty_In_Last_3_Day_GT_0]
      ,[Min_Inv_Qty_In_Last_3_Day_GT_5]
      ,[Min_Inv_Qty_In_Last_3_Day_GT_10]
	  ,[Create_Time]
	  ,[Create_By]
	  ,[Update_Time]
	  ,[Update_By]
FROM(
SELECT dt.Date_ID
	  ,st.Store_ID 
	  ,prod.SKU_ID
	  ,si.Sales_AMT AS Sales_AMT
	  ,si.Sales_QTY AS Sales_QTY
	  ,si.Sales_QTY*prod.Sale_Unit_Weight_KG AS Sales_Vol
	  ,si.Inventory_AMT AS Inventory_AMT
	  ,si.Inventory_QTY AS Inventory_QTY
	  ,si.Inventory_QTY*prod.Sale_Unit_Weight_KG AS Inventory_Vol
	  ,CASE WHEN minQtyM3D.MinInv>0 THEN 0 ELSE 1 END AS [Min_Inv_Qty_In_Last_3_Day_Is_0]
	  ,CASE WHEN minQtyM3D.MinInv>0 THEN 1 ELSE 0 END AS [Min_Inv_Qty_In_Last_3_Day_GT_0]
	  ,CASE WHEN minQtyM3D.MinInv>=5 THEN 1 ELSE 0 END AS [Min_Inv_Qty_In_Last_3_Day_GT_5]
	  ,CASE WHEN minQtyM3D.MinInv>=10 THEN 1 ELSE 0 END AS [Min_Inv_Qty_In_Last_3_Day_GT_10]
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM [FU_EDW].[Dim_Calendar] dt
CROSS JOIN [dm].[Dim_Store] st
CROSS JOIN [dm].[Dim_Product] prod
LEFT JOIN #YH_Sales_Inventory AS si ON dt.Date_ID = si.Calendar_DT AND st.Store_ID = si.Store_ID AND prod.SKU_ID = si.SKU_ID
LEFT JOIN (
	  SELECT binv.Calendar_DT
			,binv.SKU_ID
			,binv.Store_ID
			,MIN(linv.Inventory_QTY) AS MinInv
	  FROM #YH_Sales_Inventory binv
	  LEFT JOIN #YH_Sales_Inventory linv ON binv.Store_ID = linv.Store_ID AND binv.SKU_ID = linv.SKU_ID AND DATEDIFF(DAY,linv.Calendar_DT,binv.Calendar_DT)<3 AND binv.Calendar_DT>=linv.Calendar_DT
	  GROUP BY binv.Calendar_DT
			  ,binv.SKU_ID
			  ,binv.Store_ID
			 -- order by Store_ID,SKU_ID,Calendar_DT desc
) AS minQtyM3D ON dt.Date_ID = minQtyM3D.Calendar_DT AND st.Store_ID = minQtyM3D.Store_ID AND prod.SKU_ID = minQtyM3D.SKU_ID
--LEFT JOIN #YH_Sales_Inventory AS invm7d ON dt.Date_ID = minQtyM3D.Calendar_DT AND st.Store_ID = minQtyM3D.Store_ID AND prod.SKU_ID = minQtyM3D.SKU_ID 
WHERE dt.Date_ID>='20180801' AND dt.Date_ID<convert(varchar(8),getdate(),112) AND prod.Brand_IP = 'BRAVO MAMA' AND st.Channel_Account = 'YH'
) a 
--WHERE Is_Sold_FL<>0 OR Has_Inventory_FL<>0 OR Is_Sold_In_3_Days_FL<>0

END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
