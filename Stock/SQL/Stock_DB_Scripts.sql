USE [master]
GO
/****** Object:  Database [Stock]    Script Date: 2017/8/24 23:33:53 ******/
CREATE DATABASE [Stock]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Stock', FILENAME = N'C:\AK\Data\DBFile\Stock.mdf' , SIZE = 1320064KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [CDC] 
( NAME = N'Stock_CDC', FILENAME = N'C:\AK\Data\DBFile\Stock_CDC.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Stock_log', FILENAME = N'C:\AK\Data\DBFile\Stock_log.ldf' , SIZE = 14557184KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [Stock] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Stock].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Stock] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Stock] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Stock] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Stock] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Stock] SET ARITHABORT OFF 
GO
ALTER DATABASE [Stock] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Stock] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Stock] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Stock] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Stock] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Stock] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Stock] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Stock] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Stock] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Stock] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Stock] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Stock] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Stock] SET TRUSTWORTHY ON 
GO
ALTER DATABASE [Stock] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Stock] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Stock] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Stock] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Stock] SET RECOVERY FULL 
GO
ALTER DATABASE [Stock] SET  MULTI_USER 
GO
ALTER DATABASE [Stock] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Stock] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Stock] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Stock] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Stock] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Stock', N'ON'
GO
ALTER DATABASE [Stock] SET QUERY_STORE = OFF
GO
USE [Stock]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [Stock]
GO
/****** Object:  User [cdc]    Script Date: 2017/8/24 23:33:53 ******/
CREATE USER [cdc] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[cdc]
GO
ALTER ROLE [db_owner] ADD MEMBER [cdc]
GO
/****** Object:  Schema [aud]    Script Date: 2017/8/24 23:33:53 ******/
CREATE SCHEMA [aud]
GO
/****** Object:  Schema [cdc]    Script Date: 2017/8/24 23:33:53 ******/
CREATE SCHEMA [cdc]
GO
/****** Object:  Schema [ref]    Script Date: 2017/8/24 23:33:53 ******/
CREATE SCHEMA [ref]
GO
/****** Object:  Table [dbo].[DimStockList]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimStockList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StockCode] [nvarchar](255) NULL,
	[StockName] [nvarchar](255) NULL,
	[StartDate] [int] NULL,
	[EndDate] [int] NULL,
	[IsCurrent] [bit] NULL,
	[LastUpdate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [aud].[DuplicateStockList]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [aud].[DuplicateStockList]
as

with stocklist as(
SELECT StockName,StockCode,ROW_NUMBER() over(partition by StockCode order by ID,StartDate) RID
FROM dbo.DimStockList)
select distinct ds.* from dbo.DimStockList ds
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


GO
/****** Object:  Table [dbo].[FctStockDaily]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FctStockDaily](
	[Day] [int] NOT NULL,
	[StockID] [int] NOT NULL,
	[AssessmentID] [int] NULL,
	[StateID] [int] NULL,
	[EndPrice] [decimal](10, 4) NULL,
	[UpAndDown] [decimal](10, 4) NULL,
	[Rate] [decimal](19, 2) NULL,
	[LastPrice] [decimal](10, 4) NULL,
	[BeginPrice] [decimal](10, 4) NULL,
	[HighPrice] [decimal](10, 4) NULL,
	[LowPrice] [decimal](10, 4) NULL,
	[Volumn] [decimal](19, 2) NULL,
	[Amount] [decimal](19, 2) NULL,
	[LastUpdate] [datetime] NULL,
	[StockCode] [varchar](255) NOT NULL,
	[MonthKey] [int] NULL,
 CONSTRAINT [pk_FctStockDaily] PRIMARY KEY CLUSTERED 
(
	[Day] ASC,
	[StockCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [aud].[OpenDay]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [aud].[OpenDay]
as
		select row_number() over(order by a.Day) ID,
		a.Day
		from (
		select distinct f.Day
		from dbo.FctStockDaily f
		)a
GO
/****** Object:  View [aud].[FctStockDaily_LastPrice]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [aud].[FctStockDaily_LastPrice]
as
	
	with StockDaylist as(select StockCode,Day,ROW_NUMBER() over(partition by StockCode order by Day) DayCnt
	from dbo.FctStockDaily with(nolock)
	where isnull(stateid,0) <>1)
	select top 100 cur.StockCode,cur.Day CurDay,lst.Day LstDay,cur.LastPrice,lst.EndPrice
	from dbo.FctStockDaily cur with(nolock)  
	join StockDaylist a
	on cur.StockCode = a.StockCode
	and cur.Day=a.Day
	left join StockDaylist b
	on a.StockCode = b.StockCode
	and a.DayCnt = b.DayCnt + 1
	left join dbo.FctStockDaily lst with(nolock)
	on b.StockCode = lst.StockCode
	and b.Day = lst.Day
	where cur.LastPrice<>lst.EndPrice






GO
/****** Object:  Table [dbo].[DimStockAssessment]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimStockAssessment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Assessment] [varchar](100) NULL,
	[AssessRank] [int] NULL,
	[LastUpdate] [datetime] NULL,
 CONSTRAINT [PK_DimStockAssessment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[errorlog]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[errorlog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[ErrorMessage] [nvarchar](2000) NULL,
	[LastUpdate] [datetime] NULL,
 CONSTRAINT [PK_errorlog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[execlog]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[execlog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecName] [nvarchar](200) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[UpdateBy] [nvarchar](200) NULL,
 CONSTRAINT [PK_execlog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [ref].[Calender]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ref].[Calender](
	[DateKey] [int] NOT NULL,
	[CalenderDate] [datetime] NOT NULL,
	[IsOpen] [bit] NOT NULL,
	[IsWeekend] [bit] NOT NULL,
	[IsHoliday] [bit] NOT NULL,
	[Comments] [nvarchar](500) NULL,
	[LastUpdate] [datetime] NULL,
	[IsProcessed] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [idx_FctStockDaily_Day]    Script Date: 2017/8/24 23:33:53 ******/
CREATE NONCLUSTERED INDEX [idx_FctStockDaily_Day] ON [dbo].[FctStockDaily]
(
	[Day] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_FctStockDaily_StockCode]    Script Date: 2017/8/24 23:33:53 ******/
CREATE NONCLUSTERED INDEX [idx_FctStockDaily_StockCode] ON [dbo].[FctStockDaily]
(
	[StockCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DimStockList] ADD  DEFAULT (getdate()) FOR [LastUpdate]
GO
ALTER TABLE [dbo].[execlog] ADD  DEFAULT (getdate()) FOR [StartTime]
GO
ALTER TABLE [dbo].[FctStockDaily] ADD  DEFAULT (getdate()) FOR [LastUpdate]
GO
ALTER TABLE [ref].[Calender] ADD  DEFAULT ((1)) FOR [IsOpen]
GO
ALTER TABLE [ref].[Calender] ADD  DEFAULT ((0)) FOR [IsHoliday]
GO
ALTER TABLE [ref].[Calender] ADD  DEFAULT (getdate()) FOR [LastUpdate]
GO
ALTER TABLE [dbo].[FctStockDaily]  WITH CHECK ADD  CONSTRAINT [FK_FctStockDaily_DimStockList] FOREIGN KEY([StockID])
REFERENCES [dbo].[DimStockList] ([ID])
GO
ALTER TABLE [dbo].[FctStockDaily] CHECK CONSTRAINT [FK_FctStockDaily_DimStockList]
GO
/****** Object:  StoredProcedure [aud].[FctStockDaily_LastPrice_fix]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [aud].[FctStockDaily_LastPrice_fix]
	
as
begin
--set nocount on
	declare @processname varchar(100) = 'aud.FctStockDaily_LastPrice_fix';

	declare @execID int;	

	begin try
	insert into [dbo].[execlog]([ExecName],[StartTime],[UpdateBy])
	select @processname,getdate(),suser_name();
	select @execID =@@IDENTITY;
		
		--update the first day, if LastPrice is null
		update a
		set a.LastPrice = a.BeginPrice,
			a.UpAndDown = a.EndPrice - a.BeginPrice,
			a.Rate = case when a.BeginPrice=0.00 then 0.00 else (a.EndPrice - a.BeginPrice)/a.BeginPrice*100.00 end
		from  dbo.FctStockDaily a
		join (
		select StockCode,min(Day) minDay
		from dbo.FctStockDaily with(nolock)
		group by StockCode)b
		on a.StockCode = b.StockCode
		and a.Day = b.minDay
		where a.LastPrice is null;

		;with StockDaylist as(select StockCode,Day,ROW_NUMBER() over(partition by StockCode order by Day) DayCnt
		from dbo.FctStockDaily with(nolock)
		where isnull(stateid,0) <>1)
		--select top 100 cur.StockCode,cur.Day,lst.Day,cur.LastPrice,lst.EndPrice
		update cur
		set cur.LastPrice = isnull(lst.EndPrice,cur.BeginPrice),
			cur.UpAndDown = cur.EndPrice - isnull(lst.EndPrice,cur.BeginPrice),
			cur.LastUpdate = getdate()
		from dbo.FctStockDaily cur with(nolock)  
		join StockDaylist a
		on cur.StockCode = a.StockCode
		and cur.Day = a.Day
		left join StockDaylist b
		on a.StockCode = b.StockCode
		and a.DayCnt = b.DayCnt + 1
		left join dbo.FctStockDaily lst with(nolock)
		on b.StockCode = lst.StockCode
		and b.Day = lst.Day
		where (cur.LastPrice <> isnull(lst.EndPrice,0)
			or cur.LastPrice is null );

		update a
		set a.Rate = case when a.LastPrice=0.00 then 0.00 else (a.EndPrice - a.LastPrice)/a.LastPrice*100.00 end
		from dbo.FctStockDaily a
		where a.rate is null;
	  
	update [dbo].[execlog]
	set EndTime = getdate()
	where ID = @execID;

	end try
	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();

	exec dbo.errorlog_insert @processname,@errormsg;

	raiserror(@errormsg,16,1);

	end catch	
	
end

GO
/****** Object:  StoredProcedure [dbo].[DimStockAssessment_upsert]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [dbo].[DimStockAssessment_upsert] 'staging'
CREATE proc [dbo].[DimStockAssessment_upsert] 
	@stagingdbname sysname
as
begin
set nocount on;
	declare @processname varchar(100) = 'dbo.DimStockAssessment_upsert';
	declare @cmd varchar(1024);
	
	declare @execID int;	

	begin try
	insert into [dbo].[execlog]([ExecName],[StartTime],[UpdateBy])
	select @processname,getdate(),SUSER_NAME();
	select @execID =@@IDENTITY;
	set @cmd ='
	declare @StockCode nvarchar(100);
	declare @stockassessment nvarchar(100);
	declare @datekey int;

	select StockCode into #StockCodelist from '+@stagingdbname+'.dms.DimStockDaily
	
	select top 1 @StockCode = StockCode from #StockCodelist
	while exists(select 1  from #StockCodelist)
	begin
	select @stockassessment = Assessment,@datekey = Day from '+@stagingdbname+'.dms.DimStockDaily
	where StockCode = @StockCode

	update dbo.FctStockDaily
	set StateID =1
	where Day = @datekey
	and @stockassessment =''停牌''

	if not exists(select 1 from  dbo.DimStockAssessment where Assessment =  @stockassessment)
	begin
		insert into dbo.DimStockAssessment(Assessment,LastUpdate)
		select @stockassessment,getdate()
	end

	delete from #StockCodelist
	where  StockCode = @StockCode;
	select top 1 @StockCode = StockCode from #StockCodelist


	end'
	exec(@cmd);
	update [dbo].[execlog]
	set EndTime = getdate()
	where ID = @execID;
	end try
	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();
	raiserror(@errormsg,16,1);
	end catch
	

end
GO
/****** Object:  StoredProcedure [dbo].[DimStockList_upsert]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [dbo].[DimStockList_upsert] '[Staging]'
CREATE proc [dbo].[DimStockList_upsert]
	@stagingdbname sysname
as
begin
set nocount on
	declare @processname nvarchar(200) = 'dbo.DimStockList_upsert';
	declare @cmd varchar(max);
	declare @execID int;	

	begin try
	insert into [dbo].[execlog]([ExecName],[StartTime],[UpdateBy])
	select @processname,getdate(),suser_name();
	select @execID =@@IDENTITY;

	-- make sure there are no multiple IsCurrent = 1 rows.
	update a
	set IsCurrent = 0,
		LastUpdate = getdate()
	from dbo.DimStockList a
	join (select ID,StockCode,StartDate,IsCurrent,ROW_NUMBER() over(partition by StockCode order by StartDate DESC) RID from dbo.DimStockList
	where IsCurrent = 1)b
	on a.StockCode = b.StockCode
	and a.ID = b.ID
	and b.RID > 1;


	set @cmd = '
		update a
		set StockName = replace(stockname,'' '','''')
		from  '+@stagingdbname+'.dms.DimStockDaily a;
	
		update a
		set
			a.EndDate = convert(varchar(8),getdate(),112),
			IsCurrent = 0,
			LastUpdate = getdate()
		from dbo.DimStockList a
		join (select distinct StockCode,StockName from '+@stagingdbname+'.dms.DimStockDaily) b
		on a.StockCode = b.StockCode
		and a.StartDate < convert(varchar(8),getdate(),112)
		and a.StockName <> b.StockName
		and a.IsCurrent = 1;
			
		insert into dbo.DimStockList(StockCode ,StockName ,StartDate ,EndDate ,IsCurrent )
		select distinct b.StockCode,b.StockName,convert(varchar(8),getdate(),112),null,1
		from  '+@stagingdbname+'.dms.DimStockDaily b
		left join dbo.DimStockList a
		on  a.StockCode = b.StockCode
		and a.IsCurrent = 1
		where a.StockCode is null;
		'
	exec(@cmd);

	update [dbo].[execlog]
	set EndTime = getdate()
	where ID = @execID;
	end try
	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();

	exec dbo.errorlog_insert @processname,@errormsg;

	raiserror(@errormsg,16,1);

	end catch	
	
end
GO
/****** Object:  StoredProcedure [dbo].[errorlog_insert]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  create proc [dbo].[errorlog_insert]
	@processname nvarchar(200)= '',
	@errormessage nvarchar(2000)
  as
  begin
	insert into dbo.errorlog(Name,ErrorMessage,LastUpdate)
	select @processname,@errormessage,getdate();
  end
GO
/****** Object:  StoredProcedure [dbo].[FctStockDaily_upsert]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [dbo].[FctStockDaily_upsert] 'staging'
CREATE proc [dbo].[FctStockDaily_upsert] 
	@stagingdbname sysname
as 
begin
set nocount on;
	declare @processname nvarchar(200) = 'dbo.FctStockDaily_upsert';
	declare @cmd varchar(max);
	
	declare @execID int;	

	begin try
	insert into [dbo].[execlog]([ExecName],[StartTime],[UpdateBy])
	select @processname,getdate(),suser_name();
	select @execID =@@IDENTITY;

	set @cmd = '
	delete from dbo.FctStockDaily
	where stockid not in (select id from dbo.DimStockList)'
	exec(@cmd);
	

	set @cmd ='
	  select identity(int,1,1) ID,s.*
	  into #dmsDimStockDaily
	  from '+@stagingdbname+'.dms.DimStockDaily s;

	  delete s
	  from #dmsDimStockDaily s
	  join	  (select stockcode,max(ID) ID from #dmsDimStockDaily group by stockcode)b
	  on s.stockcode = b.stockcode
	  and s.ID < b.ID;

	update f
		set 
		f.MonthKey = left(f.Day,6),
		f.StockID = d.ID,
		f.AssessmentID = a.ID,	
		f.StateID = case when (s.Amount =0.00 and s.Volumn = 0.00) and s.Assessment = ''停牌'' then 1 else 0 end,	
		f.EndPrice  = case when (s.Amount =0.00 and s.Volumn = 0.00) and s.Assessment = ''停牌'' then s.LastPrice else s.EndPrice end,	
		f.UpAndDown = s.UpAndDown,
		f.Rate = s.Rate ,	
		f.LastPrice = s.LastPrice ,	
		f.BeginPrice = case when (s.Amount =0.00 and s.Volumn = 0.00) and s.Assessment = ''停牌'' then s.LastPrice else s.BeginPrice end,	
		f.HighPrice = case when (s.Amount =0.00 and s.Volumn = 0.00) and s.Assessment = ''停牌'' then s.LastPrice else s.HighPrice end,	
		f.LowPrice = case when (s.Amount =0.00 and s.Volumn = 0.00) and s.Assessment = ''停牌'' then s.LastPrice else s.LowPrice end,	
		f.Volumn = s.Volumn * 10000,	
		f.Amount = s.Amount * 10000,
		f.LastUpdate = getdate()
		from #dmsDimStockDaily s
	inner join dbo.DimStockList d
	on s.StockCode = d.StockCode
	and d.IsCurrent = 1
	inner join dbo.DimStockAssessment a
	on s.Assessment = a.Assessment
	inner join dbo.FctStockDaily f
	on s.[Day] = f.[Day]
	and f.StockCode = s.StockCode;
	
	insert into dbo.FctStockDaily
	(	[Day] ,	MonthKey, StockID ,StockCode,	AssessmentID ,	StateID ,	EndPrice ,	UpAndDown ,
	Rate ,	LastPrice ,	BeginPrice ,	HighPrice ,	LowPrice ,	Volumn ,	Amount )
	select s.[Day] , left(s.[Day],6) ,d.ID ,s.StockCode, a.ID,
	case when (s.Amount =0.00 and s.Volumn = 0.00) and s.Assessment = ''停牌'' then 1 else 0 end, 
	case when (s.Amount =0.00 and s.Volumn = 0.00) and s.Assessment = ''停牌'' then s.LastPrice else s.EndPrice end, 
	s.UpAndDown ,
	s.Rate , 
	s.LastPrice , 
	case when (s.Amount =0.00 and s.Volumn = 0.00) and s.Assessment = ''停牌'' then s.LastPrice else s.BeginPrice end,	
	case when (s.Amount =0.00 and s.Volumn = 0.00) and s.Assessment = ''停牌'' then s.LastPrice else s.HighPrice end,
	case when (s.Amount =0.00 and s.Volumn = 0.00) and s.Assessment = ''停牌'' then s.LastPrice else s.LowPrice end,	
	s.Volumn * 10000,
	s.Amount * 10000
		from #dmsDimStockDaily s
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
	print @cmd
	exec(@cmd);
	update f
	set StateID=1,
		f.LastUpdate = getdate()
	from dbo.FctStockDaily f
	where StateID <>1 
	and Amount=0 and Volumn=0
	and DAY >convert(varchar(8),getdate()-7,112);

	update f
	set EndPrice = LastPrice,	
		f.LastUpdate = getdate()
	from dbo.FctStockDaily f
	where StateID =1 
	and EndPrice<> LastPrice
	and DAY >convert(varchar(8),getdate()-7,112);

	
	update [dbo].[execlog]
	set EndTime = getdate()
	where ID = @execID;
	end try
	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();

	exec dbo.errorlog_insert @processname,@errormsg;

	raiserror(@errormsg,16,1);
	end catch
	

end
GO
/****** Object:  StoredProcedure [dbo].[SP_GetTableUpdateQuery]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--[dbo].[SP_GetTableUpdateQuery] 'dbo.fctstockdaily'
CREATE proc [dbo].[SP_GetTableUpdateQuery] 
	@FullTablename sysname
as
begin
set nocount on;
	declare @UpdateQuery nvarchar(max);
	declare @pkjoin nvarchar(max);
	declare @setValue nvarchar(max);
	declare @collist table (id int identity(1,1),name nvarchar(255),pkcol bit);

	insert into @collist(name,pkcol)
	SELECT c.name,isnull(i.is_primary_key,0)
	FROM Sys.Columns c
	left join(
	select column_id, 1 as is_primary_key  from sys.index_columns ic
	where index_id=
	(	select index_id
		from sys.indexes where is_primary_key =1
		and object_id=Object_Id(@FullTablename))
	and object_id=Object_Id(@FullTablename)
	)i
	on c.column_id =i.column_id
	Where c.object_id=Object_Id(@FullTablename);

	select * from @collist;

	select @pkjoin = isnull(@pkjoin + ' AND ' ,'ON ') + 't.'+name +' = s.'+name from @collist
	where pkcol = 1;
	select @setValue = isnull(@setValue + ',','UPDATE t SET'+char(10)) + 't.'+name +' = s.'+name+char(10)  from @collist
	where pkcol = 0;

	select @UpdateQuery = @setValue + 'FROM '+@FullTablename+' t '+char(10)+'INNER JOIN [] s'+char(10) + @pkjoin;

	print @UpdateQuery;
end



GO
/****** Object:  StoredProcedure [dbo].[StockDaily_Load]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [dbo].[StockDaily_Load]  'staging'
CREATE proc [dbo].[StockDaily_Load] 
	@stagingdbname sysname
as
begin
set nocount on;
	declare @processname varchar(100) = 'dbo.StockDaily_Load';
	declare @cmd varchar(1024);
	
	declare @execID int;	

	begin try
	insert into [dbo].[execlog]([ExecName],[StartTime],[UpdateBy])
	select @processname,getdate(),SUSER_NAME();
	select @execID =@@IDENTITY;
	
	exec [dbo].[DimStockAssessment_upsert] @stagingdbname;
	exec [dbo].[DimStockList_upsert] @stagingdbname;
	exec [dbo].[FctStockDaily_upsert] @stagingdbname;

	update [dbo].[execlog]
	set EndTime = getdate()
	where ID = @execID;
	end try

	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();
	raiserror(@errormsg,16,1);
	end catch
	

end
GO
/****** Object:  StoredProcedure [dbo].[StockDailyHistory_load]    Script Date: 2017/8/24 23:33:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[StockDailyHistory_load]
	@stagingdb sysname,
	@staingtablename sysname
as
begin
--set nocount on
	declare @processname varchar(100) = 'dbo.StockDailyHistory_load';

	declare @stgtablefullname varchar(100) = @stagingdb+'.'+@staingtablename;
	declare @cmd varchar(max);

	declare @execID int;	

	begin try
	insert into [dbo].[execlog]([ExecName],[StartTime],[UpdateBy])
	select @processname,getdate(),suser_name();
	select @execID =@@IDENTITY;
		set @cmd='
		select distinct StockCode,StockName,min(Day) StartDate,Max(Day) EndDate
		into #history
		from '+@stgtablefullname+'
		group by StockCode,StockName

		insert into  dbo.DimStockList 
		(StockCode	,StockName	,StartDate	,EndDate	,IsCurrent)
		select distinct
		h.StockCode,h.StockName,h.StartDate,NULL,1 from #history h
		left join dbo.DimStockList d
		on h.StockCode = d.StockCode
		where d.StockCode is null;

		update d
		set d.StartDate = h.StartDate
		from  dbo.DimStockList d
		join  #history h
		on d.StockCode =h.StockCode
		and d.StockName =h.StockName
		where d.StartDate > h.StartDate
		and d.IsCurrent = 1;
		  
		update f
		set f.BeginPrice=s.BeginPrice,
			f.HighPrice=s.HighPrice,
			f.LowPrice = s.LowPrice,
			f.EndPrice = s.EndPrice,
			f.Volumn =s.Volumn,
			f.Amount =s.Amount,
			f.Monthkey = left(s.Day,6),
			f.StateID = 0,
			f.LastUpdate = getdate()
		from dbo.FctStockDaily f
		join dbo.DimStockList d
		on f.StockID =d.ID
		join '+@stgtablefullname+' s
		on f.day=s.Day
		and d.StockCode =s.StockCode
		and d.IsCurrent = 1;

		insert into dbo.FctStockDaily(Day, Monthkey, StateID,
			StockID,StockCode,EndPrice,BeginPrice,HighPrice,LowPrice,
			Volumn,Amount,LastUpdate)
		select s.Day,left(s.Day,6),0,
			d.ID,d.StockCode,s.EndPrice,s.BeginPrice,s.HighPrice,s.LowPrice,s.Volumn,s.Amount,getdate()
		from '+@stgtablefullname+' s
		join dbo.DimStockList d
		on s.StockCode=d.StockCode
		and d.IsCurrent=1
		left join dbo.FctStockDaily f
		on d.ID =f.StockID
		and s.Day =f.Day
		where f.StockID is null;
		
		insert into [ref].[Calender](DateKey,
		CalenderDate,		IsOpen	,	IsWeekend,	IsHoliday,
		Comments,		LastUpdate	,	IsProcessed)
		select distinct f.Day,
		LEFT(cast(f.Day as varchar(8)),4)+''-''+SUBSTRING(cast(f.Day as varchar(8)),5,2)+''-''+SUBSTRING(cast(f.Day as varchar(8)),7,2),
		1,0,0,'''',getdate(),1
		from dbo.FctStockDaily f
		left join [ref].[Calender] c
		on f.Day = c.DateKey
		where c.DateKey is null;
		'
		print @cmd;
		exec(@cmd);

		exec [aud].[FctStockDaily_LastPrice_fix];
	   --fix LastPrice
	   --fix UpAndDown
	   --fix Rate

	
	update [dbo].[execlog]
	set EndTime = getdate()
	where ID = @execID;
	end try
	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();

	exec dbo.errorlog_insert @processname,@errormsg;

	raiserror(@errormsg,16,1);

	end catch	
	
end
GO
USE [master]
GO
ALTER DATABASE [Stock] SET  READ_WRITE 
GO
