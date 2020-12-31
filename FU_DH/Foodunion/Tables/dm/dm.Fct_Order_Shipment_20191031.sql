USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Order_Shipment_20191031](
	[Order_DateKey] [bigint] NOT NULL,
	[Order_ID] [nvarchar](100) NOT NULL,
	[Shipment_No] [nvarchar](100) NOT NULL,
	[Is_Split] [bit] NULL,
	[Sequence_ID] [smallint] NOT NULL,
	[SKU_ID] [nvarchar](100) NOT NULL,
	[Warehouse] [nvarchar](100) NULL,
	[Shipment_Type] [nvarchar](50) NULL,
	[Logistics_Code] [nvarchar](20) NULL,
	[Logistics_Name] [nvarchar](100) NULL,
	[Express_Code] [nvarchar](100) NULL,
	[Shipment_Status] [nvarchar](100) NULL,
	[Shipment_CreateTime] [datetime] NULL,
	[Shipment_ReceiveTime] [datetime] NULL,
	[Post_Fee] [decimal](19, 2) NULL,
	[Buyer_Nick] [nvarchar](100) NULL,
	[Receiver_Name] [nvarchar](100) NULL,
	[Receiver_Province] [nvarchar](100) NULL,
	[Receiver_City] [nvarchar](100) NULL,
	[Receiver_Area] [nvarchar](100) NULL,
	[Receiver_Address] [nvarchar](100) NULL,
	[Receiver_PostCode] [varchar](100) NULL,
	[Receiver_Mobile] [varchar](100) NULL,
	[Receiver_Email] [varchar](100) NULL,
	[Weight] [decimal](19, 2) NULL,
	[NeedInvoice] [bit] NULL,
	[SourceDesc] [varchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
