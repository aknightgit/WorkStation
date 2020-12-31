USE [Foodunion]
GO
DROP TABLE [dm].[Dim_Product_Channel_Mapping]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Product_Channel_Mapping](
	[Channel_Name] [varchar](50) NOT NULL,
	[SKU_ID] [varchar](50) NOT NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [varchar](50) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](50) NULL
) ON [PRIMARY]
GO
