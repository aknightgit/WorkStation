USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[AuditJob](
	[JobID] [bigint] NOT NULL,
	[Status] [varchar](100) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[DurationInSecs] [int] NULL,
	[InsertDatetime] [datetime] NOT NULL,
	[UpdateDatetime] [datetime] NOT NULL
) ON [PRIMARY]
GO
