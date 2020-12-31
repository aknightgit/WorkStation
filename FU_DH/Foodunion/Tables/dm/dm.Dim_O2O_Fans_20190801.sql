﻿USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_O2O_Fans_20190801](
	[Fan_id] [varchar](64) NOT NULL,
	[Brand] [varchar](15) NULL,
	[app_id] [varchar](64) NULL,
	[union_id] [varchar](64) NULL,
	[open_id] [varchar](64) NULL,
	[nick_name] [varchar](64) NULL,
	[gender] [varchar](7) NOT NULL,
	[city] [varchar](64) NULL,
	[province] [varchar](64) NULL,
	[country] [varchar](64) NULL,
	[subscribe] [tinyint] NULL,
	[subscribe_time] [datetime] NULL,
	[subscribe_scene] [varchar](32) NULL,
	[qr_scene] [varchar](32) NULL,
	[qr_scene_str] [varchar](64) NULL,
	[scene_qrcode_str] [varchar](8000) NULL,
	[scene_in_day] [int] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
