--use stock


--select * from dbo.DimStockList
--where stockcode=600029
--select * from [Staging].dms.dimstockdaily
--where stockcode=600029
--select * from dbo.errorlog


--drop index ux_



--exec dms.DimStockDaily_load
--go
--exec dms.DimIndexes_load


--exec  dbo.DimStockList_upsert 'Staging';
--go
--exec dbo.FctStockDaily_upsert '[Staging]'
--go
--exec [dbo].[FctIndexDaily_upsert] '[Staging]'

--BULK INSERT dms.DimStockDaily
--	   FROM ''D:\Home\indir\stockdaily_'+ @date +'.txt''
--	   WITH 
--		  (
--			 FIELDTERMINATOR =''|'',
--			 ROWTERMINATOR =''\n'', 
--			 FIRSTROW = 1
--		  );
--		  ---------------
declare @cmd nvarchar(1000);
declare @file nvarchar(500);
declare @files table (filepath varchar(500))
insert into @files(filepath)
EXEC master.dbo.xp_cmdshell 'dir /b/s d:\home\indir' 
delete from @files
where filepath not like '%#[0-9][0-9][0-9][0-9][0-9][0-9].txt'

delete from @files
where filepath is null
select * from @files
while exists (select top 1 1 from @files)
begin
select top 1 @file =  filepath from @files;
set @cmd ='';
select @cmd = 'BULK INSERT dms.StockHistory_20160630
	   FROM '''+@file+'''
	   WITH 
		  (
			 FIELDTERMINATOR =''|'',
			 ROWTERMINATOR =''\n'', 
			 FIRSTROW = 1
		  );'
		  exec(@cmd);
		  delete from @files where filepath=@file
end

use staging
create table dms.StockHistory_20160630
(	[StockCode] [nvarchar](255) NULL ,
	[StockName] [nvarchar](255) NULL,
	[Day] [int] NULL,
	[BeginPrice] [decimal](19, 2) NULL,
	[HighPrice] [decimal](19, 2) NULL,
	[LowPrice] [decimal](19, 2) NULL,
	[EndPrice] [decimal](19, 2) NULL,	
	[Volumn] [decimal](19, 2) NULL,
	[Amount] [decimal](19, 2) NULL	
)

select * from [Staging].dms.StockHistory_20160630
where stockcode ='002186'
where stockname ='ÆÖ·¢ÒøÐÐ'
--truncate table dms.StockHistory_20160630
delete from  dms.StockHistory_20160711
where DAY=20160706

truncate table  dms.StockHistory_20160630

update dms.StockHistory_20160630
set Volumn = volumn/10000, amount=amount/10000

select distinct stockcode,stockname, LEN(StockName) 
--into #stocklist
from dms.StockHistory_20160711
order by LEN(StockName)

select * from 
#stocklist
begin tran
use [Stock]
update a
set
	a.EndDate = convert(varchar(8),getdate(),112),
	IsCurrent = 0,
	LastUpdate = getdate()
from dbo.DimStockList a
join #stocklist b
on a.StockCode = b.StockCode
and a.StartDate < convert(varchar(8),getdate(),112)
and a.StockName <> b.StockName
and a.IsCurrent = 1;
			
insert into dbo.DimStockList(StockCode ,StockName ,StartDate ,EndDate ,IsCurrent )
select distinct b.StockCode,b.StockName,convert(varchar(8),getdate(),112),null,1
from dbo.DimStockList a
join #stocklist b
on  a.StockCode = b.StockCode
where a.IsCurrent = 0
and b.StockCode not in (select StockCode from dbo.DimStockList where IsCurrent = 1);


insert into dbo.DimStockList(StockCode,StockName ,StartDate ,EndDate ,IsCurrent )
select b.StockCode,b.StockName,convert(varchar(8),getdate(),112),null,1
from #stocklist b
left join dbo.DimStockList a
on  a.StockCode = b.StockCode
where a.StockCode is null

rollback
select * from  dbo.DimStockList a
order by LastUpdate desc

select * from [Stock].dbo.DimStockList a
where StockCode in (
000402,
000525,
000876,
002043,
002095,
002165,
002186,
002264,
000514,
000671,
002001,
002032,
002034,
002058,
002081,
002213,
000088,
000989,
002029,
002076,
002089,
002181,
002224,
000061,
000533,
000635,
000735,
000858,
000997,
002040,
002154,
002209,
000528,
002060,
002206,
002215,
002227,
002268,
000058,
000890,
000931,
002136,
002161,
002183,
002251,
002263)
begin tran
update b set b.stockname=a.stockname from 
dms.StockHistory_20160711 b
left join [Stock].dbo.DimStockList a
on b.stockcode =a.StockCode
and LEN(b.stockname)<len(a.StockName)
and a.IsCurrent=1
where a.StockName is not null
and len(b.stockname)=4
commit

select distinct b.stockcode,b.stockname,a.stockname from dms.StockHistory_20160711 b
left join [Stock].dbo.DimStockList a
on b.stockcode =a.StockCode
and LEN(b.stockname)<len(a.StockName)
and a.IsCurrent=1
where a.StockName is not null
and len(b.stockname)=4

select distinct b.stockcode,b.stockname,a.stockname from dms.StockHistory5min_20160711 b
left join [Stock].dbo.DimStockList a
on b.stockcode =a.StockCode
and LEN(b.stockname)<len(a.StockName)
and a.IsCurrent=1
where a.StockName is not null
and len(b.stockname)=4


begin tran
update b set b.stockname=a.stockname 
from dms.StockHistory5min_20160711 b
left join [Stock].dbo.DimStockList a
on b.stockcode =a.StockCode
and LEN(b.stockname)<len(a.StockName)
and a.IsCurrent=1
where a.StockName is not null
commit


select * from [Stock].dbo.DimStockList 
where StockCode=
300519
begin tran
insert into [Stock].dbo.DimStockList (StockCode,	StockName,	StartDate,	EndDate,	IsCurrent)
select distinct a.StockCode,a.StockName,a.StartDate,a.EndDate,
case when a.EndDate =convert(varchar(8),getdate(),112) then 1 else 0 end 
from (
select StockCode,StockName, min(Day) StartDate,Max(Day) EndDate 
from dms.StockHistory_20160711
group by StockCode,StockName)a
left join [Stock].dbo.DimStockList b
on a.StockCode=b.StockCode
where b.StockCode is null


update a
set a.StartDate = case when a.StartDate>b.StartDate then b.StartDate else a.StartDate end,
a.EndDate = case when b.EndDate=convert(varchar(8),getdate(),112) then null else a.EndDate end,
a.IsCurrent = case when b.EndDate=convert(varchar(8),getdate(),112) then 1 else 0 end
from [Stock].dbo.DimStockList a
join (select StockCode,StockName, min(Day) StartDate,Max(Day) EndDate 
from dms.StockHistory_20160711
group by StockCode,StockName)b
on a.StockCode = b.StockCode
and a.StockName = b.StockName


select * from [Stock].dbo.DimStockList b
where StockCode=600006

rollback

select * from stock.dbo.dimstocklist where stockcode in (
select stockcode
from stock.dbo.dimstocklist
group by stockcode
having count(1)>1)


select StockCode,StockName
from stock.dbo.dimstocklist
group by StockCode,StockName
having count(1)>1

use Stock
create view 


as

with stocklist as(
SELECT StockName,StockCode,ROW_NUMBER() over(partition by StockCode,StockName order by ID) RID
FROM stock.dbo.DimStockList)
select distinct ds.* from stock.dbo.DimStockList ds
join (
select a.StockCode,a.StockName,a.RID
from stocklist a
LEFT join stocklist b
on a.stockcode=b.StockCode
and a.StockName = b.StockName
and a.RID = b.RID+1
where b.RID is not null)x
on ds.StockCode=x.StockCode
and ds.StockName=x.StockName
--order by ds.StockCode,ds.StockName,ds.StartDate

select * from dbo.DuplicateStockList