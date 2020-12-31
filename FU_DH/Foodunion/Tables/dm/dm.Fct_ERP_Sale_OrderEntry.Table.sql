USE [Foodunion]
GO
ALTER TABLE [dm].[Fct_ERP_Sale_OrderEntry] DROP CONSTRAINT [DF__Fct_ERP_S__Updat__448B0BA5]
GO
ALTER TABLE [dm].[Fct_ERP_Sale_OrderEntry] DROP CONSTRAINT [DF__Fct_ERP_S__Creat__4396E76C]
GO
DROP TABLE [dm].[Fct_ERP_Sale_OrderEntry]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Sale_OrderEntry](
	[Order_Entry_ID] [varchar](100) NOT NULL,
	[Sale_Order_ID] [varchar](100) NOT NULL,
	[Sequence_ID] [int] NULL,
	[SKU_ID] [varchar](100) NULL,
	[Unit] [varchar](100) NULL,
	[QTY] [decimal](18, 9) NULL,
	[Sale_Unit] [varchar](100) NULL,
	[Sale_Unit_QTY] [decimal](18, 9) NULL,
	[Base_Unit] [varchar](100) NULL,
	[Base_Unit_QTY] [decimal](18, 9) NULL,
	[Price_Unit] [varchar](100) NULL,
	[Price] [decimal](18, 9) NULL,
	[Tax_Rate] [decimal](18, 9) NULL,
	[Tax_Price] [decimal](18, 9) NULL,
	[Discount_Rate] [decimal](18, 9) NULL,
	[Amount] [decimal](18, 9) NULL,
	[Tax_Amount] [decimal](18, 9) NULL,
	[Full_Amount] [decimal](18, 9) NULL,
	[Discount_Amount] [decimal](18, 9) NULL,
	[IsFree] [smallint] NULL,
	[Stock_Unit] [varchar](100) NULL,
	[Stock_QTY] [decimal](18, 9) NULL,
	[MPRClose_Status] [varchar](100) NULL,
	[Terminate_Status] [varchar](100) NULL,
	[Lock_QTY] [decimal](18, 9) NULL,
	[Lock_Flag] [varchar](10) NULL,
	[Plan_Delivery_Date] [datetime] NULL,
	[LOT] [nvarchar](50) NULL,
	[Produce_Date] [date] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Order_Entry_ID] ASC,
	[Sale_Order_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Sale_OrderEntry] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Sale_OrderEntry] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
