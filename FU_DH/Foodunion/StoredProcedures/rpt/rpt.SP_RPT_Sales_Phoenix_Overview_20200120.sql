USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [rpt].[SP_RPT_Sales_Phoenix_Overview_20200120]
AS BEGIN 





 ;WITH dailysales AS(

	SELECT si.DateKey
		  ,CASE WHEN si.Channel_ID IN (45,58,65) THEN 45 ELSE si.Channel_ID END AS Channel_ID		--45 Youzan  58 社区店  65 上海徐汇爱睿格林托育有限公司			都算到O2O
		  ,CASE WHEN Channel_Type='O2O' THEN 'O2O' 
			WHEN dc.Channel_Name_Display ='Lakto Tmall' THEN 'Tmall' 
			WHEN dc.Channel_Name_Display ='拼多多Pinduoduo' THEN 'PDD' 
			WHEN dc.Channel_Name_Display ='去楼下ZBox' THEN 'ZBox'
			WHEN dc.Channel_Name_Display ='深圳微之家' THEN 'EKA' END AS Channel
		  ,'Sell Out' AS Item
		  ,SUM(Amount) AS Sales
	FROM [Foodunion].[dm].[Fct_Sales_SellOut_ByChannel] si with(nolock)
	LEFT JOIN [dm].[Dim_Channel] dc ON si.Channel_ID = dc.Channel_ID
	WHERE Channel_Type IN ('EC','ZBOX','O2O')
	GROUP BY si.DateKey
		    ,CASE WHEN si.Channel_ID IN (45,58,65) THEN 45 ELSE si.Channel_ID END
			,CASE WHEN Channel_Type='O2O' THEN 'O2O' 
			WHEN dc.Channel_Name_Display ='Lakto Tmall' THEN 'Tmall' 
			WHEN dc.Channel_Name_Display ='拼多多Pinduoduo' THEN 'PDD' 
			WHEN dc.Channel_Name_Display ='去楼下ZBox' THEN 'ZBox' 
			WHEN dc.Channel_Name_Display ='深圳微之家' THEN 'EKA' END
	UNION

		SELECT si.DateKey
		  ,si.Channel_ID
		  ,CASE  dc.Channel_Name_Display WHEN 'Lakto Tmall' THEN 'Tmall' WHEN '拼多多Pinduoduo' THEN 'PDD' WHEN '去楼下ZBox' THEN 'ZBox' WHEN '有赞youzan' THEN 'O2O' END AS Channel
		  ,'Sell In' AS Item
		  ,SUM(Amount) AS Sales
	FROM [Foodunion].[dm].[Fct_Sales_SellIn_ByChannel] si with(nolock)
	LEFT JOIN [dm].[Dim_Channel] dc ON si.Channel_ID = dc.Channel_ID 
	WHERE Channel_Type IN ('EC','ZBOX','O2O')
	GROUP BY si.DateKey
		    ,si.Channel_ID
			,CASE  dc.Channel_Name_Display WHEN 'Lakto Tmall' THEN 'Tmall' WHEN '拼多多Pinduoduo' THEN 'PDD' WHEN '去楼下ZBox' THEN 'ZBox' WHEN '有赞youzan' THEN 'O2O' END
	)
,monthlysales AS (
	SELECT Datekey/100 AS Monthkey,Channel_ID,Channel,Item,SUM(Sales) AS MonthlySales
	FROM dailysales GROUP BY Datekey/100,Channel_ID,Channel,Item
	)
,weeklysales AS (
	SELECT dc.Year,dc.Week_Year_NBR,Channel_ID,Channel,Item,SUM(Sales) AS WeeklySales
	FROM dailysales d 
	JOIN FU_EDW.Dim_Calendar dc ON dc.Date_ID=d.Datekey 
	GROUP BY dc.Year,dc.Week_Year_NBR,Channel_ID,Channel,Item
	)

,monthlytarget AS (
	
	SELECT '201912' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,15000  AS MonthlyTarget UNION ALL
	SELECT '201912' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,700000  AS MonthlyTarget UNION ALL
	SELECT '201912' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,15000  AS MonthlyTarget UNION ALL
	SELECT '201912' AS Monthkey,'O2O' AS Channel,'Sell Out' AS Item,73442.2  AS MonthlyTarget UNION ALL
	SELECT '201912' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,160000  AS MonthlyTarget UNION ALL
	SELECT '202001' AS Monthkey,'Tmall' AS Channel,'Sell Out' AS Item,15000  AS MonthlyTarget UNION ALL
	SELECT '202001' AS Monthkey,'PDD' AS Channel,'Sell Out' AS Item,250000  AS MonthlyTarget UNION ALL
	SELECT '202001' AS Monthkey,'EKA' AS Channel,'Sell Out' AS Item,410000  AS MonthlyTarget UNION ALL
	SELECT '202001' AS Monthkey,'O2O' AS Channel,'Sell Out' AS Item,49853  AS MonthlyTarget UNION ALL
	SELECT '202001' AS Monthkey,'Zbox' AS Channel,'Sell Out' AS Item,130000  AS MonthlyTarget

	UNION ALL

	SELECT si.MonthKey
		  ,CASE  si.Account_Display_Name WHEN 'Lakto Tmall' THEN 'Tmall' WHEN 'Pinduoduo' THEN 'PDD' WHEN '去楼下Qulouxia' THEN 'ZBox' WHEN '有赞youzan' THEN 'O2O' END AS Channel
		  ,'Sell In' AS Item
		  --,SUM(Target_Amt_KRMB)*1000 AS Sales
		  ,CASE WHEN MAX(Category_Target_Amt_KRMB)*1000 IS NULL THEN SUM(Target_Amt_KRMB)*1000 ELSE MAX(Category_Target_Amt_KRMB)*1000 END AS Sales  --由于上传文件Target值不在同一列，所以需要判断Target存放列   --Justin 2020-01-08
    FROM [Foodunion].[dm].[Fct_Sales_SellInTarget_ByChannel] si with(nolock)
	WHERE Channel_Type IN ('Online','ZBOX','O2O') AND si.MonthKey >= 201910
	GROUP BY si.MonthKey
			,CASE  si.Account_Display_Name WHEN 'Lakto Tmall' THEN 'Tmall' WHEN 'Pinduoduo' THEN 'PDD' WHEN '去楼下Qulouxia' THEN 'ZBox' WHEN '有赞youzan' THEN 'O2O' END
    UNION ALL

	SELECT si.Datekey/100
		  ,CASE  si.Channel_Name_Display WHEN 'Lakto Tmall' THEN 'Tmall' WHEN 'Pinduoduo' THEN 'PDD' WHEN '去楼下Qulouxia' THEN 'ZBox' WHEN '有赞youzan' THEN 'O2O' END AS Channel
		  ,'Sell In' AS Item
		  ,SUM(Target_AMT)*1000 AS Sales
    FROM [Foodunion].[dm].[Fct_Sales_SellInTarget_ByChannel_hist] si with(nolock)
	WHERE  si.Channel_Name_Display IN ('Lakto Tmall','Pinduoduo' ,'去楼下Qulouxia','有赞youzan')
	GROUP BY si.Datekey/100
			,CASE  si.Channel_Name_Display WHEN 'Lakto Tmall' THEN 'Tmall' WHEN 'Pinduoduo' THEN 'PDD' WHEN '去楼下Qulouxia' THEN 'ZBox' WHEN '有赞youzan' THEN 'O2O' END

	)
,weeklytarget AS(
	SELECT dc.Year as Yearkey,dc.Week_Year_NBR,dc.Week_Date_Period,MAX(Date_ID) END_Date,Channel,Item, max(MonthlyTarget)/max(md.days)*count(1) AS WeeklyTarget
	FROM monthlytarget mt
	JOIN [FU_EDW].[Dim_Calendar] AS dc with(nolock) ON mt.MonthKey = dc.Year_Month
	JOIN (SELECT Year_Month,count(1) days FROM [FU_EDW].[Dim_Calendar] with(nolock) GROUP BY Year_Month) md ON md.Year_Month = mt.MonthKey
	GROUP BY dc.Year,dc.Week_Year_NBR,dc.Week_Date_Period,Channel,Item
	)	
	SELECT wt.Yearkey
	,k.Year_Month AS Monthkey	
	,wt.Week_Year_NBR
	,wt.Week_Date_Period
	,wt.Channel
	,wt.Item AS Item
	,wt.WeeklyTarget/1000 AS WeeklyTarget
	,ws.WeeklySales/1000 AS WeeklyActual
	,lws.WeeklySales/1000 AS LastWeekActual
	,CASE WHEN lws.WeeklySales IS NULL THEN NULL ELSE CASE WHEN lws.WeeklySales = 0 THEN NULL ELSE ws.WeeklySales/lws.WeeklySales-1 END END AS Raise	
	,mt.MonthlyTarget/1000 AS MonthlyTarget
	,m1.MonthlySales/1000 AS MonthlyActual
	,CASE WHEN ISNULL(mt.MonthlyTarget,0)=0 THEN NULL ELSE CASE WHEN mt.MonthlyTarget = 0 THEN NULL ELSE m1.MonthlySales/mt.MonthlyTarget END END AS MonthlyArch
	,l.LatestDay
FROM weeklytarget wt
LEFT JOIN weeklysales ws ON wt.Yearkey=ws.Year AND wt.Week_Year_NBR=ws.Week_Year_NBR AND wt.Channel=ws.Channel AND wt.Item=ws.Item 
LEFT JOIN weeklysales lws ON wt.Yearkey=lws.Year AND wt.Week_Year_NBR=lws.Week_Year_NBR+1 AND wt.Channel=lws.Channel  AND wt.Item=lws.Item
--LEFT JOIN (SELECT Year,Week_Year_NBR,MAX(Year_Month) Year_Month FROM FU_EDW.Dim_Calendar GROUP BY Year,Week_Year_NBR)k ON wt.Yearkey=k.Year AND wt.Week_Year_NBR=k.Week_Year_NBR
LEFT JOIN (SELECT DISTINCT Year,Week_Year_NBR,Year_Month FROM FU_EDW.Dim_Calendar)k ON wt.Yearkey=k.Year AND wt.Week_Year_NBR=k.Week_Year_NBR  --允许同一个week有两个月份可选 
LEFT JOIN monthlytarget mt ON mt.Monthkey=k.Year_Month AND mt.Channel=wt.Channel AND mt.Item=wt.Item 
LEFT JOIN monthlysales m1 ON m1.Monthkey=k.Year_Month AND m1.Channel=wt.Channel AND m1.Item=wt.Item
JOIN (SELECT MAX(Datekey) AS LatestDay FROM dailysales WHERE Item='Sell Out')l ON 1 =1 
WHERE wt.END_Date<=CONVERT(VARCHAR(8),GETDATE()+7,112) AND wt.Channel IS NOT NULL
ORDER BY 1,2,4,6
;
END


GO
