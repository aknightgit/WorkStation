USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Sales_Inventory](
	[SKU_ID] [nvarchar](200) NOT NULL,
	[Store_ID] [nvarchar](200) NOT NULL,
	[Calendar_DT] [int] NOT NULL,
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
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_YH_Sales_Inventory] PRIMARY KEY CLUSTERED 
(
	[Calendar_DT] DESC,
	[Store_ID] ASC,
	[SKU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [ix_n_YH_Sales_Inv_cal_store_sku_DD40] ON [dm].[Fct_YH_Sales_Inventory]
(
	[Calendar_DT] DESC,
	[SKU_ID] ASC,
	[Store_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
