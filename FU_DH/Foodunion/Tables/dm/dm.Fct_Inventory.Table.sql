USE [Foodunion]
GO
DROP TABLE [dm].[Fct_Inventory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Inventory](
	[Warehouse_ID] [int] NULL,
	[Vendor_CD] [nvarchar](200) NULL,
	[RDC_CD] [nvarchar](200) NULL,
	[Inventory_DT] [nvarchar](200) NULL,
	[SKU_ID] [nvarchar](200) NULL,
	[SKU_NM] [nvarchar](200) NULL,
	[SKU_EN_NM] [nvarchar](200) NULL,
	[UPC_CD] [nvarchar](200) NULL,
	[Brand_NM] [nvarchar](200) NULL,
	[SKU_Category_NM] [nvarchar](200) NULL,
	[Density_NUM] [float] NULL,
	[Measurement_Standard_DSC] [nvarchar](200) NULL,
	[Measurement_Sales_DSC] [nvarchar](200) NULL,
	[Inventory_QTY] [decimal](20, 10) NULL,
	[Assigned_QTY] [decimal](20, 10) NULL,
	[Freezing_QTY] [decimal](20, 10) NULL,
	[Avaliable_QTY] [decimal](20, 10) NULL,
	[Manufacturing_DT] [date] NULL,
	[Expiring_DT] [date] NULL,
	[Storaging_DT] [date] NULL,
	[Inventory_Type] [nvarchar](200) NULL,
	[Is_Damaged] [nvarchar](200) NULL,
	[Is_Expired] [nvarchar](200) NULL,
	[Batch_CD] [nvarchar](200) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
