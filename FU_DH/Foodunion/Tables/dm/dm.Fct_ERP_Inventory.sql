USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Inventory](
	[SKU_ID] [nvarchar](200) NULL,
	[Inventory_DT] [nvarchar](50) NULL,
	[Manufacturing_DT] [date] NULL,
	[Expiring_DT] [date] NULL,
	[Inventory_QTY] [int] NULL,
	[Weight_NBR] [decimal](38, 18) NULL,
	[Warehouse_Id] [int] NULL,
	[Fresh_Day] [int] NULL,
	[Guarantee_period] [int] NULL,
	[Guarantee_period_type] [nvarchar](50) NOT NULL,
	[Fresh_Type] [nvarchar](50) NOT NULL,
	[Storaging_DT] [date] NULL,
	[Is_Damaged] [nvarchar](200) NULL,
	[Is_Expired] [nvarchar](200) NULL,
	[Storaging_Days] [nvarchar](50) NOT NULL,
	[Best_Sales_DT] [date] NULL,
	[Best_Sales_Days] [int] NULL,
	[Sell_out_QTY] [decimal](38, 6) NULL,
	[Estimated_Sales_DT] [date] NULL,
	[Estimated_Sales_Days] [decimal](20, 10) NULL,
	[Estimated_Sales_Qty] [decimal](21, 10) NULL,
	[Estimated_Expired_Qty] [decimal](20, 10) NULL,
	[Storaging_Flag] [int] NOT NULL,
	[Manufacturing_Flag] [int] NOT NULL,
	[Expired_Flag] [int] NOT NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Inventory] ADD  CONSTRAINT [DF_Fct_ERP_Inventory_Create_Time]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Inventory] ADD  CONSTRAINT [DF_Fct_ERP_Inventory_Update_Time]  DEFAULT (getdate()) FOR [Update_Time]
GO
