USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Product_OutSKUMapping](
	[Account] [varchar](100) NULL,
	[OutSKUID] [varchar](100) NULL,
	[OutSKUName] [varchar](200) NULL,
	[SKUMappingName] [varchar](500) NULL,
	[SKU_ID] [varchar](100) NULL,
	[Price] [decimal](18, 1) NULL,
	[PriceRatio] [decimal](18, 6) NULL,
	[QTY] [int] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [varchar](100) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](100) NULL
) ON [PRIMARY]
GO
