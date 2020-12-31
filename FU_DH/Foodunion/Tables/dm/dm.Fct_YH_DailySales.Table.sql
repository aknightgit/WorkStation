USE [Foodunion]
GO
ALTER TABLE [dm].[Fct_YH_DailySales] DROP CONSTRAINT [DF__Fct_YH_Da__Updat__2BF46805]
GO
ALTER TABLE [dm].[Fct_YH_DailySales] DROP CONSTRAINT [DF__Fct_YH_Da__Creat__2B0043CC]
GO
DROP TABLE [dm].[Fct_YH_DailySales]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_DailySales](
	[Datekey] [int] NOT NULL,
	[Store_ID] [nvarchar](200) NULL,
	[SKU_ID] [nvarchar](200) NULL,
	[InStock_QTY] [decimal](18, 10) NULL,
	[InStock_Amount] [decimal](18, 10) NULL,
	[Sale_QTY] [decimal](18, 10) NULL,
	[Sale_Amount] [decimal](18, 10) NULL,
	[Promotion_Amount] [decimal](18, 10) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_YH_DailySales] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_YH_DailySales] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
