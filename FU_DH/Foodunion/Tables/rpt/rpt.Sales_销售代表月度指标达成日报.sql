USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[Sales_销售代表月度指标达成日报](
	[Region] [varchar](100) NULL,
	[Director] [varchar](100) NULL,
	[Manager] [varchar](100) NULL,
	[Manager_Display] [varchar](100) NULL,
	[RN] [smallint] NULL,
	[SalesPerson] [varchar](100) NULL,
	[进货目标] [varchar](100) NULL,
	[进货实际] [varchar](100) NULL,
	[进货达成%] [varchar](100) NULL,
	[POS目标] [varchar](100) NULL,
	[POS实际] [varchar](100) NULL,
	[POS达成%] [varchar](100) NULL,
	[常温目标] [varchar](100) NULL,
	[常温实际] [varchar](100) NULL,
	[常温达成%] [varchar](100) NULL,
	[低温目标] [varchar](100) NULL,
	[低温实际] [varchar](100) NULL,
	[低温达成%] [varchar](100) NULL,
	[常温SKU数目标] [varchar](100) NULL,
	[常温SKU数实际] [varchar](100) NULL,
	[常温SKU数达成%] [varchar](100) NULL,
	[低温SKU数目标] [varchar](100) NULL,
	[低温SKU数实际] [varchar](100) NULL,
	[低温SKU数达成%] [varchar](100) NULL,
	[Row_Attr] [varchar](200) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [rpt].[Sales_销售代表月度指标达成日报] ADD  CONSTRAINT [DF_Sales_销售代表月度指标达成日报]  DEFAULT (getdate()) FOR [Update_Time]
GO
