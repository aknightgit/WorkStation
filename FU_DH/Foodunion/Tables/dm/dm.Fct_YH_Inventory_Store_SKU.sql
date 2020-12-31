USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Inventory_Store_SKU](
	[SKU_ID] [nvarchar](200) NOT NULL,
	[Store_ID] [nvarchar](200) NOT NULL,
	[Inventory_QTY] [decimal](18, 6) NULL,
	[Inventory_AMT] [decimal](18, 6) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_YH_Inventory_Store_SKU] PRIMARY KEY CLUSTERED 
(
	[SKU_ID] ASC,
	[Store_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
