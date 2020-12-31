USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Order_Payment](
	[Order_DateKey] [bigint] NOT NULL,
	[Order_Key] [bigint] NOT NULL,
	[Payment_ID] [varchar](100) NOT NULL,
	[SeqID] [smallint] NOT NULL,
	[Payment_Type] [nvarchar](100) NULL,
	[Payment_Method] [nvarchar](100) NULL,
	[Payment_Status] [nvarchar](100) NULL,
	[Payment_Platform] [nvarchar](100) NULL,
	[Payment_AccountID] [nvarchar](100) NULL,
	[Payment_Time] [datetime] NULL,
	[Received_Time] [datetime] NULL,
	[Goods_Amount] [decimal](19, 2) NULL,
	[Post_Fee] [decimal](19, 2) NULL,
	[Adjust_Fee] [decimal](19, 2) NULL,
	[Total_Amount] [decimal](19, 2) NULL,
	[Discount_Amount] [decimal](19, 2) NULL,
	[Order_Amount] [decimal](19, 2) NULL,
	[Payment_Amount] [decimal](19, 2) NULL,
	[Received_Amount] [decimal](19, 2) NULL,
	[Point_Awarded] [decimal](19, 2) NULL,
	[Point_Fee] [decimal](19, 2) NULL,
	[Invoice_ID] [varchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Fct_Order_Payment] PRIMARY KEY CLUSTERED 
(
	[Order_DateKey] ASC,
	[Order_Key] ASC,
	[Payment_ID] ASC,
	[SeqID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_Order_Payment] ADD  CONSTRAINT [df_Fct_Order_Payment_SeqID]  DEFAULT ((1)) FOR [SeqID]
GO
ALTER TABLE [dm].[Fct_Order_Payment] ADD  CONSTRAINT [df_Fct_Order_Payment_Create_Time]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_Order_Payment] ADD  CONSTRAINT [df_Fct_Order_Payment_Update_Time]  DEFAULT (getdate()) FOR [Update_Time]
GO
