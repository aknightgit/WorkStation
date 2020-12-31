USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[Sales_销售区域达成日报](
	[Director] [varchar](100) NULL,
	[Manager] [varchar](100) NULL,
	[负责人] [varchar](100) NULL,
	[负责区域] [varchar](100) NULL,
	[MTDT] [varchar](100) NULL,
	[Sell-in指标] [varchar](100) NULL,
	[MTD Sell-In达成] [varchar](100) NULL,
	[Sell-in Ach%] [varchar](100) NULL,
	[Previous Day Sell-In] [varchar](100) NULL,
	[Previous Day Sell-In delta%] [varchar](100) NULL,
	[Sell-Out指标] [varchar](100) NULL,
	[MTD Sell-Out达成] [varchar](100) NULL,
	[Sell-Out Ach%] [varchar](100) NULL,
	[Previous Day Sell-Out] [varchar](100) NULL,
	[Previous Day Sell-Out delta%] [varchar](100) NULL,
	[Row_Attr] [varchar](200) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [rpt].[Sales_销售区域达成日报] ADD  CONSTRAINT [DF__Sales_销售区__Updat__2137ADC7]  DEFAULT (getdate()) FOR [Update_Time]
GO
