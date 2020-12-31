USE [Foodunion]
GO
ALTER TABLE [dm].[Fct_Order_Shipment] DROP CONSTRAINT [DF__Fct_Order__Updat__6BEEF189]
GO
ALTER TABLE [dm].[Fct_Order_Shipment] DROP CONSTRAINT [DF__Fct_Order__Creat__6AFACD50]
GO
DROP TABLE [dm].[Fct_Order_Shipment]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Order_Shipment](
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
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Fct_Order_Shipment2] PRIMARY KEY CLUSTERED 
(
	[Order_ID] ASC,
	[Shipment_No] ASC,
	[SKU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_Order_Shipment] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_Order_Shipment] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
