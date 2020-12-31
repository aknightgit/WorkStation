USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Fct_YH_BM_Promotion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE  [dm].[SP_Fct_YH_BM_Promotion]
AS
BEGIN 

 DECLARE @errmsg nvarchar(max),
 @DatabaseName varchar(100) = DB_NAME(),
 @ProcName varchar(100) = OBJECT_NAME(@@PROCID);

 BEGIN TRY

  TRUNCATE TABLE [dm].[Fct_YH_BM_Promotion]
   
   INSERT INTO [dm].[Fct_YH_BM_Promotion](
	   [Supplier_ID]
      ,[Supplier_NM]
      ,[SKU_ID]
      ,[Bar_CD]
      ,[SKU_NM]
      ,[Unit]
      ,[Big_class_CD]
      ,[Big_class_NM]
      ,[Mid_Class_CD]
      ,[Mid_Class_NM]
      ,[Sales_AMT]
      ,[Activity]
      ,[Activity_Date]
      ,[Region]
      ,[Start_Date]
      ,[End_Date]
      ,[Type]
      ,[Promotition]
	  ,[Create_Time]
	  ,[Create_By]
	  ,[Update_Time]
	  ,[Update_By]
   )
   SELECT [Supplier_ID]
      ,[Supplier_NM]
      ,[SKU_ID]
      ,[Bar_CD]
      ,[SKU_NM]
      ,[Unit]
      ,[Big_class_CD]
      ,[Big_class_NM]
      ,[Mid_Class_CD]
      ,[Mid_Class_NM]
      ,[Sales_AMT]
      ,[Activity]
      ,[Activity_Date]
      ,[Region]
      ,[Start_Date]
      ,DATEADD(DAY,1,[End_Date]) AS [End_Date]		--POWER BI 中的日历并不会把结束日期那一天算在过程中，所以要加一天
      ,[Type]
      ,[Promotition]
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
	  FROM [ODS].[ods].[File_YH_BM_Promotion]
	 

	  END TRY
 BEGIN CATCH
 
 SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

 END CATCH

END
GO
