USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Calendar_Month](
	[Monthkey] [bigint] NOT NULL,
	[Year] [smallint] NOT NULL,
	[Month] [tinyint] NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[Month_Name] [varchar](9) NOT NULL,
	[Month_Name_Short] [varchar](9) NOT NULL,
	[Start_of_Month] [date] NOT NULL,
	[End_of_Month] [date] NOT NULL,
	[Days_in_Month] [tinyint] NOT NULL,
	[Previous_Month] [bigint] NOT NULL,
	[Is_Past] [bit] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Dim_Calendar_Month] PRIMARY KEY CLUSTERED 
(
	[Monthkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
