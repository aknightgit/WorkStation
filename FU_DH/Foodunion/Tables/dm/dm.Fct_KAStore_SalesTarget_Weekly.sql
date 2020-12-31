USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_KAStore_SalesTarget_Weekly](
	[Yearkey] [int] NOT NULL,
	[Week_Year_NBR] [int] NOT NULL,
	[Start_Date] [int] NOT NULL,
	[End_Date] [int] NOT NULL,
	[Channel] [nvarchar](50) NOT NULL,
	[SalesTerritory] [nvarchar](50) NULL,
	[Area] [nvarchar](50) NOT NULL,
	[Channel_ID] [nvarchar](50) NOT NULL,
	[Store_ID] [nvarchar](50) NOT NULL,
	[Store_Code] [nvarchar](50) NULL,
	[Store_Name] [nvarchar](100) NULL,
	[Ambient_Sales_Target] [decimal](20, 8) NULL,
	[Fresh_Sales_Target] [decimal](20, 8) NULL,
	[Sales_Target] [decimal](20, 8) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_KAStore_SalesTarget_Weekly] PRIMARY KEY CLUSTERED 
(
	[Yearkey] ASC,
	[Week_Year_NBR] ASC,
	[Area] ASC,
	[Channel_ID] ASC,
	[Store_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_KAStore_SalesTarget_Weekly] ADD  CONSTRAINT [DF_Fct_KAStore_SalesTarget_Weekly_CreateTime]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_KAStore_SalesTarget_Weekly] ADD  CONSTRAINT [DF_Fct_KAStore_SalesTarget_Weekly_UpdateTime]  DEFAULT (getdate()) FOR [Update_Time]
GO
