USE [ConfigDB]
GO
ALTER TABLE [cfg].[AuditConfig_20190715] DROP CONSTRAINT [DF__AuditConf__Updat__78C9C9BA]
GO
ALTER TABLE [cfg].[AuditConfig_20190715] DROP CONSTRAINT [DF__AuditConf__Inser__77D5A581]
GO
ALTER TABLE [cfg].[AuditConfig_20190715] DROP CONSTRAINT [DF__AuditConf__IsEna__76E18148]
GO
ALTER TABLE [cfg].[AuditConfig_20190715] DROP CONSTRAINT [DF__AuditConf__MaxAl__75ED5D0F]
GO
DROP TABLE [cfg].[AuditConfig_20190715]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cfg].[AuditConfig_20190715](
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
	[LastRunDate] [varchar](1000) NULL,
	[LastRunReturn] [varchar](1000) NULL,
	[InsertDatetime] [datetime] NOT NULL,
	[UpdateDatetime] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [cfg].[AuditConfig_20190715] ADD  DEFAULT ((0)) FOR [MaxAllowed]
GO
ALTER TABLE [cfg].[AuditConfig_20190715] ADD  DEFAULT ((1)) FOR [IsEnabled]
GO
ALTER TABLE [cfg].[AuditConfig_20190715] ADD  DEFAULT (getdate()) FOR [InsertDatetime]
GO
ALTER TABLE [cfg].[AuditConfig_20190715] ADD  DEFAULT (getdate()) FOR [UpdateDatetime]
GO
