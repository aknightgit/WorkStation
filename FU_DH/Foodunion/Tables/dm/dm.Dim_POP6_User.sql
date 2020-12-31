USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_POP6_User](
	[User_ID] [int] NOT NULL,
	[First_Name] [varchar](50) NULL,
	[Last_Name] [varchar](50) NULL,
	[Full_Name] [varchar](100) NULL,
	[Username] [varchar](50) NULL,
	[Email_Address] [varchar](50) NULL,
	[Mobile] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[Superior_ID] [int] NULL,
	[Superior] [varchar](50) NULL,
	[Team_ID] [int] NULL,
	[Team_Name] [varchar](50) NULL,
	[Team_Status] [varchar](50) NULL,
	[Region] [varchar](50) NULL,
	[Business_Units_ID] [varchar](255) NULL,
	[Business_Unit_Name] [varchar](255) NULL,
	[Authorisation_Group_ID] [int] NULL,
	[Authorisation_Group_Name] [varchar](21) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [pk_POP6_User] PRIMARY KEY CLUSTERED 
(
	[User_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_POP6_User] ADD  CONSTRAINT [DF_Dim_POP6_User_Create_Time]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_POP6_User] ADD  CONSTRAINT [DF_Dim_POP6_User_Update_Time]  DEFAULT (getdate()) FOR [Update_Time]
GO
