USE [Foodunion]
GO
DROP PROCEDURE [dm].[SP_Dim_ERP_Unit_ConvertRate_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dm].[SP_Dim_ERP_Unit_ConvertRate_Update]
AS
BEGIN		
	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

		UPDATE p
		SET p.[Convert_Rate] = c.[ConvertRate]
		  ,p.[Use_Org] = c.[UseOrg]
			,p.[Update_Time] = GETDATE() 
			,p.[Update_By] = @ProcName
		FROM [dm].[Dim_ERP_Unit_ConvertRate] p
		JOIN ODS.[ods].[ERP_Unit_ConvertRate] c
		ON p.[From_Unit] = c.[FromUnit] AND p.[To_Unit] = c.[ToUnit];
	
		INSERT INTO [dm].[Dim_ERP_Unit_ConvertRate]
			([From_Unit]
		  ,[To_Unit]
		  ,[Convert_Rate]
		  ,[Use_Org]
		  ,[Create_Time]
		  ,[Create_By]
		  ,[Update_Time]
		  ,[Update_By]
			)
		SELECT 
			c.[FromUnit]
		  ,c.[ToUnit]
		  ,c.[ConvertRate]
		  ,c.[UseOrg]
			,GETDATE()
			,@ProcName
			,GETDATE()
			,@ProcName
		FROM ODS.[ods].[ERP_Unit_ConvertRate] c
		LEFT JOIN [dm].[Dim_ERP_Unit_ConvertRate] p
		ON p.[From_Unit] = c.[FromUnit] AND p.[To_Unit] = c.[ToUnit]
		WHERE p.[From_Unit] IS NULL;
		
--select top 1000 * from dm.Dim_ERP_Unit_ConvertRate where from_unit='cls_c'
--select top 1000 * from dm.Dim_ERP_Unit_ConvertRate where from_unit='tray'
----select top 1000 * from dm.Dim_ERP_Unit_ConvertRate where to_unit='cls_c'
--select * from dm.Dim_Product where SKU_ID='2100030'

	DELETE FROM [dm].[Dim_ERP_Unit_ConvertRate] WHERE [From_Unit]='Tray' AND [To_Unit]='Cls_C';
	DELETE FROM [dm].[Dim_ERP_Unit_ConvertRate] WHERE [From_Unit]='Tray' AND [To_Unit]='Cls_B';
	DELETE FROM [dm].[Dim_ERP_Unit_ConvertRate] WHERE [From_Unit]='Cls_B' AND [To_Unit]='Tray';
	DELETE FROM [dm].[Dim_ERP_Unit_ConvertRate] WHERE [From_Unit]='Cls_C' AND [To_Unit]='Tray';
	DELETE FROM [dm].[Dim_ERP_Unit_ConvertRate] WHERE [From_Unit]='Tray2*12' AND [To_Unit]='Cluster';
	DELETE FROM [dm].[Dim_ERP_Unit_ConvertRate] WHERE [From_Unit]='Cluster' AND [To_Unit]='Tray2*12';
	DELETE FROM [dm].[Dim_ERP_Unit_ConvertRate] WHERE [From_Unit]='Tray4*12' AND [To_Unit]='Cluster';
	DELETE FROM [dm].[Dim_ERP_Unit_ConvertRate] WHERE [From_Unit]='Cluster' AND [To_Unit]='Tray4*12';
	DELETE FROM [dm].[Dim_ERP_Unit_ConvertRate] WHERE [From_Unit]='Cluster' AND [To_Unit]='Tray4*6';
	DELETE FROM [dm].[Dim_ERP_Unit_ConvertRate] WHERE [From_Unit]='Tray4*6' AND [To_Unit]='Cluster';

	INSERT INTO [dm].[Dim_ERP_Unit_ConvertRate]
			([From_Unit]
		  ,[To_Unit]
		  ,[Convert_Rate]
		  ,[Use_Org]
		  ,[Create_Time]
		  ,[Create_By]
		  ,[Update_Time]
		  ,[Update_By]
			)
	SELECT 'Tray','Cls_C',6,NULL,GETDATE(),'',GETDATE(),''
	UNION
	SELECT 'Tray','Cls_B',4,NULL,GETDATE(),'',GETDATE(),''
	UNION
	SELECT 'Cls_C','Tray',cast(1 as decimal(18,9))/6,NULL,GETDATE(),'',GETDATE(),''
	UNION
	SELECT 'Cls_B','Tray',0.25,NULL,GETDATE(),'',GETDATE(),''
	UNION
	SELECT 'Tray2*12','Cluster',12,NULL,GETDATE(),'',GETDATE(),''
	UNION
	SELECT 'Tray4*12','Cluster',12,NULL,GETDATE(),'',GETDATE(),''
	UNION
	SELECT 'Tray4*6','Cluster',6,NULL,GETDATE(),'',GETDATE(),''
	UNION
	SELECT 'Cluster','Tray2*12',cast(1 as decimal(18,9))/12,NULL,GETDATE(),'',GETDATE(),''
	UNION
	SELECT 'Cluster','Tray4*12',cast(1 as decimal(18,9))/12 ,NULL,GETDATE(),'',GETDATE(),''
	UNION
	SELECT 'Cluster','Tray4*6',cast(1 as decimal(18,9))/6,NULL,GETDATE(),'',GETDATE(),''
	
	--select * from [dm].[Dim_ERP_Unit_ConvertRate]

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH

END
GO
