USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Product_AccountCodeMapping](
	[Account] [varchar](50) NOT NULL,
	[SKU_ID] [nvarchar](200) NULL,
	[SKU_Code] [varchar](50) NOT NULL,
	[Bar_Code] [varchar](50) NULL,
	[Parent_Barcode] [varchar](100) NULL,
	[Split_Number] [int] NULL,
	[Retail_price_group] [decimal](18, 6) NULL,
	[Retail_price_bottle] [decimal](18, 6) NULL,
	[Update_By] [varchar](100) NULL,
	[Update_Time] [datetime] NULL,
 CONSTRAINT [PK__Dim_Prod__70C65F43CF9BC4E1_44F4_00D9_FF95_EA07_3FF4_17C0] PRIMARY KEY CLUSTERED 
(
	[Account] ASC,
	[SKU_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
