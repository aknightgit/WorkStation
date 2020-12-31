USE [Foodunion]
GO
DROP TABLE [dm].[Fct_Order_Item]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Order_Item](
	[Order_Key] [bigint] NOT NULL,
	[Order_MonthKey] [bigint] NOT NULL,
	[Order_DateKey] [bigint] NOT NULL,
	[Order_ID] [varchar](100) NOT NULL,
	[Transaction_ID] [varchar](50) NULL,
	[Sequence_ID] [smallint] NOT NULL,
	[SKU_ID] [varchar](50) NULL,
	[SKU_Name_CN] [nvarchar](100) NULL,
	[SKU_Desc] [nvarchar](100) NULL,
	[SKU_RSP] [decimal](19, 9) NULL,
	[Channel_SKU_ID] [varchar](100) NULL,
	[Brand_ID] [smallint] NULL,
	[Promotion_ID] [smallint] NULL,
	[Quantity] [int] NULL,
	[Unit_Price] [decimal](19, 9) NULL,
	[Total_Amount] [decimal](19, 9) NULL,
	[Discount_Amount] [decimal](19, 9) NULL,
	[Payment_Amount] [decimal](19, 9) NULL,
	[Received_Amount] [decimal](19, 9) NULL,
	[Refund_Amount] [decimal](19, 9) NULL,
	[Refund_ID] [varchar](100) NULL,
	[Refund_Status] [varchar](100) NULL,
	[Status] [varchar](100) NULL,
	[Is_Gift] [bit] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
	[Order_Amount_Split] [decimal](20, 10) NULL,
	[Payment_Amount_Split] [decimal](20, 10) NULL,
	[Refund_Amount_Split] [decimal](20, 10) NULL,
	[Trade_ID] [nvarchar](50) NULL,
	[Express_Code] [nvarchar](50) NULL,
	[Shipment_Status] [nvarchar](50) NULL,
	[Shipment_No] [nvarchar](50) NULL,
	[Order_Type] [nvarchar](50) NULL,
	[Receiver_Address] [nvarchar](200) NULL,
	[Receiver_Province] [nvarchar](50) NULL,
	[Receiver_City] [nvarchar](50) NULL,
	[Receiver_Area] [nvarchar](50) NULL,
	[Warehouse] [nvarchar](50) NULL,
	[Payment_Status] [nvarchar](50) NULL,
	[Remark] [nvarchar](200) NULL,
	[OrderRowCnt] [int] NULL,
	[Buyer_Nick] [varchar](50) NULL,
	[WHS_ID] [varchar](50) NULL,
 CONSTRAINT [PK_Fct_Order_Item] PRIMARY KEY CLUSTERED 
(
	[Order_Key] ASC,
	[Order_DateKey] ASC,
	[Order_ID] ASC,
	[Sequence_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
