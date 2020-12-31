USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_Product_DailyData](
	[DateKey] [bigint] NOT NULL,
	[SKU_ID] [nvarchar](50) NOT NULL,
	[SKU_Code] [nvarchar](50) NOT NULL,
	[SKU_Name] [nvarchar](500) NULL,
	[Brand] [nvarchar](500) NULL,
	[Share_of_diary] [float] NULL,
	[RSP] [float] NULL,
	[On_sale_stores] [float] NULL,
	[GMV] [float] NULL,
	[Discount_Value] [float] NULL,
	[Net_sales_revenue] [float] NULL,
	[Consumer_numbers] [float] NULL,
	[Sales_numbers] [float] NULL,
	[GMV_per_store] [float] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_Product_DailyData] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC,
	[SKU_ID] ASC,
	[SKU_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
