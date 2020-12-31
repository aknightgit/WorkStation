USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











--select * from [dm].[Fct_O2O_Order_Detail_info]  where order_id = '321432729658986496'
--select * from [dm].[Fct_O2O_Order_Base_info] where order_no = 'E20190502203920084300003'


CREATE PROC [dm].[SP_Fct_Youzan_Recon]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

UPDATE [ODS].[ods].[File_Youzan_Order_MonthlyRecon]  SET Order_No = CASE WHEN Order_No LIKE 'P%' THEN Serial_No ELSE Order_No END
--------------------------------------每笔订单的入账总额


DROP TABLE  IF EXISTS #Recon

SELECT Order_No
	  ,CAST(SUM(Amount) AS DECIMAL(10,2)) AS Recon_Amount
	  INTO #Recon
FROM [ODS].[ods].[File_Youzan_Order_MonthlyRecon] 
WHERE Recon_Type IN ('订单入账','退款')
GROUP BY Order_No

----------------------------周期购订单配送次数	目前通过[dm].[Fct_O2O_Order_Detail_info] 表中的subscriptiontype字段拆分

DROP TABLE  IF EXISTS #Cycle_Times
SELECT bi.order_no
	  ,di.delivery_cnt AS Times
	  INTO #Cycle_Times
FROM [dm].[Fct_O2O_Order_Base_info] bi
LEFT JOIN [dm].[Fct_O2O_Order_Detail_info] di ON bi.Order_Id = di.order_id
WHERE is_cycle = 1 AND di.delivery_cnt<>'' AND di.delivery_cnt IS NOT NULL

----------------------------订单名称
DROP TABLE IF EXISTS #OrderName

SELECT 
	 bi.Order_No
	,STRING_AGG(di.Product_Name,'|') Order_Name
	INTO #OrderName
FROM [dm].[Fct_O2O_Order_Detail_info] di
LEFT JOIN [dm].[Fct_O2O_Order_Base_info] bi ON di.order_id = bi.order_id
GROUP BY bi.Order_No

DROP TABLE  IF EXISTS #Order_min_cnt
select mr1.Order_No,count(case when mr1.amount = mr2.amount_min then 1 END) AS min_cnt,count(1) as recon_cnt
into #Order_min_cnt
from [ODS].[ods].[File_Youzan_Order_MonthlyRecon] mr1
LEFT JOIN (select Order_No,min(Amount) as amount_min from [ODS].[ods].[File_Youzan_Order_MonthlyRecon] WHERE  Recon_Type = '订单入账' group by Order_No) mr2 ON mr1.Order_No = mr2.Order_No
WHERE Recon_Type = '订单入账' 
group by mr1.Order_No

--ALTER TABLE [dm].[Fct_Youzan_Recon] ADD Operator_Name nvarchar(50),Consign_Store nvarchar(50),Remark nvarchar(200)

TRUNCATE TABLE [dm].[Fct_Youzan_Recon]

INSERT INTO [dm].[Fct_Youzan_Recon](
		   Recon_ID
		  ,[Recon_Date]
		  ,[Recon_DateKey]
		  ,[Order_No]
		  ,[Order_Name]
		  ,Operator_Name
		  ,Consign_Store
		  ,Remark
		  ,[pay_type_str]
		  ,[Order_Amount]
		  ,[shipping_amount]
		  ,[Order_Pay_Amount]
		  ,Order_Refund_Amount
		  ,[Order_Create_DateKey]
		  ,[Pay_Datekey]
		  ,[Recon_Type]
		  ,[Serial_No]
		  ,[Income_Amount]
		  ,[Pay_Amount]
		  ,[Balance_Amount]
		  ,[Recon_Channel]
		  ,[Remarks]
		  ,[Amount]
		  ,[Period]
		  ,[Order_Seq]
		  ,[cycle]
		  ,[Cycle_Times]
		  ,Distribution_Amount
		  ,Shipping_OneTime_Amount
		  ,[Recon_Total_Amount]
		  ,[Create_Time]
		  ,[Create_By]
		  ,[Update_Time]
		  ,[Update_By]
	)
SELECT ROW_NUMBER() OVER(ORDER BY GETDATE()) AS Recon_ID
	  ,rc.[Recon_Date]
	  ,CONVERT(VARCHAR(8),CAST(rc.[Recon_Date] AS DATE),112) AS Recon_DateKey
      ,rc.[Order_No]
	  ,orn.Order_Name
	  ,eo.operator_name
	  ,bi.Consign_Store
	  ,bi.Remark
	  ,bi.pay_type_str
	  ,bi.pay_amount AS Order_Amount
	  ,bi.shipping_amount AS shipping_amount
	  ,bi.pay_amount AS Order_Pay_Amount
	  ,CASE WHEN (CASE WHEN omc.min_cnt = 1 AND omc.recon_cnt>1 AND omc.recon_cnt = ct.Times THEN ROW_NUMBER() OVER(PARTITION BY rc.Order_No ORDER BY rc.amount ) ELSE 2 END) = 1 THEN bi.refund_amount ELSE 0 END AS Order_Refund_Amount
	  ,CONVERT(VARCHAR(8),CAST(bi.order_create_time AS DATE),112) AS Order_Create_DateKey
	  ,CONVERT(varchar(8),pay_time,112) Pay_Datekey
      ,rc.[Recon_Type]
      ,rc.[Serial_No]
      ,rc.[Income_Amount]
      ,rc.[Pay_Amount]
      ,rc.[Balance_Amount]
      ,rc.[Recon_Channel]
      ,rc.[Remarks]
      ,rc.[Amount]  AS [Amount]		--礼品卡支付的金额为0
      ,rc.[Period]
	  ,CASE WHEN omc.min_cnt = 1 AND omc.recon_cnt>1 AND omc.recon_cnt = ct.Times THEN ROW_NUMBER() OVER(PARTITION BY rc.Order_No ORDER BY rc.amount ) ELSE 2 END /*ROW_NUMBER() OVER(PARTITION BY rc.Order_No ORDER BY rc.Recon_Date DESC)*/ /*CASE WHEN ISNULL(bi.cycle,0) = 1 AND bi.refund_amount>0 THEN CASE WHEN (bi.pay_amount-bi.shipping_amount)/ct.Times >= CASE WHEN bi.pay_type = 33 THEN 0 ELSE rc.[Amount] END - bi.refund_amount THEN 1 ELSE 2 END ELSE 3 END*/ AS Order_Seq
	  ,ISNULL(bi.is_cycle,0) AS cycle
	  ,CASE WHEN ISNULL(bi.is_cycle,0) = 1 THEN ct.Times ELSE 1 END AS Cycle_Times			--如果是不是周期购订单，总配送次数等于1
	  ,ROUND(CASE WHEN ISNULL(bi.is_cycle,0) = 1 THEN (bi.pay_amount-bi.shipping_amount)/ct.Times ELSE bi.pay_amount-bi.shipping_amount END,2,1) AS Distribution_Amount		--如果是周期购订单，订单每次配送金额等于订单金额除以总配送次数
	  ,CASE WHEN ISNULL(bi.is_cycle,0) = 1 THEN bi.shipping_amount/ct.Times ELSE bi.shipping_amount END AS Shipping_OneTime_Amount		--如果是周期购订单，订单每次配送金额等于订单金额除以总配送次数
	  , rec.Recon_Amount AS Recon_Total_Amount
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
FROM [ODS].[ods].[File_Youzan_Order_MonthlyRecon] rc
LEFT JOIN [dm].[Fct_O2O_Order_Base_info] bi ON rc.Order_No = bi.order_no
LEFT JOIN (SELECT DISTINCT [Operator_EmployeeID] operator_employee_id,[Operator_EmployeeName] operator_name FROM rpt.[O2O_Employee_Order]) eo ON bi.operator_employee_id = eo.operator_employee_id
LEFT JOIN #Recon rec ON rc.Order_No = rec.Order_No
LEFT JOIN #Cycle_Times ct ON rc.Order_No = ct.order_no
LEFT JOIN #OrderName orn ON rc.Order_No = orn.order_no
LEFT JOIN #Order_min_cnt omc ON rc.Order_No = omc.Order_No
WHERE Recon_Type IN ('订单入账','退款')-- and rc.Order_No = 'E20190731205645014500009'
--AND orn.Order_Name NOT LIKE '%寄生%'
--AND orn.Order_Name NOT LIKE '%周边%'
--AND orn.Order_Name NOT LIKE '%会员专享%'
--AND orn.Order_Name NOT LIKE '%福袋%'
--AND orn.Order_Name NOT LIKE '%赠品%'
--AND bi.Order_Status <> 'TRADE_CLOSED'
--AND bi.Order_Type ='普通订单'
	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END

GO
