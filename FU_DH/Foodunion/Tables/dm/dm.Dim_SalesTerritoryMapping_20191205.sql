USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_SalesTerritoryMapping_20191205](
	[ID] [int] NOT NULL,
	[Province] [varchar](200) NOT NULL,
	[Province_Short] [varchar](10) NULL,
	[SalesTerritory] [varchar](200) NULL,
	[SalesTerritory_EN] [varchar](200) NULL,
	[Leader] [varchar](200) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](20) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](20) NULL
) ON [PRIMARY]
GO
