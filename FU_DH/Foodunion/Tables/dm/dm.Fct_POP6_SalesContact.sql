USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_POP6_SalesContact](
	[POP_ID] [int] NOT NULL,
	[User_ID] [int] NOT NULL,
	[Contact_ID] [int] NULL,
	[Contact_Name] [varchar](100) NULL,
	[Contact_Mobile] [varchar](50) NULL,
	[Contact_Title] [varchar](50) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
PRIMARY KEY CLUSTERED 
(
	[POP_ID] ASC,
	[User_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_POP6_SalesContact] ADD  CONSTRAINT [DF_Fct_POP6_SalesContact_Create_Time]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_POP6_SalesContact] ADD  CONSTRAINT [DF_Fct_POP6_SalesContact_Update_Time]  DEFAULT (getdate()) FOR [Update_Time]
GO
