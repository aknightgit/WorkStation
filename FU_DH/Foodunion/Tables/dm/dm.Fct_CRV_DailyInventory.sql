USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_CRV_DailyInventory](
	[Datekey] [int] NOT NULL,
	[Date] [datetime] NULL,
	[Store_ID] [varchar](50) NOT NULL,
	[SKU_ID] [varchar](50) NOT NULL,
	[Store_Name] [nvarchar](200) NULL,
	[CRV_goodsname] [nvarchar](200) NULL,
	[Sale_Scale] [varchar](50) NULL,
	[Sale_Unit] [varchar](50) NULL,
	[Qty] [int] NULL,
	[Gross_Cost_Value] [decimal](9, 2) NULL,
	[Tax_Cost_Value] [decimal](9, 2) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Datekey] ASC,
	[Store_ID] ASC,
	[SKU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
