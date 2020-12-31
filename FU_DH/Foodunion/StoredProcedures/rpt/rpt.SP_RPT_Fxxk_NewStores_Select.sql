USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [rpt].[SP_RPT_Fxxk_NewStores_Select]
AS
BEGIN

	--FXXK中缺失的门店，在ka数据中存在的门店
	SELECT 
		--CASE ds.Channel_Account WHEN 'Vanguard' THEN 'CRV' ELSE ds.Channel_Account END,
		isnull(kvc.keyname,'') AS Channel_Account,  --渠道
		--CASE ds.Channel_Account WHEN 'Vanguard' THEN '2' WHEN 'YH' THEN '1'  END AS Account,    --所属系统
		isnull(kva.keyname,'') AS Account,    --所属系统
		isnull(kvr.Keyname,'other') AS Sales_Region,
		ds.Account_Store_Code,
		ds.Store_Name,
		--ds.Store_Province,
		ds.Store_Province AS Province,
		isnull(kv.keyname,'') AS Store_Province,
		ds.Store_City AS City,
		ds.Store_Address,
		ds.Store_Type AS Store_Type,
		ds.Status
	FROM dm.Dim_Store ds WITH(NOLOCK)    --门店主数据
	LEFT JOIN dm.Dim_Store_Fxxk fxxk  WITH(NOLOCK) --纷享销客门店
	  ON ds.Account_Store_Code = fxxk.Store_Code
	  --AND CASE ds.Channel_Account WHEN 'Vanguard' THEN '华润万家' WHEN 'YH' THEN '永辉' ELSE ds.Channel_Account END = fxxk.Channel
	JOIN (SELECT DISTINCT Store_ID FROM dm.Fct_KAStore_DailySalesInventory  WITH(NOLOCK))s ON ds.Store_ID=s.Store_ID  --有销售记录
	LEFT JOIN [ref].[Fxxk_Object_KVmap] kv ON ds.Store_Province = kv.keyvalue AND kv.ObjectName='省区'	
	LEFT JOIN [ref].[Fxxk_Object_KVmap] kvr ON ds.Sales_Region = kvr.keyvalue AND kvr.ObjectName='区域'
	LEFT JOIN [ref].[Fxxk_Object_KVmap] kvc ON (CASE ds.Channel_Account WHEN 'Vanguard' THEN 'CRV' WHEN 'YH' THEN 'YH' ELSE ds.Channel_Account END) = kvc.keyvalue AND kvc.ObjectName='渠道'
	LEFT JOIN [ref].[Fxxk_Object_KVmap] kva ON (CASE ds.Channel_Account WHEN 'Vanguard' THEN '华润万家' 
		WHEN 'YH' THEN '永辉'
		WHEN 'Huaguan' THEN '北京华冠'
		WHEN 'CenturyMart' THEN '世纪联华'
		WHEN 'RTMart' THEN '大润发'
		WHEN 'KW' THEN '孩子王' ELSE ds.Channel_Account END) = kva.keyvalue AND kva.ObjectName='门店所属系统'
	WHERE ds.Channel_Account IN ('Vanguard','YH')
	AND fxxk.Store_Code is null
	AND ISNULL(ds.Status,'')<>'营运仓'
	AND ds.Store_Name NOT LIKE '%配送中心%' AND ds.Store_Name NOT LIKE '%仓'
	--AND ds.Account_Store_Code='95D3'
	AND (ds.Store_Province IS NOT NULL AND ISNULL(ds.Store_Name,'')<>'')
	;


END
GO
