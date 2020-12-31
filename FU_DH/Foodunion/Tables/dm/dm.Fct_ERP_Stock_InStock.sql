USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Stock_InStock](
	[InStock_ID] [int] NOT NULL,
	[Datekey] [int] NOT NULL,
	[Bill_Type] [varchar](100) NULL,
	[Bill_No] [varchar](100) NOT NULL,
	[Date] [datetime] NOT NULL,
	[Stock_Org] [varchar](100) NULL,
	[Purchase_Org] [varchar](100) NULL,
	[Stock_Dept] [varchar](100) NULL,
	[Document_Status] [varchar](100) NULL,
	[Confirm_Status] [varchar](100) NULL,
	[Business_Type] [varchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[InStock_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_InStock] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_InStock] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
