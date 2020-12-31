USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_StoreInventory](
	[DateKey] [bigint] NOT NULL,
	[SKU_ID] [nvarchar](20) NOT NULL,
	[SKU_Code] [nvarchar](20) NULL,
	[Batch_No] [nvarchar](20) NOT NULL,
	[Sales_Price] [decimal](18, 2) NULL,
	[Cost_Price] [decimal](18, 2) NULL,
	[Tax_Rate] [decimal](18, 3) NULL,
	[Store_ID] [nvarchar](20) NOT NULL,
	[Store_Code] [nvarchar](20) NULL,
	[Cargo_Rack] [nvarchar](50) NOT NULL,
	[QTY] [int] NULL,
	[Info_Update_Time] [datetime] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_StoreInventory] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC,
	[SKU_ID] ASC,
	[Batch_No] ASC,
	[Store_ID] ASC,
	[Cargo_Rack] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
