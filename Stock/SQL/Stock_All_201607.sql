USE [master]
GO
/****** Object:  Database [Stock]    Script Date: 2016/7/14 0:40:25 ******/
CREATE DATABASE [Stock]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Stock', FILENAME = N'D:\DW\DATA\Stock2016' , SIZE = 3940352KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Stock_log', FILENAME = N'D:\DW\log\Stock2016' , SIZE = 14557184KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
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
ALTER DATABASE [Stock] SET TRUSTWORTHY OFF 
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
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
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
/****** Object:  User [cdc]    Script Date: 2016/7/14 0:40:25 ******/
CREATE USER [cdc] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[cdc]
GO
/****** Object:  DatabaseRole [cdc_admin]    Script Date: 2016/7/14 0:40:25 ******/
CREATE ROLE [cdc_admin]
GO
ALTER ROLE [db_owner] ADD MEMBER [cdc]
GO
/****** Object:  Schema [aud]    Script Date: 2016/7/14 0:40:26 ******/
CREATE SCHEMA [aud]
GO
/****** Object:  Schema [cdc]    Script Date: 2016/7/14 0:40:26 ******/
CREATE SCHEMA [cdc]
GO
/****** Object:  Schema [ref]    Script Date: 2016/7/14 0:40:26 ******/
CREATE SCHEMA [ref]
GO
/****** Object:  Schema [rep]    Script Date: 2016/7/14 0:40:26 ******/
CREATE SCHEMA [rep]
GO
/****** Object:  Table [dbo].[DimStockList]    Script Date: 2016/7/14 0:40:26 ******/
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
/****** Object:  View [aud].[DuplicateStockList]    Script Date: 2016/7/14 0:40:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [aud].[DuplicateStockList]
as

with stocklist as(
SELECT StockName,StockCode,ROW_NUMBER() over(partition by StockCode order by ID,StartDate) RID
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



GO
/****** Object:  View [aud].[DimStockList_lastchange]    Script Date: 2016/7/14 0:40:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [aud].[DimStockList_lastchange]
as

select top 10000 * from dbo.DimStockList
where StockCode in (
select StockCode from dbo.DimStockList
where LastUpdate > DATEADD(DAY,-1,getdate()))
order by 2,4



GO
/****** Object:  UserDefinedFunction [cdc].[fn_cdc_get_all_changes_dbo_DimIndexes]    Script Date: 2016/7/14 0:40:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	create function [cdc].[fn_cdc_get_all_changes_dbo_DimIndexes]
	(	@from_lsn binary(10),
		@to_lsn binary(10),
		@row_filter_option nvarchar(30)
	)
	returns table
	return
	
	select NULL as __$start_lsn,
		NULL as __$seqval,
		NULL as __$operation,
		NULL as __$update_mask, NULL as [ID], NULL as [Name], NULL as [LastUpdate]
	where ( [sys].[fn_cdc_check_parameters]( N'dbo_DimIndexes', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 0) = 0)

	union all
	
	select t.__$start_lsn as __$start_lsn,
		t.__$seqval as __$seqval,
		t.__$operation as __$operation,
		t.__$update_mask as __$update_mask, t.[ID], t.[Name], t.[LastUpdate]
	from [cdc].[dbo_DimIndexes_CT] t with (nolock)    
	where (lower(rtrim(ltrim(@row_filter_option))) = 'all')
	    and ( [sys].[fn_cdc_check_parameters]( N'dbo_DimIndexes', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 0) = 1)
		and (t.__$operation = 1 or t.__$operation = 2 or t.__$operation = 4)
		and (t.__$start_lsn <= @to_lsn)
		and (t.__$start_lsn >= @from_lsn)
		
	union all	
		
	select t.__$start_lsn as __$start_lsn,
		t.__$seqval as __$seqval,
		t.__$operation as __$operation,
		t.__$update_mask as __$update_mask, t.[ID], t.[Name], t.[LastUpdate]
	from [cdc].[dbo_DimIndexes_CT] t with (nolock)     
	where (lower(rtrim(ltrim(@row_filter_option))) = 'all update old')
	    and ( [sys].[fn_cdc_check_parameters]( N'dbo_DimIndexes', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 0) = 1)
		and (t.__$operation = 1 or t.__$operation = 2 or t.__$operation = 4 or
		     t.__$operation = 3 )
		and (t.__$start_lsn <= @to_lsn)
		and (t.__$start_lsn >= @from_lsn)
	
GO
/****** Object:  UserDefinedFunction [cdc].[fn_cdc_get_all_changes_dbo_DimStockList]    Script Date: 2016/7/14 0:40:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	create function [cdc].[fn_cdc_get_all_changes_dbo_DimStockList]
	(	@from_lsn binary(10),
		@to_lsn binary(10),
		@row_filter_option nvarchar(30)
	)
	returns table
	return
	
	select NULL as __$start_lsn,
		NULL as __$seqval,
		NULL as __$operation,
		NULL as __$update_mask, NULL as [ID], NULL as [StockCode], NULL as [StockName], NULL as [StartDate], NULL as [EndDate], NULL as [IsCurrent], NULL as [LastUpdate]
	where ( [sys].[fn_cdc_check_parameters]( N'dbo_DimStockList', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 0) = 0)

	union all
	
	select t.__$start_lsn as __$start_lsn,
		t.__$seqval as __$seqval,
		t.__$operation as __$operation,
		t.__$update_mask as __$update_mask, t.[ID], t.[StockCode], t.[StockName], t.[StartDate], t.[EndDate], t.[IsCurrent], t.[LastUpdate]
	from [cdc].[dbo_DimStockList_CT] t with (nolock)    
	where (lower(rtrim(ltrim(@row_filter_option))) = 'all')
	    and ( [sys].[fn_cdc_check_parameters]( N'dbo_DimStockList', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 0) = 1)
		and (t.__$operation = 1 or t.__$operation = 2 or t.__$operation = 4)
		and (t.__$start_lsn <= @to_lsn)
		and (t.__$start_lsn >= @from_lsn)
		
	union all	
		
	select t.__$start_lsn as __$start_lsn,
		t.__$seqval as __$seqval,
		t.__$operation as __$operation,
		t.__$update_mask as __$update_mask, t.[ID], t.[StockCode], t.[StockName], t.[StartDate], t.[EndDate], t.[IsCurrent], t.[LastUpdate]
	from [cdc].[dbo_DimStockList_CT] t with (nolock)     
	where (lower(rtrim(ltrim(@row_filter_option))) = 'all update old')
	    and ( [sys].[fn_cdc_check_parameters]( N'dbo_DimStockList', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 0) = 1)
		and (t.__$operation = 1 or t.__$operation = 2 or t.__$operation = 4 or
		     t.__$operation = 3 )
		and (t.__$start_lsn <= @to_lsn)
		and (t.__$start_lsn >= @from_lsn)
	
GO
/****** Object:  UserDefinedFunction [cdc].[fn_cdc_get_all_changes_dbo_FctIndexDaily]    Script Date: 2016/7/14 0:40:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	create function [cdc].[fn_cdc_get_all_changes_dbo_FctIndexDaily]
	(	@from_lsn binary(10),
		@to_lsn binary(10),
		@row_filter_option nvarchar(30)
	)
	returns table
	return
	
	select NULL as __$start_lsn,
		NULL as __$seqval,
		NULL as __$operation,
		NULL as __$update_mask, NULL as [Day], NULL as [IndexID], NULL as [Point], NULL as [UpAndDown], NULL as [Rate], NULL as [LastPoint], NULL as [BeginPoint], NULL as [HighPoint], NULL as [LowPoint], NULL as [Volumn], NULL as [Amount], NULL as [LastUpdate]
	where ( [sys].[fn_cdc_check_parameters]( N'dbo_FctIndexDaily', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 0) = 0)

	union all
	
	select t.__$start_lsn as __$start_lsn,
		t.__$seqval as __$seqval,
		t.__$operation as __$operation,
		t.__$update_mask as __$update_mask, t.[Day], t.[IndexID], t.[Point], t.[UpAndDown], t.[Rate], t.[LastPoint], t.[BeginPoint], t.[HighPoint], t.[LowPoint], t.[Volumn], t.[Amount], t.[LastUpdate]
	from [cdc].[dbo_FctIndexDaily_CT] t with (nolock)    
	where (lower(rtrim(ltrim(@row_filter_option))) = 'all')
	    and ( [sys].[fn_cdc_check_parameters]( N'dbo_FctIndexDaily', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 0) = 1)
		and (t.__$operation = 1 or t.__$operation = 2 or t.__$operation = 4)
		and (t.__$start_lsn <= @to_lsn)
		and (t.__$start_lsn >= @from_lsn)
		
	union all	
		
	select t.__$start_lsn as __$start_lsn,
		t.__$seqval as __$seqval,
		t.__$operation as __$operation,
		t.__$update_mask as __$update_mask, t.[Day], t.[IndexID], t.[Point], t.[UpAndDown], t.[Rate], t.[LastPoint], t.[BeginPoint], t.[HighPoint], t.[LowPoint], t.[Volumn], t.[Amount], t.[LastUpdate]
	from [cdc].[dbo_FctIndexDaily_CT] t with (nolock)     
	where (lower(rtrim(ltrim(@row_filter_option))) = 'all update old')
	    and ( [sys].[fn_cdc_check_parameters]( N'dbo_FctIndexDaily', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 0) = 1)
		and (t.__$operation = 1 or t.__$operation = 2 or t.__$operation = 4 or
		     t.__$operation = 3 )
		and (t.__$start_lsn <= @to_lsn)
		and (t.__$start_lsn >= @from_lsn)
	
GO
/****** Object:  UserDefinedFunction [cdc].[fn_cdc_get_net_changes_dbo_DimIndexes]    Script Date: 2016/7/14 0:40:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	create function [cdc].[fn_cdc_get_net_changes_dbo_DimIndexes]
	(	@from_lsn binary(10),
		@to_lsn binary(10),
		@row_filter_option nvarchar(30)
	)
	returns table
	return

	select NULL as __$start_lsn,
		NULL as __$operation,
		NULL as __$update_mask, NULL as [ID], NULL as [Name], NULL as [LastUpdate]
	where ( [sys].[fn_cdc_check_parameters]( N'dbo_DimIndexes', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 0)

	union all
	
	select __$start_lsn,
	    case __$count_B0016BBF
	    when 1 then __$operation
	    else
			case __$min_op_B0016BBF 
				when 2 then 2
				when 4 then
				case __$operation
					when 1 then 1
					else 4
					end
				else
				case __$operation
					when 2 then 4
					when 4 then 4
					else 1
					end
			end
		end as __$operation,
		null as __$update_mask , [ID], [Name], [LastUpdate]
	from
	(
		select t.__$start_lsn as __$start_lsn, __$operation,
		case __$count_B0016BBF 
		when 1 then __$operation 
		else
		(	select top 1 c.__$operation
			from [cdc].[dbo_DimIndexes_CT] c with (nolock)   
			where  ( (c.[ID] = t.[ID]) )  
			and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
			and (c.__$start_lsn <= @to_lsn)
			and (c.__$start_lsn >= @from_lsn)
			order by c.__$seqval) end __$min_op_B0016BBF, __$count_B0016BBF, t.[ID], t.[Name], t.[LastUpdate] 
		from [cdc].[dbo_DimIndexes_CT] t with (nolock) inner join 
		(	select  r.[ID], max(r.__$seqval) as __$max_seqval_B0016BBF,
		    count(*) as __$count_B0016BBF 
			from [cdc].[dbo_DimIndexes_CT] r with (nolock)   
			where  (r.__$start_lsn <= @to_lsn)
			and (r.__$start_lsn >= @from_lsn)
			group by   r.[ID]) m
		on t.__$seqval = m.__$max_seqval_B0016BBF and
		    ( (t.[ID] = m.[ID]) ) 	
		where lower(rtrim(ltrim(@row_filter_option))) = N'all'
			and ( [sys].[fn_cdc_check_parameters]( N'dbo_DimIndexes', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 1)
			and (t.__$start_lsn <= @to_lsn)
			and (t.__$start_lsn >= @from_lsn)
			and ((t.__$operation = 2) or (t.__$operation = 4) or 
				 ((t.__$operation = 1) and
				  (2 not in 
				 		(	select top 1 c.__$operation
							from [cdc].[dbo_DimIndexes_CT] c with (nolock) 
							where  ( (c.[ID] = t.[ID]) )  
							and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
							and (c.__$start_lsn <= @to_lsn)
							and (c.__$start_lsn >= @from_lsn)
							order by c.__$seqval
						 ) 
	 			   )
	 			 )
	 			) 	
	) Q
	
	union all
	
	select __$start_lsn,
	    case __$count_B0016BBF
	    when 1 then __$operation
	    else
			case __$min_op_B0016BBF 
				when 2 then 2
				when 4 then
				case __$operation
					when 1 then 1
					else 4
					end
				else
				case __$operation
					when 2 then 4
					when 4 then 4
					else 1
					end
			end
		end as __$operation,
		case __$count_B0016BBF
		when 1 then
			case __$operation
			when 4 then __$update_mask
			else null
			end
		else	
			case __$min_op_B0016BBF 
			when 2 then null
			else
				case __$operation
				when 1 then null
				else __$update_mask 
				end
			end	
		end as __$update_mask , [ID], [Name], [LastUpdate]
	from
	(
		select t.__$start_lsn as __$start_lsn, __$operation,
		case __$count_B0016BBF 
		when 1 then __$operation 
		else
		(	select top 1 c.__$operation
			from [cdc].[dbo_DimIndexes_CT] c with (nolock)
			where  ( (c.[ID] = t.[ID]) )  
			and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
			and (c.__$start_lsn <= @to_lsn)
			and (c.__$start_lsn >= @from_lsn)
			order by c.__$seqval) end __$min_op_B0016BBF, __$count_B0016BBF, 
		m.__$update_mask , t.[ID], t.[Name], t.[LastUpdate]
		from [cdc].[dbo_DimIndexes_CT] t with (nolock) inner join 
		(	select  r.[ID], max(r.__$seqval) as __$max_seqval_B0016BBF,
		    count(*) as __$count_B0016BBF, 
		    [sys].[ORMask](r.__$update_mask) as __$update_mask
			from [cdc].[dbo_DimIndexes_CT] r with (nolock)
			where  (r.__$start_lsn <= @to_lsn)
			and (r.__$start_lsn >= @from_lsn)
			group by   r.[ID]) m
		on t.__$seqval = m.__$max_seqval_B0016BBF and
		    ( (t.[ID] = m.[ID]) ) 	
		where lower(rtrim(ltrim(@row_filter_option))) = N'all with mask'
			and ( [sys].[fn_cdc_check_parameters]( N'dbo_DimIndexes', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 1)
			and (t.__$start_lsn <= @to_lsn)
			and (t.__$start_lsn >= @from_lsn)
			and ((t.__$operation = 2) or (t.__$operation = 4) or 
				 ((t.__$operation = 1) and
				  (2 not in 
				 		(	select top 1 c.__$operation
							from [cdc].[dbo_DimIndexes_CT] c with (nolock)
							where  ( (c.[ID] = t.[ID]) )  
							and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
							and (c.__$start_lsn <= @to_lsn)
							and (c.__$start_lsn >= @from_lsn)
							order by c.__$seqval
						 ) 
	 			   )
	 			 )
	 			) 	
	) Q
	
	union all
	
		select t.__$start_lsn as __$start_lsn,
		case t.__$operation
			when 1 then 1
			else 5
		end as __$operation,
		null as __$update_mask , t.[ID], t.[Name], t.[LastUpdate]
		from [cdc].[dbo_DimIndexes_CT] t  with (nolock) inner join 
		(	select  r.[ID], max(r.__$seqval) as __$max_seqval_B0016BBF
			from [cdc].[dbo_DimIndexes_CT] r with (nolock)
			where  (r.__$start_lsn <= @to_lsn)
			and (r.__$start_lsn >= @from_lsn)
			group by   r.[ID]) m
		on t.__$seqval = m.__$max_seqval_B0016BBF and
		    ( (t.[ID] = m.[ID]) ) 	
		where lower(rtrim(ltrim(@row_filter_option))) = N'all with merge'
			and ( [sys].[fn_cdc_check_parameters]( N'dbo_DimIndexes', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 1)
			and (t.__$start_lsn <= @to_lsn)
			and (t.__$start_lsn >= @from_lsn)
			and ((t.__$operation = 2) or (t.__$operation = 4) or 
				 ((t.__$operation = 1) and 
				   (2 not in 
				 		(	select top 1 c.__$operation
							from [cdc].[dbo_DimIndexes_CT] c with (nolock)
							where  ( (c.[ID] = t.[ID]) )  
							and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
							and (c.__$start_lsn <= @to_lsn)
							and (c.__$start_lsn >= @from_lsn)
							order by c.__$seqval
						 ) 
	 				)
	 			 )
	 			)
	 
GO
/****** Object:  UserDefinedFunction [cdc].[fn_cdc_get_net_changes_dbo_DimStockList]    Script Date: 2016/7/14 0:40:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	create function [cdc].[fn_cdc_get_net_changes_dbo_DimStockList]
	(	@from_lsn binary(10),
		@to_lsn binary(10),
		@row_filter_option nvarchar(30)
	)
	returns table
	return

	select NULL as __$start_lsn,
		NULL as __$operation,
		NULL as __$update_mask, NULL as [ID], NULL as [StockCode], NULL as [StockName], NULL as [StartDate], NULL as [EndDate], NULL as [IsCurrent], NULL as [LastUpdate]
	where ( [sys].[fn_cdc_check_parameters]( N'dbo_DimStockList', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 0)

	union all
	
	select __$start_lsn,
	    case __$count_288DEA5B
	    when 1 then __$operation
	    else
			case __$min_op_288DEA5B 
				when 2 then 2
				when 4 then
				case __$operation
					when 1 then 1
					else 4
					end
				else
				case __$operation
					when 2 then 4
					when 4 then 4
					else 1
					end
			end
		end as __$operation,
		null as __$update_mask , [ID], [StockCode], [StockName], [StartDate], [EndDate], [IsCurrent], [LastUpdate]
	from
	(
		select t.__$start_lsn as __$start_lsn, __$operation,
		case __$count_288DEA5B 
		when 1 then __$operation 
		else
		(	select top 1 c.__$operation
			from [cdc].[dbo_DimStockList_CT] c with (nolock)   
			where  ( (c.[ID] = t.[ID]) )  
			and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
			and (c.__$start_lsn <= @to_lsn)
			and (c.__$start_lsn >= @from_lsn)
			order by c.__$seqval) end __$min_op_288DEA5B, __$count_288DEA5B, t.[ID], t.[StockCode], t.[StockName], t.[StartDate], t.[EndDate], t.[IsCurrent], t.[LastUpdate] 
		from [cdc].[dbo_DimStockList_CT] t with (nolock) inner join 
		(	select  r.[ID], max(r.__$seqval) as __$max_seqval_288DEA5B,
		    count(*) as __$count_288DEA5B 
			from [cdc].[dbo_DimStockList_CT] r with (nolock)   
			where  (r.__$start_lsn <= @to_lsn)
			and (r.__$start_lsn >= @from_lsn)
			group by   r.[ID]) m
		on t.__$seqval = m.__$max_seqval_288DEA5B and
		    ( (t.[ID] = m.[ID]) ) 	
		where lower(rtrim(ltrim(@row_filter_option))) = N'all'
			and ( [sys].[fn_cdc_check_parameters]( N'dbo_DimStockList', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 1)
			and (t.__$start_lsn <= @to_lsn)
			and (t.__$start_lsn >= @from_lsn)
			and ((t.__$operation = 2) or (t.__$operation = 4) or 
				 ((t.__$operation = 1) and
				  (2 not in 
				 		(	select top 1 c.__$operation
							from [cdc].[dbo_DimStockList_CT] c with (nolock) 
							where  ( (c.[ID] = t.[ID]) )  
							and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
							and (c.__$start_lsn <= @to_lsn)
							and (c.__$start_lsn >= @from_lsn)
							order by c.__$seqval
						 ) 
	 			   )
	 			 )
	 			) 	
	) Q
	
	union all
	
	select __$start_lsn,
	    case __$count_288DEA5B
	    when 1 then __$operation
	    else
			case __$min_op_288DEA5B 
				when 2 then 2
				when 4 then
				case __$operation
					when 1 then 1
					else 4
					end
				else
				case __$operation
					when 2 then 4
					when 4 then 4
					else 1
					end
			end
		end as __$operation,
		case __$count_288DEA5B
		when 1 then
			case __$operation
			when 4 then __$update_mask
			else null
			end
		else	
			case __$min_op_288DEA5B 
			when 2 then null
			else
				case __$operation
				when 1 then null
				else __$update_mask 
				end
			end	
		end as __$update_mask , [ID], [StockCode], [StockName], [StartDate], [EndDate], [IsCurrent], [LastUpdate]
	from
	(
		select t.__$start_lsn as __$start_lsn, __$operation,
		case __$count_288DEA5B 
		when 1 then __$operation 
		else
		(	select top 1 c.__$operation
			from [cdc].[dbo_DimStockList_CT] c with (nolock)
			where  ( (c.[ID] = t.[ID]) )  
			and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
			and (c.__$start_lsn <= @to_lsn)
			and (c.__$start_lsn >= @from_lsn)
			order by c.__$seqval) end __$min_op_288DEA5B, __$count_288DEA5B, 
		m.__$update_mask , t.[ID], t.[StockCode], t.[StockName], t.[StartDate], t.[EndDate], t.[IsCurrent], t.[LastUpdate]
		from [cdc].[dbo_DimStockList_CT] t with (nolock) inner join 
		(	select  r.[ID], max(r.__$seqval) as __$max_seqval_288DEA5B,
		    count(*) as __$count_288DEA5B, 
		    [sys].[ORMask](r.__$update_mask) as __$update_mask
			from [cdc].[dbo_DimStockList_CT] r with (nolock)
			where  (r.__$start_lsn <= @to_lsn)
			and (r.__$start_lsn >= @from_lsn)
			group by   r.[ID]) m
		on t.__$seqval = m.__$max_seqval_288DEA5B and
		    ( (t.[ID] = m.[ID]) ) 	
		where lower(rtrim(ltrim(@row_filter_option))) = N'all with mask'
			and ( [sys].[fn_cdc_check_parameters]( N'dbo_DimStockList', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 1)
			and (t.__$start_lsn <= @to_lsn)
			and (t.__$start_lsn >= @from_lsn)
			and ((t.__$operation = 2) or (t.__$operation = 4) or 
				 ((t.__$operation = 1) and
				  (2 not in 
				 		(	select top 1 c.__$operation
							from [cdc].[dbo_DimStockList_CT] c with (nolock)
							where  ( (c.[ID] = t.[ID]) )  
							and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
							and (c.__$start_lsn <= @to_lsn)
							and (c.__$start_lsn >= @from_lsn)
							order by c.__$seqval
						 ) 
	 			   )
	 			 )
	 			) 	
	) Q
	
	union all
	
		select t.__$start_lsn as __$start_lsn,
		case t.__$operation
			when 1 then 1
			else 5
		end as __$operation,
		null as __$update_mask , t.[ID], t.[StockCode], t.[StockName], t.[StartDate], t.[EndDate], t.[IsCurrent], t.[LastUpdate]
		from [cdc].[dbo_DimStockList_CT] t  with (nolock) inner join 
		(	select  r.[ID], max(r.__$seqval) as __$max_seqval_288DEA5B
			from [cdc].[dbo_DimStockList_CT] r with (nolock)
			where  (r.__$start_lsn <= @to_lsn)
			and (r.__$start_lsn >= @from_lsn)
			group by   r.[ID]) m
		on t.__$seqval = m.__$max_seqval_288DEA5B and
		    ( (t.[ID] = m.[ID]) ) 	
		where lower(rtrim(ltrim(@row_filter_option))) = N'all with merge'
			and ( [sys].[fn_cdc_check_parameters]( N'dbo_DimStockList', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 1)
			and (t.__$start_lsn <= @to_lsn)
			and (t.__$start_lsn >= @from_lsn)
			and ((t.__$operation = 2) or (t.__$operation = 4) or 
				 ((t.__$operation = 1) and 
				   (2 not in 
				 		(	select top 1 c.__$operation
							from [cdc].[dbo_DimStockList_CT] c with (nolock)
							where  ( (c.[ID] = t.[ID]) )  
							and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
							and (c.__$start_lsn <= @to_lsn)
							and (c.__$start_lsn >= @from_lsn)
							order by c.__$seqval
						 ) 
	 				)
	 			 )
	 			)
	 
GO
/****** Object:  UserDefinedFunction [cdc].[fn_cdc_get_net_changes_dbo_FctIndexDaily]    Script Date: 2016/7/14 0:40:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	create function [cdc].[fn_cdc_get_net_changes_dbo_FctIndexDaily]
	(	@from_lsn binary(10),
		@to_lsn binary(10),
		@row_filter_option nvarchar(30)
	)
	returns table
	return

	select NULL as __$start_lsn,
		NULL as __$operation,
		NULL as __$update_mask, NULL as [Day], NULL as [IndexID], NULL as [Point], NULL as [UpAndDown], NULL as [Rate], NULL as [LastPoint], NULL as [BeginPoint], NULL as [HighPoint], NULL as [LowPoint], NULL as [Volumn], NULL as [Amount], NULL as [LastUpdate]
	where ( [sys].[fn_cdc_check_parameters]( N'dbo_FctIndexDaily', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 0)

	union all
	
	select __$start_lsn,
	    case __$count_3345B61B
	    when 1 then __$operation
	    else
			case __$min_op_3345B61B 
				when 2 then 2
				when 4 then
				case __$operation
					when 1 then 1
					else 4
					end
				else
				case __$operation
					when 2 then 4
					when 4 then 4
					else 1
					end
			end
		end as __$operation,
		null as __$update_mask , [Day], [IndexID], [Point], [UpAndDown], [Rate], [LastPoint], [BeginPoint], [HighPoint], [LowPoint], [Volumn], [Amount], [LastUpdate]
	from
	(
		select t.__$start_lsn as __$start_lsn, __$operation,
		case __$count_3345B61B 
		when 1 then __$operation 
		else
		(	select top 1 c.__$operation
			from [cdc].[dbo_FctIndexDaily_CT] c with (nolock)   
			where  ( (c.[Day] = t.[Day]) and (c.[IndexID] = t.[IndexID])  )  
			and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
			and (c.__$start_lsn <= @to_lsn)
			and (c.__$start_lsn >= @from_lsn)
			order by c.__$seqval) end __$min_op_3345B61B, __$count_3345B61B, t.[Day], t.[IndexID], t.[Point], t.[UpAndDown], t.[Rate], t.[LastPoint], t.[BeginPoint], t.[HighPoint], t.[LowPoint], t.[Volumn], t.[Amount], t.[LastUpdate] 
		from [cdc].[dbo_FctIndexDaily_CT] t with (nolock) inner join 
		(	select  r.[Day], r.[IndexID], max(r.__$seqval) as __$max_seqval_3345B61B,
		    count(*) as __$count_3345B61B 
			from [cdc].[dbo_FctIndexDaily_CT] r with (nolock)   
			where  (r.__$start_lsn <= @to_lsn)
			and (r.__$start_lsn >= @from_lsn)
			group by   r.[Day], r.[IndexID]) m
		on t.__$seqval = m.__$max_seqval_3345B61B and
		    ( (t.[Day] = m.[Day]) and (t.[IndexID] = m.[IndexID])  ) 	
		where lower(rtrim(ltrim(@row_filter_option))) = N'all'
			and ( [sys].[fn_cdc_check_parameters]( N'dbo_FctIndexDaily', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 1)
			and (t.__$start_lsn <= @to_lsn)
			and (t.__$start_lsn >= @from_lsn)
			and ((t.__$operation = 2) or (t.__$operation = 4) or 
				 ((t.__$operation = 1) and
				  (2 not in 
				 		(	select top 1 c.__$operation
							from [cdc].[dbo_FctIndexDaily_CT] c with (nolock) 
							where  ( (c.[Day] = t.[Day]) and (c.[IndexID] = t.[IndexID])  )  
							and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
							and (c.__$start_lsn <= @to_lsn)
							and (c.__$start_lsn >= @from_lsn)
							order by c.__$seqval
						 ) 
	 			   )
	 			 )
	 			) 	
	) Q
	
	union all
	
	select __$start_lsn,
	    case __$count_3345B61B
	    when 1 then __$operation
	    else
			case __$min_op_3345B61B 
				when 2 then 2
				when 4 then
				case __$operation
					when 1 then 1
					else 4
					end
				else
				case __$operation
					when 2 then 4
					when 4 then 4
					else 1
					end
			end
		end as __$operation,
		case __$count_3345B61B
		when 1 then
			case __$operation
			when 4 then __$update_mask
			else null
			end
		else	
			case __$min_op_3345B61B 
			when 2 then null
			else
				case __$operation
				when 1 then null
				else __$update_mask 
				end
			end	
		end as __$update_mask , [Day], [IndexID], [Point], [UpAndDown], [Rate], [LastPoint], [BeginPoint], [HighPoint], [LowPoint], [Volumn], [Amount], [LastUpdate]
	from
	(
		select t.__$start_lsn as __$start_lsn, __$operation,
		case __$count_3345B61B 
		when 1 then __$operation 
		else
		(	select top 1 c.__$operation
			from [cdc].[dbo_FctIndexDaily_CT] c with (nolock)
			where  ( (c.[Day] = t.[Day]) and (c.[IndexID] = t.[IndexID])  )  
			and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
			and (c.__$start_lsn <= @to_lsn)
			and (c.__$start_lsn >= @from_lsn)
			order by c.__$seqval) end __$min_op_3345B61B, __$count_3345B61B, 
		m.__$update_mask , t.[Day], t.[IndexID], t.[Point], t.[UpAndDown], t.[Rate], t.[LastPoint], t.[BeginPoint], t.[HighPoint], t.[LowPoint], t.[Volumn], t.[Amount], t.[LastUpdate]
		from [cdc].[dbo_FctIndexDaily_CT] t with (nolock) inner join 
		(	select  r.[Day], r.[IndexID], max(r.__$seqval) as __$max_seqval_3345B61B,
		    count(*) as __$count_3345B61B, 
		    [sys].[ORMask](r.__$update_mask) as __$update_mask
			from [cdc].[dbo_FctIndexDaily_CT] r with (nolock)
			where  (r.__$start_lsn <= @to_lsn)
			and (r.__$start_lsn >= @from_lsn)
			group by   r.[Day], r.[IndexID]) m
		on t.__$seqval = m.__$max_seqval_3345B61B and
		    ( (t.[Day] = m.[Day]) and (t.[IndexID] = m.[IndexID])  ) 	
		where lower(rtrim(ltrim(@row_filter_option))) = N'all with mask'
			and ( [sys].[fn_cdc_check_parameters]( N'dbo_FctIndexDaily', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 1)
			and (t.__$start_lsn <= @to_lsn)
			and (t.__$start_lsn >= @from_lsn)
			and ((t.__$operation = 2) or (t.__$operation = 4) or 
				 ((t.__$operation = 1) and
				  (2 not in 
				 		(	select top 1 c.__$operation
							from [cdc].[dbo_FctIndexDaily_CT] c with (nolock)
							where  ( (c.[Day] = t.[Day]) and (c.[IndexID] = t.[IndexID])  )  
							and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
							and (c.__$start_lsn <= @to_lsn)
							and (c.__$start_lsn >= @from_lsn)
							order by c.__$seqval
						 ) 
	 			   )
	 			 )
	 			) 	
	) Q
	
	union all
	
		select t.__$start_lsn as __$start_lsn,
		case t.__$operation
			when 1 then 1
			else 5
		end as __$operation,
		null as __$update_mask , t.[Day], t.[IndexID], t.[Point], t.[UpAndDown], t.[Rate], t.[LastPoint], t.[BeginPoint], t.[HighPoint], t.[LowPoint], t.[Volumn], t.[Amount], t.[LastUpdate]
		from [cdc].[dbo_FctIndexDaily_CT] t  with (nolock) inner join 
		(	select  r.[Day], r.[IndexID], max(r.__$seqval) as __$max_seqval_3345B61B
			from [cdc].[dbo_FctIndexDaily_CT] r with (nolock)
			where  (r.__$start_lsn <= @to_lsn)
			and (r.__$start_lsn >= @from_lsn)
			group by   r.[Day], r.[IndexID]) m
		on t.__$seqval = m.__$max_seqval_3345B61B and
		    ( (t.[Day] = m.[Day]) and (t.[IndexID] = m.[IndexID])  ) 	
		where lower(rtrim(ltrim(@row_filter_option))) = N'all with merge'
			and ( [sys].[fn_cdc_check_parameters]( N'dbo_FctIndexDaily', @from_lsn, @to_lsn, lower(rtrim(ltrim(@row_filter_option))), 1) = 1)
			and (t.__$start_lsn <= @to_lsn)
			and (t.__$start_lsn >= @from_lsn)
			and ((t.__$operation = 2) or (t.__$operation = 4) or 
				 ((t.__$operation = 1) and 
				   (2 not in 
				 		(	select top 1 c.__$operation
							from [cdc].[dbo_FctIndexDaily_CT] c with (nolock)
							where  ( (c.[Day] = t.[Day]) and (c.[IndexID] = t.[IndexID])  )  
							and ((c.__$operation = 2) or (c.__$operation = 4) or (c.__$operation = 1))
							and (c.__$start_lsn <= @to_lsn)
							and (c.__$start_lsn >= @from_lsn)
							order by c.__$seqval
						 ) 
	 				)
	 			 )
	 			)
	 
GO
/****** Object:  Table [dbo].[DimIndexes]    Script Date: 2016/7/14 0:40:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimIndexes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[LastUpdate] [datetime] NULL,
 CONSTRAINT [PK_DimIndexes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DimStockAssessment]    Script Date: 2016/7/14 0:40:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
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
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[errorlog]    Script Date: 2016/7/14 0:40:26 ******/
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
/****** Object:  Table [dbo].[execlog]    Script Date: 2016/7/14 0:40:26 ******/
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
/****** Object:  Table [dbo].[FctIndexDaily]    Script Date: 2016/7/14 0:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FctIndexDaily](
	[Day] [int] NOT NULL,
	[IndexID] [int] NOT NULL,
	[Point] [decimal](19, 2) NULL,
	[UpAndDown] [decimal](19, 2) NULL,
	[Rate] [decimal](19, 2) NULL,
	[LastPoint] [decimal](19, 2) NULL,
	[BeginPoint] [decimal](19, 2) NULL,
	[HighPoint] [decimal](19, 2) NULL,
	[LowPoint] [decimal](19, 2) NULL,
	[Volumn] [decimal](19, 2) NULL,
	[Amount] [decimal](19, 2) NULL,
	[LastUpdate] [datetime] NULL,
 CONSTRAINT [PK_FctIndexDaily] PRIMARY KEY CLUSTERED 
(
	[Day] ASC,
	[IndexID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FctStockDaily]    Script Date: 2016/7/14 0:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FctStockDaily](
	[Day] [int] NOT NULL,
	[StockID] [int] NOT NULL,
	[AssessmentID] [int] NULL,
	[StateID] [int] NULL,
	[EndPrice] [decimal](19, 2) NULL,
	[UpAndDown] [decimal](19, 2) NULL,
	[Rate] [decimal](19, 2) NULL,
	[LastPrice] [decimal](19, 2) NULL,
	[BeginPrice] [decimal](19, 2) NULL,
	[HighPrice] [decimal](19, 2) NULL,
	[LowPrice] [decimal](19, 2) NULL,
	[Volumn] [decimal](19, 2) NULL,
	[Amount] [decimal](19, 2) NULL,
	[LastUpdate] [datetime] NULL,
	[StockCode] [int] NOT NULL,
 CONSTRAINT [pk_FctStockDaily] PRIMARY KEY CLUSTERED 
(
	[Day] ASC,
	[StockID] ASC,
	[StockCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[stockdaily_20160624]    Script Date: 2016/7/14 0:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[stockdaily_20160624](
	[代码] [varchar](50) NULL,
	[名称] [varchar](50) NULL,
	[千股千评] [varchar](50) NULL,
	[最新价] [varchar](50) NULL,
	[涨跌额] [varchar](50) NULL,
	[涨跌幅] [varchar](50) NULL,
	[昨收] [varchar](50) NULL,
	[今开] [varchar](50) NULL,
	[最高] [varchar](50) NULL,
	[最低] [varchar](50) NULL,
	[成交量 (万股 )] [varchar](50) NULL,
	[成交额 (万元 )] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [ref].[Calender]    Script Date: 2016/7/14 0:40:27 ******/
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
SET ANSI_PADDING ON

GO
/****** Object:  Index [UX_DimSotckList]    Script Date: 2016/7/14 0:40:27 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimSotckList] ON [dbo].[DimStockList]
(
	[StockCode] ASC,
	[StockName] ASC,
	[StartDate] ASC,
	[IsCurrent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DimIndexes] ADD  DEFAULT (getdate()) FOR [LastUpdate]
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
/****** Object:  StoredProcedure [aud].[DuplicateStockList_fix]    Script Date: 2016/7/14 0:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [aud].[DuplicateStockList_fix]
	
as
begin
--set nocount on
	declare @processname varchar(100) = 'aud.DuplicateStockList_fix';

	begin try
	  select StockCode,min(ID) ID
	  into #first
	  from [aud].[DuplicateStockList]
	  group by Stockcode;

	  select distinct stockcode, ID
	  into #later
	  from [aud].[DuplicateStockList]
	  where ID not in (select ID from #first);

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
  
	end try
	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();

	exec dbo.errorlog_insert @processname,@errormsg;

	raiserror(@errormsg,16,1);

	end catch	
	
end
GO
/****** Object:  StoredProcedure [dbo].[DimStockAssessment_upsert]    Script Date: 2016/7/14 0:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[DimStockAssessment_upsert]
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
GO
/****** Object:  StoredProcedure [dbo].[DimStockList_upsert]    Script Date: 2016/7/14 0:40:27 ******/
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
	begin try

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


	set @cmd = 'update a
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

	end try
	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();

	exec dbo.errorlog_insert @processname,@errormsg;

	raiserror(@errormsg,16,1);

	end catch	
	
end
GO
/****** Object:  StoredProcedure [dbo].[errorlog_insert]    Script Date: 2016/7/14 0:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE proc [dbo].[errorlog_insert]
	@processname nvarchar(200)= '',
	@errormessage nvarchar(2000)
  as
  begin
	insert into dbo.errorlog(Name,ErrorMessage,LastUpdate)
	select @processname,@errormessage,getdate();
  end
GO
/****** Object:  StoredProcedure [dbo].[execlog_insert]    Script Date: 2016/7/14 0:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[execlog_insert]
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



GO
/****** Object:  StoredProcedure [dbo].[execlog_update]    Script Date: 2016/7/14 0:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[execlog_update]
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
GO
/****** Object:  StoredProcedure [dbo].[FctIndexDaily_upsert]    Script Date: 2016/7/14 0:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [dbo].[FctIndexDaily_upsert] '[Staging]'
CREATE proc [dbo].[FctIndexDaily_upsert] 
	@stagingdbname sysname
as
begin
set nocount on
	declare @processname nvarchar(200) = 'dbo.FctIndexDaily_upsert';

	declare @cmd varchar(max);
	begin try
	set @cmd = 'insert into dbo.DimIndexes(name)
	select distinct indexname 
	from '+@stagingdbname+'.dms.DimIndexes
	where indexname not in (select name from dbo.DimIndexes)';
	exec(@cmd);

	--select IDENT_CURRENT('dbo.DimIndexes')

	set @cmd = '			
		update f
			set f.Point = i.Point ,
			f.UpAndDown = i.UpAndDown,
			f.Rate = i.Rate,
			f.LastPoint = i.LastPoint,
			f.BeginPoint = i.BeginPoint,
			f.HighPoint = i.HighPoint,
			f.LowPoint = i.LowPoint,
			f.Volumn = i.Volumn,	
			f.Amount = i.Amount,	
			f.LastUpdate = getdate()
		from dbo.FctIndexDaily f
		join dbo.DimIndexes d
		on f.IndexID = d.ID
		join '+@stagingdbname+'.dms.DimIndexes i
		on d.Name = i.IndexName
		and f.Day = i.Day;

		insert into dbo.FctIndexDaily([Day] ,IndexID ,Point ,UpAndDown ,Rate ,LastPoint ,BeginPoint,HighPoint ,LowPoint ,
	Volumn ,	Amount ,	LastUpdate)
		select distinct i.[Day] ,	d.ID ,	i.Point ,	i.UpAndDown ,	i.Rate ,	i.LastPoint ,	i.BeginPoint,	i.HighPoint ,	i.LowPoint ,
	i.Volumn ,	i.Amount ,	getdate()
		from '+@stagingdbname+'.dms.DimIndexes i
		join dbo.DimIndexes d
		on i.IndexName = d.Name
		left join dbo.FctIndexDaily f
		on  i.Day = f.Day
		and f.IndexID = d.ID
		where f.IndexID is null;
		'
		--print @cmd;
	exec(@cmd);


	end try
	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();

	exec dbo.errorlog_insert @processname,@errormsg;

	raiserror(@errormsg,16,1);

	end catch	
	
end
GO
/****** Object:  StoredProcedure [dbo].[FctStockDaily_upsert]    Script Date: 2016/7/14 0:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[FctStockDaily_upsert]
	@stagingdbname sysname
as 
begin
set nocount on;
	declare @processname nvarchar(200) = 'dbo.FctStockDaily_upsert';
	declare @cmd varchar(1024);
	
	begin try
	set @cmd = '
	delete from dbo.FctStockDaily
	where stockid not in (select id from dbo.DimStockList)'
	exec(@cmd);

	set @cmd ='
	insert into dbo.FctStockDaily
	(	[Day] ,	StockID ,StockCode,	AssessmentID ,	StateID ,	EndPrice ,	UpAndDown ,
	Rate ,	LastPrice ,	BeginPrice ,	HighPrice ,	LowPrice ,	Volumn ,	Amount )
	select s.[Day] , d.ID ,s.StockCode, a.ID,NULL, s.EndPrice, s.UpAndDown ,
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
		set 
		f.AssessmentID = a.ID,	
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
	inner join dbo.FctStockDaily f
	on d.ID = f.StockID
	and s.[Day] = f.[Day]
	and f.StockCode = s.StockCode
	'

	exec(@cmd);
	end try
	begin catch
	declare @errormsg varchar(500) = ERROR_MESSAGE();

	exec dbo.errorlog_insert @processname,@errormsg;

	raiserror(@errormsg,16,1);
	end catch
	

end

GO
/****** Object:  StoredProcedure [dbo].[StockHistory_load]    Script Date: 2016/7/14 0:40:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[StockHistory_load]
	@stagingdb sysname,
	@staingtablename sysname
as
begin
--set nocount on
	declare @processname varchar(100) = 'dbo.StockHistory_load';

	declare @stgtablefullname varchar(100) = @stagingdb+'.'+@staingtablename;
	declare @cmd varchar(max);

	begin try
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
		join '+@stgtablefullname+' s
		on f.day=s.Day
		and d.StockCode =s.StockCode;

		insert into dbo.FctStockDaily(Day,StockID,EndPrice,BeginPrice,HighPrice,LowPrice,Volumn,Amount)
		select s.Day,d.ID,s.EndPrice,s.BeginPrice,s.HighPrice,s.LowPrice,s.Volumn/10000.00,s.Amount/10000.00
		from '+@stgtablefullname+' s
		join dbo.DimStockList d
		on s.StockCode=d.StockCode
		and d.IsCurrent=1
		left join dbo.FctStockDaily f
		on d.ID =f.StockID
		and s.Day =f.Day
		where f.StockID is null;'

	   
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
