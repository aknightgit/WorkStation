USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dm].[SP_Fct_POP6_Visit_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY	

	--User
	DELETE dm
	FROM [dm].[Dim_POP6_User] dm
	JOIN ODS.[ods].[POP6_User] ods ON dm.[User_ID]=ods.[User_ID]
	--AND ods.Load_DTM >= GETDATE()-7;

	INSERT INTO [dm].[Dim_POP6_User]
           ([User_ID]
           ,[First_Name]
           ,[Last_Name]
		   ,[Full_Name]
           ,[Username]
           ,[Email_Address]
           ,[Mobile]
           ,[Status]
		   ,[Superior_ID]
           ,[Superior]
           ,[Team_ID]
           ,[Team_Name]
           ,[Team_Status]
           ,[Region]
           ,[Business_Units_ID]
           ,[Business_Unit_Name]
           ,[Authorisation_Group_ID]
           ,[Authorisation_Group_Name]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT u1.[User_ID]
		  ,u1.[Last_Name]
		  ,u1.[First_Name]
		  ,u1.[Last_Name]+'.'+u1.[First_Name]
		  ,u1.[Username]
		  ,u1.[Email_Address]
		  ,CASE WHEN u1.[Username] LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' THEN u1.[Username] ELSE NULL END
		  --,NULL
		  --,[Longitude]
		  --,[Latitude]
		  ,CASE u1.[Status] WHEN 1 THEN 'Active' ELSE '' END
		  ,u1.[Superior_ID]
		  ,u2.[Last_Name]+'.'+u2.[First_Name]
		  ,u1.[Team_ID]
		  ,u1.[Team_Name]
		  ,CASE u1.[Team_Status] WHEN 1 THEN 'Active' ELSE '' END
		  ,NULL
		  ,u1.[Business_Units_ID]
		  ,u1.[Business_Unit_Name]
		  ,u1.[Authorisation_Group_ID]
		  ,u1.[Authorisation_Group_Name]
		  ,GETDATE(),'[dm].[SP_Fct_POP6_Visit_Update]'
		  ,GETDATE(),'[dm].[SP_Fct_POP6_Visit_Update]'
	  FROM ODS.[ods].[POP6_User] u1
	  LEFT JOIN ODS.[ods].[POP6_User] u2 ON u1.Superior_ID=u2.[User_ID];

	
	--POP Contact
	DELETE dm
	FROM dm.Fct_POP6_SalesContact dm
	JOIN ODS.[ods].[POP6_Territory] t ON dm.Pop_ID=t.Pop_ID

	INSERT INTO [dm].[Fct_POP6_SalesContact]
           ([POP_ID]
           ,[User_ID]
           ,[Contact_ID]
           ,[Contact_Name]
           ,[Contact_Mobile]
           ,[Contact_Title]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT t.POP_ID,
		t.[User_ID],
		c.Contact_ID,
		c.First_Name+c.Last_Name,
		c.Mobile,
		c.Job_Title,
		GETDATE(),'[dm].[SP_Fct_POP6_Visit_Update]',
		GETDATE(),'[dm].[SP_Fct_POP6_Visit_Update]'
	FROM ODS.[ods].[POP6_Territory] t
	LEFT JOIN ODS.[ods].[POP6_Contact] c ON t.POP_ID=c.POP_ID
	;



	--Vist
	DELETE dm
	FROM [dm].[Fct_POP6_Visit] dm
	JOIN ODS.[ods].[POP6_Visit] ods ON dm.[Visit_ID]=ods.[Visit_ID]
	AND ods.Load_DTM >= GETDATE()-7;

	INSERT INTO [dm].[Fct_POP6_Visit]
           ([Visit_ID]
           ,[Visit_Date]
		   ,[DateKey]
           ,[POP_ID]
           ,[User_ID]
           ,[Visit_Type]
           ,[Check_In_Date_Time]
           ,[Check_In_Longitude]
           ,[Check_In_Latitude]
           ,[Check_In_Photo]
           ,[Check_Out_Date_Time]
           ,[Check_Out_Longitude]
           ,[Check_Out_Latitude]
           ,[Check_Out_Photo]
           ,[Planned_Visit]
           ,[Cancelled_Visit]
           ,[Cancellation_Reason]
           ,[Cancellation_Note]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
	SELECT 
		  [Visit_ID]
		  ,[Visit_Date]
		  ,CONVERT(VARCHAR(8),[Visit_Date],112)
		  ,[POP_ID]
		  ,[User_ID]
		  ,CASE [Visit_Type] WHEN 1 THEN '' END 
		  ,[Check_In_Date_Time]
		  ,[Check_In_Longitude]
		  ,[Check_In_Latitude]
		  ,[Check_In_Photo]
		  ,[Check_Out_Date_Time]
		  ,[Check_Out_Longitude]
		  ,[Check_Out_Latitude]
		  ,[Check_Out_Photo]
		  ,[Planned_Visit]
		  ,[Cancelled_Visit]
		  ,[Cancellation_Reason]
		  ,[Cancellation_Note]
		  ,GETDATE(),'[dm].[SP_Fct_POP6_Visit_Update]'
		  ,GETDATE(),'[dm].[SP_Fct_POP6_Visit_Update]'
	  FROM ODS.[ods].[POP6_Visit]
	  WHERE Load_DTM >= GETDATE()-7;
		

	
	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

	END
GO
