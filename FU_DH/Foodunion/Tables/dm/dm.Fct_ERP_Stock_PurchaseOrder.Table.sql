USE [Foodunion]
GO
DROP TABLE [dm].[Fct_ERP_Stock_PurchaseOrder]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Stock_PurchaseOrder](
	[Datekey] [int] NOT NULL,
	[POOrder_ID] [varchar](100) NOT NULL,
	[Bill_No] [varchar](100) NULL,
	[Bill_Type] [varchar](100) NULL,
	[Purchase_Org] [varchar](100) NULL,
	[Puchase_Dept] [varchar](100) NULL,
	[Document_Status] [varchar](100) NULL,
	[Close_Status] [varchar](100) NULL,
	[Cancel_Status] [varchar](100) NULL,
	[Confirm_Status] [varchar](100) NULL,
	[Close_Date] [datetime] NULL,
	[Business_Type] [varchar](100) NULL,
	[Remarks] [varchar](512) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Datekey] ASC,
	[POOrder_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
