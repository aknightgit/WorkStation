USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Stock_OutStock](
	[OutStock_ID] [varchar](100) NOT NULL,
	[Datekey] [int] NOT NULL,
	[Bill_Type] [varchar](100) NULL,
	[Bill_No] [varchar](100) NOT NULL,
	[Date] [datetime] NULL,
	[Customer_ID] [int] NULL,
	[Channel_ID] [int] NULL,
	[Customer_Name] [varchar](100) NULL,
	[Stock_Org] [varchar](100) NULL,
	[Delivery_Dept] [varchar](100) NULL,
	[Sale_Org] [varchar](100) NULL,
	[Sale_Dept] [varchar](100) NULL,
	[Carriage_No] [varchar](100) NULL,
	[Document_Status] [varchar](100) NULL,
	[Cancel_Status] [varchar](100) NULL,
	[Business_Type] [varchar](100) NULL,
	[Ship_to] [varchar](50) NULL,
	[Receive_Contact] [varchar](100) NULL,
	[Receive_Address] [varchar](200) NULL,
	[Transfer_Biz_Type] [varchar](100) NULL,
	[Credit_Check_Result] [varchar](100) NULL,
	[Plan_Receive_Address] [varchar](200) NULL,
	[Note] [varchar](1024) NULL,
	[Sales_Man] [varchar](100) NULL,
	[SourceBillNo] [varchar](100) NULL,
	[SaleOrderNo] [varchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK__Fct_ERP___B538D47E231D2705_5508_14D2_9336_D774] PRIMARY KEY CLUSTERED 
(
	[OutStock_ID] ASC,
	[Datekey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_OutStock] ADD  CONSTRAINT [DF__Fct_ERP_S__Creat__0268428D]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_OutStock] ADD  CONSTRAINT [DF__Fct_ERP_S__Updat__035C66C6]  DEFAULT (getdate()) FOR [Update_Time]
GO
