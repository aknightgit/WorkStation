﻿USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Maco_Per_Store](
	[Year] [int] NULL,
	[MonthKey] [int] NOT NULL,
	[Month_Name_Short] [nvarchar](50) NULL,
	[Week_of_Year] [int] NULL,
	[Week_Nature_Str] [nvarchar](50) NULL,
	[Datekey] [date] NOT NULL,
	[Week_Day_Name] [nvarchar](50) NULL,
	[Channel] [nvarchar](50) NULL,
	[Region] [nvarchar](50) NULL,
	[Province] [nvarchar](50) NULL,
	[Province_Short] [nvarchar](50) NULL,
	[Sales_Area] [nvarchar](50) NULL,
	[IF_BLANK] [nvarchar](50) NULL,
	[Account_Store_Code] [nvarchar](50) NOT NULL,
	[Store_Name] [nvarchar](50) NULL,
	[Brand_Name] [nvarchar](50) NULL,
	[Plant] [nvarchar](50) NULL,
	[Product_Sort] [nvarchar](50) NULL,
	[Product_Category] [nvarchar](50) NULL,
	[FU_SKU_ID] [nvarchar](50) NOT NULL,
	[SKU_Name] [nvarchar](50) NULL,
	[SKU_Name_CN] [nvarchar](50) NULL,
	[Sale_Unit] [nvarchar](50) NULL,
	[Sales_Qty] [int] NULL,
	[Sales_AMT] [decimal](18, 5) NULL,
	[Sales_Vol_KG] [decimal](18, 5) NULL,
	[Inventory_Qty] [int] NULL,
	[Inventory_Vol_KG] [decimal](18, 5) NULL,
	[Main_FU_SKU] [nvarchar](50) NULL,
	[Promo_Period] [nvarchar](50) NULL,
	[Country_1st] [int] NULL,
	[P_2nd] [int] NULL,
	[P_3rd] [int] NULL,
	[P_4th] [int] NULL,
	[P_5th] [int] NULL,
	[P_6th] [int] NULL,
	[P_7th] [int] NULL,
	[P_8th] [int] NULL,
	[Period_Promo_SKU] [nvarchar](50) NULL,
	[VAT] [decimal](18, 8) NULL,
	[Sellin_Initial_Price] [decimal](18, 8) NULL,
	[Sellin_Promo_Price] [decimal](18, 8) NULL,
	[Nomative_VIC_KG] [decimal](18, 8) NULL,
	[VLC_KG] [decimal](18, 8) NULL,
	[Initial_MACO] [decimal](18, 8) NULL,
	[Initial_MACO%] [decimal](18, 8) NULL,
	[Final_Promo_MACO] [decimal](18, 8) NULL,
	[Final_Promo_MACO%] [decimal](18, 8) NULL,
	[TTL_Value_Initial] [decimal](18, 8) NULL,
	[TTL_Value_Promo] [decimal](18, 8) NULL,
	[VIC] [decimal](18, 8) NULL,
	[VLC] [decimal](18, 8) NULL,
	[TTL_Initial_MACO] [decimal](18, 8) NULL,
	[TTL_Initial_MACO%] [decimal](18, 8) NULL,
	[TTL_Final_Promo_MACO] [decimal](18, 8) NULL,
	[TTL_Final_Promo_MACO%] [decimal](18, 8) NULL,
	[TTL_Value_Vat] [decimal](18, 8) NULL,
	[RDC] [nvarchar](50) NULL,
	[Sales_Amount_LT0] [nvarchar](50) NULL,
	[Maco_Range] [nvarchar](50) NULL,
	[Actual_Promo_Deduct] [decimal](18, 8) NULL,
	[Actual_Sellin_price_2] [decimal](18, 8) NULL,
	[Total_Value_Vat] [decimal](18, 8) NULL,
	[Total_Value] [decimal](18, 8) NULL,
	[Act_MACO] [decimal](18, 8) NULL,
	[RSP] [decimal](18, 8) NULL,
	[RSP_Value] [decimal](18, 8) NULL,
	[RSP_VALUE_W_1] [decimal](18, 8) NULL,
	[Planned_Promo_Shelf_Price] [decimal](18, 8) NULL,
	[Target_ASP_Max] [decimal](18, 8) NULL,
	[Target_ASP_Min] [decimal](18, 8) NULL,
	[TTL_Sold_Standard] [decimal](18, 8) NULL,
	[Sales_AMT_W_1] [decimal](18, 5) NULL,
	[Sales_Qty_W_1] [int] NULL,
	[Store_Target] [decimal](18, 8) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_YH_Maco_Per_Store_1] PRIMARY KEY CLUSTERED 
(
	[MonthKey] ASC,
	[Datekey] ASC,
	[Account_Store_Code] ASC,
	[FU_SKU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
