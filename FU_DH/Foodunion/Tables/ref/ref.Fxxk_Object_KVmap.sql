USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ref].[Fxxk_Object_KVmap](
	[ID] [int] NOT NULL,
	[ObjectName] [varchar](50) NULL,
	[Keyname] [varchar](200) NULL,
	[Keyvalue] [varchar](200) NULL,
	[Update_By] [varchar](200) NULL,
	[Update_Time] [datetime] NULL
) ON [PRIMARY]
GO
