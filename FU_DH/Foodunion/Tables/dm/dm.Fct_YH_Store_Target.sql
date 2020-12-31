USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Store_Target](
	[MonthKey] [nvarchar](20) NOT NULL,
	[FU_Region] [nvarchar](200) NULL,
	[Region_Name] [nvarchar](200) NULL,
	[Store_Code] [nvarchar](200) NOT NULL,
	[Store_Name] [nvarchar](200) NULL,
	[Store_Manager] [nvarchar](200) NULL,
	[City_Manager] [nvarchar](200) NULL,
	[Region_Manager] [nvarchar](200) NULL,
	[Target] [decimal](18, 8) NULL,
	[Other] [nvarchar](200) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](1) NOT NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](1) NOT NULL,
 CONSTRAINT [PK_Fct_YH_Store_Target] PRIMARY KEY CLUSTERED 
(
	[MonthKey] ASC,
	[Store_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
