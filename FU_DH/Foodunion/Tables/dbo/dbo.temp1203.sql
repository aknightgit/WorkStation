USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp1203](
	[Datekey] [int] NULL,
	[Week_Nature_Str] [varchar](20) NOT NULL,
	[Week_Day_Name] [varchar](9) NOT NULL,
	[Sales_Region] [varchar](50) NULL,
	[Store_Province] [nvarchar](50) NULL,
	[Store_City] [nvarchar](50) NULL,
	[Store_ID] [nvarchar](200) NULL,
	[Store_Code] [varchar](50) NOT NULL,
	[Store_Name] [nvarchar](100) NULL,
	[SKU_ID] [nvarchar](200) NULL,
	[SKU_Name_S] [varchar](200) NULL,
	[Product_Sort] [nvarchar](50) NULL,
	[SellIn_woVAT] [decimal](38, 2) NOT NULL,
	[SellIn_withVAT] [decimal](38, 2) NOT NULL,
	[POS] [decimal](38, 2) NOT NULL
) ON [PRIMARY]
GO
