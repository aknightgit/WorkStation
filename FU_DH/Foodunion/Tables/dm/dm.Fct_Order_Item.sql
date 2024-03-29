﻿USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Order_Item](
	[Order_DateKey] [bigint] NOT NULL,
	[Order_Key] [bigint] NOT NULL,
	[Order_Cannelled] [bit] NULL,
	[Transaction_No] [varchar](50) NOT NULL,
	[SeqID] [smallint] NOT NULL,
	[SKU_ID] [varchar](50) NULL,
	[Bar_Code] [varchar](100) NULL,
	[SKU_Name_CN] [nvarchar](100) NULL,
	[SKU_Desc] [nvarchar](100) NULL,
	[SKU_RSP] [decimal](19, 9) NULL,
	[Channel_SKU_ID] [varchar](100) NULL,
	[Shipment_No] [varchar](100) NULL,
	[Promotion_ID] [smallint] NULL,
	[Status] [varchar](100) NULL,
	[Quantity] [int] NULL,
	[Unit_Price] [decimal](19, 2) NULL,
	[Goods_Amount_Split] [decimal](19, 2) NULL,
	[Post_Fee_Split] [decimal](19, 2) NULL,
	[Adjust_Fee_Split] [decimal](19, 2) NULL,
	[Total_Amount_Split] [decimal](19, 2) NULL,
	[Discount_Amount_Split] [decimal](19, 2) NULL,
	[Order_Amount_Split] [decimal](19, 2) NULL,
	[Payment_Amount_Split] [decimal](19, 2) NULL,
	[Refund_Amount_Split] [decimal](19, 2) NULL,
	[Refund_No] [varchar](100) NULL,
	[Refund_Status] [varchar](100) NULL,
	[Return_Qty] [int] NULL,
	[Is_Gift] [bit] NULL,
	[Express_Code] [nvarchar](50) NULL,
	[Warehouse] [nvarchar](50) NULL,
	[Remark] [nvarchar](200) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Fct_Order_Item] PRIMARY KEY CLUSTERED 
(
	[Order_DateKey] ASC,
	[Order_Key] ASC,
	[Transaction_No] ASC,
	[SeqID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
