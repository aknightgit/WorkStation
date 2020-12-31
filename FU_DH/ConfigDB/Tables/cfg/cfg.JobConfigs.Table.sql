USE [ConfigDB]
GO
ALTER TABLE [cfg].[JobConfigs] DROP CONSTRAINT [DF__JobConfig__Updat__304F08CE]
GO
ALTER TABLE [cfg].[JobConfigs] DROP CONSTRAINT [DF__JobConfig__Inser__2F5AE495]
GO
DROP TABLE [cfg].[JobConfigs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cfg].[JobConfigs](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ItemName] [varchar](100) NOT NULL,
	[ItemDesc] [varchar](100) NULL,
	[ItemValue] [varchar](1000) NULL,
	[InsertDatetime] [datetime] NOT NULL,
	[UpdateDatetime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [cfg].[JobConfigs] ADD  DEFAULT (getdate()) FOR [InsertDatetime]
GO
ALTER TABLE [cfg].[JobConfigs] ADD  DEFAULT (getdate()) FOR [UpdateDatetime]
GO
