USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Channel_hist](
	[Monthkey] [int] NOT NULL,
	[Channel_ID] [int] NOT NULL,
	[Channel_Name] [nvarchar](100) NOT NULL,
	[Channel_Name_CN] [nvarchar](100) NOT NULL,
	[ERP_Customer_ID] [nvarchar](100) NULL,
	[ERP_Customer_Name] [nvarchar](100) NULL,
	[Channel_Name_Display] [nvarchar](100) NULL,
	[Channel_Name_Short] [nvarchar](100) NULL,
	[Channel_Type] [nvarchar](100) NULL,
	[Channel_Category] [nvarchar](100) NULL,
	[Channel_Handler] [nvarchar](100) NULL,
	[Team] [nvarchar](100) NULL,
	[Team_Handler] [nvarchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Dim_Channel_hist] PRIMARY KEY CLUSTERED 
(
	[Monthkey] ASC,
	[Channel_ID] ASC,
	[Channel_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [u_channel_hist] UNIQUE NONCLUSTERED 
(
	[Monthkey] ASC,
	[Channel_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Channel_hist] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Channel_hist] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
