USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Product_AccountCodeMapping_20191128](
	[Account] [varchar](50) NOT NULL,
	[SKU_ID] [nvarchar](200) NULL,
	[SKU_Code] [varchar](50) NOT NULL,
	[Bar_Code] [varchar](50) NULL,
	[Split_Number] [int] NULL,
	[Retail_price_group] [decimal](18, 6) NULL,
	[Retail_price_bottle] [decimal](18, 6) NULL,
	[Update_By] [varchar](100) NULL,
	[Update_Time] [datetime] NULL
) ON [PRIMARY]
GO
