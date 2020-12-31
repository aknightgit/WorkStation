USE [Foodunion]
GO
DROP TABLE [dm].[Dim_Store_20190723]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Store_20190723](
	[Store_ID] [varchar](50) NOT NULL,
	[Channel_Type] [nvarchar](50) NULL,
	[Channel_Account] [nvarchar](50) NULL,
	[Account_Store_Code] [varchar](50) NOT NULL,
	[Store_Type] [nvarchar](50) NULL,
	[Store_Province] [nvarchar](50) NULL,
	[Store_Province_EN] [nvarchar](50) NULL,
	[Store_City] [nvarchar](50) NULL,
	[Store_City_EN] [varchar](50) NULL,
	[Store_Name] [nvarchar](100) NULL,
	[Store_Address] [nvarchar](500) NULL,
	[Store_Manager_NM] [nvarchar](50) NULL,
	[Store_Manager_Phone] [nvarchar](50) NULL,
	[Store_Manager_Mail] [nvarchar](50) NULL,
	[Account_Store_Type] [nvarchar](50) NULL,
	[Account_Store_Type_EN] [nvarchar](50) NULL,
	[Account_Region_CN] [nvarchar](50) NULL,
	[Account_Region_EN] [varchar](50) NULL,
	[Account_Region_EN_Short] [varchar](10) NULL,
	[Account_Area_CN] [nvarchar](50) NULL,
	[Account_Area_EN] [nvarchar](50) NULL,
	[Target_Store_FL] [bit] NULL,
	[Seed_Store_FL] [bit] NULL,
	[PG_Store_FL] [bit] NULL,
	[DSR] [nvarchar](50) NULL,
	[SR_Level_1] [nvarchar](50) NULL,
	[SR_Level_2] [nvarchar](50) NULL,
	[Account_Store_Group] [nvarchar](50) NULL,
	[Open_Date] [varchar](20) NULL,
	[Status] [nvarchar](50) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
	[lng] [decimal](30, 20) NULL,
	[lat] [decimal](30, 20) NULL
) ON [PRIMARY]
GO
