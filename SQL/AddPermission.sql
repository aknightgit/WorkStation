
--SP执行权限
create role [db_FUSP_Executor] AUTHORIZATION [dbo];
 
-- 授予角色执行的权限
grant exec to [db_FUSP_Executor];
grant ALTER to [db_FUSP_Executor];


exec sp_addrolemember N'db_FUSP_Executor',N'FU_Readonly'


--添加Object的权限
GRANT ALTER ON [rpt].[V_RPT_Rawdata_Inventory] TO [FU_Readonly]GOGRANT VIEW DEFINITION ON [rpt].[V_RPT_Rawdata_Inventory] TO [FU_Readonly]GO