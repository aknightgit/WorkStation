USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_ERP_CustomerList](
	[Customer_ID] [varchar](100) NOT NULL,
	[Customer_Name] [varchar](100) NULL,
	[Customer_Name_EN] [varchar](100) NULL,
	[Short_Name] [varchar](100) NULL,
	[ERP_Code] [varchar](100) NULL,
	[Province] [varchar](100) NULL,
	[City] [varchar](100) NULL,
	[lng] [varchar](100) NULL,
	[lat] [varchar](100) NULL,
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
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK__Dim_ERP___8CB286B9DC6C48BE_1028_BA0E_78D5_4925] PRIMARY KEY CLUSTERED 
(
	[Customer_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_ERP_CustomerList] ADD  CONSTRAINT [DF__Dim_ERP_C__Creat__361CF0BD]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_ERP_CustomerList] ADD  CONSTRAINT [DF__Dim_ERP_C__Updat__371114F6]  DEFAULT (getdate()) FOR [Update_Time]
GO
