USE [Foodunion]
GO
DROP VIEW [rpt].[V_DB_Files_Backup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [rpt].[V_DB_Files_Backup]
AS

	SELECT d.name AS DBNAME
		,f.file_size/1024/1024 AS File_Size_MB
		,f.logical_name
		,f.physical_name
		,f.backup_size/1024/1024 AS Backup_Size_MB
		,bs.name AS Bakcup_File_Name
		,bs.user_name AS Backup_User
 		,bs.database_creation_date
		,bs.backup_finish_date
		,CASE bs.type WHEN 'D' THEN 'Full' WHEN 'I' THEN 'Diff' WHEN 'L' THEN 'Log' END AS Backup_Type
		,bs.machine_name
		,bs.recovery_model
		,compressed_backup_size/1024/2014 AS Compressed_Backup_size
	FROM sys.sysdatabases d
	--JOIN  (SELECT database_name,MAX(backup_set_id) backup_set_id FROM msdb.dbo.backupset GROUP BY database_name) b
	JOIN msdb.dbo.backupset bs ON d.name=bs.database_name
	JOIN msdb.[dbo].[backupfile] f ON bs.backup_set_id=f.backup_set_id
	WHERE bs.backup_finish_date>=GETDATE()-3
	--ORDER BY d.name,bs.backup_finish_date

GO
