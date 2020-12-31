USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Promo_Period_By_SKU](
	[Channel] [nvarchar](200) NULL,
	[FU_SKU] [nvarchar](200) NULL,
	[YH_SKU_Code] [nvarchar](200) NULL,
	[SKU_Name] [nvarchar](200) NULL,
	[A/F] [nvarchar](200) NULL,
	[FU_Sellin_Price_1] [decimal](18, 5) NULL,
	[FU_Sellin_Price_2] [decimal](18, 5) NULL,
	[Store_Cost] [decimal](18, 5) NULL,
	[RSP] [decimal](18, 5) NULL,
	[VAT] [decimal](18, 5) NULL,
	[Promo_Price] [decimal](18, 5) NULL,
	[Coeff] [decimal](18, 5) NULL,
	[Coeff_Promo_Price] [decimal](18, 5) NULL,
	[Promo_Deduct] [decimal](18, 5) NULL,
	[Promo_Period] [nvarchar](200) NULL,
	[Soft_Promo_Description] [nvarchar](200) NULL,
	[Promo_Region] [nvarchar](200) NULL,
	[P1] [nvarchar](200) NULL,
	[P2] [nvarchar](200) NOT NULL,
	[P3] [nvarchar](200) NULL,
	[P4] [nvarchar](200) NULL,
	[P5] [nvarchar](200) NULL,
	[P6] [nvarchar](200) NULL,
	[P7] [nvarchar](200) NULL,
	[P8] [nvarchar](200) NULL,
	[Q1] [nvarchar](200) NULL,
	[Q2] [nvarchar](200) NULL,
	[Q3] [nvarchar](200) NULL,
	[Q4] [nvarchar](200) NULL,
	[Q5] [nvarchar](200) NULL,
	[Q6] [nvarchar](200) NULL,
	[Q7] [nvarchar](200) NULL,
	[Q8] [nvarchar](200) NULL,
	[R1] [nvarchar](200) NULL,
	[R2] [nvarchar](200) NULL,
	[R3] [nvarchar](200) NULL,
	[R4] [nvarchar](200) NULL,
	[R5] [nvarchar](200) NULL,
	[R6] [nvarchar](200) NULL,
	[R7] [nvarchar](200) NULL,
	[R8] [nvarchar](200) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_YH_Promo_Period_By_SKU] PRIMARY KEY CLUSTERED 
(
	[P2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
