USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Department](
	[Department_ID] [bigint] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Description] [nvarchar](100) NULL,
	[Parent_ID] [bigint] NULL,
	[Level_No] [smallint] NULL,
	[Is_Active] [bit] NULL,
	[Status] [varchar](10) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Dim_Department] PRIMARY KEY CLUSTERED 
(
	[Department_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Department] ADD  CONSTRAINT [df_Dim_Department_Is_Active]  DEFAULT ((1)) FOR [Is_Active]
GO
ALTER TABLE [dm].[Dim_Department] ADD  CONSTRAINT [df_Dim_Department_Create_Time]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Department] ADD  CONSTRAINT [df_Dim_Department_Update_Time]  DEFAULT (getdate()) FOR [Update_Time]
GO
