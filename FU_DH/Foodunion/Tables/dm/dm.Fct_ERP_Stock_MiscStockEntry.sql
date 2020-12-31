USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Stock_MiscStockEntry](
	[MiscStock_ID] [int] NOT NULL,
	[Sequence_ID] [int] NOT NULL,
	[SKU_ID] [nvarchar](160) NULL,
	[Stock_Name] [nvarchar](160) NULL,
	[Stock_Status] [nvarchar](160) NULL,
	[Produce_Date] [datetime] NULL,
	[Expiry_Date] [datetime] NULL,
	[LOT] [nvarchar](510) NULL,
	[LOT_Display] [nvarchar](510) NULL,
	[Unit] [nvarchar](160) NULL,
	[QTY] [decimal](23, 10) NULL,
	[Price] [decimal](23, 10) NULL,
	[Note] [nvarchar](510) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[MiscStock_ID] ASC,
	[Sequence_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_MiscStockEntry] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_MiscStockEntry] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
