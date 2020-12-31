USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_SellIn_ByChannel_2019](
	[DateKey] [int] NOT NULL,
	[Channel_ID] [int] NOT NULL,
	[Sale_Dept] [varchar](100) NOT NULL,
	[SKU_ID] [varchar](50) NOT NULL,
	[QTY] [decimal](18, 5) NULL,
	[Stock_QTY] [decimal](18, 9) NULL,
	[Amount] [decimal](18, 5) NULL,
	[Discount_Amount] [decimal](18, 5) NULL,
	[Full_Amount] [decimal](18, 5) NULL,
	[Unit_Price] [decimal](18, 5) NULL,
	[Weight_KG] [decimal](18, 5) NULL,
	[Volume_L] [decimal](18, 5) NULL,
	[Order_Amount] [decimal](18, 5) NULL,
	[Full_Order_Amount] [decimal](18, 5) NULL,
	[status] [varchar](100) NOT NULL,
	[Create_time] [datetime] NOT NULL,
	[Create_By] [varchar](100) NULL,
	[Update_time] [datetime] NOT NULL,
	[Update_By] [varchar](100) NULL,
 CONSTRAINT [PK_Fct_Sales_SellIn_ByChannel_2019] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC,
	[Channel_ID] ASC,
	[Sale_Dept] ASC,
	[SKU_ID] ASC,
	[status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
