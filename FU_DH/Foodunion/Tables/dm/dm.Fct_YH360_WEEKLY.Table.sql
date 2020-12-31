USE [Foodunion]
GO
DROP TABLE [dm].[Fct_YH360_WEEKLY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH360_WEEKLY](
	[Year] [int] NULL,
	[Week_NM] [varchar](7) NOT NULL,
	[Store_ID] [varchar](50) NOT NULL,
	[YH_categroy] [nvarchar](400) NULL,
	[SALES_AMT] [decimal](38, 6) NULL,
	[SALES_QTY] [decimal](38, 6) NULL,
	[VOLUME] [decimal](38, 15) NULL,
	[DISCOUNTSALES_AMT] [decimal](38, 6) NULL,
	[Sales_Target] [decimal](20, 8) NULL,
	[SALES_AMT_LW] [decimal](38, 6) NULL,
	[SALES_QTY_LW] [decimal](38, 6) NULL,
	[VOLUME_LW] [decimal](38, 15) NULL,
	[DISCOUNTSALES_AMT_LW] [decimal](38, 6) NULL,
	[ACTUAL_SALES_DAYS] [int] NULL,
	[ACTUAL_SALES_DAYS_LW] [int] NULL,
	[FIRST_SALES_DATE] [date] NULL,
	[IF_DISTRIBUTION_FLG] [int] NULL,
	[IF_DISTRIBUTION_FLG_LW] [int] NULL,
	[ACTUAL_INVENTORY_DAYS] [int] NULL,
	[ACTUAL_INVENTORY_DAYS_LW] [int] NULL,
	[SALES_SKU_QTY] [int] NULL,
	[SALES_SKU_QTY_LW] [int] NULL,
	[INVENTORY_SKU_QTY] [int] NULL,
	[INVENTORY_SKU_QTY_LW] [int] NULL,
	[INVENTORY_VOLUME] [decimal](20, 8) NULL,
	[INVENTORY_VOLUME_LW] [decimal](20, 8) NULL,
	[Week_Date_Period_end] [nvarchar](50) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
