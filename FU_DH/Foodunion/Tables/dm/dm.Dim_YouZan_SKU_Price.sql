USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_YouZan_SKU_Price](
	[Brand] [nvarchar](500) NULL,
	[Requirement to Logistics] [nvarchar](500) NULL,
	[Product Code] [nvarchar](50) NOT NULL,
	[Product Description] [nvarchar](500) NULL,
	[Product Category] [nvarchar](500) NULL,
	[Flavor] [nvarchar](500) NULL,
	[Sales Unit] [nvarchar](500) NULL,
	[Product Package] [nvarchar](500) NULL,
	[Shelf Life] [nvarchar](500) NULL,
	[Case Count] [nvarchar](500) NULL,
	[有赞定价] [float] NULL,
	[RSP] [float] NULL,
	[是否上Youzan] [nvarchar](500) NULL,
	[备注] [nvarchar](500) NULL,
 CONSTRAINT [PK_Dim_YouZan_SKU_Price] PRIMARY KEY CLUSTERED 
(
	[Product Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
