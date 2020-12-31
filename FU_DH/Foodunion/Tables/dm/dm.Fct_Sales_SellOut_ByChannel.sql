﻿USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_SellOut_ByChannel](
	[DateKey] [int] NOT NULL,
	[Channel_ID] [int] NOT NULL,
	[SKU_ID] [varchar](50) NOT NULL,
	[QTY] [decimal](18, 5) NULL,
	[Amount] [decimal](18, 5) NULL,
	[Amount_woTax] [decimal](18, 2) NULL,
	[Discount_Amount] [decimal](18, 5) NULL,
	[Unit_Price] [decimal](18, 5) NULL,
	[Weight_KG] [decimal](18, 5) NULL,
	[Volume_L] [decimal](18, 5) NULL,
	[Create_time] [datetime] NOT NULL,
	[Create_By] [varchar](78) NULL,
	[Update_time] [datetime] NOT NULL,
	[Update_By] [varchar](78) NULL,
 CONSTRAINT [PK__Fct_Sale__EBC070EE634C8627_985A] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC,
	[Channel_ID] ASC,
	[SKU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_Sales_SellOut_ByChannel] ADD  CONSTRAINT [DF__Fct_Sales__Creat__11606D5A]  DEFAULT (getdate()) FOR [Create_time]
GO
ALTER TABLE [dm].[Fct_Sales_SellOut_ByChannel] ADD  CONSTRAINT [DF__Fct_Sales__Updat__12549193]  DEFAULT (getdate()) FOR [Update_time]
GO
