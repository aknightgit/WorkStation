USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Channel_20191219_TEMP](
	[Channel_ID] [int] NOT NULL,
	[Channel_Name] [nvarchar](100) NOT NULL,
	[Channel_Name_CN] [nvarchar](100) NOT NULL,
	[ERP_Customer_ID] [nvarchar](100) NULL,
	[ERP_Customer_Name] [nvarchar](100) NULL,
	[Channel_Name_Display] [nvarchar](100) NULL,
	[Channel_Name_Short] [nvarchar](100) NULL,
	[Channel_Type] [nvarchar](100) NULL,
	[Channel_Category] [nvarchar](100) NULL,
	[Channel_Handler] [nvarchar](100) NULL,
	[Province] [varchar](50) NULL,
	[Team] [nvarchar](100) NULL,
	[Team_Handler] [nvarchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
	[test] [int] NULL
) ON [PRIMARY]
GO
