USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[O2O_Inventory_Detail_FOC_LOG_20191219](
	[sp_num] [varchar](100) NOT NULL,
	[Record_Generate_Date] [varchar](30) NOT NULL,
	[Create_time] [datetime] NULL,
	[Update_time] [datetime] NULL,
	[Create_By] [varchar](78) NOT NULL,
	[Update_By] [varchar](78) NOT NULL
) ON [PRIMARY]
GO
