USE [ConfigDB]
GO
DROP TABLE [aud].[Database_Monitor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[Database_Monitor](
	[Datekey] [int] NOT NULL,
	[DatabaseName] [varchar](100) NOT NULL,
	[DataFileSizeMB] [decimal](18, 2) NULL,
	[LogFileSizeMB] [decimal](18, 2) NULL,
	[InsertDatetime] [datetime] NULL,
	[UpdateDatetime] [datetime] NULL
) ON [PRIMARY]
GO
