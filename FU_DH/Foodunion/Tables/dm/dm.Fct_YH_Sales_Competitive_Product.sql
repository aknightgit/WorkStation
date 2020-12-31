USE [Foodunion]
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
	[YH_Store_CD] [nvarchar](20) NOT NULL,
	[Store_NM] [nvarchar](200) NULL,
	[Calendar_DT] [nvarchar](20) NOT NULL,
	[Sales_AMT] [nvarchar](200) NOT NULL,
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
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_YH_Sales_Competitive_Product] PRIMARY KEY CLUSTERED 
(
	[YH_Store_CD] ASC,
	[Calendar_DT] ASC,
	[Sales_AMT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
