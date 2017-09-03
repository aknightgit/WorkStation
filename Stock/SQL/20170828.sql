use stock
select top 100 *from dbo.DimStockList
order by LastUpdate desc

select * from dbo.DimStockList
where iscurrent=0

select * from dbo.DimStockList
where StockCode in (
select stockcode from dbo.DimStockList
where IsCurrent=0)
order by stockcode,stockname

select replace(stockname,' ',''),* from staging.dms.dimstockdaily
where stockcode='000088'

use Stock
select * from dbo.DimStockList
select *from dbo.DimStockAssessment

select *from dbo.FctStockDaily with(nolock)
where stockcode ='000001'
--and day between 20070510 and 20070625
and rate<-10
sp_who2

select day,count(stockcode) from dbo.FctStockDaily
group by day

update dbo.FctStockDaily
set Volumn=Volumn*10000
,Amount=amount*10000
where day=20170817

truncate table dbo.FctStockDaily
select * from  dbo.FctStockDaily

use stock
alter table dbo.fctstockdaily
add  MonthKey int null

select top 100 * from dbo.FctStockDaily

update dbo.fctstockdaily
set Monthkey = left(Day,6)

use stock
select * from dbo.fctstockdaily
where stockcode='000001'
and Volumn=0

create nonclustered index idx_FctStockDaily_StockCode on dbo.FctStockDaily(StockCode ASC)

create nonclustered index idx_FctStockDaily_Day on dbo.FctStockDaily(Day ASC)


update a
set a.stateid=0
from dbo.FctStockDaily a

update a
set Rate = UpAndDown/LastPrice * 100.00
from dbo.FctStockDaily a

select * from dbo.FctStockDaily
where LastPrice=0.00

alter table dbo.FctStockDaily
alter column EndPrice decimal(10,4) 

alter table dbo.FctStockDaily
alter column LastPrice decimal(10,4) 

alter table dbo.FctStockDaily
alter column BeginPrice decimal(10,4) 

alter table dbo.FctStockDaily
alter column HighPrice decimal(10,4) 

alter table dbo.FctStockDaily
alter column LowPrice decimal(10,4) 
alter table dbo.FctStockDaily
alter column UpAndDown decimal(10,4) 

alter table  dbo.fctstockdaily
drop CONSTRAINT [pk_FctStockDaily]

alter table dbo.fctstockdaily
add 
 CONSTRAINT [pk_FctStockDaily] PRIMARY KEY CLUSTERED 
(
	[Day] ASC,
	[StockCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


	SELECT c.name,isnull(i.is_primary_key,0)
	FROM Sys.Columns c
	left join sys.index_columns ic
	on c.object_id = ic.object_id and c.column_id =ic.column_id
	left join sys.indexes i
	on ic.object_id =i.object_id
	and i.is_primary_key=1
	Where c.object_id=Object_Id('dbo.fctstockdaily');

	select *from sys.columns where object_id=Object_Id('dbo.fctstockdaily');
	select * from  sys.index_columns ic where object_id = 693577509 and column_id =1

	select * from sys.indexes i where object_id=693577509
	and is

	SELECT c.name,isnull(i.is_primary_key,0)
	FROM Sys.Columns c
	left join(
	select column_id, 1 as is_primary_key  from sys.index_columns ic
	where index_id=
	(	select index_id
		from sys.indexes where is_primary_key =1
		and object_id=Object_Id('dbo.fctstockdaily'))
	and object_id=Object_Id('dbo.fctstockdaily')
	)i
	on c.column_id =i.column_id
	Where c.object_id=Object_Id('dbo.fctstockdaily');
