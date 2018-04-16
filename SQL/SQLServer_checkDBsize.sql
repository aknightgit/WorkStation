
declare  @dbname SYSNAME = 'intelligence_fo_ap3'

 DECLARE @cmd NVARCHAR(4000)

CREATE TABLE #dbsizes
 (
 DatabaseName SYSNAME,
 DBFileName SYSNAME,
 FileSizeMB NUMERIC(10,2),
 UsedSpaceMB NUMERIC(10,2),
 UnusedSpaceMB NUMERIC(10,2),
 FileType SYSNAME
 )
 IF @dbname IS NULL
 BEGIN
 SET @dbname='intelligence_fo_ap3'
 END


SET @cmd=N'USE '+@dbname+N';
 SELECT
 DB_NAME() AS [DatabaseName],
 [DBFileName] = ISNULL(a.name, ''*** Total size of the database ***''),
 [FileSizeMB] = CONVERT(NUMERIC(10, 2), SUM(ROUND(a.size / 128., 2))) ,
 [UsedSpaceMB] = CONVERT(NUMERIC(10, 2), SUM(ROUND(FILEPROPERTY(a.name,
 ''SpaceUsed'')
 / 128., 2))) ,
 [UnusedSpaceMB] = CONVERT(NUMERIC(10, 2), SUM(ROUND(( a.size
 - FILEPROPERTY(a.name,
 ''SpaceUsed'') )
 / 128., 2))) ,
 [Type] = CASE WHEN a.groupid IS NULL THEN '' ''
 WHEN a.groupid = 0 THEN ''Log''
 ELSE ''Data''
 END
 FROM sysfiles a
 GROUP BY groupid ,
 a.name
 WITH ROLLUP
 HAVING a.groupid IS NULL
 OR a.name IS NOT NULL
 ORDER BY CASE WHEN a.groupid IS NULL THEN 99
 WHEN a.groupid = 0 THEN 0
 ELSE 1
 END ,
 a.groupid ,
 CASE WHEN a.name IS NULL THEN 99
 ELSE 0
 END ,
 a.name'

 PRINT @CMD

IF @dbname = 'all'
 BEGIN
 INSERT INTO #dbsizes
 EXECUTE sp_msforeachdb @CMD
 END
 ELSE
 BEGIN
 INSERT INTO #dbsizes
 EXECUTE sp_executesql @statement=@cmd
 END

SELECT * FROM #dbsizes

DROP TABLE #dbsizes