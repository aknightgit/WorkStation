USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Order_CombineItem](
	[Outer_SKU_ID] [nvarchar](200) NOT NULL,
	[SKU_ID] [nvarchar](200) NOT NULL,
	[Quantity] [int] NULL,
	[Begin_Date] [int] NOT NULL,
	[End_Date] [int] NOT NULL,
	[Is_Current] [int] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Dim_Order_CombineItem] PRIMARY KEY CLUSTERED 
(
	[Outer_SKU_ID] ASC,
	[SKU_ID] ASC,
	[Begin_Date] ASC,
	[End_Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
