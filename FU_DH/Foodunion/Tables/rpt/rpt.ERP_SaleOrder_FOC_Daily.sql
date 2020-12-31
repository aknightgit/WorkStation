USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[ERP_SaleOrder_FOC_Daily](
	[Datekey] [int] NOT NULL,
	[Channel_ID] [int] NOT NULL,
	[Sale_Dept] [varchar](200) NULL,
	[Channel_Category] [nvarchar](100) NULL,
	[Channel_Name_Display] [nvarchar](100) NULL,
	[Customer_Name] [varchar](200) NOT NULL,
	[FOC_Type] [varchar](100) NULL,
	[Count_as_Sellin] [bit] NULL,
	[SKU_ID] [varchar](100) NULL,
	[Freshness] [varchar](7) NULL,
	[Vol_KG] [decimal](29, 12) NULL
) ON [PRIMARY]
GO
