USE [ConfigDB]
GO
ALTER TABLE [aud].[JobLog_20190514] DROP CONSTRAINT [DF__JobLog__UpdateDa__3B95D2F1]
GO
ALTER TABLE [aud].[JobLog_20190514] DROP CONSTRAINT [DF__JobLog__InsertDa__3AA1AEB8]
GO
ALTER TABLE [aud].[JobLog_20190514] DROP CONSTRAINT [DF__JobLog__StartTim__39AD8A7F]
GO
DROP TABLE [aud].[JobLog_20190514]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[JobLog_20190514](
	[JobID] [bigint] IDENTITY(1,1) NOT NULL,
	[PlanID] [int] NOT NULL,
	[PlanDescription] [nvarchar](100) NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NULL,
	[DurationInSec] [int] NULL,
	[StatusID] [int] NULL,
	[ReturnMsg] [nvarchar](max) NULL,
	[InsertDatetime] [datetime] NOT NULL,
	[UpdateDatetime] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [aud].[JobLog_20190514] ADD  DEFAULT (getdate()) FOR [StartTime]
GO
ALTER TABLE [aud].[JobLog_20190514] ADD  DEFAULT (getdate()) FOR [InsertDatetime]
GO
ALTER TABLE [aud].[JobLog_20190514] ADD  DEFAULT (getdate()) FOR [UpdateDatetime]
GO
