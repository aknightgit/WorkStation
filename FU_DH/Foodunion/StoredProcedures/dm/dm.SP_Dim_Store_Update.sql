USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dm].[SP_Dim_Store_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY
	--DECLARE @pName VARCHAR(100) ='[dm].[SP_Dim_Store_Update]'

	---------------------------------------------------------
	--  PG BM assignment, update from Sample '门店分配以及四月指标4.2.xlsx'
	---------------------------------------------------------
	IF EXISTS (SELECT top 1 1 FROM ODS.[ods].[File_YHStore_BMTarget] WHERE Load_DTM >= GETDATE()-1)
	BEGIN
		
		UPDATE ds
		--SELECT 
		SET	ds.PG_Store_FL=0,
			ds.SR_Level_1='',
		--	ds.Target_Store_FL=0,
			ds.Update_Time=getdate(),
			ds.Update_By=@ProcName
		FROM [dm].[Dim_Store] ds ;

		UPDATE ds
		--SELECT
		SET
			ds.PG_Store_FL = bmt.PG_Store_FLag,
			ds.SR_Level_1 = bmt.Business_Manager,
			--ds.Target_Store_FL = 1,
			ds.Update_Time = getdate(),
			ds.Update_By = @ProcName
		FROM [dm].[Dim_Store] ds 
		JOIN ODS.[ods].[File_YHStore_BMTarget] bmt
		ON ds.Account_Store_Code = bmt.Account_Store_Code
		WHERE bmt.MonthKey = convert(varchar(6),getdate(),112);
		--where ds.PG_Store_FL=1 and isnull(bmt.PG_Store_Flag,0)=0
	END

	---------------------------------------------------------
	--  Insert Store From KA daily Sales
	---------------------------------------------------------
	--INFER From YH Sales
	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_ID,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By
	,[Store_City],[Store_City_EN],[Store_Address],[Account_Store_Group],[Store_Province],[Store_Province_EN],[Account_Store_Type],[Account_Store_Type_EN],lng,lat)
	SELECT DISTINCT '','Offline',5,'YH','YH',ods.shop_id,ods.shop_name,CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from ods.EDI_YH_Sales'
		,GETDATE(),''
		,oods.[Store_City],oods.[Store_City_EN],oods.[Store_Address],oods.[Account_Store_Group]
		,oods.[Store_Province],oods.[Store_Province_EN],oods.[Account_Store_Type],oods.[Account_Store_Type_EN],oods.lng,oods.lat
	FROM ods.ods.EDI_YH_Sales ods
	LEFT JOIN ods.[ods].[Dim_Store] oods ON oods.Channel_Account='YH' AND ods.shop_id=oods.Account_Store_Code
	LEFT JOIN [dm].[Dim_Store] ds ON ods.shop_id = ds.Account_Store_Code AND ds.Channel_Account='YH'
	WHERE ds.Account_Store_Code IS NULL;

	--INFER From YH EDI_YH_Inventory
	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_ID,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By
	,[Store_City],[Store_City_EN],[Store_Address],[Account_Store_Group],[Store_Province],[Store_Province_EN],[Account_Store_Type],[Account_Store_Type_EN],lng,lat)
	SELECT DISTINCT '','Offline',5,'YH','YH',ods.shop_id,'',CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from ods.EDI_YH_Inventory'
		,GETDATE(),''
		,oods.[Store_City],oods.[Store_City_EN],oods.[Store_Address],oods.[Account_Store_Group]
		,oods.[Store_Province],oods.[Store_Province_EN],oods.[Account_Store_Type],oods.[Account_Store_Type_EN],oods.lng,oods.lat
	FROM ods.ods.EDI_YH_Inventory ods
	LEFT JOIN ods.[ods].[Dim_Store] oods ON oods.Channel_Account='YH' AND ods.shop_id=oods.Account_Store_Code
	LEFT JOIN [dm].[Dim_Store] ds ON ods.shop_id = ds.Account_Store_Code AND ds.Channel_Account='YH'
	WHERE ds.Account_Store_Code IS NULL;

	--INFER From YH JXT
	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_ID,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By
	,[Store_City],[Store_City_EN],[Store_Address],[Account_Store_Group],[Store_Province],[Store_Province_EN],[Account_Store_Type],[Account_Store_Type_EN],lng,lat)
	SELECT DISTINCT '','Offline',5,'YH','YH',ods.Store_Code,'',CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from ods.File_YH_DailySales'
		,GETDATE(),''
		,oods.[Store_City],oods.[Store_City_EN],oods.[Store_Address],oods.[Account_Store_Group]
		,oods.[Store_Province],oods.[Store_Province_EN],oods.[Account_Store_Type],oods.[Account_Store_Type_EN],oods.lng,oods.lat
	FROM ods.ODS.File_YH_DailySales ods
	LEFT JOIN ods.[ods].[Dim_Store] oods ON oods.Channel_Account='YH' AND ods.Store_Code=oods.Account_Store_Code
	LEFT JOIN [dm].[Dim_Store] ds ON ods.Store_Code = ds.Account_Store_Code AND ds.Channel_Account='YH'
	WHERE ds.Account_Store_Code IS NULL;

	--INFER From Vanguard Sales
	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Account_Area_CN,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline','Vanguard','VG'
		,ods.shopid,ods.shopname,ods.buname
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from ods.File_CRV_DailySales'
		,GETDATE(),''
	FROM ods.ods.File_CRV_DailySales ods
	LEFT JOIN [dm].[Dim_Store] ds ON ods.shopid = ds.Account_Store_Code AND ds.Channel_Account='Vanguard'
	WHERE ds.Account_Store_Code IS NULL
	AND CAST(ods.grosssalevalue AS DECIMAL(18,5))>0;

	--INFER From Vanguard Inventory
	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Account_Area_CN,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline','Vanguard','VG'
		,ods.shopid,ods.shopname
		,CASE ods.buname WHEN '07苏果' THEN '07苏果' WHEN '华东' THEN '06华东' WHEN '华北' THEN '02华北' WHEN '西北' THEN '03西北' END
		--ods.buname
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from ods.[File_CRV_DailyInventory]'
		,GETDATE(),''
	FROM ods.ods.[File_CRV_DailyInventory] ods
	LEFT JOIN [dm].[Dim_Store] ds ON ods.shopid = ds.Account_Store_Code AND ds.Channel_Account='Vanguard'
	WHERE ds.Account_Store_Code IS NULL
	AND qty>0;

	--INFER From KW Sales
	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_ID,Channel_Account,Account_Store_Code,Store_Name,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline',16,'KW'
		,ods.Store_Code,ods.Store_Name
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from ods.File_Kidswant_DailySales'
		,GETDATE(),''
	FROM ods.ods.File_Kidswant_DailySales ods
	LEFT JOIN [dm].[Dim_Store] ds ON ods.Store_Code = ds.Account_Store_Code AND ds.Channel_Account='KW'
	WHERE ds.Account_Store_Code IS NULL
	AND CAST(ods.Sales_AMT AS DECIMAL(18,5))>0;

	--INFER From SG Sales
	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_ID,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Account_Area_CN,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline',55,'Vanguard','VG'
		,CAST(TRIM(ods.Store_Code) AS INT) AS Account_Store_Code,ods.Store_Name AS Store_Name,'07苏果' AS buname
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from ods.File_SG_DailySales'
		,GETDATE(),''
	FROM ods.ods.File_SG_DailySales ods
	LEFT JOIN [dm].[Dim_Store] ds ON ds.Account_Store_Code=CAST(TRIM(ods.Store_Code) AS INT) AND ds.Account_Area_CN='07苏果'
	WHERE ds.Account_Store_Code IS NULL
	AND (CAST(ods.Sales_AMT AS DECIMAL(18,5))>0 OR CAST(ods.Ending_AMT AS DECIMAL(18,5))>0)

	--INFER From VG Mongo Sales
	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Account_Area_CN,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline','Vanguard','VG'
		,ods.shopid,ods.shopname
		,CASE ods.buname WHEN '07苏果' THEN '07苏果' WHEN '华东' THEN '06华东' WHEN '华北' THEN '02华北' WHEN '西北' THEN '03西北' WHEN 'JV华东' THEN '乐购' END
		--ods.buname
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from [ods].[Mongo_CRV_Inventory]'
		,GETDATE(),''
	FROM ods.[ods].[Mongo_CRV_Inventory] ods
	LEFT JOIN [dm].[Dim_Store] ds ON ods.shopid = ds.Account_Store_Code AND ds.Channel_Account='Vanguard'
	WHERE ds.Account_Store_Code IS NULL
	AND qty>0;

	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Account_Area_CN,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline','Vanguard','VG'
		,ods.shopid,ods.shopname
		,CASE ods.buname WHEN '07苏果' THEN '07苏果' WHEN '华东' THEN '06华东' WHEN '华北' THEN '02华北' WHEN '西北' THEN '03西北' WHEN 'JV华东' THEN '乐购' END
		--ods.buname
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from [ods].[Mongo_CRV_Inventory]'
		,GETDATE(),''
	FROM ods.[ods].[Mongo_CRV_DailySales] ods
	LEFT JOIN [dm].[Dim_Store] ds ON ods.shopid = ds.Account_Store_Code AND ds.Channel_Account='Vanguard'
	WHERE ds.Account_Store_Code IS NULL
	AND qty>0;

	--insert from qulouxia sales
	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_ID,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Account_Store_Type,Store_Type,Open_Date,[Status],[Store_Address],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline',48,'Zbox','Zbox'
		,ods.Store_Code,ods.Store_Name
		,ods.Store_Type
		,ods.Store_Type
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运',ods.Store_Name   --增加门店名称放在门店地址中解析   Justin  2020-06-03
		,GETDATE(),'Infer from [ods].[File_Qulouxia_Sales]'
		,GETDATE(),''
	FROM ods.ods.File_Qulouxia_Sales ods
	LEFT JOIN [dm].[Dim_Store] ds ON ods.Store_Code = ds.Account_Store_Code AND ds.Channel_Account='Zbox'
	WHERE ds.Account_Store_Code IS NULL
	
	-----------------------------增加ZBox Store-----------------Justin 2020-06-03
	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_ID,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Open_Date,[Status],[Store_Address],Create_Time,Create_By,Update_Time,Update_By)
		SELECT DISTINCT '','Offline',48,'Zbox','Zbox'
		,ods.[dealer_code],ods.[dealer_name]		
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运',ods.[dealer_name]
		,GETDATE(),'Infer from [ods].[File_Qulouxia_DC2Box]'
		,GETDATE(),''
	FROM [ODS].[ods].[File_Qulouxia_DC2Box] ods
	LEFT JOIN [dm].[Dim_Store] ds ON ods.[dealer_code] = ds.Account_Store_Code AND ds.Channel_Account='Zbox'
	WHERE ds.Account_Store_Code IS NULL

	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_ID,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Open_Date,[Status],[Store_Address],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline',48,'Zbox','Zbox'
		,GP.Store_ID,GP.Store_Name		
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运',GP.Store_Name
		,GETDATE(),'Infer from [ods].[File_Qulouxia_GoodsPassage]'
		,GETDATE(),'' FROM [ODS].[ods].[File_Qulouxia_GoodsPassage] GP
	LEFT JOIN [dm].[Dim_Store] S
	ON GP.Store_ID=S.Account_Store_Code
	WHERE S.Account_Store_Code IS NULL

	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_ID,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline',48,'Zbox','Zbox'
		,ods.Store_ID,ods.Store_Name
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from [ods].[File_Qulouxia_Stores]'
		,GETDATE(),''
	FROM ods.ods.[File_Qulouxia_Stores] ods
	LEFT JOIN [dm].[Dim_Store] ds ON ods.Store_ID = ds.Account_Store_Code AND ds.Channel_Account='Zbox'
	WHERE ds.Account_Store_Code IS NULL

	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_ID,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline',48,'Zbox','Zbox'
		,ods.Store_Code,ods.Store_Name
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from [ods].[File_Qulouxia_Store_SKU_Mapping]'
		,GETDATE(),''
	FROM ods.ods.[File_Qulouxia_Store_SKU_Mapping] ods
	LEFT JOIN [dm].[Dim_Store] ds ON ods.Store_Code = ds.Account_Store_Code AND ds.Channel_Account='Zbox'
	WHERE ds.Account_Store_Code IS NULL


-----------------------------------------------------------------------------------------------------------------
		--insert from centurymart sales
	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_ID,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline',87,'CenturyMart','CM'
		,ods.Store_Code,ods.Store_Name
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from [ods].[File_CenturyMart_DailySales]'
		,GETDATE(),''
	FROM ods.ods.File_CenturyMart_DailySales ods
	LEFT JOIN [dm].[Dim_Store] ds ON ods.Store_Code = ds.Account_Store_Code AND ds.Channel_Account='CenturyMart'
	WHERE ds.Account_Store_Code IS NULL
	--AND Sales_Qty>0;

	-----------------------------增加Huaguan Store-----------------Justin 2020-01-09
	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
		SELECT DISTINCT '','Offline','Huaguan','HG'
		,ods.Store_Code,ods.Store_Name
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from [ods].[File_Huaguan_DailySales]'
		,GETDATE(),''
	FROM [ODS].[ods].[File_Huaguan_DailySales] ods
	LEFT JOIN [dm].[Dim_Store] ds ON ods.Store_Code = ds.Account_Store_Code AND ds.Channel_Account='Huaguan'
	WHERE ds.Account_Store_Code IS NULL

	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_Account,Account_Short,Account_Store_Code,Store_Name,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline','Huaguan','HG'
		,ods.Store_Code,ods.Store_Name
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from [ods].[File_Huaguan_DailyInventory]'
		,GETDATE(),''
	FROM [ODS].[ods].[File_Huaguan_DailyInventory] ods
	LEFT JOIN [dm].[Dim_Store] ds ON ods.Store_Code = ds.Account_Store_Code AND ds.Channel_Account='Huaguan'
	WHERE ds.Account_Store_Code IS NULL

	

	---------------------------------------------------------
	-- update  [dm].[Dim_Store] from [ODS].[File_CRV_Store]
	---------------------------------------------------------
	UPDATE d
	SET d.Store_Address = cs.[address],
		d.Account_Area_CN = CASE cs.buname WHEN '07苏果' THEN '07苏果' WHEN '华东' THEN '06华东' WHEN '华北' THEN '02华北' WHEN '西北' THEN '03西北'  WHEN 'JV华东' THEN '乐购' END,
		d.Account_Area_EN = CASE cs.buname WHEN '07苏果' THEN '07 Suguo' WHEN '华东' THEN '06 Eastern China' WHEN '华北' THEN '02 North China' WHEN '西北' THEN '03 Northwest'  WHEN 'JV华东' THEN '乐购' END,
		d.Account_Store_Group = cs.headshopid,	
		d.Account_Store_Type = cs.shoptype,
		d.[Store_Province] = cs.province,
		d.[Store_City] = cs.city,
		Update_By = 'ods.File_CRV_Store',
		Update_Time = GETDATE()
	FROM dm.Dim_Store d
	JOIN (select distinct 
		shopid,shopname,buname,headshopid,shoptype,[address],telno
		--,code
		,note,province,city
		from ods.ods.File_CRV_Store) cs 
	ON d.Channel_Account='Vanguard' AND d.Account_Store_Code=cs.shopid
	WHERE d.Store_Address IS NULL;

	UPDATE d
	SET d.Store_Address = isnull(yh.store_address,''),	
		d.Store_City = CASE WHEN yh.city='市辖区' THEN '' ELSE yh.city END,
		d.Account_Store_Group = yh.[group],	
		Update_By = 'File_YHStore_glzx',
		Update_Time = GETDATE()
	FROM dm.Dim_Store d
	JOIN ods.stg.File_YHStore_glzx yh ON d.Channel_Account='YH' AND d.Account_Store_Code=yh.store_code
	WHERE d.Store_Address IS NULL;

	UPDATE d
	SET d.Store_Name = isnull(yh.Store_Name,''),
		Update_By = 'File_YHStore_glzx',
		Update_Time = GETDATE()
	FROM dm.Dim_Store d
	JOIN ods.stg.File_YHStore_glzx yh ON d.Channel_Account='YH' AND d.Account_Store_Code=yh.store_code
	WHERE isnull(d.Store_Name,'') ='';	

	--根据新增的IdentityID来生成StoreID
	UPDATE [dm].[Dim_Store]
	SET Store_ID = CASE Channel_Account WHEN 'Vanguard' THEN 'VG' WHEN 'Zbox' THEN 'ZB' WHEN 'CenturyMart' THEN 'CM' WHEN 'Huaguan' THEN 'HG' ELSE Channel_Account END   --增加华冠StoreID  Justin 2020-01-09
		+CAST(ID AS VARCHAR(20))
	WHERE Store_ID='';


	---------------------------------------------------------
	-- --更新省份 大区
	---------------------------------------------------------

	update [dm].[Dim_Store] set Store_Province='河北省',Store_Province_EN='Hebei',Account_Area_CN='02华北',Account_Area_EN='02 North China' 
	where Store_Address like '河北%' and Store_Province is null AND Channel_Account='Vanguard';	
	update [dm].[Dim_Store] set Store_Province='天津市',Store_Province_EN='Tianjin',Account_Area_CN='02华北',Account_Area_EN='02 North China' 
	where Store_Address like '天津%' and Store_Province is null AND Channel_Account='Vanguard';
	update [dm].[Dim_Store] set Store_Province='内蒙古',Store_Province_EN='Neimenggu',Account_Area_CN='02华北',Account_Area_EN='02 North China' 
	where Store_Address like '内蒙古%' and Store_Province is null AND Channel_Account='Vanguard';
	update [dm].[Dim_Store] set Store_Province='江西省',Store_Province_EN='Jiangxi',Account_Area_CN='06华东',Account_Area_EN='06 Eastern China' 
	where Store_Address like '江西%' and Store_Province is null AND Channel_Account='Vanguard';

	update [dm].[Dim_Store] set Store_Province='江苏省',Store_Province_EN='Jiangshu',Account_Area_CN='06华东',Account_Area_EN='06 Eastern China' 
	where Store_City='南京市' AND Channel_Account='Vanguard' AND Store_Province_EN IS NULL;
	update [dm].[Dim_Store] set Store_Province='天津市',Store_Province_EN='Tianjin',Account_Area_CN='02华北',Account_Area_EN='02 North China' 
	where Store_City='天津市' AND Channel_Account='Vanguard' AND Store_Province_EN IS NULL;
	update [dm].[Dim_Store] set Store_Province='浙江省',Store_Province_EN='Zhejiang',Account_Area_CN='06华东',Account_Area_EN='06 Eastern China' 
	where Store_City='嘉兴市' AND Channel_Account='Vanguard' AND Store_Province_EN IS NULL;

	
	update [dm].[Dim_Store] set Store_Province='福建省',Store_Province_EN='Fujian',Account_Area_CN='福建大区',Account_Area_EN='Fujian' 
	where Store_Address like '%福建%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='四川省',Store_Province_EN='Sichuan',Account_Area_CN='四川大区',Account_Area_EN='Sichuan' 
	where Store_Address like '%四川%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='北京市',Store_Province_EN='Beijing',Account_Area_CN='北京大区',Account_Area_EN='Beijing' 
	where Store_Address like '%北京%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='上海市',Store_Province_EN='Shanghai',Account_Area_CN='华东大区',Account_Area_EN='East China' 
	where Store_Address like '%上海%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='江苏省',Store_Province_EN='Jiangsu',Account_Area_CN='华东大区',Account_Area_EN='East China' 
	where Store_Address like '%江苏%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='广东省',Store_Province_EN='Guangdong',Account_Area_CN='广东大区',Account_Area_EN='Guangdong' 
	where Store_Address like '%广东%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='重庆市',Store_Province_EN='Chongqing',Account_Area_CN='重庆大区',Account_Area_EN='Chongqing' 
	where Store_Address like '%重庆%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='安徽省',Store_Province_EN='Anhui',Account_Area_CN='安徽大区',Account_Area_EN='Anhui' 
	where Store_Address like '%安徽%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='河北省',Store_Province_EN='Hebei',Account_Area_CN='河北大区',Account_Area_EN='Hebei' 
	where Store_Address like '%河北%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='云南省',Store_Province_EN='Yunnan',Account_Area_CN='云南大区',Account_Area_EN='Yunnan' 
	where Store_Address like '%云南%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='湖北省',Store_Province_EN='Hubei',Account_Area_CN='湖北大区',Account_Area_EN='Hubei' 
	where Store_Address like '%湖北%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='陕西省',Store_Province_EN='Shaanxi',Account_Area_CN='陕西大区',Account_Area_EN='Shaanxi' 
	where Store_Address like '%陕西%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='贵州省',Store_Province_EN='Guizhou',Account_Area_CN='贵州大区',Account_Area_EN='Guizhou' 
	where Store_Address like '%贵州%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='浙江省',Store_Province_EN='Zhejiang',Account_Area_CN='华东大区',Account_Area_EN='East China' 
	where Store_Address like '%浙江%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='山西省',Store_Province_EN='Shanxi',Account_Area_CN='山西大区',Account_Area_EN='Shanxi' 
	where Store_Address like '%山西%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='广西壮族自治区',Store_Province_EN='Guangxi',Account_Area_CN='广西大区',Account_Area_EN='Guangxi' 
	where Store_Address like '%广西%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='河南省',Store_Province_EN='Henan',Account_Area_CN='河南大区',Account_Area_EN='Henan' 
	where Store_Address like '%河南%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='黑龙江省',Store_Province_EN='Heilongjiang',Account_Area_CN='东北大区',Account_Area_EN='North East' 
	where Store_Address like '%黑龙江%' and Store_Province is null AND Channel_Account='YH';

	
	update [dm].[Dim_Store] set Store_Province='福建省',Store_Province_EN='Fujian',Account_Area_CN='福建大区',Account_Area_EN='Fujian' 
	where Account_Area_CN is null and Account_Store_Group like '福建%' AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='福建省',Store_Province_EN='Fujian',Account_Area_CN='福建大区',Account_Area_EN='Fujian' 
	where Account_Area_CN is null and (Account_Store_Group like '福州%' or Account_Store_Group like '厦门%') AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='重庆市',Store_Province_EN='Chongqing',Account_Area_CN='重庆大区',Account_Area_EN='Chongqing' 
	where Account_Area_CN is null and Account_Store_Group like '重庆%' AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='陕西省',Store_Province_EN='Shaanxi',Account_Area_CN='陕西大区',Account_Area_EN='Shaanxi' 
	where Account_Area_CN is null and Account_Store_Group like '陕西%' AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='四川省',Store_Province_EN='Sichuan',Account_Area_CN='四川大区',Account_Area_EN='Sichuan' 
	where Account_Area_CN is null and Account_Store_Group like '四川%' AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='安徽省',Store_Province_EN='Anhui',Account_Area_CN='安徽大区',Account_Area_EN='Anhui' 
	where Account_Area_CN is null and Account_Store_Group like '安徽%' AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='广东省',Store_Province_EN='Guangdong',Account_Area_CN='广东大区',Account_Area_EN='Guangdong' 
	where Account_Area_CN is null and Account_Store_Group like '广东%' AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='江西省',Store_Province_EN='Jiangxi',Account_Area_CN='华东大区',Account_Area_EN='East China' 
	where Account_Area_CN is null and Account_Store_Group like '江西%' AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='江苏省',Store_Province_EN='Jiangsu',Account_Area_CN='华东大区',Account_Area_EN='East China' 
	where Account_Area_CN is null and Account_Store_Group like '江苏%' AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='湖南省',Store_Province_EN='Hunan',Account_Area_CN='湖南大区',Account_Area_EN='Hunan' 
	where Account_Area_CN is null and Account_Store_Group like '湖南%' AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='浙江省',Store_Province_EN='Zhejiang',Account_Area_CN='华东大区',Account_Area_EN='East China' 
	where Account_Area_CN is null and Account_Store_Group like '浙江%' AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='宁夏回族自治区',Store_Province_EN='Ningxia',Province_Short='宁夏',Account_Area_CN='宁夏大区',Account_Area_EN='Ningxia' 
	where Account_Area_CN is null and Account_Store_Group like '宁夏%' AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='广东省',Store_Province_EN='Guangdong',Account_Area_CN='广东大区',Account_Area_EN='Guangdong' 
	where Account_Area_CN is null and Account_Store_Group like '深圳%' AND Channel_Account='YH';

	--更新城市英文名
	UPDATE dm.Dim_Store set Store_City='石家庄' where Store_City='石家庄市' ;
	update dm.dim_store	set Store_Province='陕西省' where Store_Province_EN='Shaanxi' and Store_Province is null;
	
	update dm.dim_store	set Store_Province_EN='Shanghai',Store_City_EN='Shanghai' where Store_Province='上海市' and Store_Province_EN is null;
	update dm.dim_store	set Store_Province_EN='Jiangsu' where Store_Province='江苏省' and Store_Province_EN is null;
	update dm.dim_store	set Store_City='上海市',Store_City_EN='Shanghai',Store_Province_EN='Shanghai' where Store_Province='上海市' and Store_City=''
	update dm.dim_store	set Store_City='重庆市',Store_City_EN='Chongqing',Store_Province_EN='Chongqing' where Store_Province='重庆市' and Store_City_EN is null
	update dm.dim_store	set Store_City_EN='Fuzhou' where Store_City='福州市' and Store_City_EN<>'Fuzhou'

	UPDATE s
	SET s.Store_City_EN = a.Store_City_EN
	FROM  dm.Dim_Store s
	JOIN (SELECT Store_City,MAX(Store_City_EN) Store_City_EN FROM dm.Dim_Store WHERE Store_City_EN IS NOT NULL GROUP BY Store_City)a
	ON s.Store_City=a.Store_City AND s.Store_City_EN IS NULL;

	--配送中心 仓更新
	update [dm].[Dim_Store]
	set Status='营运仓'
	where (store_name like '%中心' or store_name like '%仓')
	and SR_Level_1=''
	and Status<>'闭店' and Channel_Account='YH';

	--门店类型
	update s
	set 
		s.Account_Store_Type =	case when left([Account_Store_Code],2) = '9D' or Store_Name like 'YHO2O%' then '永辉生活'
						when left([Account_Store_Code],2) in ('9I', '9K') then '超级物种'
						when left([Account_Store_Code],2) in ('9L', '9M','9B', '9F', '9G','9N','9P') then 'Mini Bravo'
						when left([Account_Store_Code],1) in ('w') then 'Other' END,
		s.Account_Store_Type_EN =	case when left([Account_Store_Code],2) = '9D' or Store_Name like 'YHO2O%' then 'YH Life'
						when left([Account_Store_Code],2) in ('9I', '9K') then 'Super Species'
						when left([Account_Store_Code],2) in ('9L', '9M','9B', '9F', '9G','9N','9P') then 'Mini Bravo'
						when left([Account_Store_Code],1) in ('w') then 'Other' END
	from dm.[Dim_Store] s
	where (Account_Store_Type is null or Account_Store_Type_EN is null)
	AND  Channel_Account='YH';

	update  [dm].[Dim_Store]
	set Account_Store_Type='永辉超市',Account_Store_Type_EN='Bravo'
	where (Account_Store_Group like '%商业%' OR Account_Store_Group like '%进价%')
	and Account_Store_Type is null
	and Channel_Account='YH';

	------------------------------------更新ZBox门店
	UPDATE dm.dim_Store set store_type = REPLACE(store_type,'社区店',		'Compound store'  ),  account_store_type = REPLACE(account_store_type,'社区店',		'Compound store'  )		  WHERE Channel_Account = 'ZBox'
	UPDATE dm.dim_Store set store_type = REPLACE(store_type,'公寓'	,    'Appartment'		  ),  account_store_type = REPLACE(account_store_type,'公寓'	,    'Appartment'		  )	  WHERE Channel_Account = 'ZBox'
	UPDATE dm.dim_Store set store_type = REPLACE(store_type,'写字楼店',		'Office'		  ),  account_store_type = REPLACE(account_store_type,'写字楼店',		'Office'		  )		  WHERE Channel_Account = 'ZBox'
	UPDATE dm.dim_Store set store_type = REPLACE(store_type,'校园店',		'School'		  ),  account_store_type = REPLACE(account_store_type,'校园店',		'School'		  )		  WHERE Channel_Account = 'ZBox'
	UPDATE dm.dim_Store set store_type = REPLACE(store_type,'工厂'	,	'Factory'			  ),  account_store_type = REPLACE(account_store_type,'工厂'	,	'Factory'			  )	  WHERE Channel_Account = 'ZBox'
	UPDATE dm.dim_Store set store_type = REPLACE(store_type,'社区'	,	'Community Store'	  ),  account_store_type = REPLACE(account_store_type,'社区'	,	'Community Store'	  )	  WHERE Channel_Account = 'ZBox'
	UPDATE dm.dim_Store set store_type = REPLACE(store_type,'医院'	,	'Hospital'			  ),  account_store_type = REPLACE(account_store_type,'医院'	,	'Hospital'			  )	  WHERE Channel_Account = 'ZBox'
	UPDATE dm.dim_Store set store_type = REPLACE(store_type,'空白'	,	'Blank'				  ),  account_store_type = REPLACE(account_store_type,'空白'	,	'Blank'				  )	  WHERE Channel_Account = 'ZBox'

	--更新经纬度

	--UPDATE dst SET dst.[lng] = CASE WHEN ost.lng <>'null' THEN CAST(ost.[lng] AS DECIMAL(30,20)) END
	--			  ,dst.lat = CASE WHEN ost.lat <>'null' THEN CAST(ost.lat AS DECIMAL(30,20)) END 
	--FROM [dm].[Dim_Store] dst 
	--LEFT JOIN [ODS].[ods].[Dim_Store] ost 
	--ON dst.Account_Store_Code = ost.Account_Store_Code AND dst.Channel_Account = ost.Channel_Account;
	-------------------------更新KW销售区域

	UPDATE dm.Dim_Store SET Sales_Area_CN = CASE WHEN Store_City IN ('昆山市','苏州市') THEN '苏州'
												 WHEN Store_City IN ('徐州市','淮安市') THEN '苏北'
												 WHEN Store_City IN ('盐城市','泰州市','南通市') THEN '苏中'
												 WHEN Store_City IN ('宜兴市','常州市','无锡市') THEN '锡常'
												 WHEN Store_City IN ('丹阳市','南京市','扬州市','镇江市') THEN '南京'
												 WHEN Store_City IN ('杭州') THEN '杭州'
												 WHEN Store_City IN ('上海市') THEN '上海'
												 WHEN Store_Province IN ('四川省') THEN '四川'
												 WHEN Store_Province IN ('安徽省') THEN '安徽'
												 WHEN Store_City IN ('重庆市') THEN '重庆' 
												 WHEN Store_Name = '孩子王电商' THEN '电商'
												 END
	WHERE Channel_Account = 'KW'
	AND Sales_Area_CN IS NULL;

	------------------------------更新crv销售区域
	UPDATE st SET Sales_Area_CN = CASE WHEN si.buname LIKE '%华北%' OR st.Store_Province='天津市' THEN '天津'
									   WHEN si.buname LIKE '%西北%' OR st.Store_Province='陕西省' THEN '陕西'
									   WHEN (si.buname LIKE '%华东%' AND si.venderid = '1914201103')  OR st.Store_Province='江西省' THEN '江西'
									   WHEN (si.buname LIKE '%华东%' AND si.venderid = '1914201102') OR st.Store_Province='浙江省' THEN '浙江'
									   WHEN si.buname LIKE '%sg%' OR st.Account_Area_CN='07苏果' THEN '苏果'
									   WHEN si.venderid = '1914201106' OR st.Account_Area_CN='乐购' THEN '乐购'
									 END
				,Channel_ID =CASE WHEN si.buname LIKE '%华北%' OR st.Store_Province='天津市' THEN 52
									   WHEN buname LIKE '%西北%' OR st.Store_Province='陕西省' THEN 53
									   WHEN (si.buname LIKE '%华东%' AND si.venderid = '1914201103')  OR st.Store_Province='江西省' THEN 56
									   WHEN (buname LIKE '%华东%' AND si.venderid = '1914201102') OR st.Store_Province='浙江省' THEN 46
									   WHEN buname LIKE '%sg%' OR st.Account_Area_CN='07苏果' THEN 55
									   WHEN si.venderid = '1914201106'  OR st.Account_Area_CN='乐购' THEN 73
									 END
	FROM  dm.Dim_Store AS st 
	LEFT JOIN (
		SELECT DISTINCT venderid,buname,shopid FROM ods.ods.File_CRV_DailySales
		UNION 
		SELECT DISTINCT venderid,buname,shopid FROM ods.ods.File_CRV_DailyInventory
		UNION 
		SELECT DISTINCT venderid,buname,shopid FROM ods.ods.Mongo_CRV_Inventory
		UNION 
		SELECT DISTINCT venderid,buname,shopid FROM ods.ods.Mongo_CRV_DailySales
		UNION
		SELECT DISTINCT '','sg',Store_Code FROM ods.ods.File_SG_DailySales
	) AS si ON st.Account_Store_Code = si.shopid
	WHERE Channel_Account = 'Vanguard' AND (Sales_Area_CN IS NULL OR Channel_ID IS NULL);


	UPDATE dm.Dim_Store SET Province_Short = REPLACE(REPLACE(Store_Province,'省',''),'市','') WHERE Province_Short IS NULL;

	UPDATE ds
	SET ds.Sales_Region = rp.Region
	FROM dm.Dim_Store ds
	JOIN dm.Dim_Sales_RegionsbyProvince rp ON ISNULL(ds.Store_Province,'NOTFOUND')=rp.Province
	WHERE ISNULL(ds.Sales_Region,'') <> rp.Region;


	---------------------------------------------------------
	-- --更新Channel_ID
	---------------------------------------------------------
	UPDATE dm.Dim_Store SET Channel_ID = 5 WHERE Channel_Account='YH' AND Channel_ID IS NULL;
	UPDATE dm.Dim_Store SET Channel_ID = 48 WHERE Channel_Account='Zbox' AND Channel_ID IS NULL;
	UPDATE dm.Dim_Store SET Channel_ID = 16 WHERE Channel_Account='KW' AND Channel_ID IS NULL;
	UPDATE dm.Dim_Store SET Channel_ID = 87 WHERE Channel_Account='CenturyMart' AND Channel_ID IS NULL;
	UPDATE dm.Dim_Store SET Channel_ID = 20 WHERE Channel_Account='Huaguan' AND Channel_ID IS NULL;
	UPDATE dm.Dim_Store SET Channel_ID = 113 WHERE Channel_Account='RTMart' AND Channel_ID IS NULL;
	UPDATE dm.Dim_Store SET Channel_ID = CASE WHEN Account_Area_CN='03西北' THEN 53
		WHEN Account_Area_CN='06华东' AND Store_Province='江西省' THEN 56
		WHEN Account_Area_CN='06华东' AND Store_Province='浙江省' THEN 46
		WHEN Account_Area_CN='02华北' THEN 52
		WHEN Account_Area_CN='07苏果' THEN 55
		WHEN Account_Area_CN='乐购' THEN 73 END
		 WHERE Channel_Account='Vanguard' AND Channel_ID IS NULL;

	--默认 ‘Zbox’ 省份城市为 ‘北京’

	UPDATE dm.Dim_Store 
	SET	  Store_Province='北京市',	
		  Store_Province_EN='Beijing',	
		  Province_Short='北京',	
		  Store_City='北京市',	
		  Store_City_EN='Beijing'
	WHERE Channel_Account='Zbox' AND Store_Province IS NULL;

	--Add POP_ID； 暂时用code join，不完全精确

	UPDATE dm
	SET dm.POP_ID = ods.POP_ID
	FROM dm.Dim_Store dm
	JOIN ODS.[ods].[POP6_POP] ods ON dm.Account_Store_Code=ods.POP_Code
	WHERE ISNULL(dm.POP_ID,'') <> ods.POP_ID;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
--SELECT *FROM [dm].[Dim_Store]


	END


	--select *  FROM [dm].[Dim_Store] ds 
GO
