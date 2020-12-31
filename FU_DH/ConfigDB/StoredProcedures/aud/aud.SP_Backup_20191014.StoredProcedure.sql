USE [ConfigDB]
GO
DROP PROCEDURE [aud].[SP_Backup_20191014]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [aud].[SP_Backup_20191014]
AS
BEGIN


TRUNCATE TABLE [ConfigDB].[dbo].[Backup] 

INSERT INTO [ConfigDB].[dbo].[Backup] 
(  [First_lsn]
  ,[Last_lsn]
  ,[Database_name]
  ,[Name]
  ,[User_name]
  ,[Database_backup_lsn]
  ,[Backup_start_date]
  ,[Backup_finish_date]
  ,[Type]
  ,[Physical_device_name]
  ,[Filesize]
 )

SELECT DISTINCT  
		 s.first_lsn----在表中插入数据
        ,s.last_lsn
        ,s.[database_name]
        ,s.[name]
        ,s.[user_name]
        ,s.database_backup_lsn
        ,s.backup_start_date
        ,s.backup_finish_date
        ,s.type 
        ,y.physical_device_name 
        ,[ConfigDB].[DBO].[fn_get_backup_filesize](physical_device_name)
from msdb..backupset s inner join 
     msdb..backupfile f on f.backup_set_id = s.backup_set_id inner join
     msdb..backupmediaset m on s.media_set_id = m.media_set_id inner join
     msdb..backupmediafamily y on m.media_set_id = y.media_set_id
 where (s.database_name = 'ConfigDB')
 order by s.backup_finish_date desc;



 END
GO
