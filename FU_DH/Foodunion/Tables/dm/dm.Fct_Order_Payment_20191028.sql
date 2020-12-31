USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Order_Payment_20191028](
	[Order_DateKey] [bigint] NOT NULL,
	[Payment_ID] [varchar](100) NOT NULL,
	[Order_ID] [varchar](100) NOT NULL,
	[Payment_Type] [nvarchar](100) NULL,
	[Payment_Time] [datetime] NULL,
	[Received_Time] [datetime] NULL,
	[Payment_Status] [nvarchar](100) NULL,
	[Payment_Platform] [nvarchar](100) NULL,
	[Payment_Account_ID] [nvarchar](100) NULL,
	[Total_Amount] [decimal](19, 2) NULL,
	[Adjust_Fee] [decimal](19, 2) NULL,
	[Post_Fee] [decimal](19, 2) NULL,
	[Discount_Amount] [decimal](19, 2) NULL,
	[Confirm_Amount] [decimal](19, 2) NULL,
	[Payment_Amount] [decimal](19, 2) NULL,
	[Received_Amount] [decimal](19, 2) NULL,
	[Point_Awarded] [decimal](19, 2) NULL,
	[Point_Fee] [decimal](19, 2) NULL,
	[Invoice_ID] [varchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
