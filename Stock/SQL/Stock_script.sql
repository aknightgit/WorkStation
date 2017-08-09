create table dbo.DimIndexes
(	ID int identity(1,1),
	Name nvarchar(200),
	LastUpdate datetime default(getdate())
)
droP table dbo.FctIndexDaily
create table dbo.FctIndexDaily(
	[Day] int not null,
	IndexID int not null,
	Point decimal(19,2),
	UpAndDown decimal(19,2),
	Rate decimal(19,2),
	LastPoint decimal(19,2),
	BeginPoint decimal(19,2),
	HighPoint decimal(19,2),
	LowPoint decimal(19,2),
	Volumn decimal(19,2),
	Amount decimal(19,2),
	LastUpdate datetime
)
select * from FctIndexDaily
select * from DimIndexes

create schema sys.tables 

create table ref.Calender(
	DateKey int primary key clustered,
	CalenderDate datetime not null,
	IsOpen bit not null default(1),
	IsWeekend bit not null,
	IsHoliday bit not null default(0),
	Comments nvarchar(500),
	LastUpdate datetime default(getdate())
	)

declare @start datetime = '2001-1-1'
,@end datetime ='2099-12-31'

select @start =max(calenderdate) from ref.Calender;
while (@start<@end)
begin
	select @start= dateadd(dd,1,@start);
	--select datepart(weekday,getdate())
	insert into ref.Calender
	select convert(varchar(8),@start,112),@start,1,
	case when datepart(WEEKDAY,@start) in (1,7) then 1 else 0 end,
	case when datepart(DAY,@start)=1 and DATEPART(MONTH,@start) in (5,10,1) then 1 else 0 end,
	null,
	getdate()

	
end
update ref.Calender
set IsOpen =0 where IsWeekend=1 or IsHoliday =1

select * from ref.Calender

create table dbo.FctStockDaily
(	ID bigint identity(1,1) primary key clustered,
	[Day] int,
	StockID int,
	AssessmentID int,
	StateID int,
	EndPrice decimal(19,2),
	UpAndDown decimal(19,2),
	Rate decimal(19,2),
	LastPrice decimal(19,2),
	BeginPrice decimal(19,2),
	HighPrice decimal(19,2),
	LowPrice decimal(19,2),
	Volumn decimal(19,2),
	Amount decimal(19,2),
	LastUpdate datetime default(getdate())
)

select * from dbo.FctStockDaily
order by day,rate desc

exec dbo.FctStockDaily_upsert '[Staging]'
go
drop proc dbo.FctStockDaily_upsert
go
create proc dbo.FctStockDaily_upsert
	@stagingdbname sysname
as 
begin
set nocount on;

	declare @cmd varchar(1024);
	
	begin try
	set @cmd ='
	insert into dbo.FctStockDaily
	(	[Day] ,	StockID ,	AssessmentID ,	StateID ,	EndPrice ,	UpAndDown ,
	Rate ,	LastPrice ,	BeginPrice ,	HighPrice ,	LowPrice ,	Volumn ,	Amount )
	select s.[Day] , d.ID ,a.ID,NULL, s.EndPrice, s.UpAndDown ,
	s.Rate , s.LastPrice , s.BeginPrice , s.HighPrice , s.LowPrice ,s.Volumn ,s.Amount 
		from '+@stagingdbname+'.dms.DimStockDaily s
	inner join dbo.DimStockList d
	on s.StockCode = d.StockCode
	and d.IsCurrent = 1
	inner join dbo.DimStockAssessment a
	on s.Assessment = a.Assessment
	left join dbo.FctStockDaily f
	on d.ID = f.StockID
	and s.[Day] = f.[Day]
	where f.StockID is null
	'

	exec(@cmd);

	set @cmd ='
	update f
		set f.AssessmentID = a.ID,	
		StateID = '''',	
		f.EndPrice  = s.EndPrice,	
		f.UpAndDown = s.UpAndDown,
		f.Rate = s.Rate ,	
		f.LastPrice = s.LastPrice ,	
		f.BeginPrice = s.BeginPrice ,	
		f.HighPrice = s.HighPrice ,	
		f.LowPrice =s.LowPrice ,	
		f.Volumn = s.Volumn ,	
		f.Amount = s.Amount
		from '+@stagingdbname+'.dms.DimStockDaily s
	inner join dbo.DimStockList d
	on s.StockCode = d.StockCode
	and d.IsCurrent = 1
	inner join dbo.DimStockAssessment a
	on s.Assessment = a.Assessment
	left join dbo.FctStockDaily f
	on d.ID = f.StockID
	and s.[Day] = f.[Day]
	'

	exec(@cmd);
	end try
	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();
	raiserror(@errormsg,16,1);
	end catch
	

end
go

drop table dbo.DimStockList
go
Create table dbo.DimStockList
(
	ID int identity(1,1) PRIMARY KEY CLUSTERED,
	StockCode nvarchar(255),
	StockName nvarchar(255),
	StartDate int,
	EndDate int,
	IsCurrent bit,
	LastUpdate datetime default(getdate())
)
go
select * from dbo.DimStockList
order by 2,3
where IsCurrent=1

select * from dbo.DimStockList
where enddate is not null
select * from dbo.DimStockList
where stockcode in (600054,
600055,
600072,
900907,
900942,
600123,
600162,
600232)
select a.*
from dbo.DimStockList a
		join staging.dms.DimStockDaily b
		on a.StockCode = b.StockCode
		and a.StartDate < convert(varchar(8),getdate(),112)
		--and a.StockName <> b.StockName
		and a.id=258

if (select stockname from dbo.DimStockList where id=258)<>(select stockname from dbo.DimStockList where id=3224)
print 'hi'

select StockCode,stockname
from dbo.dimstocklist
group by StockCode,stockname
having(count(1)>1)

delete from dbo.dimstocklist where id<=221

truncate table dbo.DimStockList

exec  dbo.DimStockList_upsert 'Staging';

drop  proc dbo.DimStockList_upsert
go
create proc dbo.DimStockList_upsert
	@stagingdbname sysname
as
begin
--set nocount on

	declare @cmd varchar(max);
	begin try

	set @cmd = 'update a
		set a.StockName = b.StockName,
			a.EndDate = convert(varchar(8),getdate(),112),
			IsCurrent = 0,
			LastUpdate = getdate()
		from dbo.DimStockList a
		join '+@stagingdbname+'.dms.DimStockDaily b
		on a.StockCode = b.StockCode
		and a.StartDate < convert(varchar(8),getdate(),112)
		and a.StockName <> b.StockName
			
		insert into dbo.DimStockList(StockCode ,StockName ,StartDate ,EndDate ,IsCurrent )
		select a.StockCode,a.StockName,convert(varchar(8),getdate(),112),null,1
		from dbo.DimStockList a
		join '+@stagingdbname+'.dms.DimStockDaily b
		on  a.StockCode = b.StockCode
		where a.IsCurrent = 0
		'
	exec(@cmd);

	set @cmd ='insert into dbo.DimStockList(StockCode,StockName ,StartDate ,EndDate ,IsCurrent )
	select b.StockCode,b.StockName,convert(varchar(8),getdate(),112),null,1
	from '+@stagingdbname+'.dms.DimStockDaily b
	left join dbo.DimStockList a
	on  a.StockCode = b.StockCode
	where a.StockCode is null
	'
	exec(@cmd);

	end try
	begin catch
		raiserror ('',16,1);

	end catch	
	
end

select * from dbo.DimStockAssessment
create table dbo.DimStockAssessment
(	ID int identity(1,1),
	Assessment varchar(100),
	AssessRank int,
	LastUpdate datetime
)
go

exec dbo.DimStockAssessment_upsert '[Staging]'
drop proc dbo.DimStockAssessment_upsert
go
create proc dbo.DimStockAssessment_upsert
	@stagingdbname sysname
as
begin
set nocount on;

	declare @cmd varchar(1024);
	
	begin try
	set @cmd ='
	declare @StockCode int;
	declare @stockassessment nvarchar(100);

	select StockCode into #StockCodelist from '+@stagingdbname+'.dms.DimStockDaily
	
	select top 1 @StockCode = StockCode from #StockCodelist
	while exists(select 1  from #StockCodelist)
	begin
	select @stockassessment = Assessment from '+@stagingdbname+'.dms.DimStockDaily
	where StockCode = @StockCode

	if not exists(select 1 from  dbo.DimStockAssessment where Assessment =  @stockassessment)
	begin
		insert into dbo.DimStockAssessment(Assessment)
		select @stockassessment
	end

	delete from #StockCodelist
	where  StockCode = @StockCode;
	select top 1 @StockCode = StockCode from #StockCodelist

	end'
	exec(@cmd);
	end try
	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();
	raiserror(@errormsg,16,1);
	end catch
	

end

create table dbo.execlog
(	ID bigint identity(1,1),
	ExecName nvarchar(200),
	StartTime datetime default(getdate()),
	EndTime datetime,
	UpdateBy nvarchar(200)
)
go
create proc dbo.execlog_insert
	@name nvarchar(200) = '',
	@execID bigint output
as
begin
set nocount on;

	begin try
		begin tran	
		insert into dbo.execlog(ExecName,StartTime,UpdateBy)
		select @name,getdate(),user_id();

		select @execID = SCOPE_IDENTITY();

		commit
	end try
	begin catch
	if @@TRANCOUNT>0 
	rollback;

	declare @errormsg varchar(500) = ERROR_MESSAGE();
	raiserror(@errormsg,16,1);
	end catch
end


go
create proc dbo.execlog_update
	@name nvarchar(200) ,
	@execID bigint 
as
begin
set nocount on;

	begin try
		begin tran	
		if exists(select top 1 1 from dbo.execlog where ID = @execID )
		begin
		update  dbo.execlog
		set EndTime = getdate(), UpdateBy = user_id();
		
		end
		commit
	end try
	begin catch
	if @@TRANCOUNT>0 
	rollback;

	declare @errormsg varchar(500) = ERROR_MESSAGE();
	raiserror(@errormsg,16,1);
	end catch
end

go


create proc dbo.execlog_update
	@name nvarchar(200) ,
	@execID bigint 
as
begin
set nocount on;

	begin try
		begin tran	
		if exists(select top 1 1 from dbo.execlog where ID = @execID )
		begin
		update  dbo.execlog
		set EndTime = getdate(), UpdateBy = user_id();
		
		end
		commit
	end try
	begin catch
	if @@TRANCOUNT>0 
	rollback;

	declare @errormsg varchar(500) = ERROR_MESSAGE();
	raiserror(@errormsg,16,1);
	end catch
end