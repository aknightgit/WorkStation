USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







--exec [rpt].[SP_RPT_O2O_Inventory_Detail_Expire]


CREATE PROC [rpt].[SP_RPT_O2O_Inventory_Detail_Expire]
AS
BEGIN


	DECLARE @PROGRAM_RUN_DATE AS VARCHAR(30)
	SET @PROGRAM_RUN_DATE = CONVERT(VARCHAR(8),GETDATE(),112)

	DELETE FROM rpt.O2O_Inventory_Detail_Expire_Log
	WHERE Record_Generate_Date = @PROGRAM_RUN_DATE

    ---------------------Step1.1: 报废申请单
    DROP TABLE IF EXISTS #SNM_Expire
    SELECT snm.SP_NUM
	    ,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date) AS [APPLY_Date]
		,CASE WHEN snm.v LIKE '%|%' THEN SUBSTRING(snm.v,CHARINDEX('|',snm.v)+1,7) ELSE REPLACE(LEFT(snm.v,CHARINDEX(' ',snm.v)),' ','') END AS SKU_ID
        --,snm.V SKU_NAME
        ,al.APPLY_NAME
		,sum(CAST(qty.V AS FLOAT)) AS Expire_Qty
        INTO #SNM_Expire
    FROM [DM].[FCT_O2O_WX_APPLYDATA]  snm
    LEFT JOIN [DM].[FCT_O2O_WX_APPLYLIST] al ON al.SP_NUM=snm.SP_NUM
    LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] qty ON qty.SP_NUM=snm.SP_NUM AND qty.ITEM_ID=snm.ITEM_ID+2 --自关联，取当前产品对应的库存数量
    LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] pd ON pd.SP_NUM=snm.SP_NUM AND pd.ITEM_ID=snm.ITEM_ID+1--自关联，取当前产品对应的生产日期
    LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] rs ON rs.SP_NUM=snm.SP_NUM AND rs.ITEM_ID=snm.ITEM_ID+3--自关联，取当前产品对应申请原因
    --LEFT JOIN (SELECT sp_num,item_id,k,v,RIGHT(v,[dbo].[IndexOfChR](v)) AS [Period] FROM [DM].[FCT_O2O_WX_APPLYDATA] WHERE k = '库存期间' AND v LIKE '%期间%') pddt ON pddt.SP_NUM=snm.SP_NUM --自关联，当前sp_num 的库存期间
    WHERE snm.K= '产品名称'
    AND qty.K ='数量'
    AND al.spname = 'O2O-库存产品报废'
--    AND rs.v in ('包装损坏','过期')
    AND al.sp_status  IN ('1','2')
    --AND pddt.sp_num IS NOT NULL
	GROUP BY snm.sp_num
		,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date)
		,al.APPLY_NAME
		,snm.V


	---------------------Step1.2: 报废申请单按申请日期排序
    DROP TABLE IF EXISTS #Expire
    SELECT SP_NUM
	    ,[APPLY_Date]
		,SKU_ID
        ,APPLY_NAME
		,Expire_Qty
		,sum(Expire_Qty) over(partition by SKU_ID order by [APPLY_Date] asc,SP_NUM asc)  as cummulated_expire_Qty
        INTO #Expire
    FROM #SNM_Expire
	--WHERE convert(varchar(6),[APPLY_Date],112) = convert(varchar(6),dateadd(M,-2,getdate()),112)
	WHERE convert(varchar(8),[APPLY_Date],112) between '20191030' and convert(varchar(8),getdate(),112)		--起始单据设置为2019年10月30日开始的单据，10月29号之前的，财务已经全部扣减

	DROP TABLE IF EXISTS #SNM_Expire

    ---------------------Step2: 赢养顾问网点库存
    DROP TABLE IF EXISTS #ERP_inventory
    select inv.SKU_ID,
           inv.Produce_Date,
           inv.LOT,
           inv.Expiry_Date,
           inv.Stock_Unit,
           'y' as [是否残损],
           'y' as [是否过期],
           floor(inv.Sale_QTY) as Sale_QTY,
           sum(floor(inv.Sale_QTY)) over(partition by inv.SKU_ID order by inv.Produce_Date asc,inv.LOT asc) as cummulated_inventory_qty
           --row_number() over(partition by inv.SKU_ID order by inv.SKU_ID,inv.Produce_Date asc) as row_num
    into #ERP_inventory
    from [dm].[Fct_ERP_Stock_Inventory] inv
    where Stock_Name = '赢养顾问网点库存' and Sale_QTY <> 0
    and DateKey = (select max(DateKey) from [dm].[Fct_ERP_Stock_Inventory])
    --order by SKU_ID,Produce_Date

    ---------------------Step3: 赢养顾问网点库存按批次生产日期升序排列
    DROP TABLE IF EXISTS #ERP_inventory_deduct_Expire
    select expire_inv.SP_NUM,
		   expire_inv.SKU_ID,
		   expire_inv.APPLY_Date,
		   expire_inv.apply_name,
           erp_inv.Produce_Date,
           erp_inv.LOT,
           erp_inv.Expiry_Date,
           erp_inv.Stock_Unit,
           'y' as [是否残损],
           'y' as [是否过期],
           erp_inv.Sale_QTY,
           erp_inv.cummulated_inventory_qty,
           expire_inv.Expire_Qty,
		   expire_inv.cummulated_expire_Qty,

		   /* 按SKU_ID报废单据提交日期升序排列后的 [累计报废数量] - 按SKU_ID库存批次生产日期升序排列后的 [累计批次数量]，用来判断是否还可以继续扣减下一个批次*/
           expire_inv.cummulated_expire_Qty - IsNull(erp_inv.cummulated_inventory_qty,0) as remnant_expire_qty,
		   row_number() over(partition by expire_inv.SKU_ID,erp_inv.Produce_Date,erp_inv.LOT
							 order by expire_inv.APPLY_Date,expire_inv.SP_NUM) lot_row_num
    into #ERP_inventory_deduct_Expire
    from #Expire expire_inv
    left join #ERP_inventory erp_inv
    on expire_inv.SKU_ID = erp_inv.SKU_ID

	---------------------Step4: 根据步骤 Step3中 lot_row_num, 找出每个批次 扣减 报废单数量之后，还剩下的累计数量
	DROP TABLE IF EXISTS #rpt_inventory_step1
    select t1.SP_NUM,
		   t1.SKU_ID,
		   t1.APPLY_Date,
		   t1.apply_name,
           t1.Produce_Date,
           t1.LOT,
           t1.Expiry_Date,
           t1.Stock_Unit,
           t1.[是否残损],
           t1.[是否过期],
           t1.Sale_QTY,
           t1.cummulated_inventory_qty,
           t1.Expire_Qty,
		   t1.cummulated_expire_Qty,
           t1.remnant_expire_qty,
		   t1.lot_row_num,
		   CASE WHEN t2.remnant_expire_qty is null then t1.Sale_QTY
		        WHEN t2.remnant_expire_qty < 0 THEN -1 * t2.remnant_expire_qty
				WHEN t2.remnant_expire_qty > 0 THEN 0
				WHEN t2.remnant_expire_qty = 0 THEN 0 END AS LOT_remain_qty
	into #rpt_inventory_step1
	from #ERP_inventory_deduct_Expire t1
	left join #ERP_inventory_deduct_Expire t2
	on t1.SKU_ID = t2.SKU_ID AND t1.LOT = t2.LOT AND t1.lot_row_num = t2.lot_row_num + 1 
	AND convert(varchar(8),t1.Produce_Date,112) = convert(varchar(8),t2.Produce_Date,112)

	/* ---------------------Step5-1: 
	 * 累计报废数量 < 累计批次数量, 对应批次没有扣完
	*/
    DROP TABLE IF EXISTS #inventory_rpt_dataset1
    select SP_NUM,
		   APPLY_Date,
		   SKU_ID,
           Stock_Unit,
           Produce_Date,
           LOT,
           --Expiry_Date,
           'y' AS [是否残损],
           'y' as [是否过期],
		   apply_name,
           Sale_QTY,
           cummulated_inventory_qty,
           Expire_Qty,
		   cummulated_expire_Qty,
           remnant_expire_qty,
		   LOT_remain_qty,
		   CASE WHEN Sale_QTY + remnant_expire_qty > Expire_Qty THEN Expire_Qty
		        WHEN Sale_QTY + remnant_expire_qty < Expire_Qty THEN Sale_QTY + remnant_expire_qty
				WHEN Sale_QTY + remnant_expire_qty = Expire_Qty THEN Sale_QTY + remnant_expire_qty
				END AS [数量],
		   row_number() over(partition by SKU_ID,APPLY_Date,SP_NUM
							 order by APPLY_Date,SP_NUM asc,Produce_Date asc,LOT asc, remnant_expire_qty desc) as row_num
	into #inventory_rpt_dataset1
	from #rpt_inventory_step1
	where remnant_expire_qty < 0
	
	/* ---------------------Step5-2: 
	 * 累计报废数量 > 累计批次数量, 对应批次扣完
	*/
    DROP TABLE IF EXISTS #inventory_rpt_dataset2
    select SP_NUM,
		   APPLY_Date,
		   SKU_ID,
           Stock_Unit,
           Produce_Date,
           LOT,
           --Expiry_Date,
           'y' AS [是否残损],
           'y' as [是否过期],
		   apply_name,
           Sale_QTY,
           cummulated_inventory_qty,
           Expire_Qty,
		   cummulated_expire_Qty,
           remnant_expire_qty,
		   LOT_remain_qty,
		   --LOT_remain_qty AS [数量],
	       CASE WHEN LOT_remain_qty > Sale_QTY THEN Sale_QTY
				WHEN LOT_remain_qty = Sale_QTY THEN Sale_QTY
				WHEN LOT_remain_qty < Sale_QTY THEN LOT_remain_qty
				END AS [数量],
	       rank() over(partition by SKU_ID order by APPLY_Date asc,SP_NUM asc) as rank_num
	into #inventory_rpt_dataset2
	from #rpt_inventory_step1
	where remnant_expire_qty >= 0

	---------------------Step6: 报废单写入LOG表 rpt.O2O_Inventory_Detail_Expire_LOG
	insert into rpt.O2O_Inventory_Detail_Expire_LOG(sp_num,Record_Generate_Date,Create_time,Update_time,Create_By,Update_By)
	select distinct sp_num,
		   @PROGRAM_RUN_DATE as Record_Generate_Date,
		   getdate() as Create_time,
		   getdate() as Update_time,
	       'rpt.SP_RPT_O2O_Inventory_Detail_Expire' AS Create_By,
		   'rpt.SP_RPT_O2O_Inventory_Detail_Expire' AS Update_By
	from (
		  select distinct sp_num from #inventory_rpt_dataset1
		  union all
		  select distinct sp_num from #inventory_rpt_dataset2
		 ) as tmp_list
	where sp_num not in (select sp_num from rpt.O2O_Inventory_Detail_Expire_LOG)

	---------------------Step6: 生成报表数据
	--insert into [rpt].[O2O_Inventory_Detail_Expire](
	--       SKU,[名称],[数量],[单位],[批次号],[是否残损],[是否过期],KOL,[报废单提交日期],[报废单],[报废单数量],[批次号即时库存数量]
	--	   )
    select SKU,[名称],[数量],[单位],[批次号],[是否残损],[是否过期],KOL,[报废单提交日期],[报废单],[报废单数量],[批次号即时库存数量]
	from (
	--6.1 对应批次未扣完
    select ds.SKU_ID AS SKU,
		   sku.SKU_Name_CN AS [名称],
		   ds.[数量],
		   ds.Stock_Unit AS [单位],
		   ds.LOT AS [批次号],
	       ds.[是否残损],
		   ds.[是否过期],
		   ds.apply_name AS KOL
		  ,ds.APPLY_Date AS [报废单提交日期]
	      ,ds.SP_NUM AS [报废单]
		  ,ds.Expire_Qty as [报废单数量]
		  ,ds.Sale_QTY as [批次号即时库存数量]
	from #inventory_rpt_dataset1 ds
	left join dm.dim_product sku
	on ds.SKU_ID = sku.SKU_ID
	where isNull(ds.[数量],0) > 0
	--AND ds.LOT_remain_qty <> 0

	--6.2 对应批次已扣完
	union all
    select ds.SKU_ID AS SKU,
		   sku.SKU_Name_CN AS [名称],
		   ds.[数量],
		   ds.Stock_Unit AS [单位],
		   ds.LOT AS [批次号],
	       ds.[是否残损],
		   ds.[是否过期],
		   ds.apply_name AS KOL
		  ,ds.APPLY_Date AS [报废单提交日期]
	      ,ds.SP_NUM AS [报废单]
		  ,ds.Expire_Qty as [报废单数量]
		  ,ds.Sale_QTY as [批次号即时库存数量]
	from #inventory_rpt_dataset2 ds
	left join dm.dim_product sku
	on ds.SKU_ID = sku.SKU_ID
	where isNull(ds.[数量],0) > 0
	--AND ds.LOT_remain_qty <> 0

	--6.3 报废单的SKU已经没有库存
	union all
    select ds.SKU_ID AS SKU,
		   sku.SKU_Name_CN AS [名称],
		   ds.[数量],
		   ds.Stock_Unit AS [单位],
		   ds.LOT AS [批次号],
	       ds.[是否残损],
		   ds.[是否过期],
		   ds.apply_name AS KOL
		  ,ds.APPLY_Date AS [报废单提交日期]
	      ,ds.SP_NUM AS [报废单]
		  ,ds.Expire_Qty as [报废单数量]
		  ,ds.Sale_QTY as [批次号即时库存数量]
	from #inventory_rpt_dataset2 ds
	left join dm.dim_product sku
	on ds.SKU_ID = sku.SKU_ID
	where ds.[数量] IS NULL

	union all
    select ds.SKU_ID AS SKU,
		   sku.SKU_Name_CN AS [名称],
		   ds.[数量],
		   ds.Stock_Unit AS [单位],
		   ds.LOT AS [批次号],
	       ds.[是否残损],
		   ds.[是否过期],
		   ds.apply_name AS KOL
		  ,ds.APPLY_Date AS [报废单提交日期]
	      ,ds.SP_NUM AS [报废单]
		  ,ds.Expire_Qty as [报废单数量]
		  ,ds.Sale_QTY as [批次号即时库存数量]
	from #inventory_rpt_dataset1 ds
	left join dm.dim_product sku
	on ds.SKU_ID = sku.SKU_ID
	where ds.[数量] IS NULL
	) result
	WHERE [报废单] in (select sp_num from rpt.O2O_Inventory_Detail_Expire_Log where Record_Generate_Date = @PROGRAM_RUN_DATE)
	order by SKU,[报废单提交日期],[报废单],[批次号]

   END
GO
