USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_O2O_wxFans_event_record](
	[id] [varchar](64) NOT NULL,
	[mp_id] [varchar](64) NOT NULL,
	[app_id] [varchar](64) NOT NULL,
	[open_id] [varchar](256) NOT NULL,
	[event_name] [varchar](32) NULL,
	[event_key] [varchar](255) NULL,
	[event_msg] [varchar](2048) NULL,
	[event_create_time] [datetime] NULL,
	[in_day] [int] NOT NULL,
	[create_time] [datetime] NOT NULL,
	[Create_By] [varchar](78) NOT NULL,
	[Update_By] [varchar](78) NOT NULL,
 CONSTRAINT [PK_Fct_O2O_wxFans_event_record] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
