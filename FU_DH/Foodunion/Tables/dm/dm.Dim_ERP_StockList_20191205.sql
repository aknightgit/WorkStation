USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_ERP_StockList_20191205](
	[Stock_ID] [varchar](100) NOT NULL,
	[Stock_Code] [varchar](100) NULL,
	[Allow_Lock] [bit] NULL,
	[Stock_Address] [varchar](100) NULL,
	[Stock_Name] [varchar](100) NULL,
	[Stock_Name_EN] [varchar](200) NULL,
	[Use_Org] [varchar](100) NULL,
	[Status] [varchar](100) NULL,
	[Property] [varchar](100) NULL,
	[Stock_Group] [varchar](100) NULL,
	[Stock_Group_Desc] [varchar](100) NULL,
	[Stock_Org] [varchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
