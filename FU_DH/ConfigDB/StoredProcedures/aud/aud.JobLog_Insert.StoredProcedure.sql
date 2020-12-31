USE [ConfigDB]
GO
DROP PROCEDURE [aud].[JobLog_Insert]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[JobLog_Insert]
(@PlanID INT,@JobID INT OUTPUT)
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO aud.JobLog(
	PlanID, 
	PlanDescription,
	StartTime,
	EndTime,
	DurationInSec,
	StatusID,  -- 1 Running, 2 Error, 0 Succeed
	ReturnMsg,
	InsertDatetime,
	UpdateDatetime
	)
	SELECT
	PlanID,
	PlanDescription,
	GETDATE(),
	NULL,
	NULL,
	1,
	NULL,
	GETDATE(),
	GETDATE()
	FROM cfg.JobPlans jp
	WHERE PlanID=@PlanID
	;

	set @JobID = @@IDENTITY;

END 

GO
