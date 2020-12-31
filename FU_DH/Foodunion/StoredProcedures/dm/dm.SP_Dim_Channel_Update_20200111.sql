USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dm].[SP_Dim_Channel_Update_20200111]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY
		
		--[dm].[Dim_ERP_CustomerList]
		INSERT INTO [dm].[Dim_Channel]
           ([Channel_Name]
           ,[Channel_Name_CN]
           ,[ERP_Customer_ID]
           ,[ERP_Customer_Name]
           ,[Channel_Name_Display]
           ,[Channel_Name_Short]
           ,[Channel_Type]
           ,[Channel_Category]
           ,[Channel_Handler]
           ,[Team]
           ,[Team_Handler]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
		SELECT 
			--TOP 1070 *
			list.Customer_Name_EN
			,list.Customer_Name
			,list.Customer_ID
			,list.Customer_Name
			,list.Customer_Name
			,list.Short_Name
			,null
			,null
			,null
			,null
			,null
			,getdate(),'dm.Dim_ERP_CustomerList'
			,getdate(),'dm.Dim_ERP_CustomerList'
		FROM dm.Dim_ERP_CustomerList list
		WHERE Customer_Name NOT IN (SELECT ISNULL(ERP_Customer_Name,'') FROM dm.Dim_Channel)
		AND Customer_Name IN (SELECT distinct ISNULL(Customer_Name,'') FROM dm.Fct_ERP_Sale_Order);

		--更新CP渠道的省份、大区归属
		--UPDATE c
		--SET c.Channel_Handler=m.Leader,
		--	c.Channel_Category='CP - '+m.SalesTerritory_EN,
		--	Update_Time=getdate()
		--FROM [dm].[Dim_Channel] c
		--JOIN [dm].[Dim_SalesTerritoryMapping] m ON c.Province=m.Province_Short AND c.Channel_Type='CP'
		--WHERE c.Channel_Handler<>m.Leader
		--OR c.Channel_Category<>'CP - '+m.SalesTerritory_EN
	

		UPDATE A SET A.Channel_Category=CP.[Region_Name_EN],
	           A.Channel_Handler=CP.[CP_Manager],
		       Update_Time=getdate()
		FROM [dm].[Dim_Channel] A
		LEFT JOIN [dm].[Dim_ERP_CustomerList] C
		ON A.ERP_Customer_Name=C.Customer_Name
		JOIN [ODS].[ods].[File_CP_ManagerTarget] CP
		ON  C.ERP_Code=CP.[ERP_Customer_Code]
		WHERE A.Channel_Type='CP'



		--每月备份渠道映射信息,且预先插入下个月数据
		DELETE FROM [dm].[Dim_Channel_hist] WHERE Monthkey>=CONVERT(VARCHAR(6),GETDATE(),112);
		INSERT INTO [dm].[Dim_Channel_hist]
           ([Monthkey]
		   ,[Channel_ID]
           ,[Channel_Name]
           ,[Channel_Name_CN]
           ,[ERP_Customer_ID]
           ,[ERP_Customer_Name]
           ,[Channel_Name_Display]
           ,[Channel_Name_Short]
           ,[Channel_Type]
           ,[Channel_Category]
           ,[Channel_Handler]
           ,[Team]
           ,[Team_Handler]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
		SELECT CONVERT(VARCHAR(6),GETDATE(),112)
			,[Channel_ID]
			,[Channel_Name]
			,[Channel_Name_CN]
			,[ERP_Customer_ID]
			,[ERP_Customer_Name]
			,[Channel_Name_Display]
			,[Channel_Name_Short]
			,[Channel_Type]
			,[Channel_Category]
			,[Channel_Handler]
			,[Team]
			,[Team_Handler]
			,[Create_Time]
			,[Create_By]
			,[Update_Time]
			,[Update_By]
		FROM [dm].[Dim_Channel]
		UNION 
		SELECT CONVERT(VARCHAR(6),DATEADD(MONTH,1,GETDATE()),112)
			,[Channel_ID]
			,[Channel_Name]
			,[Channel_Name_CN]
			,[ERP_Customer_ID]
			,[ERP_Customer_Name]
			,[Channel_Name_Display]
			,[Channel_Name_Short]
			,[Channel_Type]
			,[Channel_Category]
			,[Channel_Handler]
			,[Team]
			,[Team_Handler]
			,[Create_Time]
			,[Create_By]
			,[Update_Time]
			,[Update_By]
		FROM [dm].[Dim_Channel];;


	---- 新建过往历史月份的补单             Justin 2019-12-25
		INSERT INTO [dm].[Dim_Channel_hist]
           ([Monthkey]
		   ,[Channel_ID]
           ,[Channel_Name]
           ,[Channel_Name_CN]
           ,[ERP_Customer_ID]
           ,[ERP_Customer_Name]
           ,[Channel_Name_Display]
           ,[Channel_Name_Short]
           ,[Channel_Type]
           ,[Channel_Category]
           ,[Channel_Handler]
           ,[Team]
           ,[Team_Handler]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
		SELECT DISTINCT LEFT(A.Datekey,6) AS [Monthkey]
			  ,B.[Channel_ID]
			  ,B.[Channel_Name]
			  ,B.[Channel_Name_CN]
			  ,B.[ERP_Customer_ID]
			  ,B.[ERP_Customer_Name]
			  ,B.[Channel_Name_Display]
			  ,B.[Channel_Name_Short]
			  ,B.[Channel_Type]
			  ,B.[Channel_Category]
			  ,B.[Channel_Handler]
			  ,B.[Team]
			  ,B.[Team_Handler]
			  ,GETDATE() AS [Create_Time]
			  ,'[dm].[SP_Dim_Channel_Update]'[Create_By]
			  ,GETDATE() AS [Update_Time]
			  ,'[dm].[SP_Dim_Channel_Update]'[Update_By]
		FROM dm.Fct_ERP_Sale_Order A
		LEFT JOIN [dm].[Dim_Channel] B
		ON A.Customer_Name=B.ERP_Customer_Name
		LEFT JOIN [dm].[Dim_Channel_hist] C
		ON A.Datekey/100=C.Monthkey AND C.[ERP_Customer_Name]=B.[ERP_Customer_Name] AND C.Channel_ID=B.[Channel_ID] --AND C.[Channel_Name]=B.[Channel_Name]
		WHERE A.Datekey<convert(varchar(10),B.Create_Time,112) AND C.[ERP_Customer_Name] IS NULL ;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
