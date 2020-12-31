USE [Foodunion]
GO
ALTER TABLE [dm].[Fct_KAStore_SalesTarget_Monthly] DROP CONSTRAINT [DF__Fct_KASto__Updat__4FC7B427]
GO
ALTER TABLE [dm].[Fct_KAStore_SalesTarget_Monthly] DROP CONSTRAINT [DF__Fct_KASto__Creat__4ED38FEE]
GO
DROP TABLE [dm].[Fct_KAStore_SalesTarget_Monthly]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_KAStore_SalesTarget_Monthly](
	[Monthkey] [int] NOT NULL,
	[Channel] [nvarchar](50) NOT NULL,
	[Store_ID] [nvarchar](50) NOT NULL,
	[Store_Code] [nvarchar](50) NULL,
	[Store_Name] [nvarchar](100) NULL,
	[Ambient_Sales_Target] [decimal](20, 8) NULL,
	[Fresh_Sales_Target] [decimal](20, 8) NULL,
	[Sales_Target] [decimal](20, 8) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_KAStore_SalesTarget_Monthly] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_KAStore_SalesTarget_Monthly] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
