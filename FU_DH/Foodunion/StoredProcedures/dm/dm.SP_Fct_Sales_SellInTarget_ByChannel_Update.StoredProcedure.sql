USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_Sales_SellInTarget_ByChannel_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dm].[SP_Fct_Sales_SellInTarget_ByChannel_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	-- update  [Fct_Sales_SellInTarget]
	DELETE t
	FROM [dm].[Fct_Sales_SellInTarget_ByChannel] t
	JOIN ODS.[ods].[File_Sales_SellInTarget_ByChannel] o
	ON t.Monthkey = o.Monthkey AND ISNULL(t.[ERP_Customer_Name],'') = ISNULL(o.[ERP_Customer_Name],'')

	INSERT INTO [dm].[Fct_Sales_SellInTarget_ByChannel]
           ( [MonthKey]
			,[ERP_Customer_Name]
			,[Account_Display_Name]
			,[Channel_Short_Name]
			,[Channel_Type]
			,[Channel_Category_Name]
			,[Channel_Handler]
			,[Team]
			,[Team_Handler]
			,[Target_Amt_KRMB]
			,[Target_Vol_MT]
			,[Category_Target_Amt_KRMB]
			,[Category_Target_Vol_MT]
			,[Create_Time]
			,[Create_By]
			,[Update_Time]
			,[Update_By])
    SELECT  [MonthKey]
			,ISNULL([ERP_Customer_Name],'') AS [ERP_Customer_Name]
			,[Account_Display_Name]
			,[Channel_Short_Name]
			,[Channel_Type]
			,[Channel_Category_Name]
			,[Channel_Handler]
			,[Team]
			,[Team_Handler]
			,[Target_Amt_KRMB]
			,[Target_Vol_MT]
			,[Category_Target_Amt_KRMB]
			,[Category_Target_Vol_MT]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
	FROM ODS.[ODS].[File_Sales_SellInTarget_ByChannel] o;

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH


	END
GO
