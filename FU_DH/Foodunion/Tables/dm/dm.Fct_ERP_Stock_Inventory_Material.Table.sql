USE [Foodunion]
GO
DROP TABLE [dm].[Fct_ERP_Stock_Inventory_Material]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Stock_Inventory_Material](
	[Material_Group_NM] [nvarchar](200) NULL,
	[Material_NM] [nvarchar](255) NULL,
	[Warehouse_NM] [nvarchar](80) NULL,
	[Inventory_DT] [date] NULL,
	[SKU_ID] [nvarchar](80) NULL,
	[SKU_NM] [nvarchar](255) NULL,
	[Unit_DSC] [nvarchar](80) NULL,
	[Inventory_QTY] [decimal](23, 10) NULL,
	[Batch_CD] [nvarchar](255) NULL,
	[Manufacturing_DT] [date] NULL,
	[Expiring_DT] [date] NULL,
	[Storaging_DT] [date] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
