
--SPִ��Ȩ��
create role [db_FUSP_Executor] AUTHORIZATION [dbo];
 
-- �����ɫִ�е�Ȩ��
grant exec to [db_FUSP_Executor];
grant ALTER to [db_FUSP_Executor];


exec sp_addrolemember N'db_FUSP_Executor',N'FU_Readonly'


--���Object��Ȩ��
GRANT ALTER ON [rpt].[V_RPT_Rawdata_Inventory] TO [FU_Readonly]GOGRANT VIEW DEFINITION ON [rpt].[V_RPT_Rawdata_Inventory] TO [FU_Readonly]GO