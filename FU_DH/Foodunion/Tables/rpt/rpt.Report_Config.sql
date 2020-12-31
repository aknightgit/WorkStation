USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[Report_Config](
	[Report_ID] [varchar](100) NOT NULL,
	[Report_Name] [varchar](100) NOT NULL,
	[Workspace] [varchar](100) NULL,
	[Dataset] [varchar](100) NULL,
	[Dataset_Workspace] [varchar](100) NULL,
	[IncreRefresh_StartDatekey] [varchar](100) NULL,
	[IncreRefresh_StartMonthkey] [varchar](100) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](100) NULL,
 CONSTRAINT [pk_report_config] PRIMARY KEY CLUSTERED 
(
	[Report_ID] ASC,
	[Report_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
