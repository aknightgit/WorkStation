USE [Foodunion]
GO
DROP TABLE [dm].[Fct_O2O_Employee_Order_20190731]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_O2O_Employee_Order_20190731](
	[Datekey] [int] NOT NULL,
	[Employee_ID] [varchar](64) NOT NULL,
	[Order_no] [varchar](64) NULL,
	[Order_Create_time] [datetime] NULL,
	[User_OpenID] [varchar](64) NOT NULL,
	[Employee_name] [varchar](64) NULL,
	[fenxiao_employee_id] [varchar](64) NULL,
	[fenxiao_name] [varchar](64) NULL,
	[operator_employee_id] [varchar](64) NULL,
	[operator_name] [varchar](64) NULL,
	[order_status_str] [varchar](255) NULL,
	[pay_amount] [decimal](18, 2) NULL,
	[shipping_type] [varchar](8) NOT NULL,
	[shipping_fee] [decimal](18, 2) NULL,
	[refund_time] [datetime] NULL,
	[refund_state] [varchar](8) NOT NULL,
	[refund_amount] [decimal](11, 2) NULL,
	[order_amount] [decimal](21, 2) NULL,
	[sales_commssion] [numeric](23, 3) NULL,
	[shipping_amount] [decimal](21, 2) NULL,
	[shipping_commssion] [numeric](24, 4) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
