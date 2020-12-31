USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dm].[SP_Fct_FXXK_KAStoreVisit_Update]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	DECLARE @retention INT = 30;

	--TRUNCATE TABLE [dm].[Fct_FXXK_KAStoreVisit];
	DELETE dm
	FROM [dm].[Fct_FXXK_KAStoreVisit] dm
	JOIN [ODS].[ods].[Fxxk_SRDailyCheckin] ods ON dm.ID = ods.check_id
	WHERE ods.Load_DTM >= GETDATE()-@retention;

	INSERT INTO [dm].[Fct_FXXK_KAStoreVisit]
           ([ID]
		   ,[Datekey]
           ,[Visit_Date]
           ,[Customer]
           ,[SalesPerson]
           ,[SalesPerson_Account]
           ,[Department]
           ,[Device_ID]
           ,[Region]
           ,[Store_ID]
		   ,[Store_Code]
           ,[Store_Name]
           ,[Store_Province]
           ,[Store_City]
           ,[Store_Address]
           ,[Checkin_Status]
           ,[Checkin_Time]
           ,[CheckOut_Time]
           ,[Duration_Mins]
           ,[Duration_Hrs]
           ,[longitude]
           ,[Latitude]
           ,[Checkin_Distance]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By]
		   ,[Checkin_Type]
		   ,[Checkout_Lon]
		   ,[Checkout_Lat]
		   ,[Finish_Time]
		   )
	SELECT ods.check_id,
		convert(varchar(8),ods.checkins_time,112),
		ods.checkins_time,
		isnull(ds.Channel_Account,''),
		emp.[Name], 
		[dbo].[Format_CleanColumnName](ods.created_by),
		ods.owner_department,
		ods.device_id,
		ds.Sales_Region,
		--'', --storeid
		isnull(ds.Store_ID,''),
		st.storecode,
		LEFT(ods.crm_child_object,CASE WHEN LEN(ods.crm_child_object) =0 THEN 1 ELSE LEN(ods.crm_child_object) END -1),
		ods.address_province,
		ods.address_city,
		ods.checkin_address_desc,
		ods.[status],
		ods.checkins_time,
		ods.check_out_time,
		DATEDIFF(MINUTE,ods.checkins_time,ods.check_out_time),
		DATEDIFF(MINUTE,ods.checkins_time,ods.check_out_time)*1.0/60,
		ods.checkins_lon,
		ods.checkins_lat,
		ods.checkins_distnace,
		GETDATE(),'[dm].[SP_Fct_FXXK_KAStoreVisit_Update]',
		GETDATE(),'[dm].[SP_Fct_FXXK_KAStoreVisit_Update]',

---------------------------新增字段
	--	check_type_id,
---------------------------20201111 用Fxxk_Checkin_Type 的typename 替换typeid
        ck.typeName as [Checkin_Type] ,
		check_out_lon,
		check_out_lat,
		finish_time

	FROM [ODS].[ods].[Fxxk_SRDailyCheckin] ods
	JOIN [dm].[Dim_Employee] emp ON [dbo].[Format_CleanColumnName](ods.created_by)=emp.UserID_Fxxk
	JOIN [ODS].[ods].[Fxxk_StoreList] st ON ods.customer_id=st.id
	LEFT JOIN [dm].[Dim_Store] ds ON st.storecode=ds.Account_Store_Code AND CHARINDEX(ds.Province_Short,ods.address_province)>0
	left join [ODS].ods.Fxxk_Checkin_Type ck on ods.check_type_id = ck.typeId
	WHERE ods.checkin_status = 'true'
	AND ods.is_deleted = 'false'
	AND ods.Load_DTM >= GETDATE()-@retention;

	
	UPDATE a
		SET a.Store_ID=b.Store_ID,a.Customer=b.Customer
	FROM  [dm].[Fct_FXXK_KAStoreVisit] a
	JOIN  [dm].[Fct_FXXK_KAStoreVisit] b on a.Store_Name=b.Store_Name AND a.Store_ID='' AND b.Store_ID<>'';
		
	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END


--select *from dm.Fct_FXXK_KAStoreVisit where id='5fa87e70c20d160001d3f722'

GO
