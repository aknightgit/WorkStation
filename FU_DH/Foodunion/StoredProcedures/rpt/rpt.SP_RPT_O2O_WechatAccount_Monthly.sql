USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [rpt].[SP_RPT_O2O_WechatAccount_Monthly]
AS
BEGIN 

DROP  TABLE IF EXISTS #LastDay
SELECT Monthkey AS YearMonth
	  ,MAX(Date) AS LastDay
	  INTO #LastDay
FROM dm.Dim_Calendar
WHERE Datekey BETWEEN 20190226 AND CONVERT(VARCHAR(8),GETDATE(),112)	
GROUP BY Monthkey



	;WITH CTE_C AS(
	SELECT c.Datekey AS Date_ID,ca.Account,
		c.Date AS Date_NM,
		isnull(newfan.NewFansCnt,0) as NewFansCnt,
		isnull(unsub.UnsubCnt,0) AS UnsubFansCnt,
		isnull(newfan.NewFansCnt,0) - isnull(unsub.UnsubCnt,0) AS NetIncreFansCnt,
		COALESCE(ca.TotalFansCnt,0) AS TotalFansCnt
	FROM DM.[Dim_Calendar] c with(nolock)
	LEFT JOIN (select convert(varchar(8),getdate(),112) AS Date_ID,
		case mp_id when '297825819592626176' then 'Foodunion' 
			when '297465504275238912' then 'Lakto'  
			when '325288922244583424' then 'Rasa' 
			when '325303654313758720' then 'Shapetime' 
			when '374308420620259328' then 'Limbazu Piens'		
			when '382172194358300672' then '富友联合食品' 	 	
			when '325364401861431296' then 'Bravo Mama' end as 'Account',
		COUNT(DISTINCT open_id) TotalFansCnt
		from [dm].[Fct_O2O_wxFans_info] with(nolock) where subscribe=1
		--and mp_id='297825819592626176'
		group by mp_id
		) ca ON 1=1	--c.Date_ID = ca.Date_ID
	LEFT JOIN (SELECT in_day AS Date_ID,
		case mp_id when '297825819592626176' then 'Foodunion' 
			when '297465504275238912' then 'Lakto'  
			when '325288922244583424' then 'Rasa' 
			when '325303654313758720' then 'Shapetime' 
			when '374308420620259328' then 'Limbazu Piens' 			
			when '382172194358300672' then '富友联合食品' 	
			when '325364401861431296' then 'Bravo Mama' end as 'Account',
		count(DISTINCT open_id) NewFansCnt
		FROM [dm].[Fct_O2O_wxFans_event_record] with(nolock)
		WHERE event_name = 'subscribe'
	--	AND mp_id = '297825819592626176'
		GROUP by in_day,mp_id
		--ORDER by 1 desc;
		)newfan ON c.Datekey = newfan.Date_ID AND ca.Account=newfan.Account		
	LEFT JOIN (SELECT in_day AS Date_ID,
		case mp_id when '297825819592626176' then 'Foodunion' 
			when '297465504275238912' then 'Lakto'  
			when '325288922244583424' then 'Rasa' 
			when '325303654313758720' then 'Shapetime' 
			when '374308420620259328' then 'Limbazu Piens' 			
			when '382172194358300672' then '富友联合食品' 	
			when '325364401861431296' then 'Bravo Mama' end as 'Account',
		count(DISTINCT open_id) UnsubCnt
		FROM [dm].[Fct_O2O_wxFans_event_record] with(nolock)
		WHERE event_name = 'unsubscribe'
		GROUP by in_day,mp_id
		)unsub ON c.Datekey = unsub.Date_ID	AND unsub.Account=ca.Account
	WHERE c.Datekey BETWEEN 20190226 AND CONVERT(VARCHAR(8),GETDATE(),112)	
	)
--ORDER BY 1 DESC
	,CTE_sum AS(
	SELECT a.Date_ID,a.Date_NM,a.Account
		,a.NewFansCnt,a.UnsubFansCnt,a.NetIncreFansCnt,a.TotalFansCnt,
		a.TotalFansCnt-sum(a.NetIncreFansCnt) over(partition by account order by a.Date_ID desc) AS TotalFansCnt_1
	FROM CTE_C a
	)
	,CTE_sum_Month AS(
	SELECT LEFT(a.Date_ID,6) AS YearMonth
	    ,a.Account
		,SUM(a.NewFansCnt) AS NewFansCnt,SUM(a.UnsubFansCnt) AS UnsubFansCnt,SUM(a.NetIncreFansCnt) AS NetIncreFansCnt
		,(SELECT ISNULL(SUM(b.TotalFansCnt_1),MAX(a.TotalFansCnt)) FROM CTE_sum b WHERE DATEADD(DAY,-1,CAST(b.Date_ID AS VARCHAR)) = ld.LastDay AND a.Account = b.Account) AS TotalFansCnt
		,ld.LastDay
	FROM CTE_sum a
	LEFT JOIN #LastDay ld ON LEFT(a.Date_ID,6) = ld.YearMonth
		GROUP BY LEFT(a.Date_ID,6),ld.YearMonth,ld.LastDay
				,a.Account
	)
	--select * from (
	SELECT a.YearMonth
		,a.Account
		--,CASE WHEN a.YearMonth = '201903' THEN (SELECT TotalFansCnt FROM CTE_sum_Month b WHERE a.Account = b.account AND b.YearMonth = '201902')+NewFansCnt ELSE  a.NewFansCnt END AS NewFansCnt
		,a.NewFansCnt --AS NewFansCnt_act
		,-1*a.UnsubFansCnt AS UnsubFansCnt
		,a.NetIncreFansCnt,
		--a.TotalFansCnt,b.TotalFansCnt_1,
		a.TotalFansCnt AS TotalFansCnt
	FROM CTE_sum_Month a
	UNION
	SELECT Monthkey  
		  ,Account
		  ,NewSub
		--  ,NewSub
		  ,0
		  ,NetIncreace
		  ,SUM(NewSub) OVER(ORDER BY Monthkey)
	FROM(
		SELECT 
			c.Monthkey,
			'Member' as Account,
			SUM(member_cnt) as NewSub,
		--	0,
			SUM(member_cnt) as NetIncreace
		--	sum(isnull(member_cnt,0)) over(order by c.Date_ID)
		FROM dm.[Dim_Calendar] c with(nolock)
		LEFT JOIN (SELECT 
			convert(varchar(8),join_date,112) as Date_ID,
			count(wx_open_id) as member_cnt
			FROM ODS.[ods].[SCRM_member_info]
			GROUP BY convert(varchar(8),join_date,112) )m
		on c.Datekey=m.Date_ID
		LEFT JOIN #LastDay ld ON LEFT(c.Datekey,6) = ld.YearMonth
		WHERE c.Datekey BETWEEN 20190301 AND CONVERT(VARCHAR(8),GETDATE(),112)	
		GROUP BY c.Monthkey
	) AS mem
	order by Account,YearMonth
	--) piv
	--UNPIVOT(Amount FOR [Type] IN ([NewFansCnt],[UnsubFansCnt])) AS T
	--where Account = 'foodunion'
	--order by YearMonth

END
GO
