USE [Foodunion]
GO
ALTER TABLE [dm].[Dim_Plant] DROP CONSTRAINT [DF__Dim_Plant__Updat__604834B3]
GO
ALTER TABLE [dm].[Dim_Plant] DROP CONSTRAINT [DF__Dim_Plant__Creat__5F54107A]
GO
DROP TABLE [dm].[Dim_Plant]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Plant](
	[Plant_ID] [smallint] NOT NULL,
	[Plant_Code] [varchar](20) NULL,
	[Plant_Name] [nvarchar](100) NOT NULL,
	[Plant_Name_CN] [nvarchar](100) NOT NULL,
	[Launch_Date] [datetime] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Plant] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Plant] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
