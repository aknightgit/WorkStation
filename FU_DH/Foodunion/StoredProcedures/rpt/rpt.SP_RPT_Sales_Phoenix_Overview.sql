USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from dm.Dim_Channel where Channel_Name_CN like '%旗舰店%'

CREATE   PROCEDURE [rpt].[SP_RPT_Sales_Phoenix_Overview]
AS BEGIN 


	DROP TABLE IF EXISTS #dailysales;
	SELECT * INTO #dailysales FROM (
	SELECT si.DateKey
		  ,CASE WHEN si.Channel_ID IN (45,58,65) THEN 45 
				WHEN dc.Channel_Category='EC-Tmall' THEN 18 
				WHEN si.Channel_ID IN (71,97,108,109) THEN 71 
				ELSE si.Channel_ID END AS Channel_ID		--45 Youzan  58 社区店  65 上海徐汇爱睿格林托育有限公司			都算到O2O
		  ,CASE WHEN Channel_Type='DTC' THEN 'DTC' 
			WHEN dc.Channel_Category='EC-Tmall' THEN 'Tmall' 
			WHEN dc.Channel_Category='EC-PDD' THEN 'PDD' 
			WHEN dc.Channel_Name_Display ='去楼下ZBox' THEN 'ZBox'
			WHEN dc.Channel_Category='EC-EKA' THEN 'EKA' 
			END AS Channel
		  ,'Sell Out' AS Item
		  ,SUM(Amount) AS Sales
	FROM [dm].[Fct_Sales_SellOut_ByChannel] si with(nolock)
	LEFT JOIN [dm].[Dim_Channel] dc ON si.Channel_ID = dc.Channel_ID
	LEFT JOIN DM.Dim_Calendar C ON SI.DateKey=C.Datekey
	WHERE Channel_Type IN ('EC','ZBOX','DTC') AND C.Is_Past=1  --增加时间判断，与Omni channel report 数据逻辑一致
	GROUP BY si.DateKey
		    ,CASE WHEN si.Channel_ID IN (45,58,65) THEN 45 
				WHEN dc.Channel_Category='EC-Tmall' THEN 18 
				WHEN si.Channel_ID IN (71,97,108,109) THEN 71 
				ELSE si.Channel_ID END 
		  ,CASE WHEN Channel_Type='DTC' THEN 'DTC' 
			WHEN dc.Channel_Category='EC-Tmall' THEN 'Tmall' 
			WHEN dc.Channel_Category='EC-PDD' THEN 'PDD' 
			WHEN dc.Channel_Name_Display ='去楼下ZBox' THEN 'ZBox'
			WHEN dc.Channel_Category='EC-EKA' THEN 'EKA' 
			END 
	UNION

	SELECT si.DateKey
		  ,CASE WHEN si.Channel_ID IN (45,58,65) THEN 45 
				WHEN dc.Channel_Category='EC-Tmall' THEN 18 
				WHEN si.Channel_ID IN (71,97,108,109) THEN 71 
				ELSE si.Channel_ID END AS Channel_ID
		  ,CASE  WHEN dc.Channel_Category='EC-Tmall' THEN 'Tmall' 
			WHEN dc.Channel_Name_Display ='拼多多Pinduoduo' THEN 'PDD' 
			WHEN dc.Channel_Name_Display ='去楼下ZBox' THEN 'ZBox' 
			WHEN dc.Channel_Name_Display ='有赞youzan' THEN 'DTC' END AS Channel
		  ,'Sell In' AS Item
		  ,SUM(Amount) AS Sales
	FROM [dm].[Fct_Sales_SellIn_ByChannel] si with(nolock)
	LEFT JOIN [dm].[Dim_Channel] dc ON si.Channel_ID = dc.Channel_ID 
	WHERE Channel_Type IN ('EC','ZBOX','DTC')
	GROUP BY si.DateKey
		    ,CASE WHEN si.Channel_ID IN (45,58,65) THEN 45 
				WHEN dc.Channel_Category='EC-Tmall' THEN 18 
				WHEN si.Channel_ID IN (71,97,108,109) THEN 71 
				ELSE si.Channel_ID END 
		  ,CASE  WHEN dc.Channel_Category='EC-Tmall' THEN 'Tmall' 
			WHEN dc.Channel_Name_Display ='拼多多Pinduoduo' THEN 'PDD' 
			WHEN dc.Channel_Name_Display ='去楼下ZBox' THEN 'ZBox' 
			WHEN dc.Channel_Name_Display ='有赞youzan' THEN 'DTC' END 
		  
	)a

	--SELECT * FROM #dailysales;

	--DROP TABLE IF EXISTS #monthlysales;	
	--SELECT Datekey/100 AS Monthkey,Channel_ID,Channel,Item,SUM(Sales) AS MonthlySales
	--INTO #monthlysales
	--FROM #dailysales GROUP BY Datekey/100,Channel_ID,Channel,Item;

	DROP TABLE IF EXISTS #monthlysales;	
	SELECT Datekey/100 AS Monthkey,Channel,Item,SUM(Sales) AS MonthlySales
	INTO #monthlysales
	FROM #dailysales GROUP BY Datekey/100,Channel,Item;

	--DROP TABLE IF EXISTS #weeklysales;
	--SELECT dc.Year,dc.Week_of_Year,Channel_ID,Channel,Item,SUM(Sales) AS WeeklySales
	--INTO #weeklysales
	--FROM #dailysales d 
	--JOIN dm.Dim_Calendar dc ON dc.Datekey=d.Datekey 
	--GROUP BY dc.Year,dc.Week_of_Year,Channel_ID,Channel,Item

	DROP TABLE IF EXISTS #weeklysales;
	SELECT dc.Year,dc.Week_of_Year,Channel,Item,SUM(Sales) AS WeeklySales
	INTO #weeklysales
	FROM #dailysales d 
	JOIN dm.Dim_Calendar dc ON dc.Datekey=d.Datekey 
	GROUP BY dc.Year,dc.Week_of_Year,Channel,Item;

	--SELECT * FROM #weeklysales
	
	--select * from #dailysales where channel = 'PDD'

	DROP TABLE IF EXISTS #monthlytarget;
	
	SELECT * INTO #monthlytarget FROM (	
	SELECT '201912' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,15000  AS MonthlyTarget UNION ALL
	SELECT '201912' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,700000  AS MonthlyTarget UNION ALL
	SELECT '201912' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,15000  AS MonthlyTarget UNION ALL
	SELECT '201912' AS Monthkey,'DTC' AS Channel,'Sell Out' AS Item,73442.2  AS MonthlyTarget UNION ALL
	SELECT '201912' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,160000  AS MonthlyTarget UNION ALL
	SELECT '202001' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,15000  AS MonthlyTarget UNION ALL
	SELECT '202001' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,250000  AS MonthlyTarget UNION ALL
	SELECT '202001' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,410000  AS MonthlyTarget UNION ALL
	SELECT '202001' AS Monthkey,'DTC' AS Channel,'Sell Out' AS Item,49853  AS MonthlyTarget UNION ALL
	SELECT '202001' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,130000  AS MonthlyTarget UNION ALL
	SELECT '202002' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,20000  AS MonthlyTarget UNION ALL
	SELECT '202002' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,150000  AS MonthlyTarget UNION ALL
	SELECT '202002' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,15000  AS MonthlyTarget UNION ALL
	SELECT '202002' AS Monthkey,'DTC' AS Channel,'Sell Out' AS Item,43000  AS MonthlyTarget UNION ALL
	SELECT '202002' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,360000  AS MonthlyTarget UNION ALL

	SELECT '202003' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,120000  AS MonthlyTarget UNION ALL
	SELECT '202003' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,250000  AS MonthlyTarget UNION ALL
	SELECT '202003' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,40000  AS MonthlyTarget UNION ALL
	SELECT '202003' AS Monthkey,'DTC' AS Channel,'Sell Out' AS Item,145527  AS MonthlyTarget UNION ALL
	SELECT '202003' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,368280  AS MonthlyTarget UNION ALL

	SELECT '202004' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,500000  AS MonthlyTarget UNION ALL
	SELECT '202004' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,300000  AS MonthlyTarget UNION ALL
	SELECT '202004' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,500000  AS MonthlyTarget UNION ALL
	SELECT '202004' AS Monthkey,'DTC' AS Channel,'Sell Out' AS Item,197704  AS MonthlyTarget UNION ALL
	SELECT '202004' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,578279  AS MonthlyTarget UNION ALL

	SELECT '202005' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,625000  AS MonthlyTarget UNION ALL
	SELECT '202005' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,300000  AS MonthlyTarget UNION ALL
	SELECT '202005' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,625000  AS MonthlyTarget UNION ALL
	SELECT '202005' AS Monthkey,'DTC' AS Channel,'Sell Out' AS Item,291189  AS MonthlyTarget UNION ALL
	SELECT '202005' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,856312  AS MonthlyTarget UNION ALL

	SELECT '202006' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,1174179  AS MonthlyTarget UNION ALL
	SELECT '202006' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,69524  AS MonthlyTarget UNION ALL
	SELECT '202006' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,107537  AS MonthlyTarget UNION ALL
	SELECT '202006' AS Monthkey,'DTC' AS Channel,'Sell Out' AS Item,423900  AS MonthlyTarget UNION ALL
	SELECT '202006' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,405000  AS MonthlyTarget UNION ALL

	SELECT '202007' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,553986  AS MonthlyTarget UNION ALL
	SELECT '202007' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,133616  AS MonthlyTarget UNION ALL
	SELECT '202007' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,155838  AS MonthlyTarget UNION ALL
	SELECT '202007' AS Monthkey,'DTC' AS Channel,'Sell Out' AS Item,635372  AS MonthlyTarget UNION ALL
	SELECT '202007' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,486000  AS MonthlyTarget UNION ALL

	SELECT '202008' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,683255  AS MonthlyTarget UNION ALL
	SELECT '202008' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,117670  AS MonthlyTarget UNION ALL
	SELECT '202008' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,139582  AS MonthlyTarget UNION ALL
	SELECT '202008' AS Monthkey,'DTC' AS Channel,'Sell Out' AS Item,929244  AS MonthlyTarget UNION ALL
	SELECT '202008' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,583200  AS MonthlyTarget UNION ALL

	SELECT '202009' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,891388  AS MonthlyTarget UNION ALL
	SELECT '202009' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,155360  AS MonthlyTarget UNION ALL
	SELECT '202009' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,249916  AS MonthlyTarget UNION ALL
	SELECT '202009' AS Monthkey,'DTC' AS Channel,'Sell Out' AS Item,1297965  AS MonthlyTarget UNION ALL
	SELECT '202009' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,699840  AS MonthlyTarget UNION ALL

	SELECT '202010' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,524833  AS MonthlyTarget UNION ALL
	SELECT '202010' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,218119  AS MonthlyTarget UNION ALL
	SELECT '202010' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,281962  AS MonthlyTarget UNION ALL
	SELECT '202010' AS Monthkey,'DTC' AS Channel,'Sell Out' AS Item,1912594  AS MonthlyTarget UNION ALL
	SELECT '202010' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,839808  AS MonthlyTarget UNION ALL

	SELECT '202011' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,5188669  AS MonthlyTarget UNION ALL
	SELECT '202011' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,236696  AS MonthlyTarget UNION ALL
	SELECT '202011' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,282117  AS MonthlyTarget UNION ALL
	SELECT '202011' AS Monthkey,'DTC' AS Channel,'Sell Out' AS Item,2671127  AS MonthlyTarget UNION ALL
	SELECT '202011' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,923789  AS MonthlyTarget 


	UNION ALL

	SELECT si.MonthKey
		  ,CASE  si.Account_Display_Name WHEN 'Lakto Tmall' THEN 'Tmall' 
		  WHEN 'Pinduoduo' THEN 'PDD' 
		  WHEN '去楼下Qulouxia' THEN 'ZBox' 
		  WHEN '有赞youzan' THEN 'DTC' END AS Channel
		  ,'Sell In' AS Item
		  --,SUM(Target_Amt_KRMB)*1000 AS Sales
		  ,CASE WHEN MAX(Category_Target_Amt_KRMB)*1000 IS NULL THEN SUM(Target_Amt_KRMB)*1000 ELSE MAX(Category_Target_Amt_KRMB)*1000 END AS Sales  --由于上传文件Target值不在同一列，所以需要判断Target存放列   --Justin 2020-01-08
    FROM [dm].[Fct_Sales_SellInTarget_ByChannel] si with(nolock)
	WHERE Channel_Type IN ('Online','ZBOX','DTC') AND si.MonthKey >= 201910
	GROUP BY si.MonthKey
			,CASE  si.Account_Display_Name WHEN 'Lakto Tmall' THEN 'Tmall' 
			WHEN 'Pinduoduo' THEN 'PDD' 
			WHEN '去楼下Qulouxia' THEN 'ZBox' 
			WHEN '有赞youzan' THEN 'DTC' 
			END
    UNION ALL

	SELECT si.Datekey/100
		  ,CASE  si.Channel_Name_Display 
		  WHEN 'Lakto Tmall' THEN 'Tmall' 
		  WHEN 'Pinduoduo' THEN 'PDD' 
		  WHEN '去楼下Qulouxia' THEN 'ZBox' 
		  WHEN '有赞youzan' THEN 'DTC' END AS Channel
		  ,'Sell In' AS Item
		  ,SUM(Target_AMT)*1000 AS Sales
    FROM [dm].[Fct_Sales_SellInTarget_ByChannel_hist] si with(nolock)
	WHERE  si.Channel_Name_Display IN ('Lakto Tmall','Pinduoduo' ,'去楼下Qulouxia','有赞youzan')
	GROUP BY si.Datekey/100
			,CASE  si.Channel_Name_Display WHEN 'Lakto Tmall' THEN 'Tmall' 
			WHEN 'Pinduoduo' THEN 'PDD' 
			WHEN '去楼下Qulouxia' THEN 'ZBox' 
			WHEN '有赞youzan' THEN 'DTC' END
	)b

	DROP TABLE IF EXISTS #weeklytarget;	
	SELECT * INTO #weeklytarget FROM (	
	SELECT dc.Year as Yearkey,dc.Week_of_Year,dc.Week_Nature_Str,MAX(Datekey) END_Date,Channel,Item, max(MonthlyTarget)/max(md.days)*count(1) AS WeeklyTarget
	FROM #monthlytarget mt
	JOIN [dm].[Dim_Calendar] AS dc with(nolock) ON mt.MonthKey = dc.Monthkey
	JOIN (SELECT Monthkey,count(1) days FROM [dm].[Dim_Calendar] with(nolock) GROUP BY Monthkey) md ON md.Monthkey = mt.MonthKey
	GROUP BY dc.Year,dc.Week_of_Year,dc.Week_Nature_Str,Channel,Item
	)m

	--SELECT * FROM #weeklytarget;

	SELECT wt.Yearkey
		,k.Monthkey AS Monthkey	
		,wt.Week_of_Year AS Week_Year_NBR
		,wt.Week_Nature_Str AS Week_Date_Period
		,wt.Channel
		,wt.Item AS Item
		,wt.WeeklyTarget AS WeeklyTarget
		,ws.WeeklySales AS WeeklyActual
		,lws.WeeklySales AS LastWeekActual
		,CASE WHEN lws.WeeklySales IS NULL THEN NULL ELSE CASE WHEN lws.WeeklySales = 0 THEN NULL ELSE ws.WeeklySales/lws.WeeklySales-1 END END AS Raise	
		,mt.MonthlyTarget AS MonthlyTarget
		,m1.MonthlySales AS MonthlyActual
		,CASE WHEN ISNULL(mt.MonthlyTarget,0)=0 THEN NULL ELSE CASE WHEN mt.MonthlyTarget = 0 THEN NULL ELSE m1.MonthlySales/mt.MonthlyTarget END END AS MonthlyArch
		,l.LatestDay
	FROM #weeklytarget wt
	LEFT JOIN #weeklysales ws ON wt.Yearkey=ws.Year AND wt.Week_of_Year=ws.Week_of_Year AND wt.Channel=ws.Channel AND wt.Item=ws.Item 
	LEFT JOIN #weeklysales lws ON wt.Yearkey=lws.Year AND wt.Week_of_Year=lws.Week_of_Year+1 AND wt.Channel=lws.Channel  AND wt.Item=lws.Item
	--LEFT JOIN (SELECT Year,Week_of_Year,MAX(Monthkey) Monthkey FROM dm.Dim_Calendar GROUP BY Year,Week_of_Year)k ON wt.Yearkey=k.Year AND wt.Week_of_Year=k.Week_of_Year
	LEFT JOIN (SELECT DISTINCT Year,Week_of_Year,Monthkey FROM dm.Dim_Calendar)k ON wt.Yearkey=k.Year AND wt.Week_of_Year=k.Week_of_Year  --允许同一个week有两个月份可选 
	LEFT JOIN #monthlytarget mt ON mt.Monthkey=k.Monthkey AND mt.Channel=wt.Channel AND mt.Item=wt.Item 
	LEFT JOIN #monthlysales m1 ON m1.Monthkey=k.Monthkey AND m1.Channel=wt.Channel AND m1.Item=wt.Item
	JOIN (SELECT MAX(Datekey) AS LatestDay FROM #dailysales WHERE Item='Sell Out')l ON 1 =1 
	WHERE wt.END_Date<=CONVERT(VARCHAR(8),GETDATE()+7,112) AND wt.Channel IS NOT NULL
	ORDER BY 1,2,4,6
;
END


--SELECT * FROM #weeklytarget wt WHERE Channel='PDD' AND Week_of_Year=3
--SELECT * FROM #weeklysales WHERE Channel='PDD' AND Week_of_Year=3
--SELECT * FROM #dailysales WHERE Channel='PDD' AND DateKey BETWEEN 20200101 AND 20200120



 --;WITH dailysales AS(

	--SELECT si.DateKey
	--	  ,CASE WHEN si.Channel_ID IN (45,58,65) THEN 45 
	--			--WHEN si.Channel_ID IN (71,97,108,109) THEN 71 
	--			ELSE si.Channel_ID END AS Channel_ID		--45 Youzan  58 社区店  65 上海徐汇爱睿格林托育有限公司			都算到O2O
	--	  ,CASE WHEN Channel_Type='O2O' THEN 'O2O' 
	--		WHEN dc.Channel_Name_Display ='Lakto Tmall' THEN 'Tmall' 
	--		WHEN dc.Channel_Category='EC-PDD' THEN 'PDD' 
	--		WHEN dc.Channel_Name_Display ='去楼下ZBox' THEN 'ZBox'
	--		WHEN dc.Channel_Name_Display ='深圳微之家' THEN 'EKA' END AS Channel
	--	  ,'Sell Out' AS Item
	--	  ,SUM(Amount) AS Sales
	--FROM [dm].[Fct_Sales_SellOut_ByChannel] si with(nolock)
	--LEFT JOIN [dm].[Dim_Channel] dc ON si.Channel_ID = dc.Channel_ID
	--WHERE Channel_Type IN ('EC','ZBOX','O2O')
	--GROUP BY si.DateKey
	--	    ,CASE WHEN si.Channel_ID IN (45,58,65) THEN 45 
	--			--WHEN si.Channel_ID IN (71,97,108,109) THEN 71 
	--			ELSE si.Channel_ID END
	--		,CASE WHEN Channel_Type='O2O' THEN 'O2O' 
	--		WHEN dc.Channel_Name_Display ='Lakto Tmall' THEN 'Tmall' 
	--		WHEN dc.Channel_Category='EC-PDD' THEN 'PDD' 
	--		WHEN dc.Channel_Name_Display ='去楼下ZBox' THEN 'ZBox' 
	--		WHEN dc.Channel_Name_Display ='深圳微之家' THEN 'EKA' END
	--UNION

	--SELECT si.DateKey
	--	  ,si.Channel_ID
	--	  ,CASE  dc.Channel_Name_Display WHEN 'Lakto Tmall' THEN 'Tmall' 
	--		WHEN '拼多多Pinduoduo' THEN 'PDD' 
	--		WHEN '去楼下ZBox' THEN 'ZBox' 
	--		WHEN '有赞youzan' THEN 'O2O' END AS Channel
	--	  ,'Sell In' AS Item
	--	  ,SUM(Amount) AS Sales
	--FROM [dm].[Fct_Sales_SellIn_ByChannel] si with(nolock)
	--LEFT JOIN [dm].[Dim_Channel] dc ON si.Channel_ID = dc.Channel_ID 
	--WHERE Channel_Type IN ('EC','ZBOX','O2O')
	--GROUP BY si.DateKey
	--	    ,si.Channel_ID
	--		,CASE  dc.Channel_Name_Display WHEN 'Lakto Tmall' THEN 'Tmall' 
	--		WHEN '拼多多Pinduoduo' THEN 'PDD' 
	--		WHEN '去楼下ZBox' THEN 'ZBox' 
	--		WHEN '有赞youzan' THEN 'O2O' END
	--)
--,monthlysales AS (
--	SELECT Datekey/100 AS Monthkey,Channel_ID,Channel,Item,SUM(Sales) AS MonthlySales
--	FROM dailysales GROUP BY Datekey/100,Channel_ID,Channel,Item
--	)
--,weeklysales AS (
--	SELECT dc.Year,dc.Week_of_Year,Channel_ID,Channel,Item,SUM(Sales) AS WeeklySales
--	FROM dailysales d 
--	JOIN dm.Dim_Calendar dc ON dc.Datekey=d.Datekey 
--	GROUP BY dc.Year,dc.Week_of_Year,Channel_ID,Channel,Item
--	)

--,monthlytarget AS (
	
--	SELECT '201912' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,15000  AS MonthlyTarget UNION ALL
--	SELECT '201912' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,700000  AS MonthlyTarget UNION ALL
--	SELECT '201912' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,15000  AS MonthlyTarget UNION ALL
--	SELECT '201912' AS Monthkey,'O2O' AS Channel,'Sell Out' AS Item,73442.2  AS MonthlyTarget UNION ALL
--	SELECT '201912' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,160000  AS MonthlyTarget UNION ALL
--	SELECT '202001' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,15000  AS MonthlyTarget UNION ALL
--	SELECT '202001' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,250000  AS MonthlyTarget UNION ALL
--	SELECT '202001' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,410000  AS MonthlyTarget UNION ALL
--	SELECT '202001' AS Monthkey,'O2O' AS Channel,'Sell Out' AS Item,49853  AS MonthlyTarget UNION ALL
--	SELECT '202001' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,130000  AS MonthlyTarget

--	UNION ALL

--	SELECT si.MonthKey
--		  ,CASE  si.Account_Display_Name WHEN 'Lakto Tmall' THEN 'Tmall' WHEN 'Pinduoduo' THEN 'PDD' WHEN '去楼下Qulouxia' THEN 'ZBox' WHEN '有赞youzan' THEN 'O2O' END AS Channel
--		  ,'Sell In' AS Item
--		  --,SUM(Target_Amt_KRMB)*1000 AS Sales
--		  ,CASE WHEN MAX(Category_Target_Amt_KRMB)*1000 IS NULL THEN SUM(Target_Amt_KRMB)*1000 ELSE MAX(Category_Target_Amt_KRMB)*1000 END AS Sales  --由于上传文件Target值不在同一列，所以需要判断Target存放列   --Justin 2020-01-08
--    FROM [Foodunion].[dm].[Fct_Sales_SellInTarget_ByChannel] si with(nolock)
--	WHERE Channel_Type IN ('Online','ZBOX','O2O') AND si.MonthKey >= 201910
--	GROUP BY si.MonthKey
--			,CASE  si.Account_Display_Name WHEN 'Lakto Tmall' THEN 'Tmall' WHEN 'Pinduoduo' THEN 'PDD' WHEN '去楼下Qulouxia' THEN 'ZBox' WHEN '有赞youzan' THEN 'O2O' END
--    UNION ALL

--	SELECT si.Datekey/100
--		  ,CASE  si.Channel_Name_Display WHEN 'Lakto Tmall' THEN 'Tmall' WHEN 'Pinduoduo' THEN 'PDD' WHEN '去楼下Qulouxia' THEN 'ZBox' WHEN '有赞youzan' THEN 'O2O' END AS Channel
--		  ,'Sell In' AS Item
--		  ,SUM(Target_AMT)*1000 AS Sales
--    FROM [Foodunion].[dm].[Fct_Sales_SellInTarget_ByChannel_hist] si with(nolock)
--	WHERE  si.Channel_Name_Display IN ('Lakto Tmall','Pinduoduo' ,'去楼下Qulouxia','有赞youzan')
--	GROUP BY si.Datekey/100
--			,CASE  si.Channel_Name_Display WHEN 'Lakto Tmall' THEN 'Tmall' WHEN 'Pinduoduo' THEN 'PDD' WHEN '去楼下Qulouxia' THEN 'ZBox' WHEN '有赞youzan' THEN 'O2O' END

--	)
--,weeklytarget AS(
--	SELECT dc.Year as Yearkey,dc.Week_of_Year,dc.Week_Nature_Str,MAX(Datekey) END_Date,Channel,Item, max(MonthlyTarget)/max(md.days)*count(1) AS WeeklyTarget
--	FROM monthlytarget mt
--	JOIN [dm].[Dim_Calendar] AS dc with(nolock) ON mt.MonthKey = dc.Monthkey
--	JOIN (SELECT Monthkey,count(1) days FROM [dm].[Dim_Calendar] with(nolock) GROUP BY Monthkey) md ON md.Monthkey = mt.MonthKey
--	GROUP BY dc.Year,dc.Week_of_Year,dc.Week_Nature_Str,Channel,Item
--	)	
GO
