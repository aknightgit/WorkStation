USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Customer_20200207](
	[Super_ID] [bigint] NOT NULL,
	[WX_Union_ID] [varchar](100) NULL,
	[WX_Open_ID] [varchar](100) NULL,
	[Mobile_Phone] [varchar](20) NOT NULL,
	[Mobile_Phone_2] [varchar](20) NULL,
	[First_Name] [varchar](100) NULL,
	[Last_Name] [varchar](100) NULL,
	[Full_Name] [varchar](200) NULL,
	[Nick_Name] [varchar](100) NULL,
	[Source] [varchar](100) NULL,
	[Status] [varchar](100) NULL,
	[Gender] [varchar](10) NULL,
	[Birth_Date] [datetime] NULL,
	[Nationality] [varchar](10) NULL,
	[Province] [varchar](100) NULL,
	[City] [varchar](100) NULL,
	[Area] [varchar](100) NULL,
	[Address] [varchar](200) NULL,
	[ZipCode] [varchar](10) NULL,
	[Email] [varchar](100) NULL,
	[QQ] [varchar](100) NULL,
	[Is_Registered] [bit] NULL,
	[Register_Platform] [varchar](100) NULL,
	[Platform_Member_ID] [bigint] NULL,
	[Register_Date] [datetime] NULL,
	[FirstOrderPlatform] [varchar](100) NULL,
	[FirstOrderDate] [date] NULL,
	[FirstContactDate] [date] NULL,
	[Vip_Level] [varchar](100) NULL,
	[Vip_Expiry_Date] [date] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [varchar](100) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](100) NULL
) ON [PRIMARY]
GO
