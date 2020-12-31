USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[O2O_Inventory_Detail_Expire](
	[SKU] [varchar](100) NULL,
	[名称] [nvarchar](500) NULL,
	[数量] [float] NULL,
	[单位] [varchar](100) NULL,
	[批次号] [varchar](100) NULL,
	[是否残损] [varchar](1) NOT NULL,
	[是否过期] [varchar](1) NOT NULL,
	[KOL] [varchar](100) NULL,
	[报废单提交日期] [date] NULL,
	[报废单] [varchar](100) NOT NULL,
	[报废单数量] [float] NULL,
	[批次号即时库存数量] [float] NULL
) ON [PRIMARY]
GO
