USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Order_Satisfaction_Rate](
	[Purchase_Datekey] [nvarchar](50) NULL,
	[Apply_Datekey] [nvarchar](50) NULL,
	[Region_code] [nvarchar](50) NULL,
	[Region_Name] [nvarchar](50) NULL,
	[Store_ID] [nvarchar](50) NULL,
	[Store_code] [nvarchar](50) NULL,
	[Store_Name] [nvarchar](50) NULL,
	[SKU_ID] [nvarchar](50) NULL,
	[SKU_code] [nvarchar](50) NULL,
	[Goods_Name] [nvarchar](50) NULL,
	[Purchase_QTY] [int] NULL,
	[Receipt_QTY] [int] NULL,
	[Satisfaction_Rate] [float] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](100) NOT NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](100) NOT NULL
) ON [PRIMARY]
GO
