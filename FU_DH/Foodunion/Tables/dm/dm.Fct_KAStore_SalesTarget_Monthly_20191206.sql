USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_KAStore_SalesTarget_Monthly_20191206](
	[Monthkey] [int] NOT NULL,
	[Channel] [nvarchar](50) NOT NULL,
	[Channel_ID] [nvarchar](50) NULL,
	[Area] [nvarchar](50) NULL,
	[Store_ID] [nvarchar](50) NULL,
	[Store_Code] [nvarchar](50) NULL,
	[Store_Name] [nvarchar](100) NULL,
	[Ambient_Sales_Target] [decimal](20, 8) NULL,
	[Fresh_Sales_Target] [decimal](20, 8) NULL,
	[Sales_Target] [decimal](20, 8) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
