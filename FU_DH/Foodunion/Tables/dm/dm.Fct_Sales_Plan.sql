USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_Plan](
	[Plan_DT] [nvarchar](200) NULL,
	[SKU_ID] [nvarchar](200) NULL,
	[SALES_FCST_VOL] [decimal](18, 9) NULL,
	[SALES_OUT_VOL] [decimal](18, 9) NULL,
	[SALES_IN_VOL] [decimal](18, 9) NULL,
	[Week_NM] [nvarchar](200) NULL,
	[year_month] [nvarchar](200) NULL,
	[Week_Month] [nvarchar](200) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
