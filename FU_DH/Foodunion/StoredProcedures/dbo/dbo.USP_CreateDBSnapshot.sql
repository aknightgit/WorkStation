USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USP_CreateDBSnapshot]

@DBName nvarchar(200),   --要创建snapshot的DB
@SnapshotName nvarchar(200),  --Snapshot的名字
@FilePath nvarchar(200),  --'E:\
@ForceDrop int = 1

AS
BEGIN

DECLARE @errmsg nvarchar(max),
	@DatabaseName varchar(100) = DB_NAME(),
	@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

BEGIN TRY 

	DECLARE @sqlcmd NVARCHAR(2000)

	SET @sqlcmd = 'IF '+ CAST(@ForceDrop AS VARCHAR(2))+'=1'+' DROP DATABASE IF EXISTS '+ @SnapshotName;
	PRINT @sqlcmd
	EXEC (@sqlcmd);

	--PRINT 
	SET @sqlcmd = 'CREATE DATABASE '+ @SnapshotName+ ' ON (name = '+ @DBName+',filename='''+@FilePath+'\'+@SnapshotName+'.mdf'''+')  as snapshot of '+ @DBName;
	PRINT @sqlcmd
	EXEC (@sqlcmd);


   END TRY
BEGIN CATCH

	SELECT @errmsg =  ERROR_MESSAGE();

	EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

	RAISERROR(@errmsg,16,1);

END CATCH

END
GO
