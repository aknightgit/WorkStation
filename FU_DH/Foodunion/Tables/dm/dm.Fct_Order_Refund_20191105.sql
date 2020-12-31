USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Order_Refund_20191105](
	[Order_MonthKey] [bigint] NOT NULL,
	[Order_DateKey] [bigint] NOT NULL,
	[Refund_ID] [bigint] NOT NULL,
	[Order_ID] [varchar](100) NOT NULL,
	[Transaction_ID] [varchar](100) NOT NULL,
	[Platform_Name_CN] [varchar](100) NULL,
	[SKU_ID] [varchar](100) NULL,
	[Refund_Quantity] [int] NULL,
	[Refund_CreateTime] [datetime] NULL,
	[Refund_EndTime] [datetime] NULL,
	[Refund_Reason] [nvarchar](200) NULL,
	[Refund_Status] [nvarchar](100) NULL,
	[Refund_Via] [nvarchar](100) NULL,
	[Refund_PayNo] [nvarchar](100) NULL,
	[Refund_Amount] [decimal](19, 2) NULL,
	[Refund_Point] [decimal](19, 2) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
