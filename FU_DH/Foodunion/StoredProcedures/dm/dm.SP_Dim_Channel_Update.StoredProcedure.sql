USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Dim_Channel_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dm].[SP_Dim_Channel_Update]
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
		WHERE Customer_Name NOT IN (SELECT ERP_Customer_Name FROM dm.Dim_Channel)
		AND Customer_Name IN (SELECT distinct Customer_Name FROM dm.Fct_ERP_Sale_Order);

		--每月备份渠道映射信息
		DELETE FROM [dm].[Dim_Channel_hist] WHERE Monthkey=CONVERT(VARCHAR(6),GETDATE(),112);
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
		  FROM [dm].[Dim_Channel];



	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
