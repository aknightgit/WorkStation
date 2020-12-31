USE [Foodunion]
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
		SELECT DISTINCT 
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
		--WHERE Customer_Name NOT IN (SELECT ISNULL(ERP_Customer_Name,'') FROM dm.Dim_Channel)
		WHERE Customer_ID NOT IN (SELECT ISNULL(ERP_Customer_ID,'') FROM dm.Dim_Channel)
		AND Customer_Name NOT IN (SELECT ISNULL(ERP_Customer_Name,'') FROM dm.Dim_Channel)
		AND Customer_Name IN (SELECT distinct ISNULL(Customer_Name,'') FROM dm.Fct_ERP_Sale_Order)
		AND IsActive=1;  --Justin  20200528
		--AND Customer_Name ='上海谋熠商贸有限公司';
		
		
		UPDATE dc
		--SELECT *
		 SET dc.Channel_Name=ec.Customer_Name
		 ,dc.Channel_Name_CN=ec.Customer_Name
		 ,dc.ERP_Customer_Name=ec.Customer_Name
		 ,dc.Channel_Name_Short=ec.Short_Name
		 ,dc.Update_Time = getdate()
		FROM dm.Dim_Channel dc 
		JOIN dm.Dim_ERP_CustomerList ec ON dc.ERP_Customer_ID=ec.Customer_ID
		WHERE dc.ERP_Customer_Name<>ec.Customer_Name;

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
			   A.Update_By='[ods].[File_CP_ManagerTarget]',
		       Update_Time=getdate()
		FROM [dm].[Dim_Channel] A
		LEFT JOIN [dm].[Dim_ERP_CustomerList] C
		ON A.ERP_Customer_Name=C.Customer_Name
		JOIN [ODS].[ods].[File_CP_ManagerTarget] CP  
		ON  C.ERP_Code=CP.[ERP_Customer_Code] AND cp.MonthKey= CONVERT(VARCHAR(6),GETDATE(),112)
		WHERE A.Channel_Type='Distributor'


		--更新Channel表Finance渠道分组
		UPDATE A SET A.Channel_FIN=F.[CHANNEL],
	           A.SubChannel_FIN=F.[SUBCHANNEL],
			   A.Update_By='[ods].[File_Customer_Mapping_Fin]',
			   A.Update_Time=GETDATE()
		FROM [dm].[Dim_Channel] A
		LEFT JOIN [ODS].[ods].[File_Customer_Mapping_Fin] F
		ON A.ERP_Customer_Name=F.[CUS_NAME] 
		WHERE  ISNULL(A.Channel_FIN,'')<>F.[CHANNEL] OR ISNULL(A.SubChannel_FIN,'')<>F.[SUBCHANNEL];


		UPDATE C SET C.[Region]= CASE WHEN CP.Region_Name_CN='中区&上海' THEN '中沪' ELSE CP.Region_Name_CN END
		FROM [dm].[Dim_Channel] C
		LEFT JOIN (
		SELECT * FROM ods.[ods].[File_CP_ManagerTarget] 
        WHERE MonthKey=(SELECT MAX(MonthKey) FROM ods.[ods].[File_CP_ManagerTarget] )) CP
		ON C.[ERP_Customer_Name]=CP.[ERP_Customer_Name]
		WHERE C.[SubChannel_FIN]='Distributor' AND C.[Region] IS NULL ;


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

		--更新hist表中的customer名字
		UPDATE h
		set h.ERP_Customer_Name=c.ERP_Customer_Name
			,h.Channel_Name=c.Channel_Name
			,h.Channel_Name_CN=c.Channel_Name_CN
			,h.Channel_Name_Display=c.Channel_Name_Display
		FROM [dm].[Dim_Channel_hist] h
		JOIN dm.Dim_Channel c on h.Channel_ID=c.Channel_ID
		WHERE h.ERP_Customer_Name<>c.ERP_Customer_Name
		AND h.Monthkey >= CONVERT(VARCHAR(6),DATEADD(MONTH,-1,GETDATE()),112);
        
		UPDATE h
		set h.ERP_Customer_ID=c.ERP_Customer_ID			 
		FROM [dm].[Dim_Channel_hist] h
		JOIN dm.Dim_Channel c on h.ERP_Customer_Name=c.ERP_Customer_Name;    --根据ERP_Customer_Name用最新channel 表中 ERP_Customer_ID 更新channel history 的ERP_Customer_ID  --2020-04-30
		

		

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
		ON A.Datekey/100=C.Monthkey --AND C.[ERP_Customer_Name]=B.[ERP_Customer_Name] 
		AND C.ERP_Customer_ID=B.ERP_Customer_ID
		AND C.Channel_ID=B.[Channel_ID] --AND C.[Channel_Name]=B.[Channel_Name]
		WHERE 
		--A.Datekey<convert(varchar(10),B.Create_Time,112) AND 
		C.[ERP_Customer_Name] IS NULL ;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
