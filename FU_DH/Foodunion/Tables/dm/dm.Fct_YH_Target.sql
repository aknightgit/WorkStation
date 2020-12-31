USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Target](
	[period] [nvarchar](255) NOT NULL,
	[Store_id] [nvarchar](255) NOT NULL,
	[Region] [nvarchar](255) NULL,
	[Store_NM] [nvarchar](255) NULL,
	[PG] [nvarchar](255) NULL,
	[Low] [nvarchar](255) NULL,
	[Normal] [nvarchar](255) NULL,
	[Sales_Target] [decimal](18, 6) NULL,
	[Ambient_Sales_Target] [decimal](20, 8) NULL,
	[Fresh_Sales_Target] [decimal](20, 8) NULL,
	[DSR] [nvarchar](255) NULL,
	[Active_Order_AMT] [decimal](20, 10) NULL,
	[Open_Order_AMT] [decimal](20, 10) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_YH_Target] PRIMARY KEY CLUSTERED 
(
	[period] ASC,
	[Store_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
