USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_Product_Scrap](
	[DateKey] [bigint] NOT NULL,
	[Scrap_Date] [date] NOT NULL,
	[SKU_ID] [nvarchar](50) NOT NULL,
	[SKU_Code] [nvarchar](50) NOT NULL,
	[SKU_Name] [nvarchar](500) NULL,
	[QTY] [int] NULL,
	[Produce_Date] [date] NOT NULL,
	[Scrap_Reason] [nvarchar](50) NOT NULL,
	[Source] [nvarchar](50) NULL,
	[Store_ID] [nvarchar](50) NULL,
	[Store_Name] [nvarchar](200) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
