USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[Report_Users](
	[ID] [int] NOT NULL,
	[UserName] [varchar](100) NOT NULL,
	[Short] [varchar](100) NULL,
	[UPN] [varchar](100) NOT NULL,
	[Department] [varchar](100) NULL,
	[Territory] [varchar](100) NULL,
	[UserRole] [varchar](100) NOT NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [rpt].[Report_Users] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
