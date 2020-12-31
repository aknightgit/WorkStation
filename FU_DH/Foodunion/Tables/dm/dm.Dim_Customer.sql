USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Customer](
	[Super_ID] [bigint] NOT NULL,
	[WX_Union_ID] [varchar](500) NULL,
	[WX_Open_ID] [varchar](500) NULL,
	[Mobile_Phone] [varchar](20) NOT NULL,
	[Mobile_Phone_2] [varchar](20) NULL,
	[First_Name] [varchar](500) NULL,
	[Last_Name] [varchar](500) NULL,
	[Full_Name] [varchar](500) NULL,
	[Nick_Name] [varchar](500) NULL,
	[Source] [varchar](500) NULL,
	[Status] [varchar](500) NULL,
	[Gender] [varchar](10) NULL,
	[Birth_Date] [datetime] NULL,
	[Nationality] [varchar](10) NULL,
	[Province] [varchar](500) NULL,
	[City] [varchar](500) NULL,
	[Area] [varchar](500) NULL,
	[Address] [varchar](500) NULL,
	[ZipCode] [varchar](10) NULL,
	[Email] [varchar](500) NULL,
	[QQ] [varchar](500) NULL,
	[Is_Registered] [bit] NULL,
	[Register_Platform] [varchar](500) NULL,
	[Platform_Member_ID] [bigint] NULL,
	[Register_Date] [datetime] NULL,
	[FirstOrderPlatform] [varchar](500) NULL,
	[FirstOrderDate] [date] NULL,
	[TotalOrderCnt] [int] NULL,
	[Comments] [varchar](max) NULL,
	[FirstContactDate] [date] NULL,
	[Vip_Level] [varchar](500) NULL,
	[Vip_Expiry_Date] [date] NULL,
	[LastOrderPlatform] [varchar](500) NULL,
	[LastOrderDate] [date] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [varchar](500) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](500) NULL,
 CONSTRAINT [PK_Dim_Customer_6517_2158] PRIMARY KEY CLUSTERED 
(
	[Super_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [uk_mobile_phone] UNIQUE NONCLUSTERED 
(
	[Mobile_Phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Customer] ADD  CONSTRAINT [DF__Dim_Custo__Creat__587CF5B9]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Customer] ADD  CONSTRAINT [DF__Dim_Custo__Updat__597119F2]  DEFAULT (getdate()) FOR [Update_Time]
GO
