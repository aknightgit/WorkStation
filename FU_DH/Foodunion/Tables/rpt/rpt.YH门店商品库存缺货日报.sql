USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[YH门店商品库存缺货日报](
	[SKU_ID] [nvarchar](200) NULL,
	[SKU_Name_CN] [nvarchar](200) NULL,
	[Sales_Area] [nvarchar](200) NULL,
	[Sales or MD] [nvarchar](200) NULL,
	[城市经理] [nvarchar](200) NULL,
	[大区负责人] [nvarchar](200) NULL,
	[Store code] [nvarchar](200) NULL,
	[Store_Name] [nvarchar](200) NULL,
	[Inventory_Qty] [decimal](18, 0) NULL,
	[OOS (stock <=10)] [nvarchar](200) NULL,
	[Region] [nvarchar](200) NULL,
	[MailSent] [nvarchar](200) NULL,
	[Create_Date] [datetime] NULL
) ON [PRIMARY]
GO
