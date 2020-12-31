USE [Foodunion]
GO
DROP TABLE [dm].[Dim_Platform]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Platform](
	[Platform_ID] [int] IDENTITY(1,1) NOT NULL,
	[Platform_Name] [varchar](50) NOT NULL,
	[Platform_Name_CN] [nvarchar](100) NOT NULL,
	[Channel_Name] [varchar](50) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Dim_Platform] PRIMARY KEY CLUSTERED 
(
	[Platform_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
