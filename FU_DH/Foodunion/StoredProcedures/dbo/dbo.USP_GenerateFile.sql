USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[USP_GenerateFile] -- @exec_sql  varchar(2000)--,@file_name varchar(200),@file_path varchar(200)

as

begin

---这里可以增加对数据表的查询条件或更多的数据处理；

---将结果放入一个新的数据表，然后将这个新表导出EXCEL文件；

declare @file_path varchar(200);--导出EXCEl文件的路径；

declare @file_name varchar(200);--导出EXCEl的文件名；

declare @exec_sql  varchar(200);--SQL语句；

---分开定义是为了以后修改路径或文件名更方便。

set @file_path = 'D:\Data\'

set @file_name = 'dept' + CONVERT(varchar(100), GETDATE(), 112)+'.xls'

set @exec_sql = 'select * from Foodunion.dm.Dim_Brand'  ---数据表使用的完整路径；

set @exec_sql = ' bcp "'+@exec_sql+'" out "'+@file_path+''+@file_name+'" -c -T -U "FU_ETL" -P "XUY8jE5PKQ6@"';

----U "sa" -P "SQLpassword" 这是数据库的sa账号和密码；

exec master..xp_cmdshell @exec_sql

end
GO
