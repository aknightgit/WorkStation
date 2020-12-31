USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC  [dm].[SP_Dim_O2O_Fans_Update]
AS BEGIN

	 DECLARE @errmsg nvarchar(max),
	 @DatabaseName varchar(100) = DB_NAME(),
	 @ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	TRUNCATE TABLE  [dm].[Dim_O2O_Fans] ;

	INSERT INTO [dm].[Dim_O2O_Fans]
           ([Fan_id]
           ,[Brand]
           ,[app_id]
           ,[union_id]
           ,[open_id]
           ,[nick_name]
           ,[gender]
           ,[city]
           ,[province]
           ,[country]
           ,[subscribe]
           ,[subscribe_time]
           ,[subscribe_scene]
           ,[qr_scene]
           ,[qr_scene_str]
           ,[scene_qrcode_str]
           ,[scene_in_day]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	
	SELECT i.id as Fan_id,
		--i.mp_id,
		CASE WHEN i.mp_id = 325364401861431296 THEN 'Bravomama倍乐曼'
			WHEN i.mp_id = 297825819592626176 THEN 'FoodUnion'
			WHEN i.mp_id = 297465504275238912 THEN 'Lakto乐味可'
			WHEN i.mp_id = 325288922244583424 THEN 'Rasa醇饴牧场'
			WHEN i.mp_id = 325303654313758720 THEN 'SHAPETIME形动力' END AS 'Brand',
		i.app_id,
		i.union_id,
		i.open_id,
		i.nick_name,
		CASE i.gender WHEN 1 THEN 'M' WHEN 2 THEN 'F' ELSE 'Unknonw' END AS gender,
		i.city,
		i.province,
		i.country,
		i.subscribe,
		i.subscribe_time,
		i.subscribe_scene,
		i.qr_scene,
		i.qr_scene_str,
		--i.scene_qrcode_id,
		replace(isnull(a.event_key,''),'qrscene_','') AS scene_qrcode_str,
		a.in_day as scene_in_day,
		getdate(),@ProcName,getdate(),@ProcName
	FROM ODS.ods.SCRM_wx_fans_info i with(nolock)
	LEFT JOIN (		
			select open_id,	event_key, in_day, ROW_NUMBER() over(partition by open_id order by event_create_time) RID
			from ODS.ods.SCRM_wx_fans_event_record with(nolock)
			where event_name in ('SCAN','subscribe') --and isnull(event_key,'')<>''
			and mp_id='297825819592626176'
			and event_key <>'' --找出第一次引流非空的作为KOL人
			) a
	ON i.open_id=a.open_id AND a.RID=1
	WHERE mp_id='297825819592626176'  --O2O
	ORDER BY 1
	;

	-- update KOL info from ODS.[ods].[SCRM_O2O_QRCodeMapping]
	UPDATE f
		SET f.KOL = qr.QRCode,
			f.[Channel] = qr.[Channel],
			f.KOL_Mobile = qr.Mobile,
			f.KOL_EmployeeID = e.Employee_ID,
			f.KOL_EmployeeName = isnull(e.Employee_Name,qr.QRCode)
	FROM [dm].[Dim_O2O_Fans] f 
	JOIN ODS.[ods].[SCRM_O2O_QRCodeMapping] qr with(nolock) 
	ON qr.QRkey = CASE WHEN f.[scene_qrcode_str] LIKE 'youzan%' THEN [scene_qrcode_str]
		WHEN f.[scene_qrcode_str] LIKE '100%' THEN 'FGF' ELSE 'Organic' END 
	LEFT JOIN [dm].[Dim_O2O_Employee] e ON qr.Mobile = e.mobile;


END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
