USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_CountyLocation_20191028](
	[CountyCode] [varchar](200) NULL,
	[Province] [varchar](200) NULL,
	[City] [varchar](200) NULL,
	[County] [varchar](200) NULL,
	[Longitude] [varchar](200) NULL,
	[Latitude] [varchar](200) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](1) NOT NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](1) NOT NULL
) ON [PRIMARY]
GO
