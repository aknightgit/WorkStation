USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



	  
CREATE PROCEDURE  [aud].[JobLog_Precheck] (@PID INT)
AS
BEGIN

DECLARE @errmsg nvarchar(max),
		@DatabaseName varchar(100) = DB_NAME(),
		@ProcName varchar(100) = OBJECT_NAME(@@PROCID),
		@time Datetime,
		@end  Datetime,
		@i  INT,
		@job varchar(100),
		@Njob varchar(100);

set @time=getdate();
set @END=DATEADD(SS,3600,GETDATE());
set @i=1;

BEGIN TRY 

while @time<=@end AND  @i=1
begin

set @i=(select COUNT(1) AS CON from [aud].[JobLog] 
		where StatusID =1 
		AND PlanID IN(0,1,2,4) 
		AND CONVERT(VARCHAR(10),StartTime,112)=CONVERT(VARCHAR(10),GETDATE(),112)
		AND JOBID = (select MAX(JOBID) from [aud].[JobLog] where  PlanID IN(0,1,2,4) ))
set @time=DATEADD(SS,60,@time)

if @time<=@end and @i=1
    waitfor DELAY '000:01:00'

end

set @job=(select [PlanDescription] from [aud].[JobLog] 
		where StatusID =1 
		AND PlanID IN(0,1,2,4) 
		AND CONVERT(VARCHAR(10),StartTime,112)=CONVERT(VARCHAR(10),GETDATE(),112)
		AND JOBID = (select MAX(JOBID) from [aud].[JobLog] where  PlanID IN(0,1,2,4) ));
set @Njob= (SELECT [PlanDescription] FROM [ConfigDB].[cfg].[JobPlans] WHERE [PlanID]=@PID);
if @time>=@end and @i=1

SELECT 1/0

END TRY

BEGIN CATCH

SELECT @errmsg =  @job+'执行超过1小时,'+@Njob+'等待超过1小时。';

 EXEC ConfigDB.[aud].[errorlog_insert] @DatabaseName,@ProcName,NULL,@errmsg;

 RAISERROR(@errmsg,16,1);

END CATCH

END
GO
