sp_helptext 'sys.sp_cdc_change_job'

EXEC sys.sp_cdc_enable_db

create procedure sys.sp_cdc_change_job
(
	@job_type nvarchar(20) = N'capture',
	@maxtrans int = null,
	@maxscans int = null,
	@continuous bit = null,
	@pollinginterval bigint = null,
	@retention bigint = null,
	@threshold bigint = null
)	
as
begin
    set nocount on

    declare @retcode int
		,@db_name sysname
		
	set @db_name = db_name()	

    --
    -- Job security check proc
    --
    exec @retcode = [sys].[sp_MScdc_job_security_check]
    if @retcode <> 0 or @@error <> 0
        return(1)
        
    -- Verify database is currently enabled for change data capture
    if ([sys].[fn_cdc_is_db_enabled]() != 1)
    begin
		raiserror(22901, 16, -1, @db_name)
        return 1
    end
        
	set @job_type = rtrim(ltrim(lower(@job_type)))
        
    -- Verify parameter
    if @job_type not in (N'capture', N'cleanup')
    begin
        raiserror(22992, 16, -1, @job_type)
        return(1)
    end
   
	-- Call internal stored procedure to complete verification and update job attributes
	exec @retcode = sys.sp_cdc_change_job_internal
		@job_type,
		@maxtrans,
		@maxscans,
		@continuous,
		@pollinginterval,
		@retention,
		@threshold
		
	if @@error <> 0 or @retcode <> 0
		return 1
		
	return 0		
end
