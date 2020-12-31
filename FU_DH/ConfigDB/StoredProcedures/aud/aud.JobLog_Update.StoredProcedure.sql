USE [ConfigDB]
GO
DROP PROCEDURE [aud].[JobLog_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[JobLog_Update]
(@PlanID INT,@JobID INT,@SequenceID INT,@StatusID INT,@ReturnMsg Nvarchar(max))
AS
BEGIN

	SET NOCOUNT ON;

	IF(@StatusID=0)
	BEGIN
		UPDATE aud.JobLog
		SET EndTime=getdate(),
		StatusID=@StatusID,
		ReturnMsg=isnull(@ReturnMsg,''),
		DurationInSec=datediff("SECOND",StartTime,getdate()),
		UpdateDatetime=getdate()
		WHERE JobID=@JobID;
	END
	ELSE
	BEGIN
		UPDATE aud.JobLog
		SET StatusID=2,   -- Job Fails
		FailSequenceID=@SequenceID,
		ReturnMsg=@ReturnMsg,
		DurationInSec=datediff("SECOND",StartTime,getdate()),
		UpdateDatetime=getdate()
		WHERE JobID=@JobID;
	END

	UPDATE cjp
	SET cjp.LastRunDate= jl.StartTime,
		cjp.LastRunStatus= CASE WHEN jl.StatusID=0 THEN 'Succeed' ELSE 'Fail' END,
		cjp.UpdateDatetime = getdate()
	FROM cfg.JobPlans cjp
	--JOIN cfg.JobPlanTask
	JOIN aud.JobLog jl ON cjp.PlanID=jl.PlanID AND jl.JobID=@JobID;



END 

GO
