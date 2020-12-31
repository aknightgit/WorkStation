USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [rpt].[SP_RPT_O2O_WechatAccount_Daily]
AS
BEGIN 

	;WITH CTE_C AS(
	SELECT c.Datekey AS Date_ID,ca.Account,
		c.Date AS Date_NM,
		isnull(newfan.NewFansCnt,0) as NewFansCnt,
		isnull(unsub.UnsubCnt,0) AS UnsubFansCnt,
		isnull(newfan.NewFansCnt,0) - isnull(unsub.UnsubCnt,0) AS NetIncreFansCnt,
		COALESCE(ca.TotalFansCnt,0) AS TotalFansCnt
	FROM dm.[Dim_Calendar] c with(nolock)
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
	SELECT a.Date_ID,a.Date_NM,a.Account,
		a.NewFansCnt,a.UnsubFansCnt,a.NetIncreFansCnt,
		--a.TotalFansCnt,b.TotalFansCnt_1,
		isnull(b.TotalFansCnt_1,a.TotalFansCnt) AS TotalFansCnt
	FROM CTE_sum a
	LEFT JOIN CTE_sum b ON a.Date_NM = DATEADD("day",-1,b.Date_NM) AND a.Account=b.Account

	UNION

	SELECT 
		c.Datekey AS Date_ID,
		c.Date AS Date_NM,
		'Member' as Account,
		isnull(member_cnt,0) as NewSub,
		0,
		isnull(member_cnt,0) as NetIncreace,
		sum(isnull(member_cnt,0)) over(order by c.Datekey)
	FROM dm.[Dim_Calendar] c with(nolock)
	LEFT JOIN (SELECT 
		convert(varchar(8),join_date,112) as Date_ID,
		count(wx_open_id) as member_cnt
		FROM ODS.[ods].[SCRM_member_info]
		GROUP BY convert(varchar(8),join_date,112) )m
	on c.Datekey=m.Date_ID
	WHERE c.Datekey BETWEEN 20190301 AND CONVERT(VARCHAR(8),GETDATE(),112)	

	ORDER BY 1,2,3
END
GO
