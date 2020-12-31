USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Stock_Inventory](
	[Datekey] [int] NOT NULL,
	[Stock_ID] [varchar](100) NOT NULL,
	[Stock_Name] [varchar](100) NOT NULL,
	[Stock_Org] [varchar](100) NULL,
	[Stock_Status] [varchar](10) NOT NULL,
	[SKU_ID] [varchar](100) NOT NULL,
	[SKU_Name] [varchar](100) NULL,
	[SKU_Name_EN] [varchar](200) NULL,
	[LOT] [varchar](100) NOT NULL,
	[Produce_Date] [date] NOT NULL,
	[Expiry_Date] [date] NULL,
	[Stock_Unit] [varchar](10) NULL,
	[Stock_QTY] [decimal](18, 9) NULL,
	[Lock_QTY] [decimal](18, 9) NULL,
	[Base_Unit] [varchar](10) NULL,
	[Base_QTY] [decimal](18, 9) NULL,
	[Sale_Unit] [varchar](10) NULL,
	[Sale_QTY] [decimal](18, 9) NULL,
	[IsEffective] [bit] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
	[Storaging_Date] [date] NULL,
 CONSTRAINT [PK_Fct_ERP_Stock_Inventory] PRIMARY KEY CLUSTERED 
(
	[Datekey] ASC,
	[Stock_ID] ASC,
	[SKU_ID] ASC,
	[LOT] ASC,
	[Stock_Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_Inventory] ADD  CONSTRAINT [DF__Fct_ERP_S__Creat__7F21C18E]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_Inventory] ADD  CONSTRAINT [DF__Fct_ERP_S__Updat__0015E5C7]  DEFAULT (getdate()) FOR [Update_Time]
GO
