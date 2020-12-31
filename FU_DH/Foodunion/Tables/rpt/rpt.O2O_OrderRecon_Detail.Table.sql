USE [Foodunion]
GO
DROP TABLE [rpt].[O2O_OrderRecon_Detail]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[O2O_OrderRecon_Detail](
	[入账期间] [varchar](17) NULL,
	[月份] [nvarchar](30) NULL,
	[订单创建时间] [datetime] NULL,
	[交易成功时间] [datetime] NULL,
	[订单号] [varchar](100) NULL,
	[唯一值] [varchar](100) NULL,
	[商品名称] [varchar](128) NULL,
	[商品类型] [varchar](12) NOT NULL,
	[期数] [int] NULL,
	[每次数量] [int] NULL,
	[每次金额] [decimal](18, 2) NULL,
	[期间内配送次数] [int] NULL,
	[期间内配送数量] [int] NULL,
	[入账金额] [decimal](18, 2) NULL,
	[期间内配送金额] [decimal](18, 2) NULL,
	[期间运费] [decimal](9, 2) NULL,
	[礼品卡] [varchar](1) NULL,
	[无SKU的订单] [varchar](100) NULL,
	[运费] [decimal](18, 2) NOT NULL,
	[规格编码] [varchar](64) NULL,
	[商品编码] [nvarchar](4000) NULL,
	[020渠道的进货价] [decimal](9, 2) NULL,
	[RSP*数量] [decimal](9, 2) NULL,
	[折扣] [decimal](19, 2) NULL,
	[发货仓库] [varchar](7) NOT NULL,
	[发货员工] [varchar](100) NULL,
	[商品数量] [int] NULL,
	[商品实际成交金额] [decimal](18, 2) NULL,
	[商品已退款金额] [decimal](11, 2) NOT NULL,
	[收货人/提货人] [varchar](255) NULL,
	[收货人手机号/提货人手机号] [varchar](255) NULL,
	[详细收货地址/提货地址] [varchar](1277) NULL,
	[下单网点] [varchar](100) NULL,
	[商家订单备注] [varchar](512) NULL,
	[商品发货状态] [varchar](6) NOT NULL,
	[商品发货方式] [varchar](64) NULL,
	[商品发货时间] [datetime] NULL,
	[商品退款状态] [varchar](64) NULL,
	[周期购信息] [varchar](200) NULL,
	[订单类型] [varchar](27) NOT NULL,
	[分销员] [varchar](100) NOT NULL,
	[本期首次入账日期] [datetime] NULL,
	[当前累计配送次数] [int] NULL,
	[当前活跃订阅单] [varchar](1) NOT NULL,
	[订阅已过期] [varchar](1) NOT NULL,
	[订阅即将过期] [varchar](1) NOT NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](39) NOT NULL
) ON [PRIMARY]
GO
