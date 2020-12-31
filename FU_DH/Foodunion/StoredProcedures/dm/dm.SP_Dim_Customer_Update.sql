USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dm].[SP_Dim_Customer_Update]
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
           ,[Mobile_Phone_2]
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
           ,[ZipCode]
           ,[Email]
           ,[QQ]
           ,[Is_Registered]
           ,[Register_Platform]
           ,[Platform_Member_ID]
           ,[Register_Date]
           ,[FirstOrderPlatform]
           ,[FirstOrderDate]
           ,[FirstContactDate]
		   ,[Comments]
           ,[Vip_Level]
           ,[Vip_Expiry_Date]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT
		wx_union_id
		,wx_open_id
		,[dbo].[GET_NUMBER](replace(mobile,'86-','')) AS mobile
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
		,10000000 + external_Member_ID
		,join_date
		,null
		,null
		,join_date
		,'SRCM Register'
		,vip_level
		,null
		,getdate(),'ODS.ods.SCRM_member_info'
		,getdate(),'ODS.ods.SCRM_member_info'
	FROM ODS.ods.SCRM_member_info 
	WHERE [dbo].[GET_NUMBER](replace(mobile,'86-','')) NOT IN  (SELECT [Mobile_Phone] FROM [dm].[Dim_Customer])
	;

	--Youzan订单：下单人和收货人手机一样的
	INSERT INTO [dm].[Dim_Customer]
           ([WX_Union_ID]
           ,[WX_Open_ID]
           ,[Mobile_Phone]
           ,[Mobile_Phone_2]
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
           ,[ZipCode]
           ,[Email]
           ,[QQ]
           ,[Is_Registered]
           ,[Register_Platform]
           ,[Platform_Member_ID]
           ,[Register_Date]
           ,[FirstOrderPlatform]
           ,[FirstOrderDate]
           ,[FirstContactDate]
		   ,[Comments]
           ,[Vip_Level]
           ,[Vip_Expiry_Date]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
     
	SELECT 	--DISTINCT 
			MAX(union_id) AS [WX_Union_ID]
           ,MAX(Open_id) AS [WX_Open_ID]         
		   ,[dbo].[GET_NUMBER](replace(Buyer_Mobile,'86-','')) AS   [Mobile_Phone]
           ,NULL AS [Mobile_Phone_2]
           ,NULL AS [First_Name]
           ,NULL AS [Last_Name]
           ,MAX(Receiver_Name) AS [Full_Name]
           ,MAX(Fans_Nickname) AS [Nick_Name]
           ,'有赞商城' AS [Source]
           ,NULL AS [Status]
           ,NULL AS [Gender]
           ,NULL AS [Birth_Date]
           ,NULL AS [Nationality]
           ,MAX(Delivery_Province) AS [Province]
           ,MAX(Delivery_City) AS [City]
           ,MAX(Delivery_District) AS [Area]
           ,MAX(Delivery_Address) AS [Address]
           ,NULL AS [ZipCode]
           ,NULL AS [Email]
           ,NULL AS [QQ]
           ,NULL AS [Is_Registered]
           ,NULL AS [Register_Platform]
           ,NULL AS [Platform_Member_ID]
           ,NULL AS [Register_Date]
           ,'有赞商城' AS [FirstOrderPlatform]
           ,MIN(Order_Create_Time) AS [FirstOrderDate]
           ,MIN(Order_Create_Time) AS [FirstContactDate]
		   ,'有赞 Order Buyer'
           ,NULL AS [Vip_Level]
           ,NULL AS [Vip_Expiry_Date]
		   ,GETDATE(),'[dm].[Fct_O2O_Order_Base_info]'
		   ,GETDATE(),'[dm].[Fct_O2O_Order_Base_info]'
	FROM [dm].[Fct_O2O_Order_Base_info]
	WHERE Buyer_Mobile=Receiver_Mobile
	AND [dbo].[GET_NUMBER](replace(Buyer_Mobile,'86-','')) NOT IN (SELECT [Mobile_Phone] FROM [dm].[Dim_Customer])
	GROUP BY Buyer_Mobile
	--ORDER BY Order_Create_Time

	--有赞订单：下单人和收货人手机不一样的
	INSERT INTO [dm].[Dim_Customer]
           ([WX_Union_ID]
           ,[WX_Open_ID]
           ,[Mobile_Phone]
           ,[Mobile_Phone_2]
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
           ,[ZipCode]
           ,[Email]
           ,[QQ]
           ,[Is_Registered]
           ,[Register_Platform]
           ,[Platform_Member_ID]
           ,[Register_Date]
           ,[FirstOrderPlatform]
           ,[FirstOrderDate]
           ,[FirstContactDate]
		   ,[Comments]
           ,[Vip_Level]
           ,[Vip_Expiry_Date]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT
			NULL AS [WX_Union_ID]
           ,NULL AS [WX_Open_ID]
           ,[dbo].[GET_NUMBER](replace(Receiver_Mobile,'86-','')) AS [Mobile_Phone]
           ,NULL AS [Mobile_Phone_2]
           ,NULL AS [First_Name]
           ,NULL AS [Last_Name]
           ,MAX(Receiver_Name) AS [Full_Name]
           ,NULL AS [Nick_Name]
           ,'有赞商城' AS [Source]
           ,NULL AS [Status]
           ,NULL AS [Gender]
           ,NULL AS [Birth_Date]
           ,NULL AS [Nationality]
           ,MAX(Delivery_Province) AS [Province]
           ,MAX(Delivery_City) AS [City]
           ,MAX(Delivery_District) AS [Area]
           ,MAX(Delivery_Address) AS [Address]
           ,NULL AS [ZipCode]
           ,NULL AS [Email]
           ,NULL AS [QQ]
           ,NULL AS [Is_Registered]
           ,NULL AS [Register_Platform]
           ,NULL AS [Platform_Member_ID]
           ,NULL AS [Register_Date]
           ,'有赞商城' AS [FirstOrderPlatform]
           ,MIN(Order_Create_Time) AS [FirstOrderDate]
           ,MIN(Order_Create_Time) AS [FirstContactDate]
		   ,'有赞 Order Receiver'
           ,NULL AS [Vip_Level]
           ,NULL AS [Vip_Expiry_Date]
		   ,GETDATE(),'[dm].[Fct_O2O_Order_Base_info]'
		   ,GETDATE(),'[dm].[Fct_O2O_Order_Base_info]'
	FROM [dm].[Fct_O2O_Order_Base_info] bi
	--LEFT JOIN dm.Dim_O2O_Fans f ON 
	WHERE ISNULL(Buyer_Mobile,'') <> Receiver_Mobile
	AND [dbo].[GET_NUMBER](replace(Receiver_Mobile,'86-','')) NOT IN (SELECT [Mobile_Phone] FROM [dm].[Dim_Customer])
	GROUP BY Receiver_Mobile
	;
	/****************************************  新增从Fct_Order中导入用户信息到dm.Dim_Customer中    Justin 2020-02-14********************************/
    --FCT_Order 下单人和收货人一样的
	INSERT INTO [dm].[Dim_Customer]
           ([WX_Union_ID]
           ,[WX_Open_ID]
           ,[Mobile_Phone]
           ,[Mobile_Phone_2]
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
           ,[ZipCode]
           ,[Email]
           ,[QQ]
           ,[Is_Registered]
           ,[Register_Platform]
           ,[Platform_Member_ID]
           ,[Register_Date]
           ,[FirstOrderPlatform]
           ,[FirstOrderDate]
           ,[FirstContactDate]
		   ,[Comments]
           ,[Vip_Level]
           ,[Vip_Expiry_Date]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	    SELECT
			NULL AS [WX_Union_ID]
           ,NULL AS [WX_Open_ID]
           --,Receiver_Mobile AS [Mobile_Phone]
		   ,SUBSTRING(Receiver_Mobile,CHARINDEX('1',Receiver_Mobile),11) AS Mobile_Phone   --手机号存在空字符   Justin 2020-05-17
           ,NULL AS [Mobile_Phone_2]
           ,NULL AS [First_Name]
           ,NULL AS [Last_Name]
           ,MAX([Receiver_Name]) AS [Full_Name]
           ,MAX([Buyer_Nick]) AS [Nick_Name]
           ,MAX(C.Channel_Name_Short) AS [Source]
           ,NULL AS [Status]
           ,NULL AS [Gender]
           ,NULL AS [Birth_Date]
           ,NULL AS [Nationality]
           ,MAX([Receiver_Province]) AS [Province]
           ,MAX([Receiver_City]) AS [City]
           ,MAX([Receiver_Area]) AS [Area]
           ,MAX([Receiver_Address]) AS [Address]
           ,NULL AS [ZipCode]
           ,NULL AS [Email]
           ,NULL AS [QQ]
           ,NULL AS [Is_Registered]
           ,NULL AS [Register_Platform]
           ,NULL AS [Platform_Member_ID]
           ,NULL AS [Register_Date]
           ,MAX(C.Channel_Name_Short) AS [FirstOrderPlatform]
           ,MIN([Order_CreateTime]) AS [FirstOrderDate]
           ,MIN([Order_CreateTime]) AS [FirstContactDate]
		   ,MAX(C.Channel_Name_Short) +' Order Buyer'
           ,NULL AS [Vip_Level]
           ,NULL AS [Vip_Expiry_Date]
		   ,GETDATE(),'[dm].[Fct_Order]'
		   ,GETDATE(),'[dm].[Fct_Order]'
	FROM [dm].[Fct_Order] O WITH(NOLOCK)
    LEFT JOIN [dm].[Dim_Channel] C WITH(NOLOCK)
		ON O.Channel_ID=C.Channel_ID
	LEFT JOIN [dm].[Dim_Customer] cs WITH(NOLOCK)
		ON SUBSTRING(Receiver_Mobile,CHARINDEX('1',Receiver_Mobile),11) = cs.Mobile_Phone
	WHERE [Order_CreateTime]>='2019-09-01' 
		AND [Is_Cancelled] = 0
		AND (ISNULL([Buyer_Mobile],'') = [Receiver_Mobile] OR O.Buyer_Nick=O.Receiver_Name)
		AND cs.Mobile_Phone IS NULL
		--AND Receiver_Mobile NOT IN (SELECT [Mobile_Phone] FROM [dm].[Dim_Customer] WITH(NOLOCK))
	GROUP BY Receiver_Mobile

   --FCT_Order 下单人和收货人不一样的
	INSERT INTO [dm].[Dim_Customer]
           ([WX_Union_ID]
           ,[WX_Open_ID]
           ,[Mobile_Phone]
           ,[Mobile_Phone_2]
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
           ,[ZipCode]
           ,[Email]
           ,[QQ]
           ,[Is_Registered]
           ,[Register_Platform]
           ,[Platform_Member_ID]
           ,[Register_Date]
           ,[FirstOrderPlatform]
           ,[FirstOrderDate]
           ,[FirstContactDate]
		   ,[Comments]
           ,[Vip_Level]
           ,[Vip_Expiry_Date]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
  SELECT
			NULL AS [WX_Union_ID]
           ,NULL AS [WX_Open_ID]
           ,CASE WHEN LEN(Receiver_Mobile)>20 THEN LEFT([dbo].[GET_NUMBER](replace(Receiver_Mobile,'86-','')) ,11) ELSE [dbo].[GET_NUMBER](replace(Receiver_Mobile,'86-','')) END AS [Mobile_Phone]
           ,CASE WHEN LEN(Receiver_Mobile)>20 THEN RIGHT([dbo].[GET_NUMBER](replace(Receiver_Mobile,'86-','')) ,11) ELSE  NULL END AS [Mobile_Phone_2]
           ,NULL AS [First_Name]
           ,NULL AS [Last_Name]
           ,MAX([Receiver_Name]) AS [Full_Name]
           ,MAX([Buyer_Nick]) AS [Nick_Name]
           ,MAX(C.Channel_Name_Short) AS [Source]
           ,NULL AS [Status]
           ,NULL AS [Gender]
           ,NULL AS [Birth_Date]
           ,NULL AS [Nationality]
           ,MAX([Receiver_Province]) AS [Province]
           ,MAX([Receiver_City]) AS [City]
           ,MAX([Receiver_Area]) AS [Area]
           ,MAX([Receiver_Address]) AS [Address]
           ,NULL AS [ZipCode]
           ,NULL AS [Email]
           ,NULL AS [QQ]
           ,NULL AS [Is_Registered]
           ,NULL AS [Register_Platform]
           ,NULL AS [Platform_Member_ID]
           ,NULL AS [Register_Date]
           ,MAX(C.Channel_Name_Short) AS [FirstOrderPlatform]
           ,MIN([Order_CreateTime]) AS [FirstOrderDate]
           ,MIN([Order_CreateTime]) AS [FirstContactDate]
		   ,MAX(C.Channel_Name_Short) +' Order Receiver'
           ,NULL AS [Vip_Level]
           ,NULL AS [Vip_Expiry_Date]
		   ,GETDATE(),'[dm].[Fct_Order]'
		   ,GETDATE(),'[dm].[Fct_Order]'
	FROM [dm].[Fct_Order] O WITH(NOLOCK)
	LEFT JOIN [dm].[Dim_Channel] C WITH(NOLOCK)
		ON O.Channel_ID=C.Channel_ID
	LEFT JOIN [dm].[Dim_Customer] cs WITH(NOLOCK)
		ON (LEFT([dbo].[GET_NUMBER](replace(Receiver_Mobile,'86-','')),11) = cs.Mobile_Phone
		OR [dbo].[GET_NUMBER](replace(Receiver_Mobile,'86-','')) = cs.Mobile_Phone )
	WHERE [Order_CreateTime]>='2019-09-01' 
		AND [Is_Cancelled] = 0
		AND (ISNULL([Buyer_Mobile],'') <> [Receiver_Mobile] AND O.Buyer_Nick<>O.Receiver_Name)
		AND cs.Mobile_Phone IS NULL
	GROUP BY Receiver_Mobile ;

	--更新Super_ID到Fct_Order中
	UPDATE o
	SET o.Super_ID=c.super_id
	from dm.Fct_Order o 
	join dm.Dim_Customer c on ISNULL(o.Buyer_Mobile,o.Receiver_Mobile)=c.Mobile_Phone
	where o.Super_ID<>c.Super_ID
/****************************************  新增从Fct_Order中导入用户信息到dm.Dim_Customer中    Justin 2020-02-14********************************/


/*************************  更新 dm.Dim_Customer中FirstOrderDate，FirstOrderPlatform，FirstContactDate，LastOrderDate，LastOrderPlatform，TotalOrderCnt    Justin 2020-02-14********************************/
  --更新FirstOrderDate，FirstOrderPlatform，FirstContactDate
    --Youzan
	UPDATE A SET A.[FirstOrderDate]=B.[FirstOrderDate]
		,A.FirstContactDate=B.FirstOrderDate
		,A.FirstOrderPlatform=B.FirstOrderPlatform
	FROM [dm].[Dim_Customer] A 
	JOIN
	(SELECT  Receiver_Mobile AS [Mobile_Phone]       
		,'有赞商城' AS [FirstOrderPlatform]
		,MIN(Order_Create_Time) AS [FirstOrderDate]		 
	FROM [dm].[Fct_O2O_Order_Base_info]
	GROUP BY Receiver_Mobile) B
	ON A.Mobile_Phone=B.Mobile_Phone AND ISNULL(A.FirstOrderDate,'9999-01-01')>B.FirstOrderDate;

	--更新FirstOrderDate，FirstOrderPlatform，FirstContactDate
    --FCT ORDER
	UPDATE A SET A.[FirstOrderDate]=B.[FirstOrderDate]
		,A.FirstContactDate=B.FirstOrderDate
		,A.FirstOrderPlatform=B.FirstOrderPlatform
	FROM [dm].[Dim_Customer] A 
	JOIN
	(SELECT [Mobile_Phone],[FirstOrderPlatform],[FirstOrderDate] FROM (
       SELECT Receiver_Mobile AS [Mobile_Phone]
         ,C.Channel_Name_Short AS [FirstOrderPlatform]
         ,[Order_CreateTime] AS [FirstOrderDate]	
		 ,ROW_NUMBER()OVER(PARTITION BY Receiver_Mobile ORDER BY [Order_CreateTime]) RN
	FROM [dm].[Fct_Order] O
    LEFT JOIN [dm].[Dim_Channel] C
    ON O.Channel_ID=C.Channel_ID
	WHERE [Order_CreateTime]>='2019-09-01' AND [Is_Cancelled]<>1 ) T
	WHERE RN=1) B
	ON A.Mobile_Phone=B.Mobile_Phone AND ISNULL(A.FirstOrderDate,'9999-01-01')>B.FirstOrderDate;

	--更新LastOrderDate，LastOrderPlatform 
    --Youzan
	UPDATE A SET A.[LastOrderDate]=B.[LastOrderDate]
		,A.LastOrderPlatform=B.LastOrderPlatform
	FROM [dm].[Dim_Customer] A 
	JOIN
	(SELECT  Receiver_Mobile AS [Mobile_Phone]       
		,'有赞商城' AS LastOrderPlatform
		,MAX(Order_Create_Time) AS [LastOrderDate]		 
	FROM [dm].[Fct_O2O_Order_Base_info]
	GROUP BY Receiver_Mobile
	) B
	ON A.Mobile_Phone=B.Mobile_Phone 
	WHERE ISNULL(A.[LastOrderDate],'1990-01-01')<B.[LastOrderDate];

	--更新LastOrderDate，LastOrderPlatform 
    --FCT ORDER
	UPDATE A SET A.[LastOrderDate]=B.[LastOrderDate]
		,A.LastOrderPlatform=B.LastOrderPlatform
	FROM [dm].[Dim_Customer] A 
	JOIN
	(SELECT [Mobile_Phone],LastOrderPlatform,[LastOrderDate] FROM (
       SELECT Receiver_Mobile AS [Mobile_Phone]
         ,C.Channel_Name_Short AS LastOrderPlatform
         ,[Order_CreateTime] AS [LastOrderDate]	
		 ,ROW_NUMBER()OVER(PARTITION BY Receiver_Mobile ORDER BY [Order_CreateTime] DESC) RN
	FROM [dm].[Fct_Order] O
    LEFT JOIN [dm].[Dim_Channel] C
    ON O.Channel_ID=C.Channel_ID
	WHERE [Order_CreateTime]>='2019-09-01' AND [Is_Cancelled]<>1 ) T
	WHERE RN=1) B
	ON A.Mobile_Phone=B.Mobile_Phone 
	WHERE ISNULL(A.[LastOrderDate],'1990-01-01')<B.[LastOrderDate] ;

	--更新[TotalOrderCnt]
    
	UPDATE A 
	SET A.[TotalOrderCnt]=B.[TotalOrderCnt]
	FROM [dm].[Dim_Customer] A 
	JOIN
	(SELECT Receiver_Mobile AS Mobile_Phone,COUNT(DISTINCT Order_No) AS [TotalOrderCnt] FROM(
		SELECT ISNULL(Buyer_Mobile, Receiver_Mobile) Receiver_Mobile,Order_No FROM [dm].[Fct_O2O_Order_Base_info]
		UNION
		SELECT ISNULL(Buyer_Mobile, Receiver_Mobile) Receiver_Mobile,Trans_No FROM [dm].[Fct_Order]
		WHERE [Order_CreateTime]>='2019-09-01' AND [Is_Cancelled]<>1
		) T
	GROUP BY Receiver_Mobile) B
	ON A.Mobile_Phone=B.Mobile_Phone 
	WHERE A.[TotalOrderCnt]<>B.[TotalOrderCnt] OR A.[TotalOrderCnt] IS NULL;

/*************************  更新 dm.Dim_Customer中FirstOrderDate，FirstOrderPlatform，FirstContactDate，LastOrderDate，LastOrderPlatform，TotalOrderCnt    Justin 2020-02-14********************************/

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
