USE [Foodunion]
GO
DROP TABLE [dm].[Fct_O2O_Order_Base_info_20190925]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_O2O_Order_Base_info_20190925](
	[Datekey] [int] NOT NULL,
	[Order_ID] [varchar](64) NOT NULL,
	[Order_No] [varchar](64) NULL,
	[Order_Source] [varchar](64) NULL,
	[Order_Type] [varchar](64) NULL,
	[Fan_id] [varchar](64) NULL,
	[KOL] [varchar](64) NULL,
	[Fans_Nickname] [varchar](255) NULL,
	[Open_id] [varchar](255) NULL,
	[Fans_Orders_Cnt] [int] NULL,
	[Union_id] [varchar](64) NULL,
	[is_cycle] [tinyint] NULL,
	[Order_Status] [varchar](255) NULL,
	[Order_Status_Str] [varchar](255) NULL,
	[Pay_Status] [varchar](64) NULL,
	[Pay_Type_Str] [varchar](255) NULL,
	[Pay_Type] [varchar](64) NULL,
	[Order_Amount] [decimal](18, 2) NULL,
	[Shipping_Amount] [decimal](18, 2) NULL,
	[Pay_Amount] [decimal](18, 2) NULL,
	[Refund_Amount] [decimal](11, 2) NULL,
	[Order_Create_Time] [datetime] NULL,
	[Order_Close_Time] [datetime] NULL,
	[Expired_Time] [datetime] NULL,
	[Pay_Time] [datetime] NULL,
	[Refund_Time] [datetime] NULL,
	[Refund_State] [varchar](64) NULL,
	[Close_Type] [varchar](64) NULL,
	[Express_Type] [varchar](64) NULL,
	[Consign_Time] [datetime] NULL,
	[Offline_id] [varchar](100) NULL,
	[Consign_Store] [varchar](100) NULL,
	[Buyer_Mobile] [varchar](255) NULL,
	[Receiver_Name] [varchar](255) NULL,
	[Receiver_Mobile] [varchar](255) NULL,
	[Delivery_Province] [varchar](255) NULL,
	[Delivery_City] [varchar](255) NULL,
	[Delivery_District] [varchar](255) NULL,
	[Delivery_Address] [varchar](512) NULL,
	[Fenxiao_Employee_id] [varchar](64) NULL,
	[Fenxiao_Mobile] [varchar](64) NULL,
	[Operator_Employee_id] [varchar](64) NULL,
	[Remark] [varchar](512) NULL,
	[is_deleted] [tinyint] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](100) NOT NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](100) NOT NULL
) ON [PRIMARY]
GO
