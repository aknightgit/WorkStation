USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cfg].[JobPlans](
	[PlanID] [int] NOT NULL,
	[PlanDescription] [nvarchar](100) NULL,
	[NotificationDL] [nvarchar](500) NULL,
	[NotificationCC] [nvarchar](500) NULL,
	[LastRunDate] [datetime] NULL,
	[LastRunStatus] [varchar](50) NULL,
	[InsertDatetime] [datetime] NOT NULL,
	[UpdateDatetime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [cfg].[JobPlans] ADD  DEFAULT (getdate()) FOR [InsertDatetime]
GO
ALTER TABLE [cfg].[JobPlans] ADD  DEFAULT (getdate()) FOR [UpdateDatetime]
GO
