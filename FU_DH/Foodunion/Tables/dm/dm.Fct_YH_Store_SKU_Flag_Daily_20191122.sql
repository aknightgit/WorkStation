USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Store_SKU_Flag_Daily_20191122](
	[Date_ID] [int] NOT NULL,
	[Store_ID] [varchar](50) NOT NULL,
	[SKU_ID] [varchar](50) NOT NULL,
	[Sales_AMT] [decimal](38, 6) NULL,
	[Sales_QTY] [decimal](38, 6) NULL,
	[Sales_Vol] [decimal](38, 6) NULL,
	[Inventory_AMT] [decimal](38, 6) NULL,
	[Inventory_QTY] [decimal](38, 6) NULL,
	[Inventory_Vol] [decimal](38, 6) NULL,
	[Min_Inv_Qty_In_Last_3_Day_Is_0] [int] NOT NULL,
	[Min_Inv_Qty_In_Last_3_Day_GT_0] [int] NOT NULL,
	[Min_Inv_Qty_In_Last_3_Day_GT_5] [int] NOT NULL,
	[Min_Inv_Qty_In_Last_3_Day_GT_10] [int] NOT NULL,
	[Sales_Store_AVG_AMT_REGION] [decimal](38, 6) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
