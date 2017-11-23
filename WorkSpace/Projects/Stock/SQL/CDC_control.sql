
use stock

select is_cdc_enabled,* from sys.databases
where name ='stock'

exec [sys].[sp_cdc_disable_db]
go
exec [sys].[sp_cdc_enable_db]
go
exec sys.sp_cdc_help_jobs
go
exec sys.sp_cdc_change_job @job_type='cleanup',@retention=1440;

exec  [sys].[sp_cdc_enable_table] 
@source_schema ='dbo',
@source_name ='DimStockList',
@capture_instance  = 'dbo_DimStockList',
@supports_net_changes  = 1,
@role_name =N'cdc_admin',
@index_name  = null,
@captured_column_list  = null,
@filegroup_name = 'CDC',
@allow_partition_switch  = 1;

exec  [sys].[sp_cdc_disable_table] 
@source_schema ='dbo',
@source_name ='FctStockDaily',
@capture_instance  = 'dbo_FctStockDaily'

exec  [sys].[sp_cdc_enable_table] 
@source_schema ='dbo',
@source_name ='FctStockDaily',
@capture_instance  = 'dbo_FctStockDaily',
@supports_net_changes  = 1,
@role_name =N'cdc_admin',
@index_name  = null,
@captured_column_list  = null,
@filegroup_name = 'CDC',
@allow_partition_switch  = 1;


exec  [sys].[sp_cdc_disable_table] 
@source_schema ='dbo',
@source_name ='FctStockDetail_5min',
@capture_instance  = 'dbo_FctStockDetail_5min'

exec  [sys].[sp_cdc_enable_table] 
@source_schema ='dbo',
@source_name ='FctStockDetail_5min',
@capture_instance  = 'dbo_FctStockDetail_5min',
@supports_net_changes  = 1,
@role_name =N'cdc_admin',
@index_name  = null,
@captured_column_list  = null,
@filegroup_name = 'CDC',
@allow_partition_switch  = 1;

exec  [sys].[sp_cdc_enable_table] 
@source_schema ='dbo',
@source_name ='DimIndexes',
@capture_instance  = 'dbo_DimIndexes',
@supports_net_changes  = 1,
@role_name =N'cdc_admin',
@index_name  = null,
@captured_column_list  = null,
@filegroup_name = 'CDC',
@allow_partition_switch  = 1;

exec  [sys].[sp_cdc_enable_table] 
@source_schema ='dbo',
@source_name ='FctIndexDaily',
@capture_instance  = 'dbo_FctIndexDaily',
@supports_net_changes  = 1,
@role_name =N'cdc_admin',
@index_name  = null,
@captured_column_list  = null,
@filegroup_name = 'CDC',
@allow_partition_switch  = 1;
exec sys.sp_cdc_help_change_data_capture

select top 100 * from sys.dm_cdc_log_scan_sessions

select top 10 * from cdc.lsn_time_mapping

exec sp_repldone @xactid = NULL, @xact_segno = NULL, @numtrans = 0, @time = 0, @reset = 1  