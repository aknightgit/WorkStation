USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Stock_MisdStock](
	[MisdStock_ID] [int] NOT NULL,
	[Bill_Type] [nvarchar](160) NULL,
	[Bill_No] [nvarchar](60) NULL,
	[DateKey] [int] NULL,
	[Stock_Org] [nvarchar](510) NULL,
	[Document_Status] [varchar](8) NULL,
	[Stock_Direct] [varchar](4) NULL,
	[Cancel_Status] [varchar](6) NULL,
	[Note] [nvarchar](510) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[MisdStock_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_MisdStock] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_MisdStock] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
