USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[Sales_YH门店商品库存OOS明细60天](
	[Datekey] [bigint] NOT NULL,
	[Date] [datetime] NOT NULL,
	[Region] [varchar](200) NULL,
	[Region_Director] [varchar](200) NULL,
	[Store_Province] [nvarchar](50) NULL,
	[Store_ID] [varchar](50) NOT NULL,
	[Account_Store_Code] [varchar](50) NOT NULL,
	[Store_Name] [nvarchar](100) NULL,
	[SKU_ID] [nvarchar](7) NULL,
	[SKU_Name] [varchar](200) NOT NULL,
	[SKU_Name_CN] [nvarchar](200) NOT NULL,
	[Flag] [varchar](12) NOT NULL,
	[Inventory_QTY] [int] NOT NULL,
	[Sales_Qty] [int] NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](100) NULL
) ON [PRIMARY]
GO
