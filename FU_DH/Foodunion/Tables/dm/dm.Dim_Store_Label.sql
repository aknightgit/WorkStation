USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Store_Label](
	[ID] [bigint] NOT NULL,
	[Store_ID] [varchar](50) NOT NULL,
	[Account_Store_Code] [varchar](50) NOT NULL,
	[Store_Name] [nvarchar](100) NULL,
	[Level_Code] [nvarchar](100) NULL,
	[MD] [nvarchar](100) NULL,
	[Is_Current] [bit] NOT NULL,
	[Effective_Date] [date] NOT NULL,
	[Expiry_Date] [date] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Dim_Store_Label8] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Dim_Store_Label] UNIQUE NONCLUSTERED 
(
	[Store_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Store_Label] ADD  DEFAULT ('1900-1-1') FOR [Effective_Date]
GO
ALTER TABLE [dm].[Dim_Store_Label] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Store_Label] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
