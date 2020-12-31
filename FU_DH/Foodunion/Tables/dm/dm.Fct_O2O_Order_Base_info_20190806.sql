USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_O2O_Order_Base_info_20190806](
	[order_id] [varchar](64) NOT NULL,
	[member_id] [varchar](64) NULL,
	[order_no] [varchar](64) NULL,
	[deleted] [tinyint] NULL,
	[pay_status] [tinyint] NULL,
	[pay_type_str] [varchar](255) NULL,
	[order_discount_fee] [decimal](11, 2) NULL,
	[pay_type] [int] NULL,
	[type] [int] NULL,
	[amount] [decimal](18, 2) NULL,
	[pre_amount] [decimal](18, 2) NULL,
	[shipping_amount] [decimal](18, 2) NULL,
	[shipping_type] [tinyint] NULL,
	[shipping_no] [varchar](64) NULL,
	[shipping_time] [datetime] NULL,
	[receive_time] [datetime] NULL,
	[shipping_comp_name] [varchar](64) NULL,
	[pay_amount] [decimal](18, 2) NULL,
	[pay_time] [datetime] NULL,
	[order_status] [varchar](255) NULL,
	[cycle] [tinyint] NULL,
	[expired_time] [datetime] NULL,
	[refund_time] [datetime] NULL,
	[refund_state] [int] NULL,
	[refund_amount] [decimal](11, 2) NULL,
	[order_create_time] [datetime] NULL,
	[order_status_str] [varchar](255) NULL,
	[close_type] [int] NULL,
	[express_type] [int] NULL,
	[consign_time] [datetime] NULL,
	[offline_id] [int] NULL,
	[buy_id] [int] NULL,
	[buy_phone] [varchar](255) NULL,
	[fans_id] [varchar](255) NULL,
	[fans_nickname] [varchar](255) NULL,
	[outer_user_id] [varchar](255) NULL,
	[receiver_name] [varchar](255) NULL,
	[receiver_tel] [varchar](255) NULL,
	[delivery_province] [varchar](255) NULL,
	[delivery_city] [varchar](255) NULL,
	[delivery_district] [varchar](255) NULL,
	[delivery_address] [varchar](255) NULL,
	[source] [int] NULL,
	[brand_id] [varchar](64) NULL,
	[youzan_config_id] [varchar](64) NULL,
	[employee_id] [varchar](64) NULL,
	[member_contact_id] [varchar](64) NULL,
	[wx_fans_info_id] [varchar](64) NULL,
	[fenxiao] [tinyint] NULL,
	[fenxiao_mobile] [varchar](64) NULL,
	[fenxiao_employee_id] [varchar](64) NULL,
	[operaton_mobile] [varchar](64) NULL,
	[operator_name] [varchar](255) NULL,
	[operator_employee_id] [varchar](64) NULL,
	[wx_union_id] [varchar](64) NULL,
	[remark] [varchar](255) NULL,
	[datekey] [varchar](78) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_O2O_Order_Base_info_20190806] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_O2O_Order_Base_info_20190806] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
