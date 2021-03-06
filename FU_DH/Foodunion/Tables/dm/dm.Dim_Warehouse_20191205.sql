﻿USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Warehouse_20191205](
	[ID] [int] NOT NULL,
	[WHS_ID] [varchar](50) NOT NULL,
	[Warehouse_Name] [varchar](200) NULL,
	[Warehouse_Name_EN] [varchar](200) NULL,
	[Org_Group] [varchar](100) NULL,
	[Province] [varchar](100) NULL,
	[City] [varchar](100) NULL,
	[Warehouse_Type] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
