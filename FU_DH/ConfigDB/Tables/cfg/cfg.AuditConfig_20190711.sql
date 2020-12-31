USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cfg].[AuditConfig_20190711](
	[AuditID] [int] NOT NULL,
	[AuditName] [varchar](100) NOT NULL,
	[AuditDesc] [varchar](100) NULL,
	[ConnectionID] [int] NOT NULL,
	[CheckQuery] [varchar](max) NULL,
	[MaxAllowed] [int] NOT NULL,
	[IsEnabled] [bit] NULL,
	[AlertLevel] [smallint] NULL,
	[NotificationDL] [varchar](1000) NULL,
	[NotificationCC] [varchar](1000) NULL,
	[NotificationContent] [varchar](max) NULL,
	[LastRunDate] [varchar](1000) NULL,
	[LastRunReturn] [varchar](1000) NULL,
	[InsertDatetime] [datetime] NOT NULL,
	[UpdateDatetime] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
