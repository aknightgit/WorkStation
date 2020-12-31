USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LogSize_20191014](
	[dbname] [nvarchar](50) NOT NULL,
	[logsize] [decimal](8, 2) NOT NULL,
	[logused] [decimal](5, 2) NOT NULL,
	[status] [int] NULL
) ON [PRIMARY]
GO
