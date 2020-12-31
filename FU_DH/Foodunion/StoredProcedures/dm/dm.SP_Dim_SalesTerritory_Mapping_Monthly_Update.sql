USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dm].[SP_Dim_SalesTerritory_Mapping_Monthly_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY
	--select * from  [dm].[Dim_SalesTerritory_Mapping_Monthly] 
	--[dbo].[USP_Change_TableColumn] '[dm].[Dim_SalesTerritory_Mapping_Monthly]','ADD','Area VARCHAR(50)','Region_EN',0
	--[dbo].[USP_Change_TableColumn] '[dm].[Dim_SalesTerritory_Mapping_Monthly]','ALTER','Update_By VARCHAR(100)',NULL,0
	--TRUNCATE TABLE  [dm].[Dim_SalesTerritory_Mapping_Monthly] ; 

	DELETE D FROM [dm].[Dim_SalesTerritory_Mapping_Monthly] D
	JOIN ODS.[ods].[File_Sales_SalesTerritory_Mapping] O
	ON D.[Monthkey]=O.[Month];

	INSERT INTO [dm].[Dim_SalesTerritory_Mapping_Monthly]
           ([Monthkey]
           ,[Channel]
           ,[Province]
           ,[Province_Short]
           ,[Code]
           ,[Region]
           ,[Region_EN]
           ,[Manager]
           ,[Region_Director]
		   ,[Area]
           ,[Create_Time]
           ,[Create_By]
           ,[Update_Time]
           ,[Update_By]) 
	SELECT [Month]
		  ,[KA]
		  ,[Province]
		  ,CASE WHEN [Province] LIKE '内蒙古%' THEN '内蒙古'
			WHEN [Province] LIKE '黑龙江%' THEN '黑龙江'
			ELSE SUBSTRING([Province],1,2)
			END AS [Province_Short]
		  ,''
		  ,[Region]
		  ,[Region_EN]
		  ,[Manager]
		  ,[Director]		  
		  ,[Area]
		  ,GETDATE()
		  ,@ProcName
		  ,GETDATE()
		  ,@ProcName
	  FROM ODS.[ods].[File_Sales_SalesTerritory_Mapping]
	  ;

	  --select * from [dm].[Dim_CountyLocation]

	  UPDATE t
	  SET t.Code = cl.CountyCode
	  FROM  [dm].[Dim_SalesTerritory_Mapping_Monthly] t
	  JOIN  [dm].[Dim_CountyLocation] cl ON cl.City='' AND cl.Province LIKE '%'+t.Province_Short+'%'
	  ;
	  UPDATE  [dm].[Dim_SalesTerritory_Mapping_Monthly] 
	  SET Is_Current= CASE WHEN Monthkey = CONVERT(VARCHAR(6),GETDATE(),112) THEN 1 ELSE 0 END
		

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
