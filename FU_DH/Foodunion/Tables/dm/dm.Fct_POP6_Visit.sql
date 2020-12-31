USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_POP6_Visit](
	[Visit_ID] [int] NOT NULL,
	[Visit_Date] [date] NOT NULL,
	[DateKey] [int] NOT NULL,
	[POP_ID] [int] NOT NULL,
	[User_ID] [int] NOT NULL,
	[Visit_Type] [varchar](50) NULL,
	[Check_In_Date_Time] [datetime] NULL,
	[Check_In_Longitude] [varchar](255) NULL,
	[Check_In_Latitude] [varchar](255) NULL,
	[Check_In_Photo] [varchar](1000) NULL,
	[Check_Out_Date_Time] [datetime] NULL,
	[Check_Out_Longitude] [varchar](255) NULL,
	[Check_Out_Latitude] [varchar](255) NULL,
	[Check_Out_Photo] [varchar](1000) NULL,
	[Planned_Visit] [int] NULL,
	[Cancelled_Visit] [int] NULL,
	[Cancellation_Reason] [varchar](255) NULL,
	[Cancellation_Note] [varchar](255) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
PRIMARY KEY CLUSTERED 
(
	[Visit_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_POP6_Visit] ADD  CONSTRAINT [DF_Fct_POP6_Visit_Create_Time]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_POP6_Visit] ADD  CONSTRAINT [DF_Fct_POP6_Visit_Update_Time]  DEFAULT (getdate()) FOR [Update_Time]
GO
