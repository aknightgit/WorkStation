USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Order_CombineItem_20191120](
	[Outer_SKU_ID] [nvarchar](200) NOT NULL,
	[SKU_ID] [varchar](200) NULL,
	[Quantity] [int] NULL,
	[Begin_Date] [int] NOT NULL,
	[End_Date] [int] NOT NULL,
	[Is_Current] [int] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
