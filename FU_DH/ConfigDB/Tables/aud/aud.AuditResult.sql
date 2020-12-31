USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[AuditResult](
	[ID] [bigint] NOT NULL,
	[JobID] [bigint] NOT NULL,
	[AuditID] [int] NOT NULL,
	[AuditName] [varchar](100) NOT NULL,
	[ConnectionType] [varchar](100) NOT NULL,
	[ServerName] [varchar](100) NOT NULL,
	[DatabaseName] [varchar](100) NOT NULL,
	[CheckQuery] [varchar](max) NULL,
	[MaxAllowed] [int] NOT NULL,
	[QueryResult] [int] NULL,
	[AlertLevel] [smallint] NULL,
	[NotifyBy] [varchar](100) NULL,
	[DingRobot] [varchar](256) NULL,
	[Mobile] [varchar](20) NULL,
	[MailDL] [varchar](1000) NULL,
	[MailCC] [varchar](1000) NULL,
	[Content] [varchar](max) NULL,
	[Status] [varchar](100) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[DurationInSecs] [int] NULL,
	[InsertDatetime] [datetime] NOT NULL,
	[UpdateDatetime] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
