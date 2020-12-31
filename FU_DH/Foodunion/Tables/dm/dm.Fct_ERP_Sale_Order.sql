USE [Foodunion]
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
	[Channel_ID] [int] NULL,
	[Customer_Name] [varchar](200) NOT NULL,
	[Sale_Org] [varchar](200) NULL,
	[Sale_Dept] [varchar](200) NULL,
	[Document_Status] [varchar](100) NULL,
	[Close_Status] [varchar](100) NULL,
	[Cancel_Status] [varchar](100) NULL,
	[Note] [varchar](400) NULL,
	[Store_Name] [varchar](100) NULL,
	[Province] [varchar](100) NULL,
	[City] [varchar](100) NULL,
	[Address] [varchar](400) NULL,
	[Mobile] [varchar](100) NULL,
	[Contact_Name] [varchar](100) NULL,
	[FOC_Type] [varchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK__Fct_ERP___7333E8B5290346D7_CC31_0E97_31E0] PRIMARY KEY CLUSTERED 
(
	[Sale_Order_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Sale_Order] ADD  CONSTRAINT [DF__Fct_ERP_S__Creat__1471E42F]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Sale_Order] ADD  CONSTRAINT [DF__Fct_ERP_S__Updat__15660868]  DEFAULT (getdate()) FOR [Update_Time]
GO
