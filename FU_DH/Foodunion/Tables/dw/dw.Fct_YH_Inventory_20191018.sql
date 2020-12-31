USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[Fct_YH_Inventory_20191018](
	[YH_Type] [nvarchar](255) NULL,
	[YH_Type_CN] [nvarchar](255) NULL,
	[SKU_ID] [nvarchar](255) NULL,
	[SKU_NM] [nvarchar](255) NULL,
	[YH_UPC] [nvarchar](255) NULL,
	[Region_CD] [nvarchar](255) NULL,
	[Region_NM] [nvarchar](255) NULL,
	[Store_ID] [nvarchar](255) NULL,
	[Store_NM] [nvarchar](255) NULL,
	[Calendar_DT] [nvarchar](255) NULL,
	[Inventory_AMT] [decimal](18, 6) NULL,
	[Inventory_WithTax_AMT] [decimal](18, 6) NULL,
	[Inventory_QTY] [decimal](18, 6) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
