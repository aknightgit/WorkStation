USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Sales_RegionsbyProvince](
	[Province_Code] [varchar](20) NULL,
	[Province] [varchar](100) NULL,
	[Region_ID] [int] NULL,
	[Region] [varchar](100) NULL,
	[Province_Manager] [varchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Sales_RegionsbyProvince] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Sales_RegionsbyProvince] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
