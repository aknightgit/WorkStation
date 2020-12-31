USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE aud.JobTaskLog_Update
(@LogID INT,@StatusID INT,@ReturnMsg Nvarchar(max))
AS
BEGIN

	SET NOCOUNT ON;
	IF @StatusID=0
	BEGIN

	UPDATE aud.JobTaskLog
	SET
	EndTime = getdate(),
	DurationInSec = datediff("SECOND",StartTime,getdate()),
	StatusID = 0,  --1 Running, 2 Error, 0 Succeed
	ReturnMsg = '',
	UpdateDatetime = getdate()
	WHERE LogID=@LogID;

	END
	ELSE
	BEGIN

	UPDATE aud.JobTaskLog
	SET
	StatusID = 2,  -- 1 Running, 2 Error, 0 Succeed
	ReturnMsg = @ReturnMsg,
	UpdateDatetime = getdate()
	WHERE LogID=@LogID;

	END

	UPDATE jt
	SET jt.LastRunDate = jtl.StartTime,
	jt.LastRunStatus = CASE WHEN jtl.StatusID=0 THEN 'Succeed' ELSE 'Fail' END,
	jt.UpdateDatetime = getdate()
	FROM cfg.JobTasks jt
	JOIN aud.JobTaskLog jtl ON jt.TaskID=jtl.TaskID and jtl.LogID=@LogID;

END 

GO
