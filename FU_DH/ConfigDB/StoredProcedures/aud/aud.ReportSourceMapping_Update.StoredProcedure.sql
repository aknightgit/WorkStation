USE [ConfigDB]
GO
DROP PROCEDURE [aud].[ReportSourceMapping_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- =============================================
CREATE PROCEDURE [aud].[ReportSourceMapping_Update]

AS
BEGIN	

	SET XACT_ABORT ON;

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--1. YH Sales
	update a
	set a.Up_to_Date=replace(b.Calendar_DT,'-',''), a.Last_Load_File=b.Load_Source,a.Last_Run_Time=b.Load_DTM,
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()
	from  aud.ReportSourceMapping a
	join (
	select top 1 Calendar_DT,Load_Source,Load_DTM from  [ods].[ods].[File_YH_Sales]
	order by Calendar_DT desc
	)b
	on 1=1
	where Subject_Area='YH Sales';

	--2. YH Inventory
	update a
	set a.Up_to_Date=replace(b.Calendar_DT,'-',''), a.Last_Load_File=b.Load_Source,a.Last_Run_Time=b.Load_DTM,
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()
	from  aud.ReportSourceMapping a
	join (
	select top 1 Calendar_DT,Load_Source,Load_DTM from  [ods].[ods].[File_YH_Inventory]
	order by Calendar_DT desc
	)b
	on 1=1
	where Subject_Area='YH Inventory';

	--3. YH Sales Target
	--update a
	--set a.Up_to_Date=replace(b.DATE_DT,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=b.Load_DTM,
	--	a.Update_by='[aud].[ReportSourceMapping_Update]',
	--	a.Update_datetime = getdate()
	--from  aud.ReportSourceMapping a
	--join (
	--select top 1 DATE_DT,File_NM,Load_DTM from  [Foodunion].[FU_ODS].[T_ODS_YH_Target]
	--order by DATE_DT desc
	--)b
	--on 1=1
	--where Subject_Area='YH Sales Target';

	----4 YH Overview Sell-In
	--update a
	--set a.Up_to_Date=b.FMODIFYDATE, a.Last_Load_File=b.Update_Source,a.Last_Run_Time=b.Update_DTM,
	--	a.Update_by='[aud].[ReportSourceMapping_Update]',
	--	a.Update_datetime = getdate()
	--from  aud.ReportSourceMapping a
	--join (
	--select top 1 FMODIFYDATE,'' Update_Source,Update_DTM AS Update_DTM from  [Foodunion].[FU_ODS].[T_ODS_ERP_ORDER]--[Foodunion].[FU_EDW].[T_EDW_FCT_SALES_PLAN]
	--order by FMODIFYDATE desc
	--)b
	--on 1=1
	--where Subject_Area='YH Overview Sell-In';

	--5 SC 顺丰Inventory
	--update a
	--set a.Up_to_Date=replace(b.[Date_DT],'-',''), a.Last_Load_File=b.File_NM,--,a.Last_Run_Time=cast(b.Load_DTM as datetime),
	--	a.Update_by='[aud].[ReportSourceMapping_Update]',
	--	a.Update_datetime = getdate()
	----select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	--from  aud.ReportSourceMapping a
	--join (
	--select top 1 [Date_DT],File_NM,left(Load_DTM,10) as Load_DTM from  [Foodunion].[FU_ODS].[T_ODS_Inventory]
	--where Vendor_CD ='SF'
	--order by [Date_DT] desc
	--)b
	--on 1=1
	--where Subject_Area='SC 顺丰Inventory';


	--6 SC 恒知Inventory
	update a
	set a.Up_to_Date=Datekey, a.Last_Load_File=b.Load_Source,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate() --,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
    from  aud.ReportSourceMapping a
	join (
	select top 1 Datekey,Load_Source,left(Load_DTM,10) as Load_DTM from  ODS.[ods].[ERP_Stock_Inventory]
	where Stock_Name LIKE '%恒知%'
	order by Datekey desc
	)b
	on 1=1
	where Subject_Area='SC 恒知Inventory';

	-- MW 猫武士Inventory
	update a
	set a.Up_to_Date=replace(b.[Date_DT],'-',''), a.Last_Load_File=b.Load_Source,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate() --,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
	select top 1 [Date_DT],Load_Source,left(Load_DTM,10) as Load_DTM from  ODS.[ods].[File_Inventory]
	where Vendor_CD ='MW'
	order by [Date_DT] desc
	)b
	on 1=1
	where Subject_Area='SC 猫武士Inventory';

	--7 Omni Channel Sell-In
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
	select top 1 Datekey as Date_ID,'K3 ERP'as File_NM,[Update_Time] as Load_DTM from  [Foodunion].[dm].[Fct_ERP_Sale_Order]
	order by Date_ID desc
	)b
	on 1=1
	where Subject_Area='Omni Channel Sell-In';

	
	--8 Sell-out Lotus Sales
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
	select top 1 * from (
		select  period as Date_ID,'' as File_NM,Load_DTM as Load_DTM from  [ODS].[ods].[File_Sales_Lotus]
		union
		select  CONVERT(varchar(8),CAST([DATE] AS DATE),112),Load_Source,left(Load_DTM,23) from [ODS].[ods].[File_Sales_KA_POS] 
		where Customer_NM IN ('易初东区','易初南区')
		)d order by Date_ID desc
	)b
	on 1=1
	where Subject_Area='Sell-out Lotus Sales';

	-- Sell-out 华冠 Sales
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (	
	select top 1 * from (
		select top 1 period as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM from  [ODS].[ods].[File_Sales_HuaGuan]
		union
		select  CONVERT(varchar(8),CAST([DATE] AS DATE),112),Load_Source,left(Load_DTM,23) from [ODS].[ods].[File_Sales_KA_POS] 
		where Customer_NM IN ('华冠')
		)d order by Date_ID desc
	)b
	on 1=1
	where Subject_Area='Sell-out 华冠 Sales';

	-- Sell-out 欧尚Sales
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
	select top 1 * from (
		select top 1 period as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM from  [ODS].[ods].[File_Sales_Auchan]
		union
		select  CONVERT(varchar(8),CAST([DATE] AS DATE),112),Load_Source,left(Load_DTM,23) from [ODS].[ods].[File_Sales_KA_POS] 
		where Customer_NM IN ('欧尚')
		)d order by Date_ID desc
	)b
	on 1=1
	where Subject_Area='Sell-out 欧尚Sales';

	-- Sell-out JD Sales
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
	select top 1 period as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM from  [ODS].[ods].[File_Sales_JD]
	order by Date_ID desc
	)b
	on 1=1
	where Subject_Area='Sell-out JD Sales';

	
	-- Sell-out Mia Sales
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
	select top 1 period as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM from  [ODS].[ods].[File_Sales_Mia]
	order by Date_ID desc
	)b
	on 1=1
	where Subject_Area='Sell-out Mia Sales';

	-- Sell-out Tmall Sales
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
	select top 1 period as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM from  [ODS].[ods].[File_Sales_Tamll]
	order by Date_ID desc
	)b
	on 1=1
	where Subject_Area='Sell-out Tmall Sales';

	-- 京东退款
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
		select top 1 period as Date_ID,'' as File_NM,Load_DTM as Load_DTM
		--*
		from  [ODS].[ods].[File_Sales_JD_Refund]
		order by Date_ID desc
	)b
	on 1=1
	where Subject_Area='京东退款';

	-- Sell-out wechat Sales
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
		select top 1 period as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM
		--,*
		from  [ODS].[ods].[File_Sales_Wechat]
		order by Date_ID desc
	)b
	on 1=1
	where Subject_Area='Sell-out wechat Sales';

	-- YH ONline Sale
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
		select top 1 Calendar_DT as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM
		--,*
		from ods.[ods].[File_YH_Sales_Channel]
		order by Date_ID desc
	)b
	on 1=1
	where Subject_Area='YH Online Sale';

	-- Promotion Campaign Calendar
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
		select top 1 Convert(VARCHAR(8),Load_DTM,112) as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM
		--,*
		from ods.[ods].[File_YH_BM_Promotion]
		order by Date_ID desc
	)b
	on 1=1
	where Subject_Area='Promotion Campaign Calendar';


	-- BM Share StoreCard
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
		select top 1 Convert(VARCHAR(8),Create_Time,112) as Date_ID,'乳制品数据1902.xlsx' as File_NM,Create_Time as Load_DTM
		--,*
		from  [Foodunion].[dw].[Fct_YH_Sales_Competitive_Product]
		order by Date_ID desc
	)b
	on 1=1
	where Subject_Area='Store Score Card BM Share';

	-- YH Store PG/BM
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
		select top 1 Convert(VARCHAR(8),Load_DTM,112) as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM
		--,*
		from  ODS.[ods].[File_YHStore_BMTarget]
		order by Date_ID desc
	)b
	on 1=1
	where Subject_Area='YH Store PG/BM';

	--3. YH Sales Target
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
		select top 1 Convert(VARCHAR(8),Load_DTM,112) as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM
		--,*
		from  ODS.[ods].[File_YHStore_BMTarget]
		order by Date_ID desc
	)b
	on 1=1
	where Subject_Area='YH Sales Target';

	--Sell-out Tmall Sales
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
		select top 1 Convert(VARCHAR(8),created,112) as Date_ID,'TP Order' as File_NM,Load_DTM as Load_DTM
		from ODS.[ods].[TP_Trade_Order] 
		where sourcePlatformCode='TB'
		order by 1 desc
	)b
	on 1=1
	where Subject_Area='Sell-out Tmall Sales';

	--Sell-out JD Sales
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
		select top 1 Convert(VARCHAR(8),created,112) as Date_ID,'TP Order' as File_NM,Load_DTM as Load_DTM
		from ODS.[ods].[TP_Trade_Order] 
		where sourcePlatformCode='JD'
		order by 1 desc
	)b
	on 1=1
	where Subject_Area='Sell-out JD Sales';

	--YH Overview Sales FCST						By:CWC
	--update a
	--set a.Up_to_Date=CONVERT(varchar(8), Load_DT, 112 ), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
	--	a.Update_by='[aud].[ReportSourceMapping_Update]',
	--	a.Update_datetime = getdate() --,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	----select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	--from  aud.ReportSourceMapping a
	--join (
	--select top 1 File_NM,CONVERT(date, Load_DT, 120 )  as Load_DT from  [Foodunion].[FU_ODS].[T_ODS_Production_Plan]
	--order by Load_DT desc
	--)b
	--on 1=1
	--where Subject_Area='YH Overview Sales FCST';

	--OMS Sales						By:CWC
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
		select top 1 Convert(VARCHAR(8),[Load_DTM],112) as Date_ID,Load_Source AS File_NM,Load_DTM as Load_DTM
		from [ODS].[ods].[File_Sales_OMS_Tamll]
		order by [Load_DTM] desc
	)b
	on 1=1
	where Subject_Area='OMS Sales';
	
	--O全时，罗森，每日优鲜，便利蜂，爱鲜蜂，嗨家便利，客非Sales						By:CWC
	update a
	set a.Up_to_Date=replace(b.Date_ID,'-',''), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()--,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
		select top 1 Convert(VARCHAR(8),[Load_DTM],112) as Date_ID,Load_Source AS File_NM,Load_DTM as Load_DTM
		from [ODS].[ods].[File_Sales_KA_POS]
		order by [Load_DTM] desc
	)b
	on 1=1
	where Subject_Area='全时，罗森，每日优鲜，便利蜂，爱鲜蜂，嗨家便利，客非Sales';

	--YH Sell-in Target						By:CWC
	update a
	set a.Up_to_Date=CONVERT(varchar(8), Load_DT, 112 ), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate() --,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
	select top 1 [Load_Source] AS File_NM,CONVERT(date, Load_DTM, 120)  as Load_DT from  ODS.[ods].[File_Sales_SellInTarget]
	order by [Monthkey] desc
	)b
	on 1=1
	where Subject_Area='YH Sell-in Target';

	--Sell-In Target					By:CWC
	update a
	set a.Up_to_Date=CONVERT(varchar(8), Load_DT, 112 ), a.Last_Load_File=b.Load_Source,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate() --,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
	select top 1 Load_Source,CONVERT(date, Load_DTM, 120 )  as Load_DT from  ods.[ods].[File_Sales_SellInTarget]
	order by Load_DT desc
	)b
	on 1=1
	where Subject_Area='Sell-In Target';

    --SC ERP Inventory
	update a
	set a.Up_to_Date=CONVERT(varchar(8), Load_DTM, 112 ), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()
	from  aud.ReportSourceMapping a
	join (
	select top 1 Load_DTM as Date_ID,'ERP'as File_NM,Load_DTM as Load_DTM FROM ods.[ods].[ERP_Stock_Inventory]
	order by Load_DTM desc
	)b
	on 1=1
	where Subject_Area='SC Hengzhi Inventory';

	--Kidswant					By:CWC
	update a
	set a.Up_to_Date=CONVERT(varchar(8), Load_DT, 112 ), a.Last_Load_File=b.Load_Source,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate() --,a.Last_Run_Time=cast(b.Load_DTM as datetime)
	--select replace(b.[Date_DT],'-',''),b.File_NM,cast(b.Load_DTM as datetime)
	from  aud.ReportSourceMapping a
	join (
	select top 1 Load_Source,CONVERT(date, Load_DTM, 120 )  as Load_DT from  ods.[ods].[File_Kidswant_DailySales]
	order by Load_DT desc
	)b
	on 1=1
	where Subject_Area='Kidswant Sales&Inventory';

	--O2O KOL Mapping
	update a
	set a.Up_to_Date=CONVERT(varchar(8), Load_DTM, 112 ), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()
	from  aud.ReportSourceMapping a
	join (
		select top 1 Load_DTM as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM FROM ODS.[ods].[SCRM_O2O_QRCodeMapping]
		order by Load_DTM desc
	)b
	on a.Is_Enabled=1
	where Data_Source_Name='O2O KOL Mapping';

	--CRV Pos Data
	update a
	set a.Up_to_Date=CONVERT(varchar(8), Load_DTM, 112 ), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()
	from  aud.ReportSourceMapping a
	join (
		select top 1 sdate as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM FROM ODS.[ods].Mongo_CRV_DailySales
		order by sdate desc
	)b
	on a.Is_Enabled=1
	where Data_Source_Name='CRV Pos Data';

	--Demand Planning
	update a
	set a.Up_to_Date=CONVERT(varchar(8), Load_DTM, 112 ), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()
	from  aud.ReportSourceMapping a
	join (
		select top 1 Load_DTM as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM FROM ODS.[ods].[File_Production_DemandPlanning]		
		order by Load_DTM desc
	)b
	on a.Is_Enabled=1
	where Data_Source_Name='Demand Planning';

	--Plant Produce
	update a
	set a.Up_to_Date=CONVERT(varchar(8), Load_DTM, 112 ), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()
	from  aud.ReportSourceMapping a
	join (
		select top 1 Load_DTM as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM FROM ODS.[ods].File_Plant	
		order by Load_DTM desc
	)b
	on a.Is_Enabled=1
	where Data_Source_Name='Plant Produce';

	--KW Pos Data
	update a
	set a.Up_to_Date=CONVERT(varchar(8), Load_DTM, 112 ), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()
	from  aud.ReportSourceMapping a
	join (
		select top 1 Date as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM FROM ODS.[ods].File_Kidswant_DailySales	
		order by Date desc
	)b
	on a.Is_Enabled=1
	where Data_Source_Name='KW Pos Data';

	--YH Sales Target
	update a
	set a.Up_to_Date=CONVERT(varchar(8), Load_DTM, 112 ), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()
	from  aud.ReportSourceMapping a
	join (
		select top 1 Load_DTM as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM FROM ODS.[ods].File_YHStore_BMTarget	
		order by Load_DTM desc
	)b
	on a.Is_Enabled=1
	where Data_Source_Name='YH Sales Target';

	--Lakto Daily Allin1
	update a
	set a.Up_to_Date=CONVERT(varchar(8), Load_DTM, 112 ), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()
	from  aud.ReportSourceMapping a
	join (
		select top 1 [统计日期] as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM FROM ODS.[ods].File_Tmall_DailyinAll	
		order by [统计日期] desc
	)b
	on a.Is_Enabled=1
	where Data_Source_Name='Lakto Daily Allin1';

	--Youzan Order MonthlyRecon
	update a
	set a.Up_to_Date=CONVERT(varchar(8), Load_DTM, 112 ), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()
	from  aud.ReportSourceMapping a
	join (
		select top 1 Recon_Date as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM FROM ODS.[ods].[File_Youzan_Order_MonthlyRecon]
		order by Recon_Date desc
	)b
	on a.Is_Enabled=1
	where Data_Source_Name='Youzan Order MonthlyRecon';

	--Youzan Sales Detail Reference
	update a
	set a.Up_to_Date=CONVERT(varchar(8), Load_DTM, 112 ), a.Last_Load_File=b.File_NM,a.Last_Run_Time=GETDATE(),
		a.Update_by='[aud].[ReportSourceMapping_Update]',
		a.Update_datetime = getdate()
	from  aud.ReportSourceMapping a
	join (
		select top 1 Recon_Date as Date_ID,Load_Source as File_NM,Load_DTM as Load_DTM FROM ODS.[ods].[File_Youzan_Sales_Detail_Reference]
		order by Recon_Date desc
	)b
	on a.Is_Enabled=1
	where Data_Source_Name='Youzan Sales Detail Reference';

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END
GO
