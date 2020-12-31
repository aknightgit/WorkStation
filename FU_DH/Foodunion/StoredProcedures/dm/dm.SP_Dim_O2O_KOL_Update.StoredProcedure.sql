USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Dim_O2O_KOL_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC  [dm].[SP_Dim_O2O_KOL_Update]
AS BEGIN

	 DECLARE @errmsg nvarchar(max),
	 @DatabaseName varchar(100) = DB_NAME(),
	 @ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	TRUNCATE TABLE  [dm].[Dim_O2O_KOL] ;
	INSERT INTO [dm].[Dim_O2O_KOL]
        ([KolName]
		,KOL_Employee_ID
        ,[QRKey]
        ,[Channel]
        ,[Mobile]
        ,[Store]
        ,[Offline_id]
        ,[Province]
        ,[City]
        ,[Area]
        ,[Address]
        ,[is_self_fetch]
        ,[is_store]
        ,[Mobile2]
        ,[lng]
        ,[lat]
        ,[Create_Time]
        ,[Create_By]
        ,[Update_Time]
        ,[Update_By])
	SELECT 
		isnull(e.employee_name,qr.QRCode) as KolName
		--e.employee_name AS KolName
		,CASE WHEN qr.Mobile IS NOT NULL THEN isnull(e.employee_id,qr.mobile) ELSE '11111111111' END AS Employee_ID
		,qr.QRKey as QRKey
		,qr.Channel
		,qr.Mobile
		,isnull(ys2.name,qr.Store)
		,isnull(ys2.yz_id,ys.yz_id) as Offline_id
		,isnull(ys2.Province,ys.province)
		,isnull(ys2.City,ys.city)
		,isnull(ys2.Area,ys.area)
		,isnull(ys2.Address,ys.Address)
		,isnull(ys2.is_self_fetch,ys.is_self_fetch)
		,isnull(ys2.is_store,ys.is_store)
		,isnull(ys2.phone2,ys.phone2) as Mobile2
		,isnull(ys2.lng,ys.lng)
		,isnull(ys2.lat,ys.lat)
		,GETDATE()
		,@ProcName
		,GETDATE()
		,@ProcName  
	FROM ods.ods.SCRM_O2O_QRCodeMapping qr
	LEFT JOIN ods.[ods].[SCRM_youzan_store] ys ON qr.Store=ys.name
	LEFT JOIN ods.[ods].[SCRM_youzan_store] ys2 ON qr.Mobile=ys2.phone2
	LEFT JOIN ods.[ods].[SCRM_youzan_employee] e ON e.mobile=qr.Mobile AND e.employee_no NOT IN ('ms.WuLong')
	--ORDER BY KolName,QRKey
	WHERE qr.QRCode NOT IN ('办公室','武康路')

	UNION

	SELECT 
		e.employee_name as KolName
		,e.employee_id AS Employee_ID
		,'' as QRKey
		,'' as Channel
		,e.mobile
		,''
		,'' as Offline_id
		,null
		,null
		,null
		,''
		,''
		,''
		,e.mobile as Mobile2
		,null
		,null
		,GETDATE()
		,@ProcName
		,GETDATE()
		,@ProcName  
	FROM ods.[ods].[SCRM_youzan_employee] e 
	WHERE (org_name='o2o' or employee_id in 
			(SELECT DISTINCT Fenxiao_Employee_id FROM ODS.ods.SCRM_order_base_info))  --未在mapping表，但是有分销单,
		AND mobile NOT IN (SELECT isnull(Mobile,'') 
		FROM ods.ods.SCRM_O2O_QRCodeMapping )  -- O2O Employee that not in QR Mapping list
	
	UNION
	--无Fenxiaoid 取手机号，有分销员可能未注册EmployeeID
	SELECT 
		fenxiao_mobile as KolName
		,fenxiao_mobile AS Employee_ID
		,'' as QRKey
		,'' as Channel
		,fenxiao_mobile as mobile
		,''
		,'' as Offline_id
		,null
		,null
		,null
		,''
		,''
		,''
		,fenxiao_mobile as Mobile2
		,null
		,null
		,GETDATE()
		,@ProcName
		,GETDATE()
		,@ProcName  
	FROM ODS.ods.SCRM_order_base_info  --未在mapping表，但是有分销单,无Fenxiaoid则取手机号，有分销员可能未注册EmployeeID
	WHERE Fenxiao_Employee_id IS NULL and fenxiao_mobile is NOT NULL
	AND fenxiao_mobile NOT IN (select mobile from ods.ods.SCRM_O2O_QRCodeMapping)
	
	ORDER BY KolName,QRKey
	;

	INSERT INTO [dm].[Dim_O2O_KOL]
        ([KolName]
		,KOL_Employee_ID
        ,[QRKey]
        ,[Channel]
        ,[Mobile]
        ,[Store]
        ,[Offline_id]
        ,[Province]
        ,[City]
        ,[Area]
        ,[Address]
        ,[is_self_fetch]
        ,[is_store]
        ,[Mobile2]
        ,[lng]
        ,[lat]
        ,[Create_Time]
        ,[Create_By]
        ,[Update_Time]
        ,[Update_By])
	SELECT DISTINCT
		ys.name as KolName
		--e.employee_name AS KolName
		,'11111111111' AS Employee_ID
		,'' as QRKey
		,'' as Channel
		,'' as mobile
		,ys.name
		,ys.yz_id as Offline_id
		,ys.[Province]
        ,ys.[City]
        ,ys.[Area]
		,ys.[Address]
        ,ys.[is_self_fetch]
        ,ys.[is_store]
		,'' as Mobile2
		,null
		,null
		,GETDATE()
		,'SCRM_youzan_store补充'
		,GETDATE()
		,'SCRM_youzan_store补充'
		--SELECT *
	FROM ODS.ods.SCRM_order_base_info  ob 
	JOIN ODS.ODS.SCRM_youzan_store ys ON ob.offline_id=ys.yz_id
	--LEFT JOIN ODS.[ods].[SCRM_youzan_employee] e ON e.mobile=ob.fenxiao_mobile
	LEFT JOIN dm.Dim_O2O_KOL k ON ob.offline_id=k.Offline_id
	WHERE k.Offline_id IS NULL;
	
	--SELECT Offline_id FROM DM.Dim_O2O_KOL where offline_id='58830878'

	--Unknown for Non KOL Order
	SET IDENTITY_INSERT [dm].[Dim_O2O_KOL] ON ;
	INSERT INTO [dm].[Dim_O2O_KOL]
        (ID
		,[KolName]
		,[KOL_Employee_ID]
        ,[QRKey]
        ,[Channel]
        ,[Province]
        ,[City]
        ,[Area]
        ,[Create_Time]
        ,[Update_Time]
        )
	SELECT 0,'Non KOL Order','00000000000','','Non KOL','Non KOL','Non KOL','Non KOL',GETDATE(),GETDATE();
	SET IDENTITY_INSERT [dm].[Dim_O2O_KOL] OFF;

	--找不到Office/Store
	UPDATE [dm].[Dim_O2O_KOL]
	SET Province='Other',City='Other',Area='Other'
	WHERE Province IS NULL OR CITY IS NULL;

END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END

--select * from dm.Dim_O2O_KOL where offline_id is null
--select *from ods.ods.SCRM_O2O_QRCodeMapping where QRCode='顾问-杨帆'
--select * from ods.[ods].[SCRM_youzan_store] where name='富友宝山区真华路配送站'
--select *from ods.[ods].[SCRM_youzan_employee] where mobile='15801816676'
--select *from ods.[ods].[SCRM_youzan_employee] where employee_id='307595365765484544'
--select *from ods.[ods].[SCRM_youzan_employee] where employee_name like '%顾问-刘方%'

--update ods.ods.SCRM_O2O_QRCodeMapping
--set Mobile='15801816676' where QRCode='顾问-刘方'

--select *from ods.[ods].[SCRM_youzan_store] where yz_id='58818322'
--select *from ods.[ods].[SCRM_youzan_employee] e


--select *from ods.ods.SCRM_O2O_QRCodeMapping qr where QRCode='褚晓丽'
--select * from ods.[ods].[SCRM_youzan_employee] where mobile='13681892145'
--select * from ods.[ods].[SCRM_youzan_employee] where employee_name like '褚%'
GO
