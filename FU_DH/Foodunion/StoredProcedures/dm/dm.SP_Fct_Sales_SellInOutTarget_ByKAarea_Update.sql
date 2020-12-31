USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dm].[SP_Fct_Sales_SellInOutTarget_ByKAarea_Update]
AS
BEGIN
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY	
	/*
	TRUNCATE TABLE [dm].[Fct_Sales_SellOutTarget_ByKAarea]
	INSERT INTO [dm].[Fct_Sales_SellOutTarget_ByKAarea]
	(
	   [Monthkey]
      ,[KA]
      ,[Area]
	  ,[Channel_ID]
      ,[TargetAmt]
      ,[TargetAmt_Ambient]
      ,[TargetAmt_Fresh]
      ,[TargetAmt_KATotal]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
	)
	SELECT 
	   [Monthkey]
      ,CASE KA WHEN 'YH' THEN 'YH'
			   WHEN 'Vanguard' THEN 'VG'
			   WHEN 'Kidswant' THEN 'KW'
			   WHEN 'CenturyMart' THEN 'CM'
			   ELSE KA
		END AS [KA]
      ,[Area]
	  ,CASE KA WHEN 'YH' THEN '5'
			   WHEN 'Vanguard' THEN '15'
			   WHEN 'Kidswant' THEN '16'
			   WHEN 'CenturyMart' THEN '87'
		END AS Channel_ID
      ,[TargetAmt]
      ,[TargetAmt_Ambient]
      ,[TargetAmt_Fresh]
      ,[TargetAmt_KATotal]
      ,GETDATE()
	  ,@ProcName
	  ,GETDATE()
	  ,@ProcName
    FROM [ODS].[ods].[File_Sales_SellOutTarget]

	TRUNCATE TABLE [dm].[Fct_Sales_SellInTarget_ByKAarea]
	INSERT INTO [dm].[Fct_Sales_SellInTarget_ByKAarea]
	(
	   [Monthkey]
      ,[KA]
      ,[Area]
	  ,[Channel_ID]
      ,[TargetAmt]
      ,[TargetAmt_Ambient]
      ,[TargetAmt_Fresh]
      ,[TargetAmt_KATotal]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
	)
	SELECT 
	   [Monthkey]
      ,CASE KA WHEN 'YH' THEN 'YH'
			   WHEN 'Vanguard' THEN 'VG'
			   WHEN 'Kidswant' THEN 'KW'
			   WHEN 'CenturyMart' THEN 'CM'
			   ELSE KA
		END AS [KA]
      ,[Area]
	  ,CASE KA WHEN 'YH' THEN '5'
			   WHEN 'Vanguard' THEN '15'
			   WHEN 'Kidswant' THEN '16'
			   WHEN 'CenturyMart' THEN '87'
		END AS Channel_ID
      ,[TargetAmt_Sellin]
      ,[TargetAmt_Ambient]
      ,[TargetAmt_Fresh]
      ,null [TargetAmt_KATotal]
      ,GETDATE()
	  ,@ProcName
	  ,GETDATE()
	  ,@ProcName
    FROM [ODS].[ods].[File_Sales_SellOutTarget];

	*/
	-- 从新表ODS.ODS.File_Sales_SellINOutTarget出target
	DELETE t
	FROM [dm].[Fct_Sales_SellOutTarget_ByKAarea] t
	JOIN ODS.ODS.File_Sales_SellINOutTarget o ON t.Monthkey=o.Month;
	INSERT INTO [dm].[Fct_Sales_SellOutTarget_ByKAarea]
	(
	   [Monthkey]
      ,[KA]
      ,[Area]
	  ,[Channel_ID]
      ,[TargetAmt]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
	)
	SELECT 
	   [Month]
      ,CASE KA WHEN 'YH' THEN 'YH'
			   WHEN 'Vanguard' THEN 'VG'
			   WHEN 'Kidswant' THEN 'KW'
			   WHEN 'CenturyMart' THEN 'CM'
			   ELSE KA
		END AS [KA]
      ,[Area]
	  ,CASE KA WHEN 'YH' THEN '5'
			   WHEN 'Vanguard' THEN '15'
			   WHEN 'Kidswant' THEN '16'
			   WHEN 'CenturyMart' THEN '87'
		END AS Channel_ID
		,SellOut
      ,GETDATE()
	  ,@ProcName
	  ,GETDATE()
	  ,@ProcName
    FROM [ODS].[ods].[File_Sales_SellINOutTarget];
	
	DELETE t
	FROM [dm].[Fct_Sales_SellInTarget_ByKAarea] t
	JOIN ODS.ODS.File_Sales_SellINOutTarget o ON t.Monthkey=o.Month;
	INSERT INTO [dm].[Fct_Sales_SellInTarget_ByKAarea]
	(
	   [Monthkey]
      ,[KA]
      ,[Area]
	  ,[Channel_ID]
      ,[TargetAmt]
      ,[Create_Time]
      ,[Create_By]
      ,[Update_Time]
      ,[Update_By]
	)
	SELECT 
	   [Month]
      ,CASE KA WHEN 'YH' THEN 'YH'
			   WHEN 'Vanguard' THEN 'VG'
			   WHEN 'Kidswant' THEN 'KW'
			   WHEN 'CenturyMart' THEN 'CM'
			   ELSE KA
		END AS [KA]
      ,[Area]
	  ,CASE KA WHEN 'YH' THEN '5'
			   WHEN 'Vanguard' THEN '15'
			   WHEN 'Kidswant' THEN '16'
			   WHEN 'CenturyMart' THEN '87'
		END AS Channel_ID
		,SellIn
      ,GETDATE()
	  ,@ProcName
	  ,GETDATE()
	  ,@ProcName
    FROM [ODS].[ods].[File_Sales_SellINOutTarget];
	--SELECT * FROM  [dm].[Fct_Sales_SellOutTarget_ByKAarea]
	--SELECT * FROM  [dm].[Fct_Sales_SellinTarget_ByKAarea]
	--SELECT *FROM ODS.ODS.File_Sales_SellINOutTarget


	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

	END


	--SELECT * FROM DM.Dim_Channel
GO
