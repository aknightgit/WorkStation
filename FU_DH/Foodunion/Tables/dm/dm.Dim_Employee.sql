USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Employee](
	[Employee_ID] [bigint] NOT NULL,
	[Employee_No] [nvarchar](100) NOT NULL,
	[Name] [nvarchar](100) NULL,
	[English_Name] [nvarchar](100) NULL,
	[Nick_Name] [nvarchar](100) NULL,
	[Gender] [nvarchar](10) NULL,
	[UserID_Fxxk] [nvarchar](100) NULL,
	[LeaderID] [nvarchar](100) NULL,
	[Leader_Name] [varchar](200) NULL,
	[Department] [nvarchar](100) NULL,
	[Employee_Role] [nvarchar](100) NULL,
	[Region] [nvarchar](100) NULL,
	[Mobile] [nvarchar](11) NULL,
	[Email] [nvarchar](100) NULL,
	[Join_Date] [date] NULL,
	[Is_Active] [bit] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK__Dim_Empl__CF9024443D416F77_0E1E] PRIMARY KEY CLUSTERED 
(
	[Employee_ID] ASC,
	[Employee_No] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Employee] ADD  CONSTRAINT [df_Dim_Employee_Is_Active]  DEFAULT ((1)) FOR [Is_Active]
GO
ALTER TABLE [dm].[Dim_Employee] ADD  CONSTRAINT [df_Dim_Employee_Create_Time]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Employee] ADD  CONSTRAINT [df_Dim_Employee_Update_Time]  DEFAULT (getdate()) FOR [Update_Time]
GO
