USE [Foodunion]
GO
/****** Object:  StoredProcedure [dm].[SP_Fct_O2O_Employee_Order_Update]    Script Date: 2019/7/31 9:59:32 ******/
DROP PROCEDURE [dm].[SP_Fct_O2O_Employee_Order_Update]
GO
/****** Object:  StoredProcedure [dm].[SP_Fct_O2O_Employee_Order_Update]    Script Date: 2019/7/31 9:59:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dm].[SP_Fct_O2O_Employee_Order_Update]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	TRUNCATE TABLE [dm].[Fct_O2O_Employee_Order];

	INSERT INTO [dm].[Fct_O2O_Employee_Order](
			[Datekey]
			,[Employee_ID]
			,[Order_no]
			,[Order_Create_time]
			,[User_OpenID]
			,[Employee_name]
			,[fenxiao_employee_id]
			,[fenxiao_name]
			,[operator_employee_id]
			,[operator_name]
			,[order_status_str]
			,[pay_amount]
			,[shipping_type]
			,[shipping_fee]
			,[refund_time]
			,[refund_state]
			,[refund_amount]
			,[order_amount]
			,[sales_commssion]
			,[shipping_amount]
			,[shipping_commssion]
			,[Create_Time]
			,[Create_By]
			,[Update_Time]
			,[Update_By]
	)
	SELECT
			CONVERT(varchar(8),t.order_create_time, 112) AS [Datekey],
			t.employee_id AS [Employee_ID],	
			order_no as [Order_no],
			order_create_time as [Order_Create_time],
			t.user_openid,			
			d.name as [Employee_name],
			fenxiao_employee_id,
			b.name as fenxiao_name,
			operator_employee_id,
			c.name as operator_name,		
			order_status_str,
			pay_amount,		
			case when express_type='0' then '快递发货' when express_type='2' then '同城配送' else '其他' end AS shipping_type,
			shipping_fee,
			refund_time,
			case when refund_state='12' then '全部退单' when refund_state='2' then '部分退单' else '正常' end as refund_state,
			refund_amount,
			t.order_amount AS order_amount,
			CASE  WHEN (t.order_amount <= 8000) THEN (t.order_amount * 0.1)
								  WHEN ((t.order_amount > 8000) AND (t.order_amount <= 12000)) THEN (800 + ((t.order_amount - 8000) * 0.15))
								  WHEN ((t.order_amount > 12000) AND (t.order_amount <= 16000)) THEN (1400 + ((t.order_amount - 12000) * 0.20))
								  WHEN ((t.order_amount > 16000) AND (t.order_amount <= 20000)) THEN (2200 + ((t.order_amount - 16000) * 0.30))
								  WHEN (t.order_amount > 20000) THEN (3400 + ((t.order_amount - 20000) * 0.35))
								  ELSE 0 END AS sales_commssion,		 
			t.shipping_amount AS shipping_amount,
			t.shipping_amount*0.05 AS shipping_commssion
		   ,GETDATE() AS [Create_Time]
		   ,OBJECT_NAME(@@PROCID) AS [Create_By]
		   ,GETDATE() AS [Update_Time]
		   ,OBJECT_NAME(@@PROCID) AS [Update_By]
	FROM
			(
					SELECT
						fenxiao_employee_id,
						operator_employee_id,
						express_type,
						order_no,
						order_create_time,
						pay_amount,
						shipping_amount AS shipping_fee,
						refund_time,
						refund_state,
						refund_amount,
						order_status_str,
						sob.fenxiao_employee_id AS employee_id,
						sob.outer_user_id AS user_openid,
						CASE WHEN sob.refund_time IS NOT NULL THEN 0 ELSE 1 END AS order_cnt,
						CASE WHEN sob.refund_state = '12' AND sob.refund_time IS NOT NULL THEN 0
							ELSE sob.pay_amount - sob.shipping_amount - isnull(sob.refund_amount,0)	END  AS order_amount,
						0 AS shipping_amount
					FROM ods.ods.SCRM_order_base_info sob
					WHERE sob.pay_status = '2'
						AND sob.fenxiao_employee_id IS NOT NULL			
								
					UNION ALL

					SELECT
						fenxiao_employee_id,
						operator_employee_id,
						express_type,
						order_no,
						order_create_time,
						pay_amount,
						shipping_amount AS shipping_fee,
						refund_time,
						refund_state,
						refund_amount,
						order_status_str,
						sob.operator_employee_id AS employee_id,
						sob.outer_user_id AS user_openid,
						0 AS order_cnt,
						0 AS order_amount,
						CASE WHEN (sob.refund_state = '12') THEN 0
							ELSE sob.pay_amount - sob.shipping_amount - isnull(sob.refund_amount,0)	END AS shipping_amount
					FROM ods.ods.SCRM_order_base_info sob
					WHERE sob.pay_status = '2'
						AND sob.express_type = '2'
						AND order_status_str in ('已完成','已发货')
						AND sob.operator_employee_id IS NOT NULL

	
				) t
	left join  ods.ods.SCRM_auth_employee b on t.fenxiao_employee_id=b.id
	left join  ods.ods.SCRM_auth_employee c on t.operator_employee_id=c.id
	left join  ods.ods.SCRM_auth_employee d on t.employee_id=d.id
	
	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END


--select * from ods.ods.SCRM_order_base_info
--where order_no='E20190312202657068500023'
--select * from ods.ods.SCRM_order_base_item
GO
