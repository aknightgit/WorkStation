USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Dim_Store_Update]
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
	(Store_ID,Channel_Type,Channel_Account,Account_Store_Code,Store_Name,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By
	,[Store_City],[Store_City_EN],[Store_Address],[Account_Store_Group],[Store_Province],[Store_Province_EN],[Account_Store_Type],[Account_Store_Type_EN],lng,lat)
	SELECT DISTINCT '','Offline','YH',ods.shop_id,ods.shop_name,CONVERT(VARCHAR(8),GETDATE(),112),'营运'
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
	(Store_ID,Channel_Type,Channel_Account,Account_Store_Code,Store_Name,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By
	,[Store_City],[Store_City_EN],[Store_Address],[Account_Store_Group],[Store_Province],[Store_Province_EN],[Account_Store_Type],[Account_Store_Type_EN],lng,lat)
	SELECT DISTINCT '','Offline','YH',ods.shop_id,'',CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from ods.EDI_YH_Inventory'
		,GETDATE(),''
		,oods.[Store_City],oods.[Store_City_EN],oods.[Store_Address],oods.[Account_Store_Group]
		,oods.[Store_Province],oods.[Store_Province_EN],oods.[Account_Store_Type],oods.[Account_Store_Type_EN],oods.lng,oods.lat
	FROM ods.ods.EDI_YH_Inventory ods
	LEFT JOIN ods.[ods].[Dim_Store] oods ON oods.Channel_Account='YH' AND ods.shop_id=oods.Account_Store_Code
	LEFT JOIN [dm].[Dim_Store] ds ON ods.shop_id = ds.Account_Store_Code AND ds.Channel_Account='YH'
	WHERE ds.Account_Store_Code IS NULL;

	--INFER From Vanguard Sales
	INSERT INTO [dm].[Dim_Store]
	(Store_ID,Channel_Type,Channel_Account,Account_Store_Code,Store_Name,Account_Area_CN,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline','Vanguard'
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
	(Store_ID,Channel_Type,Channel_Account,Account_Store_Code,Store_Name,Account_Area_CN,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline','Vanguard'
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
	(Store_ID,Channel_Type,Channel_Account,Account_Store_Code,Store_Name,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline','KW'
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
	(Store_ID,Channel_Type,Channel_Account,Account_Store_Code,Store_Name,Account_Area_CN,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline','Vanguard'
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
	(Store_ID,Channel_Type,Channel_Account,Account_Store_Code,Store_Name,Account_Area_CN,Open_Date,[Status],Create_Time,Create_By,Update_Time,Update_By)
	SELECT DISTINCT '','Offline','Vanguard'
		,ods.shopid,ods.shopname
		,CASE ods.buname WHEN '07苏果' THEN '07苏果' WHEN '华东' THEN '06华东' WHEN '华北' THEN '02华北' WHEN '西北' THEN '03西北' END
		--ods.buname
		,CONVERT(VARCHAR(8),GETDATE(),112),'营运'
		,GETDATE(),'Infer from [ods].[Mongo_CRV_Inventory]'
		,GETDATE(),''
	FROM ods.[ods].[Mongo_CRV_Inventory] ods
	LEFT JOIN [dm].[Dim_Store] ds ON ods.shopid = ds.Account_Store_Code AND ds.Channel_Account='Vanguard'
	WHERE ds.Account_Store_Code IS NULL
	AND qty>0;

	---------------------------------------------------------
	-- update  [dm].[Dim_Store] from [ODS].[File_CRV_Store]
	---------------------------------------------------------
	UPDATE d
	SET d.Store_Address = cs.address,
		d.Account_Area_CN = CASE cs.buname WHEN '07苏果' THEN '07苏果' WHEN '华东' THEN '06华东' WHEN '华北' THEN '02华北' WHEN '西北' THEN '03西北' END,
		d.Account_Area_EN = CASE cs.buname WHEN '07苏果' THEN '07 Suguo' WHEN '华东' THEN '06Eastern China' WHEN '华北' THEN '02 North China' WHEN '西北' THEN '03 Northwest' END,
		d.Account_Store_Group = cs.headshopid,	
		d.Account_Store_Type = cs.shoptype,
		d.[Store_Province] = cs.province,
		d.[Store_City] = cs.city,
		Update_By = 'ods.File_CRV_Store',
		Update_Time = GETDATE()
	FROM dm.Dim_Store d
	JOIN (select distinct 
		shopid,shopname,buname,headshopid,shoptype,address,telno,code,note,province,city
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
	
	UPDATE [dm].[Dim_Store]
	SET Store_ID = CASE Channel_Account WHEN 'Vanguard' THEN 'VG' ELSE Channel_Account END 
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
	update [dm].[Dim_Store] set Store_Province='江西省',Store_Province_EN='Jiangxi',Account_Area_CN='06华东',Account_Area_EN='06Eastern China' 
	where Store_Address like '江西%' and Store_Province is null AND Channel_Account='Vanguard';

	update [dm].[Dim_Store] set Store_Province='江苏省',Store_Province_EN='Jiangshu',Account_Area_CN='06华东',Account_Area_EN='06Eastern China' 
	where Store_City='南京市' AND Channel_Account='Vanguard' AND Store_Province_EN IS NULL;

	
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
	update [dm].[Dim_Store] set Store_Province='陕西省',Store_Province_EN='Shannxi',Account_Area_CN='陕西大区',Account_Area_EN='Shannxi' 
	where Store_Address like '%陕西%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='贵州省',Store_Province_EN='Guizhou',Account_Area_CN='贵州大区',Account_Area_EN='Guizhou' 
	where Store_Address like '%贵州%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='浙江省',Store_Province_EN='Zhejiang',Account_Area_CN='华东大区',Account_Area_EN='East China' 
	where Store_Address like '%浙江%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='山西省',Store_Province_EN='Shanxi',Account_Area_CN='山西大区',Account_Area_EN='Shanxi' 
	where Store_Address like '%山西%' and Store_Province is null AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='广西省',Store_Province_EN='Guangxi',Account_Area_CN='广西大区',Account_Area_EN='Guangxi' 
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
	update [dm].[Dim_Store] set Store_Province='陕西省',Store_Province_EN='Shannxi',Account_Area_CN='陕西大区',Account_Area_EN='Shannxi' 
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
	update [dm].[Dim_Store] set Store_Province='宁夏省',Store_Province_EN='Ningxia',Account_Area_CN='宁夏大区',Account_Area_EN='Ningxia' 
	where Account_Area_CN is null and Account_Store_Group like '宁夏%' AND Channel_Account='YH';
	update [dm].[Dim_Store] set Store_Province='广东省',Store_Province_EN='Guangdong',Account_Area_CN='广东大区',Account_Area_EN='Guangdong' 
	where Account_Area_CN is null and Account_Store_Group like '深圳%' AND Channel_Account='YH';

	--更新城市英文名
	UPDATE dm.Dim_Store set Store_City='石家庄' where Store_City='石家庄市' ;
	update dm.dim_store	set Store_Province='陕西省' where Store_Province_EN='Shannxi' and Store_Province is null;
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
	where Account_Store_Group like '%商业%'
	and Account_Store_Type is null
	and Channel_Account='YH';

	--更新经纬度

	--UPDATE dst SET dst.[lng] = CASE WHEN ost.lng <>'null' THEN CAST(ost.[lng] AS DECIMAL(30,20)) END
	--			  ,dst.lat = CASE WHEN ost.lat <>'null' THEN CAST(ost.lat AS DECIMAL(30,20)) END 
	--FROM [dm].[Dim_Store] dst 
	--LEFT JOIN [ODS].[ods].[Dim_Store] ost 
	--ON dst.Account_Store_Code = ost.Account_Store_Code AND dst.Channel_Account = ost.Channel_Account;

	
	
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
