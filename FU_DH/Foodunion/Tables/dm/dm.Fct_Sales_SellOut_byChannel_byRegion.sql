USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_SellOut_byChannel_byRegion](
	[DateKey] [int] NOT NULL,
	[Channel_ID] [int] NOT NULL,
	[Region_ID] [int] NULL,
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
	[Update_By] [varchar](78) NULL,
 CONSTRAINT [PK__Fct_Sale__44D8075BEFFE9158_D08C] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC,
	[Channel_ID] ASC,
	[Sale_Area] ASC,
	[Sale_Territory] ASC,
	[SKU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_Sales_SellOut_byChannel_byRegion] ADD  CONSTRAINT [DF__Fct_Sales__Creat__467E410F]  DEFAULT (getdate()) FOR [Create_time]
GO
ALTER TABLE [dm].[Fct_Sales_SellOut_byChannel_byRegion] ADD  CONSTRAINT [DF__Fct_Sales__Updat__47726548]  DEFAULT (getdate()) FOR [Update_time]
GO
