USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_Store_SKU_Mapping](
	[Store_ID] [nvarchar](50) NOT NULL,
	[Store_Code] [nvarchar](50) NOT NULL,
	[Store_Name] [nvarchar](500) NULL,
	[SKU_ID] [nvarchar](50) NULL,
	[SKU_Code] [nvarchar](50) NOT NULL,
	[SKU_Name] [nvarchar](500) NULL,
	[SKU_Category] [nvarchar](50) NULL,
	[Begin_Date] [varchar](8) NOT NULL,
	[End_Date] [varchar](8) NULL,
	[Update_Source] [nvarchar](255) NULL,
	[Update_DTM] [datetime] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_Store_SKU_Mapping] PRIMARY KEY CLUSTERED 
(
	[Store_ID] ASC,
	[Store_Code] ASC,
	[SKU_Code] ASC,
	[Begin_Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
