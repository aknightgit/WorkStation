USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SP_EXEC_Stats_Foodunion](
	[Object_ID] [int] NOT NULL,
	[Database_ID] [int] NOT NULL,
	[Database_Name] [nvarchar](128) NOT NULL,
	[Schema_Name] [sysname] NULL,
	[存储过程名称] [sysname] NOT NULL,
	[创建日期] [datetime] NOT NULL,
	[修改日期] [datetime] NOT NULL,
	[最后一次运行时间(S)] [bigint] NULL,
	[总耗时时间(S)] [bigint] NULL,
	[执行总次数] [bigint] NOT NULL,
	[最后一次执行时间] [datetime] NOT NULL,
	[创建天数(天)] [int] NULL,
	[运行频率(次/天)] [decimal](19, 2) NULL,
	[Load_Date] [datetime] NULL
) ON [PRIMARY]
GO
