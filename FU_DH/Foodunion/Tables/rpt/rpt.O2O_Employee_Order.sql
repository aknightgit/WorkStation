USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[O2O_Employee_Order](
	[Datekey] [int] NOT NULL,
	[Order_no] [varchar](64) NOT NULL,
	[Order_CreateTime] [datetime] NOT NULL,
	[Order_CloseTime] [datetime] NULL,
	[User_UnionID] [varchar](64) NULL,
	[User_OpenID] [varchar](64) NULL,
	[Employee_ID] [varchar](64) NULL,
	[Employee_Name] [varchar](64) NULL,
	[Fenxiao_EmployeeID] [varchar](64) NULL,
	[Fenxiao_EmployeeName] [varchar](64) NULL,
	[Operator_EmployeeID] [varchar](64) NULL,
	[Operator_EmployeeName] [varchar](64) NULL,
	[Order_Status] [varchar](255) NULL,
	[Pay_Amount] [decimal](18, 2) NULL,
	[Shipping_Type] [varchar](64) NOT NULL,
	[Shipping_Fee] [decimal](18, 2) NULL,
	[Refund_Time] [datetime] NULL,
	[Refund_State] [varchar](64) NOT NULL,
	[Refund_Amount] [decimal](11, 2) NULL,
	[Order_Amount] [decimal](21, 2) NULL,
	[Sales_Commission] [numeric](23, 3) NULL,
	[Shipping_Amount] [decimal](21, 2) NULL,
	[Shipping_Commission] [numeric](24, 4) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
ALTER TABLE [rpt].[O2O_Employee_Order] ADD  CONSTRAINT [DF__O2O_Emplo__Creat__17835B04]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [rpt].[O2O_Employee_Order] ADD  CONSTRAINT [DF__O2O_Emplo__Updat__18777F3D]  DEFAULT (getdate()) FOR [Update_Time]
GO
