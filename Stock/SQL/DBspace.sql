SP_SPACEUSED 

--���С
create table #t(name varchar(255), rows bigint, reserved varchar(20), data varchar(20), index_size varchar(20), unused varchar(20))
exec sp_MSforeachtable "insert into #t exec sp_spaceused '?'" 
select * from #t
drop table #t

--1����ѯ�������̷�����ʣ��ռ䣺
Exec master.dbo.xp_fixeddrives

--2����ѯ���ݿ�������ļ�����־�ļ��������Ϣ�������ļ��顢��ǰ�ļ���С���ļ����ֵ���ļ��������á��ļ��߼������ļ�·���ȣ�
select * from stock.[dbo].[sysfiles]
--ת���ļ���С��λΪMB��
select name, convert(float,size) * (8192.0/1024.0)/1024. from stock.dbo.sysfiles

--3����ѯ��ǰ���ݿ�Ĵ���ʹ�������
Exec sp_spaceused

--������ѯ���ݿ�����������ݿ���־�ļ��Ĵ�С��������
DBCC SQLPERF(LOGSPACE)

dbcc shrinkdatabase(stock)

USE [Stock]
GO
DBCC SHRINKFILE (N'Stock_log' , 0, TRUNCATEONLY)
GO
