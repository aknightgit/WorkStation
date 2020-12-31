USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_SellOut_byChannel_byRegion_20200108](
	[DateKey] [int] NOT NULL,
	[Channel_ID] [int] NOT NULL,
	[Sale_Area] [varchar](50) NOT NULL,
	[Sale_Territory] [varchar](50) NOT NULL,
	[SKU_ID] [varchar](50) NOT NULL,
	[Sale_QTY] [decimal](18, 5) NULL,
	[Sale_AMT] [decimal](18, 5) NULL,
	[Sale_AMT_Krmb] [decimal](18, 5) NULL,
	[Weight_KG] [decimal](18, 5) NULL,
	[Weight_MT] [decimal](18, 5) NULL,
	[Volume_L] [decimal](18, 5) NULL,
	[Create_time] [datetime] NOT NULL,
	[Create_By] [varchar](78) NULL,
	[Update_time] [datetime] NOT NULL,
	[Update_By] [varchar](78) NULL
) ON [PRIMARY]
GO
