USE [Staging]
GO
CREATE SCHEMA [dms] AUTHORIZATION [dbo]
GO
drop TABLE dms.DimStockDaily
CREATE TABLE dms.DimStockDaily
(
	StockCode nvarchar(255),
	StockName nvarchar(255),	
	Assessment nvarchar(500),
	EndPrice decimal(19,2),
	UpAndDown decimal(19,2),
	Rate decimal(19,2),
	LastPrice decimal(19,2),
	BeginPrice decimal(19,2),
	HighPrice decimal(19,2),
	LowPrice decimal(19,2),
	Volumn decimal(19,2),
	Amount decimal(19,2),
	[Day] int
)

alter table dms.dimstockdaily
add Day int
select * from dms.DimStockDaily
go

drop TABLE dms.DimIndexes
go
CREATE TABLE dms.DimIndexes
(
	ID int ,	
	Point decimal(19,2),
	UpAndDown decimal(19,2),
	Rate decimal(19,2),
	LastPoint decimal(19,2),
	BeginPoint decimal(19,2),
	HighPoint decimal(19,2),
	LowPoint decimal(19,2),
	Volumn decimal(19,2),
	Amount decimal(19,2),
	IndexName nvarchar(100),
	[Day] int
)

--sp_configure 
--EXEC sp_configure 'show advanced options', 1;
--RECONFIGURE;
--EXEC sp_configure 'xp_cmdshell', 1;
--RECONFIGURE;

--select * from  Staging.dms.DimStockDaily
--truncate table dms.DimStockDaily
--go
--exec master..xp_cmdshell 'bcp Staging.dms.DimStockDaily in D:\Home\indir\stockdaily_20160624.txt -c -t"|" -T'
	BULK INSERT Staging.dms.DimStockDaily
	   FROM 'D:\Home\indir\stockdaily_20160627.txt'
	   WITH 
		  (
			 FIELDTERMINATOR ='|',
			 ROWTERMINATOR ='\n', 
			 FIRSTROW = 1
		  );
go
drop proc dms.DimStockDaily_load
go
create proc dms.DimStockDaily_load
as
begin
	declare @cmd varchar(1024);
	declare @date varchar(8);
	truncate table dms.DimStockDaily;
	--go
	
	select @date = case when datepart(hour,getdate())>19 then convert(varchar(8),getdate(),112)
		else convert(varchar(8),getdate() -1 ,112) end

	begin try
	set @cmd='
	BULK INSERT dms.DimStockDaily
	   FROM ''D:\Home\indir\stockdaily_'+ @date +'.txt''
	   WITH 
		  (
			 FIELDTERMINATOR =''|'',
			 ROWTERMINATOR =''\n'', 
			 FIRSTROW = 1
		  );'
	exec(@cmd);
	end try
	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();
	raiserror(@errormsg,16,1);
	end catch
end

	--BULK INSERT dms.DimIndexes
	--   FROM 'D:\Home\indir\indexdaily_20160628.txt'
	--   WITH 
	--	  (
	--		 FIELDTERMINATOR ='|',
	--		 ROWTERMINATOR ='\n', 
	--		 FIRSTROW = 2
	--	  );
drop proc dms.DimIndexes_load
go
create proc dms.DimIndexes_load
as
begin
	declare @cmd varchar(1024);
	declare @date varchar(8);
	--go
	
	select @date = case when datepart(hour,getdate())>19 then convert(varchar(8),getdate(),112)
		else convert(varchar(8),getdate() -1 ,112) end

	begin try
	set @cmd='
	BULK INSERT dms.DimIndexes
	   FROM ''D:\Home\indir\indexdaily_'+ @date +'.txt''
	   WITH 
		  (
			 FIELDTERMINATOR =''|'',
			 ROWTERMINATOR =''\n'', 
			 FIRSTROW = 2
		  );'
	print @cmd;
	exec(@cmd);
	end try
	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();
	raiserror(@errormsg,16,1);
	end catch
end