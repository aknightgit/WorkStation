USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Product_VICVLC_TEST](
	[Channel] [varchar](50) NULL,
	[SKU_ID] [varchar](50) NULL,
	[Barcode] [varchar](50) NULL,
	[Channel_SKU] [varchar](50) NULL,
	[VOL_KG] [float] NULL,
	[VAT] [decimal](18, 3) NULL,
	[RSP] [decimal](18, 5) NULL,
	[FU_sellin_price_W_VAT] [float] NULL,
	[FU_sellin_price_W/O_VAT] [float] NULL,
	[Store_cost_W_VAT] [float] NULL,
	[Store_cost_W/O_VAT] [float] NULL,
	[VIC_KG] [decimal](18, 5) NULL,
	[VIC] [float] NULL,
	[VLC_KG] [decimal](18, 5) NULL,
	[VLC] [float] NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[IsCurrent] [bit] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
