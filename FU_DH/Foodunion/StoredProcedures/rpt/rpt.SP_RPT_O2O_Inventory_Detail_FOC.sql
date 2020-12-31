USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









--exec [rpt].[SP_RPT_O2O_Inventory_Detail_FOC]


CREATE PROC [rpt].[SP_RPT_O2O_Inventory_Detail_FOC]
AS
BEGIN

	DECLARE @PROGRAM_RUN_DATE AS VARCHAR(30)
	SET @PROGRAM_RUN_DATE = CONVERT(VARCHAR(8),GETDATE(),112)

	DELETE FROM rpt.O2O_Inventory_Detail_FOC_Log
	WHERE Record_Generate_Date = @PROGRAM_RUN_DATE

    ---------------------Step1.1: FOC申请单
    DROP TABLE IF EXISTS #SNM_FOC
	SELECT
		 snm.SP_NUM
		,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date) AS [APPLY_Date]
		,al.APPLY_NAME AS APPLY_NAME
		,CASE WHEN snm.v LIKE '%|%' THEN SUBSTRING(snm.v,CHARINDEX('|',snm.v)+1,7) ELSE REPLACE(LEFT(snm.v,CHARINDEX(' ',snm.v)),' ','') END AS SKU_ID
		,SUM(CAST(qty.V AS FLOAT)) AS FOC_Qty
	INTO #SNM_FOC
	FROM [DM].[FCT_O2O_WX_APPLYDATA]  snm 
	INNER JOIN [DM].[FCT_O2O_WX_APPLYLIST] al ON al.SP_NUM=snm.SP_NUM
	INNER JOIN [DM].[FCT_O2O_WX_APPLYDATA] qty ON qty.SP_NUM=snm.SP_NUM AND qty.item_id = snm.item_id+2 --自关联，取当前产品对应的库存数量
	INNER JOIN [DM].[FCT_O2O_WX_APPLYDATA] pd ON pd.SP_NUM=snm.SP_NUM AND pd.item_id = snm.item_id+1--自关联，取当前产品对应的生产日期
	INNER JOIN [DM].[FCT_O2O_WX_APPLYDATA] rs ON rs.SP_NUM=snm.SP_NUM AND rs.item_id=snm.item_id-1--自关联，取当前产品对应申请原因
	WHERE snm.K= '产品名称'
	AND rs.v in ('试吃活动','随单赠送','环保袋换')
	AND al.sp_status  IN ('1','2')
	GROUP BY snm.sp_num
			,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date)
			,al.APPLY_NAME
			,CASE WHEN snm.v LIKE '%|%' THEN SUBSTRING(snm.v,CHARINDEX('|',snm.v)+1,7) ELSE REPLACE(LEFT(snm.v,CHARINDEX(' ',snm.v)),' ','') END

	---------------------Step1.2: FOC申请单按申请日期排序
    DROP TABLE IF EXISTS #FOC
    SELECT SP_NUM
	    ,[APPLY_Date]
		,SKU_ID
        ,APPLY_NAME
		,FOC_Qty
		,sum(FOC_Qty) over(partition by SKU_ID order by [APPLY_Date] asc,SP_NUM asc)  as cummulated_foc_Qty
        INTO #FOC
    FROM #SNM_FOC
	--WHERE convert(varchar(6),[APPLY_Date],112) = convert(varchar(6),dateadd(M,-2,getdate()),112)
	WHERE convert(varchar(8),[APPLY_Date],112) between '20191030' and convert(varchar(8),getdate(),112)		--起始单据设置为2019年10月30日开始的单据，10月29号之前的，财务已经全部扣减

	DROP TABLE IF EXISTS #SNM_FOC

    ---------------------Step2: 赢养顾问网点库存
    DROP TABLE IF EXISTS #ERP_inventory
    select inv.SKU_ID,
           inv.Produce_Date,
           inv.LOT,
           inv.Expiry_Date,
           inv.Stock_Unit,
           floor(inv.Sale_QTY) as Sale_QTY,
           sum(floor(inv.Sale_QTY)) over(partition by inv.SKU_ID order by inv.Produce_Date asc,inv.LOT asc) as cummulated_inventory_qty
           --row_number() over(partition by inv.SKU_ID order by inv.SKU_ID,inv.Produce_Date asc) as row_num
    into #ERP_inventory
    from [dm].[Fct_ERP_Stock_Inventory] inv
    where Stock_Name = '赢养顾问网点库存' and Sale_QTY <> 0
    and DateKey = (select max(DateKey) from [dm].[Fct_ERP_Stock_Inventory])
    --order by SKU_ID,Produce_Date
	
    ---------------------Step3: 对比网点库存和 FOC 单据数量
    DROP TABLE IF EXISTS #ERP_inventory_deduct_foc
    select foc.SP_NUM,
		   foc.SKU_ID,
		   foc.APPLY_Date,
		   foc.apply_name,
           erp_inv.Produce_Date,
           erp_inv.LOT,
           erp_inv.Expiry_Date,
           erp_inv.Stock_Unit,
           erp_inv.Sale_QTY,
           erp_inv.cummulated_inventory_qty,
           foc.FOC_Qty,
		   foc.cummulated_foc_Qty,

		   /* 对每个SKU, 按单据提交日期升序排列后的 [累计FOC数量] - 按库存批次日期升序排列后的 [累计批次数量]，用来判断单据是否还可以继续扣减下一个批次*/
           foc.cummulated_foc_Qty - IsNull(erp_inv.cummulated_inventory_qty,0) as remnant_foc_qty,
		   row_number() over(partition by foc.SKU_ID,erp_inv.Produce_Date,erp_inv.LOT
							 order by foc.APPLY_Date,foc.SP_NUM) lot_row_num
    into #ERP_inventory_deduct_foc
    from #FOC foc
    left join #ERP_inventory erp_inv
    on foc.SKU_ID = erp_inv.SKU_ID

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
           t1.Sale_QTY,
           t1.cummulated_inventory_qty,
           t1.FOC_Qty,
		   t1.cummulated_foc_Qty,
           t1.remnant_foc_qty,
		   t1.lot_row_num,
		   CASE WHEN t2.remnant_foc_qty is null then t1.Sale_QTY
		        WHEN t2.remnant_foc_qty < 0 THEN -1 * t2.remnant_foc_qty
				WHEN t2.remnant_foc_qty > 0 THEN 0
				WHEN t2.remnant_foc_qty = 0 THEN 0 END AS LOT_remain_qty
	into #rpt_inventory_step1
	from #ERP_inventory_deduct_foc t1
	left join #ERP_inventory_deduct_foc t2
	on t1.SKU_ID = t2.SKU_ID AND t1.LOT = t2.LOT AND t1.lot_row_num = t2.lot_row_num + 1 
	AND convert(varchar(8),t1.Produce_Date,112) = convert(varchar(8),t2.Produce_Date,112)

	/* ---------------------Step5-1: 
	 * 累计FOC数量 < 累计批次数量, 对应批次没有扣完
	 * 累计FOC数量 = 累计批次数量, 对应批次刚好扣完 (具体的扣减数量需要根据情况判断, 例如 FOC 单据连续冲了两个批次号)
	*/
    DROP TABLE IF EXISTS #inventory_rpt_dataset1
    select SP_NUM,
		   APPLY_Date,
		   SKU_ID,
           Stock_Unit,
           Produce_Date,
           LOT,
           --Expiry_Date,
		   apply_name,
           Sale_QTY,
           cummulated_inventory_qty,
           FOC_Qty,
		   cummulated_foc_Qty,
           remnant_foc_qty,
		   LOT_remain_qty,
		   CASE WHEN Sale_QTY + remnant_foc_qty > FOC_Qty THEN FOC_Qty
		        WHEN Sale_QTY + remnant_foc_qty < FOC_Qty THEN Sale_QTY + remnant_foc_qty
				WHEN Sale_QTY + remnant_foc_qty = FOC_Qty THEN Sale_QTY + remnant_foc_qty
				END AS [数量],
		   row_number() over(partition by SKU_ID,APPLY_Date,SP_NUM
							 order by APPLY_Date,SP_NUM asc,Produce_Date asc,LOT asc, remnant_foc_qty desc) as row_num
	into #inventory_rpt_dataset1
	from #rpt_inventory_step1
	where remnant_foc_qty < 0
	
	/* ---------------------Step5-2: 
	 * 累计报废数量 > 累计批次数量, 对应批次扣完
	 * 累计报废数量 = 累计批次数量, 对应批次扣完，两种情况：(1)两个报废单合起来扣完这个批次，(2)单独一个报废单扣完这个批次
	*/
    DROP TABLE IF EXISTS #inventory_rpt_dataset2
    select SP_NUM,
		   APPLY_Date,
		   SKU_ID,
           Stock_Unit,
           Produce_Date,
           LOT,
           --Expiry_Date,
		   apply_name,
           Sale_QTY,
           cummulated_inventory_qty,
           FOC_Qty,
		   cummulated_foc_Qty,
           remnant_foc_qty,
		   LOT_remain_qty,
		   --LOT_remain_qty AS [数量],
	   --    CASE WHEN remnant_foc_qty > 0 THEN LOT_remain_qty
		  --      WHEN remnant_foc_qty = 0 AND LOT_remain_qty > Sale_QTY THEN Sale_QTY
				--WHEN remnant_foc_qty = 0 AND LOT_remain_qty = Sale_QTY THEN Sale_QTY
				--WHEN remnant_foc_qty = 0 AND LOT_remain_qty < Sale_QTY THEN LOT_remain_qty
				--END AS [数量],
	       CASE WHEN LOT_remain_qty > Sale_QTY THEN Sale_QTY
				WHEN LOT_remain_qty = Sale_QTY THEN Sale_QTY
				WHEN LOT_remain_qty < Sale_QTY THEN LOT_remain_qty
				END AS [数量],
	       rank() over(partition by SKU_ID order by APPLY_Date asc,SP_NUM asc) as rank_num
	into #inventory_rpt_dataset2
	from #rpt_inventory_step1
	where remnant_foc_qty >= 0

	---------------------Step6: 报废单写入LOG表 rpt.O2O_Inventory_Detail_FOC_LOG
	insert into rpt.O2O_Inventory_Detail_FOC_LOG(sp_num,Record_Generate_Date,Create_time,Update_time,Create_By,Update_By)
	select distinct sp_num,
		   @PROGRAM_RUN_DATE as Record_Generate_Date,
		   getdate() as Create_time,
		   getdate() as Update_time,
	       'rpt.SP_RPT_O2O_Inventory_Detail_FOC' AS Create_By,
		   'rpt.SP_RPT_O2O_Inventory_Detail_FOC' AS Update_By
	from (
		  select distinct sp_num from #inventory_rpt_dataset1
		  union all
		  select distinct sp_num from #inventory_rpt_dataset2
		 ) as tmp_list
	where sp_num not in (select sp_num from rpt.O2O_Inventory_Detail_FOC_LOG)

	---------------------Step6: 生成报表数据
    select SKU,[Product Name],[规格],[批次号],[数量],[RDC仓库],[单位] as Unit,KOL as [收货人(KOL)],[FOC单据提交日期],[FOC单据],[FOC单据数量],[批次号即时库存数量]
	from (
	--6.1 对应批次未扣完
    select ds.SKU_ID AS SKU,
		   sku.SKU_Name_CN AS [Product Name],
		   sku.Sale_Scale AS [规格],
		   ds.[数量],
		   IsNull(ds.Stock_Unit,sku.Sale_Unit) AS [单位],
		   ds.LOT AS [批次号],
		   'O2O.03' AS [RDC仓库],
		   ds.apply_name AS KOL
		  ,ds.APPLY_Date AS [FOC单据提交日期]
	      ,ds.SP_NUM AS [FOC单据]
		  ,ds.FOC_Qty as [FOC单据数量]
		  ,ds.Sale_QTY as [批次号即时库存数量]
	from #inventory_rpt_dataset1 ds
	left join dm.dim_product sku
	on ds.SKU_ID = sku.SKU_ID
	where isNull(ds.[数量],0) > 0
	--AND ds.LOT_remain_qty <> 0

	--6.2 对应批次已扣完
	union all
    select ds.SKU_ID AS SKU,
		   sku.SKU_Name_CN AS [Product Name],
		   sku.Sale_Scale AS [规格],
		   ds.[数量],
		   IsNull(ds.Stock_Unit,sku.Sale_Unit) AS [单位],
		   ds.LOT AS [批次号],
		   'O2O.03' AS [RDC仓库],
		   ds.apply_name AS KOL
		  ,ds.APPLY_Date AS [FOC单据提交日期]
	      ,ds.SP_NUM AS [FOC单据]
		  ,ds.FOC_Qty as [FOC单据数量]
		  ,ds.Sale_QTY as [批次号即时库存数量]
	from #inventory_rpt_dataset2 ds
	left join dm.dim_product sku
	on ds.SKU_ID = sku.SKU_ID
	where isNull(ds.[数量],0) > 0
	--AND ds.LOT_remain_qty <> 0

	--6.3 报废单的SKU已经没有库存 (SKU在微信申请单，不在ERP库存表里)
	union all
    select ds.SKU_ID AS SKU,
		   sku.SKU_Name_CN AS [Product Name],
		   sku.Sale_Scale AS [规格],
		   ds.[数量],
		   IsNull(ds.Stock_Unit,sku.Sale_Unit) AS [单位],
		   ds.LOT AS [批次号],
		   'O2O.03' AS [RDC仓库],
		   ds.apply_name AS KOL
		  ,ds.APPLY_Date AS [FOC单据提交日期]
	      ,ds.SP_NUM AS [FOC单据]
		  ,ds.FOC_Qty as [FOC单据数量]
		  ,ds.Sale_QTY as [批次号即时库存数量]
	from #inventory_rpt_dataset2 ds
	left join dm.dim_product sku
	on ds.SKU_ID = sku.SKU_ID
	where ds.[数量] IS NULL

	union all
    select ds.SKU_ID AS SKU,
		   sku.SKU_Name_CN AS [Product Name],
		   sku.Sale_Scale AS [规格],
		   ds.[数量],
		   IsNull(ds.Stock_Unit,sku.Sale_Unit) AS [单位],
		   ds.LOT AS [批次号],
		   'O2O.03' AS [RDC仓库],
		   ds.apply_name AS KOL
		  ,ds.APPLY_Date AS [FOC单据提交日期]
	      ,ds.SP_NUM AS [FOC单据]
		  ,ds.FOC_Qty as [FOC单据数量]
		  ,ds.Sale_QTY as [批次号即时库存数量]
	from #inventory_rpt_dataset1 ds
	left join dm.dim_product sku
	on ds.SKU_ID = sku.SKU_ID
	where ds.[数量] IS NULL
	) result
	WHERE [FOC单据] in (select sp_num from rpt.O2O_Inventory_Detail_FOC_Log where Record_Generate_Date = @PROGRAM_RUN_DATE)
	order by SKU,[FOC单据提交日期],[FOC单据],[批次号]


   END
GO
