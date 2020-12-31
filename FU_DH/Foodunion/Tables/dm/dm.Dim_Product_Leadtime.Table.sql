USE [Foodunion]
GO
ALTER TABLE [dm].[Dim_Product_Leadtime] DROP CONSTRAINT [DF__Dim_Produ__Updat__0E2EFAF4]
GO
ALTER TABLE [dm].[Dim_Product_Leadtime] DROP CONSTRAINT [DF__Dim_Produ__Creat__0D3AD6BB]
GO
DROP TABLE [dm].[Dim_Product_Leadtime]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Product_Leadtime](
	[SKU_ID] [varchar](50) NOT NULL,
	[SKU_Name] [varchar](100) NULL,
	[SKU_Name_CN] [varchar](100) NULL,
	[Product_Category] [varchar](100) NULL,
	[Shelf_Life_D] [int] NULL,
	[LongestRawMaterialLeadtime] [smallint] NULL,
	[DaysProductionLeadtimeIncludingQFS] [smallint] NULL,
	[ProductionCycle] [smallint] NULL,
	[DeliveryLeadtime] [smallint] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[SKU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Product_Leadtime] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Product_Leadtime] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
