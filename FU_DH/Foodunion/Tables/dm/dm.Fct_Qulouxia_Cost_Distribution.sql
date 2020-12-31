USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_Cost_Distribution](
	[DateKey] [bigint] NULL,
	[Store_ID] [nvarchar](50) NULL,
	[Store_Code] [nvarchar](50) NULL,
	[Store_Name] [nvarchar](500) NULL,
	[SKU_ID] [nvarchar](50) NULL,
	[SKU_Code] [nvarchar](50) NOT NULL,
	[SKU_Name] [nvarchar](500) NULL,
	[Category] [nvarchar](500) NULL,
	[Promotion_Type] [nvarchar](500) NULL,
	[Promotion_ID] [nvarchar](50) NOT NULL,
	[Promotion_Name] [nvarchar](255) NULL,
	[Cost_Price] [decimal](18, 2) NULL,
	[Sales_Price] [decimal](18, 2) NULL,
	[Promotion_Price] [decimal](18, 2) NOT NULL,
	[QTY] [float] NULL,
	[Discount_Amount] [decimal](18, 2) NULL,
	[Order_No] [nvarchar](50) NOT NULL,
	[Is_Member] [nvarchar](500) NULL,
	[UserID] [nvarchar](50) NULL,
	[Platform] [nvarchar](500) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_Cost_Distribution_1] PRIMARY KEY CLUSTERED 
(
	[SKU_Code] ASC,
	[Promotion_ID] ASC,
	[Promotion_Price] ASC,
	[Order_No] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
