USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Store_Flag_Daily](
	[Date_ID] [int] NOT NULL,
	[Store_ID] [varchar](50) NOT NULL,
	[Sales_AMT] [decimal](38, 6) NULL,
	[Sales_QTY] [decimal](38, 6) NULL,
	[Sales_Vol] [decimal](38, 6) NULL,
	[YH_Home_Sales_AMT] [decimal](38, 6) NULL,
	[JD_Home_Sales_AMT] [decimal](38, 6) NULL,
	[Inventory_AMT] [decimal](38, 6) NULL,
	[Inventory_QTY] [decimal](38, 6) NULL,
	[Inventory_Vol] [decimal](38, 6) NULL,
	[Distribution] [varchar](50) NULL,
	[Online_Distribution] [varchar](50) NULL,
	[SKU_Distribution] [varchar](50) NULL,
	[Load_DTM] [datetime] NULL,
	[Store_Count_Target] [int] NULL,
	[Inventory_MA14_AMT] [decimal](20, 10) NULL,
	[Inventory_MA14_QTY] [decimal](20, 10) NULL,
	[Inventory_MA14_VOL] [decimal](20, 10) NULL,
	[Sales_MA7_AMT] [decimal](20, 10) NULL,
	[Sales_MA7_14_AMT] [decimal](20, 10) NULL,
	[Active_Days_MA7] [decimal](20, 10) NULL,
	[Sales_MA14_AMT] [decimal](20, 10) NULL,
	[Sales_MA14_QTY] [decimal](20, 10) NULL,
	[Sales_MA14_VOL] [decimal](20, 10) NULL,
	[Inventory_SKU_Count] [decimal](20, 10) NULL,
	[Sales_Store_AVG_AMT_REGION_MA7] [decimal](38, 6) NULL,
	[Sales_Store_AVG_AMT_REGION_MA14] [decimal](38, 6) NULL,
	[Sales_Store_AVG_AMT_REGION_MA7_14] [decimal](38, 6) NULL,
	[Last_Order_DT] [date] NULL,
	[Last2_Order_DT] [date] NULL,
	[Date_Gap_Last1_2] [int] NULL,
	[Order_Qty_L7] [decimal](20, 10) NULL,
	[Order_Amt_L7] [decimal](20, 10) NULL,
	[Order_SKUCount_L7] [decimal](20, 10) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
	[This_WK_Order_AMT] [decimal](20, 10) NULL,
	[Last_Order_AMT] [decimal](20, 10) NULL,
 CONSTRAINT [PK_Fct_YH_Store_Flag_Daily] PRIMARY KEY NONCLUSTERED 
(
	[Date_ID] ASC,
	[Store_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ix_c_YH_Store_Flag_Daily_Cal_C0FD_5219] ON [dm].[Fct_YH_Store_Flag_Daily]
(
	[Date_ID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
