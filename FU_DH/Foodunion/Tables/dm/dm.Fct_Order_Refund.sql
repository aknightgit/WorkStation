USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Order_Refund](
	[Order_DateKey] [bigint] NOT NULL,
	[Order_Key] [bigint] NOT NULL,
	[Refund_No] [varchar](100) NOT NULL,
	[Transaction_No] [varchar](100) NOT NULL,
	[Refund_CreateTime] [datetime] NULL,
	[Refund_EndTime] [datetime] NULL,
	[Refund_Type] [char](10) NULL,
	[Refund_Reason] [nvarchar](200) NULL,
	[Refund_Status] [nvarchar](100) NULL,
	[Refund_Via] [nvarchar](100) NULL,
	[Is_Return] [bit] NULL,
	[Return_No] [bit] NULL,
	[Return_Shipment_No] [varchar](100) NULL,
	[Logistics_Name] [varchar](100) NULL,
	[Refund_Goods_Amount] [decimal](19, 2) NULL,
	[Refund_Post_Fee] [decimal](19, 2) NULL,
	[Refund_Total_Amount] [decimal](19, 2) NULL,
	[Refund_Discount_Amount] [decimal](19, 2) NULL,
	[Refund_Order_Amount] [decimal](19, 2) NULL,
	[Refund_Payment_Amount] [decimal](19, 2) NULL,
	[Remarks] [nvarchar](1024) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Fct_Order_Refund_840C_E517_9CCF] PRIMARY KEY CLUSTERED 
(
	[Order_DateKey] ASC,
	[Order_Key] ASC,
	[Refund_No] ASC,
	[Transaction_No] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_Order_Refund] ADD  CONSTRAINT [DF__Fct_Order__Creat__2E86BBED]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_Order_Refund] ADD  CONSTRAINT [DF__Fct_Order__Updat__2F7AE026]  DEFAULT (getdate()) FOR [Update_Time]
GO
