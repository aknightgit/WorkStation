USE [Foodunion]
GO
DROP TABLE [dm].[Dim_Product_Leadtime_20190724]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Product_Leadtime_20190724](
	[SKU_ID] [varchar](50) NOT NULL,
	[SKU_Name] [varchar](100) NULL,
	[SKU_Name_CN] [varchar](100) NULL,
	[LongestRawMaterialLeadtime] [smallint] NULL,
	[DaysProductionLeadtimeIncludingQFS] [smallint] NULL,
	[ProductionCycle] [smallint] NULL,
	[DeliveryLeadtime] [smallint] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
