USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[YH门店覆盖](
	[Store_ID] [nvarchar](50) NULL,
	[Channel_Account] [nvarchar](50) NULL,
	[Account_Short] [nvarchar](50) NULL,
	[Account_Store_Code] [nvarchar](50) NULL,
	[Store_Province] [nvarchar](50) NULL,
	[Store_Province_EN] [nvarchar](50) NULL,
	[Province_Short] [nvarchar](50) NULL,
	[Store_City] [nvarchar](50) NULL,
	[负责人] [nvarchar](50) NULL,
	[Account_Store_Code_bak] [nvarchar](50) NULL,
	[status] [nvarchar](50) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](100) NULL
) ON [PRIMARY]
GO
