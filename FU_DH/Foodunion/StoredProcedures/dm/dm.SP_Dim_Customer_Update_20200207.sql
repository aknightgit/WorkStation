USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dm].[SP_Dim_Customer_Update_20200207]
AS
BEGIN

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	--TRUNCATE TABLE [dm].[Dim_Customer];

	--从SCRM注册用户导入customer
	INSERT INTO [dm].[Dim_Customer]
           ([WX_Union_ID]
           ,[WX_Open_ID]
           ,[Mobile_Phone]
           ,[Mobile_Phone_Secondary]
           ,[First_Name]
           ,[Last_Name]
           ,[Full_Name]
           ,[Nick_Name]
           ,[Source]
           ,[Status]
           ,[Gender]
           ,[Birth_Date]
           ,[Nationality]
           ,[Province]
           ,[City]
           ,[Area]
           ,[Address]
           ,[Post_Code]
           ,[Email]
           ,[QQ]
           ,[Is_Registered]
           ,[Register_Platform]
           ,[Member_ID]
           ,[Register_Date]
           ,[FirstOrderSource]
           ,[FirstOrderDate]
           ,[FirstContactDate]
           ,[Vip_Level]
           ,[Vip_Expiry_Date]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT
		wx_union_id
		,wx_open_id
		,mobile
		,null
		,null
		,null
		,cust_name
		,nick_name
		,'SCRM'
		,NULL
		,CASE WHEN gender=1 THEN 'M' ELSE 'F' END
		,birthday
		,nationality
		,province_name
		,city_name
		,area_name
		,detail_address
		,post_code
		,email
		,qq
		,1 AS 'Is_Registered'
		,'SCRM'
		,10000000 + external_member_id
		,join_date
		,null
		,null
		,join_date
		,vip_level
		,null
		,getdate(),'ODS.ods.SCRM_member_info'
		,getdate(),'ODS.ods.SCRM_member_info'
	FROM ODS.ods.SCRM_member_info 
	WHERE mobile NOT IN  (SELECT [Mobile_Phone] FROM [dm].[Dim_Customer])
	;

	--下单人和收货人手机一样的
	INSERT INTO [dm].[Dim_Customer]
           ([WX_Union_ID]
           ,[WX_Open_ID]
           ,[Mobile_Phone]
           ,[Mobile_Phone_Secondary]
           ,[First_Name]
           ,[Last_Name]
           ,[Full_Name]
           ,[Nick_Name]
           ,[Source]
           ,[Status]
           ,[Gender]
           ,[Birth_Date]
           ,[Nationality]
           ,[Province]
           ,[City]
           ,[Area]
           ,[Address]
           ,[Post_Code]
           ,[Email]
           ,[QQ]
           ,[Is_Registered]
           ,[Register_Platform]
           ,[Member_ID]
           ,[Register_Date]
           ,[FirstOrderSource]
           ,[FirstOrderDate]
           ,[FirstContactDate]
           ,[Vip_Level]
           ,[Vip_Expiry_Date]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
     
	SELECT 	--DISTINCT 
			MAX(union_id) AS [WX_Union_ID]
           ,MAX(Open_id) AS [WX_Open_ID]
           ,Buyer_Mobile AS [Mobile_Phone]
           ,NULL AS [Mobile_Phone_Secondary]
           ,NULL AS [First_Name]
           ,NULL AS [Last_Name]
           ,MAX(Receiver_Name) AS [Full_Name]
           ,MAX(Fans_Nickname) AS [Nick_Name]
           ,'Youzan' AS [Source]
           ,NULL AS [Status]
           ,NULL AS [Gender]
           ,NULL AS [Birth_Date]
           ,NULL AS [Nationality]
           ,MAX(Delivery_Province) AS [Province]
           ,MAX(Delivery_City) AS [City]
           ,MAX(Delivery_District) AS [Area]
           ,MAX(Delivery_Address) AS [Address]
           ,NULL AS [Post_Code]
           ,NULL AS [Email]
           ,NULL AS [QQ]
           ,NULL AS [Is_Registered]
           ,NULL AS [Register_Platform]
           ,NULL AS [Member_ID]
           ,NULL AS [Register_Date]
           ,'Youzan' AS [FirstOrderSource]
           ,MIN(Order_Create_Time) AS [FirstOrderDate]
           ,MIN(Order_Create_Time) AS [FirstContactDate]
           ,NULL AS [Vip_Level]
           ,NULL AS [Vip_Expiry_Date]
		   ,GETDATE(),'[dm].[Fct_O2O_Order_Base_info]'
		   ,GETDATE(),'[dm].[Fct_O2O_Order_Base_info]'
	FROM [dm].[Fct_O2O_Order_Base_info]
	WHERE Buyer_Mobile=Receiver_Mobile
	AND Receiver_Mobile NOT IN (SELECT [Mobile_Phone] FROM [dm].[Dim_Customer])
	GROUP BY Buyer_Mobile
	--ORDER BY Order_Create_Time

	--下单人和收货人手机不一样的
	INSERT INTO [dm].[Dim_Customer]
           ([WX_Union_ID]
           ,[WX_Open_ID]
           ,[Mobile_Phone]
           ,[Mobile_Phone_Secondary]
           ,[First_Name]
           ,[Last_Name]
           ,[Full_Name]
           ,[Nick_Name]
           ,[Source]
           ,[Status]
           ,[Gender]
           ,[Birth_Date]
           ,[Nationality]
           ,[Province]
           ,[City]
           ,[Area]
           ,[Address]
           ,[Post_Code]
           ,[Email]
           ,[QQ]
           ,[Is_Registered]
           ,[Register_Platform]
           ,[Member_ID]
           ,[Register_Date]
           ,[FirstOrderSource]
           ,[FirstOrderDate]
           ,[FirstContactDate]
           ,[Vip_Level]
           ,[Vip_Expiry_Date]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT
			NULL AS [WX_Union_ID]
           ,NULL AS [WX_Open_ID]
           ,Receiver_Mobile AS [Mobile_Phone]
           ,NULL AS [Mobile_Phone_Secondary]
           ,NULL AS [First_Name]
           ,NULL AS [Last_Name]
           ,MAX(Receiver_Name) AS [Full_Name]
           ,NULL AS [Nick_Name]
           ,'Youzan' AS [Source]
           ,NULL AS [Status]
           ,NULL AS [Gender]
           ,NULL AS [Birth_Date]
           ,NULL AS [Nationality]
           ,MAX(Delivery_Province) AS [Province]
           ,MAX(Delivery_City) AS [City]
           ,MAX(Delivery_District) AS [Area]
           ,MAX(Delivery_Address) AS [Address]
           ,NULL AS [Post_Code]
           ,NULL AS [Email]
           ,NULL AS [QQ]
           ,NULL AS [Is_Registered]
           ,NULL AS [Register_Platform]
           ,NULL AS [Member_ID]
           ,NULL AS [Register_Date]
           ,'Youzan' AS [FirstOrderSource]
           ,MIN(Order_Create_Time) AS [FirstOrderDate]
           ,MIN(Order_Create_Time) AS [FirstContactDate]
           ,NULL AS [Vip_Level]
           ,NULL AS [Vip_Expiry_Date]
		   ,GETDATE(),'[dm].[Fct_O2O_Order_Base_info]'
		   ,GETDATE(),'[dm].[Fct_O2O_Order_Base_info]'
	FROM [dm].[Fct_O2O_Order_Base_info] bi
	--LEFT JOIN dm.Dim_O2O_Fans f ON 
	WHERE ISNULL(Buyer_Mobile,'') <> Receiver_Mobile
	AND Receiver_Mobile NOT IN (SELECT [Mobile_Phone] FROM [dm].[Dim_Customer])
	GROUP BY Receiver_Mobile
	;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END


--SELECT *FROM [dm].[Dim_Customer] WHERE FULL_NAME LIKE '%昆%'

--select *from  [dm].[Dim_Customer] where Nick_Name like '%ak%'
--select *from  [dm].[Fct_O2O_Order_Base_info] where Fans_Nickname like '%ak%'

--select * from dm.Dim_O2O_Fans where nick_name='AK'
GO
