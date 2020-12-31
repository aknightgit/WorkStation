USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Stock_TransferIn](
	[TransID] [varchar](100) NOT NULL,
	[Datekey] [int] NOT NULL,
	[Bill_No] [varchar](100) NOT NULL,
	[Date] [datetime] NOT NULL,
	[Stock_Org] [varchar](100) NULL,
	[Bill_Type] [varchar](100) NULL,
	[Transfer_Biz_Type] [varchar](100) NULL,
	[Transfer_Direct] [varchar](100) NULL,
	[Biz_Type] [varchar](100) NULL,
	[Document_Status] [varchar](100) NULL,
	[Bill_Create_Date] [datetime] NULL,
	[Extrange_Rate] [decimal](18, 9) NULL,
	[Tax_Include] [bit] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[TransID] ASC,
	[Datekey] ASC,
	[Bill_No] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_TransferIn] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_TransferIn] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
