USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_O2O_Employee_Commission_Update_bak]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [rpt].[SP_O2O_Employee_Commission_Update_bak]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	----[rpt].[O2O_Employee_Commission]
	--TRUNCATE TABLE [rpt].[O2O_Employee_Commission];
	
	SELECT distinct
		a.Monthkey AS monthkey,
		a.Employee_ID AS Employee_ID,
		a.[Employee_Name] as [Employee_Name],
		ISNULL(b.Order_Cnt, 0) AS [Order_Count],
		ISNULL(b.Operate_Order_Cnt, 0) AS [Operate_Order_Cnt],
		ROUND(ISNULL(b.Comm_Amt, 0), 2) AS [Commission_Amount],
		b.Payment_Amt AS [Payment_Amount],
		b.Order_Amt AS [Order_Amount],
		b.Shipping_Amt AS [Shipping_Amount],
		b.[Sales_Commission],
        b.[Shipping_Commission],
		GETDATE() AS [Create_Time],
		@ProcName AS [Create_By],
		GETDATE() AS [Update_Time],
		@ProcName AS [Update_By]
	INTO #O2O_Employee_Commission
    FROM (SELECT 
			b.year*100+b.month AS Monthkey,
			a.Employee_ID AS Employee_ID,
			a.[Employee_Name] as [Employee_Name]
        FROM  dm.Dim_O2O_Employee a
		CROSS JOIN (SELECT DISTINCT Year,Month FROM FU_EDW.Dim_Calendar) b
		where b.year*100+b.month <= CONVERT(VARCHAR(6),GETDATE(),112)
		) a
	JOIN (
		SELECT 
				tol.Monthkey,
				tol.Employee_ID AS Employee_ID,
				tol.Order_Cnt AS Order_Cnt,
				tol.Operate_Order_Cnt AS Operate_Order_Cnt,
				tol.Payment_Amt,
				tol.Order_Amt,
				tol.Shipping_Amt,
				CASE  WHEN (tol.Order_Amt <= 8000) THEN (tol.Order_Amt * 0.1)
						WHEN (tol.Order_Amt > 8000 AND tol.Order_Amt <= 12000) THEN (800 + (tol.Order_Amt - 8000) * 0.15)
						WHEN (tol.Order_Amt > 12000 AND tol.Order_Amt <= 16000) THEN (1400 + (tol.Order_Amt - 12000) * 0.20)
						WHEN (tol.Order_Amt > 16000 AND tol.Order_Amt <= 20000) THEN (2200 + (tol.Order_Amt - 16000) * 0.30)
						WHEN (tol.Order_Amt > 20000) THEN (3400 + (tol.Order_Amt - 20000) * 0.35)
						ELSE 0 END AS [Sales_Commission],
				tol.Shipping_Amt * 0.05 AS [Shipping_Commission],
				CASE  WHEN (tol.Order_Amt <= 8000) THEN (tol.Order_Amt * 0.1)
						WHEN (tol.Order_Amt > 8000 AND tol.Order_Amt <= 12000) THEN (800 + (tol.Order_Amt - 8000) * 0.15)
						WHEN (tol.Order_Amt > 12000 AND tol.Order_Amt <= 16000) THEN (1400 + (tol.Order_Amt - 12000) * 0.20)
						WHEN (tol.Order_Amt > 16000 AND tol.Order_Amt <= 20000) THEN (2200 + (tol.Order_Amt - 16000) * 0.30)
						WHEN (tol.Order_Amt > 20000) THEN (3400 + (tol.Order_Amt - 20000) * 0.35)
						ELSE 0 END + tol.Shipping_Amt * 0.05 AS Comm_Amt
			FROM (SELECT 
					t.Monthkey,
					t.Employee_ID AS Employee_ID,
					SUM(t.Order_Cnt) AS Order_Cnt,
					SUM(t.Operate_Order_Cnt) AS Operate_Order_Cnt,
					SUM(t.Payment_Amt) AS Payment_Amt,
					SUM(t.Order_Amt) AS Order_Amt,
					SUM(t.Shipping_Amt) AS Shipping_Amt
					FROM  (SELECT 
								CONVERT(VARCHAR(6),sob.order_create_time,112) AS Monthkey,
								sob.Fenxiao_Employee_ID AS Employee_ID,
								SUM(CASE WHEN sob.refund_state = '全额退款成功' THEN 0 ELSE 1 END) AS Order_Cnt,
								0 AS Operate_Order_Cnt,
								SUM(sob.pay_amount) AS Payment_Amt,
								SUM(sob.pay_amount - sob.shipping_amount) 
									+SUM(CASE WHEN sob.refund_time IS NOT NULL THEN	
									(CASE WHEN (sob.refund_state = '全额退款成功') THEN (0 - (sob.pay_amount - sob.shipping_amount)) ELSE (0 - isnull(sob.refund_amount,0))	END)
									ELSE 0
									END) AS Order_Amt,
								0 AS Shipping_Amt
							FROM dm.Fct_O2O_Order_Base_info sob WITH(NOLOCK)
							WHERE sob.pay_status = '已支付'			         
								AND ISNULL(sob.fenxiao_Employee_ID,'00000000000') <> '00000000000'
								AND sob.order_status_str NOT IN ('已关闭')	
								AND sob.order_create_time IS NOT NULL									
							GROUP BY CONVERT(VARCHAR(6),sob.order_create_time,112),sob.Fenxiao_Employee_ID

							UNION ALL 

							SELECT 
								CONVERT(VARCHAR(6),sob.order_create_time,112) AS Monthkey,
								sob.Operator_Employee_ID AS Employee_ID,
								0 AS Order_Cnt,
								SUM(1) AS Operate_Order_Cnt,
								0 AS Payment_Amt,
								0 AS Order_Amt,
								SUM(sob.pay_amount - sob.shipping_amount) 
									+ SUM(CASE WHEN (sob.refund_time IS NOT NULL) THEN
									(CASE WHEN (sob.refund_state = '全额退款成功') THEN (0 - (sob.pay_amount - sob.shipping_amount)) ELSE (0 - isnull(sob.refund_amount,0)) END)
									ELSE 0 END) AS Shipping_Amt
							FROM dm.Fct_O2O_Order_Base_info sob WITH(NOLOCK)
							WHERE sob.pay_status = '已支付'
								AND sob.express_type in ('同城配送','到店自提')
								AND sob.order_status_str IN ('已完成' , '已发货')
								AND sob.Operator_Employee_ID IS NOT NULL	
								AND sob.order_create_time IS NOT NULL								 
							GROUP BY CONVERT(VARCHAR(6),sob.order_create_time,112),sob.Operator_Employee_ID

					) t  -- Month total
					WHERE t.Employee_ID IS NOT NULL
					GROUP BY t.Employee_ID,t.Monthkey
				) tol   -- comm cal
		) b ON a.Monthkey = b.Monthkey 
			AND a.Employee_ID = b.Employee_ID
		;


		IF (DATEPART("DAY",GETDATE())<=10) --每个月10号前，直接重算刷新
		BEGIN

		DELETE FROM [rpt].[O2O_Employee_Commission]
		WHERE Monthkey >= CONVERT(VARCHAR(6),dateadd("MONTH",-1,getdate()),112);

		INSERT INTO [rpt].[O2O_Employee_Commission]
           ([Monthkey]
           ,[Employee_ID]
           ,[Employee_Name]
           ,[Order_Count]
		   ,[Operate_Order_Cnt]
           ,[Commission_Amount]
           ,[Order_Amount]
           ,[Shipping_Amount]
		   ,[Sales_Commission]
           ,[Shipping_Commission]
		   ,[Payment_Amount]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
		SELECT [Monthkey]
           ,[Employee_ID]
           ,[Employee_Name]
           ,[Order_Count]
		   ,[Operate_Order_Cnt]
           ,[Commission_Amount]
           ,[Order_Amount]
           ,[Shipping_Amount]
		   ,[Sales_Commission]
           ,[Shipping_Commission]
		   ,[Payment_Amount]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By]
		 FROM #O2O_Employee_Commission WHERE Monthkey >= CONVERT(VARCHAR(6),dateadd("MONTH",-1,getdate()),112);

		END

		 --Adjust Commission 
		 UPDATE adj
		 SET 
			adj.[Order_Count] = c.[Order_Count]
			,adj.[Operate_Order_Cnt] = c.[Operate_Order_Cnt]
			--,adj.Commission_Amount =  c.Commission_Amount
			,adj.Order_Amount =  c.Order_Amount
			,adj.Shipping_Amount =  c.Shipping_Amount
			,adj.Sales_Commission =  c.Sales_Commission
			,adj.Shipping_Commission =  c.Shipping_Commission
			,adj.Adj_Commission_Amount = c.Commission_Amount --10号开始
			,adj.Payment_Amount = c.Payment_Amount
			,adj.Update_By = 'ADJ'
			,adj.Update_Time= GETDATE()
		 FROM [rpt].[O2O_Employee_Commission] adj
		 JOIN #O2O_Employee_Commission c ON adj.Monthkey=c.monthkey 
			AND adj.Employee_id=c.Employee_ID
		 WHERE adj.Order_Amount<>c.Order_Amount OR adj.[Order_Count] = c.[Order_Count] OR adj.Commission_Amount<>c.Commission_Amount;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END


	--select * from  ods.ods.SCRM_Employee_month_commission_hist hist

	--select * from [rpt].[O2O_Employee_Commission] order by 1 desc;
	--select  Dateadd("Month",-1,GETDATE())
GO
