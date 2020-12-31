USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [rpt].[SP_RPT_Qulouxia_Store_Daily_Avg]
AS
BEGIN


	DECLARE @MAX_DateKey VARCHAR(8) = (SELECT MAX(DATEKEY) FROM [dm].[Fct_Qulouxia_Sales])

---------------------使用新存储过程计算平均
	DROP TABLE IF EXISTS #Mapping
	SELECT DISTINCT cal.Datekey AS Date_ID
		  ,st.store_id
		  ,acm.SKU_ID
	INTO #Mapping
	FROM ODS.ods.[File_Qulouxia_Store_SKU_Mapping] skm
	LEFT JOIN [dm].[Dim_Product_AccountCodeMapping] acm ON skm.SKU_Code = acm.SKU_Code AND Account = 'ZBox'
	LEFT JOIN dm.Dim_Store st ON skm.Store_Code = st.Account_Store_Code AND st.Channel_Account = 'Zbox'
	CROSS JOIN dm.Dim_Calendar cal 
	where CAL.Datekey BETWEEN skm.Begin_Date AND ISNULL(skm.End_Date,@MAX_DateKey) AND st.store_id IS NOT NULL

	SELECT ISNULL(mp.Date_ID,qs.DATEKEY) AS DATEKEY
		  ,ISNULL(mp.SKU_ID,qs.SKU_ID) AS SKU_ID
		  ,st.Store_Type
		--  ,ISNULL(mp.Store_ID,qs.Store_ID) AS Store_ID
		  ,SUM(Payment) AS Payment
		  ,COUNT(DISTINCT ISNULL(mp.Store_ID,qs.Store_ID)) AS Store_cnt
		  ,SUM(Payment)/COUNT(DISTINCT ISNULL(mp.Store_ID,qs.Store_ID)) AS Sales_SKU_avg
	INTO #AVG_SKU_STORE_TYPE
	FROM #Mapping mp
	FULL OUTER JOIN (SELECT DATEKEY,Store_ID,SKU_ID,Payment FROM dm.Fct_Qulouxia_Sales WHERE Order_Status <> '已取消') qs ON mp.Date_ID = qs.DATEKEY AND mp.Store_ID = qs.Store_ID AND mp.SKU_ID = qs.SKU_ID
	LEFT JOIN dm.Dim_Store st ON ISNULL(mp.Store_ID,qs.Store_ID) = st.Store_ID
	GROUP BY ISNULL(mp.Date_ID,qs.DATEKEY),ISNULL(mp.SKU_ID,qs.SKU_ID),st.Store_Type

	SELECT DATEKEY
		  ,Store_Type AS Account_Store_Type
		  ,SUM(Payment) AS Payment
		  ,SUM(Sales_SKU_avg) AS Sales_SKU_avg
	--	  ,AVG(Store_cnt) AS Store_cnt
	FROM #AVG_SKU_STORE_TYPE

	GROUP BY DATEKEY
		    ,Store_Type

END

GO
