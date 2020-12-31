USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dm].[SP_Dim_Store_Fxxk_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY	

	--IF exists (select * from tempdb.dbo.sysobjects where id = object_id(N'#Temp_Store_Fxxk') and type='U')
	--TRUNCATE TABLE [dm].[Dim_Store_Fxxk] ;
    DROP TABLE IF EXISTS #Temp_Store_Fxxk;

	SELECT fs.id as [Fxxk_ID]
	  ,fs.storecode as StoreCode
	  ,fs.storename as StoreName
	  ,fs.address as StoreAddress
	  ,d.departmentid as DeptID
	  ,d.name as DeptName
	  ,fs.owner
	  ,u.name as StoreOwner
	  ,u.position
	  ,(case fs.channel 
		when '永辉' then 'YH'
		when '华润万家' then 'CRV'
		else '其他'
		end)	AS channel_account
	  ,fs.store_type	
	  ,fs.account_type	
	  ,fs.channel	
	  ,fs.region	
	  ,fs.sales_region	
	  ,fs.account_status	
	  ,fs.pg	
	  ,fs.store_level
	  ,cre.name as createby
	  ,lf.name as lastfollower
	  ,fs.last_modified_time
	  ,row_number() over(partition by fs.storecode,fs.channel order by fs.last_modified_time desc) as rid
	  ,getdate() [Create_Time]
	  ,'AK' [Create_By]
	  ,GETDATE() [Update_Time]
	  ,'AK' [Update_By] 
	INTO  #Temp_Store_Fxxk
	FROM ODS.[ods].[Fxxk_StoreList] fs
	LEFT JOIN ODS.[ods].[Fxxk_DepartmentInfo] d on fs.owner_department_id=d.departmentid
	LEFT JOIN ODS.[ods].[Fxxk_UserList] u on fs.[owner]=u.openUserId
	LEFT JOIN ODS.[ods].[Fxxk_UserList] cre on fs.[created_by]=cre.openUserId
	LEFT JOIN ODS.[ods].[Fxxk_UserList] lf on [dbo].[Format_CleanColumnName](fs.[last_follower])=lf.openUserId
	WHERE ISNULL(fs.storecode,'闭店') <>'闭店';

	DELETE o
	FROM [dm].[Dim_Store_Fxxk] o
	JOIN #Temp_Store_Fxxk s
	ON o.[Fxxk_ID]=s.[Fxxk_ID]
	WHERE s.rid=1;

	INSERT INTO  [Foodunion].[dm].[Dim_Store_Fxxk]
	(
	   [Fxxk_ID]
      ,[Store_Code]
      ,[Store_Name]
      ,[Store_Address]
	  ,[Channel]
	  ,[Channel_Account]
	  ,[Store_Type]
	  ,[Sales_Region]
	  ,[Store_Level]
      ,[Department_ID]
      ,[Department_Name]
      ,[Owner_ID]
      ,[Owner]
      ,[Role]
	  ,[Store_CreatedBy] 
	  ,[Last_Follower]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
	)
	select [Fxxk_ID]
	  ,StoreCode
	  ,StoreName
	  ,StoreAddress
	  ,channel
	  ,channel_account
	  ,store_type
	  ,sales_region
	  ,store_level
	  ,DeptID
	  ,DeptName
	  ,owner
	  ,StoreOwner
	  ,position
	  ,createby
	  ,lastfollower
	  ,[Create_Time]
	  ,[Create_By]
	  ,[Update_Time]
	  ,[Update_By]  
	from #Temp_Store_Fxxk
	where rid = 1
	 ;


---------------------------------------------UPDATE dm.Dim_Store   20201109------------------------------------
	
	UPDATE fxxk
		SET fxxk.Channel = CASE ds.Channel_Account when 'YH' THEN '永辉' WHEN 'Vanguard' THEN '华润万家' 
			WHEN 'CenturyMart' THEN '世纪联华' WHEN 'Huaguan' THEN '北京华冠'  END
	FROM [dm].[Dim_Store_Fxxk] fxxk
	JOIN [dm].[Dim_Store] ds ON fxxk.Store_Code = ds.Account_Store_Code
	WHERE fxxk.Channel='其他';

	UPDATE dm.Dim_Store 
	SET dm.Dim_Store.Store_Type = [dm].[Dim_Store_Fxxk].Store_Type 
		,dm.Dim_Store.Sales_Region = [dm].[Dim_Store_Fxxk].Sales_Region 
		,dm.Dim_Store.Level_Code = [dm].[Dim_Store_Fxxk].Store_Level 
		,dm.Dim_Store.SR_Level_1 = [dm].[Dim_Store_Fxxk].Owner 

	FROM [dm].[Dim_Store_Fxxk]
	WHERE dm.Dim_Store.Account_Store_Code=[dm].[Dim_Store_Fxxk].Store_Code
		and (case  [dm].[Dim_Store_Fxxk].Channel 
		when '永辉' then 'YH'
		when '孩子王' then 'KW'
		when '北京华冠' then 'Huaguan'
		when '世纪联华' then 'CenturyMart'
		when '华润万家' then 'Vanguard'
		end)  = dm.Dim_Store.Channel_Account

;



	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

	END


GO
