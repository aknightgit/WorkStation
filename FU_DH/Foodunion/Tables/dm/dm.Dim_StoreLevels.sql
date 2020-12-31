USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_StoreLevels](
	[Level_ID] [int] NOT NULL,
	[Level_Code] [varchar](50) NOT NULL,
	[Type] [varchar](50) NULL,
	[Min_Value] [decimal](18, 2) NULL,
	[Max_Value] [decimal](18, 2) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Dim_StoreLevels] PRIMARY KEY CLUSTERED 
(
	[Level_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
