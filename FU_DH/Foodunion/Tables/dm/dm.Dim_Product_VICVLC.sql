USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Product_VICVLC](
	[Channel] [varchar](50) NOT NULL,
	[SKU_ID] [varchar](50) NOT NULL,
	[Barcode] [varchar](50) NULL,
	[Channel_SKU] [varchar](50) NULL,
	[External_SKU] [varchar](50) NULL,
	[VOL_KG] [decimal](18, 3) NULL,
	[VAT] [decimal](18, 2) NULL,
	[RSP] [float] NULL,
	[FU_sellin_price_W_VAT] [decimal](18, 4) NULL,
	[FU_sellin_price_W/O_VAT] [decimal](18, 4) NULL,
	[Store_cost_W_VAT] [decimal](18, 4) NULL,
	[Store_cost_W/O_VAT] [decimal](18, 4) NULL,
	[VIC_KG] [decimal](18, 4) NULL,
	[VIC] [decimal](18, 4) NULL,
	[VLC_KG] [decimal](18, 4) NULL,
	[VLC] [decimal](18, 4) NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[IsCurrent] [bit] NOT NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK__Dim_Prod__79F1D4FBEFA8C27A_B6FF] PRIMARY KEY CLUSTERED 
(
	[Channel] ASC,
	[SKU_ID] ASC,
	[IsCurrent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Product_VICVLC] ADD  CONSTRAINT [df_Dim_Product_VICVLC_CreateTime]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Product_VICVLC] ADD  CONSTRAINT [df_Dim_Product_VICVLC_Update_Time]  DEFAULT (getdate()) FOR [Update_Time]
GO
