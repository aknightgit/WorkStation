USE [Foodunion]
GO
ALTER TABLE [dm].[Fct_Order_Refund] DROP CONSTRAINT [DF__Fct_Order__Updat__35C7EB02]
GO
ALTER TABLE [dm].[Fct_Order_Refund] DROP CONSTRAINT [DF__Fct_Order__Creat__34D3C6C9]
GO
DROP TABLE [dm].[Fct_Order_Refund]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Order_Refund](
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
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Fct_Order_Refund] PRIMARY KEY CLUSTERED 
(
	[Order_DateKey] ASC,
	[Order_ID] ASC,
	[Refund_ID] ASC,
	[Transaction_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_Order_Refund] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_Order_Refund] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
