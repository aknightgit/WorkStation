USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_SellOut_ByChannel_20191225](
	[DateKey] [int] NOT NULL,
	[Channel_ID] [int] NOT NULL,
	[SKU_ID] [varchar](50) NOT NULL,
	[QTY] [decimal](18, 5) NULL,
	[Amount] [decimal](18, 5) NULL,
	[Discount_Amount] [decimal](18, 5) NULL,
	[Unit_Price] [decimal](18, 5) NULL,
	[Weight_KG] [decimal](18, 5) NULL,
	[Volume_L] [decimal](18, 5) NULL,
	[Create_time] [datetime] NOT NULL,
	[Create_By] [varchar](78) NULL,
	[Update_time] [datetime] NOT NULL,
	[Update_By] [varchar](78) NULL
) ON [PRIMARY]
GO
