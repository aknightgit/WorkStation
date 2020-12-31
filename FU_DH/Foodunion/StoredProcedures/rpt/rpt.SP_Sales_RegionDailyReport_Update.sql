USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [rpt].[SP_Sales_RegionDailyReport_Update]
AS
BEGIN

	EXEC [dm].[SP_Dim_SalesTerritory_Mapping_Monthly_Update];
	EXEC [dm].[SP_Dim_Store_SalesPerson_Monthly_Update];

	TRUNCATE TABLE rpt.Sales_销售区域达成日报;

	DROP TABLE IF EXISTS #tmp_sales;
	SELECT dbo.Split(st.Region_Director,' ',1) AS Director
		,st.Region
		,CASE WHEN ISNULL(st.Manager, '暂无') = '暂无' THEN 'Unassigned' ELSE st.Manager END AS Manager
		,CASE WHEN ISNULL(sp.Sales_Person,'') = '' THEN '' ELSE sp.Sales_Person END AS SalesPerson
		,ISNULL(s.Sales_Area_CN,'') AS Area
		,s.Store_Province AS Province
		,MAX(s.Store_City) AS City
		,MAX(CAST(si.TargetAmt AS decimal(9,2))) AS SellinTarget_Area
		,MAX(CAST(spt.SellInTarget_SP AS decimal(9,2))) AS SellInTarget_SP
		,SUM(CAST(jxt.InStock_QTY*pp.SKU_Price AS decimal(9,2))) AS SellIn
		,MAX(CAST(so.TargetAmt AS decimal(9,2))) AS SellOutTarget_Area
		,MAX(CAST(spt.SellOutTarget_SP AS decimal(9,2))) AS SellOutTarget_SP
		,SUM(CAST(jxt.Sale_Amount AS decimal(9,2))) AS SellOut
		--,SUM(dsi.Sales_AMT) AS SellOut_FromKA
	INTO #tmp_sales
	FROM [dm].[Dim_SalesTerritory_Mapping_Monthly] st
	JOIN [dm].[Dim_Store] s ON s.Store_Province LIKE '%'+st.Province_Short+'%' AND s.Channel_Account='YH'
	JOIN [dm].[Fct_YH_JXT_Daily] jxt ON s.Store_ID=jxt.Store_ID AND st.Monthkey = jxt.Datekey/100
	--LEFT JOIN [dm].[Fct_KAStore_DailySalesInventory] dsi ON s.Store_ID=dsi.Store_ID AND jxt.Datekey = dsi.Datekey AND jxt.SKU_ID=dsi.SKU_ID
	LEFT JOIN [dm].[Dim_Store_SalesPerson_Monthly] sp ON s.Store_ID=sp.Store_ID
	LEFT JOIN [dm].[Dim_Product_Pricelist] pp ON jxt.SKU_ID=pp.SKU_ID AND pp.Price_List_No='XSJMB0010'
	LEFT JOIN [dm].[Fct_Sales_SellInTarget_ByKAarea] si ON st.Monthkey = si.Monthkey AND s.Sales_Area_CN = si.Area AND si.KA = 'YH'
	LEFT JOIN [dm].[Fct_Sales_SellOutTarget_ByKAarea] so ON st.Monthkey = so.Monthkey AND s.Sales_Area_CN = so.Area AND so.KA = 'YH'
	LEFT JOIN (SELECT [Month],SalesPerson,SUM(CAST(Sellin AS decimal(9,2))) SellInTarget_SP,SUM(CAST(SellOut  AS decimal(9,2))) SellOutTarget_SP FROM ODS.[ods].[File_Sales_SellInOutTarget_byStore]
		GROUP BY [Month],SalesPerson) spt ON st.Monthkey = spt.[Month] AND sp.Sales_Person = spt.SalesPerson 
	--WHERE jxt.Datekey between 20200401 and 20200416
	GROUP BY st.Region_Director 
		,st.Region
		,CASE WHEN ISNULL(st.Manager, '暂无') = '暂无' THEN 'Unassigned' ELSE st.Manager END
		,CASE WHEN ISNULL(sp.Sales_Person,'') = '' THEN '' ELSE sp.Sales_Person END
		,s.Sales_Area_CN
		,s.Store_Province
	;
	--SELECT *FROM #tmp_sales ORDER BY 1 ,2

	--区域负责人
	DROP TABLE IF EXISTS #RegionDir;
	SELECT Director,Region,SUM(SellinTarget_Area) AS SellinTarget_Area,SUM(SellIn) AS SellIn, SUM(SellIn)/SUM(SellinTarget_Area) AS SellInAch
		,SUM(SellOutTarget_Area) AS SellOutTarget_Area,SUM(SellOut) AS SellOut, SUM(SellOut)/SUM(SellOutTarget_Area) AS SellOutAch
	INTO #RegionDir
	FROM(
		SELECT Director 
			,Region
			,Area 
			,MAX(SellinTarget_Area) AS SellinTarget_Area
			,SUM(SellIn) AS SellIn
			,MAX(SellOutTarget_Area) AS SellOutTarget_Area
			,SUM(SellOut) AS SellOut
		FROM #tmp_sales
		--WHERE 
		GROUP BY Director,Region,Area )a
	GROUP BY Director,Region 
	;
	--SELECT *FROM #RegionDir

	--区域经理
	DROP TABLE IF EXISTS #AreaMgr;
	SELECT Director,Manager,Area,SUM(SellinTarget_Area) AS SellinTarget_Area,SUM(SellIn) AS SellIn, SUM(SellIn)/SUM(SellinTarget_Area) AS SellInAch
		,SUM(SellOutTarget_Area) AS SellOutTarget_Area,SUM(SellOut) AS SellOut, SUM(SellOut)/SUM(SellOutTarget_Area) AS SellOutAch
	INTO #AreaMgr
	FROM(
		SELECT Director,Manager 
			,Area 
			,MAX(SellinTarget_Area) AS SellinTarget_Area
			,SUM(SellIn)  SellIn
			,MAX(SellOutTarget_Area) AS SellOutTarget_Area
			,SUM(SellOut) SellOut
		FROM #tmp_sales
		--WHERE SalesPerson='' AND Manager NOT IN (SELECT DISTINCT SalesPerson FROM #tmp_sales WHERE SalesPerson<>'')--OR Manager=SalesPerson
		WHERE Manager NOT IN (SELECT DISTINCT SalesPerson FROM #tmp_sales WHERE SalesPerson<>'')
		GROUP BY Director,Manager,Area 
	)b
	GROUP BY Director,Manager,Area 
	;
	--SELECT *FROM #AreaMgr

	--门店经理
	DROP TABLE IF EXISTS #SalesPerson;
	SELECT Director,Manager,SalesPerson,Area+'门店' AS Area,SUM(SellinTarget_SP) AS SellinTarget_SP,SUM(SellIn) AS SellIn, SUM(SellIn)/SUM(SellinTarget_SP) AS SellInAch
		,SUM(SellOutTarget_SP) AS SellOutTarget_SP,SUM(SellOut) AS SellOut, SUM(SellOut)/SUM(SellOutTarget_SP) AS SellOutAch
	INTO #SalesPerson
	FROM(
		SELECT Director,Manager,CASE WHEN SalesPerson = '' THEN Manager ELSE SalesPerson END AS SalesPerson
			,Area 
			,MAX(SellInTarget_SP) SellinTarget_SP
			,SUM(SellIn) AS SellIn
			,MAX(SellOutTarget_SP) SellOutTarget_SP
			,SUM(SellOut) AS SellOut
		FROM #tmp_sales
		WHERE SalesPerson<>'' OR Manager=SalesPerson
		GROUP BY Director,Manager,CASE WHEN SalesPerson = '' THEN Manager ELSE SalesPerson END,Area 
	)b
	GROUP BY Director,Manager,SalesPerson,Area 
	;
	--SELECT *FROM #SalesPerson

	INSERT INTO [rpt].[Sales_销售区域达成日报]
           ([Director]
           ,[Manager]
           ,[负责人]
           ,[负责区域]
           ,[Sell-in指标]
           ,[MTD Sell-In达成]
           ,[Sell-in Ach%]
           ,[Sell-Out指标]
           ,[MTD Sell-Out达成]
           ,[Sell-Out Ach%]
		   ,[Row_Attr]
           ,[Update_Time]
           ,[Update_By])
	SELECT Director,'',Director,Region
		,[dbo].[Format_Number2Thousand](SellinTarget_Area),[dbo].[Format_Number2Thousand](SellIn),CAST(CAST(ROUND(SellInAch*100,0) AS INT) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SellOutTarget_Area),[dbo].[Format_Number2Thousand](SellOut),CAST(CAST(ROUND(SellOutAch*100,0) AS INT) AS VARCHAR(5))+'%'
		,'bgcolor=#E6E6E6 align=left'
		,GETDATE(),'[rpt].[SP_Sales_RegionDailyReport_Update]' 
		FROM #RegionDir
	UNION
	SELECT Director,Manager,Manager,Area
		,[dbo].[Format_Number2Thousand](SellinTarget_Area),[dbo].[Format_Number2Thousand](SellIn),CAST(CAST(ROUND(SellInAch*100,0) AS INT) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SellOutTarget_Area),[dbo].[Format_Number2Thousand](SellOut),CAST(CAST(ROUND(SellOutAch*100,0) AS INT) AS VARCHAR(5))+'%'
		,''
		,GETDATE(),'[rpt].[SP_Sales_RegionDailyReport_Update]' 
		FROM #AreaMgr
	UNION
	SELECT Director,Manager,SalesPerson,Area
		,[dbo].[Format_Number2Thousand](SellinTarget_SP),[dbo].[Format_Number2Thousand](SellIn),CAST(CAST(ROUND(SellInAch*100,0) AS INT) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SellOutTarget_SP),[dbo].[Format_Number2Thousand](SellOut),CAST(CAST(ROUND(SellOutAch*100,0) AS INT) AS VARCHAR(5))+'%'
		,''
		,GETDATE(),'[rpt].[SP_Sales_RegionDailyReport_Update]' 
		FROM #SalesPerson
	UNION
	SELECT 'z' AS Director,'曹富贵' AS Manager,'曹富贵' AS SalesPerson,'全国' AS '负责区域'
		,[dbo].[Format_Number2Thousand](SUM(SellinTarget_Area)),[dbo].[Format_Number2Thousand](SUM([SellIn]))
		,CAST(CAST(ROUND(SUM([SellIn])/SUM(SellinTarget_Area)*100,0) AS INT) AS VARCHAR(5))+'%' 
		,[dbo].[Format_Number2Thousand](SUM(SellOutTarget_Area)),[dbo].[Format_Number2Thousand](SUM([SellOut]))
		,CAST(CAST(ROUND(SUM([SellOut])/SUM(SellOutTarget_Area)*100,0) AS INT) AS VARCHAR(5))+'%'
		,'bgcolor=#FFEFD8 align=left'
		,GETDATE(),'[rpt].[SP_Sales_RegionDailyReport_Update]'		
		FROM #RegionDir
   END



   /*
   
SELECT 
      [负责人]
      ,[负责区域]
      ,[Sell-in指标]
      ,[MTD Sell-In达成]
      ,[Sell-in Ach%]
      ,[Sell-Out指标]
      ,[MTD Sell-Out达成]
      ,[Sell-Out Ach%]
  FROM [rpt].[Sales_销售区域达成日报]
  WHERE [负责人] NOT IN ('Unassigned')
  ORDER BY Director DESC,Manager

  */
GO
