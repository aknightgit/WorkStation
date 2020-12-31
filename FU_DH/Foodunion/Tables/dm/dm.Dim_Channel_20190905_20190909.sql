USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Channel_20190905_20190909](
	[Channel_ID] [int] NOT NULL,
	[newcol3] [varchar](50) NULL,
	[Channel_Name] [varchar](50) NOT NULL,
	[Channel_Name_CN] [nvarchar](100) NOT NULL,
	[Channel_Name_Display] [varchar](50) NOT NULL,
	[Channel_Name_Short] [varchar](50) NOT NULL,
	[Channel_Group] [varchar](50) NULL,
	[Channel_Category] [varchar](50) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
