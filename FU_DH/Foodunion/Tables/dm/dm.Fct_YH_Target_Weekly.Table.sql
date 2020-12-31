USE [Foodunion]
GO
ALTER TABLE [dm].[Fct_YH_Target_Weekly] DROP CONSTRAINT [DF__Fct_YH_Ta__Updat__2858E14B]
GO
ALTER TABLE [dm].[Fct_YH_Target_Weekly] DROP CONSTRAINT [DF__Fct_YH_Ta__Creat__2764BD12]
GO
DROP TABLE [dm].[Fct_YH_Target_Weekly]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Target_Weekly](
	[Yearkey] [int] NOT NULL,
	[Week_Year_NBR] [int] NOT NULL,
	[Start_Date] [int] NOT NULL,
	[End_Date] [int] NOT NULL,
	[Store_ID] [nvarchar](50) NULL,
	[Region] [nvarchar](50) NULL,
	[Store_Name] [nvarchar](512) NULL,
	[Sales_Target] [decimal](18, 9) NULL,
	[Ambient_Sales_Target] [decimal](18, 9) NULL,
	[Fresh_Sales_Target] [decimal](18, 9) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
	[KPI_DESC] [nchar](10) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_YH_Target_Weekly] ADD  CONSTRAINT [DF__Fct_YH_Ta__Creat__2764BD12]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_YH_Target_Weekly] ADD  CONSTRAINT [DF__Fct_YH_Ta__Updat__2858E14B]  DEFAULT (getdate()) FOR [Update_Time]
GO
