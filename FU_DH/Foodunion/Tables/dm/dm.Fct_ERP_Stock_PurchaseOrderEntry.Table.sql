USE [Foodunion]
GO
DROP TABLE [dm].[Fct_ERP_Stock_PurchaseOrderEntry]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Stock_PurchaseOrderEntry](
	[POOrder_ID] [varchar](100) NOT NULL,
	[Sequence_ID] [smallint] NOT NULL,
	[SourceBillNo] [varchar](100) NULL,
	[SKU_ID] [varchar](100) NULL,
	[Unit] [varchar](100) NULL,
	[QTY] [decimal](18, 9) NULL,
	[Stock_Unit] [varchar](100) NULL,
	[Stock_QTY] [decimal](18, 9) NULL,
	[Note] [varchar](512) NULL,
	[Is_Stock] [varchar](100) NULL,
	[Delivery_Date] [date] NULL,
	[Price_Unit] [varchar](100) NULL,
	[Price_QTY] [decimal](18, 9) NULL,
	[Price] [decimal](18, 9) NULL,
	[Tax_Rate] [decimal](18, 9) NULL,
	[Tax_Price] [decimal](18, 9) NULL,
	[Amount] [decimal](18, 9) NULL,
	[Tax_Amount] [decimal](18, 9) NULL,
	[All_Amount] [decimal](18, 9) NULL,
	[Discount_Amount] [decimal](18, 9) NULL,
	[Rec_QTY] [decimal](18, 9) NULL,
	[Stk_QTY] [decimal](18, 9) NULL,
	[Remain_RecQTY] [decimal](18, 9) NULL,
	[Remain_StkQTY] [decimal](18, 9) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[POOrder_ID] ASC,
	[Sequence_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
