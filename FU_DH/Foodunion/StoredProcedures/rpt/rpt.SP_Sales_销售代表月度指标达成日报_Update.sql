USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [rpt].[SP_Sales_销售代表月度指标达成日报_Update]
AS
BEGIN

	EXEC [dm].[SP_Dim_SalesTerritory_Mapping_Monthly_Update];
	--EXEC [dm].[SP_Dim_Store_SalesPerson_Monthly_Update];
	
	DECLARE @currMonth INT = CONVERT(VARCHAR(6),GETDATE()-1,112);
	DROP TABLE IF EXISTS #tmpSales;
	SELECT a.Region,a.Region_Director,a.Area,a.Manager,b.SalesPerson
		
		,SUM(b.SellIn_TGT) AS SellIn_TGT
		,SUM(b.SellIn_MTD) AS SellIn_MTD
		,SUM(b.SellOut_TGT) AS SellOut_TGT
		,SUM(b.SellOut_MTD) AS SellOut_MTD
		,SUM(b.SellOut_TGT_A) AS SellOut_TGT_A
		,SUM(b.SellOut_MTD_A) AS SellOut_MTD_A
		,SUM(b.SellOut_TGT_F) AS SellOut_TGT_F
		,SUM(b.SellOut_MTD_F) AS SellOut_MTD_F
		,SUM(b.SellOut_TGTSKU_A) AS SellOut_TGTSKU_A
		,SUM(b.SellOut_SKUCnt_A) AS SellOut_SKUCnt_A
		,SUM(b.SellOut_TGTSKU_F) AS SellOut_TGTSKU_F
		,SUM(b.SellOut_SKUCnt_F) AS SellOut_SKUCnt_F
	INTO #tmpSales
	FROM (
		SELECT DISTINCT Region,Region_Director,Province_Short,Area,ISNULL(Manager,Province_Short) AS Manager
		FROM dm.Dim_SalesTerritory_Mapping_Monthly WITH(NOLOCK)
		WHERE Monthkey=@currMonth
		--AND Manager IS NOT NULL
	)a
	JOIN (SELECT ds.Province_Short
		,ISNULL(sp.Sales_Person,'') AS SalesPerson

		,SUM(tgt.SellIn_TGT) AS SellIn_TGT
		,SUM(jxt.SellIn_MTD) AS SellIn_MTD

		,SUM(tgt.SellOut_TGT) AS SellOut_TGT
		,SUM(tgt.SellOut_TGT_A) AS SellOut_TGT_A
		,SUM(tgt.SellOut_TGT_F) AS SellOut_TGT_F		
		,SUM(tgt.SellOut_TGTSKU_A) AS SellOut_TGTSKU_A
		,SUM(tgt.SellOut_TGTSKU_F) AS SellOut_TGTSKU_F

		,SUM(ka.Sales_AMT) AS SellOut_MTD
		,SUM(ka.SellOut_MTD_A) AS SellOut_MTD_A
		,SUM(ka.SellOut_MTD_F) AS SellOut_MTD_F
		,SUM(ka.SellOut_SKUCnt) AS SellOut_SKUCnt
		,SUM(ka.SellOut_SKUCnt_A) AS SellOut_SKUCnt_A
		,SUM(ka.SellOut_SKUCnt_F) AS SellOut_SKUCnt_F
		--,
		FROM [dm].[Dim_Store] ds WITH(NOLOCK) 
		LEFT JOIN (SELECT * FROM [dm].[Fct_Sales_SellInOutTarget_byStore] WHERE Monthkey=@currMonth) tgt 
			ON tgt.Store_ID=ds.Store_ID
		LEFT JOIN (SELECT * FROM [dm].[Dim_Store_SalesPerson_Monthly] WHERE Monthkey=@currMonth) sp  
			ON  tgt.Store_Code=sp.Store_Code  --取这个版本的门店负责人
		LEFT JOIN (SELECT ka.Store_ID,
				 SUM(CASE WHEN p.Product_Sort='Ambient' THEN ka.Sales_AMT ELSE 0 END) AS SellOut_MTD_A,
				 SUM(CASE WHEN p.Product_Sort='Fresh' THEN ka.Sales_AMT ELSE 0 END) AS SellOut_MTD_F,
				 SUM(ka.Sales_AMT) AS Sales_AMT,
				 COUNT(DISTINCT CASE WHEN p.Product_Sort='Ambient' AND ka.Sales_Qty>0 AND CHARINDEX('_0',ka.SKU_ID)=0 THEN ka.SKU_ID ELSE NULL END) AS SellOut_SKUCnt_A,
				 COUNT(DISTINCT CASE WHEN p.Product_Sort='Fresh' AND ka.Sales_Qty>0 AND CHARINDEX('_0',ka.SKU_ID)=0 THEN ka.SKU_ID ELSE NULL END) AS SellOut_SKUCnt_F,
				 COUNT(DISTINCT LEFT(ka.SKU_ID,7)) AS SellOut_SKUCnt
			FROM dm.Fct_KAStore_DailySalesInventory ka WITH(NOLOCK) 
			JOIN dm.Dim_Product p WITH(NOLOCK) ON ka.SKU_ID=p.SKU_ID
			WHERE ka.Datekey/100=@currMonth
			AND ka.Store_ID LIKE 'YH%' 
			--WHERE ka.Datekey between 20200801 and 20200802		
			--and ka.Store_ID IN (select top 19 Store_ID from [dm].[Fct_Sales_SellInOutTarget_byStore] where SalesPerson='蔡文亮')
			GROUP BY ka.Store_ID	
			)ka
			ON ds.Store_ID = ka.Store_ID --AND tgt.Monthkey=ka.Datekey/100
		LEFT JOIN (SELECT jxt.Store_ID,
				SUM(CAST(jxt.InStock_QTY*pp.SKU_Price AS decimal(9,2))) AS SellIn_MTD
			FROM [dm].[Fct_YH_JXT_Daily] jxt WITH(NOLOCK) 
			LEFT JOIN [dm].[Dim_Product_Pricelist] pp WITH(NOLOCK) ON jxt.SKU_ID=pp.SKU_ID AND pp.Price_List_No=
				(SELECT TOP 1 Price_List_No FROM dm.Dim_ERP_CustomerList WITH(NOLOCK) where Customer_Name = '富平云商供应链管理有限公司')
			WHERE jxt.Datekey/100=@currMonth
			GROUP BY jxt.Store_ID  
			)jxt 
			ON jxt.Store_ID = ds.Store_ID
		WHERE --tgt.Monthkey=@currMonth AND 
		ds.Channel_Account='YH'
		--AND tgt.SalesPerson IS NOT NULL
		GROUP BY ds.Province_Short,ISNULL(sp.Sales_Person,'')
		--HAVING (sum(tgt.SellOut_TGT)+sum(tgt.SellOut_TGT_A)+sum(tgt.SellOut_TGT_F)>0)
	)b ON a.Province_Short=b.Province_Short
	
	GROUP BY  a.Region,a.Region_Director,a.Area,a.Manager,b.SalesPerson
	ORDER BY 1,2,3,4,5
	;
	--SELECT *FROM #tmpSales;

	TRUNCATE TABLE [rpt].[Sales_销售代表月度指标达成日报];

	INSERT INTO [rpt].[Sales_销售代表月度指标达成日报]
           ([Region]
           ,[Director]
           ,[Manager],[Manager_Display],[RN]
           ,[SalesPerson]
           ,[进货目标]
           ,[进货实际]
           ,[进货达成%]
           ,[POS目标]
           ,[POS实际]
           ,[POS达成%]
           ,[常温目标]
           ,[常温实际]
           ,[常温达成%]
           ,[低温目标]
           ,[低温实际]
           ,[低温达成%]
           ,[常温SKU数目标]
           ,[常温SKU数实际]
           ,[常温SKU数达成%]
           ,[低温SKU数目标]
           ,[低温SKU数实际]
           ,[低温SKU数达成%]
           ,[Row_Attr]
           ,[Update_Time]
           ,[Update_By])
		--门店代表
	SELECT	Region,Region_Director,Manager,'',ROW_NUMBER() OVER(PARTITION BY Region_Director,Manager ORDER BY SalesPerson),
		SalesPerson,
		[dbo].[Format_Number2Thousand](SellIn_TGT),[dbo].[Format_Number2Thousand](SellIn_MTD),
		CASE WHEN (SellIn_TGT)=0 THEN '-' ELSE CAST(CAST(ROUND(SellIn_MTD*100.0/SellIn_TGT,0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SellOut_TGT),[dbo].[Format_Number2Thousand](SellOut_MTD)
		,CASE WHEN SellOut_TGT=0 THEN '-' ELSE CAST(CAST(ROUND(SellOut_MTD*100.0/SellOut_TGT,0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SellOut_TGT_A),[dbo].[Format_Number2Thousand](SellOut_MTD_A)
		,CASE WHEN SellOut_TGT_A=0 THEN '-' ELSE CAST(CAST(ROUND(SellOut_MTD_A*100.0/SellOut_TGT_A,0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SellOut_TGT_F),[dbo].[Format_Number2Thousand](SellOut_MTD_F)
		,CASE WHEN SellOut_TGT_F=0 THEN '-' ELSE CAST(CAST(ROUND(SellOut_MTD_F*100.0/SellOut_TGT_F,0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SellOut_TGTSKU_A),[dbo].[Format_Number2Thousand](SellOut_SKUCnt_A)
		,CASE WHEN SellOut_TGTSKU_A=0 THEN '-' ELSE CAST(CAST(ROUND(SellOut_SKUCnt_A*100.0/SellOut_TGTSKU_A,0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SellOut_TGTSKU_F),[dbo].[Format_Number2Thousand](SellOut_SKUCnt_F)
		,CASE WHEN SellOut_TGTSKU_F=0 THEN '-' ELSE CAST(CAST(ROUND(SellOut_SKUCnt_F*100.0/SellOut_TGTSKU_F,0) AS INT) AS VARCHAR(5))+'%' END,
		'',
		GETDATE(),'[rpt].[SP_Sales_销售代表月度指标达成日报_Update]'		
	FROM #tmpSales
	UNION  --区域代表
	SELECT	Region,Region_Director,a.Manager,a.Manager,0,'',
		[dbo].[Format_Number2Thousand](MAX(Tgt)),[dbo].[Format_Number2Thousand](SUM(SellIn_MTD)),
		CASE WHEN MAX(Tgt)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellIn_MTD)*100.0/MAX(Tgt),0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGT)),[dbo].[Format_Number2Thousand](SUM(SellOut_MTD))
		,CASE WHEN SUM(SellOut_TGT)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_MTD)*100.0/SUM(SellOut_TGT),0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGT_A)),[dbo].[Format_Number2Thousand](SUM(SellOut_MTD_A))
		,CASE WHEN SUM(SellOut_TGT_A)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_MTD_A)*100.0/SUM(SellOut_TGT_A),0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGT_F)),[dbo].[Format_Number2Thousand](SUM(SellOut_MTD_F))
		,CASE WHEN SUM(SellOut_TGT_F)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_MTD_F)*100.0/SUM(SellOut_TGT_F),0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGTSKU_A)),[dbo].[Format_Number2Thousand](SUM(SellOut_SKUCnt_A))
		,CASE WHEN SUM(SellOut_TGTSKU_A)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_SKUCnt_A)*100.0/SUM(SellOut_TGTSKU_A),0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGTSKU_F)),[dbo].[Format_Number2Thousand](SUM(SellOut_SKUCnt_F))
		,CASE WHEN SUM(SellOut_TGTSKU_F)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_SKUCnt_F)*100.0/SUM(SellOut_TGTSKU_F),0) AS INT) AS VARCHAR(5))+'%' END,
		'align=left style="font-weight:bold;"',
		GETDATE(),'[rpt].[SP_Sales_销售代表月度指标达成日报_Update]'		
	FROM #tmpSales a
	LEFT JOIN (
		SELECT ISNULL(stm.Manager,s.Area) AS Manager,SUM(s.TargetAmt) AS Tgt
		FROM [dm].[Fct_Sales_SellInTarget_ByKAarea] s
		JOIN (SELECT DISTINCT Area,Manager FROM dm.Dim_SalesTerritory_Mapping_Monthly WHERE Monthkey=@currMonth) stm ON s.Area=stm.Area AND s.KA='YH'
		WHERE s.Monthkey=@currMonth
		GROUP BY ISNULL(stm.Manager,s.Area))si ON a.Manager=si.Manager
	GROUP BY a.Region,a.Region_Director,a.Manager
	
	UNION  --大区汇总
	
	SELECT Region,Region_Director,'总计-'+Region,'总计-'+Region,0,'',
		[dbo].[Format_Number2Thousand](SUM(Tgt)),[dbo].[Format_Number2Thousand](SUM(SellIn_MTD)),
		CASE WHEN SUM(Tgt)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellIn_MTD)*100.0/SUM(Tgt),0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGT)),[dbo].[Format_Number2Thousand](SUM(SellOut_MTD))
		,CASE WHEN SUM(SellOut_TGT)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_MTD)*100.0/SUM(SellOut_TGT),0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGT_A)),[dbo].[Format_Number2Thousand](SUM(SellOut_MTD_A))
		,CASE WHEN SUM(SellOut_TGT_A)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_MTD_A)*100.0/SUM(SellOut_TGT_A),0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGT_F)),[dbo].[Format_Number2Thousand](SUM(SellOut_MTD_F))
		,CASE WHEN SUM(SellOut_TGT_F)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_MTD_F)*100.0/SUM(SellOut_TGT_F),0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGTSKU_A)),[dbo].[Format_Number2Thousand](SUM(SellOut_SKUCnt_A))
		,CASE WHEN SUM(SellOut_TGTSKU_A)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_SKUCnt_A)*100.0/SUM(SellOut_TGTSKU_A),0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGTSKU_F)),[dbo].[Format_Number2Thousand](SUM(SellOut_SKUCnt_F))
		,CASE WHEN SUM(SellOut_TGTSKU_F)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_SKUCnt_F)*100.0/SUM(SellOut_TGTSKU_F),0) AS INT) AS VARCHAR(5))+'%' END,
		'bgcolor=#F0F8FF align=left style="font-weight:bold;"',
		GETDATE(),'[rpt].[SP_Sales_销售代表月度指标达成日报_Update]'		
		FROM
			(SELECT	Region,Region_Director,a.Manager,
				(MAX(Tgt)) AS Tgt,(SUM(SellIn_MTD)) AS SellIn_MTD,
				(SUM(SellOut_TGT)) AS SellOut_TGT,(SUM(SellOut_MTD)) AS SellOut_MTD,
				(SUM(SellOut_TGT_A)) AS SellOut_TGT_A,(SUM(SellOut_MTD_A)) AS SellOut_MTD_A,
				(SUM(SellOut_TGT_F)) AS SellOut_TGT_F,(SUM(SellOut_MTD_F)) AS SellOut_MTD_F,
				(SUM(SellOut_TGTSKU_A)) AS SellOut_TGTSKU_A,(SUM(SellOut_SKUCnt_A)) AS SellOut_SKUCnt_A,
				(SUM(SellOut_TGTSKU_F)) AS SellOut_TGTSKU_F,(SUM(SellOut_SKUCnt_F)) AS SellOut_SKUCnt_F
			FROM #tmpSales a
			LEFT JOIN (
				SELECT ISNULL(stm.Manager,s.Area) AS Manager,SUM(s.TargetAmt) AS Tgt
				FROM [dm].[Fct_Sales_SellInTarget_ByKAarea] s
				JOIN (SELECT DISTINCT Area,Manager FROM dm.Dim_SalesTerritory_Mapping_Monthly WHERE Monthkey=@currMonth) stm ON s.Area=stm.Area AND s.KA='YH'
				WHERE s.Monthkey=@currMonth
				GROUP BY ISNULL(stm.Manager,s.Area))si ON a.Manager=si.Manager
			GROUP BY a.Region,a.Region_Director,a.Manager
			)xx
		GROUP BY Region,Region_Director
	
	UNION
	SELECT	'总计','总计','总计-全国','总计-全国',0,'',
		[dbo].[Format_Number2Thousand](MAX(s.Tgt)),[dbo].[Format_Number2Thousand](SUM(SellIn_MTD)),
		CASE WHEN MAX(Tgt)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellIn_MTD)*100.0/MAX(Tgt),0) AS INT) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGT)),[dbo].[Format_Number2Thousand](SUM(SellOut_MTD))
		,CASE WHEN SUM(SellOut_TGT)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_MTD)*100.0/SUM(SellOut_TGT),0) AS int) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGT_A)),[dbo].[Format_Number2Thousand](SUM(SellOut_MTD_A))
		,CASE WHEN SUM(SellOut_TGT_A)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_MTD_A)*100.0/SUM(SellOut_TGT_A),0) AS int) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGT_F)),[dbo].[Format_Number2Thousand](SUM(SellOut_MTD_F))
		,CASE WHEN SUM(SellOut_TGT_F)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_MTD_F)*100.0/SUM(SellOut_TGT_F),0) AS int) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGTSKU_A)),[dbo].[Format_Number2Thousand](SUM(SellOut_SKUCnt_A))
		,CASE WHEN SUM(SellOut_TGTSKU_A)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_SKUCnt_A)*100.0/SUM(SellOut_TGTSKU_A),0) AS int) AS VARCHAR(5))+'%' END,
		[dbo].[Format_Number2Thousand](SUM(SellOut_TGTSKU_F)),[dbo].[Format_Number2Thousand](SUM(SellOut_SKUCnt_F))
		,CASE WHEN SUM(SellOut_TGTSKU_F)=0 THEN '-' ELSE CAST(CAST(ROUND(SUM(SellOut_SKUCnt_F)*100.0/SUM(SellOut_TGTSKU_F),0) AS int) AS VARCHAR(5))+'%' END,
		'bgcolor=#FFEFD8 align=left style="font-weight:bold;"',
		GETDATE(),'[rpt].[SP_Sales_销售代表月度指标达成日报_Update]'		
	FROM #tmpSales t
	JOIN (SELECT SUM(TargetAmt) Tgt FROM [dm].[Fct_Sales_SellInTarget_ByKAarea] WHERE Monthkey=@currMonth AND KA='YH') s ON 1=1

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
      [Manager_Display] AS [区域负责人]
      ,[SalesPerson] AS [门店负责人]
      ,[进货目标]
      ,[进货实际]
      ,[进货达成%]
      ,[POS目标]
      ,[POS实际]
      ,[POS达成%]
      ,[常温目标]
      ,[常温实际]
      ,[常温达成%]
      ,[低温目标]
      ,[低温实际]
      ,[低温达成%]
      ,[常温SKU数目标]
      ,[常温SKU数实际]
      ,[常温SKU数达成%]
      ,[低温SKU数目标]
      ,[低温SKU数实际]
      ,[低温SKU数达成%]
      ,[Row_Attr]
  FROM [rpt].[Sales_销售代表月度指标达成日报]
  WHERE Manager_Display !='' OR SalesPerson !=''
  ORDER BY Region,Director,Manager,RN

  SELECT *FROM [rpt].[Sales_销售代表月度指标达成日报]
  ORDER BY Director,Manager, RN

  */
GO
