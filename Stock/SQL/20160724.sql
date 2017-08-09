select top 10 * from [cdc].[dbo_FctStockDaily_CT]

select min(__$start_lsn),max(__$start_lsn) from  [cdc].[dbo_FctStockDaily_CT]

sys.help_cdc_jobs
[sys].[sp_cdc_help_jobs]

select * from cdc.lsn_time_mapping
where start_lsn in (0x000002FF000033D70049,
0x0000020C000096270003)

select top 10 * from [cdc].[dbo_FctStockDaily_CT]
order by 1 desc

select count(1) from 
select top 10 * from ref.Calender


SELECT top 100*, StockCode,Day
FROM dbo.FctStockDaily f with(nolock)
full join ref.Calender c 
on f.Day = c.DateKey
and c.IsOpen = 1
--where stockcode =000001
where f.StateID=1
--where c.DateKey is null
--GROUP BY StockCode,Day
order by 1 desc,2

select * from  dbo.FctStockDaily f with(nolock)
where stockcode=
600035
order by 1


select f.Day,f.StockCode,c.DateKey from (
select Day,StockCode from dbo.FctStockDaily f with(nolock)
where StateID <>1
and stockcode=600035)f
full join ref.Calender c
on  f.Day = c.DateKey

order by 1



select top 1000 * from dbo.FctStockDaily f with(nolock)
join (
select StockCode,min(Day) minDay,max(Day) maxDay from dbo.FctStockDaily f with(nolock)
group by StockCode)b
on f.StockCode = b.StockCode
--and  f.StockCode=600035
right join ref.Calender c
on f.Day = c.DateKey
where  c.DateKey between b.minDay and b.maxDay
and c.IsOpen =1
and isnull(f.StateID,0) <> 1
--and f.Day is null
order by c.DateKey 


update  f
set f.StateID = 1

--select f.*
from dbo.FctStockDaily f
join 
(
select x.StockCode,x.DateKey
from (
select b.StockCode,c.DateKey  from ref.Calender c
join(
select StockCode,min(Day) minDay,max(Day) maxDay from dbo.FctStockDaily f with(nolock)
group by StockCode)b
on c.DateKey between b.minDay and b.maxDay
where c.IsOpen=1
--where b.StockCode=600035
)x
left join dbo.FctStockDaily f with(nolock)
on x.DateKey = f.Day
and x.StockCode = f.StockCode
and isnull(f.StateID,0)<>1
where f.Day is null
--order by 1 ,2
)a
on f.StockCode=a.StockCode
and f.Day = a.DateKey
and f.StateID<>1