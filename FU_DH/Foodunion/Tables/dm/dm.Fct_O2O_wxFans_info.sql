USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_O2O_wxFans_info](
	[id] [varchar](64) NOT NULL,
	[mp_id] [varchar](64) NOT NULL,
	[app_id] [varchar](64) NULL,
	[member_id] [varchar](64) NOT NULL,
	[union_id] [varchar](64) NULL,
	[open_id] [varchar](64) NULL,
	[nick_name] [varchar](64) NULL,
	[head_img_url] [varchar](256) NULL,
	[gender] [tinyint] NULL,
	[city] [varchar](64) NULL,
	[province] [varchar](64) NULL,
	[country] [varchar](64) NULL,
	[language] [varchar](64) NULL,
	[subscribe] [tinyint] NULL,
	[subscribe_time] [datetime] NULL,
	[subscribe_scene] [varchar](32) NULL,
	[qr_scene] [varchar](32) NULL,
	[qr_scene_str] [varchar](64) NULL,
	[remark] [varchar](64) NULL,
	[group_id] [int] NULL,
	[tagid_list] [varchar](512) NULL,
	[whole_fans_info_str] [varchar](2048) NULL,
	[scene_qrcode_id] [varchar](64) NOT NULL,
	[create_time] [datetime] NULL,
	[update_time] [datetime] NULL,
	[Create_By] [varchar](78) NOT NULL,
	[Update_By] [varchar](78) NOT NULL,
 CONSTRAINT [PK_Fct_O2O_wxFans_info] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
