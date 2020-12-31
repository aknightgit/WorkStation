USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 将查询结果集直接导出到excel文件中(包含表头,别名不能包含'(')，通过SQLServer数据库内置对象提高数据导出速率(事理 2011.5) 
 exec proc_ExportDataToExcel '.\SQL2005','OA','asdfef85','','select  top 10* from SL_User where UserId<500','D:/1.xls'
 判断xp_cmdshell存储过程是否存在select count(*) from master.dbo.sysobjects where xtype='X' and name='xp_cmdshell'
 注意：使用此存储过程，数据库登录用户要有sysadmin权限，需要创建表AppLock管理xp_cmdshell的开启与关闭
    create table AppLock (Id int not null identity(1,1) primary key,SessionCount int not null,Name varchar(50) not null)
    insert into AppLock values(0,'proc_ExportDataToExcel')
*/
CREATE PROC [dbo].[USP_ExportDataToExcel]
(
    @server nvarchar(50),--数据库服务名称
    @database nvarchar(50),--数据库名称
    @uid nvarchar(50),--数据库登录用户名
    @pwd varchar(50),--数据库登录密码
    @selectSQL varchar(7000),--查询语句
    @fileSavePath nvarchar(500)--excel文件存放目录如，D:/1.xls
)
AS 
BEGIN       
    declare @errorSum int --记录错误标志   
    declare @sql varchar(8000)
    declare @tableName varchar(55)--随机临时表名称
    declare @tempTableName varchar(55)   
	
    set @errorSum = 1


    --生成随机名称，防止多个人同时导出数据问题               
    select @tableName = replace('##ExportDataToExcel'+Convert(varchar(36),newid()),'-','')
    set @tempTableName=@tableName+'Temp'
    
    --拼接复制表结构的sql语句
    declare @tempSQL varchar(7000)
    --判断第一个select后面是否有top
    declare @hasTop varchar(10)
    declare @index int
    set @index=charindex(' ',@selectSQL)
    set @hasTop=lower(ltrim(substring(@selectSQL,@index+1,10)))
    set @hasTop=substring(@hasTop,0,4)
    if(@hastop='top ')
        begin
            --将其它top换成top 0
            set @tempSQL=substring(@selectSQL,12,len(@selectSQL)-11)--截取"select top "之后字符串
            set @index=patindex('%[0-9][^0-9]%', @tempSQL)--查询top后最后一个数字位置
            set @tempSQL='select top 0 '+substring(@tempSQL,@index+1,len(@tempSQL)-@index)    
        end
    else
        begin
            --在第一个select后面加上top 1
            set @tempSQL='select top 0 '+substring(@selectSQL,8,len(@selectSQL)-7)
        end

    --通过查询语句创建用于复制表结构的空临时表
    begin try
        set @sql='select * into '+@tempTableName+' from ('+@tempSQL+') as temp where 1=0'        
        exec (@sql)
        set @errorSum = @errorSum+1        
    end try
    begin catch
        raiserror('创建复制表结构的空临时表失败！',16,1)
        return @errorSum
    end catch;

    --查询表结构
    declare @columnName nvarchar(4000)
    declare @columnName2 nvarchar(4000)
    select @columnName=isnull(@columnName+',','')+''''+SC.name+'''',@columnName2=
    case when ST.name in('text','ntext') then isnull(@columnName2+',','')+SC.name
         when ST.name in('char','varchar') then isnull(@columnName2+',','')+'cast('+SC.name+' as varchar('+cast((case when SC.length<255 then 255 else SC.length end) as varchar)+')) '+SC.name         
         when ST.name in('nchar','nvarchar') then isnull(@columnName2+',','')+'cast('+SC.name+' as nvarchar('+cast((case when SC.length<255 then 255 else SC.length end) as varchar)+')) '+SC.name          
         else isnull(@columnName2+',','')+'cast('+SC.name+' as varchar(1000)) '+SC.name end
    from tempdb..sysobjects SO,tempdb..syscolumns SC,tempdb..systypes ST 
    where SO.id=SC.id and SO.xtype='U' and SO.status>=0 and SC.xtype=ST.xusertype and SO.name=@tempTableName
    and ST.name not in('image','sql_variant','varbinary','binary')
    order by SC.colorder
    
    declare @dropTableSql varchar(200)
    begin try        
        --创建全字符串类型的空临时表
        set @sql='select * into '+@tableName+' from (select '+@columnName2+' from '+@tempTableName+' where 1=0) as temp'
        exec (@sql)

        --删除临时空临时表
        set @dropTableSql='if exists(select * from tempdb..sysobjects where name='''+@tempTableName+''') drop table '+@tempTableName
        exec (@dropTableSql)    
        
        --插入列名(表头)
        set @sql='insert into '+@tableName+' values('+@columnName+')'
        exec (@sql)    
        
        --插入数据到临时表
        set @sql='insert into '+@tableName+' select * from ('+@selectSQL+') as temp'
        exec (@sql)    
        set @errorSum = @errorSum+1            
    end try
    begin catch
        raiserror('创建数据临时表或往临时表中插入数据失败！',16,1)
        exec (@dropTableSql)
        return @errorSum
    end catch

    --删除数据临时表
    set @dropTableSql='if exists(select * from tempdb..sysobjects where name='''+@tableName+''') drop table '+@tableName
    --导出数据
    begin try
        declare @sessionCount int
        select @sessionCount=SessionCount from AppLock where [Name]='proc_ExportDataToExcel'
        if @sessionCount=0
        begin
            /*开启xp_cmdshell,数据库登录用户要有sysadmin权限*/        
            begin try            
                EXEC sp_configure 'show advanced options', 1
                RECONFIGURE
                EXEC sp_configure 'xp_cmdshell', 1
                RECONFIGURE        
                EXEC sp_configure 'show advanced options', 0
                RECONFIGURE
            end try
            begin catch
            end catch;
        end

        --更新一个表时，默认有排他锁
        update AppLock set SessionCount=SessionCount+1 where [Name]='proc_ExportDataToExcel'
        set @sql='master..xp_cmdshell ''bcp "select * from '+@database+'.dbo.'+@tableName+'" queryout "'+@fileSavePath+'" -w -S"'+@server+'" -U"'+@uid+'" -P"'+@pwd+'"'''        
        exec (@sql)
        update AppLock set SessionCount=SessionCount-1 where [Name]='proc_ExportDataToExcel'
        set @errorSum = @errorSum+1

        declare @sessionCount2 int
        select @sessionCount2=SessionCount from AppLock where [Name]='proc_ExportDataToExcel'
        if @sessionCount2=0
        begin
            /*关闭xp_cmdshell，加锁使用才能不造成冲突*/
            begin try            
                EXEC sp_configure 'show advanced options', 1
                RECONFIGURE
                EXEC sp_configure 'xp_cmdshell', 0
                RECONFIGURE    
                EXEC sp_configure 'show advanced options', 0
                RECONFIGURE
            end try
            begin catch
            end catch;
        end
    end try
    begin catch  
        exec (@dropTableSql)
        declare @errorMsg nvarchar(4000)
        set @errorMsg=ERROR_MESSAGE()  
        if(@errorMsg is not null)
            raiserror(@errorMsg,16,1)
        return @errorSum
    end catch;
        
    exec (@dropTableSql)  --删除数据临时表      
    return @errorSum
END
GO
