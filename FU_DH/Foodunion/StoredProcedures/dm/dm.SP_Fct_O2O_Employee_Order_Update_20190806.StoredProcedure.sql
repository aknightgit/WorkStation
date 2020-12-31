USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_O2O_Employee_Order_Update_20190806]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dm].[SP_Fct_O2O_Employee_Order_Update_20190806]
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
			,[Fenxiao_Employee_id]
			,[fenxiao_name]
			,[Operator_Employee_id]
			,[operator_name]
			,[order_status_str]
			,[pay_amount]
			,[shipping_type]
			,[shipping_fee]
			,[refund_time]
			,[refund_state]
			,[refund_amount]
			,[Order_Amount]
			,[sales_commssion]
			,[Shipping_Amount]
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
			d.[Employee_name] as [Employee_name],
			Fenxiao_Employee_id,
			b.[Employee_name] as fenxiao_name,
			Operator_Employee_id,
			c.[Employee_name] as operator_name,		
			order_status_str,
			pay_amount,		
			case when express_type='0' then '快递发货' when express_type='2' then '同城配送' else '其他' end AS shipping_type,
			shipping_fee,
			refund_time,
			case when refund_state='12' then '全部退单' when refund_state='2' then '部分退单' else '正常' end as refund_state,
			refund_amount,
			t.Order_Amount AS Order_Amount,
			CASE  WHEN (t.Order_Amount <= 8000) THEN (t.Order_Amount * 0.1)
								  WHEN ((t.Order_Amount > 8000) AND (t.Order_Amount <= 12000)) THEN (800 + ((t.Order_Amount - 8000) * 0.15))
								  WHEN ((t.Order_Amount > 12000) AND (t.Order_Amount <= 16000)) THEN (1400 + ((t.Order_Amount - 12000) * 0.20))
								  WHEN ((t.Order_Amount > 16000) AND (t.Order_Amount <= 20000)) THEN (2200 + ((t.Order_Amount - 16000) * 0.30))
								  WHEN (t.Order_Amount > 20000) THEN (3400 + ((t.Order_Amount - 20000) * 0.35))
								  ELSE 0 END AS sales_commssion,		 
			t.Shipping_Amount AS Shipping_Amount,
			t.Shipping_Amount*0.05 AS shipping_commssion
		   ,GETDATE() AS [Create_Time]
		   ,@ProcName AS [Create_By]
		   ,GETDATE() AS [Update_Time]
		   ,@ProcName AS [Update_By]
	FROM
			(
					SELECT
						Fenxiao_Employee_id,
						Operator_Employee_id,
						express_type,
						order_no,
						order_create_time,
						pay_amount,
						Shipping_Amount AS shipping_fee,
						refund_time,
						refund_state,
						refund_amount,
						order_status_str,
						sob.Fenxiao_Employee_id AS employee_id,
						sob.outer_user_id AS user_openid,
						CASE WHEN sob.refund_time IS NOT NULL THEN 0 ELSE 1 END AS order_cnt,
						CASE WHEN sob.refund_state = '12' AND sob.refund_time IS NOT NULL THEN 0
							ELSE sob.pay_amount - sob.Shipping_Amount - isnull(sob.refund_amount,0)	END  AS Order_Amount,
						0 AS Shipping_Amount
					FROM ods.ods.SCRM_order_base_info sob
					WHERE sob.pay_status = '2'
						AND sob.Fenxiao_Employee_id IS NOT NULL			
								
					UNION ALL

					SELECT
						Fenxiao_Employee_id,
						Operator_Employee_id,
						express_type,
						order_no,
						order_create_time,
						pay_amount,
						Shipping_Amount AS shipping_fee,
						refund_time,
						refund_state,
						refund_amount,
						order_status_str,
						sob.Operator_Employee_id AS employee_id,
						sob.outer_user_id AS user_openid,
						0 AS order_cnt,
						0 AS Order_Amount,
						CASE WHEN (sob.refund_state = '12') THEN 0
							ELSE sob.pay_amount - sob.Shipping_Amount - isnull(sob.refund_amount,0)	END AS Shipping_Amount
					FROM ods.ods.SCRM_order_base_info sob
					WHERE sob.pay_status = '2'
						AND sob.express_type = '2'
						AND order_status_str in ('已完成','已发货')
						AND sob.Operator_Employee_id IS NOT NULL

	
				) t
	left join  ods.ods.SCRM_youzan_employee b on t.Fenxiao_Employee_id=b.employee_id
	left join  ods.ods.SCRM_youzan_employee c on t.Operator_Employee_id=c.employee_id
	left join  ods.ods.SCRM_youzan_employee d on t.employee_id=d.employee_id
	
	---------------------------------------------
	-- new rpt table 
	Truncate Table [rpt].[O2O_Employee_Order];
	INSERT INTO [rpt].[O2O_Employee_Order]
           ([Datekey]
           ,[Order_no]
           ,[Order_CreateTime]
           ,[User_UnionID]
           ,[User_OpenID]
           ,[Fenxiao_EmployeeID]
           ,[Fenxiao_EmployeeName]
           ,[Operator_EmployeeID]
           ,[Operator_EmployeeName]
           ,[Order_Status]
           ,[Pay_Amount]
           ,[Shipping_Type]
           ,[Shipping_Fee]
           ,[Refund_Time]
           ,[Refund_State]
           ,[Refund_Amount]
           ,[Order_Amount]
           ,[Sales_Commission]
           ,[Shipping_Amount]
           ,[Shipping_Commission]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT
			CONVERT(varchar(8),t.order_create_time, 112) AS [Datekey],
			--t.employee_id AS [Employee_ID],	
			order_no as [Order_no],
			order_create_time as [Order_Createtime],
			t.Union_id,
			t.Open_id,			
			--d.[Employee_name] as [Employee_name],
			Fenxiao_Employee_id,
			b.[Employee_name] as fenxiao_name,
			Operator_Employee_id,
			c.[Employee_name] as operator_name,		
			order_status_str,
			pay_amount,		
			Express_Type,
			Shipping_Fee,
			Refund_Time,
			Refund_State,
			Refund_Amount,
			Order_Amount,
			CASE  WHEN (t.Order_Amount <= 8000) THEN (t.Order_Amount * 0.1)
								  WHEN ((t.Order_Amount > 8000) AND (t.Order_Amount <= 12000)) THEN (800 + ((t.Order_Amount - 8000) * 0.15))
								  WHEN ((t.Order_Amount > 12000) AND (t.Order_Amount <= 16000)) THEN (1400 + ((t.Order_Amount - 12000) * 0.20))
								  WHEN ((t.Order_Amount > 16000) AND (t.Order_Amount <= 20000)) THEN (2200 + ((t.Order_Amount - 16000) * 0.30))
								  WHEN (t.Order_Amount > 20000) THEN (3400 + ((t.Order_Amount - 20000) * 0.35))
								  ELSE 0 END AS sales_commssion,		 
			t.Shipping_Amount AS Shipping_Amount,
			t.Shipping_Amount*0.05 AS shipping_commssion
		   ,GETDATE() AS [Create_Time]
		   ,@ProcName AS [Create_By]
		   ,GETDATE() AS [Update_Time]
		   ,@ProcName AS [Update_By]
	FROM
			(
					SELECT
						Fenxiao_Employee_id,
						Operator_Employee_id,
						Express_Type,
						Order_No,
						Order_Create_Time,
						Pay_Amount,
						Shipping_Amount AS Shipping_Fee,
						Refund_Time,
						Refund_State,
						Refund_Amount,
						Order_Status_Str,
						Union_id,
						Open_id,
						CASE WHEN Refund_Time IS NOT NULL THEN 0 ELSE 1 END AS Order_Cnt,
						CASE WHEN Refund_State = '全额退款成功' AND Refund_Time IS NOT NULL THEN 0
							ELSE Pay_Amount - Shipping_Amount - isnull(Refund_Amount,0)	END  AS Order_Amount,
						0 AS Shipping_Amount
					FROM [dm].[Fct_O2O_Order_Base_info_new] sob
					WHERE sob.Pay_Status = '已支付'
						AND sob.Fenxiao_Employee_id IS NOT NULL			
								
					UNION ALL

					SELECT
						Fenxiao_Employee_id,
						Operator_Employee_id,
						Express_Type,
						Order_No,
						Order_Create_Time,
						Pay_Amount,
						Shipping_Amount AS Shipping_Fee,
						Refund_Time,
						Refund_State,
						Refund_Amount,
						Order_Status_Str,
						Union_id,
						Open_id,
						0 AS Order_Cnt,
						0 AS Order_Amount,
						CASE WHEN (Refund_State = '全额退款成功') THEN 0
							ELSE Pay_Amount - Shipping_Amount - isnull(Refund_Amount,0)	END AS Shipping_Amount
					FROM [dm].[Fct_O2O_Order_Base_info_new] sob
					WHERE Pay_Status = '已支付'
						AND Express_Type = '同城配送'
						AND Order_Status_Str in ('已完成','已发货')
						AND Operator_Employee_id IS NOT NULL

	
				) t
	LEFT JOIN  dm.Dim_O2O_Employee b on t.Fenxiao_Employee_id=b.employee_id
	LEFT JOIN  dm.Dim_O2O_Employee c on t.Operator_Employee_id=c.employee_id
	--left join  ods.ods.SCRM_youzan_employee d on t.employee_id=d.employee_id
	;

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
