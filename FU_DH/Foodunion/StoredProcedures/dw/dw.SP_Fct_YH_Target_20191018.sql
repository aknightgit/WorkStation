USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE  [dw].[SP_Fct_YH_Target_20191018]
AS
BEGIN

DECLARE @errmsg nvarchar(max),
@DatabaseName varchar(100) = DB_NAME(),
@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY 

 TRUNCATE TABLE dw.[Fct_YH_Target];

 INSERT INTO dw.[Fct_YH_Target]
 (     [period]
      ,[Store_ID]
      ,[Region]
      ,[Store_NM]
      ,[PG]
      ,[Sales_Target]
      ,[Ambient_Sales_Target]
      ,[Fresh_Sales_Target]
    --  ,[DSR]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By])
SELECT  convert(varchar(8),[DATE_DT],112)
      ,ST.Store_ID
      ,ST.Store_City
      ,ST.Store_Name
	  ,NULL AS [PG]
      ,[Sales_Target_AMT]
      ,[Sales_Target_Ambient_AMT]
      ,[Sales_Target_Fresh_AMT]
	--  ,ST.DSR
	  ,GETDATE() AS [Create_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Create_By]
	  ,GETDATE() AS [Update_Time]
	  ,OBJECT_NAME(@@PROCID) AS [Update_By]
  FROM [ODS].[ods].[File_YH_Target] TG
  LEFT JOIN dm.Dim_Store ST ON TG.YH_Store_CD = ST.Account_Store_Code
  WHERE TG.YH_Store_CD <> '#N/A'
 --WHERE [DATE_DT] = (SELECT MAX([DATE_DT]) [DATE_DT] FROM [Foodunion].[ODS].[ods].[File_YH_Target])

  UNION

  SELECT 
    ods.MonthKey*100+1,
	--LEFT(ods.MonthKey,4)+'-'+right(ods.monthkey,2)+'-01',
	s.Store_ID,
	--s.[Account_Store_Code],	
	s.Store_City,
	s.Store_Name,
	NULL,
	ods.Total_Target Total_Target,
	ods.Ambient_Target Ambient_Target,
	ods.Fresh_Target Fresh_Target
--	ods.Business_Manager
	,GETDATE() AS [Create_Time]
	,OBJECT_NAME(@@PROCID) AS [Create_By]
	,GETDATE() AS [Update_Time]
	,OBJECT_NAME(@@PROCID) AS [Update_By]
  FROM ODS.ods.[File_YHStore_BMTarget] ods
  JOIN dm.Dim_Store s
  ON ods.[Account_Store_Code]=s.[Account_Store_Code] AND s.Channel_Account = 'YH'
   
   END TRY
BEGIN CATCH

SELECT @errmsg =  ERROR_MESSAGE();

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
