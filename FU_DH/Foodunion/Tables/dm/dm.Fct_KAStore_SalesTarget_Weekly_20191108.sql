USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_KAStore_SalesTarget_Weekly_20191108](
	[Yearkey] [int] NOT NULL,
	[Week_Year_NBR] [int] NOT NULL,
	[Start_Date] [int] NOT NULL,
	[End_Date] [int] NOT NULL,
	[Channel] [nvarchar](50) NOT NULL,
	[Store_ID] [nvarchar](50) NOT NULL,
	[Store_Code] [nvarchar](50) NULL,
	[Store_Name] [nvarchar](100) NULL,
	[Ambient_Sales_Target] [decimal](20, 8) NULL,
	[Fresh_Sales_Target] [decimal](20, 8) NULL,
	[Sales_Target] [decimal](20, 8) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
