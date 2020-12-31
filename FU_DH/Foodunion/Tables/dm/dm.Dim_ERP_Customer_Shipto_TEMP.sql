USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_ERP_Customer_Shipto_TEMP](
	[Customer_ID] [varchar](100) NOT NULL,
	[Customer_Name] [varchar](100) NULL,
	[Sequence_ID] [varchar](100) NOT NULL,
	[Ship_To] [varchar](100) NULL,
	[Ship_To_Desc] [varchar](100) NULL,
	[Address] [varchar](200) NULL,
	[Province] [varchar](100) NULL,
	[City] [varchar](100) NULL,
	[lng] [varchar](100) NULL,
	[TEL] [varchar](100) NULL,
	[IsActive] [bit] NULL,
	[Start_Date] [datetime] NULL,
	[End_Date] [datetime] NULL,
	[Country] [varchar](200) NULL,
	[Mobile] [varchar](200) NULL,
	[Default_Stock_ID] [varchar](100) NULL,
	[Default_Stock_Name] [varchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
