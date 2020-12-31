USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Store_Covered](
	[Store_ID] [nvarchar](50) NULL,
	[Channel_Account] [nvarchar](50) NULL,
	[Account_Short] [nvarchar](50) NULL,
	[Account_Store_Code] [nvarchar](50) NULL,
	[Store_Province] [nvarchar](50) NULL,
	[Store_Province_EN] [nvarchar](50) NULL,
	[Province_Short] [nvarchar](50) NULL,
	[Store_City] [nvarchar](50) NULL,
	[Manager] [nvarchar](50) NULL,
	[Account_Store_Code_bak] [nvarchar](50) NULL,
	[Status] [nvarchar](50) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](100) NOT NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](100) NOT NULL
) ON [PRIMARY]
GO
