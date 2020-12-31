USE [Foodunion]
GO
DROP TABLE [dm].[Dim_Store_Flg]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Store_Flg](
	[Store_ID] [varchar](50) NOT NULL,
	[Account_Store_Code] [varchar](50) NOT NULL,
	[FIRST_SALES_DATE_AMBIENT] [nvarchar](200) NULL,
	[FIRST_SALES_DATE_Fresh] [nvarchar](200) NULL,
	[Load_DTM] [datetime] NULL,
	[FIRST_SALES_DATE] [nvarchar](200) NULL,
	[FIRST_SALES_DATE_BOTH] [nvarchar](200) NULL
) ON [PRIMARY]
GO
