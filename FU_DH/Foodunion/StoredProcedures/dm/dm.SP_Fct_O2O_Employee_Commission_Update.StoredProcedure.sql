USE [Foodunion]
GO
/****** Object:  StoredProcedure [dm].[SP_Fct_O2O_Employee_Commission_Update]    Script Date: 2019/7/31 9:59:32 ******/
DROP PROCEDURE [dm].[SP_Fct_O2O_Employee_Commission_Update]
GO
/****** Object:  StoredProcedure [dm].[SP_Fct_O2O_Employee_Commission_Update]    Script Date: 2019/7/31 9:59:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dm].[SP_Fct_O2O_Employee_Commission_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY
	TRUNCATE TABLE [dm].[Fct_O2O_Employee_Commission];
	INSERT INTO [dm].[Fct_O2O_Employee_Commission](
		[monthkey]
	   ,[employee_id]
	   ,[order_count]
	   ,[commission_amount]
	   ,[Create_Time]
	   ,[Create_By]
	   ,[Update_Time]
	   ,[Update_By]
	)
	SELECT distinct
        a.year*100+a.month AS monthkey,
        a.employee_id AS employee_id,
        ISNULL(b.order_cnt, 0) AS [order_count],
        ROUND(ISNULL(b.comm_amt, 0), 2) AS [commission_amount]
       ,GETDATE() AS [Create_Time]
       ,OBJECT_NAME(@@PROCID) AS [Create_By]
       ,GETDATE() AS [Update_Time]
       ,OBJECT_NAME(@@PROCID) AS [Update_By]
        FROM
        (SELECT 
                b.year AS year,
                b.month AS month,
                a.id AS employee_id
                FROM  ods.ods.SCRM_auth_employee a
				 CROSS JOIN (SELECT DISTINCT Year,Month FROM Foodunion.FU_EDW.Dim_Calendar) b) a
		LEFT JOIN (SELECT 
						hist.year AS year,
						hist.month AS month,
						hist.employee_id AS employee_id,
						hist.Order_Count AS order_cnt,
						hist.Commission_Amount AS comm_amt
					FROM  ods.ods.SCRM_Employee_month_commission_hist hist
					UNION ALL 
					SELECT 
						t.YEAR AS YEAR,
						t.MONTH AS MONTH,
						t.employee_id AS employee_id,
						t.order_cnt AS ORDER_CNT,
						CASE  WHEN (t.order_amt <= 8000) THEN (t.order_amt * 0.1)
							  WHEN ((t.order_amt > 8000) AND (t.order_amt <= 12000)) THEN (800 + ((t.order_amt - 8000) * 0.15))
							  WHEN ((t.order_amt > 12000) AND (t.order_amt <= 16000)) THEN (1400 + ((t.order_amt - 12000) * 0.20))
							  WHEN ((t.order_amt > 16000) AND (t.order_amt <= 20000)) THEN (2200 + ((t.order_amt - 16000) * 0.30))
							  WHEN (t.order_amt > 20000) THEN (3400 + ((t.order_amt - 20000) * 0.35))
							  ELSE 0 END + t.shipping_amt * 0.05 AS comm_amt
				    FROM (SELECT 
								 t.YEAR AS YEAR,
								 t.MONTH AS MONTH,
								 t.employee_id AS employee_id,
								 SUM(t.order_cnt) AS order_cnt,
								 SUM(t.order_amt) AS order_amt,
								 SUM(t.shipping_amt) AS shipping_amt
						  FROM  (SELECT 
									YEAR(GETDATE()) AS YEAR,
								    MONTH(GETDATE()) AS MONTH,
								    sob.fenxiao_employee_id AS employee_id,
								    (SUM(CASE WHEN (sob.order_create_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )) THEN 1 ELSE 0 END) 
									+SUM(CASE WHEN (sob.refund_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )) THEN -(1) ELSE 0 END)) AS order_cnt,
									(SUM(CASE WHEN (sob.order_create_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )) THEN (sob.pay_amount - sob.shipping_amount) ELSE 0 END) 
										+SUM(CASE WHEN (sob.refund_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )) THEN
										(CASE WHEN (sob.refund_state = '12') THEN (0 - (sob.pay_amount - sob.shipping_amount)) ELSE (0 - isnull(sob.refund_amount,0))	END)
										ELSE 0
									 END)) AS order_amt,
									 0 AS shipping_amt
								 FROM ods.ods.SCRM_order_base_info sob
								 WHERE
								     ((sob.pay_status = '2')
								         AND (sob.fenxiao_employee_id IS NOT NULL)
								         AND ((sob.order_create_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )))
								         OR (sob.refund_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )))
								 GROUP BY sob.fenxiao_employee_id
								 UNION ALL 
								 SELECT 
									 YEAR(GETDATE()) AS YEAR,
									 MONTH(GETDATE()) AS MONTH,
									 sob.operator_employee_id AS employee_id,
									 0 AS order_cnt,
									 0 AS order_amt,
									(SUM(CASE WHEN (sob.order_create_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )) THEN (sob.pay_amount - sob.shipping_amount) ELSE 0 END) 
									+ SUM(CASE WHEN (sob.refund_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )) THEN
												    (CASE WHEN (sob.refund_state = '12') THEN (0 - (sob.pay_amount - sob.shipping_amount)) ELSE (0 - isnull(sob.refund_amount,0)) END)
									 ELSE 0 END)) AS shipping_amt
							     FROM ods.ods.SCRM_order_base_info sob
							     WHERE
									(( sob.pay_status = '2')
									 AND (sob.express_type = '2')
									 AND (sob.order_status_str IN ('已完成' , '已发货'))
									 AND (sob.operator_employee_id IS NOT NULL)
									 AND ((sob.order_create_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )))
									 OR (sob.refund_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )))
								 GROUP BY sob.operator_employee_id
						  ) t
						  GROUP BY t.employee_id,t.YEAR,t.MONTH
					 ) t
		) b ON (a.year = b.year) AND (a.month = b.month) AND (a.employee_id = b.employee_id)

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END


	--select * from  ods.ods.SCRM_Employee_month_commission_hist hist
GO
