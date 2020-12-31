USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [DBO].[fn_get_backup_filesize](
@filename nvarchar(1000)
)
returns numeric(20,0) 
as 
begin
Declare @filesize  numeric(20,0) ;
declare @media_set_id int;

select @media_set_id = media_set_id from msdb.dbo.backupmediafamily
where physical_device_name = @filename;

Select @filesize = sum(compressed_backup_size)
From msdb.dbo.backupset 
where media_set_id = @media_set_id;

if @filesize is null
 set @filesize = 0;
 
return @filesize;
end
GO
