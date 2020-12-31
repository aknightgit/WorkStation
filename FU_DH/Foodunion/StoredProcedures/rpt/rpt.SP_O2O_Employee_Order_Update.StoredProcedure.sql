USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_O2O_Employee_Order_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [rpt].[SP_O2O_Employee_Order_Update]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	
	---------------------------------------------
	-- 以订单成功关闭时间，统计佣金
	Truncate Table [rpt].[O2O_Employee_Order];
	INSERT INTO [rpt].[O2O_Employee_Order]
           ([Datekey]
           ,[Order_no]
           ,[Order_CreateTime]
		   ,[Order_CloseTime]
           ,[User_UnionID]
           ,[User_OpenID]
		   ,[Employee_ID]
		   ,[Employee_name]
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
			CONVERT(varchar(8),t.Order_Close_Time, 112) AS [Datekey],			
			order_no as [Order_no],
			order_create_time as [Order_Createtime],
			Order_Close_Time as [Order_CloseTime],
			t.Union_id,
			t.Open_id,			
			e.employee_id AS [Employee_ID],	
			e.[Employee_name] as [Employee_name],
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
								  ELSE 0 END AS sales_commssion,		 --应该没有用，comm计算在Month表
			t.Shipping_Amount AS Shipping_Amount,
			t.Shipping_Amount*0.05 AS shipping_commssion
		   ,GETDATE() AS [Create_Time]
		   ,@ProcName AS [Create_By]
		   ,GETDATE() AS [Update_Time]
		   ,@ProcName AS [Update_By]
	FROM
			(
			SELECT
				Fenxiao_Employee_id AS Employee_ID,
				Fenxiao_Employee_id,
				Operator_Employee_id,
				Express_Type,
				Order_No,
				Order_Create_Time,
				Order_Close_Time,
				Pay_Amount,
				Shipping_Amount AS Shipping_Fee,
				Refund_Time,
				Refund_State,
				Refund_Amount,
				Order_Status_Str,
				Union_id,
				Open_id,
				CASE WHEN Refund_State = '全额退款成功' THEN 0 ELSE 1 END AS Order_Cnt,
				CASE WHEN Refund_State = '全额退款成功' AND Refund_Time IS NOT NULL THEN 0
					ELSE Pay_Amount - Shipping_Amount - isnull(Refund_Amount,0)	END  AS Order_Amount,
				0 AS Shipping_Amount
			FROM [dm].[Fct_O2O_Order_Base_info] sob WITH(NOLOCK)
			WHERE sob.Pay_Status = '已支付'
				AND isnull(sob.Fenxiao_Employee_id,'00000000000') <> '00000000000'		
				AND sob.order_status_str NOT IN ('已关闭')	
				AND sob.Order_Create_Time >= '2019-8-1'			 --从2019-8月开始从新计算佣金		
				AND sob.Order_Close_Time IS NOT NULL
						
			UNION ALL

			SELECT
				Operator_Employee_id AS Employee_ID,
				Fenxiao_Employee_id,
				Operator_Employee_id,
				Express_Type,
				Order_No,
				Order_Create_Time,
				Order_Close_Time,
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
			FROM [dm].[Fct_O2O_Order_Base_info] sob WITH(NOLOCK)
			WHERE Pay_Status = '已支付'
				AND Express_Type in ('同城配送','到店自提')
				AND Order_Status_Str in ('已完成','已发货')
				AND Operator_Employee_id IS NOT NULL
				AND sob.Order_Create_Time >= '2019-8-1'			 --从2019-8月开始从新计算佣金
				AND sob.Order_Close_Time IS NOT NULL
 				) t
	LEFT JOIN  dm.Dim_O2O_Employee b on t.Fenxiao_Employee_id=b.employee_id
	LEFT JOIN  dm.Dim_O2O_Employee c on t.Operator_Employee_id=c.employee_id
	LEFT JOIN  dm.Dim_O2O_Employee e on t.Employee_ID=e.employee_id  --计算佣金合并
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
