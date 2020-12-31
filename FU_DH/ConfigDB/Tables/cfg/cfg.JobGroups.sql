USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cfg].[JobGroups](
	[GroupID] [int] NOT NULL,
	[GroupName] [nvarchar](100) NULL,
	[GroupDescription] [nvarchar](100) NULL,
	[IsEnabled] [bit] NOT NULL,
	[InsertDatetime] [datetime] NOT NULL,
	[UpdateDatetime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [cfg].[JobGroups] ADD  DEFAULT ((1)) FOR [IsEnabled]
GO
ALTER TABLE [cfg].[JobGroups] ADD  DEFAULT (getdate()) FOR [InsertDatetime]
GO
ALTER TABLE [cfg].[JobGroups] ADD  DEFAULT (getdate()) FOR [UpdateDatetime]
GO
