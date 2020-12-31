USE [Foodunion]
GO
DROP TABLE [dm].[Fct_Sales_Channel_20191023]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_Channel_20191023](
	[Yearkey] [nvarchar](200) NULL,
	[Datekey] [nvarchar](200) NULL,
	[Customer] [nvarchar](200) NULL,
	[Channel_ID] [varchar](200) NOT NULL,
	[Store_NM] [nvarchar](200) NULL,
	[SKU] [nvarchar](200) NULL,
	[SKU_NM] [nvarchar](200) NULL,
	[Brand] [nvarchar](200) NULL,
	[Category] [nvarchar](200) NULL,
	[RSP] [decimal](18, 6) NULL,
	[QTY] [decimal](18, 6) NULL,
	[GS_Price] [decimal](18, 6) NULL,
	[POS] [decimal](18, 6) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](37) NOT NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](37) NOT NULL
) ON [PRIMARY]
GO
