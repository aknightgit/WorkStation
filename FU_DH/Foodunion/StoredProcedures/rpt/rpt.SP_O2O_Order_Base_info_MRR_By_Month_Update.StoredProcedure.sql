USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_O2O_Order_Base_info_MRR_By_Month_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [rpt].[SP_O2O_Order_Base_info_MRR_By_Month_Update]
AS 
BEGIN

DECLARE @errmsg nvarchar(max),
	@DatabaseName varchar(100) = DB_NAME(),
	@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY

	------------------------- MRR: 每个月付款金额
	----------------计算 MRR、ARPU
	DROP TABLE IF EXISTS #MRR_ARPU;
	SELECT LEFT(Deliverydatekey,6) AS TMonth
		  ,SUM(Delivery_Amt) AS MRR
		  ,COUNT(DISTINCT Open_id) AS Guest_Count
	INTO #MRR_ARPU
	FROM [rpt].[O2O_Order_Base_info_Delivery]
	GROUP BY LEFT(Deliverydatekey,6);
	--SELECT * FROM #MRR_ARPU

	-------------------------Expansion MRR 同一批客户，次月付款金额增加的情况
	-------------------------计算Expansion MRR  只计算当一个客户连续两个月都存在的情况MRR增加的客户的MRR
	DROP TABLE IF EXISTS #MRR_Customer_M;
	SELECT LEFT(Deliverydatekey,6) AS TMonth
		  ,Open_id
		  ,SUM(Delivery_Amt) AS MRR
	INTO #MRR_Customer_M
	FROM [rpt].[O2O_Order_Base_info_Delivery]
	GROUP BY LEFT(Deliverydatekey,6)
			,Open_id;

	DROP TABLE IF EXISTS #Expansion_MRR;
	SELECT 
		 MRRA.TMonth
		,SUM(MRRA.MRR-MRRB.MRR) AS Expansion_MRR
	INTO #Expansion_MRR
	FROM #MRR_Customer_M AS MRRA
	INNER JOIN #MRR_Customer_M MRRB ON MRRB.TMonth+CASE WHEN MRRB.TMonth%100 = 12 THEN 89 ELSE 1 END = MRRA.TMonth AND MRRA.Open_id = MRRB.Open_id
	WHERE MRRB.Open_id IS NOT NULL AND MRRA.MRR-MRRB.MRR>=0
	GROUP BY MRRA.TMonth ;
	--SELECT * FROM #Expansion_MRR ORDER BY TMonth
	--select * from #MRR_Customer_M;

	-------------------------Expansion MRR 同一批客户，次月付款金额减少的情况
	-------------------------计算Contraction MRR 只计算当一个客户连续两个月都存在的情况MRR减少加的客户的MRR
	DROP TABLE IF EXISTS #Contraction_MRR
	SELECT 
		 MRRA.TMonth
		,SUM(MRRA.MRR-MRRB.MRR) AS Contraction_MRR
	INTO #Contraction_MRR
	FROM #MRR_Customer_M AS MRRA
	INNER JOIN #MRR_Customer_M MRRB ON MRRB.TMonth+CASE WHEN MRRB.TMonth%100 = 12 THEN 89 ELSE 1 END = MRRA.TMonth AND MRRA.Open_id = MRRB.Open_id
	WHERE MRRB.Open_id IS NOT NULL AND MRRA.MRR-MRRB.MRR<0
	GROUP BY MRRA.TMonth  ;
	--SELECT * FROM #Contraction_MRR ORDER BY TMonth

	------------------------New MRR 每个月新进粉丝，付款金额
	--计算 NEW_Customer 获取每个open_id第一次付费时间新增月份。再汇总第一个月的付款金额
	DROP TABLE IF EXISTS #New_MRR;
	SELECT
		LEFT(MinDate,6) AS TMonth
	   ,COUNT(DISTINCT MO.Open_id) AS New_Customer
	   ,SUM(MC.MRR) AS NEW_MRR
	INTO #New_MRR
	FROM(
	SELECT Open_id
		  ,MIN(Deliverydatekey) AS MinDate
	FROM [rpt].[O2O_Order_Base_info_Delivery]
	GROUP BY Open_id
	) MO
	LEFT JOIN #MRR_Customer_M MC ON LEFT(MO.MinDate,6) = MC.TMonth AND MO.Open_id = MC.Open_id		-----------------关联#MRR_Customer_M表获取最早付款月份的付款金额
	GROUP BY LEFT(MinDate,6);
	--SELECT * FROM #New_MRR

	------------------------Churn MRR 每个月丢失粉丝，付款金额
	--计算 流失的MRR，只要到现在为止30天内没有付费的，都算流失的。获取每个open_id最后一次付费时间的下一个月作为流失月份。再汇总流失的客户最后一个月的付款金额
	DROP TABLE IF EXISTS #Lost_MRR;
	SELECT
		LEFT(CONVERT(VARCHAR(8),DATEADD(MONTH,1,CAST(MO.MaxDate AS VARCHAR)),112),6) AS TMonth
	   ,COUNT(DISTINCT MO.Open_id) AS Lost_Customer
	   ,SUM(MC.MRR) AS Lost_MRR
	   INTO #Lost_MRR
	FROM(
		----------------------------获取每个客户最后付款时间
		SELECT Open_id
			  ,MAX(Deliverydatekey) AS MaxDate
		FROM [rpt].[O2O_Order_Base_info_Delivery]
		GROUP BY Open_id
		) MO
	LEFT JOIN #MRR_Customer_M MC ON LEFT(MO.MaxDate,6) = MC.TMonth AND MO.Open_id = MC.Open_id		-----------------关联#MRR_Customer_M表获取最后付款月份的付款金额
	WHERE DATEDIFF(DAY,CAST(MO.MaxDate AS VARCHAR),(SELECT MAX(DeliveryDate) FROM [rpt].[O2O_Order_Base_info_Delivery]))>30						------------------过滤掉30天内付过款的
	GROUP BY LEFT(CONVERT(VARCHAR(8),DATEADD(MONTH,1,CAST(MO.MaxDate AS VARCHAR)),112),6);
	--SELECT * FROM #Lost_MRR


	------------------------------------------------
	--新逻辑计算 NEW MRR 以及 Churn MRR
	--
	------------------------------------------------
	--计算NewMRR_Over_Last
	DROP TABLE IF EXISTS #NewMRR_Over_Last
	SELECT 
		 MRRA.TMonth
		,SUM(MRRA.MRR) AS NewMRR_Over_Last
		,count(distinct MRRA.Open_id) AS New_Over_Last
	INTO #NewMRR_Over_Last
	FROM #MRR_Customer_M AS MRRA
	LEFT JOIN #MRR_Customer_M MRRB ON MRRB.TMonth+CASE WHEN MRRB.TMonth%100 = 12 THEN 89 ELSE 1 END = MRRA.TMonth AND MRRA.Open_id = MRRB.Open_id
	WHERE MRRB.Open_id IS NULL 
	GROUP BY MRRA.TMonth ;
	--SELECT * FROM #NewMRR_Over_Last ORDER BY TMonth

	--计算ChurnMRR_Over_Last
	DROP TABLE IF EXISTS #ChurnMRR_Over_Last
	SELECT 
		 MRRB.TMonth+CASE WHEN MRRB.TMonth%100 = 12 THEN 89 ELSE 1 END AS TMonth
		,SUM(MRRB.MRR) AS ChurnMRR_Over_Last
		,count(distinct MRRB.Open_id) AS Churn_Over_Last
	INTO #ChurnMRR_Over_Last
	FROM #MRR_Customer_M AS MRRB
	LEFT JOIN #MRR_Customer_M MRRA ON MRRB.TMonth+CASE WHEN MRRB.TMonth%100 = 12 THEN 89 ELSE 1 END = MRRA.TMonth AND MRRA.Open_id = MRRB.Open_id
	WHERE MRRA.Open_id IS NULL 
	GROUP BY MRRB.TMonth ;
	--SELECT * FROM #ChurnMRR_Over_Last ORDER BY TMonth

	TRUNCATE TABLE [rpt].[O2O_Order_Base_info_MRR_By_Month]
	INSERT INTO  [rpt].[O2O_Order_Base_info_MRR_By_Month]
	(
		[TMonth]
	   ,[MRR]
	   ,[MRR_LM]
	   ,[Active_Customer_Count]
	   ,[Active_Customer_Count_LM]
	   ,[Expansion_MRR]
	   ,[Contraction_MRR]
	   ,[New_Customer]
	   ,[NEW_MRR]
	   ,[Lost_Customer]
	   ,[Lost_MRR]
	   ,New_Over_Last
	   ,NewMRR_Over_Last
	   ,Churn_Over_Last
	   ,ChurnMRR_Over_Last
	   ,[Churn_Rate]
	   ,[Create_Time]
	   ,[Create_By]
	   ,[Update_Time]
	   ,[Update_By]
	)

	SELECT ma.TMonth
		  ,ma.MRR
		  ,malm.MRR AS [MRR_LM]
		  ,ma.Guest_Count AS Active_Customer_Count
		  ,malm.Guest_Count AS [Active_Customer_Count_LM]
		  ,em.Expansion_MRR
		  ,cm.Contraction_MRR
		  ,nm.New_Customer
		  ,nm.NEW_MRR
		  ,0-lm.Lost_Customer AS Lost_Customer
		  ,0-lm.Lost_MRR Lost_MRR

		  ,nl.New_Over_Last
		  ,nl.NewMRR_Over_Last
		  ,0-cl.Churn_Over_Last AS Churn_Over_Last
		  ,0-cl.ChurnMRR_Over_Last AS ChurnMRR_Over_Last
		  --,CAST(lm.Lost_Customer AS decimal(20,10))/malm.Guest_Count AS [Churn_Rate]
		  ,CAST(cl.Churn_Over_Last AS decimal(20,10))/malm.Guest_Count AS [Churn_Rate]
		  ,GETDATE()
		  ,@ProcName
		  ,GETDATE()
		  ,@ProcName
	FROM #MRR_ARPU ma
	LEFT JOIN #MRR_ARPU malm ON ma.TMonth = CASE WHEN malm.TMonth%100=12 THEN malm.TMonth+89 ELSE malm.TMonth+1 END
	LEFT JOIN #Expansion_MRR em ON ma.TMonth = em.TMonth
	LEFT JOIN #Contraction_MRR cm ON ma.TMonth = cm.TMonth
	LEFT JOIN #New_MRR nm ON ma.TMonth = nm.TMonth
	LEFT JOIN #Lost_MRR lm ON ma.TMonth = lm.TMonth
	LEFT JOIN #NewMRR_Over_Last nl ON  ma.TMonth = nl.TMonth
	LEFT JOIN #ChurnMRR_Over_Last cl ON  ma.TMonth = cl.TMonth
	WHERE ma.TMonth IS NOT NULL
	--AND ma.TMonth <= CONVERT(VARCHAR(6),GETDATE(),112)


END TRY
BEGIN CATCH

	SELECT @errmsg =  ERROR_MESSAGE();

	EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

	RAISERROR(@errmsg,16,1);

END CATCH

END




--select * from  [rpt].[O2O_Order_Base_info_MRR_By_Month]
--select* from [dm].[Fct_O2O_Order_Detail_info]

--select  A.*, B.delivery_cnt ,b.SubscriptionType from [dm].[Fct_O2O_Order_Base_info] A 
--left join [dm].[Fct_O2O_Order_Detail_info] B on A.Order_ID = B.Order_ID
--where is_cycle = 1  and Order_Status_Str <> '已关闭'


--select  left(datekey,6) as Tmonth, Open_ID,  B.delivery_cnt ,b.SubscriptionType , count(distinct A.Order_ID) as TC , sum( Pay_Amount) as Sales  from [dm].[Fct_O2O_Order_Base_info] A 
--left join [dm].[Fct_O2O_Order_Detail_info] B on A.Order_ID = B.Order_ID
--where is_cycle = 1 and Order_Status_Str <> '已关闭'
--group by Open_ID , left(datekey,6), B.delivery_cnt ,b.SubscriptionType 
--order by TC desc

--select  A.*, B.delivery_cnt ,b.SubscriptionType from [dm].[Fct_O2O_Order_Base_info] A 
--left join [dm].[Fct_O2O_Order_Detail_info] B on A.Order_ID = B.Order_ID
--where is_cycle = 1  and Order_Status_Str <> '已关闭'

----------------------------计算客户增减
--SELECT MRRA.TMonth,
--	  ,MRRA.Guest_Count AS CM_Guest_Count
--	  ,MRRB.Guest_Count AS LM_Guest_Count
--	  , 
--FROM #MRR_ARPU AS MRRA
--LEFT JOIN #MRR_ARPU MRRB ON MRRB.TMonth+CASE WHEN MRRB.TMonth%100 = 12 THEN 89 ELSE 1 END = MRRA.TMonth
--------------计算流失率

-- select '2019-06-01' as TMonth, Is_Active1 , Is_Active2,   count(distinct Open_ID) as BaseCount, sum(sales) as Sales from 
--(
--select Open_ID, case when  min(deliverydate) <= '2019-06-01' and  max(deliverydate) > '2019-06-01' then 1 
--else 0 end as Is_Active1 ,
--case when  min(deliverydate) <= '2019-06-30' and  max(deliverydate) > '2019-06-30' then 1 
--else 0 end as Is_Active2 ,sum(delivery_Amt) as Sales
--from [rpt].[O2O_Order_Base_info_Delivery] A

--group by   open_ID having  min(deliverydate) <= '2019-06-30'
--) A
--group by Is_Active1 ,Is_Active2 --,delivery_cnt
--union all
-- select '2019-07-01' as TMonth, Is_Active1 , Is_Active2,   count(distinct Open_ID) as BaseCount, sum(sales) as Sales from 
--(
--select Open_ID, case when  min(deliverydate) <= '2019-07-01' and  max(deliverydate) > '2019-07-01' then 1 
--else 0 end as Is_Active1 ,
--case when  min(deliverydate) <= '2019-07-31' and  max(deliverydate) > '2019-07-31' then 1 
--else 0 end as Is_Active2 ,sum(delivery_Amt) as Sales
--from [rpt].[O2O_Order_Base_info_Delivery] A

--group by   open_ID having  min(deliverydate) <= '2019-07-31'
--) A
--group by Is_Active1 ,Is_Active2 --,delivery_cnt

--union all

-- select '2019-08-01' as TMonth, Is_Active1 , Is_Active2,   count(distinct Open_ID) as BaseCount, sum(sales) as Sales from 
--(
--select Open_ID, case when  min(deliverydate) <= '2019-08-01' and  max(deliverydate) > '2019-08-01' then 1 
--else 0 end as Is_Active1 ,
--case when  min(deliverydate) <= '2019-08-31' and  max(deliverydate) > '2019-08-31' then 1 
--else 0 end as Is_Active2 ,sum(delivery_Amt) as Sales
--from [rpt].[O2O_Order_Base_info_Delivery] A

--group by   open_ID having  min(deliverydate) <= '2019-08-31'
--) A
--group by Is_Active1 ,Is_Active2 --,delivery_cnt

----计算 各种 MRR

--To analyze MRR – and specially MRR growth – we should consider three different aspects of MRR:
--New MRR is the simply new revenue brought by brand new customers acquired. 
--Expansion MRR is the increamental part of your revenue from existing customers 
--Churn MRR is the revenue that has been lost from customers cancelling or downgrading their plans. 
--Keep in mind that MRR churn is different from customer churn.
--MRR Growth: to calculate your MRR growth you should actually consider all these three aspects on a formula.
--Net New MRR = New MRR + Expansion MRR – Churn MRR
GO
