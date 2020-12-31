USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [rpt].[SP_RPT_O2O_WechatFans_Daily]
AS
BEGIN 

	;WITH CTE_C AS(
	SELECT c.Datekey AS Date_ID,
		c.Date_Str AS Date_NM,
		o.Pay_Date,
		isnull(o.Order_Count,0) AS Order_Count,
		isnull(o.Fans_Count,0) AS Order_FansCount,
		isnull(o.Pay_Aount,0) AS Payment_Amount,
		isnull(o.Revenue,0) AS Revenue,
		isnull(o.weight_kg,0) AS Weight_kg,
		isnull(newfan.NewFansCnt,0) as NewFansCnt,
		isnull(unsub.UnsubCnt,0) AS UnsubFansCnt,
		isnull(newfan.NewFansCnt,0) - isnull(unsub.UnsubCnt,0) AS NetIncreFansCnt,
		COALESCE(ca.TotalFansCnt,0) AS TotalFansCnt,
		o.Regular_Customer_Count,
		o.Regular_Customer_Count14
	FROM dm.[Dim_Calendar] c with(nolock)
	LEFT JOIN (SELECT 
		CAST(i.pay_time AS DATE) AS Pay_Date,
		CONVERT(VARCHAR(8),i.pay_time,112) AS Date_ID,
		COUNT(distinct i.Order_No) AS Order_Count,
		COUNT(distinct isnull(i.Union_id,'')) AS Fans_Count,
		SUM(i.pay_Amount) AS Pay_Aount,
		SUM(CASE WHEN i.order_status='TRADE_SUCCESS' THEN pay_Amount ELSE 0 END) AS Revenue,
		SUM(i.Refund_Amount) AS Refund_Aount,
		SUM(weight_kg) AS Weight_kg,
		count(distinct t.union_id) Regular_Customer_Count,
		count(distinct t1.Regular_Customer_Last14) Regular_Customer_Count14
		FROM [dm].[Fct_O2O_Order_Base_info] i  with(nolock)	
		LEFT JOIN (
			SELECT order_id, SUM(QTY * pcs_cnt * delivery_cnt * Unit_Weight_g)/1000 as weight_kg
			FROM [dm].[Fct_O2O_Order_Detail_info]
			GROUP BY order_id
			)w ON i.order_id = w.order_id  ----销售产品重量
			-------------判断是否为老客户-----------
		LEFT JOIN (
			select datekey,
			union_id,
			ROW_NUMBER() over(partition by union_id order by datekey ) rid
			from [dm].[Fct_O2O_Order_Base_info] i 	
			where datekey is not null
				and union_id <>''
			) t on t.union_id=i.union_id and t.datekey<i.datekey and t.rid=1
      -----------------判断过去两周有过订单的老客户--------------
		LEFT JOIN (
			select distinct t.order_id,t.union_id,t1.union_id Regular_Customer_Last14 
			from [dm].[Fct_O2O_Order_Base_info] t
			LEFT JOIN 
			(
			select datekey,
			union_id
			from [dm].[Fct_O2O_Order_Base_info] t 	
			where datekey is not null
				and union_id <>''
				)t1 on t1.union_id=t.union_id and t1.datekey<t.datekey
				 and t1.datekey>=CONVERT(varchar(20),t.pay_time-14,112)
			) t1 on t1.order_id=i.order_id
				WHERE i.pay_time IS NOT NULL
				AND i.Order_Status<>'TRADE_CLOSED'
				GROUP BY CAST(pay_time AS DATE),CONVERT(VARCHAR(8),pay_time,112)
				--ORDER BY 1 DESC
		) o ON c.Datekey = o.Date_ID

			LEFT JOIN (SELECT in_day AS Date_ID,count(DISTINCT open_id) NewFansCnt
				FROM [dm].[Fct_O2O_wxFans_event_record] with(nolock)
				WHERE event_name = 'subscribe'
				AND mp_id = '297825819592626176'
				GROUP by in_day
				--ORDER by 1 desc;
				)newfan ON c.Datekey = newfan.Date_ID
			LEFT JOIN (SELECT in_day AS Date_ID,count(DISTINCT open_id) UnsubCnt
				FROM [dm].[Fct_O2O_wxFans_event_record] with(nolock)
				WHERE event_name = 'unsubscribe'
				AND mp_id = '297825819592626176'
				GROUP by in_day
				--ORDER by 1 desc;
				)unsub ON c.Datekey = unsub.Date_ID
			LEFT JOIN (select convert(varchar(8),getdate(),112) AS Date_ID,
				COUNT(DISTINCT open_id) TotalFansCnt
				from [dm].[Dim_O2O_Fans] with(nolock) where subscribe=1
				and Brand='FoodUnion') ca ON 1=1	--c.Date_ID = ca.Date_ID
			WHERE c.Datekey BETWEEN 20190301 AND CONVERT(VARCHAR(8),GETDATE(),112)
			)
	--ORDER BY 1 DESC
		,CTE_sum AS(
		SELECT a.Date_ID,a.Date_NM,a.Pay_Date,a.Order_Count,a.Order_FansCount,a.Payment_Amount,a.Revenue,a.Weight_kg
			,a.NewFansCnt,a.UnsubFansCnt,a.NetIncreFansCnt,a.TotalFansCnt,
			a.TotalFansCnt-sum(a.NetIncreFansCnt) over(order by a.Date_ID desc) AS TotalFansCnt_1,
			a.Regular_Customer_Count,a.Regular_Customer_Count14
		FROM CTE_C a
		)
		SELECT a.Date_ID,a.Date_NM,a.Pay_Date
		,a.Order_Count,a.Order_FansCount
		,a.Payment_Amount,a.Revenue,a.Weight_kg
		,a.NewFansCnt,a.UnsubFansCnt,a.NetIncreFansCnt,
			--a.TotalFansCnt,b.TotalFansCnt_1,
			isnull(b.TotalFansCnt_1,a.TotalFansCnt) AS TotalFansCnt,
			a.Regular_Customer_Count,a.Regular_Customer_Count14
		FROM CTE_sum a
		LEFT JOIN CTE_sum b ON a.Date_NM = DATEADD("day",-1,b.Date_NM)
		ORDER BY a.Date_ID DESC;
/*
	;WITH CTE_C AS(
	SELECT c.Date_ID,
		c.Date_NM,
		o.Pay_Date,
		isnull(o.Order_Count,0) AS Order_Count,
		isnull(o.Fans_Count,0) AS Order_FansCount,
		isnull(o.Pay_Aount,0) AS Payment_Amount,
		isnull(o.Revenue,0) AS Revenue,
		isnull(o.weight_kg,0) AS Weight_kg,
		isnull(newfan.NewFansCnt,0) as NewFansCnt,
		isnull(unsub.UnsubCnt,0) AS UnsubFansCnt,
		isnull(newfan.NewFansCnt,0) - isnull(unsub.UnsubCnt,0) AS NetIncreFansCnt,
		COALESCE(ca.TotalFansCnt,0) AS TotalFansCnt,
		o.Regular_Customer_Count,
		o.Regular_Customer_Count14
	FROM [FU_EDW].[Dim_Calendar] c with(nolock)
	LEFT JOIN (SELECT 
		CAST(pay_time AS DATE) AS Pay_Date,
		CONVERT(VARCHAR(8),pay_time,112) AS Date_ID,
		COUNT(distinct order_no) AS Order_Count,
		COUNT(distinct fans_id) AS Fans_Count,
		SUM(pay_Amount) AS Pay_Aount,
		SUM(CASE WHEN order_status='TRADE_SUCCESS' THEN pay_Amount ELSE 0 END) AS Revenue,
		SUM(Refund_Amount) AS Refund_Aount,
		SUM(weight_kg) AS Weight_kg,
		count(distinct t.wx_union_id) Regular_Customer_Count,
		count(distinct t1.Regular_Customer_Last14) Regular_Customer_Count14
		FROM [dm].[Fct_O2O_Order_Base_info] i  with(nolock)	
		LEFT JOIN (
			SELECT order_id, SUM(QTY * w1 * w2 * weight_g)/1000 as weight_kg
			FROM (
				SELECT 
					order_id
					,isnull(weight_g,0) weight_g
					,isnull(quantity,1) QTY
					,coalesce(dbo.split(dbo.split(scale,'*',2),'盒',1),dbo.split(dbo.split(scale,'周',2),'盒',1),1) as 'w1'
					,coalesce(dbo.split(dbo.split(subscriptiontype,'送',2),'次',1),dbo.split(dbo.split(subscriptiontype,'周',-1),'盒',1),1) as 'w2'
					,scale
					,subscriptiontype
				FROM [dm].[Fct_O2O_Order_Detail_info]
				)x
			GROUP BY order_id)w ON i.order_id = w.order_id  ----销售产品重量
			-------------判断是否为老客户-----------
		LEFT JOIN (
		select datekey,
		wx_union_id,
		ROW_NUMBER() over(partition by wx_union_id order by datekey ) rid
		from [dm].[Fct_O2O_Order_Base_info] i 	
		where datekey is not null
			and wx_union_id <>''
		) t on t.wx_union_id=i.wx_union_id and t.datekey<i.datekey and t.rid=1
      -----------------判断过去两周有过订单的老客户--------------
	LEFT JOIN (
	select distinct t.order_id,t.wx_union_id,t1.wx_union_id Regular_Customer_Last14 
	from [dm].[Fct_O2O_Order_Base_info] t
	LEFT JOIN 
	(
	select datekey,
	wx_union_id
	from [dm].[Fct_O2O_Order_Base_info] t 	
	where datekey is not null
		and wx_union_id <>''
		)t1 on t1.wx_union_id=t.wx_union_id and t1.datekey<t.datekey
		 and t1.datekey>=CONVERT(varchar(20),t.pay_time-14,112)
	) t1 on t1.order_id=i.order_id

			WHERE pay_time IS NOT NULL
			GROUP BY CAST(pay_time AS DATE),CONVERT(VARCHAR(8),pay_time,112)
			--ORDER BY 1 DESC
			) o ON c.Date_ID = o.Date_ID
		LEFT JOIN (SELECT in_day AS Date_ID,count(DISTINCT open_id) NewFansCnt
			FROM [dm].[Fct_O2O_wxFans_event_record] with(nolock)
			WHERE event_name = 'subscribe'
			AND mp_id = '297825819592626176'
			GROUP by in_day
			--ORDER by 1 desc;
			)newfan ON c.Date_ID = newfan.Date_ID
		LEFT JOIN (SELECT in_day AS Date_ID,count(DISTINCT open_id) UnsubCnt
			FROM [dm].[Fct_O2O_wxFans_event_record] with(nolock)
			WHERE event_name = 'unsubscribe'
			AND mp_id = '297825819592626176'
			GROUP by in_day
			--ORDER by 1 desc;
			)unsub ON c.Date_ID = unsub.Date_ID
		--LEFT JOIN (select in_day AS Date_ID,count(distinct open_id) UnsubCnt
		--	FROM  (select *, row_number() over(partition by in_day,open_id order by event_create_time desc) rid 
		--		 from [dm].[Fct_O2O_wxFans_event_record]
		--		 where mp_id='297825819592626176')uns
		--	where event_name ='unsubscribe'
		--	and rid = 1
		--	group by in_day
		--	)unsub ON c.Date_ID = unsub.Date_ID
		LEFT JOIN (select convert(varchar(8),getdate(),112) AS Date_ID,
			COUNT(DISTINCT open_id) TotalFansCnt
			from [dm].[Fct_O2O_wxFans_info] with(nolock) where subscribe=1
			and mp_id='297825819592626176') ca ON 1=1	--c.Date_ID = ca.Date_ID
		WHERE c.Date_ID BETWEEN 20190301 AND CONVERT(VARCHAR(8),GETDATE(),112)
		)
	--ORDER BY 1 DESC
		,CTE_sum AS(
		SELECT a.Date_ID,a.Date_NM,a.Pay_Date,a.Order_Count,a.Order_FansCount,a.Payment_Amount,a.Revenue,a.Weight_kg
			,a.NewFansCnt,a.UnsubFansCnt,a.NetIncreFansCnt,a.TotalFansCnt,
			a.TotalFansCnt-sum(a.NetIncreFansCnt) over(order by a.Date_ID desc) AS TotalFansCnt_1,
			a.Regular_Customer_Count,a.Regular_Customer_Count14
		FROM CTE_C a
		)
		SELECT a.Date_ID,a.Date_NM,a.Pay_Date
		,a.Order_Count,a.Order_FansCount
		,a.Payment_Amount,a.Revenue,a.Weight_kg
		,a.NewFansCnt,a.UnsubFansCnt,a.NetIncreFansCnt,
			--a.TotalFansCnt,b.TotalFansCnt_1,
			isnull(b.TotalFansCnt_1,a.TotalFansCnt) AS TotalFansCnt,
			a.Regular_Customer_Count,a.Regular_Customer_Count14
		FROM CTE_sum a
		LEFT JOIN CTE_sum b ON a.Date_NM = DATEADD("day",-1,b.Date_NM)
		ORDER BY a.Date_ID DESC;
		*/

END
GO
