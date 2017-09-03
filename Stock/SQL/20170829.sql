Could not obtain information about Windows NT group/user

USE stock 
GO 
ALTER DATABASE stock set TRUSTWORTHY ON; 
GO 
EXEC dbo.sp_changedbowner @loginame = N'sa', @map = false 
GO 
sp_configure 'show advanced options', 1; 
GO 
RECONFIGURE; 
GO 
sp_configure 'clr enabled', 1; 
GO 
RECONFIGURE; 
GO


sys.sp_cdc_enable_table   @source_schema ='dbo',
@source_name = 'DimStockList',
@supports_net_changes = 1,
@role_name = 'dbo',
@filegroup_name ='CDC'

USE STOCK
SELECT * FROM DBO.DimStockList
WHERE ISCURRENT=0


SELECT * FROM DBO.DimStockList
WHERE STOCKCODE IN (SELECT STOCKCODE FROM DBO.DimStockList
WHERE ISCURRENT=0)
ORDER BY 2,4

SELECT *FROM DBO.DimStockAssessment

SELECT * FROM DBO.FctStockDaily
WHERE DAY=20170823

SELECT * FROM STAGING.DMS.DimStockDaily

SELECT TOP 100 * from dbo.FctStockDaily
order by LastUpdate desc

select top 100 * from dbo.DimStockList
order by LastUpdate desc


[sys].[sp_cdc_disable_db]
[sys].[sp_cdc_enable_db]
use stock
sys.sp_cdc_enable_table   @source_schema ='dbo',
@source_name = 'DimStockList',
@supports_net_changes = 1,
@role_name = 'dbo',
@filegroup_name ='CDC'

  
  select top 100 *from dbo.FctStockDaily
  where stockcode='600011'
  order by day desc
  and day=20170821

  select top 100 *from dbo.FctStockDaily
  where stockcode='600011'
  order by LastUpdate  desc

  select * from staging.dms.DimStockDaily
  where stockcode='000001'
    select * from staging.dms.DimStockDaily
  where stockcode='600011'

  select top 100 *from dbo.errorlog
  order by 1 desc

  select identity(int,1,1) ID,s.*
  into #tmp
  from staging.dms.DimStockDaily s

  delete s
  from #tmp s
  JOIN
  (select stockcode,max(ID) ID from #tmp group by stockcode)b
  on s.stockcode = b.stockcode
  and s.ID < b.ID

  SELECT * FROM #tmp
  order by 2


  select s.*
  from #dmsdimstockdaily s
	inner join dbo.DimStockList d
	on s.StockCode = d.StockCode
	and d.IsCurrent = 1
	inner join dbo.DimStockAssessment a
	on s.Assessment = a.Assessment
	left join dbo.FctStockDaily f
	on d.ID = f.StockID
	and s.[Day] = f.[Day]
	where f.StockID is null
	and s.StockCode='600011'

