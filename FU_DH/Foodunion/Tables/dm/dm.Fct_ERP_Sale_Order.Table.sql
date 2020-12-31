USE [Foodunion]
GO
ALTER TABLE [dm].[Fct_ERP_Sale_Order] DROP CONSTRAINT [DF__Fct_ERP_S__Updat__15660868]
GO
ALTER TABLE [dm].[Fct_ERP_Sale_Order] DROP CONSTRAINT [DF__Fct_ERP_S__Creat__1471E42F]
GO
DROP TABLE [dm].[Fct_ERP_Sale_Order]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Sale_Order](
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
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Sale_Order_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Sale_Order] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Sale_Order] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
