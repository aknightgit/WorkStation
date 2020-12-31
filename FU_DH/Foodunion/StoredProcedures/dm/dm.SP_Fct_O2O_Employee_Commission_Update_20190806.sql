USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dm].[SP_Fct_O2O_Employee_Commission_Update_20190806]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY
	
	--[dm].[Fct_O2O_Employee_Commission]
	TRUNCATE TABLE [dm].[Fct_O2O_Employee_Commission];

	INSERT INTO [dm].[Fct_O2O_Employee_Commission](
		[monthkey]
	   ,[Employee_ID]
	   ,[Employee_Name]
	   ,[Order_Count]
	   ,[Commission_Amount]
	   ,[Create_Time]
	   ,[Create_By]
	   ,[Update_Time]
	   ,[Update_By]
	)
	SELECT distinct
        a.year*100+a.month AS monthkey,
        a.Employee_ID AS Employee_ID,
		a.[Employee_Name] as [Employee_Name],
        ISNULL(b.Order_Cnt, 0) AS [Order_Count],
        ROUND(ISNULL(b.Comm_Amt, 0), 2) AS [Commission_Amount]
       ,GETDATE() AS [Create_Time]
       ,OBJECT_NAME(@@PROCID) AS [Create_By]
       ,GETDATE() AS [Update_Time]
       ,OBJECT_NAME(@@PROCID) AS [Update_By]
        FROM
        (SELECT 
				b.year AS year,
				b.month AS month,
				a.Employee_ID AS Employee_ID,
				a.[Employee_Name] as [Employee_Name]
            FROM  ods.ods.SCRM_youzan_employee a
			CROSS JOIN (SELECT DISTINCT Year,Month FROM Foodunion.FU_EDW.Dim_Calendar) b
		) a
		LEFT JOIN (SELECT 
						hist.year AS year,
						hist.month AS month,
						hist.Employee_ID AS Employee_ID,
						hist.Order_Count AS Order_Cnt,
						hist.Commission_Amount AS Comm_Amt
					FROM  ods.ods.SCRM_Employee_month_commission_hist hist
					UNION ALL 
					SELECT 
						t.YEAR AS YEAR,
						t.MONTH AS MONTH,
						t.Employee_ID AS Employee_ID,
						t.Order_Cnt AS Order_Cnt,
						CASE  WHEN (t.Order_Amt <= 8000) THEN (t.Order_Amt * 0.1)
							  WHEN ((t.Order_Amt > 8000) AND (t.Order_Amt <= 12000)) THEN (800 + ((t.Order_Amt - 8000) * 0.15))
							  WHEN ((t.Order_Amt > 12000) AND (t.Order_Amt <= 16000)) THEN (1400 + ((t.Order_Amt - 12000) * 0.20))
							  WHEN ((t.Order_Amt > 16000) AND (t.Order_Amt <= 20000)) THEN (2200 + ((t.Order_Amt - 16000) * 0.30))
							  WHEN (t.Order_Amt > 20000) THEN (3400 + ((t.Order_Amt - 20000) * 0.35))
							  ELSE 0 END + t.Shipping_Amt * 0.05 AS Comm_Amt
				    FROM (SELECT 
								 t.YEAR AS YEAR,
								 t.MONTH AS MONTH,
								 t.Employee_ID AS Employee_ID,
								 SUM(t.Order_Cnt) AS Order_Cnt,
								 SUM(t.Order_Amt) AS Order_Amt,
								 SUM(t.Shipping_Amt) AS Shipping_Amt
						  FROM  (SELECT 
									YEAR(GETDATE()) AS YEAR,
								    MONTH(GETDATE()) AS MONTH,
								    sob.fenxiao_Employee_ID AS Employee_ID,
								    (SUM(CASE WHEN (sob.order_create_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )) THEN 1 ELSE 0 END) 
									+SUM(CASE WHEN (sob.refund_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )) THEN -(1) ELSE 0 END)) AS Order_Cnt,
									(SUM(CASE WHEN (sob.order_create_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )) THEN (sob.pay_amount - sob.shipping_amount) ELSE 0 END) 
										+SUM(CASE WHEN (sob.refund_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )) THEN
										(CASE WHEN (sob.refund_state = '12') THEN (0 - (sob.pay_amount - sob.shipping_amount)) ELSE (0 - isnull(sob.refund_amount,0))	END)
										ELSE 0
									 END)) AS Order_Amt,
									 0 AS Shipping_Amt
								 FROM ods.ods.SCRM_order_base_info sob
								 WHERE
								     ((sob.pay_status = '2')
								         AND (sob.fenxiao_Employee_ID IS NOT NULL)
								         AND ((sob.order_create_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )))
								         OR (sob.refund_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )))
								 GROUP BY sob.fenxiao_Employee_ID
								 UNION ALL 
								 SELECT 
									 YEAR(GETDATE()) AS YEAR,
									 MONTH(GETDATE()) AS MONTH,
									 sob.Operator_Employee_ID AS Employee_ID,
									 0 AS Order_Cnt,
									 0 AS Order_Amt,
									(SUM(CASE WHEN (sob.order_create_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )) THEN (sob.pay_amount - sob.shipping_amount) ELSE 0 END) 
									+ SUM(CASE WHEN (sob.refund_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )) THEN
												    (CASE WHEN (sob.refund_state = '12') THEN (0 - (sob.pay_amount - sob.shipping_amount)) ELSE (0 - isnull(sob.refund_amount,0)) END)
									 ELSE 0 END)) AS Shipping_Amt
							     FROM ods.ods.SCRM_order_base_info sob
							     WHERE
									(( sob.pay_status = '2')
									 AND (sob.express_type = '2')
									 AND (sob.order_status_str IN ('已完成' , '已发货'))
									 AND (sob.Operator_Employee_ID IS NOT NULL)
									 AND ((sob.order_create_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )))
									 OR (sob.refund_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )))
								 GROUP BY sob.Operator_Employee_ID
						  ) t
						  GROUP BY t.Employee_ID,t.YEAR,t.MONTH
					 ) t
		) b ON (a.year = b.year) AND (a.month = b.month) AND (a.Employee_ID = b.Employee_ID)
		;


	----[rpt].[O2O_Employee_Commission]
	TRUNCATE TABLE [rpt].[O2O_Employee_Commission];
	INSERT INTO [rpt].[O2O_Employee_Commission]
           ([Monthkey]
           ,[Employee_ID]
           ,[Employee_Name]
           ,[Order_Count]
		   ,[Operate_Order_Cnt]
           ,[Commission_Amount]
           ,[Order_Amount]
           ,[Shipping_Amount]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT distinct
		a.year*100+a.month AS monthkey,
		a.Employee_ID AS Employee_ID,
		a.[Employee_Name] as [Employee_Name],
		ISNULL(b.Order_Cnt, 0) AS [Order_Count],
		ISNULL(b.Operate_Order_Cnt, 0) AS [Operate_Order_Cnt],
		ROUND(ISNULL(b.Comm_Amt, 0), 2) AS [Commission_Amount],
		--0,
		--0,
		b.Order_Amt AS [Order_Amount],
		b.Shipping_Amt AS [Shipping_Amount],
		GETDATE() AS [Create_Time],
		@ProcName AS [Create_By],
		GETDATE() AS [Update_Time],
		@ProcName AS [Update_By]
        FROM (SELECT 
				b.year AS year,
				b.month AS month,
				a.Employee_ID AS Employee_ID,
				a.[Employee_Name] as [Employee_Name]
            FROM  dm.Dim_O2O_Employee a
			CROSS JOIN (SELECT DISTINCT Year,Month FROM FU_EDW.Dim_Calendar) b
			where b.year*100+b.month <= CONVERT(VARCHAR(6),GETDATE(),112)
		) a
		LEFT JOIN (
		SELECT 
						t.YEAR AS YEAR,
						t.MONTH AS MONTH,
						t.Employee_ID AS Employee_ID,
						t.Order_Cnt AS Order_Cnt,
						t.Operate_Order_Cnt AS Operate_Order_Cnt,
						t.Order_Amt,
						t.Shipping_Amt,
						CASE  WHEN (t.Order_Amt <= 8000) THEN (t.Order_Amt * 0.1)
							  WHEN ((t.Order_Amt > 8000) AND (t.Order_Amt <= 12000)) THEN (800 + ((t.Order_Amt - 8000) * 0.15))
							  WHEN ((t.Order_Amt > 12000) AND (t.Order_Amt <= 16000)) THEN (1400 + ((t.Order_Amt - 12000) * 0.20))
							  WHEN ((t.Order_Amt > 16000) AND (t.Order_Amt <= 20000)) THEN (2200 + ((t.Order_Amt - 16000) * 0.30))
							  WHEN (t.Order_Amt > 20000) THEN (3400 + ((t.Order_Amt - 20000) * 0.35))
							  ELSE 0 END + t.Shipping_Amt * 0.05 AS Comm_Amt
				    FROM (SELECT 
								 t.YEAR AS YEAR,
								 t.MONTH AS MONTH,
								 t.Employee_ID AS Employee_ID,
								 SUM(t.Order_Cnt) AS Order_Cnt,
								 SUM(t.Operate_Order_Cnt) AS Operate_Order_Cnt,
								 SUM(t.Order_Amt) AS Order_Amt,
								 SUM(t.Shipping_Amt) AS Shipping_Amt
						  FROM  (SELECT 
									YEAR(sob.order_create_time) AS YEAR,
									 MONTH(sob.order_create_time) AS MONTH,
								    sob.Fenxiao_Employee_ID AS Employee_ID,
								    (SUM(CASE WHEN (sob.order_create_time IS NOT NULL) THEN 1 ELSE 0 END) 
									+SUM(CASE WHEN (sob.refund_time IS NOT NULL) THEN -(1) ELSE 0 END)) AS Order_Cnt,
									0 AS Operate_Order_Cnt,
									(SUM(CASE WHEN (sob.order_create_time IS NOT NULL) THEN (sob.pay_amount - sob.shipping_amount) ELSE 0 END) 
										+SUM(CASE WHEN (sob.refund_time IS NOT NULL) THEN
										(CASE WHEN (sob.refund_state = '全额退款成功') THEN (0 - (sob.pay_amount - sob.shipping_amount)) ELSE (0 - isnull(sob.refund_amount,0))	END)
										ELSE 0
									 END)) AS Order_Amt,
									 0 AS Shipping_Amt
								 FROM dm.Fct_O2O_Order_Base_info_new sob
								 WHERE
								     (sob.pay_status = '已支付'
								         AND sob.fenxiao_Employee_ID IS NOT NULL
								         --AND ((sob.order_create_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )))
								         --OR (sob.refund_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 ))
									)
								 GROUP BY YEAR(sob.order_create_time),MONTH(sob.order_create_time),sob.Fenxiao_Employee_ID
								 UNION ALL 
								 SELECT 
									 YEAR(sob.order_create_time) AS YEAR,
									 MONTH(sob.order_create_time) AS MONTH,
									 sob.Operator_Employee_ID AS Employee_ID,
									 0 AS Order_Cnt,
									 1 AS Operate_Order_Cnt,
									 0 AS Order_Amt,
									(SUM(CASE WHEN (sob.order_create_time IS NOT NULL) THEN (sob.pay_amount - sob.shipping_amount) ELSE 0 END) 
									+ SUM(CASE WHEN (sob.refund_time IS NOT NULL) THEN
									  (CASE WHEN (sob.refund_state = '全额退款成功') THEN (0 - (sob.pay_amount - sob.shipping_amount)) ELSE (0 - isnull(sob.refund_amount,0)) END)
									 ELSE 0 END)) AS Shipping_Amt
							     FROM dm.Fct_O2O_Order_Base_info_new sob
							     WHERE
									( sob.pay_status = '已支付'
									 AND sob.express_type = '同城配送'
									 AND sob.order_status_str IN ('已完成' , '已发货')
									 AND sob.Operator_Employee_ID IS NOT NULL
									 --AND ((sob.order_create_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 )))
									 --OR (sob.refund_time >= CONVERT(date, DATEADD(DD,-DAY(GETDATE())+1,GETDATE()), 120 ))
									 )
								 GROUP BY YEAR(sob.order_create_time),MONTH(sob.order_create_time),sob.Operator_Employee_ID
						  ) t
						  WHERE t.Employee_ID IS NOT NULL
						  GROUP BY t.Employee_ID,t.YEAR,t.MONTH
					 ) t
		) b ON (a.year = b.year) AND (a.month = b.month) AND (a.Employee_ID = b.Employee_ID)
		;
	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END


	--select * from  ods.ods.SCRM_Employee_month_commission_hist hist
GO
