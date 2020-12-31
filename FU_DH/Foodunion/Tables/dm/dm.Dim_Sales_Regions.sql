USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Sales_Regions](
	[Region_ID] [smallint] NOT NULL,
	[Region] [varchar](100) NULL,
	[Region_Display] [varchar](100) NULL,
	[Director] [varchar](100) NULL,
	[Director_EN] [varchar](100) NULL,
	[In_Use] [bit] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Dim_Sales_Regions] PRIMARY KEY CLUSTERED 
(
	[Region_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Sales_Regions] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Sales_Regions] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
