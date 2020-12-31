USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [rpt].[SP_Sales_YH门店商品库存OOS明细60天_Update]
AS
BEGIN

	----------------------------------OOS 关系表
    DROP TABLE IF EXISTS #Temp_OOS ;
	WITH OOS AS 
	(
		SELECT  '1171001' AS SKU_ID ,3.1 AS OOS_QTY  UNION ALL
		SELECT  '1171001_0' AS SKU_ID ,12.3 AS OOS_QTY  UNION ALL
		SELECT  '1171003' AS SKU_ID ,2.6 AS OOS_QTY  UNION ALL
		SELECT  '1172007' AS SKU_ID ,2.6 AS OOS_QTY  UNION ALL
		SELECT  '1172005_0' AS SKU_ID ,3.2 AS OOS_QTY  UNION ALL
		SELECT  '1172005' AS SKU_ID ,7.6 AS OOS_QTY  UNION ALL
		SELECT  '1172006' AS SKU_ID ,3.1 AS OOS_QTY  UNION ALL
		SELECT  '1172006_0' AS SKU_ID ,4.6 AS OOS_QTY  UNION ALL
		SELECT  '1172002' AS SKU_ID ,3.2 AS OOS_QTY  UNION ALL
		SELECT  '1172002_0' AS SKU_ID ,6.9 AS OOS_QTY  UNION ALL
		SELECT  '1172008' AS SKU_ID ,3.1 AS OOS_QTY  UNION ALL
		SELECT  '1120005' AS SKU_ID ,2.4 AS OOS_QTY  UNION ALL
		SELECT  '1170005' AS SKU_ID ,4 AS OOS_QTY  UNION ALL
		SELECT  '1170002' AS SKU_ID ,6.3 AS OOS_QTY  UNION ALL
		SELECT  '1170001' AS SKU_ID ,13.1 AS OOS_QTY  UNION ALL
		SELECT  '2100066' AS SKU_ID ,2.8 AS OOS_QTY  UNION ALL
		SELECT  '2100067' AS SKU_ID ,2.4 AS OOS_QTY  UNION ALL
		SELECT  '2100065' AS SKU_ID ,2.4 AS OOS_QTY  UNION ALL
		SELECT  '2100080' AS SKU_ID ,1.7 AS OOS_QTY  UNION ALL
		SELECT  '2100064' AS SKU_ID ,5.4 AS OOS_QTY  UNION ALL
		SELECT  '2100063' AS SKU_ID ,5.4 AS OOS_QTY  UNION ALL
		SELECT  '2100079' AS SKU_ID ,1.6 AS OOS_QTY  UNION ALL
		SELECT  '2100062' AS SKU_ID ,5 AS OOS_QTY  UNION ALL
		SELECT  '2100029' AS SKU_ID ,3.7 AS OOS_QTY  
  
	)
	SELECT * INTO #Temp_OOS FROM OOS
	;

	--SELECT COUNT(1) FROM rpt.Sales_YH门店商品库存明细60天;
	--TRUNCATE TABLE rpt.Sales_YH门店商品库存明细60天;

	--INSERT INTO [rpt].[Sales_YH门店商品库存明细60天]
	DROP TABLE IF EXISTS #lastday;
	SELECT dc.Datekey,dc.Date
		,a.* 
		,isnull(b.flag,'out of stock') as 'Flag',isnull(CAST(b.Inventory_Qty AS INT),0) AS Inventory_QTY,isnull(CAST(b.Sales_Qty AS INT),0) AS Sales_Qty
	INTO #lastday
	FROM(
		SELECT DISTINCT
		stm.Region,
		stm.Region_Director,
		ds.Store_Province,
		ds.Store_ID,
		ds.Account_Store_Code,
		ds.Store_Name,
		LEFT(ka.SKU_ID,7) SKU_ID,
		p.SKU_Name,
		p.SKU_Name_CN 
	FROM dm.Fct_KAStore_DailySalesInventory ka WITH(NOLOCK)
	JOIN dm.Dim_Store ds WITH(NOLOCK) on ka.Store_ID=ds.Store_ID
	JOIN dm.Dim_SalesTerritory_Mapping_Monthly stm WITH(NOLOCK) on ds.Province_Short=stm.Province_Short and stm.Monthkey=convert(varchar(6),dateadd(day,-2,getdate()),112)
	JOIN dm.Dim_Product p ON ka.SKU_ID=p.SKU_ID 
	WHERE ds.Channel_Account='YH'
	AND p.Status='Active'
	AND CHARINDEX('_0',ka.SKU_ID)=0
	AND ka.SKU_ID not in ('1172007','1172008','1171003','1120005')
	AND ka.Datekey>=20200101 --convert(varchar(8),dateadd(year,-1,getdate()),112)
	AND (ka.Sales_Qty+ka.Inventory_Qty)>0
	)a
	JOIN dm.Dim_Calendar dc ON Is_Past=1 and dc.Datekey>=convert(varchar(8),dateadd(day,-3,getdate()),112)
	LEFT JOIN	(
		SELECT 
			ka.Datekey,
			dc.Date,
			ds.Store_ID,
			ds.Account_Store_Code,
			left(ka.SKU_ID,7) SKU_ID,
			case when ka.Inventory_Qty> isnull(oos.OOS_QTY,10) then 'in stock' else 'out of stock' end as flag,
			ka.Sales_Qty,
			ka.Inventory_Qty
		FROM dm.Fct_KAStore_DailySalesInventory ka WITH(NOLOCK)
		JOIN dm.Dim_Calendar dc ON ka.Datekey=dc.Datekey
		JOIN dm.Dim_Store ds WITH(NOLOCK) on ka.Store_ID=ds.Store_ID
--------------------------获取OOS 数量
		LEFT JOIN #Temp_OOS oos on ka.SKU_ID = oos.SKU_ID

		WHERE ds.Channel_Account='YH'
		AND ka.Datekey >= convert(varchar(8),dateadd(day,-2,getdate()),112)
		--AND ka.Inventory_Qty >10
		AND CHARINDEX('_0',ka.SKU_ID)=0
		AND ka.SKU_ID not in ('1172007','1172008','1171003','1120005')
	)b ON a.Store_ID=b.Store_ID 
		AND a.SKU_ID=b.SKU_ID
		AND dc.Datekey=b.Datekey
		;

	DELETE t
	FROM [rpt].[Sales_YH门店商品库存OOS明细60天] t
	JOIN #lastday tmp ON t.Datekey=tmp.Datekey;

	INSERT INTO [rpt].[Sales_YH门店商品库存OOS明细60天]
	(
	   [Datekey]
      ,[Date]
      ,[Region]
      ,[Region_Director]
      ,[Store_Province]
      ,[Store_ID]
      ,[Account_Store_Code]
      ,[Store_Name]
      ,[SKU_ID]
      ,[SKU_Name]
      ,[SKU_Name_CN]
      ,[Flag]
      ,[Inventory_QTY]
      ,[Sales_Qty]
      ,[Update_Time]
      ,[Update_By]
	)
	SELECT *,GETDATE(),'[rpt].[SP_Sales_YH门店商品库存OOS明细60天_Update]' FROM #lastday;


END



GO
