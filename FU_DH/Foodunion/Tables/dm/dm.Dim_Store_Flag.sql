USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Store_Flag](
	[Store_ID] [varchar](50) NOT NULL,
	[Account_Store_Code] [varchar](50) NOT NULL,
	[FIRST_SALES_DATE_AMBIENT] [nvarchar](200) NULL,
	[FIRST_SALES_DATE_Fresh] [nvarchar](200) NULL,
	[FIRST_SALES_DATE] [nvarchar](200) NULL,
	[FIRST_SALES_DATE_BOTH] [nvarchar](200) NULL,
	[Star_Store] [nvarchar](100) NULL,
	[Target_Store] [nvarchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Dim_Store_Flg] PRIMARY KEY CLUSTERED 
(
	[Store_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Store_Flag] ADD  CONSTRAINT [DF_Dim_Store_Flg_Create_Time]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Store_Flag] ADD  CONSTRAINT [DF_Dim_Store_Flg_Update_Time]  DEFAULT (getdate()) FOR [Update_Time]
GO
