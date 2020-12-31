USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE PROC [rpt].[SP_RPT_O2O_Inventory_Detail]
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
UNION ALL
SELECT '7/27-7/31','2019-07-27','2019-07-31',0,'7月期间7/27-7/31'

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
--		SELECT * FROM #Inv_TEMP
	--UNION ALL SELECT CAST(sp_num AS VARCHAR),sp_year,spname,apply_Date,Period,Apply_name,SKU_ID,CAST(SKU_Name AS NVARCHAR),Inventory_Qty FROM ods.ods.File_Youzan_Order_MonthlyRecon_201907_TEMP WHERE spname = 'O2O-周产品盘点'




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
		,SUM(CAST(CASE WHEN qty.V LIKE '%赠%' THEN 0 ELSE qty.V END AS FLOAT)) AS Instock_Qty
	INTO #InStock
	FROM [DM].[FCT_O2O_WX_APPLYDATA]  snm
	INNER JOIN [DM].[FCT_O2O_WX_APPLYLIST] al ON al.SP_NUM=snm.SP_NUM
	INNER JOIN [DM].[FCT_O2O_WX_APPLYDATA] qty ON qty.SP_NUM=snm.SP_NUM AND qty.k LIKE '%数量%' AND qty.ITEM_ID-snm.ITEM_ID<=2 AND qty.ITEM_ID>snm.ITEM_ID -- qty.ITEM_ID=snm.ITEM_ID+1 --自关联，取当前产品对应的库存数量
	LEFT JOIN (SELECT sp_num,item_id,k,v,RIGHT(v,[dbo].[IndexOfChR](v)) AS [Period] FROM [DM].[FCT_O2O_WX_APPLYDATA] WHERE k = '补货时间' AND v LIKE '%期间%') pddt ON pddt.SP_NUM=snm.SP_NUM --自关联，当前sp_num 的补货日期
	WHERE snm.K= '产品名称'
	AND al.spname in ('o2o-产品补货申请')
	--AND qty.K ='数量（单位：盒）'
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
--UNION ALL SELECT CAST(sp_num AS VARCHAR),spname,apply_Date,Period,Apply_name,SKU_ID,CAST(SKU_Name AS NVARCHAR),Inventory_Qty FROM ods.ods.File_Youzan_Order_MonthlyRecon_201907_TEMP WHERE spname = 'O2O-产品补货'



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
	AND al.spname = 'O2O-库存产品报废'
--	AND rs.v in ('包装损坏','过期')
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
	--SELECT 
	--	   ob.order_no AS sp_num
	--	  ,'Order' AS SPNAME
	--	  ,eo.operator_name AS Apply_Name
	--	  ,CAST(ob.consign_time AS DATE) AS 'APPLY_Date'
	--	  ,pr.[Period]
	--	  ,od.SKU_ID AS SKU_ID
	--	  ,od.Product_Name AS SKU_Name
	--	  ,od.QTY*od.pcs_cnt AS Sales_Qty
	--	  ,ob.remark
	--INTO #Sales
	--FROM [dm].[Fct_O2O_Order_Detail_info] od
	--LEFT JOIN [dm].[Fct_O2O_Order_Base_info] ob ON od.order_id = ob.order_id
	--LEFT JOIN FU_EDW.Dim_Calendar cal ON CAST(ob.consign_time AS DATE) = cal.Date_NM
	--LEFT JOIN #Period_Rank pr ON CAST(ob.consign_time AS DATE) BETWEEN pr.Begin_DT AND pr.End_DT

------------------------通过有赞入账获得销售数据
SELECT 
	yr.Order_No AS sp_num
   ,'Order' AS SPNAME
   ,eo.operator_name AS Apply_Name
   ,eof.Fenxiao_EmployeeName AS Fenxiao_Name
   ,CAST(yr.Recon_Date AS DATE) AS 'APPLY_Date'
   ,pr.[Period]
   ,di.SKU_ID AS SKU_ID
   ,di.Product_Name AS SKU_Name
   ,di.QTY*di.pcs_cnt AS Sales_Qty
   ,bi.remark
	INTO #Sales
FROM [dm].[Fct_Youzan_Recon] yr
LEFT JOIN [dm].[Fct_O2O_Order_Base_info] bi ON yr.Order_No = bi.Order_No
LEFT JOIN [dm].[Fct_O2O_Order_Detail_info] di ON bi.Order_ID  = di.Order_ID
LEFT JOIN (SELECT DISTINCT [Operator_EmployeeID] operator_employee_id,[Operator_EmployeeName] operator_name FROM rpt.[O2O_Employee_Order]) eo ON bi.operator_employee_id = eo.operator_employee_id
LEFT JOIN (SELECT DISTINCT Fenxiao_EmployeeID ,Fenxiao_EmployeeName  FROM rpt.[O2O_Employee_Order]) eof ON bi.Fenxiao_Employee_id = eof.Fenxiao_EmployeeID
LEFT JOIN #Period_Rank pr ON CAST(yr.Recon_Date AS DATE) BETWEEN pr.Begin_DT AND pr.End_DT



















-------------------------------------------------------------------------------手动插入的8A期初库存

DROP TABLE IF EXISTS #SKU_Name
SELECT DISTINCT SKU_ID,SKU_Name_CN INTO #SKU_Name FROM [dm].[Fct_O2O_Order_Detail_info]


	SELECT 
	    sp_num
	   ,sp_Type
	   ,spname
	   ,APPLY_Date
	   ,Apply_Name
	   ,Fenxiao_Name
	   ,base.[Period]
	   ,pr3.[Date]
	   ,base.SKU_ID
	   ,ISNULL(sn.SKU_Name_CN,base.SKU_NAME) AS SKU_NAME
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
		   ,Apply_Name AS Fenxiao_Name
		   ,[period]
		   ,SKU_ID
		   ,SKU_NAME
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
		   ,Apply_Name AS Fenxiao_Name
		   ,pr2.[period]
		   ,SKU_ID
		   ,SKU_NAME
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
		   ,Apply_Name AS Fenxiao_Name
		   ,[period]
		   ,SKU_ID
		   ,SKU_NAME
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
		   ,Apply_Name AS Fenxiao_Name
		   ,[Period]
		   ,SKU_ID
		   ,SKU_NAME
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
		   ,Apply_Name AS Fenxiao_Name
		   ,[Period]
		   ,SKU_ID
		   ,SKU_NAME
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
		   ,Fenxiao_Name AS Fenxiao_Name
		   ,[Period] AS [Date]
		   ,SKU_ID
		   ,SKU_NAME
		   ,0 AS Begin_Inventory_Qty
		   ,0 AS InStock_Qty
		   ,0 AS FOC_Qty
		   ,0 AS Expire_Qty
		   ,Sales_Qty AS Sales_Qty
		   ,0 AS End_Inventory_Qty
		   ,remark
		FROM #Sales
	) base
	LEFT JOIN #Period_Rank pr3 ON base.period = pr3.Period
	LEFT JOIN dm.Dim_Product prod ON base.SKU_ID = prod.SKU_ID
	LEFT JOIN #SKU_Name sn ON base.SKU_ID = sn.SKU_ID
	GROUP BY
		sp_num
		,sp_Type
		,spname
		,APPLY_Date
		,Apply_Name
		,Fenxiao_Name
		,base.[Period]
		,pr3.Date
		,base.SKU_ID
		,ISNULL(sn.SKU_Name_CN,base.SKU_NAME)
		,Remark






	--IF OBJECT_ID('TEMPDB..#Inventory') IS NOT NULL
	--BEGIN
	--DROP TABLE #Inventory
	--END

	--SELECT  
	--	 snm.SP_NUM
	--	,al.SPNAME
	----	,DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') AS 'APPLY_TIME'
	--	,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date) AS 'APPLY_Date'
	--	,al.APPLY_NAME AS APPLY_NAME
	----	,CAST(DATEADD(S,cast(pddt.v as bigint)/1000 + 8 * 3600,'1970-01-01') as date) AS 'Inventory_DT'
	--	,CAST(LEFT(cal.Week_Date_Period,10) AS DATE) AS Inventory_DT			--取盘点日期那周一作为库存日期
	--	,CASE WHEN snm.v LIKE '%|%' THEN SUBSTRING(snm.v,CHARINDEX('|',snm.v)+1,7) ELSE REPLACE(LEFT(snm.v,CHARINDEX(' ',snm.v)),' ','') END AS SKU_ID
	--	,snm.V SKU_NAME
	----	,CAST(CASE WHEN RIGHT(pddt.v,5)='00000' THEN DATEADD(S,cast(pddt.v as bigint)/1000 + 8 * 3600,'1970-01-01')  ELSE pddt.v END as date) AS 'PRODUCE_DATE'
	--	,SUM(CAST(qty.V AS FLOAT)) AS Inventory_Qty
	--	,cal.Week_Year_NBR
	----	,al.sp_status
	----直接求和	,ROW_NUMBER() OVER(PARTITION BY cal.[Year],cal.Week_Year_NBR,al.Apply_Name,snm.v,pd.V ORDER BY snm.SP_NUM DESC) rn
	--INTO #Inventory
	--FROM [DM].[FCT_O2O_WX_APPLYDATA]  snm
	--INNER JOIN [DM].[FCT_O2O_WX_APPLYLIST] al ON al.SP_NUM=snm.SP_NUM
	--LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] qty ON qty.SP_NUM=snm.SP_NUM AND qty.ITEM_ID=snm.ITEM_ID+2 --自关联，取当前产品对应的库存数量
	--LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] pd ON pd.SP_NUM=snm.SP_NUM AND pd.ITEM_ID=snm.ITEM_ID+1--自关联，取当前产品对应的生产日期
	--LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] pddt ON pddt.SP_NUM=snm.SP_NUM AND pddt.k='盘点日期'--自关联，当前sp_num 的盘点日期
	--LEFT JOIN FU_EDW.Dim_Calendar AS cal ON CAST(CASE WHEN RIGHT(pddt.v,5)='00000' THEN DATEADD(S,cast(pddt.v as bigint)/1000 + 8 * 3600,'1970-01-01')  ELSE pddt.v END as date) = cal.Date_NM
	--WHERE snm.K= '产品名称'
	--AND al.SPNAME='O2O-周产品盘点'
	--AND qty.K ='产品数量（盒）'
	--AND pd.K='生产日期'
	--AND al.sp_status  IN ('1','2')
	--AND ISDATE(pddt.v) = 1
	--GROUP BY snm.sp_num
	--		,al.APPLY_NAME
	--		,al.SPNAME
	--		,al.APPLY_TIME
	--		,LEFT(cal.Week_Date_Period,10) 
	--		,snm.V
	----		,CAST(CASE WHEN RIGHT(pddt.v,5)='00000' THEN DATEADD(S,cast(pddt.v as bigint)/1000 + 8 * 3600,'1970-01-01')  ELSE pddt.v END as date)
	--		,cal.Week_Year_NBR
	--	--	,al.sp_status

	------------------------入库		
	--IF OBJECT_ID('TEMPDB..#InStock') IS NOT NULL
	--BEGIN
	--DROP TABLE #InStock
	--END

	--SELECT  
	--	 snm.SP_NUM
	--	,al.SPNAME
	----	,DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') AS 'APPLY_TIME'
	--	,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date) AS 'APPLY_Date'
	--	,CAST(LEFT(cal.Week_Date_Period,10) AS DATE) AS Instock_DT			--取入库日期那周一作为入库日期
	--	,al.APPLY_NAME AS APPLY_NAME
	--	,CASE WHEN snm.v LIKE '%|%' THEN SUBSTRING(snm.v,CHARINDEX('|',snm.v)+1,7) ELSE REPLACE(LEFT(snm.v,CHARINDEX(' ',snm.v)),' ','') END AS SKU_ID
	--	,snm.V SKU_NAME
	--	,SUM(CAST(qty.V AS FLOAT)) AS Instock_Qty
	--	,cal.Week_Year_NBR
	--	,cal.Week_Day
	----	,al.sp_status
	--INTO #InStock
	--FROM [DM].[FCT_O2O_WX_APPLYDATA]  snm
	--INNER JOIN [DM].[FCT_O2O_WX_APPLYLIST] al ON al.SP_NUM=snm.SP_NUM
	--INNER JOIN [DM].[FCT_O2O_WX_APPLYDATA] qty ON qty.SP_NUM=snm.SP_NUM AND qty.ITEM_ID=snm.ITEM_ID+1 --自关联，取当前产品对应的库存数量
	--LEFT JOIN FU_EDW.Dim_Calendar AS cal ON CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') AS DATE) = DATEADD(DAY,-4,cal.Date_NM) --把时间往后推4天，得到的补货数量作为本周的补货数量
	--WHERE snm.K= '产品名称'
	--AND al.spname in ('o2o-产品补货申请')
	--AND qty.K ='数量（单位：盒）'
	--AND al.sp_status  IN ('1','2')
	--AND cal.Week_Day IN (1,2,3,4,5)		--原来是4,5,6,7,1
	--GROUP BY  snm.sp_num
	--		,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date)
	--		,al.APPLY_NAME
	--		,al.SPNAME
	--		,al.APPLY_TIME
	--		,snm.V
	--		,cal.Week_Year_NBR
	--		,cal.Week_Day
	--	--	,al.sp_status
	--		,cal.Week_Date_Period

	-----------------------FOC
	--IF OBJECT_ID('TEMPDB..#FOC') IS NOT NULL
	--BEGIN
	--DROP TABLE #FOC
	--END
	--SELECT  
	--	 snm.SP_NUM
	--	,al.SPNAME
	----	,DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') AS 'APPLY_TIME'
	--	,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date) AS 'APPLY_Date'
	--	,CAST(LEFT(cal.Week_Date_Period,10) AS DATE) AS FOC_DT			--取FOC那周一作为FOC日期
	--	,al.APPLY_NAME AS APPLY_NAME
	--	,CASE WHEN snm.v LIKE '%|%' THEN SUBSTRING(snm.v,CHARINDEX('|',snm.v)+1,7) ELSE REPLACE(LEFT(snm.v,CHARINDEX(' ',snm.v)),' ','') END AS SKU_ID
	--	,snm.V SKU_NAME
	--	,qty.v
	--	,SUM(CAST(qty.V AS FLOAT)) AS FOC_Qty
	--	,cal.Week_Year_NBR
	----	,al.sp_status
	----直接求和	,ROW_NUMBER() OVER(PARTITION BY cal.[Year],cal.Week_Year_NBR,al.Apply_Name,snm.v,pd.V ORDER BY snm.SP_NUM DESC) rn
	--INTO #FOC
	--FROM [DM].[FCT_O2O_WX_APPLYDATA]  snm 
	--INNER JOIN [DM].[FCT_O2O_WX_APPLYLIST] al ON al.SP_NUM=snm.SP_NUM
	--INNER JOIN [DM].[FCT_O2O_WX_APPLYDATA] qty ON qty.SP_NUM=snm.SP_NUM AND qty.ITEM_ID=snm.ITEM_ID+2 --自关联，取当前产品对应的库存数量
	--INNER JOIN [DM].[FCT_O2O_WX_APPLYDATA] pd ON pd.SP_NUM=snm.SP_NUM AND pd.ITEM_ID=snm.ITEM_ID+1--自关联，取当前产品对应的生产日期
	--INNER JOIN [DM].[FCT_O2O_WX_APPLYDATA] rs ON rs.SP_NUM=snm.SP_NUM AND rs.ITEM_ID=snm.ITEM_ID+3--自关联，取当前产品对应申请原因
	--INNER JOIN [DM].[FCT_O2O_WX_APPLYDATA] dt ON dt.SP_NUM=snm.SP_NUM AND dt.k='活动日期'--自关联，取当前产品poc的活动日期
	--LEFT JOIN FU_EDW.Dim_Calendar AS cal ON CAST(DATEADD(S,cast(dt.v as bigint)/1000 + 8 * 3600,'1970-01-01') as date) = cal.Date_NM
	--WHERE snm.K= '产品名称'
	--AND qty.K ='数量'
	--AND rs.v in ('试吃活动','随单赠送','环保袋换')
	--AND al.sp_status  IN ('1','2')
	--GROUP BY snm.sp_num
	--		 ,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date)
	--		,al.APPLY_NAME
	--		,al.APPLY_TIME
	--		,al.SPNAME
	--		,snm.V
	--		,cal.Week_Year_NBR
	--	--	,al.sp_status
	--		,dt.v
	--		,cal.Week_Date_Period
	--		,qty.v
	--		order by qty.v

	-----------------------报废
	--IF OBJECT_ID('TEMPDB..#Expire') IS NOT NULL
	--BEGIN
	--DROP TABLE #Expire
	--END
	--SELECT  
	--	 snm.SP_NUM
	--	,al.SPNAME
	----	,DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') AS 'APPLY_TIME'
	--	,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date) AS 'APPLY_Date'
	--	,CAST(LEFT(cal.Week_Date_Period,10) AS DATE) AS Expire_DT			--取FOC那周一作为FOC日期
	--	,al.APPLY_NAME AS APPLY_NAME
	--	,CASE WHEN snm.v LIKE '%|%' THEN SUBSTRING(snm.v,CHARINDEX('|',snm.v)+1,7) ELSE REPLACE(LEFT(snm.v,CHARINDEX(' ',snm.v)),' ','') END AS SKU_ID
	--	,snm.V SKU_NAME
	--	,SUM(CAST(qty.V AS FLOAT)) AS Expire_Qty
	--	,cal.Week_Year_NBR
	----	,al.sp_status
	----直接求和	,ROW_NUMBER() OVER(PARTITION BY cal.[Year],cal.Week_Year_NBR,al.Apply_Name,snm.v,pd.V ORDER BY snm.SP_NUM DESC) rn
	--	INTO #Expire
	--FROM [DM].[FCT_O2O_WX_APPLYDATA]  snm
	--LEFT JOIN [DM].[FCT_O2O_WX_APPLYLIST] al ON al.SP_NUM=snm.SP_NUM
	--LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] qty ON qty.SP_NUM=snm.SP_NUM AND qty.ITEM_ID=snm.ITEM_ID+2 --自关联，取当前产品对应的库存数量
	--LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] pd ON pd.SP_NUM=snm.SP_NUM AND pd.ITEM_ID=snm.ITEM_ID+1--自关联，取当前产品对应的生产日期
	--LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] rs ON rs.SP_NUM=snm.SP_NUM AND rs.ITEM_ID=snm.ITEM_ID+3--自关联，取当前产品对应申请原因
	--LEFT JOIN [DM].[FCT_O2O_WX_APPLYDATA] dt ON dt.SP_NUM=snm.SP_NUM AND dt.ITEM_ID = 5--自关联，取当前产品poc的活动日期
	--LEFT JOIN FU_EDW.Dim_Calendar AS cal ON CAST(DATEADD(S,cast(dt.v as bigint)/1000 + 8 * 3600,'1970-01-01') as date) = cal.Date_NM
	--WHERE snm.K= '产品名称'
	--AND qty.K ='数量'
	--AND rs.v in ('包装损坏','过期')
	--AND al.sp_status  IN ('1','2')
	--AND dt.k IN ('报废日期','活动日期')
	--GROUP BY snm.sp_num
	--		,al.SPNAME
	--		,CAST(DATEADD(S,cast(al.APPLY_TIME as bigint) + 8 * 3600,'1970-01-01') as date)
	--		,al.APPLY_NAME
	--		,al.APPLY_TIME
	--		,snm.V
	--		,cal.Week_Year_NBR
	--	--	,al.sp_status
	--		,dt.v
	--		,cal.Week_Date_Period
	-------------------------销售

	--IF OBJECT_ID('TEMPDB..#Sales') IS NOT NULL
	--BEGIN
	--DROP TABLE #Sales
	--END
	--SELECT 
	--	   ob.order_no AS sp_num
	--	  ,'Order' AS SPNAME
	--	  ,eo.operator_name AS Apply_Name
	--	  ,CAST(ob.consign_time AS DATE) AS 'APPLY_Date'
	--	  ,CAST(LEFT(cal.Week_Date_Period,10) AS DATE) AS Sales_DT			--取FOC那周一作为销售日期AS [Date]
	--	  ,od.SKU_ID AS SKU_ID
	--	  ,od.QTY*od.pcs_cnt AS Sales_Qty
	--	  ,ob.remark
	--INTO #Sales
	--FROM [dm].[Fct_O2O_Order_Detail_info] od
	--LEFT JOIN [dm].[Fct_O2O_Order_Base_info] ob ON od.order_id = ob.order_id
	--LEFT JOIN (SELECT DISTINCT [Operator_EmployeeID] operator_employee_id,[Operator_EmployeeName] operator_name FROM rpt.[O2O_Employee_Order]) eo ON ob.operator_employee_id = eo.operator_employee_id
	--LEFT JOIN FU_EDW.Dim_Calendar cal ON CAST(ob.consign_time AS DATE) = cal.Date_NM
	--WHERE ob.consign_time IS NOT NULL


	--SELECT 
	--	sp_num
	--	,sp_Type
	--	,spname
	--	,APPLY_Date
	--   ,Apply_Name
	--   ,[Date]
	--   ,SKU_ID
	--   ,Remark
	--   ,SUM(Begin_Inventory_Qty) AS Begin_Inventory_Qty
	--   ,SUM(InStock_Qty) AS InStock_Qty
	--   ,SUM(FOC_Qty) AS FOC_Qty
	--   ,SUM(Expire_Qty) AS Expire_Qty
	--   ,SUM(Sales_Qty) AS Sales_Qty
	--   ,SUM(Begin_Inventory_Qty)+SUM(InStock_Qty)-SUM(FOC_Qty)-SUM(Expire_Qty)-SUM(Sales_Qty) AS Cal_Qty
	--   ,SUM(End_Inventory_Qty) AS End_Inventory_Qty
	--   ,SUM(Begin_Inventory_Qty)+SUM(InStock_Qty)-SUM(FOC_Qty)-SUM(Expire_Qty)-SUM(Sales_Qty)-SUM(End_Inventory_Qty) AS Gap_Qty
	--FROM(
	--	--期末库存
	--	SELECT 
	--		sp_num
	--	   ,'End_Inventory' AS sp_Type
	--	   ,spname
	--	   ,APPLY_Date
	--	   ,Apply_Name
	--	   ,Inventory_DT AS [Date]
	--	   ,SKU_ID
	--	   ,0 AS Begin_Inventory_Qty
	--	   ,0 AS InStock_Qty
	--	   ,0 AS FOC_Qty
	--	   ,0 AS Expire_Qty
	--	   ,0 AS Sales_Qty
	--	   ,Inventory_Qty AS End_Inventory_Qty
	--	   ,'' AS Remark
	--	FROM #Inventory
	--	--期初库存
	--	UNION ALL
	--	SELECT 
	--		sp_num
	--	   ,'Begin_Inventory' AS sp_Type
	--	   ,spname
	--	   ,APPLY_Date
	--	   ,Apply_Name
	--	   ,DATEADD(DAY,7,Inventory_DT) AS [Date]
	--	   ,SKU_ID
	--	   ,Inventory_Qty AS Begin_Inventory_Qty
	--	   ,0 AS InStock_Qty
	--	   ,0 AS FOC_Qty
	--	   ,0 AS Expire_Qty
	--	   ,0 AS Sales_Qty
	--	   ,0 AS End_Inventory_Qty
	--	   ,'' AS Remark
	--	FROM #Inventory
	--	--入库库存
	--	UNION ALL
	--	SELECT
	--		sp_num 
	--	   ,'Instock' AS sp_Type
	--	   ,spname
	--	   ,APPLY_Date
	--	   ,Apply_Name
	--	   ,Instock_DT AS [Date]
	--	   ,SKU_ID
	--	   ,0 AS Begin_Inventory_Qty
	--	   ,Instock_Qty AS InStock_Qty
	--	   ,0 AS FOC_Qty
	--	   ,0 AS Expire_Qty
	--	   ,0 AS Sales_Qty
	--	   ,0 AS End_Inventory_Qty
	--	   ,'' AS Remark
	--	FROM #InStock
	--	--FOC
	--	UNION ALL
	--	SELECT 
	--		sp_num
	--	   ,'FOC' AS sp_Type
	--	   ,spname
	--	   ,APPLY_Date
	--	   ,Apply_Name
	--	   ,FOC_DT AS [Date]
	--	   ,SKU_ID
	--	   ,0 AS Begin_Inventory_Qty
	--	   ,0 AS InStock_Qty
	--	   ,FOC_Qty AS FOC_Qty
	--	   ,0 AS Expire_Qty
	--	   ,0 AS Sales_Qty
	--	   ,0 AS End_Inventory_Qty
	--	   ,'' AS Remark
	--	FROM #FOC
	--	--EXPIRE
	--	UNION ALL
	--	SELECT
	--		sp_num
	--	   ,'Expire' AS sp_Type
	--	   ,spname
	--	   ,APPLY_Date
	--	   ,Apply_Name
	--	   ,Expire_DT AS [Date]
	--	   ,SKU_ID
	--	   ,0 AS Begin_Inventory_Qty
	--	   ,0 AS InStock_Qty
	--	   ,0 AS FOC_Qty
	--	   ,Expire_Qty AS Expire_Qty
	--	   ,0 AS Sales_Qty
	--	   ,0 AS End_Inventory_Qty
	--	   ,'' AS Remark
	--	FROM #Expire
	--		sales
	--	UNION ALL
	--	SELECT
	--		sp_num
	--	   ,'Sales' AS sp_Type 
	--	   ,spname
	--	   ,APPLY_Date
	--	   ,Apply_Name
	--	   ,Sales_DT AS [Date]
	--	   ,SKU_ID
	--	   ,0 AS Begin_Inventory_Qty
	--	   ,0 AS InStock_Qty
	--	   ,0 AS FOC_Qty
	--	   ,0 AS Expire_Qty
	--	   ,Sales_Qty AS Sales_Qty
	--	   ,0 AS End_Inventory_Qty
	--	   ,remark
	--	FROM #Sales
	--) base
	--GROUP BY
	--	sp_num
	--	,sp_Type
	--	,spname
	--	,APPLY_Date
	--	,Apply_Name
	--	,[Date]
	--	,SKU_ID
	--	,Remark








   END
GO
