USE [Foodunion]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_InStockEntry] DROP CONSTRAINT [DF__Fct_ERP_S__Updat__7405149D]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_InStockEntry] DROP CONSTRAINT [DF__Fct_ERP_S__Creat__7310F064]
GO
DROP TABLE [dm].[Fct_ERP_Stock_InStockEntry]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Stock_InStockEntry](
	[InStock_ID] [int] NOT NULL,
	[SourceBillNo] [varchar](100) NOT NULL,
	[Sequence_ID] [varchar](100) NOT NULL,
	[SKU_ID] [varchar](100) NOT NULL,
	[Stock_Name] [varchar](100) NULL,
	[Stock_Status] [varchar](100) NULL,
	[Unit] [varchar](100) NULL,
	[Must_QTY] [decimal](18, 9) NULL,
	[Real_QTY] [decimal](18, 9) NULL,
	[Produce_Date] [datetime] NULL,
	[Expiry_Date] [datetime] NULL,
	[LOT] [varchar](100) NULL,
	[LOT_Display] [varchar](100) NULL,
	[Sale_Unit] [nvarchar](50) NULL,
	[Sale_Unit_QTY] [decimal](20, 10) NULL,
	[Base_Unit] [varchar](100) NULL,
	[Base_Unit_QTY] [decimal](18, 9) NULL,
	[Base_Unit_Price] [decimal](18, 9) NULL,
	[Price] [decimal](18, 9) NULL,
	[TaxPrice] [decimal](18, 9) NULL,
	[Price_Unit] [varchar](100) NULL,
	[Price_Unit_QTY] [decimal](18, 9) NULL,
	[Tax_Rate] [decimal](18, 9) NULL,
	[Discount_Rate] [decimal](18, 9) NULL,
	[IsFree] [bit] NULL,
	[Tax_Amount] [decimal](18, 9) NULL,
	[Discount_Amount] [decimal](18, 9) NULL,
	[Amount] [decimal](18, 9) NULL,
	[Full_Amount] [decimal](18, 9) NULL,
	[Cost_Price] [decimal](18, 9) NULL,
	[Cost_Amount] [decimal](18, 9) NULL,
	[Gross_Weight] [decimal](18, 9) NULL,
	[Net_Weight] [decimal](18, 9) NULL,
	[Note] [varchar](200) NULL,
	[Remain_InStock_Base_QTY] [decimal](18, 9) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[InStock_ID] ASC,
	[Sequence_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_InStockEntry] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_InStockEntry] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
