USE [Foodunion]
GO
DROP TABLE [dm].[Fct_YH_Goods_Display_20191018]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Goods_Display_20191018](
	[Calendar_DT] [int] NULL,
	[YH_City] [nvarchar](200) NULL,
	[YH_Store_CD] [nvarchar](200) NULL,
	[YH_Store_NM] [nvarchar](200) NULL,
	[YH_TYPE] [nvarchar](200) NULL,
	[SKU_ID] [nvarchar](200) NULL,
	[SKU_QTY] [decimal](19, 10) NULL,
	[SKU_KG_Vol] [decimal](19, 10) NULL,
	[Inventory_QTY] [decimal](19, 10) NULL,
	[Inventory_KG_Vol] [decimal](19, 10) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
