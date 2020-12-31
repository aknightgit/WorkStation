USE [Foodunion]
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
	[Update_By] [varchar](50) NULL,
 CONSTRAINT [PK_Dim_Product_Channel_Mapping] PRIMARY KEY CLUSTERED 
(
	[Channel_Name] ASC,
	[SKU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
