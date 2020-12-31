USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Store_Flag_Monthly_20191018](
	[YearMonth] [varchar](12) NULL,
	[Store_ID] [varchar](50) NOT NULL,
	[YH_categroy] [nvarchar](400) NULL,
	[Sales_AMT] [decimal](38, 6) NULL,
	[Sales_QTY] [decimal](38, 6) NULL,
	[Sales_Volume] [decimal](38, 6) NULL,
	[Inventory_AMT] [decimal](38, 6) NULL,
	[Inventory_QTY] [decimal](38, 6) NULL,
	[Inventory_Volume] [decimal](38, 6) NULL,
	[Sales_LM_AMT] [float] NULL,
	[Sales_LM_QTY] [float] NULL,
	[Sales_LM_Volume] [float] NULL,
	[Inventory_LM_AMT] [float] NULL,
	[Inventory_LM_QTY] [float] NULL,
	[Inventory_LM_Volume] [float] NULL,
	[Has_Inventory_SKU_NUM] [int] NULL,
	[Has_Inventory_LM_SKU_NUM] [int] NULL,
	[Is_Sold_SKU_NUM] [int] NULL,
	[Is_Sold_LM_SKU_NUM] [int] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
