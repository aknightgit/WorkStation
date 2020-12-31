USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_CenturyMart_DailySales](
	[Datekey] [varchar](8) NOT NULL,
	[Cust_No] [nvarchar](50) NULL,
	[Cust_Name] [nvarchar](200) NULL,
	[Barcode] [nvarchar](50) NULL,
	[Goods_No] [nvarchar](50) NULL,
	[Sub_No] [nvarchar](50) NULL,
	[SKU_ID] [nvarchar](50) NOT NULL,
	[Goods_Name] [nvarchar](200) NULL,
	[Goods_Code] [nvarchar](50) NULL,
	[Scale] [nvarchar](50) NULL,
	[Unit] [nvarchar](50) NULL,
	[Store_ID] [nvarchar](50) NOT NULL,
	[Store_Code] [nvarchar](50) NULL,
	[Store_Name] [nvarchar](200) NULL,
	[Ending_Inv] [decimal](18, 6) NULL,
	[Ending_Amt] [decimal](18, 6) NULL,
	[Pre_Amt] [decimal](18, 6) NULL,
	[Sale_Days] [decimal](18, 6) NULL,
	[Sale_Qty] [decimal](18, 6) NULL,
	[Sale_Amt] [decimal](18, 6) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Datekey] ASC,
	[SKU_ID] ASC,
	[Store_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
