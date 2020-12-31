USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[YH门店商品库存缺货日报汇总](
	[SKU_ID] [nvarchar](205) NULL,
	[SKU_Name_CN] [nvarchar](200) NULL,
	[Sales_Area] [nvarchar](200) NULL,
	[Sales or MD] [nvarchar](200) NULL,
	[Sales Manager] [nvarchar](200) NULL,
	[Sales Director] [nvarchar](200) NULL,
	[Store_no] [int] NULL,
	[OOS] [nvarchar](200) NULL,
	[Region] [nvarchar](200) NULL,
	[Row_Attr] [varchar](52) NOT NULL
) ON [PRIMARY]
GO
