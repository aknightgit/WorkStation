USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Store](
	[ID] [int] NOT NULL,
	[Store_ID] [varchar](50) NOT NULL,
	[Channel_Type] [nvarchar](50) NULL,
	[Channel_ID] [int] NULL,
	[Channel_Account] [nvarchar](50) NULL,
	[Account_Short] [varchar](10) NULL,
	[Account_Store_Code] [varchar](50) NOT NULL,
	[Store_Type] [nvarchar](50) NULL,
	[Store_Province] [nvarchar](50) NULL,
	[Store_Province_EN] [nvarchar](50) NULL,
	[Province_Short] [varchar](10) NULL,
	[Store_City] [nvarchar](50) NULL,
	[Store_City_EN] [varchar](50) NULL,
	[Store_Name] [nvarchar](100) NULL,
	[Store_Address] [nvarchar](500) NULL,
	[Store_Manager_NM] [nvarchar](50) NULL,
	[Store_Manager_Phone] [nvarchar](50) NULL,
	[Store_Manager_Mail] [nvarchar](50) NULL,
	[Account_Store_Type] [nvarchar](50) NULL,
	[Account_Store_Type_EN] [nvarchar](50) NULL,
	[Account_Area_CN] [nvarchar](50) NULL,
	[Account_Area_EN] [nvarchar](50) NULL,
	[Sales_Region] [varchar](50) NULL,
	[Sales_Area_CN] [nvarchar](50) NULL,
	[Target_Store_FL] [bit] NULL,
	[Level_Code] [nvarchar](50) NULL,
	[PG_Store_FL] [bit] NULL,
	[SR_Level_1] [nvarchar](50) NULL,
	[SR_Level_2] [nvarchar](50) NULL,
	[Account_Store_Group] [nvarchar](50) NULL,
	[Open_Date] [varchar](20) NULL,
	[Status] [nvarchar](50) NULL,
	[lng] [decimal](30, 20) NULL,
	[lat] [decimal](30, 20) NULL,
	[POP_ID] [int] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Dim_Store_859C_8A5A_96A8_7918_493A_93EF] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[Store_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_Dim_Store_Channel_Code_4A66_95AD_95F9_FA49_9D76] ON [dm].[Dim_Store]
(
	[Account_Store_Code] ASC,
	[Channel_Account] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
