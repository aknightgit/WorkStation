USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_Store_List](
	[DateKey] [bigint] NOT NULL,
	[Store_ID] [nvarchar](50) NOT NULL,
	[Store_Code] [nvarchar](50) NULL,
	[Store_Name] [nvarchar](500) NULL,
	[SKU_ID] [nvarchar](50) NOT NULL,
	[SKU_Code] [nvarchar](50) NOT NULL,
	[SKU_Name] [nvarchar](500) NULL,
	[Category] [nvarchar](500) NULL,
	[Shelf_Life_D] [float] NOT NULL,
	[Solt_Capacity] [float] NOT NULL,
	[Solt_QTY] [float] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_Store_List] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC,
	[Store_ID] ASC,
	[SKU_ID] ASC,
	[SKU_Code] ASC,
	[Shelf_Life_D] ASC,
	[Solt_Capacity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
