USE [ConfigDB]
GO
ALTER TABLE [dbo].[Backup] DROP CONSTRAINT [DF__Backup__Filesize__2EBBC617]
GO
DROP TABLE [dbo].[Backup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Backup](
	[First_lsn] [varchar](50) NULL,
	[Last_lsn] [varchar](50) NULL,
	[Database_name] [varchar](50) NOT NULL,
	[Name] [varchar](250) NOT NULL,
	[User_name] [varchar](50) NOT NULL,
	[Database_backup_lsn] [nchar](50) NULL,
	[Backup_start_date] [datetime] NULL,
	[Backup_finish_date] [datetime] NULL,
	[Type] [nvarchar](50) NULL,
	[Physical_device_name] [nvarchar](250) NULL,
	[Filesize] [varchar](50) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Backup] ADD  DEFAULT ((0)) FOR [Filesize]
GO
