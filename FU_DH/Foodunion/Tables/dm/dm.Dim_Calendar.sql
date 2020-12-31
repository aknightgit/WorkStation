USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Calendar](
	[Datekey] [bigint] NOT NULL,
	[Date] [datetime] NOT NULL,
	[Date_Str] [varchar](10) NOT NULL,
	[Year] [smallint] NOT NULL,
	[Month] [tinyint] NOT NULL,
	[Monthkey] [bigint] NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[Day_of_Year] [smallint] NOT NULL,
	[Day_of_Month] [tinyint] NOT NULL,
	[Day_of_Week] [tinyint] NOT NULL,
	[Week_Day_Name] [varchar](9) NOT NULL,
	[Week_Day_Name_CN] [varchar](9) NOT NULL,
	[Week_of_Month] [tinyint] NOT NULL,
	[Week_of_Quarter] [tinyint] NOT NULL,
	[Week_of_Year] [tinyint] NOT NULL,
	[Week_of_Year_Str] [varchar](10) NOT NULL,
	[Week_Nature_Str] [varchar](20) NOT NULL,
	[Start_of_Week] [date] NOT NULL,
	[End_of_Week] [date] NOT NULL,
	[Month_Name] [varchar](9) NOT NULL,
	[Month_Name_Short] [varchar](9) NOT NULL,
	[Start_of_Month] [date] NOT NULL,
	[End_of_Month] [date] NOT NULL,
	[Start_of_Quarter] [date] NOT NULL,
	[End_of_Quarter] [date] NOT NULL,
	[Start_of_Year] [date] NOT NULL,
	[End_of_Year] [date] NOT NULL,
	[Is_Holiday] [bit] NOT NULL,
	[Is_Weekend] [bit] NOT NULL,
	[Is_Past] [bit] NOT NULL,
	[Days_in_Month] [tinyint] NOT NULL,
	[Previous_Month] [bigint] NOT NULL,
	[Previous_Week] [int] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Dim_Calendar_76B4] PRIMARY KEY CLUSTERED 
(
	[Datekey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
