USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Channel_20191011](
	[Channel_ID] [int] NOT NULL,
	[Channel_Name] [varchar](50) NOT NULL,
	[Channel_Name_CN] [nvarchar](100) NOT NULL,
	[Channel_Name_Display] [varchar](50) NOT NULL,
	[Channel_Name_Short] [varchar](50) NOT NULL,
	[Channel_Group] [varchar](50) NULL,
	[Channel_Category] [varchar](50) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Dim_Channel] PRIMARY KEY CLUSTERED 
(
	[Channel_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
