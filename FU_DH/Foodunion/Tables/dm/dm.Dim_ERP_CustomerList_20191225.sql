USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_ERP_CustomerList_20191225](
	[Customer_ID] [varchar](100) NOT NULL,
	[Customer_Name] [varchar](100) NULL,
	[Customer_Name_EN] [varchar](100) NULL,
	[Short_Name] [varchar](100) NULL,
	[ERP_Code] [varchar](100) NULL,
	[Customer_Address] [varchar](200) NULL,
	[ZIP] [varchar](100) NULL,
	[TEL] [varchar](100) NULL,
	[FAX] [varchar](100) NULL,
	[Is_Credit_Check] [bit] NULL,
	[Tax_Rate] [decimal](18, 9) NULL,
	[Price_List_No] [varchar](100) NULL,
	[Discount_List_No] [varchar](100) NULL,
	[Use_Org] [varchar](100) NULL,
	[IsActive] [bit] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
