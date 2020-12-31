USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[Fct_YH_Target_20191018](
	[period] [nvarchar](255) NULL,
	[Store_ID] [nvarchar](255) NULL,
	[Region] [nvarchar](255) NULL,
	[Store_NM] [nvarchar](255) NULL,
	[PG] [nvarchar](255) NULL,
	[Low] [nvarchar](255) NULL,
	[Normal] [nvarchar](255) NULL,
	[Sales_Target] [decimal](18, 6) NULL,
	[Ambient_Sales_Target] [decimal](20, 8) NULL,
	[Fresh_Sales_Target] [decimal](20, 8) NULL,
	[DSR] [nvarchar](255) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
