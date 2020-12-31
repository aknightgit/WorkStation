USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_SalesTerritory_Mapping_Monthly](
	[Monthkey] [int] NOT NULL,
	[Channel] [varchar](100) NULL,
	[Province] [varchar](200) NOT NULL,
	[Province_Short] [varchar](10) NULL,
	[Code] [varchar](100) NULL,
	[Region] [varchar](200) NULL,
	[Region_EN] [varchar](200) NULL,
	[Region_Director] [varchar](200) NULL,
	[Area] [varchar](50) NULL,
	[Manager] [varchar](200) NULL,
	[Is_Current] [bit] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](100) NULL,
 CONSTRAINT [PK_Dim_SalesTerritory_Mapping_Monthly_2DAB_7E2F_574A_B22F_8158] PRIMARY KEY CLUSTERED 
(
	[Monthkey] ASC,
	[Province] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_SalesTerritory_Mapping_Monthly] ADD  CONSTRAINT [DF_Dim_SalesTerritory_Mapping_Monthly_CreateTime]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_SalesTerritory_Mapping_Monthly] ADD  CONSTRAINT [DF_Dim_SalesTerritory_Mapping_Monthly_UpdateTime]  DEFAULT (getdate()) FOR [Update_Time]
GO
