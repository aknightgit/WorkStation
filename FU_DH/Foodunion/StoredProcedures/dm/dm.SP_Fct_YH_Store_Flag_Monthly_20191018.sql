USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC  [dm].[SP_Fct_YH_Store_Flag_Monthly_20191018]
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY

TRUNCATE TABLE   dm.Fct_YH_Store_Flag_Monthly

SELECT LEFT(Calendar_DT,6)+'01' AS Calendar_DT
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
	  LEFT(Calendar_DT,6)
	 ,Store_ID


INSERT INTO  dm.Fct_YH_Store_Flag_Monthly
(
[YearMonth]
,[Store_ID]
,[Sales_AMT]
,[Sales_QTY]
,[Sales_Volume]
,[Inventory_AMT]
,[Inventory_QTY]
,[Inventory_Volume]
,[Sales_LM_AMT]
,[Sales_LM_QTY]
,[Sales_LM_Volume]
,[Inventory_LM_AMT]
,[Inventory_LM_QTY]
,[Inventory_LM_Volume]
,[Has_Inventory_SKU_NUM]
,[Has_Inventory_LM_SKU_NUM]
,[Is_Sold_SKU_NUM]
,[Is_Sold_LM_SKU_NUM]
,[Create_Time]
,[Create_By]
,[Update_Time]
,[Update_By]
)
SELECT dt.Date_ID
	  ,st.Store_ID 
	  ,SUM(si.[Sales_AMT])		AS	[Sales_AMT]
	  ,SUM(si.[Sales_QTY])		AS	[Sales_QTY]
	  ,SUM(si.[Sales_Vol])		AS	[Sales_Vol]
	  ,SUM(si.[Inventory_AMT])	AS	[Inventory_AMT]
	  ,SUM(si.[Inventory_QTY])	AS	[Inventory_QTY]
	  ,SUM(si.[Inventory_Vol])	AS	[Inventory_Vol]
	  ,SUM(slm.[Sales_AMT])		AS	[Sales_LM_AMT]
	  ,SUM(slm.[Sales_QTY])		AS	[Sales_LM_QTY]
	  ,SUM(slm.[Sales_Vol])		AS	[Sales_LM_Volume]
	  ,SUM(slm.[Inventory_AMT])	AS	[Inventory_LM_AMT]
	  ,SUM(slm.[Inventory_QTY])	AS	[Inventory_LM_QTY]
	  ,SUM(slm.[Inventory_Vol])	AS	[Inventory_LM_Volume]
	  ,MAX(si.SKU_Count) AS [Has_Inventory_SKU_NUM]
	  ,MAX(slm.SKU_Count) AS [Has_Inventory_LM_SKU_NUM]
	  ,CASE WHEN SUM(si.[Sales_AMT]) > 0 THEN 1 ELSE 0 END AS [Is_Sold_SKU_NUM]
	  ,CASE WHEN SUM(slm.[Sales_AMT]) > 0 THEN 1 ELSE 0 END AS [Is_Sold_LM_SKU_NUM]
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM (SELECT DISTINCT CAST(YEAR_MONTH AS VARCHAR)+'01' AS Date_ID FROM [FU_EDW].[Dim_Calendar]) dt
CROSS JOIN  [dm].[Dim_Store] st
LEFT JOIN #YH_Sales_Inventory AS si ON dt.Date_ID = si.Calendar_DT  AND st.Store_ID = si.Store_ID
LEFT JOIN 
(		SELECT dt.Date_ID
			  ,st.Store_ID 
			  ,SUM(si.Sales_AMT		) AS Sales_AMT
			  ,SUM(si.Sales_QTY		) AS Sales_QTY
			  ,SUM(si.Sales_VOL		) AS Sales_VOL
			  ,SUM(si.Inventory_AMT	) AS Inventory_AMT
			  ,SUM(si.Inventory_QTY	) AS Inventory_QTY
			  ,SUM(si.Inventory_VOL	) AS Inventory_VOL
			  ,MAX(si.SKU_Count) AS SKU_Count
		FROM (SELECT DISTINCT CAST(YEAR_MONTH AS VARCHAR)+'01' AS Date_ID FROM [FU_EDW].[Dim_Calendar]) dt
		CROSS JOIN [dm].[Dim_Store] st
		LEFT JOIN #YH_Sales_Inventory AS si ON dt.Date_ID = DATEADD(MONTH,1,si.Calendar_DT) AND st.Store_ID = si.Store_ID
		WHERE dt.Date_ID>='20180801' AND CAST(dt.Date_ID AS DATE)<GETDATE() AND  Status = N'营运' AND st.Channel_Account = 'YH' --AND stf.FIRST_SALES_DATE IS NOT NULL -- AND dt.Date_ID NOT IN (SELECT DISTINCT sfd.Date_ID FROM FU_DM.T_DM_FCT_YH_Store_Flag_Daily sfd)-- AND Target_Store_FL=1 
		GROUP BY dt.Date_ID
				,st.Store_ID 
) AS slm ON dt.Date_ID = slm.Date_ID  AND st.Store_ID = slm.Store_ID
WHERE dt.Date_ID>='20180801' AND CAST(dt.Date_ID AS DATE)<CAST(GETDATE() AS DATE) AND  Status = N'营运' AND st.Channel_Account = 'YH' AND Account_Store_Code NOT LIKE 'w%' AND Account_Store_Group NOT LIKE '%虚拟%' --AND stf.FIRST_SALES_DATE IS NOT NULL -- AND dt.Date_ID NOT IN (SELECT DISTINCT sfd.Date_ID FROM FU_DM.T_DM_FCT_YH_Store_Flag_Daily sfd)-- AND Target_Store_FL=1 
GROUP BY dt.Date_ID
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
