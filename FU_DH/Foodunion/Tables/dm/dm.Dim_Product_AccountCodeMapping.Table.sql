USE [Foodunion]
GO
DROP TABLE [dm].[Dim_Product_AccountCodeMapping]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Product_AccountCodeMapping](
	[Account] [varchar](50) NOT NULL,
	[SKU_Code] [varchar](50) NOT NULL,
	[Bar_Code] [varchar](50) NULL,
	[Update_By] [varchar](100) NULL,
	[Update_Time] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Account] ASC,
	[SKU_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
