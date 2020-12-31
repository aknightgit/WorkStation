USE [Foodunion]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_ReturnStockEntry] DROP CONSTRAINT [DF__Fct_ERP_S__Updat__430CD787]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_ReturnStockEntry] DROP CONSTRAINT [DF__Fct_ERP_S__Creat__4218B34E]
GO
DROP TABLE [dm].[Fct_ERP_Stock_ReturnStockEntry]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Stock_ReturnStockEntry](
	[ReturnStock_ID] [int] NOT NULL,
	[Sequence_ID] [int] NOT NULL,
	[SKU_ID] [nvarchar](160) NULL,
	[Stock_Name] [nvarchar](160) NULL,
	[Stock_Status] [nvarchar](160) NULL,
	[Must_QTY] [decimal](23, 10) NULL,
	[Real_QTY] [decimal](23, 10) NULL,
	[Produce_Date] [datetime] NULL,
	[Expiry_Date] [datetime] NULL,
	[LOT] [nvarchar](510) NULL,
	[LOT_Display] [nvarchar](510) NULL,
	[Base_Unit] [nvarchar](160) NULL,
	[Base_Unit_QTY] [decimal](23, 10) NULL,
	[Price] [decimal](23, 10) NULL,
	[TaxPrice] [decimal](23, 10) NULL,
	[Price_Unit] [nvarchar](160) NULL,
	[Price_Unit_QTY] [decimal](23, 10) NULL,
	[Tax_Rate] [decimal](24, 10) NULL,
	[Discount_Rate] [decimal](24, 10) NULL,
	[IsFree] [char](1) NULL,
	[Tax_Amount] [decimal](23, 10) NULL,
	[Discount_Amount] [decimal](23, 10) NULL,
	[Amount] [decimal](23, 10) NULL,
	[Full_Amount] [decimal](23, 10) NULL,
	[Cost_Price] [decimal](23, 10) NULL,
	[Cost_Amount] [decimal](23, 10) NULL,
	[Note] [nvarchar](510) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
	[Sale_Unit] [nvarchar](50) NULL,
	[Sale_Unit_QTY] [decimal](20, 10) NULL,
PRIMARY KEY CLUSTERED 
(
	[ReturnStock_ID] ASC,
	[Sequence_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_ReturnStockEntry] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_ReturnStockEntry] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
