USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dm].[SP_Fct_Sales_SellInTarget_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	-- update  [Fct_Sales_SellInTarget]
	DELETE t
	FROM [dm].[Fct_Sales_SellInTarget] t
	JOIN ODS.[ods].[File_Sales_SellInTarget] o
	ON t.Monthkey = o.Monthkey;

	INSERT INTO [dm].[Fct_Sales_SellInTarget]
           ([Monthkey]
		   ,[Channel]
		   ,[Region]
           ,[Customer_Name]
           ,[Account_Display_Name]
           ,[Target_Amount]
           ,[Target_Volumn_MT]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By])
    SELECT  [Monthkey]
			,UPPER([Channel])
		   ,[Region]
           ,isnull([Customer_Name],'')
           ,[Customer_Account_Display]
           ,isnull([Target_Amount],0)
           ,isnull([Target_Volumn_MT],0)
			,GETDATE()
			,'[ods].[File_Sales_SellInTarget]'
			,GETDATE()
			,@ProcName
	FROM ODS.[ODS].[File_Sales_SellInTarget] o;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH


	END
GO
