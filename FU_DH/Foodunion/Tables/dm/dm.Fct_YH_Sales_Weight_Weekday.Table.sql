USE [Foodunion]
GO
DROP TABLE [dm].[Fct_YH_Sales_Weight_Weekday]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Sales_Weight_Weekday](
	[Region] [nvarchar](50) NULL,
	[Week_Day] [int] NULL,
	[Week_Day_Weight] [decimal](38, 10) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
