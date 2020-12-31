USE [Foodunion]
GO
ALTER TABLE [dm].[Dim_ERP_StockList] DROP CONSTRAINT [DF__Dim_ERP_S__Updat__1BBE003C]
GO
ALTER TABLE [dm].[Dim_ERP_StockList] DROP CONSTRAINT [DF__Dim_ERP_S__Creat__1AC9DC03]
GO
DROP TABLE [dm].[Dim_ERP_StockList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_ERP_StockList](
	[Stock_ID] [varchar](100) NOT NULL,
	[Stock_Code] [varchar](100) NULL,
	[Allow_Lock] [bit] NULL,
	[Stock_Address] [varchar](100) NULL,
	[Stock_Name] [varchar](100) NULL,
	[Stock_Name_EN] [varchar](200) NULL,
	[Use_Org] [varchar](100) NULL,
	[Stock_Org] [varchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Stock_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_ERP_StockList] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_ERP_StockList] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
