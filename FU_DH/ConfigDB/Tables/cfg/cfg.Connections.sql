USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cfg].[Connections](
	[ConnectionID] [int] NOT NULL,
	[ConnectionName] [nvarchar](100) NULL,
	[ConnectionType] [nvarchar](100) NOT NULL,
	[ServerName] [nvarchar](100) NULL,
	[PortNumber] [nvarchar](100) NULL,
	[DatabaseName] [nvarchar](100) NULL,
	[UserName] [nvarchar](100) NULL,
	[Password] [nvarchar](100) NULL,
	[FilePath] [nvarchar](100) NULL,
	[InsertDatetime] [datetime] NOT NULL,
	[UpdateDatetime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [cfg].[Connections] ADD  DEFAULT ('') FOR [ServerName]
GO
ALTER TABLE [cfg].[Connections] ADD  DEFAULT (getdate()) FOR [InsertDatetime]
GO
ALTER TABLE [cfg].[Connections] ADD  DEFAULT (getdate()) FOR [UpdateDatetime]
GO
