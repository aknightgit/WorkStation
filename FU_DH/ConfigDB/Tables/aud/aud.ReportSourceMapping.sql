USE [ConfigDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[ReportSourceMapping](
	[Data_Source_ID] [int] NOT NULL,
	[Report_Name] [varchar](100) NULL,
	[Subject_Area] [varchar](100) NULL,
	[Data_Source_Name] [varchar](100) NULL,
	[Load_Frequency] [varchar](100) NULL,
	[Source_System] [varchar](100) NULL,
	[Load_Period] [varchar](100) NULL,
	[Ready_Time] [varchar](100) NULL,
	[Load_Method] [varchar](100) NULL,
	[Maintainer] [varchar](100) NULL,
	[Data_Owner] [varchar](100) NULL,
	[Assignment] [varchar](100) NULL,
	[Data_Sample] [varchar](100) NULL,
	[Comments] [varchar](1000) NULL,
	[Is_Enabled] [bit] NULL,
	[Load_Job_Name] [varchar](100) NULL,
	[Last_Run_Time] [datetime] NULL,
	[Last_Load_File] [varchar](200) NULL,
	[Up_to_Date] [varchar](100) NULL,
	[Update_by] [varchar](100) NULL,
	[Update_datetime] [datetime] NULL,
 CONSTRAINT [pk_source_id] PRIMARY KEY CLUSTERED 
(
	[Data_Source_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
