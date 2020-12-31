USE [ConfigDB]
GO
DROP PROCEDURE [aud].[JobTaskLog_Insert]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[JobTaskLog_Insert]
(@JobID INT,@PlanDescription NVARCHAR(100),@SequenceID INT,
@GroupName NVARCHAR(100),@TaskName NVARCHAR(100),
@TaskID INT,@TaskType NVARCHAR(100),
@ExecutorPath NVARCHAR(100),@ExecutorName NVARCHAR(100),@ExecQuery NVARCHAR(MAX),
@ExecConnectionID INT,@Threads INT,@LogID INT OUTPUT)
AS
BEGIN

	SET NOCOUNT ON;
	IF @TaskType ='CallJob' OR @TaskType ='SysExec'
	BEGIN
		INSERT INTO aud.JobTaskLog(
		JobID ,
		PlanDescription,
		DateKey,
		SequenceID,	
		GroupName,
		TaskName,
		TaskID,
		TaskType,  
		[ExecutorPath],
		RuntimeExecutor,
		ExecConnectionID,
		Threads,
		StartTime,
		StatusID ,  -- 1 Running, 2 Error, 0 Succeed
		InsertDatetime,
		UpdateDatetime
		)
		SELECT
		@JobID,
		@PlanDescription,
		convert(varchar(8),getdate(),112),
		@SequenceID,	
		@GroupName,
		@TaskName,
		@TaskID,
		@TaskType,  
		@ExecutorPath,
		@ExecutorName,
		@ExecConnectionID,
		@Threads,
		getdate(),
		1 ,  -- 1 Running, 2 Error, 0 Succeed
		getdate(),
		getdate()
		;
	END
	IF @TaskType ='Stored Procedure'
	BEGIN
		INSERT INTO aud.JobTaskLog(
		JobID ,
		PlanDescription,
		DateKey,
		SequenceID,	
		GroupName,
		TaskName,
		TaskID,
		TaskType,  
		RuntimeExecutor,
		ExecConnectionID,
		Threads,
		StartTime,
		StatusID ,  -- 1 Running, 2 Error, 0 Succeed
		InsertDatetime,
		UpdateDatetime
		)
		SELECT
		@JobID,
		@PlanDescription,
		convert(varchar(8),getdate(),112),
		@SequenceID,	
		@GroupName,
		@TaskName,
		@TaskID,
		@TaskType,  
		@ExecQuery,
		@ExecConnectionID,
		@Threads,
		getdate(),
		1 ,  -- 1 Running, 2 Error, 0 Succeed
		getdate(),
		getdate()
		;
	END
	

	set @LogID = @@IDENTITY;

END 

GO
