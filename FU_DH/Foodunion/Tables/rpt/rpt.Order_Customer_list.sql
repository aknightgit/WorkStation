USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[Order_Customer_list](
	[订单月份] [bigint] NULL,
	[订单日期] [datetime] NULL,
	[周] [tinyint] NOT NULL,
	[订单号] [nvarchar](200) NULL,
	[订单渠道] [nvarchar](100) NULL,
	[渠道ID] [int] NOT NULL,
	[渠道简称] [nvarchar](100) NULL,
	[订单创建时间] [datetime] NULL,
	[订单付款时间] [datetime] NULL,
	[订单关闭时间] [datetime] NULL,
	[付款方式] [nvarchar](255) NULL,
	[订单状态] [nvarchar](255) NULL,
	[订单金额] [decimal](38, 5) NULL,
	[折扣金额] [decimal](38, 5) NULL,
	[付款金额] [decimal](38, 5) NULL,
	[退款金额] [decimal](11, 2) NULL,
	[买家昵称] [nvarchar](255) NULL,
	[买家手机号] [nvarchar](255) NULL,
	[wx_openid] [varchar](255) NULL,
	[收货人姓名] [nvarchar](255) NULL,
	[收货人手机号] [nvarchar](255) NULL,
	[省份] [nvarchar](255) NULL,
	[城市] [nvarchar](255) NULL,
	[区域] [nvarchar](255) NULL,
	[收货地址] [nvarchar](512) NULL,
	[客户ID] [nvarchar](255) NULL,
	[新客户] [int] NOT NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](255) NULL
) ON [PRIMARY]
GO
ALTER TABLE [rpt].[Order_Customer_list] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
