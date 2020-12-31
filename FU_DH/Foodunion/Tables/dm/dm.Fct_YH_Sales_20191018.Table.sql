USE [Foodunion]
GO
DROP TABLE [dm].[Fct_YH_Sales_20191018]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Sales_20191018](
	[POS_DT] [int] NULL,
	[SKU_ID] [nvarchar](50) NULL,
	[Store_ID] [nvarchar](50) NULL,
	[Sales_AMT] [decimal](18, 6) NULL,
	[Sales_QTY] [decimal](18, 6) NULL,
	[Sales_VOL] [decimal](18, 6) NULL,
	[DiscountSales_AMT] [decimal](18, 6) NULL,
	[DiscountSales_QTY] [decimal](18, 6) NULL,
	[WithTax_SalesCost_AMT] [decimal](18, 6) NULL,
	[WithTax_Discount_AMT] [decimal](18, 6) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
