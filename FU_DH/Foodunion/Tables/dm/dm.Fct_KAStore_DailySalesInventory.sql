USE [Foodunion]
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
	[Update_By] [nvarchar](100) NULL,
	[Sellin_Price_ID] [int] NULL,
	[Inventory_Gross_Cost] [decimal](18, 9) NULL,
	[Inventory_Net_Cost] [decimal](18, 9) NULL,
 CONSTRAINT [PK_Fct_KAStore_DailySalesInventory_C064] PRIMARY KEY CLUSTERED 
(
	[Datekey] ASC,
	[Store_ID] ASC,
	[SKU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_KAStore_DailySalesInventory] ADD  CONSTRAINT [DF__Fct_KASto__Creat__3ACC9741]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_KAStore_DailySalesInventory] ADD  CONSTRAINT [DF__Fct_KASto__Updat__3BC0BB7A]  DEFAULT (getdate()) FOR [Update_Time]
GO
