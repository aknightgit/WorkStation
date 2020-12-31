USE [ConfigDB]
GO
DROP TABLE [dbo].[and.ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[and.ConfigDB](
	[name] [varchar](255) NULL,
	[rows] [int] NULL,
	[reserved] [varchar](50) NULL,
	[data] [varchar](50) NULL,
	[index_size] [varchar](50) NULL,
	[unused] [varchar](50) NULL
) ON [PRIMARY]
GO
