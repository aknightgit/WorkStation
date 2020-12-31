USE [Foodunion]
GO
DROP TABLE [dm].[Fct_O2O_wx_ApplyData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_O2O_wx_ApplyData](
	[sp_num] [varchar](100) NOT NULL,
	[item_id] [int] NOT NULL,
	[k] [varchar](100) NOT NULL,
	[v] [varchar](1024) NULL,
	[Create_time] [datetime] NULL,
	[Update_time] [datetime] NULL,
	[Create_By] [varchar](78) NOT NULL,
	[Update_By] [varchar](78) NOT NULL
) ON [PRIMARY]
GO
