USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [rpt].[SP_RPT_O2O_WechatFans_20190806]
AS
BEGIN 
	
	SELECT wfi.open_id,
		wfi.union_id,
		wfi.subscribe, 
		wfi.subscribeday,
		wfi.gender,
		wfi.province,
		isnull(qr.Channel,'Unknow') as Channel,
		isnull(qr.QRCode,wfi.QRKey) as QRCode,
		isnull(cast(qr.Mobile as varchar(20)),wfi.QRKey) as Mobile
		--ob.[order_no],
		--ob.pay_amount,
		--CASE WHEN ob.[order_no] is not null THEN wfi.open_id ELSE NULL END AS User_OpenID,
		--ob.order_status,
		--CONVERT(VARCHAR(8),ob.order_create_time,112) Order_Datekey,
		--ob.order_create_time,
		--ob.pay_time,
		--ob.consign_time,
		--DATEDIFF("HOUR",ob.pay_time,ob.consign_time) as OrderFullfillPeriod,
		--ob.delivery_province,
		--ob.delivery_city,
		--ob.delivery_district
	FROM (SELECT 
				CASE WHEN a.event_key LIKE '%youzan%' THEN replace(a.event_key,'qrscene_','')
					WHEN a.event_key LIKE 'qrscene%' AND a.event_key NOT LIKE '%youzan%' THEN 'FGF'
					ELSE 'Organic' END AS QRKey
				,i.open_id
				,i.union_id
				,i.subscribe
				,convert(varchar(8),i.subscribe_time,112) subscribeday
				,CASE i.gender WHEN 1 THEN 'Male' WHEN 2 THEN 'Female' ELSE 'Unknonw' END AS gender
				,CASE i.province WHEN '' THEN 'Unknown' ELSE i.province END AS province
				,i.city
			FROM [dm].[Fct_O2O_wxFans_info] i with(nolock)
			LEFT JOIN (		
					select open_id,	event_key, ROW_NUMBER() over(partition by open_id order by event_create_time) RID
					from [dm].[Fct_O2O_wxFans_event_record] with(nolock)
					where event_name ='subscribe' --and isnull(event_key,'')<>''
					) a
			ON i.open_id=a.open_id AND a.RID=1
			WHERE mp_id='297825819592626176'
			--AND i.open_id='osXC9w_C58phWIm3Ro4fg8nUg1kY'		
			--order by 1
		)wfi
	LEFT JOIN ODS.[ods].[SCRM_O2O_QRCodeMapping] qr with(nolock)
	ON qr.QRkey = wfi.QRKey
	--LEFT JOIN ODS.[ods].[SCRM_order_base_info] ob 
	--ON ob.pay_time is not null
	--AND qr.Mobile = ob.fenxiao_mobile
	--ON wfi.open_id = ob.outer_user_id AND ob.pay_time is not null --paid order only
	--order by Order_Datekey desc
END

GO
