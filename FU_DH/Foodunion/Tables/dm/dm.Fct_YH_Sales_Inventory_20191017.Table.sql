USE [Foodunion]
GO
DROP TABLE [dm].[Fct_YH_Sales_Inventory_20191017]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Sales_Inventory_20191017](
	[SKU_ID] [nvarchar](200) NOT NULL,
	[Store_ID] [nvarchar](200) NOT NULL,
	[Calendar_DT] [int] NULL,
	[Sales_AMT] [decimal](18, 6) NULL,
	[Sales_QTY] [decimal](18, 6) NULL,
	[DiscountSales_AMT] [decimal](18, 6) NULL,
	[DiscountSales_QTY] [decimal](18, 6) NULL,
	[Inventory_AMT] [decimal](18, 6) NULL,
	[Inventory_WithTax_AMT] [decimal](18, 6) NULL,
	[Inventory_QTY] [decimal](18, 6) NULL,
	[Inventory_LD_AMT] [decimal](18, 6) NULL,
	[Inventory_WithTax_LD_AMT] [decimal](18, 6) NULL,
	[Inventory_LD_QTY] [decimal](18, 6) NULL,
	[Is_Sold_FL] [int] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
