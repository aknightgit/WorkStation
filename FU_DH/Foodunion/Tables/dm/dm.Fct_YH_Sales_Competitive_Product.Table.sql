USE [Foodunion]
GO
DROP TABLE [dm].[Fct_YH_Sales_Competitive_Product]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Sales_Competitive_Product](
	[YH_Type] [nvarchar](200) NULL,
	[YH_Type_CN] [nvarchar](200) NULL,
	[SKU_ID] [nvarchar](200) NULL,
	[SKU_NM] [nvarchar](200) NULL,
	[YH_UPC] [nvarchar](200) NULL,
	[SC_Density_SKU_Ton_Num] [nvarchar](200) NULL,
	[YH_categroy] [nvarchar](200) NULL,
	[Region_CD] [nvarchar](200) NULL,
	[Region_NM] [nvarchar](200) NULL,
	[Store_ID] [nvarchar](200) NULL,
	[YH_Store_CD] [nvarchar](200) NULL,
	[Store_NM] [nvarchar](200) NULL,
	[Calendar_DT] [nvarchar](200) NULL,
	[Sales_AMT] [nvarchar](200) NULL,
	[Sales_QTY] [nvarchar](200) NULL,
	[DiscountSales_AMT] [nvarchar](200) NULL,
	[DiscountSales_QTY] [nvarchar](200) NULL,
	[WithTax_SalesCost_AMT] [nvarchar](200) NULL,
	[Sals_Share_PC] [nvarchar](200) NULL,
	[WithTax_Discount_AMT] [nvarchar](200) NULL,
	[Gross_WithTax_AMT] [nvarchar](200) NULL,
	[Gross_WithTax_PC] [nvarchar](200) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
