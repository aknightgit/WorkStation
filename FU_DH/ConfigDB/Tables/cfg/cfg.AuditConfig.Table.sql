USE [ConfigDB]
GO
ALTER TABLE [cfg].[AuditConfig] DROP CONSTRAINT [DF__AuditConf__Updat__0BDC9E2E]
GO
ALTER TABLE [cfg].[AuditConfig] DROP CONSTRAINT [DF__AuditConf__Inser__0AE879F5]
GO
ALTER TABLE [cfg].[AuditConfig] DROP CONSTRAINT [DF__AuditConf__IsEna__09F455BC]
GO
ALTER TABLE [cfg].[AuditConfig] DROP CONSTRAINT [DF__AuditConf__MaxAl__09003183]
GO
DROP TABLE [cfg].[AuditConfig]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cfg].[AuditConfig](
	[AuditID] [int] IDENTITY(1,1) NOT NULL,
	[AuditName] [varchar](100) NOT NULL,
	[AuditDesc] [varchar](100) NULL,
	[ConnectionID] [int] NOT NULL,
	[CheckQuery] [varchar](max) NULL,
	[MaxAllowed] [int] NOT NULL,
	[IsEnabled] [bit] NULL,
	[AlertLevel] [smallint] NULL,
	[NotifyBy] [varchar](100) NULL,
	[DingRobot] [varchar](256) NULL,
	[Mobile] [varchar](20) NULL,
	[MailDL] [varchar](1000) NULL,
	[MailCC] [varchar](1000) NULL,
	[ContentType] [varchar](1000) NULL,
	[ContentText] [varchar](max) NULL,
	[XMLConfigFile] [varchar](1000) NULL,
	[AlertOnce] [bit] NULL,
	[AlertBeginHour] [int] NULL,
	[AlertEndHour] [int] NULL,
	[LastRunDate] [datetime] NULL,
	[LastRunReturn] [varchar](1000) NULL,
	[InsertDatetime] [datetime] NOT NULL,
	[UpdateDatetime] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [cfg].[AuditConfig] ADD  DEFAULT ((0)) FOR [MaxAllowed]
GO
ALTER TABLE [cfg].[AuditConfig] ADD  DEFAULT ((1)) FOR [IsEnabled]
GO
ALTER TABLE [cfg].[AuditConfig] ADD  DEFAULT (getdate()) FOR [InsertDatetime]
GO
ALTER TABLE [cfg].[AuditConfig] ADD  DEFAULT (getdate()) FOR [UpdateDatetime]
GO
