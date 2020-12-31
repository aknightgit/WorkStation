USE [Foodunion]
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
	[Update_By] [varchar](6) NOT NULL,
 CONSTRAINT [PK_Dim_Product_Display_Standard] PRIMARY KEY CLUSTERED 
(
	[Channel] ASC,
	[SKU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
