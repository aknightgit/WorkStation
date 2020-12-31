USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Stock_ReturnStock](
	[ReturnStock_ID] [int] NOT NULL,
	[Bill_Type] [nvarchar](200) NULL,
	[Bill_No] [nvarchar](60) NULL,
	[Datekey] [int] NOT NULL,
	[Stock_Org] [nvarchar](510) NULL,
	[Stock_Dept] [nvarchar](510) NULL,
	[Document_Status] [varchar](50) NULL,
	[CANCEL_STATUS] [varchar](50) NULL,
	[Business_Type] [varchar](50) NULL,
	[Note] [nvarchar](510) NULL,
	[Channel_ID] [int] NULL,
	[Customer] [nvarchar](510) NULL,
	[Return_Reason] [nvarchar](510) NULL,
	[Receive_Address] [nvarchar](510) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK__Fct_ERP___3F83C49F351B37CA_31BC_029D] PRIMARY KEY CLUSTERED 
(
	[ReturnStock_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_ReturnStock] ADD  CONSTRAINT [DF__Fct_ERP_S__Creat__3E48226A]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_ReturnStock] ADD  CONSTRAINT [DF__Fct_ERP_S__Updat__3F3C46A3]  DEFAULT (getdate()) FOR [Update_Time]
GO
