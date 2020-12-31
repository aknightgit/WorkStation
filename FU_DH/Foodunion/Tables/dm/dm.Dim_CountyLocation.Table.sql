USE [Foodunion]
GO
DROP TABLE [dm].[Dim_CountyLocation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_CountyLocation](
	[CountyCode] [varchar](200) NULL,
	[Province] [varchar](200) NULL,
	[City] [varchar](200) NULL,
	[County] [varchar](200) NULL,
	[Longitude] [varchar](200) NULL,
	[Latitude] [varchar](200) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](20) NOT NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](20) NOT NULL
) ON [PRIMARY]
GO
