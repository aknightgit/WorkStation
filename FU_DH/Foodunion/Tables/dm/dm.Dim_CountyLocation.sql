USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_CountyLocation](
	[CountyCode] [varchar](200) NOT NULL,
	[Province] [varchar](200) NULL,
	[Province_Short] [varchar](10) NULL,
	[City] [varchar](200) NULL,
	[County] [varchar](200) NULL,
	[Longitude] [varchar](200) NULL,
	[Latitude] [varchar](200) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](20) NOT NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](20) NOT NULL,
 CONSTRAINT [PK_Dim_CountyLocation_8BF9_3C0A] PRIMARY KEY CLUSTERED 
(
	[CountyCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
