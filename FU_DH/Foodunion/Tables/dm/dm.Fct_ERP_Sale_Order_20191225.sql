USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Sale_Order_20191225](
	[Sale_Order_ID] [varchar](100) NOT NULL,
	[Datekey] [int] NOT NULL,
	[Bill_No] [varchar](100) NOT NULL,
	[Bill_Type] [varchar](100) NULL,
	[Business_Type] [varchar](100) NULL,
	[Date] [datetime] NOT NULL,
	[Customer_Name] [varchar](200) NOT NULL,
	[Sale_Org] [varchar](200) NULL,
	[Sale_Dept] [varchar](200) NULL,
	[Document_Status] [varchar](100) NULL,
	[Close_Status] [varchar](100) NULL,
	[Cancel_Status] [varchar](100) NULL,
	[Note] [varchar](400) NULL,
	[Store_Name] [varchar](100) NULL,
	[Address] [varchar](400) NULL,
	[Mobile] [varchar](100) NULL,
	[Contact_Name] [varchar](100) NULL,
	[FOC_Type] [varchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
