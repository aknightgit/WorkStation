USE [Foodunion]
GO
DROP TABLE [dm].[Dim_Product_Display_Standard]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Product_Display_Standard](
	[Channel] [varchar](8) NOT NULL,
	[SKU_ID] [varchar](50) NOT NULL,
	[SKU_Name] [varchar](200) NOT NULL,
	[SKU_Name_CN] [nvarchar](200) NOT NULL,
	[Standard_Qty] [int] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](6) NOT NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](6) NOT NULL
) ON [PRIMARY]
GO
