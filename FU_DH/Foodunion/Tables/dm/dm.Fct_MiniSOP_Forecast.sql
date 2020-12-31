USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_MiniSOP_Forecast](
	[Period] [varchar](50) NOT NULL,
	[Year] [varchar](50) NOT NULL,
	[Week_no] [varchar](50) NOT NULL,
	[SKU_ID] [varchar](50) NOT NULL,
	[Barcode] [varchar](50) NULL,
	[Category] [varchar](50) NULL,
	[Brand] [varchar](50) NULL,
	[Family] [varchar](50) NULL,
	[Product_Description_EN] [varchar](200) NULL,
	[Product_Description_CN] [varchar](200) NULL,
	[Plant] [varchar](50) NOT NULL,
	[Sales_Territory] [varchar](50) NULL,
	[RDC] [varchar](50) NOT NULL,
	[Channel] [varchar](50) NOT NULL,
	[Baseline_Forecast] [decimal](9, 2) NULL,
	[Promotion] [decimal](9, 2) NULL,
	[Order_Qty] [decimal](9, 2) NULL,
	[Ship_to_Qty] [decimal](9, 2) NULL,
	[OTIF] [decimal](9, 2) NULL,
	[Sell_out_Qty] [decimal](9, 2) NULL,
	[Sell_out_Vs_Forecast] [decimal](9, 2) NULL,
	[Closing_Inv] [decimal](9, 2) NULL,
	[Inv_Coverage_Days] [decimal](9, 2) NULL,
	[Date] [varchar](50) NULL,
	[SaleManager] [varchar](50) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Fct_MiniSOP_Forecast] PRIMARY KEY CLUSTERED 
(
	[Year] ASC,
	[Week_no] ASC,
	[Plant] ASC,
	[SKU_ID] ASC,
	[RDC] ASC,
	[Channel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
