USE [Foodunion]
GO
DROP TABLE [dm].[Dim_indicator_desc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_indicator_desc](
	[Indicator] [nvarchar](50) NULL,
	[Desc_CN] [nvarchar](500) NULL,
	[Report_NM] [nvarchar](50) NULL
) ON [PRIMARY]
GO
