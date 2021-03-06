/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [ID]
      ,[StockCode]
      ,[StockName]
      ,[StartDate]
      ,[EndDate]
      ,[IsCurrent]
      ,[LastUpdate]
  FROM [Stock].[aud].[DuplicateStockList]

  select * from dbo.DimStockList
  where LastUpdate>dateadd(minute,-5,getdate())

  select * from dbo.DimStockList
  where stockcode in (600095,
600215,
600360,
600491,
600500,
601088)
order by 2,4
select * from staging.dms.DimStockDaily b
where StockCode=600095
select * from cdc.dbo_DimStockList_CT
where StockCode=600095

update dbo.DimStockList
set EndDate=20160705
where  stockcode in (600095,
600215,
600360,
600491,
600500,
601088)
and IsCurrent=0

  select StockCode,min(ID) ID
  into #first
  from [Stock].[aud].[DuplicateStockList]
  group by Stockcode

  select distinct stockcode, ID
  into #later
  from [Stock].[aud].[DuplicateStockList]
  where ID not in (select ID from #first)

  --select * from #later
  --order by 1
  begin tran
  update f
  set f.StockID = s.ID
  from [dbo].[FctStockDaily] f
  join #later l
  on f.stockid=l.id
  join #first s
  on l.stockcode =s.stockcode

  delete a
  from dbo.DimStockList a
  join #later l
  on a.ID=l.ID

  update a
  set IsCurrent = 1,
	EndDate = NULL
  from dbo.DimStockList a
  join #first f
  on a.ID=f.ID

  commit

rollback

  select distinct day into #days
     from dbo.fctstockdaily

	 use stock
 --update a
 update d
 set d.IsHoliday=1,d.IsOpen=0
 from (
 select a.*
 from 
 [ref].[Calender] a
 left join #days b
 on a.DateKey=b.Day
 where a.datekey between (select min(day) from #days) and (select max(day) from #days)
 and b.day is null
 and a.IsOpen=1
 )d