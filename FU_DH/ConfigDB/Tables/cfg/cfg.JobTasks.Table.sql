USE [ConfigDB]
GO
ALTER TABLE [cfg].[JobTasks] DROP CONSTRAINT [DF__JobTasks__Update__17D860BF]
GO
ALTER TABLE [cfg].[JobTasks] DROP CONSTRAINT [DF__JobTasks__Insert__16E43C86]
GO
ALTER TABLE [cfg].[JobTasks] DROP CONSTRAINT [DF__JobTasks__IsEnab__15F0184D]
GO
DROP TABLE [cfg].[JobTasks]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cfg].[JobTasks](
	[TaskID] [int] IDENTITY(1,1) NOT NULL,
	[GroupID] [int] NULL,
	[Category] [varchar](50) NULL,
	[TaskName] [nvarchar](100) NULL,
	[TaskType] [nvarchar](100) NULL,
	[ExecutorPath] [nvarchar](100) NULL,
	[ExecutorName] [nvarchar](100) NULL,
	[ExecQuery] [nvarchar](max) NULL,
	[ExecParameters] [nvarchar](max) NULL,
	[ExecConnectionID] [int] NULL,
	[IsEnabled] [bit] NOT NULL,
	[LastRunDate] [datetime] NULL,
	[LastRunStatus] [varchar](50) NULL,
	[InsertDatetime] [datetime] NOT NULL,
	[UpdateDatetime] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TaskID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [cfg].[JobTasks] ADD  DEFAULT ((1)) FOR [IsEnabled]
GO
ALTER TABLE [cfg].[JobTasks] ADD  DEFAULT (getdate()) FOR [InsertDatetime]
GO
ALTER TABLE [cfg].[JobTasks] ADD  DEFAULT (getdate()) FOR [UpdateDatetime]
GO
