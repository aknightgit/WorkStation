USE [Foodunion]
GO
DROP PROCEDURE [rpt].[SP_RPT_O2O_Inventory_Detail_NEW]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROC [rpt].[SP_RPT_O2O_Inventory_Detail_NEW]
AS
BEGIN


-------------------------------获取期间数据并进行排序
DROP TABLE IF EXISTS #Period_Rank

SELECT [Period]
	  ,sp_year_max+'/'+LEFT([period],CHARINDEX('-',[period])-1) AS Begin_DT
	  ,sp_year_min+'/'+RIGHT([period],LEN([period])-CHARINDEX('-',[period])) AS End_DT
	  ,DENSE_RANK() OVER(ORDER BY sp_year_max+'/'+LEFT([period],CHARINDEX('-',[period])-1)) AS Period_Rank
	  ,[Date]
	  INTO #Period_Rank
FROM 
(SELECT  MAX(LEFT(sp_num,4)) AS sp_year_max,MIN(LEFT(sp_num,4)) AS sp_year_min,RIGHT(v,[dbo].[IndexOfChR](v)) AS [Period],MIN(v) AS [Date] FROM [DM].[FCT_O2O_WX_APPLYDATA] WHERE v LIKE '%期间%' GROUP BY RIGHT(v,[dbo].[IndexOfChR](v))) AS per
select * from #Period_Rank

-----------------------------------库存
	DROP TABLE IF EXISTS #Inventory


	SELECT  
		 snm.SP_NUM
		,LEFT(snm.sp_num,4) AS sp_year
		,al.SPNAME
		,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date) AS 'APPLY_Date'
		,pddt.[period] AS [period]
		,al.APPLY_NAME AS APPLY_NAME
		,CASE WHEN snm.v LIKE '%|%' THEN SUBSTRING(snm.v,CHARINDEX('|',snm.v)+1,7) ELSE REPLACE(LEFT(snm.v,CHARINDEX(' ',snm.v)),' ','') END AS SKU_ID
		,snm.V SKU_NAME
--		,CAST(CASE WHEN RIGHT(pd.v,5)='00000' THEN DATEADD(S,cast(pd.v as bigint)/1000 + 8 * 3600,'1970-01-01')  ELSE pd.v END as date) AS 'PRODUCE_DATE'
		,SUM(CAST(qty.V AS FLOAT)) AS Inventory_Qty
	INTO #Inventory
	FROM [DM].[FCT_O2O_WX_APPLYDATA]  snm
	INNER JOIN [DM].[FCT_O2O_WX_APPLYLIST] al ON al.SP_NUM=snm.SP_NUM
	LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] qty ON qty.SP_NUM=snm.SP_NUM AND qty.ITEM_ID=snm.ITEM_ID+2 --自关联，取当前产品对应的库存数量
	LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] pd ON pd.SP_NUM=snm.SP_NUM AND pd.ITEM_ID=snm.ITEM_ID+1--自关联，取当前产品对应的生产日期
	LEFT JOIN (SELECT sp_num,item_id,k,v,RIGHT(v,[dbo].[IndexOfChR](v)) AS [Period] FROM [DM].[FCT_O2O_WX_APPLYDATA] WHERE k = '盘点日期' AND v LIKE '%期间%') pddt ON pddt.SP_NUM=snm.SP_NUM --自关联，当前sp_num 的盘点日期
	--LEFT JOIN FU_EDW.Dim_Calendar AS cal ON CAST(CASE WHEN RIGHT(pddt.v,5)='00000' THEN DATEADD(S,cast(pddt.v as bigint)/1000 + 8 * 3600,'1970-01-01')  ELSE pddt.v END as date) = cal.Date_NM			--现在通过手工填的区间来
	WHERE snm.K= '产品名称'
	AND al.SPNAME='O2O-周产品盘点'
	AND qty.K ='产品数量（盒）'
	AND pd.K='生产日期'
	AND al.sp_status  IN ('1','2')
	AND pddt.sp_num IS NOT NULL
	GROUP BY snm.sp_num
			,al.APPLY_NAME
			,al.SPNAME
			,al.APPLY_TIME
			,pddt.[period]
			,snm.V
		--	,pd.v	--生产日期


	----------------------入库		
	DROP TABLE IF EXISTS #InStock


		SELECT  
		 snm.SP_NUM
		,al.SPNAME
		,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date) AS 'APPLY_Date'
		,pddt.[period] AS [period]
		,al.APPLY_NAME AS APPLY_NAME
		,CASE WHEN snm.v LIKE '%|%' THEN SUBSTRING(snm.v,CHARINDEX('|',snm.v)+1,7) ELSE REPLACE(LEFT(snm.v,CHARINDEX(' ',snm.v)),' ','') END AS SKU_ID
		,snm.V SKU_NAME
		,SUM(CAST(qty.V AS FLOAT)) AS Instock_Qty
	INTO #InStock
	FROM [DM].[FCT_O2O_WX_APPLYDATA]  snm
	INNER JOIN [DM].[FCT_O2O_WX_APPLYLIST] al ON al.SP_NUM=snm.SP_NUM
	INNER JOIN [DM].[FCT_O2O_WX_APPLYDATA] qty ON qty.SP_NUM=snm.SP_NUM AND qty.ITEM_ID=snm.ITEM_ID+1 --自关联，取当前产品对应的库存数量
	LEFT JOIN (SELECT sp_num,item_id,k,v,RIGHT(v,[dbo].[IndexOfChR](v)) AS [Period] FROM [DM].[FCT_O2O_WX_APPLYDATA] WHERE k = '补货时间' AND v LIKE '%期间%') pddt ON pddt.SP_NUM=snm.SP_NUM --自关联，当前sp_num 的补货日期
	WHERE snm.K= '产品名称'
	AND al.spname in ('o2o-产品补货申请')
	AND qty.K ='数量（单位：盒）'
	AND al.sp_status  IN ('1','2')
	AND pddt.sp_num IS NOT NULL
	GROUP BY  snm.sp_num
			,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date)
			,al.APPLY_NAME
			,al.SPNAME
			,al.APPLY_TIME
			,snm.V
		--	,al.sp_status
			,pddt.[period]


	---------------------FOC

	DROP TABLE IF EXISTS #FOC
	SELECT
		 snm.SP_NUM
		,al.SPNAME
		,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date) AS 'APPLY_Date'
		,pddt.[period] AS [period]
		,al.APPLY_NAME AS APPLY_NAME
		,CASE WHEN snm.v LIKE '%|%' THEN SUBSTRING(snm.v,CHARINDEX('|',snm.v)+1,7) ELSE REPLACE(LEFT(snm.v,CHARINDEX(' ',snm.v)),' ','') END AS SKU_ID
		,snm.V SKU_NAME
		,SUM(CAST(qty.V AS FLOAT)) AS FOC_Qty
	INTO #FOC
	FROM [DM].[FCT_O2O_WX_APPLYDATA]  snm 
	INNER JOIN [DM].[FCT_O2O_WX_APPLYLIST] al ON al.SP_NUM=snm.SP_NUM
	INNER JOIN [DM].[FCT_O2O_WX_APPLYDATA] qty ON qty.SP_NUM=snm.SP_NUM AND qty.item_id = snm.item_id+2 --自关联，取当前产品对应的库存数量
	INNER JOIN [DM].[FCT_O2O_WX_APPLYDATA] pd ON pd.SP_NUM=snm.SP_NUM AND pd.item_id = snm.item_id+1--自关联，取当前产品对应的生产日期
	INNER JOIN [DM].[FCT_O2O_WX_APPLYDATA] rs ON rs.SP_NUM=snm.SP_NUM AND rs.item_id=snm.item_id-1--自关联，取当前产品对应申请原因
	LEFT JOIN (SELECT sp_num,item_id,k,v,RIGHT(v,[dbo].[IndexOfChR](v)) AS [Period] FROM [DM].[FCT_O2O_WX_APPLYDATA] WHERE k = '库存期间' AND v LIKE '%期间%') pddt ON pddt.SP_NUM=snm.SP_NUM --自关联，当前sp_num 的库存期间
	WHERE snm.K= '产品名称'
	AND rs.v in ('试吃活动','随单赠送','环保袋换')
	AND al.sp_status  IN ('1','2')
	AND pddt.sp_num IS NOT NULL
	GROUP BY snm.sp_num
			,al.APPLY_NAME
			,al.APPLY_TIME
			,al.SPNAME
			,snm.V
			,pddt.[period]
			
	---------------------报废
	DROP TABLE IF EXISTS #Expire
	SELECT  
		 snm.SP_NUM
		,al.SPNAME
		,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date) AS 'APPLY_Date'
		,pddt.[period] AS [period]
		,al.APPLY_NAME AS APPLY_NAME
		,CASE WHEN snm.v LIKE '%|%' THEN SUBSTRING(snm.v,CHARINDEX('|',snm.v)+1,7) ELSE REPLACE(LEFT(snm.v,CHARINDEX(' ',snm.v)),' ','') END AS SKU_ID
		,snm.V SKU_NAME
		,SUM(CAST(qty.V AS FLOAT)) AS Expire_Qty
		INTO #Expire
	FROM [DM].[FCT_O2O_WX_APPLYDATA]  snm
	LEFT JOIN [DM].[FCT_O2O_WX_APPLYLIST] al ON al.SP_NUM=snm.SP_NUM
	LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] qty ON qty.SP_NUM=snm.SP_NUM AND qty.ITEM_ID=snm.ITEM_ID+2 --自关联，取当前产品对应的库存数量
	LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] pd ON pd.SP_NUM=snm.SP_NUM AND pd.ITEM_ID=snm.ITEM_ID+1--自关联，取当前产品对应的生产日期
	LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] rs ON rs.SP_NUM=snm.SP_NUM AND rs.ITEM_ID=snm.ITEM_ID+3--自关联，取当前产品对应申请原因
	LEFT JOIN (SELECT sp_num,item_id,k,v,RIGHT(v,[dbo].[IndexOfChR](v)) AS [Period] FROM [DM].[FCT_O2O_WX_APPLYDATA] WHERE k = '库存期间' AND v LIKE '%期间%') pddt ON pddt.SP_NUM=snm.SP_NUM --自关联，当前sp_num 的库存期间
	WHERE snm.K= '产品名称'
	AND qty.K ='数量'
	AND rs.v in ('包装损坏','过期')
	AND al.sp_status  IN ('1','2')
	AND pddt.sp_num IS NOT NULL
	GROUP BY snm.sp_num
			,al.SPNAME
			,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date)
			,al.APPLY_NAME
			,al.APPLY_TIME
			,snm.V
			,pddt.[Period]
	-----------------------销售

	IF OBJECT_ID('TEMPDB..#Sales') IS NOT NULL
	BEGIN
	DROP TABLE #Sales
	END
	SELECT 
		   ob.order_no AS sp_num
		  ,'Order' AS SPNAME
		  ,eo.operator_name AS Apply_Name
		  ,CAST(ob.consign_time AS DATE) AS 'APPLY_Date'
		  ,pr.[Period]
		  ,od.SKU_ID AS SKU_ID
		  ,od.QTY*od.pcs_cnt AS Sales_Qty
		  ,ob.remark
	INTO #Sales
	FROM [dm].[Fct_O2O_Order_Detail_info] od
	LEFT JOIN [dm].[Fct_O2O_Order_Base_info] ob ON od.order_id = ob.order_id
	LEFT JOIN (SELECT DISTINCT [Operator_EmployeeID] operator_employee_id,[Operator_EmployeeName] operator_name FROM rpt.[O2O_Employee_Order]) eo ON ob.operator_employee_id = eo.operator_employee_id
	LEFT JOIN FU_EDW.Dim_Calendar cal ON CAST(ob.consign_time AS DATE) = cal.Date_NM
	LEFT JOIN #Period_Rank pr ON CAST(ob.consign_time AS DATE) BETWEEN pr.Begin_DT AND pr.End_DT
	WHERE ob.consign_time IS NOT NULL AND pr.[Period] IS NOT NULL

	SELECT 
	    sp_num
	   ,sp_Type
	   ,spname
	   ,APPLY_Date
	   ,Apply_Name
	   ,[Period]
	   ,SKU_ID
	   ,Remark
	   ,SUM(Begin_Inventory_Qty) AS Begin_Inventory_Qty
	   ,SUM(InStock_Qty) AS InStock_Qty
	   ,SUM(FOC_Qty) AS FOC_Qty
	   ,SUM(Expire_Qty) AS Expire_Qty
	   ,SUM(Sales_Qty) AS Sales_Qty
	   ,SUM(Begin_Inventory_Qty)+SUM(InStock_Qty)-SUM(FOC_Qty)-SUM(Expire_Qty)-SUM(Sales_Qty) AS Cal_Qty
	   ,SUM(End_Inventory_Qty) AS End_Inventory_Qty
	   ,SUM(Begin_Inventory_Qty)+SUM(InStock_Qty)-SUM(FOC_Qty)-SUM(Expire_Qty)-SUM(Sales_Qty)-SUM(End_Inventory_Qty) AS Gap_Qty
	FROM(
		--期末库存
		SELECT 
			sp_num
		   ,'End_Inventory' AS sp_Type
		   ,spname
		   ,APPLY_Date
		   ,Apply_Name
		   ,[period]
		   ,SKU_ID
		   ,0 AS Begin_Inventory_Qty
		   ,0 AS InStock_Qty
		   ,0 AS FOC_Qty
		   ,0 AS Expire_Qty
		   ,0 AS Sales_Qty
		   ,Inventory_Qty AS End_Inventory_Qty
		   ,'' AS Remark
		FROM #Inventory
		--期初库存
		UNION ALL
		SELECT 
			sp_num
		   ,'Begin_Inventory' AS sp_Type
		   ,spname
		   ,APPLY_Date
		   ,Apply_Name
		   ,pr2.[period]
		   ,SKU_ID
		   ,Inventory_Qty AS Begin_Inventory_Qty
		   ,0 AS InStock_Qty
		   ,0 AS FOC_Qty
		   ,0 AS Expire_Qty
		   ,0 AS Sales_Qty
		   ,0 AS End_Inventory_Qty
		   ,'' AS Remark
		FROM #Inventory inv
		LEFT JOIN #Period_Rank pr ON inv.[Period] = pr.[Period]
		LEFT JOIN #Period_Rank pr2 ON pr2.Period_Rank  = pr.Period_Rank+1
		--入库库存
		UNION ALL
		SELECT
			sp_num 
		   ,'Instock' AS sp_Type
		   ,spname
		   ,APPLY_Date
		   ,Apply_Name
		   ,[period]
		   ,SKU_ID
		   ,0 AS Begin_Inventory_Qty
		   ,Instock_Qty AS InStock_Qty
		   ,0 AS FOC_Qty
		   ,0 AS Expire_Qty
		   ,0 AS Sales_Qty
		   ,0 AS End_Inventory_Qty
		   ,'' AS Remark
		FROM #InStock
		--FOC
		UNION ALL
		SELECT 
			sp_num
		   ,'FOC' AS sp_Type
		   ,spname
		   ,APPLY_Date
		   ,Apply_Name
		   ,[Period]
		   ,SKU_ID
		   ,0 AS Begin_Inventory_Qty
		   ,0 AS InStock_Qty
		   ,FOC_Qty AS FOC_Qty
		   ,0 AS Expire_Qty
		   ,0 AS Sales_Qty
		   ,0 AS End_Inventory_Qty
		   ,'' AS Remark
		FROM #FOC
		--EXPIRE
		UNION ALL
		SELECT
			sp_num
		   ,'Expire' AS sp_Type
		   ,spname
		   ,APPLY_Date
		   ,Apply_Name
		   ,[Period]
		   ,SKU_ID
		   ,0 AS Begin_Inventory_Qty
		   ,0 AS InStock_Qty
		   ,0 AS FOC_Qty
		   ,Expire_Qty AS Expire_Qty
		   ,0 AS Sales_Qty
		   ,0 AS End_Inventory_Qty
		   ,'' AS Remark
		FROM #Expire
			sales
		UNION ALL
		SELECT
			sp_num
		   ,'Sales' AS sp_Type 
		   ,spname
		   ,APPLY_Date
		   ,Apply_Name
		   ,[Period] AS [Date]
		   ,SKU_ID
		   ,0 AS Begin_Inventory_Qty
		   ,0 AS InStock_Qty
		   ,0 AS FOC_Qty
		   ,0 AS Expire_Qty
		   ,Sales_Qty AS Sales_Qty
		   ,0 AS End_Inventory_Qty
		   ,remark
		FROM #Sales
	) base
	GROUP BY
		sp_num
		,sp_Type
		,spname
		,APPLY_Date
		,Apply_Name
		,[Period]
		,SKU_ID
		,Remark








   END
GO
