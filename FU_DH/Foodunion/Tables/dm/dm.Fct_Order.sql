USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Order](
	[Order_Key] [bigint] NOT NULL,
	[Order_MonthKey] [bigint] NOT NULL,
	[Order_DateKey] [bigint] NOT NULL,
	[Order_ID] [varchar](100) NOT NULL,
	[Order_No] [nvarchar](500) NULL,
	[Trans_No] [nvarchar](500) NULL,
	[Order_Type_ID] [smallint] NULL,
	[Super_ID] [bigint] NOT NULL,
	[Member_ID] [bigint] NULL,
	[Channel_ID] [smallint] NULL,
	[Platform_ID] [smallint] NULL,
	[Promotion_ID] [smallint] NULL,
	[Order_CreateTime] [datetime] NULL,
	[Order_PayTime] [datetime] NULL,
	[Order_CloseTime] [datetime] NULL,
	[Promise_Delivery_Time] [datetime] NULL,
	[Order_Source] [nvarchar](500) NULL,
	[Order_Status] [nvarchar](500) NULL,
	[Is_Cancelled] [bit] NULL,
	[Is_Split] [bit] NULL,
	[Is_Refund] [bit] NULL,
	[Total_Amount] [decimal](19, 2) NULL,
	[Discount_Amount] [decimal](19, 2) NULL,
	[Payment_Amount] [decimal](19, 2) NULL,
	[Refund_Amount] [decimal](19, 2) NULL,
	[Received_Amount] [decimal](19, 2) NULL,
	[Item_Count] [smallint] NULL,
	[Total_Quantity] [int] NULL,
	[Baoma_ID] [nvarchar](500) NULL,
	[Buyer_Nick] [nvarchar](500) NULL,
	[Buyer_Mobile] [varchar](20) NULL,
	[Receiver_Name] [nvarchar](500) NULL,
	[Receiver_Mobile] [nvarchar](500) NULL,
	[Receiver_Province] [nvarchar](500) NULL,
	[Receiver_City] [nvarchar](500) NULL,
	[Receiver_Area] [nvarchar](500) NULL,
	[Receiver_Address] [nvarchar](500) NULL,
	[Receiver_Postcode] [nvarchar](500) NULL,
	[Copy_From] [nvarchar](500) NULL,
	[Split_From] [nvarchar](500) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Fct_Order2_B2BD_08DC_6756_3940_CBD2_D7B1_4508_88D4_834F_C357] PRIMARY KEY CLUSTERED 
(
	[Order_Key] ASC,
	[Order_DateKey] ASC,
	[Order_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [u_fct_Order_F89C_F2B9_9A0E_8F2D_F878_8C38_AF2E_CBFB_3D0D_64C9] ON [dm].[Fct_Order]
(
	[Order_DateKey] ASC,
	[Order_ID] ASC,
	[Channel_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_Order] ADD  CONSTRAINT [DF__Fct_Order__Creat__3FE65219]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_Order] ADD  CONSTRAINT [DF__Fct_Order__Updat__40DA7652]  DEFAULT (getdate()) FOR [Update_Time]
GO
