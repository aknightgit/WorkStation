USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Order_20191118](
	[Order_Key] [bigint] NOT NULL,
	[Order_MonthKey] [bigint] NOT NULL,
	[Order_DateKey] [bigint] NOT NULL,
	[Order_ID] [varchar](100) NOT NULL,
	[Order_Type_ID] [smallint] NULL,
	[Super_ID] [bigint] NOT NULL,
	[Member_ID] [bigint] NULL,
	[Channel_ID] [smallint] NULL,
	[Platform_ID] [smallint] NULL,
	[Promotion_ID] [smallint] NULL,
	[Order_CreateTime] [datetime] NULL,
	[Order_EndTime] [datetime] NULL,
	[Promise_Delivery_Time] [datetime] NULL,
	[Order_Source] [nvarchar](100) NULL,
	[Order_Status] [nvarchar](100) NULL,
	[Is_Cancelled] [bit] NULL,
	[Total_Amount] [decimal](19, 2) NULL,
	[Discount_Amount] [decimal](19, 2) NULL,
	[Payment_Amount] [decimal](19, 2) NULL,
	[Received_Amount] [decimal](19, 2) NULL,
	[Item_Count] [smallint] NULL,
	[Total_Quantity] [int] NULL,
	[Baoma_ID] [varchar](100) NULL,
	[Buyer_Nick] [varchar](200) NULL,
	[Receiver_Name] [varchar](200) NULL,
	[Receiver_Mobile] [varchar](200) NULL,
	[Receiver_Province] [varchar](200) NULL,
	[Receiver_City] [varchar](200) NULL,
	[Receiver_Area] [varchar](200) NULL,
	[Receiver_Address] [varchar](500) NULL,
	[Receiver_Postcode] [varchar](200) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
	[Order_CloseTime] [datetime] NULL,
 CONSTRAINT [PK_Fct_Order] PRIMARY KEY CLUSTERED 
(
	[Order_Key] ASC,
	[Order_DateKey] ASC,
	[Order_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Order_20191118] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Order_20191118] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
