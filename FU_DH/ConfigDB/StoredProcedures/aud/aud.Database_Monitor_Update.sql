USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
CREATE PROCEDURE [aud].[Database_Monitor_Update]

AS
BEGIN	

	--SET XACT_ABORT ON;

	DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID);

	BEGIN TRY

	
	DELETE FROM aud.Database_Monitor WHERE Datekey=convert(varchar(8),getdate(),112);

	;with fs
	as
	(
		select database_id, type, size * 8.0 / 1024 size
		from sys.master_files
	)
	INSERT INTO aud.Database_Monitor
		(Datekey ,
		DatabaseName ,
		DataFileSizeMB ,
		LogFileSizeMB ,
		[InsertDatetime] ,
		[UpdateDatetime] )
	select 
		convert(varchar(8),getdate(),112),
		name,
		(select sum(size) from fs where type = 0 and fs.database_id = db.database_id) DataFileSizeMB,
		(select sum(size) from fs where type = 1 and fs.database_id = db.database_id) LogFileSizeMB
		,getdate()
		,getdate()
	from sys.databases db

	END TRY
	BEGIN CATCH
	
		SELECT @errmsg =  ERROR_MESSAGE();

		EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

		RAISERROR(@errmsg,16,1);

	END CATCH
END
GO
