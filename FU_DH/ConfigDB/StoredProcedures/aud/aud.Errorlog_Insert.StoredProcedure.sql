USE [ConfigDB]
GO
DROP PROCEDURE [aud].[Errorlog_Insert]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [aud].[Errorlog_Insert]
(@DatabaseName varchar(100),
	@ExecName varchar(200),
	@JobID int,
	@ErrorMessage nvarchar(2000))
AS 
BEGIN

	INSERT INTO [aud].[errorlog]
           ([DatabaseName]
           ,[ExecName]
           ,[JobID]
           ,[ErrorMessage]
           ,[CreateBy]
           ,[CreateTime])
    SELECT @DatabaseName,
			@ExecName,
			@JobID,
			@ErrorMessage,
			'aud.errorlog_insert',
			GETDATE()

END
GO
