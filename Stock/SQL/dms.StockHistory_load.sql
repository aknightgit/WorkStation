USE [Staging]
GO
/****** Object:  StoredProcedure [dms].[DimStockDaily_load]    Script Date: 2016/7/11 21:10:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter proc [dms].[StockHistory_load]
	@date int = null
as
begin
	declare @cmd varchar(1024);
	declare @stagingtablename nvarchar(100);

	select @date = isnull(@date,convert(varchar(8),getdate(),112));

	select @stagingtablename = 'dms.StockHistory_'+convert(varchar(8),@date);

	select @cmd ='if exists(select 1 from sys.tables where name = '''+replace(@stagingtablename,'dms.','')+''')
		drop table '+@stagingtablename+';
create table '+@stagingtablename+'
(	[StockCode] [nvarchar](255) NULL ,
	[StockName] [nvarchar](255) NULL,
	[Day] [int] NULL,
	[BeginPrice] [decimal](19, 2) NULL,
	[HighPrice] [decimal](19, 2) NULL,
	[LowPrice] [decimal](19, 2) NULL,
	[EndPrice] [decimal](19, 2) NULL,	
	[Volumn] [decimal](19, 2) NULL,
	[Amount] [decimal](19, 2) NULL	
)'
	--go

	exec(@cmd);

	begin try
	set @cmd='
	declare @cmd nvarchar(1000);
declare @file nvarchar(500);
declare @files table (filepath varchar(500))
insert into @files(filepath)
EXEC master.dbo.xp_cmdshell ''dir /b/s d:\home\indir''
delete from @files
where filepath not like ''%#[0-9][0-9][0-9][0-9][0-9][0-9].txt''

delete from @files
where filepath is null
--select * from @files
while exists (select top 1 1 from @files)
begin
select top 1 @file =  filepath from @files;
set @cmd ='''';
select @cmd = ''BULK INSERT '+@stagingtablename+'
	   FROM ''''''+@file+''''''
	   WITH 
		  (
			 FIELDTERMINATOR =''''|'''',
			 ROWTERMINATOR =''''\n'''', 
			 FIRSTROW = 1
		  );''
		  exec(@cmd);
		  delete from @files where filepath=@file
end;'
	--print @cmd;
	exec(@cmd);

	set @cmd ='
	select distinct b.stockcode,b.stockname,a.stockname from '+@stagingtablename+' b
left join [Stock].dbo.DimStockList a
on b.stockcode = a.StockCode
and b.stockname <> a.StockName
and a.IsCurrent=1
where a.StockName is not null'

	end try
	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();
	raiserror(@errormsg,16,1);
	end catch
end