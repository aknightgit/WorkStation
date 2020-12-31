USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_O2O_FansCnt_byKOL_byMonth]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [rpt].[SP_RPT_O2O_FansCnt_byKOL_byMonth]
AS
BEGIN


	--����active
	DROP TABLE IF EXISTS #ActiveFans_0;
	SELECT CONVERT(VARCHAR(6),GETDATE(),112) AS Monthkey
		,ISNULL(Channel,'Not Recognized') Channel
		,ISNULL(KOL_EmployeeName,'Not Recognized') KOL_EmployeeName
		,'ActiveFans' AS Item
		,COUNT(1) ActiveFans
	INTO #ActiveFans_0
	FROM dm.Dim_O2O_Fans f
	WHERE f.subscribe=1
	GROUP BY Channel,KOL_EmployeeName
	ORDER BY 4 DESC


	--ÿ����
	DROP TABLE IF EXISTS #follow;
	SELECT LEFT(er0.in_day,6) AS Monthkey
		,ISNULL(f.Channel,'Not Recognized') Channel
		,ISNULL(f.KOL_EmployeeName,'Not Recognized') KOL_EmployeeName
		,'Follow' AS Item
		,COUNT(DISTINCT er0.open_id) AS Follow
	INTO #follow
	FROM dm.Dim_O2O_Fans f
	JOIN dm.Fct_O2O_wxFans_event_record er0 ON f.open_id=er0.open_id 
	WHERE er0.event_name='subscribe' AND er0.in_day>=CONVERT(VARCHAR(8),DATEADD("Month",-6,GETDATE()),112)
	GROUP BY LEFT(er0.in_day,6),Channel,KOL_EmployeeName
	ORDER BY 2,3,1 DESC

	DROP TABLE IF EXISTS #follow_full; --����ȱʧ�·�
	SELECT c.Year_Month AS Monthkey,list.Channel,list.KOL_EmployeeName,'Follow' AS Item, isnull(f.follow,0) AS follow
	INTO #follow_full
	FROM (SELECT Channel,KOL_EmployeeName FROM #follow
			UNION 
		  SELECT Channel,KOL_EmployeeName FROM #ActiveFans_0) list
	JOIN (SELECT DISTINCT Year_Month FROM FU_EDW.Dim_Calendar WHERE Date_ID BETWEEN CONVERT(VARCHAR(8),DATEADD("Month",-6,GETDATE()),112) AND CONVERT(VARCHAR(8),GETDATE(),112))c ON 1 = 1
	LEFT JOIN #follow f ON c.Year_Month=f.Monthkey AND list.Channel=f.Channel AND list.KOL_EmployeeName=f.KOL_EmployeeName

	--SELECT * FROM #follow

	--ÿ�¼�
	DROP TABLE IF EXISTS #unfollow;
	SELECT LEFT(er0.in_day,6) AS Monthkey
		,ISNULL(f.Channel,'Not Recognized') Channel
		,ISNULL(f.KOL_EmployeeName,'Not Recognized') KOL_EmployeeName
		,'UnFollow' AS Item
		,COUNT(DISTINCT er0.open_id) AS UnFollow
	INTO #unfollow
	FROM dm.Dim_O2O_Fans f
	JOIN dm.Fct_O2O_wxFans_event_record er0 ON f.open_id=er0.open_id 
	WHERE er0.event_name='unsubscribe' AND er0.in_day>=CONVERT(VARCHAR(8),DATEADD("Month",-6,GETDATE()),112)
	GROUP BY LEFT(er0.in_day,6),Channel,KOL_EmployeeName
	ORDER BY 4 DESC

	--SELECT TOP 100 * FROM dm.Fct_O2O_wxFans_event_record

	--SELECT * from #ActiveFans_0 order by 1,2,3

	--��ʷ��ĩ��Ծ
	DROP TABLE IF EXISTS #pastFans;
	SELECT 
		CurrentMonth
		,Channel
		,KOL_EmployeeName	
		,PastMonth
		,MAX(ActiveFans) ActiveFans
		,SUM(Follow) Follow
		,SUM(UnFollow) UnFollow
		,MAX(isnull(ActiveFans,0)) - SUM(isnull(Follow,0)) + SUM(isnull(UnFollow,0)) AS FansCnt	
	INTO #pastFans
	FROM(
		SELECT a.Monthkey AS CurrentMonth
			,a.Channel
			,a.KOL_EmployeeName
			,a.ActiveFans
			,c.Year_Month AS PastMonth
			,f.Monthkey AS FollowMonth
			,isnull(f.Follow,0) AS Follow
			,isnull(u.Monthkey,f.Monthkey) AS UnFollowMonth
			,isnull(u.UnFollow,0) AS UnFollow
		FROM #ActiveFans_0 a
		JOIN (SELECT DISTINCT Year_Month FROM FU_EDW.Dim_Calendar WHERE Date_ID BETWEEN CONVERT(VARCHAR(8),DATEADD("Month",-6,GETDATE()),112) AND CONVERT(VARCHAR(8),GETDATE(),112))c ON 1 = 1
		LEFT JOIN #follow_full f ON c.Year_Month<f.Monthkey AND a.Channel=f.Channel AND a.KOL_EmployeeName=f.KOL_EmployeeName
		LEFT JOIN #unfollow u ON f.Monthkey=u.Monthkey AND u.Channel=f.Channel AND u.KOL_EmployeeName=f.KOL_EmployeeName
		--WHERE a.KOL_EmployeeName='��С��'
		--ORDER BY 1,2,3,4
	)a
	GROUP BY CurrentMonth
		,Channel
		,KOL_EmployeeName	
		,PastMonth


	SELECT Monthkey,Channel,KOL_EmployeeName,Item,isnull(cast(ActiveFans as int),0) AS FansCnt FROM #ActiveFans_0  --��ǰ��Ծ��˿
	UNION 
	SELECT Monthkey,Channel,KOL_EmployeeName,Item,isnull(Follow,0) AS FansCnt FROM #follow --ÿ������
	WHERE Monthkey > CONVERT(VARCHAR(8),DATEADD("Month",-6,GETDATE()),112) 
	UNION
	SELECT Monthkey,Channel,KOL_EmployeeName,Item,isnull(UnFollow,0) AS FansCnt FROM #unfollow --ÿ�¼���
	WHERE Monthkey > CONVERT(VARCHAR(8),DATEADD("Month",-6,GETDATE()),112)
	UNION
	SELECT PastMonth,Channel,KOL_EmployeeName,'ActiveFans' AS Item, isnull(FansCnt,0) FROM #pastFans 
	WHERE PastMonth<CONVERT(VARCHAR(6),GETDATE(),112) --��ʷ��Ծ
	AND isnull(FansCnt,0)>=0


	--ORDER BY 5 


   END
GO
