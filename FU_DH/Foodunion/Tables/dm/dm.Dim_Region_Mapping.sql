USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Region_Mapping](
	[Account] [varchar](100) NULL,
	[Region] [varchar](100) NOT NULL,
	[Region_Manager] [varchar](100) NULL,
	[Area] [varchar](100) NOT NULL,
	[Area_Manager] [varchar](100) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
