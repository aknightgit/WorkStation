USE [ConfigDB]
GO
ALTER TABLE [aud].[JobLog] DROP CONSTRAINT [DF__JobLog__UpdateDa__4A78EF25]
GO
ALTER TABLE [aud].[JobLog] DROP CONSTRAINT [DF__JobLog__InsertDa__4984CAEC]
GO
ALTER TABLE [aud].[JobLog] DROP CONSTRAINT [DF__JobLog__StartTim__4890A6B3]
GO
DROP TABLE [aud].[JobLog]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[JobLog](
	[JobID] [bigint] IDENTITY(1,1) NOT NULL,
	[PlanID] [int] NOT NULL,
	[PlanDescription] [nvarchar](100) NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NULL,
	[DurationInSec] [int] NULL,
	[StatusID] [int] NULL,
	[FailSequenceID] [int] NULL,
	[ReturnMsg] [nvarchar](max) NULL,
	[InsertDatetime] [datetime] NOT NULL,
	[UpdateDatetime] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [aud].[JobLog] ADD  DEFAULT (getdate()) FOR [StartTime]
GO
ALTER TABLE [aud].[JobLog] ADD  DEFAULT (getdate()) FOR [InsertDatetime]
GO
ALTER TABLE [aud].[JobLog] ADD  DEFAULT (getdate()) FOR [UpdateDatetime]
GO
