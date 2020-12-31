USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_DailySales_20191122](
	[Datekey] [int] NOT NULL,
	[Store_ID] [nvarchar](200) NOT NULL,
	[SKU_ID] [nvarchar](200) NOT NULL,
	[InStock_QTY] [decimal](18, 10) NULL,
	[InStock_Amount] [decimal](18, 10) NULL,
	[Sale_QTY] [decimal](18, 10) NULL,
	[Sale_Amount] [decimal](18, 10) NULL,
	[Promotion_Amount] [decimal](18, 10) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
