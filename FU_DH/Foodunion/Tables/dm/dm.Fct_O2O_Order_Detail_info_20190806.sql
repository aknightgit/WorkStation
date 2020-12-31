USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_O2O_Order_Detail_info_20190806](
	[id] [varchar](64) NOT NULL,
	[order_id] [varchar](64) NULL,
	[order_no] [varchar](255) NULL,
	[product_id] [varchar](64) NULL,
	[product_name] [varchar](128) NULL,
	[quantity] [int] NULL,
	[unit_price] [decimal](18, 2) NULL,
	[product_img_url] [varchar](128) NULL,
	[product_url] [varchar](128) NULL,
	[gift] [tinyint] NULL,
	[buyer_messages] [varchar](256) NULL,
	[order_create_time] [datetime] NOT NULL,
	[order_update_time] [datetime] NULL,
	[total_issue] [int] NULL,
	[issue] [int] NULL,
	[sku_id] [varchar](255) NULL,
	[sku_name] [varchar](255) NULL,
	[total_price] [decimal](11, 2) NULL,
	[sku_unique_code] [varchar](255) NULL,
	[weight_g] [decimal](9, 2) NULL,
	[scale] [varchar](64) NULL,
	[flavor] [varchar](64) NULL,
	[subscriptiontype] [varchar](64) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_O2O_Order_Detail_info_20190806] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_O2O_Order_Detail_info_20190806] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
