USE [Foodunion]
GO
DROP TABLE [dw].[Fct_YH_Sales_All_Not_Mapped]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[Fct_YH_Sales_All_Not_Mapped](
	[YH_Type] [nvarchar](200) NULL,
	[YH_Type_CN] [nvarchar](200) NULL,
	[SKU_ID] [nvarchar](200) NULL,
	[SKU_NM] [nvarchar](200) NULL,
	[YH_UPC] [nvarchar](200) NULL,
	[Region_CD] [nvarchar](200) NULL,
	[Region_NM] [nvarchar](200) NULL,
	[Store_ID] [nvarchar](200) NULL,
	[YH_Store_CD] [nvarchar](200) NULL,
	[Store_NM] [nvarchar](200) NULL,
	[Calendar_DT] [nvarchar](200) NULL,
	[Sales_AMT] [decimal](18, 6) NULL,
	[Sales_QTY] [decimal](18, 6) NULL,
	[DiscountSales_AMT] [decimal](18, 6) NULL,
	[DiscountSales_QTY] [decimal](18, 6) NULL,
	[WithTax_SalesCost_AMT] [decimal](18, 6) NULL,
	[Sals_Share_PC] [decimal](18, 6) NULL,
	[WithTax_Discount_AMT] [decimal](18, 6) NULL,
	[Gross_WithTax_AMT] [decimal](18, 6) NULL,
	[Gross_WithTax_PC] [decimal](18, 6) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
