USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE  [dm].[SP_Fct_Sales_Plan_Update]
	-- Add the parameters for the stored procedure here
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY
	/****** Script for SelectTopNRows command from SSMS  ******/

	TRUNCATE TABLE dm.[Fct_Sales_Plan]

	----------------------------------------Sales out
	INSERT INTO dm.[Fct_Sales_Plan](
	 Plan_DT
	,SKU_ID
	,SALES_OUT_VOL
	,Week_NM
	,Year_Month
	,Week_Month
	,[Create_Time]
	,[Create_By]
	,[Update_Time]
	,[Update_By]
	)
	SELECT  MIN(SAD.calday) AS Calendar_DT
		   ,SKU_ID
		   ,SUM(Sales_Vol) AS Sales_Vol
		   ,Week_of_Year
		   ,Monthkey
		   ,Week_of_Month
		   ,GETDATE() AS [Create_Time]
		   ,OBJECT_NAME(@@PROCID) AS [Create_By]
		   ,GETDATE() AS [Update_Time]
		   ,OBJECT_NAME(@@PROCID) AS [Update_By]
	FROM (
		SELECT 
			 SA.calday
			,CL.Week_of_Year
			,CL.Monthkey
			,CL.Week_of_Month
			,SKU_ID
			,SUM(Sales_QTY*prod.Sale_Unit_Weight_KG)/1000 AS Sales_Vol 
		FROM ODS.ods.EDI_YH_Sales SA
		LEFT JOIN [dm].[Dim_Calendar] CL ON SA.calday = CL.Datekey
		LEFT JOIN DM.Dim_Product Prod ON sa.bar_code = Prod.Bar_Code AND CASE WHEN sa.goods_name LIKE '%小猪%' THEN 'PEPPA' WHEN sa.goods_name LIKE '%瑞奇%' THEN 'RIKI' ELSE 'PEPPA' END = CASE WHEN prod.Brand_IP IN ('PEPPA','RIKI') THEN prod.Brand_IP ELSE 'PEPPA' END
		GROUP BY SA.calday
				,CL.Week_of_Year
				,CL.Monthkey
				,CL.Week_of_Month
				,SKU_ID
	) AS SAD
	GROUP BY Week_of_Year
			,Monthkey
			,Week_of_Month
			,SKU_ID 



	----------------------------------------Sales Forcast
	INSERT INTO dm.[Fct_Sales_Plan](
	 Plan_DT
	,SKU_ID
	,SALES_FCST_VOL
	,Week_NM
	,Year_Month
	,Week_Month
	,[Create_Time]
	,[Create_By]
	,[Update_Time]
	,[Update_By]
	)
	SELECT 
	 1+100*[Month]+10000*[Year] AS Calendar_DT
	,SKU_ID
	,Volume AS SALES_FCST_VOL
	,[Month]+100*[Year] AS Monthkey
	,LEFT(convert(varchar(8), 1+100*[Month]+10000*[Year],112),6) AS Monthkey
	,DATEPART("WW",CAST(1+100*[Month]+10000*[Year] AS VARCHAR))-DATEPART(WK,DATEADD(MM, DATEDIFF(MM,0,CAST( 1+100*[Month]+10000*[Year] AS VARCHAR) ), 0))+1 AS Week_Month
	,GETDATE() AS [Create_Time]
	,OBJECT_NAME(@@PROCID) AS [Create_By]
	,GETDATE() AS [Update_Time]
	,OBJECT_NAME(@@PROCID) AS [Update_By]
	FROM ods.[ods].[File_Production_DemandPlanning] PL WHERE Channel = 'YH' AND volume>0 AND Item='Adjusted demand'
	----------------------------------------Sell In
	/*
	INSERT INTO [dm].[T_EDW_Fct_Sales_Plan](
	 Plan_DT
	,SKU_ID
	,SALES_In_VOL
	,Week_NM
	,Monthkey
	,Week_Month
	,Update_DTM
	)
	SELECT 
	 convert(varchar(8),Date_DT,112) AS Calendar_DT
	,PROD.SKU_ID
	,SI.Sales_In_Vol
	,DATEPART("WW",Date_DT) AS Monthkey
	,LEFT(CONVERT(varchar(8),Date_DT,112),6) AS Week_Month
	,DATEPART("WW",Date_DT)-DATEPART(WK,DATEADD(MM, DATEDIFF(MM,0,CAST(Date_DT AS DATE) ), 0))+1 AS Week_Month
	,GETDATE() AS Update_DTM
	FROM [FU_ODS].[T_ODS_YH_Sell-In] SI
	LEFT JOIN (SELECT Product_Category,MAX(SKU_ID) AS SKU_ID FROM dm.Dim_Product GROUP BY Product_Category) PROD ON PROD.Product_Category = SI.YH_Type
	where convert(varchar(8),Date_DT,112)<'20190101' 
	order by 1 desc
	*/

	-- insert Sell-in order Volumn(MT) from ERP orders
	INSERT INTO dm.[Fct_Sales_Plan](
	 Plan_DT
	,SKU_ID
	,SALES_In_VOL
	,Week_NM
	,year_month
	,Week_Month
	,[Create_Time]
	,[Create_By]
	,[Update_Time]
	,[Update_By]
	)
	
	SELECT cd.Datekey
		  ,soe.SKU_ID
		  ,soe.BaseUnitQTY*cr.Convert_Rate*prod.Sale_Unit_Weight_KG/1000 AS Volumn_MT
		  ,cd.[Date]
		  ,cd.Monthkey
		  ,cd.Week_of_Month
		  ,GETDATE() AS [Create_Time]
		  ,OBJECT_NAME(@@PROCID) AS [Create_By]
		  ,GETDATE() AS [Update_Time]
		  ,OBJECT_NAME(@@PROCID) AS [Update_By]
	FROM ODS.ods.ERP_Sale_OrderEntry soe
	LEFT JOIN ODS.ods.ERP_Sale_Order so ON soe.SaleOrderID = so.SaleOrderID
	LEFT JOIN dm.Dim_Calendar cd ON CAST(so.[Date] AS DATE) = cd.[Date]
	LEFT JOIN dm.Dim_Product prod ON soe.SKU_ID = prod.SKU_ID
	LEFT JOIN dm.Dim_ERP_Unit_ConvertRate cr on cr.From_Unit = soe.BaseUnit AND cr.To_Unit = prod.Sale_Unit_CN
	WHERE Customer = '富平云商供应链管理有限公司'

END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
