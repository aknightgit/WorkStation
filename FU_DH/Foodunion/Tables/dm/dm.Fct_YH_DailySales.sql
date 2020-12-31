USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_DailySales](
	[Datekey] [int] NOT NULL,
	[Store_ID] [nvarchar](200) NOT NULL,
	[SKU_ID] [nvarchar](200) NOT NULL,
	[InStock_QTY] [decimal](18, 10) NULL,
	[InStock_Amount] [decimal](18, 10) NULL,
	[Sale_QTY] [decimal](18, 10) NULL,
	[Sale_Amount] [decimal](18, 10) NULL,
	[Promotion_Amount] [decimal](18, 10) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Fct_YH_DailySales] PRIMARY KEY CLUSTERED 
(
	[Datekey] ASC,
	[Store_ID] ASC,
	[SKU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
