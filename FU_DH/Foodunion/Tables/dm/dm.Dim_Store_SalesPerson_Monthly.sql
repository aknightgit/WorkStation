USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Store_SalesPerson_Monthly](
	[Monthkey] [int] NOT NULL,
	[Channel] [varchar](20) NOT NULL,
	[Store_ID] [varchar](100) NOT NULL,
	[Store_Code] [varchar](100) NOT NULL,
	[Sales_Person] [varchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Monthkey] ASC,
	[Channel] ASC,
	[Store_ID] ASC,
	[Store_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Store_SalesPerson_Monthly] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Store_SalesPerson_Monthly] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
