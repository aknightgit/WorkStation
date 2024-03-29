USE [Foodunion]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_Inventory] DROP CONSTRAINT [DF__Fct_ERP_S__Updat__0015E5C7]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_Inventory] DROP CONSTRAINT [DF__Fct_ERP_S__Creat__7F21C18E]
GO
DROP TABLE [dm].[Fct_ERP_Stock_Inventory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Stock_Inventory](
	[Datekey] [int] NOT NULL,
	[Stock_ID] [varchar](100) NOT NULL,
	[Stock_Name] [varchar](100) NOT NULL,
	[Stock_Org] [varchar](100) NULL,
	[Stock_Status] [varchar](10) NULL,
	[SKU_ID] [varchar](100) NOT NULL,
	[SKU_Name] [varchar](100) NULL,
	[SKU_Name_EN] [varchar](200) NULL,
	[LOT] [varchar](100) NOT NULL,
	[Produce_Date] [date] NOT NULL,
	[Expiry_Date] [date] NULL,
	[Stock_Unit] [varchar](10) NULL,
	[Stock_QTY] [decimal](18, 9) NULL,
	[Lock_QTY] [decimal](18, 9) NULL,
	[Base_Unit] [varchar](10) NULL,
	[Base_QTY] [decimal](18, 9) NULL,
	[Sale_Unit] [varchar](10) NULL,
	[Sale_QTY] [decimal](18, 9) NULL,
	[IsEffective] [bit] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
	[Storaging_Date] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_Inventory] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_Inventory] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
