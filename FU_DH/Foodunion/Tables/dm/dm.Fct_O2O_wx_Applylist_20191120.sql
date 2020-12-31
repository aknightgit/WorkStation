USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_O2O_wx_Applylist_20191120](
	[sp_num] [varchar](100) NOT NULL,
	[spname] [varchar](100) NULL,
	[apply_name] [varchar](100) NULL,
	[apply_org] [varchar](100) NULL,
	[approval_name] [varchar](200) NULL,
	[notify_name] [varchar](200) NULL,
	[sp_status] [varchar](100) NULL,
	[mediaids] [varchar](max) NULL,
	[apply_time] [varchar](100) NULL,
	[apply_user_id] [varchar](100) NULL,
	[Create_time] [datetime] NULL,
	[Create_By] [varchar](78) NOT NULL,
	[Update_time] [datetime] NULL,
	[Update_By] [varchar](78) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
