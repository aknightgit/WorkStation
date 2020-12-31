USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_O2O_wx_ApplyData](
	[sp_num] [varchar](100) NOT NULL,
	[item_id] [int] NOT NULL,
	[k] [varchar](100) NOT NULL,
	[v] [varchar](1024) NOT NULL,
	[Create_time] [datetime] NULL,
	[Update_time] [datetime] NULL,
	[Create_By] [varchar](78) NOT NULL,
	[Update_By] [varchar](78) NOT NULL,
 CONSTRAINT [PK_Fct_O2O_wx_ApplyData] PRIMARY KEY CLUSTERED 
(
	[sp_num] ASC,
	[item_id] ASC,
	[k] ASC,
	[v] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
