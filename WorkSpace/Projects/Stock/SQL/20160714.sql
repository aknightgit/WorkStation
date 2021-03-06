/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [StockCode]
      ,[StockName]
      ,[Day]
      ,[BeginPrice]
      ,[HighPrice]
      ,[LowPrice]
      ,[EndPrice]
      ,[Volumn]
      ,[Amount]
  FROM [Staging].[dms].[StockHistory_20160711]
  --where day=20160705

  use Stock

  select distinct StockCode,StockName,min(Day) StartDate,Max(Day) EndDate
  into #history
  from [Staging].[dms].[StockHistory_20160711]
  group by StockCode,StockName

  insert into  dbo.DimStockList 
  (StockCode	,StockName	,StartDate	,EndDate	,IsCurrent)
  select distinct
  h.StockCode,h.StockName,h.StartDate,NULL,1 from #history h
  left join dbo.DimStockList d
  on h.StockCode =d.StockCode
  where d.StockCode is null;

  update d
  set d.StartDate = h.StartDate
  from  dbo.DimStockList d
  join  #history h
  on d.StockCode =h.StockCode
  and d.StockName =h.StockName
  --and d.IsCurrent = 0;
  
  update f
	set f.BeginPrice=s.BeginPrice,
		f.HighPrice=s.HighPrice,
		f.LowPrice = s.LowPrice,
		f.EndPrice = s.EndPrice,
		f.Volumn =s.Volumn/10000.00,
		f.Amount =s.Amount/10000.00
  from dbo.FctStockDaily f
  join dbo.DimStockList d
  on f.StockID =d.ID
  join [Staging].[dms].[StockHistory_20160711] s
  on f.day=s.Day
  and d.StockCode =s.StockCode;

  insert into dbo.FctStockDaily(Day,StockID,EndPrice,BeginPrice,HighPrice,LowPrice,Volumn,Amount)
  select s.Day,d.ID,s.EndPrice,s.BeginPrice,s.HighPrice,s.LowPrice,s.Volumn/10000.00,s.Amount/10000.00
  from [Staging].[dms].[StockHistory_20160711] s
  join dbo.DimStockList d
  on s.StockCode=d.StockCode
  and d.IsCurrent=1
  left join dbo.FctStockDaily f
  on d.ID =f.StockID
  and s.Day =f.Day
  where f.StockID is null;

  select * from dbo.DimStockList d where LastUpdate>= '2016-7-13'
  or stockcode=600000

  select * from dbo.FctStockDaily where StockID=(select id from dbo.DimStockList where stockcode =600000)
  order by day
  select top 100 * from [Staging].[dms].[StockHistory_20160711] where StockCode=600000 order by day desc

  create nonclustered index ix_FctStockDaily_DayStockID ON dbo.FctStockDaily
  (Day,StockID)

  use Stock
  select top 100 * from dbo.FctStockDaily
  order by day desc

  sp_spaceused 'dbo.fctstockdaily'

  select 

  alter table dbo.FctStockDaily
  add  StockCode nvarchar(255) null

  drop index  ix_FctStockDaily_DayStockID
  on  dbo.FctStockDaily
  create index   ix_FctStockDaily_DayIDCode on dbo.FctStockDaily(Day, StockID,StockCode)



  select * from dbo.FctStockDaily
  where EndPrice <> isnull(LastPrice,0) + isnull(UpAndDown,0)
  and StockID in (select id from dbo.DimStockList where stockcode =600000)
  Union
  select a.* from dbo.FctStockDaily a
  left join  dbo.FctStockDaily b
  on a.StockCode = b.StockCode
  and b.Day = (select max(Day) from dbo.FctStockDaily where StockCode = a.StockCode and Day<a.Day)
  where isnull(a.LastPrice,0) <> b.EndPrice
  and a.StockID in (select id from dbo.DimStockList where stockcode =600000)
  union
  select * from dbo.FctStockDaily
  where rate  <> cast(isnull(UpAndDown,0)*100/LastPrice as decimal(9,2))
  and  StockID in (select id from dbo.DimStockList where stockcode =600000)
  and Day>=
20160627
select 0.217/15.64
  begin tran
  update a
  set a.stockcode = b.stockcode
  from dbo.FctStockDaily a
  join dbo.DimStockList b
  on a.StockID=b.ID
  commit
  select top 100 * from dbo.FctStockDaily a
  order by day,stockid
  where stockcode is null

  DROP   CONSTRAINT PK__FctStock__3214EC27512B7B57 ON dbo.FctStockDaily
  alter TABLE dbo.FctStockDaily
  drop COLUMN ID

  drop index UX_FctStockDaily on 
  dbo.FctStockDaily
  drop index ix_FctStockDaily_DayIDCode on 
  dbo.FctStockDaily

  alter table dbo.FctStockDaily
  alter column [Day] [int] not NULL
  
  alter table dbo.FctStockDaily
  alter column [StockID] [int] not NULL
  
  alter table dbo.FctStockDaily
  alter column [StockCode] [int] not NULL

  alter table dbo.FctStockDaily
  add constraint pk_FctStockDaily primary key  ([Day],[StockID],[StockCode])