USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[Fxxk_DailyStoreSales_Export_Audit](
	[ID] [varchar](100) NOT NULL,
	[Datekey] [bigint] NOT NULL,
	[TS] [varchar](20) NOT NULL,
	[Store_ID] [varchar](20) NOT NULL,
	[Store_Code] [varchar](20) NULL,
	[Fxxk_ID] [varchar](255) NULL,
	[SellIn] [decimal](9, 2) NULL,
	[SellOut] [decimal](9, 2) NULL,
	[IsExported] [bit] NULL,
	[Update_at] [datetime] NULL,
	[Update_by] [varchar](100) NULL
) ON [PRIMARY]
GO
