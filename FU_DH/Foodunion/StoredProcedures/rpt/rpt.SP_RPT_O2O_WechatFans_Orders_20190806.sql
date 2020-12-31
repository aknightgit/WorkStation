USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [rpt].[SP_RPT_O2O_WechatFans_Orders_20190806]
AS
BEGIN 
	
	--有分销员，用分销员手机号关联
	SELECT 
		ob.[order_no],
		ob.pay_amount,		
		ob.order_status,
		CONVERT(VARCHAR(8),ob.order_create_time,112) Order_Datekey,
		ob.order_create_time,
		ob.wx_union_id,
		ob.fenxiao_mobile,
		ob.pay_time,
		CONVERT(VARCHAR(8),ob.pay_time,112) Payment_Datekey,
		ob.consign_time,
		DATEDIFF("HOUR",ob.pay_time,ob.consign_time) as OrderFullfillPeriod,
		ob.delivery_province,
		ob.delivery_city,
		ob.delivery_district,
		ob.cycle
	FROM [dm].[Fct_O2O_Order_Base_info] ob  with(nolock)
	WHERE ob.pay_time is not null
	AND ob.fenxiao_mobile IN (SELECT Mobile FROM ODS.[ods].[SCRM_O2O_QRCodeMapping] WHERE Mobile IS NOT NULL)

	UNION ALL

	--无分销员手机号mapping，用QRKey做关联
	SELECT 
		ob.[order_no],
		ob.pay_amount,		
		ob.order_status,
		CONVERT(VARCHAR(8),ob.order_create_time,112) Order_Datekey,
		ob.order_create_time,
		ob.wx_union_id,
		CASE WHEN a.event_key LIKE '%youzan%' THEN replace(a.event_key,'qrscene_','')
					WHEN a.event_key like 'qrscene%' AND a.event_key NOT LIKE '%youzan%' THEN 'FGF'
					ELSE 'Organic' END AS fenxiao_mobile,  --use QRkey from non fenxiao
		ob.pay_time,
		CONVERT(VARCHAR(8),ob.pay_time,112) Payment_Datekey,
		ob.consign_time,
		DATEDIFF("HOUR",ob.pay_time,ob.consign_time) as OrderFullfillPeriod,
		ob.delivery_province,
		ob.delivery_city,
		ob.delivery_district,
		ob.cycle
	FROM [dm].[Fct_O2O_Order_Base_info] ob  with(nolock)
	LEFT JOIN [dm].[Fct_O2O_wxFans_info] i with(nolock) ON ob.outer_user_id = i.open_id AND  i.mp_id='297825819592626176'
	LEFT JOIN (		
			select open_id,	event_key, ROW_NUMBER() over(partition by open_id order by event_create_time) RID
			from [dm].[Fct_O2O_wxFans_event_record] with(nolock)
			where event_name ='subscribe' --and isnull(event_key,'')<>''
			) a
		ON i.open_id=a.open_id AND a.RID=1
	WHERE ob.pay_time is not null
	AND isnull(ob.fenxiao_mobile,'') NOT IN (SELECT Mobile FROM ODS.[ods].[SCRM_O2O_QRCodeMapping] WHERE Mobile IS NOT NULL);

END

--select *from[dm].[Fct_O2O_Order_Base_info]
--select *from [dm].[Fct_O2O_wxFans_info]
GO
