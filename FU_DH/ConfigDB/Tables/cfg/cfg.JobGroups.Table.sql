USE [ConfigDB]
GO
ALTER TABLE [cfg].[JobGroups] DROP CONSTRAINT [DF__JobGroups__Updat__5C0D8F7B]
GO
ALTER TABLE [cfg].[JobGroups] DROP CONSTRAINT [DF__JobGroups__Inser__5B196B42]
GO
ALTER TABLE [cfg].[JobGroups] DROP CONSTRAINT [DF__JobGroups__IsEna__5A254709]
GO
DROP TABLE [cfg].[JobGroups]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cfg].[JobGroups](
	[GroupID] [int] IDENTITY(1,1) NOT NULL,
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
