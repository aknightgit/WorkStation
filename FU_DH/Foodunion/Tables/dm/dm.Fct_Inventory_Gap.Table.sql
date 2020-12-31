USE [Foodunion]
GO
DROP TABLE [dm].[Fct_Inventory_Gap]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Inventory_Gap](
	[Inventory_DT] [nvarchar](200) NULL,
	[Warehouse_ID] [int] NULL,
	[SKU_ID] [nvarchar](200) NULL,
	[Manufacturing_DT] [date] NULL,
	[Manual_Inventory_QTY] [decimal](20, 10) NULL,
	[ERP_Inventory_QTY] [decimal](20, 10) NULL,
	[GAP] [decimal](21, 10) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
