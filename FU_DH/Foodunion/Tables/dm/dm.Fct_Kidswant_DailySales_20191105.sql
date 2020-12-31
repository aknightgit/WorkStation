USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Kidswant_DailySales_20191105](
	[Datekey] [int] NULL,
	[Bill_No] [nvarchar](50) NULL,
	[SKU_ID] [nvarchar](50) NULL,
	[Store_ID] [nvarchar](50) NULL,
	[Store_Code] [nvarchar](50) NULL,
	[Store_Name] [nvarchar](50) NULL,
	[Goods_Status] [nvarchar](50) NULL,
	[Delivery_Type] [nvarchar](50) NULL,
	[InStock_Qty] [decimal](20, 10) NULL,
	[TransferIn_Qty] [decimal](20, 10) NULL,
	[TransferOut_Qty] [decimal](20, 10) NULL,
	[Return_Qty] [decimal](20, 10) NULL,
	[Sales_Qty] [decimal](20, 10) NULL,
	[Sales_AMT] [decimal](20, 10) NULL,
	[Ending_Qty] [decimal](20, 10) NULL,
	[Ending_AMT] [decimal](20, 10) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
	[SKU_Name] [varchar](200) NULL
) ON [PRIMARY]
GO
