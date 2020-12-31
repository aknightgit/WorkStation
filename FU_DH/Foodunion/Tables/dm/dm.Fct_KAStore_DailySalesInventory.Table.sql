USE [Foodunion]
GO
ALTER TABLE [dm].[Fct_KAStore_DailySalesInventory] DROP CONSTRAINT [DF__Fct_KASto__Updat__3BC0BB7A]
GO
ALTER TABLE [dm].[Fct_KAStore_DailySalesInventory] DROP CONSTRAINT [DF__Fct_KASto__Creat__3ACC9741]
GO
DROP TABLE [dm].[Fct_KAStore_DailySalesInventory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_KAStore_DailySalesInventory](
	[Datekey] [int] NOT NULL,
	[Store_ID] [nvarchar](50) NOT NULL,
	[SKU_ID] [nvarchar](50) NOT NULL,
	[Store_Code] [nvarchar](50) NULL,
	[Store_Name] [nvarchar](100) NULL,
	[KA_SKU_Name] [varchar](200) NULL,
	[Sale_Scale] [nvarchar](50) NULL,
	[InStock_Qty] [decimal](18, 9) NULL,
	[TransferIn_Qty] [decimal](18, 9) NULL,
	[TransferOut_Qty] [decimal](18, 9) NULL,
	[Return_Qty] [decimal](18, 9) NULL,
	[Sales_Qty] [decimal](18, 9) NULL,
	[Sales_AMT] [decimal](18, 9) NULL,
	[Sales_Vol_KG] [decimal](18, 9) NULL,
	[Inventory_Qty] [decimal](18, 9) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_KAStore_DailySalesInventory] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_KAStore_DailySalesInventory] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
