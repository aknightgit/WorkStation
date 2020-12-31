USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [rpt].[SP_Sales_销售区域达成日报_Update]
AS
BEGIN

	EXEC [dm].[SP_Dim_SalesTerritory_Mapping_Monthly_Update];
	EXEC [dm].[SP_Dim_Store_SalesPerson_Monthly_Update];

	TRUNCATE TABLE rpt.Sales_销售区域达成日报;

	DROP TABLE IF EXISTS #tmp_sales;
	SELECT ISNULL(dbo.Split(st.Region_Director,' ',1)+'_'+st.Region,st.Region_Director+'_'+st.Region) AS Director
		,st.Region
		,CASE WHEN ISNULL(st.Manager, '暂无') = '暂无' THEN 'Unassigned' ELSE st.Manager END AS Manager
		,CASE WHEN ISNULL(sp.Sales_Person,'') = '' THEN '' ELSE sp.Sales_Person END AS SalesPerson
		,ISNULL(s.Sales_Area_CN,'') AS Area
		,s.Store_Province AS Province
		,s.Store_City AS City
		,MAX(CAST(si.TargetAmt AS decimal(9,2))) AS SellinTarget_Area
		,MAX(CAST(spt.SellInTarget_SP AS decimal(9,2))) AS SellInTarget_SP
		,SUM(CAST(jxt.InStock_QTY*pp.SKU_Price AS decimal(9,2))) AS SellIn
		,SUM(CAST((CASE WHEN Datekey=CONVERT(VARCHAR(8),GETDATE()-1,112)THEN jxt.InStock_QTY ELSE 0 END)*pp.SKU_Price AS decimal(9,2))) AS SellIn_Previous
		,MAX(CAST(so.TargetAmt AS decimal(9,2))) AS SellOutTarget_Area
		,MAX(CAST(spt.SellOutTarget_SP AS decimal(9,2))) AS SellOutTarget_SP
		,SUM(CAST(jxt.Sale_Amount AS decimal(9,2))) AS SellOut
		,SUM(CAST((CASE WHEN Datekey=CONVERT(VARCHAR(8),GETDATE()-1,112)THEN jxt.Sale_Amount ELSE 0 END) AS decimal(9,2))) AS SellOut_Previous
		,'        ' AS Ignore_Tag
		--,SUM(dsi.Sales_AMT) AS SellOut_FromKA
	INTO #tmp_sales
	FROM [dm].[Dim_SalesTerritory_Mapping_Monthly] st WITH(NOLOCK)
	JOIN [dm].[Dim_Store] s WITH(NOLOCK) ON s.Store_Province LIKE '%'+st.Province_Short+'%' AND s.Channel_Account='YH'
	LEFT JOIN [dm].[Fct_YH_JXT_Daily] jxt WITH(NOLOCK) ON s.Store_ID=jxt.Store_ID AND st.Monthkey = jxt.Datekey/100                                           --为保证全国销量采用外关联   Justin 2020-05-08
	--LEFT JOIN [dm].[Fct_KAStore_DailySalesInventory] dsi ON s.Store_ID=dsi.Store_ID AND jxt.Datekey = dsi.Datekey AND jxt.SKU_ID=dsi.SKU_ID
	LEFT JOIN [dm].[Dim_Store_SalesPerson_Monthly] sp WITH(NOLOCK) ON sp.Monthkey=st.Monthkey AND (s.Store_ID=sp.Store_ID OR sp.Store_ID = s.Store_City)
	LEFT JOIN [dm].[Dim_Product_Pricelist] pp WITH(NOLOCK) ON jxt.SKU_ID=pp.SKU_ID AND pp.Price_List_No=(SELECT TOP 1 Price_List_No FROM dm.Dim_ERP_CustomerList where Customer_Name = '富平云商供应链管理有限公司')
	LEFT JOIN [dm].[Fct_Sales_SellInTarget_ByKAarea] si WITH(NOLOCK) ON st.Monthkey = si.Monthkey AND s.Sales_Area_CN = si.Area AND si.KA = 'YH' --AND si.Area<>'其他'
	LEFT JOIN [dm].[Fct_Sales_SellOutTarget_ByKAarea] so WITH(NOLOCK) ON st.Monthkey = so.Monthkey AND s.Sales_Area_CN = so.Area AND so.KA = 'YH' --AND so.Area<>'其他'
	LEFT JOIN (SELECT [Month],SalesPerson,SUM(CAST(Sellin AS decimal(9,2))) SellInTarget_SP,SUM(CAST(SellOut  AS decimal(9,2))) SellOutTarget_SP 
		FROM ODS.[ods].[File_Sales_SellInOutTarget_byStore]  WITH(NOLOCK)
		GROUP BY [Month],SalesPerson) spt ON st.Monthkey = spt.[Month] AND sp.Sales_Person = spt.SalesPerson 
	--WHERE jxt.Datekey between 20200401 and 20200416
	WHERE st.Monthkey = CONVERT(VARCHAR(6),GETDATE()-1,112)
	GROUP BY ISNULL(dbo.Split(st.Region_Director,' ',1)+'_'+st.Region,st.Region_Director+'_'+st.Region)
		,st.Region
		,CASE WHEN ISNULL(st.Manager, '暂无') = '暂无' THEN 'Unassigned' ELSE st.Manager END
		,CASE WHEN ISNULL(sp.Sales_Person,'') = '' THEN '' ELSE sp.Sales_Person END
		,s.Sales_Area_CN
		,s.Store_Province
		,s.Store_City
	;
	--SELECT * FROM #tmp_sales ORDER BY 1 

	--UPDATE #tmp_sales SET SellinTarget_Area=NULL,SellOutTarget_Area=NULL WHERE Area='其他' AND Region<>'南区';
	--如果该市，有指定的市级负责人，则忽略其他人的sellout金额汇总
	UPDATE t
		SET t.Ignore_Tag = CASE WHEN t.SalesPerson<>sp.Sales_Person THEN 'Ignore' ELSE t.City END
	FROM #tmp_sales t
	JOIN [dm].[Dim_Store_SalesPerson_Monthly] sp ON sp.Monthkey=CONVERT(VARCHAR(6),GETDATE()-1,112) and Channel='YH' AND t.City=sp.Store_ID
	--WHERE t.SalesPerson<>sp.Sales_Person
	--SELECT *FROM #tmp_sales ORDER BY 1 ,2

	--区域负责人
	DROP TABLE IF EXISTS #RegionDir;
	SELECT Director,Region,SUM(SellinTarget_Area) AS SellinTarget_Area,SUM(SellIn) AS SellIn, SUM(SellIn)/SUM(SellInTarget_Area) AS SellInAch
	    ,SUM(SellIn_Previous) AS SellIn_Previous, SUM(SellIn_Previous)/SUM(SellInTarget_Area) AS SellIn_PreviousAch
		,SUM(SellOutTarget_Area) AS SellOutTarget_Area,SUM(SellOut) AS SellOut, SUM(SellOut)/SUM(SellOutTarget_Area) AS SellOutAch
		,SUM(SellOut_Previous) AS SellOut_Previous, SUM(SellOut_Previous)/SUM(SellOutTarget_Area) AS SellOut_PreviousAch
	INTO #RegionDir
	FROM(
		SELECT Director 
			,Region
			,Area 
			,MAX(CASE WHEN Area='其他' THEN NULL ELSE SellinTarget_Area END) AS SellinTarget_Area
			,SUM(SellIn) AS SellIn
			,SUM(SellIn_Previous) AS SellIn_Previous
			,MAX(CASE WHEN Area='其他' THEN NULL ELSE SellOutTarget_Area END) AS SellOutTarget_Area
			,SUM(SellOut) AS SellOut
			,SUM(SellOut_Previous) AS SellOut_Previous
		FROM #tmp_sales
		WHERE Ignore_Tag <> 'Ignore'
		GROUP BY Director,Region,Area 
		UNION
		SELECT NULL
			,'其他'
			,'其他'
			,MAX(SellinTarget_Area)
			,NULL 
			,NULL
			,MAX(SellOutTarget_Area)
			,NULL		
			,NULL
		FROM #tmp_sales
		WHERE Area='其他'
		)a
	GROUP BY Director,Region 
	;
	--SELECT * FROM #RegionDir

	--区域经理
	DROP TABLE IF EXISTS #AreaMgr;
	SELECT Director,Manager,Area,SUM(SellinTarget_Area) AS SellinTarget_Area,SUM(SellIn) AS SellIn, 
		CASE WHEN SUM(SellinTarget_Area)=0 THEN NULL ELSE SUM(SellIn)/SUM(SellinTarget_Area) END AS SellInAch
		,SUM(SellIn_Previous) AS SellIn_Previous
		,CASE WHEN SUM(SellInTarget_Area)=0 THEN NULL ELSE SUM(SellIn_Previous)/SUM(SellInTarget_Area) END AS SellIn_PreviousAch
		,SUM(SellOutTarget_Area) AS SellOutTarget_Area,SUM(SellOut) AS SellOut
		,CASE WHEN SUM(SellOutTarget_Area)=0 THEN NULL ELSE SUM(SellOut)/SUM(SellOutTarget_Area) END AS SellOutAch
		,SUM(SellOut_Previous) AS SellOut_Previous
		,CASE WHEN SUM(SellOutTarget_Area)=0 THEN NULL ELSE SUM(SellOut_Previous)/SUM(SellOutTarget_Area) END AS SellOut_PreviousAch
	INTO #AreaMgr
	FROM(
		SELECT Director,Manager 
			,Area 
			,MAX(CASE WHEN Area='其他' THEN NULL ELSE SellinTarget_Area END) AS SellinTarget_Area
			,SUM(SellIn)  SellIn
			,SUM(SellIn_Previous) AS SellIn_Previous
			,MAX(CASE WHEN Area='其他' THEN NULL ELSE SellOutTarget_Area END) AS SellOutTarget_Area
			,SUM(SellOut) SellOut
			,SUM(SellOut_Previous) AS SellOut_Previous
		FROM #tmp_sales
		--WHERE SalesPerson='' AND Manager NOT IN (SELECT DISTINCT SalesPerson FROM #tmp_sales WHERE SalesPerson<>'')--OR Manager=SalesPerson
		WHERE Manager NOT IN (SELECT DISTINCT SalesPerson FROM #tmp_sales WHERE SalesPerson<>'')
		AND Ignore_Tag <> 'Ignore'
		GROUP BY Director,Manager,Area 
		UNION
		SELECT NULL
			,'Unassigned'
			,'其他'
			,MAX(SellinTarget_Area)
			,NULL 
			,NULL
			,MAX(SellOutTarget_Area)
			,NULL		
			,NULL	
		FROM #tmp_sales
		WHERE Area='其他'
	)b
	GROUP BY Director,Manager,Area 
	;
	--SELECT *FROM #AreaMgr ORDER BY 1,2,3

	--门店经理
	DROP TABLE IF EXISTS #SalesPerson;
	SELECT Director,Manager,SalesPerson
		,CASE WHEN City<>'' THEN Area+City ELSE Area+'门店' END AS Area
		,SUM(SellinTarget_SP) AS SellinTarget_SP,SUM(SellIn) AS SellIn, SUM(SellIn)/SUM(SellinTarget_SP) AS SellInAch
		,SUM(SellIn_Previous) AS SellIn_Previous, SUM(SellIn_Previous)/SUM(SellinTarget_SP) AS SellIn_PreviousAch
		,SUM(SellOutTarget_SP) AS SellOutTarget_SP,SUM(SellOut) AS SellOut, SUM(SellOut)/SUM(SellOutTarget_SP) AS SellOutAch
		,SUM(SellOut_Previous) AS SellOut_Previous, SUM(SellOut_Previous)/SUM(SellOutTarget_SP) AS SellOut_PreviousAch
	INTO #SalesPerson
	FROM(
		SELECT Director,Manager,CASE WHEN SalesPerson = '' THEN Manager ELSE SalesPerson END AS SalesPerson
			,Area 
			,MAX(SellInTarget_SP) SellinTarget_SP
			,SUM(SellIn) AS SellIn
			,SUM(SellIn_Previous) AS SellIn_Previous
			,MAX(SellOutTarget_SP) SellOutTarget_SP
			,SUM(SellOut) AS SellOut
			,SUM(SellOut_Previous) AS SellOut_Previous
			,MAX(CASE WHEN Ignore_Tag = 'Ignore' THEN '' ELSE Ignore_Tag END) AS City
		FROM #tmp_sales
		WHERE SalesPerson<>'' OR Manager=SalesPerson
		GROUP BY Director,Manager,CASE WHEN SalesPerson = '' THEN Manager ELSE SalesPerson END,Area
	)b
	GROUP BY Director,Manager,SalesPerson,Area ,City
	;
	--SELECT *FROM #SalesPerson

	--MTDT
	DROP TABLE IF EXISTS #MTDT;
	SELECT RTRIM(CAST(CAST(CAST(Current_Day AS FLOAT)*100/END_DAY AS  decimal(18,0)) AS  VARCHAR(5))+'%')  AS MTDT INTO #MTDT
	FROM(SELECT CAST(RIGHT(MAX(JXT.Datekey),2) AS INT) AS Current_Day,DAY(MAX(End_of_Month)) AS END_DAY FROM [dm].[Fct_YH_JXT_Daily] JXT
	LEFT JOIN [dm].[Dim_Calendar] CD
	ON JXT.Datekey=CD.Datekey) T;

	INSERT INTO [rpt].[Sales_销售区域达成日报]
           ([Director]
		  ,[Manager]
		  ,[负责人]
		  ,[负责区域]
		  ,[MTDT]
		  ,[Sell-in指标]
		  ,[MTD Sell-In达成]
		  ,[Sell-in Ach%]
		  ,[Previous Day Sell-In]
		  ,[Previous Day Sell-In delta%]
		  ,[Sell-Out指标]
		  ,[MTD Sell-Out达成]
		  ,[Sell-Out Ach%]
		  ,[Previous Day Sell-Out]
		  ,[Previous Day Sell-Out delta%]
		  ,[Row_Attr]
		  ,[Update_Time]
		  ,[Update_By])
	SELECT Director,''
		,CASE WHEN [Director] LIKE '杨谦%' THEN '' ELSE coalesce(dbo.split(Director,'_',1),Director,'Unassigned') END,Region,MTDT                          
		,[dbo].[Format_Number2Thousand](SellinTarget_Area),[dbo].[Format_Number2Thousand](SellIn),CAST(CAST(ROUND(SellInAch*100,0) AS INT) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SellIn_Previous),CAST(CAST(ROUND(SellIn_PreviousAch*100,5) AS decimal(19,1)) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SellOutTarget_Area),[dbo].[Format_Number2Thousand](SellOut),CAST(CAST(ROUND(SellOutAch*100,0) AS INT) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SellOut_Previous),CAST(CAST(ROUND(SellOut_PreviousAch*100,5) AS decimal(19,1)) AS VARCHAR(5))+'%'
		,'bgcolor='+ CASE WHEN [Director] LIKE '杨谦%' THEN '#F5F5F5' ELSE '#FFF8DC' END+' align=left style="font-weight:bold;"'
		,GETDATE(),'[rpt].[SP_Sales_RegionDailyReport_Update]' 
		FROM #RegionDir A
		LEFT JOIN #MTDT B ON 1=1
		WHERE A.Region <> '其他'
	UNION
	SELECT Director,Manager,ISNULL(Manager,'Unassigned'),Area,MTDT 
		,[dbo].[Format_Number2Thousand](SellinTarget_Area),[dbo].[Format_Number2Thousand](SellIn),CAST(CAST(ROUND(SellInAch*100,0) AS INT) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SellIn_Previous),CAST(CAST(ROUND(SellIn_PreviousAch*100,5) AS decimal(19,1)) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SellOutTarget_Area),[dbo].[Format_Number2Thousand](SellOut),CAST(CAST(ROUND(SellOutAch*100,0) AS INT) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SellOut_Previous),CAST(CAST(ROUND(SellOut_PreviousAch*100,5) AS decimal(19,1)) AS VARCHAR(5))+'%'
		,''
		,GETDATE(),'[rpt].[SP_Sales_RegionDailyReport_Update]' 
		FROM #AreaMgr A
		LEFT JOIN #MTDT B ON 1=1
	UNION
	-- 对于同一个人，可能跨区负责不同的门店，允许多区域
	SELECT Director
		,MAX(Manager)
		,isnull(SalesPerson,'Unassigned')
		,REPLACE(string_agg(Area,','),'门店,','')
		,MAX(MTDT)
		,[dbo].[Format_Number2Thousand](MAX(SellinTarget_SP))
		,[dbo].[Format_Number2Thousand](SUM(SellIn))
		,CAST(CAST(ROUND(SUM(SellIn)*100/MAX(SellinTarget_SP),0) AS INT) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SUM(SellIn_Previous))
		,CAST(CAST(ROUND(SUM(SellIn_Previous)*100/MAX(SellinTarget_SP),5) AS decimal(19,1)) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](MAX(SellOutTarget_SP))
		,[dbo].[Format_Number2Thousand](SUM(SellOut))
		,CAST(CAST(ROUND(SUM(SellOut)*100/MAX(SellOutTarget_SP),0) AS INT) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SUM(SellOut_Previous))
		,CAST(CAST(ROUND(SUM(SellOut_Previous)*100/MAX(SellOutTarget_SP),5) AS decimal(19,1)) AS VARCHAR(5))+'%'
		,''
		,GETDATE(),'[rpt].[SP_Sales_RegionDailyReport_Update]' 
		FROM #SalesPerson A
		LEFT JOIN #MTDT B ON 1=1
		GROUP BY Director,isnull(SalesPerson,'Unassigned')
	UNION
	SELECT 'z' AS Director,'全国' AS Manager,'全国' AS SalesPerson,'全国' AS '负责区域',MAX(MTDT)
		,[dbo].[Format_Number2Thousand](SUM(SellinTarget_Area)),[dbo].[Format_Number2Thousand](SUM([SellIn]))
		,CAST(CAST(ROUND(SUM([SellIn])/SUM(SellinTarget_Area)*100,0) AS INT) AS VARCHAR(5))+'%' 
		,[dbo].[Format_Number2Thousand](SUM(SellIn_Previous)),CAST(CAST(ROUND(SUM(SellIn_Previous)/SUM(SellinTarget_Area)*100,5) AS decimal(19,1)) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SUM(SellOutTarget_Area)),[dbo].[Format_Number2Thousand](SUM([SellOut]))
		,CAST(CAST(ROUND(SUM([SellOut])/SUM(SellOutTarget_Area)*100,0) AS INT) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SUM(SellOut_Previous)),CAST(CAST(ROUND(SUM(SellOut_Previous)/SUM(SellOutTarget_Area)*100,5) AS decimal(19,1)) AS VARCHAR(5))+'%'
		,'bgcolor=#FFEFD8 align=left style="font-weight:bold;"'
		,GETDATE(),'[rpt].[SP_Sales_RegionDailyReport_Update]'		
		FROM #RegionDir A
		LEFT JOIN #MTDT B ON 1=1
	UNION		--杨谦单独一区 North&West
	SELECT '杨谦汇总' AS Director,'' AS Manager,'杨谦' AS SalesPerson,'北区&西区' AS '负责区域',MAX(MTDT)
		,[dbo].[Format_Number2Thousand](SUM(SellinTarget_Area)),[dbo].[Format_Number2Thousand](SUM([SellIn]))
		,CAST(CAST(ROUND(SUM([SellIn])/SUM(SellinTarget_Area)*100,0) AS INT) AS VARCHAR(5))+'%' 
		,[dbo].[Format_Number2Thousand](SUM(SellIn_Previous)),CAST(CAST(ROUND(SUM(SellIn_Previous)/SUM(SellinTarget_Area)*100,5) AS decimal(19,1)) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SUM(SellOutTarget_Area)),[dbo].[Format_Number2Thousand](SUM([SellOut]))
		,CAST(CAST(ROUND(SUM([SellOut])/SUM(SellOutTarget_Area)*100,0) AS INT) AS VARCHAR(5))+'%'
		,[dbo].[Format_Number2Thousand](SUM(SellOut_Previous)),CAST(CAST(ROUND(SUM(SellOut_Previous)/SUM(SellOutTarget_Area)*100,5) AS decimal(19,1)) AS VARCHAR(5))+'%'
		,'bgcolor=#FFF8DC align=left style="font-weight:bold;"'
		,GETDATE(),'[rpt].[SP_Sales_RegionDailyReport_Update]'		
		FROM #RegionDir A
		LEFT JOIN #MTDT B ON 1=1
		WHERE Director LIKE '杨谦%'
		;
 END

    /****************************************

   更改单元格字体格式借用 CSS 方法：
   style="font-weight:bold;text-decoration:underline;"
   font-weight:bold;  字体加粗
   text-decoration:underline;  加下划线
   color:#00F;  字体颜色（RGB颜色值）
   font-style:italic;  斜体   font-style:oblique; 字体倾斜
   background:#00F  背景颜色

  ******************************************/


/*
SELECT 
      [负责人]
      ,[负责区域]
	  ,[MTDT]
      ,[Sell-in指标]
      ,[MTD Sell-In达成]
      ,[Sell-in Ach%]
      ,[Sell-Out指标]
      ,[MTD Sell-Out达成]
      ,[Sell-Out Ach%]
  FROM [rpt].[Sales_销售区域达成日报]
  WHERE [负责人] NOT IN ('Unassigned')
  ORDER BY Director DESC,Manager,[负责区域]

  */
GO
