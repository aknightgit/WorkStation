USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dm].[SP_Fct_Youzan_Revenue_Details]
AS
BEGIN		
DECLARE @errmsg nvarchar(max),
	@DatabaseName varchar(100) = DB_NAME(),
	@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY

TRUNCATE TABLE [dm].[Fct_Youzan_Revenue_Details]

INSERT INTO [dm].[Fct_Youzan_Revenue_Details]
   ([Revenue_Type]
   ,[Revenue_Name]
   ,[Order_No]
   ,[Serial_No]
   ,[Linked_Order_No]
   ,[Source_of_transaction]
   ,[Accounting_body]
   ,[Accounting]
   ,[Income_Amount]
   ,[Pay_Amount]
   ,[Balance_Amount]
   ,[Payment_method]
   ,[Counterparty]
   ,[Channel]
   ,[Order_Create_Time]
   ,[Revenue_Time]
   ,[Operator]
   ,[Additional_Info]
   ,[Remark]
   ,[Create_Time]
   ,[Create_By]
   ,[Update_Time]
   ,[Update_By])
SELECT [Revenue_Type]
      ,[Revenue_Name]
      ,[Order_No]
      ,[Serial_No]
      ,[Linked_Order_No]
      ,[Source_of_transaction]
      ,[Accounting_body]
      ,[Accounting]
      ,[Income_Amount]
      ,[Pay_Amount]
      ,[Balance_Amount]
      ,[Payment_method]
      ,[Counterparty]
      ,[Channel]
      ,[Order_Create_Time]
      ,[Revenue_Time]
      ,[Operator]
      ,[Additional_Info]
      ,[Remark]
      ,GETDATE()
	  ,@ProcName
	  ,GETDATE()
	  ,@ProcName
FROM ODS.[ods].[File_Youzan_Revenue_Details]
WHERE [Revenue_Type] IN ('订单入账','退款')

END TRY
BEGIN CATCH

	SELECT @errmsg =  ERROR_MESSAGE();

	EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

	RAISERROR(@errmsg,16,1);

END CATCH

END
GO
