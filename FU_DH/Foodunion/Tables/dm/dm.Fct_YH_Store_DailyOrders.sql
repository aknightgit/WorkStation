USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Store_DailyOrders](
	[OrderID] [nvarchar](20) NOT NULL,
	[SeqID] [nvarchar](20) NOT NULL,
	[Purchase_Datekey] [nvarchar](20) NOT NULL,
	[Purchase_QTY] [int] NULL,
	[PO_QTY] [int] NULL,
	[Apply_Datekey] [nvarchar](100) NULL,
	[Approve_QTY] [int] NULL,
	[Receipt_Datekey] [nvarchar](20) NOT NULL,
	[Receipt_QTY] [int] NULL,
	[Store_ID] [nvarchar](100) NULL,
	[Store_Name] [nvarchar](100) NULL,
	[SKU_ID] [nvarchar](100) NULL,
	[Goods_Name] [nvarchar](200) NULL,
	[Shipment_Type] [nvarchar](100) NULL,
	[Scale] [nvarchar](100) NULL,
	[Unit] [nvarchar](100) NULL,
	[EDIUpdateTime] [nvarchar](20) NOT NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_YH_Store_DailyOrders] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC,
	[SeqID] ASC,
	[Purchase_Datekey] ASC,
	[Receipt_Datekey] ASC,
	[EDIUpdateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
