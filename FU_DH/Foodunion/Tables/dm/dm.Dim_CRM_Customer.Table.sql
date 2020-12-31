USE [Foodunion]
GO
ALTER TABLE [dm].[Dim_CRM_Customer] DROP CONSTRAINT [DF__Dim_CRM_C__Updat__224B023A]
GO
ALTER TABLE [dm].[Dim_CRM_Customer] DROP CONSTRAINT [DF__Dim_CRM_C__Creat__2156DE01]
GO
DROP TABLE [dm].[Dim_CRM_Customer]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_CRM_Customer](
	[Super_ID] [bigint] IDENTITY(2000000001,1) NOT NULL,
	[Member_ID] [bigint] NOT NULL,
	[WX_Union_ID] [varchar](100) NULL,
	[WX_Open_ID] [varchar](100) NULL,
	[Mobile_Phone] [int] NULL,
	[Last_Name] [varchar](100) NULL,
	[First_Name] [varchar](100) NULL,
	[Full_Name] [varchar](100) NULL,
	[Nick_Name] [varchar](100) NULL,
	[Status] [varchar](100) NULL,
	[Gender] [varchar](10) NULL,
	[Birth_Date] [datetime] NULL,
	[Nationality] [varchar](10) NULL,
	[Province] [varchar](100) NULL,
	[City] [varchar](100) NULL,
	[Area] [varchar](100) NULL,
	[Address] [varchar](200) NULL,
	[Post_Code] [varchar](10) NULL,
	[Email_Address] [varchar](100) NULL,
	[QQ] [varchar](100) NULL,
	[Is_Registered] [bit] NULL,
	[Register_Date] [datetime] NULL,
	[Source] [varchar](100) NULL,
	[Vip_Level] [varchar](100) NULL,
	[Vip_Expiry_Date] [date] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [varchar](100) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_CRM_Customer] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_CRM_Customer] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
