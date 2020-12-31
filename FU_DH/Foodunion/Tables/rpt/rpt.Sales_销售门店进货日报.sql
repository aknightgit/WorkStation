USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[Sales_销售门店进货日报](
	[销售] [varchar](100) NULL,
	[省份] [varchar](100) NULL,
	[门店区域] [varchar](100) NULL,
	[门店编码] [varchar](100) NULL,
	[门店名称] [varchar](100) NULL,
	[SKU_ID] [varchar](100) NULL,
	[规格] [varchar](100) NULL,
	[产品名称] [varchar](100) NULL,
	[最近3日进货数量] [varchar](100) NULL,
	[最近3日销售数量] [varchar](100) NULL,
	[最近3日销售金额] [varchar](100) NULL,
	[昨日销售数量] [varchar](100) NULL,
	[昨日销售金额] [varchar](100) NULL,
	[Row_Attr] [varchar](200) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [rpt].[Sales_销售门店进货日报] ADD  CONSTRAINT [DF_Sales_销售门店进货日报_Update_Time]  DEFAULT (getdate()) FOR [Update_Time]
GO
