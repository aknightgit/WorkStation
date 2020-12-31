USE [Foodunion]
GO
DROP TABLE [dw].[Fct_Inventory_Outstock_bkp]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[Fct_Inventory_Outstock_bkp](
	[Warehouse_ID] [varchar](8) NULL,
	[Outstock_DT] [varchar](8) NULL,
	[SKU_ID] [nvarchar](200) NULL,
	[MANUFACTURING_DT] [varchar](8) NULL,
	[Order_QTY] [decimal](38, 0) NULL,
	[Actual_QTY] [decimal](38, 0) NULL,
	[Actual_Weight] [decimal](38, 0) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
