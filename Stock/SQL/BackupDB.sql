declare @today varchar(8) = convert(varchar(8),getdate(),112);

declare @cmd varchar(500);

set @cmd='
BACKUP DATABASE [Stock] TO  DISK = N''H:\DATA\Stock_'+@today+''' WITH NOFORMAT, NOINIT,  NAME = N''Stock-Full'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
'
exec(@cmd);