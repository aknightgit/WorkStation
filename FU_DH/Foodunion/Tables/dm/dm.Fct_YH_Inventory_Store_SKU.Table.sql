USE [Foodunion]
GO
DROP TABLE [dm].[Fct_YH_Inventory_Store_SKU]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Inventory_Store_SKU](
	[SKU_ID] [nvarchar](200) NULL,
	[Store_ID] [nvarchar](400) NULL,
	[Inventory_QTY] [decimal](18, 6) NULL,
	[Inventory_AMT] [decimal](18, 6) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
