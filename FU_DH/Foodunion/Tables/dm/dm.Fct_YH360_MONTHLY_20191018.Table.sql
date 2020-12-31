USE [Foodunion]
GO
DROP TABLE [dm].[Fct_YH360_MONTHLY_20191018]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH360_MONTHLY_20191018](
	[Year_Month] [int] NULL,
	[MONTH_DAYS] [int] NULL,
	[Store_ID] [varchar](50) NOT NULL,
	[YH_categroy] [nvarchar](400) NULL,
	[SALES_AMT] [decimal](38, 6) NULL,
	[SALES_QTY] [decimal](38, 6) NULL,
	[VOLUME] [decimal](38, 15) NULL,
	[DISCOUNTSALES_AMT] [decimal](38, 6) NULL,
	[Sales_Target] [decimal](20, 8) NULL,
	[SALES_AMT_LM] [decimal](38, 6) NULL,
	[SALES_QTY_LM] [decimal](38, 6) NULL,
	[VOLUME_LM] [decimal](38, 15) NULL,
	[DISCOUNTSALES_AMT_LM] [decimal](38, 6) NULL,
	[ACTUAL_SALES_DAYS] [int] NULL,
	[MONTH_DAYS_LM] [int] NULL,
	[ACTUAL_SALES_DAYS_LM] [int] NULL,
	[FIRST_SALES_DATE] [date] NULL,
	[IF_DISTRIBUTION_FLG] [int] NULL,
	[IF_DISTRIBUTION_FLG_LM] [int] NULL,
	[ACTUAL_INVENTORY_DAYS] [int] NULL,
	[ACTUAL_INVENTORY_DAYS_LM] [int] NULL,
	[SALES_SKU_QTY] [int] NULL,
	[SALES_SKU_QTY_LM] [int] NULL,
	[INVENTORY_SKU_QTY] [int] NULL,
	[INVENTORY_SKU_QTY_LM] [int] NULL,
	[INVENTORY_VOLUME] [decimal](20, 8) NULL,
	[INVENTORY_VOLUME_LM] [decimal](20, 8) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
