USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE   PROC  [dw].[SP_Fct_YH_Goods_Display_20191018] 
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY

TRUNCATE TABLE   dw.[Fct_YH_Goods_Display]

--------------------------------------Goods_Display
SELECT 
		 UP.[YH_City]		
		,UP.[YH_Store_CD]	
		,UP.[Store_Name]	
		,UP.YH_TYPE	
		,UP.SKU_QTY		
		,UP.SKU_KG_Vol		
		INTO #Goods_Display
FROM (
------------------------------------------------------- Fresh Milk
SELECT
	 ST.Store_City AS [YH_City]
	,GD.YH_Store_CD
	,ST.Store_Name
	,'Fresh Milk' AS [YH_TYPE]
	,CAST(FM_950 AS FLOAT)+CAST(FM_500 AS FLOAT)+CAST(FM_250 AS FLOAT) AS SKU_QTY
	,CAST(FM_950 AS FLOAT)*0.998+CAST(FM_500 AS FLOAT)*0.52+CAST(FM_250 AS FLOAT)*0.26 AS SKU_KG_Vol
FROM [ODS].[ods].[File_YH_Goods_Display] GD
LEFT JOIN dm.Dim_Store ST ON GD.YH_Store_CD = st.Account_Store_Code
--------------------------------------------------------Fresh spoonable yoghurt
UNION ALL 
SELECT
	 ST.Store_City
	,GD.YH_Store_CD
	,ST.Store_Name
	,'Fresh spoonable yoghurt' AS [YH_TYPE]
	,CAST(SY_Plain AS FLOAT)+CAST(SY_Strawberry AS FLOAT)+CAST(SY_MP AS FLOAT) AS SKU_QTY
	,CAST(SY_Plain AS FLOAT)*0.5+CAST(SY_Strawberry AS FLOAT)*0.5+CAST(SY_MP AS FLOAT)*0.5 AS SKU_KG_Vol
FROM [ODS].[ods].[File_YH_Goods_Display] GD
LEFT JOIN dm.Dim_Store ST ON GD.YH_Store_CD = st.Account_Store_Code
--------------------------------------------------------Fresh drinkable yoghurt
UNION ALL 
SELECT
	 ST.Store_City
	,GD.YH_Store_CD
	,ST.Store_Name
	,'Fresh drinkable yoghurt' AS [YH_TYPE]
	,CAST(DY_Plain AS FLOAT)+CAST(DY_Vallina AS FLOAT)+CAST(DY_MP AS FLOAT) AS SKU_QTY
	,CAST(DY_Plain AS FLOAT)*0.2+CAST(DY_Vallina AS FLOAT)*0.2+CAST(DY_MP AS FLOAT)*0.2 AS SKU_KG_Vol
FROM [ODS].[ods].[File_YH_Goods_Display] GD
LEFT JOIN dm.Dim_Store ST ON GD.YH_Store_CD = st.Account_Store_Code
--------------------------------------------------------Greek Yoghurt
UNION ALL 
SELECT
	 ST.Store_City
	,GD.YH_Store_CD
	,ST.Store_Name
	,'Greek Yoghurt' AS [YH_TYPE]
	,CAST(GY_Plain AS FLOAT)+CAST(GY_Strawberry AS FLOAT)+CAST(GY_MP AS FLOAT) AS SKU_QTY
	,CAST(GY_Plain AS FLOAT)*0.4+CAST(GY_Strawberry AS FLOAT)*0.4+CAST(GY_MP AS FLOAT)*0.4 AS SKU_KG_Vol
FROM [ODS].[ods].[File_YH_Goods_Display] GD
LEFT JOIN dm.Dim_Store ST ON GD.YH_Store_CD = st.Account_Store_Code
WHERE GD.YH_Store_CD IS NOT NULL
--------------------------------------------------------UHT Milk
UNION ALL 
SELECT
	 ST.Store_City
	,GD.YH_Store_CD
	,ST.Store_Name
	,'UHT Milk' AS [YH_TYPE]
	,CAST(Ambient_UHT AS FLOAT) AS SKU_QTY
	,CAST(Ambient_UHT AS FLOAT)*1.248 AS SKU_QTY
FROM [ODS].[ods].[File_YH_Goods_Display] GD
LEFT JOIN dm.Dim_Store ST ON GD.YH_Store_CD = st.Account_Store_Code
--------------------------------------------------------Ambient Yogurt
UNION ALL 
SELECT
	 ST.Store_City
	,GD.YH_Store_CD
	,ST.Store_Name
	,'Ambient Yogurt' AS [YH_TYPE]
	,CAST(Ambient_Plain_Yogurt AS FLOAT)+CAST(Ambient_Flavors AS FLOAT) AS SKU_QTY
	,CAST(Ambient_Plain_Yogurt AS FLOAT)*1.26+CAST(Ambient_Flavors AS FLOAT)*1.26 AS SKU_KG_Vol
FROM [ODS].[ods].[File_YH_Goods_Display] GD
LEFT JOIN dm.Dim_Store ST ON GD.YH_Store_CD = st.Account_Store_Code

) UP



-----------------------------------------------------------Actual_Inventory
SELECT
	 CAST(Calendar_DT AS DATE) AS Calendar_Dt
	,YH_Store_CD
	,Prod.YH_Type
	,SUM(Inventory_QTY) AS Inventory_QTY
	,SUM(Inventory_QTY*Prod.Density_SKU_Ton_Num*1000.0) AS Inventory_KG_Vol
	INTO #Actual_Inventory
FROM [ODS].[ods].[File_YH_Inventory] Inv
LEFT JOIN [FU_EDW].[T_EDW_DIM_Product] Prod ON Inv.YH_UPC = Prod.YH_UPC
WHERE PROD.YH_Type IS NOT NULL
GROUP BY Calendar_DT
		,YH_Store_CD
		,Prod.YH_Type

-------------------------------------------------------JOIN Insert
INSERT INTO dw.[Fct_YH_Goods_Display]
(
 Calendar_DT		
,[YH_City]			
,[Store_ID]		  
,[YH_Store_CD]		
,[YH_Store_NM]		
,YH_TYPE			
,SKU_ID			  
,SKU_QTY			
,SKU_KG_Vol			
,Inventory_QTY		
,Inventory_KG_Vol
,[Create_Time]
,[Create_By]
,[Update_Time]
,[Update_By]
)
SELECT 
	   DT.Date_ID
	  ,ST.Store_City
	  ,ST.Store_ID
	  ,GD.YH_Store_CD
	  ,ST.Store_Name
	  ,GD.YH_TYPE
	  ,PROD.SKU_ID
	  ,GD.SKU_QTY
	  ,GD.SKU_KG_Vol
	  ,AI.Inventory_QTY
	  ,AI.Inventory_KG_Vol
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM #Goods_Display GD
LEFT JOIN #Actual_Inventory AI ON GD.YH_TYPE = AI.YH_Type AND GD.YH_Store_CD = AI.YH_Store_CD
LEFT JOIN (SELECT YH_Type,MIN(SKU_ID) AS SKU_ID FROM [FU_EDW].[T_EDW_DIM_Product] WHERE YH_Type IS NOT NULL GROUP BY YH_Type) PROD ON GD.YH_TYPE = PROD.YH_Type
LEFT JOIN dm.Dim_Store ST ON GD.YH_Store_CD = st.Account_Store_Code
LEFT JOIN [FU_EDW].[Dim_Calendar] DT ON DT.Date_NM = CAST(AI.Calendar_Dt AS DATE)
WHERE GD.YH_Store_CD IS NOT NULL AND AI.Calendar_Dt IS NOT NULL
	
END TRY
 BEGIN CATCH
 
 SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

 END CATCH
	
		
END



GO
