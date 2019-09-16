

--Table Space
CREATE VIEW rpt.V_Tables_Size
AS
SELECT 
    s.Name+'.'+t.NAME AS TableName,
    --s.Name AS SchemaName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    p.rows DESC


------------------------------------
select top 10 * from msdb.dbo.backupset ORDER BY 1 DESC
select top 10 *from msdb.[dbo].[backupfile] order by 1 desc
select top 10 *from sys.sysdatabases T1 
SELECT database_name,MAX(backup_set_id) backup_set_id FROM msdb.dbo.backupset GROUP BY database_name
select top 10 * from sys.sysdevices


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
ORDER BY d.name,bs.backup_finish_date


--D
SELECT T1.Name AS DatabaseName, 
	Isnull(Max(T2.recovery_model), 'No Backup Taken') AS recovery_model, 
	'Full' AS BackupType, 
	MAX(T2.name) AS BackupFile,
	CONVERT(DATETIME, Max(T2.backup_finish_date)) AS LastBackUpTaken 
FROM sys.sysdatabases T1 
	LEFT OUTER JOIN msdb.dbo.backupset T2 
	ON T2.database_name = T1.name 
WHERE type = 'D' 
GROUP BY T1.Name 

--Get the most recent Diff backup taken 
UNION ALL 
SELECT T1.Name AS DatabaseName, 
 Isnull(Max(T2.recovery_model), 'No Backup Taken') AS recovery_model, 
 'Differential' AS BackupType, 
 Isnull(CONVERT(VARCHAR(23), CONVERT(DATETIME, Max(T2.backup_finish_date), 131)), '') AS LastBackUpTaken 
FROM sys.sysdatabases T1 
 LEFT OUTER JOIN msdb.dbo.backupset T2 
 ON T2.database_name = T1.name 
WHERE type = 'I' 
GROUP BY T1.Name 

--Get the most recent Log backup taken 
UNION ALL 
SELECT T1.Name AS DatabaseName, 
 Isnull(Max(T2.recovery_model), 'No Backup Taken') AS recovery_model, 
 'Log' AS BackupType, 
 Isnull(CONVERT(VARCHAR(23), CONVERT(DATETIME, Max(T2.backup_finish_date), 131)), '') AS LastBackUpTaken 
FROM sys.sysdatabases T1 
 LEFT OUTER JOIN msdb.dbo.backupset T2 
 ON T2.database_name = T1.name 
WHERE type = 'L' 
GROUP BY T1.Name 

--Get the databases with no backup yet taken 
UNION ALL 
SELECT T1.Name AS DatabaseName, 
 Isnull(Max(T2.recovery_model), 'No Backup Taken') AS recovery_model, 
 'No Backup' AS BackupType, 
 Isnull(CONVERT(VARCHAR(23), CONVERT(DATETIME, Max(T2.backup_finish_date), 131)), '') AS LastBackUpTaken 
FROM sys.sysdatabases T1 
 LEFT OUTER JOIN msdb.dbo.backupset T2 
 ON T2.database_name = T1.name 
WHERE type IS NULL 
GROUP BY T1.Name 

--Sort the combined results
ORDER BY T1.name, 
 BackupType 

