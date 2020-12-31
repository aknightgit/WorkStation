USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Product_Pricelist](
	[Price_ID] [int] NOT NULL,
	[Price_List_No] [varchar](50) NULL,
	[Price_List_Name] [varchar](100) NULL,
	[Sale_ORG_Name] [varchar](100) NULL,
	[SKU_ID] [varchar](50) NULL,
	[Sale_Unit] [varchar](50) NULL,
	[SKU_Price] [decimal](18, 9) NULL,
	[SKU_Price_withTax] [decimal](18, 5) NULL,
	[Base_Unit] [varchar](50) NULL,
	[SKU_Base_Price] [decimal](18, 9) NULL,
	[Base_Price_withTax] [decimal](18, 5) NULL,
	[Effective_Date] [datetime] NULL,
	[Expiry_Date] [datetime] NULL,
	[Is_Current] [bit] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Dim_Product_Pricelist] PRIMARY KEY CLUSTERED 
(
	[Price_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
