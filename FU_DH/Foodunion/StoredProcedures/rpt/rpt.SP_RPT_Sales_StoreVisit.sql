USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [rpt].[SP_RPT_Sales_StoreVisit]

  AS
BEGIN

	SELECT 
		'FXXK' AS SFA_Platform,
		v.ID AS V_ID,
		CONVERT(VARCHAR(8),Visit_Date,112) Datekey,
		Visit_Date,
		Checkin_Type AS Visit_Type,
		ds.Channel_Account,
		v.Store_ID,
		SalesPerson,
		SalesPerson_Account,
		Region,
		Store_Code,
		ds.Store_Name,
		ds.Store_Province,
		ds.Store_City,
		Checkin_Time,
		CheckOut_Time,
		Duration_Hrs,
		Duration_Mins,
		Longitude,
		Latitude,
		ds.SR_Level_1 AS Store_Owner,
		ds.Store_Type,
		ds.Sales_Region AS Sales_Region,
		ds.[Status] AS Store_Status		
	FROM dm.Fct_FXXK_KAStoreVisit v WITH(NOLOCK) 
	JOIN dm.Dim_Store ds WITH(NOLOCK) ON v.Store_ID=ds.Store_ID
	;
  


END

--select top 10 *from dm.Fct_FXXK_KAStoreVisit v WITH(NOLOCK) 
--select *from dm.Dim_Employee where Employee_No='FSUID_C2B254723FE85FBAD26935B8B67F3038'

--SELECT DATEKEY, COUNT(1) FROM dm.Fct_FXXK_KAStoreVisit v WITH(NOLOCK)  GROUP BY DATEKEY ORDER BY 1 DESC
GO
