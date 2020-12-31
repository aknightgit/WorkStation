USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_SKU_RSP](
	[Channel] [nvarchar](200) NULL,
	[FU_SKU] [nvarchar](200) NOT NULL,
	[YH_SKU_Code] [nvarchar](200) NULL,
	[SKU_Name_CN] [nvarchar](200) NULL,
	[SKU_Name_EN] [nvarchar](200) NULL,
	[A/F] [nvarchar](200) NULL,
	[FU_Sellin_Price_1] [decimal](18, 3) NULL,
	[Store_Cost] [decimal](18, 3) NULL,
	[RSP] [decimal](18, 3) NULL,
	[VAT] [decimal](18, 3) NULL,
	[VOL_KG] [decimal](18, 6) NULL,
	[VIC] [decimal](18, 6) NULL,
	[VLC] [decimal](18, 6) NULL,
	[MACO] [decimal](18, 6) NULL,
	[MACO%] [decimal](18, 6) NULL,
	[Sellin_Price_W/O_Vat] [decimal](18, 9) NULL,
	[Target_ASP_Max] [decimal](18, 9) NULL,
	[Price_KG_Max] [decimal](18, 9) NULL,
	[Target_ASP_Min] [decimal](18, 9) NULL,
	[Price_KG_Min] [decimal](18, 9) NULL,
	[MD_Min_Margin] [decimal](18, 9) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_YH_SKU_RSP] PRIMARY KEY CLUSTERED 
(
	[FU_SKU] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
