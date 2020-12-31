USE [Foodunion]
GO
DROP TABLE [dm].[Fct_Youzan_Revenue_Details]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Youzan_Revenue_Details](
	[Revenue_Type] [varchar](200) NULL,
	[Revenue_Name] [varchar](200) NULL,
	[Order_No] [varchar](200) NULL,
	[Serial_No] [varchar](200) NULL,
	[Linked_Order_No] [varchar](200) NULL,
	[Source_of_transaction] [varchar](200) NULL,
	[Accounting_body] [varchar](200) NULL,
	[Accounting] [varchar](200) NULL,
	[Income_Amount] [decimal](18, 6) NULL,
	[Pay_Amount] [decimal](18, 6) NULL,
	[Balance_Amount] [decimal](18, 6) NULL,
	[Payment_method] [varchar](200) NULL,
	[Counterparty] [varchar](200) NULL,
	[Channel] [varchar](200) NULL,
	[Order_Create_Time] [datetime] NULL,
	[Revenue_Time] [datetime] NULL,
	[Operator] [varchar](200) NULL,
	[Additional_Info] [varchar](200) NULL,
	[Remark] [varchar](200) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
