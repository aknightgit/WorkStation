USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_SalesTerritoryMapping](
	[ID] [int] NOT NULL,
	[Province] [varchar](200) NOT NULL,
	[Province_Short] [varchar](10) NULL,
	[Code] [varchar](100) NULL,
	[SalesTerritory] [varchar](200) NULL,
	[SalesTerritory_EN] [varchar](200) NULL,
	[Leader] [varchar](200) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](20) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](20) NULL,
 CONSTRAINT [PK_Dim_SalesTerritoryMapping_3734] PRIMARY KEY CLUSTERED 
(
	[Province] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_SalesTerritoryMapping] ADD  CONSTRAINT [DF__Dim_Sales__Creat__60A82766]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_SalesTerritoryMapping] ADD  CONSTRAINT [DF__Dim_Sales__Updat__619C4B9F]  DEFAULT (getdate()) FOR [Update_Time]
GO
