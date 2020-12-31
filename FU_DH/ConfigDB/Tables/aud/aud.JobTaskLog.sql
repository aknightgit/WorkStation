USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[JobTaskLog](
	[LogID] [bigint] NOT NULL,
	[JobID] [bigint] NOT NULL,
	[PlanDescription] [nvarchar](100) NULL,
	[DateKey] [int] NOT NULL,
	[SequenceID] [int] NOT NULL,
	[GroupName] [nvarchar](100) NULL,
	[TaskName] [nvarchar](100) NULL,
	[TaskID] [int] NOT NULL,
	[TaskType] [nvarchar](100) NULL,
	[ExecutorPath] [nvarchar](100) NULL,
	[RuntimeExecutor] [nvarchar](max) NULL,
	[ExecConnectionID] [int] NULL,
	[Threads] [int] NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NULL,
	[DurationInSec] [int] NULL,
	[StatusID] [int] NULL,
	[ReturnMsg] [nvarchar](max) NULL,
	[InsertDatetime] [datetime] NOT NULL,
	[UpdateDatetime] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [aud].[JobTaskLog] ADD  DEFAULT (getdate()) FOR [StartTime]
GO
ALTER TABLE [aud].[JobTaskLog] ADD  DEFAULT (getdate()) FOR [InsertDatetime]
GO
ALTER TABLE [aud].[JobTaskLog] ADD  DEFAULT (getdate()) FOR [UpdateDatetime]
GO
