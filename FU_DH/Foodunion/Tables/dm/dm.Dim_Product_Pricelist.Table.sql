USE [Foodunion]
GO
ALTER TABLE [dm].[Dim_Product_Pricelist] DROP CONSTRAINT [DF__Dim_Produ__Updat__477C86E9]
GO
ALTER TABLE [dm].[Dim_Product_Pricelist] DROP CONSTRAINT [DF__Dim_Produ__Creat__468862B0]
GO
DROP TABLE [dm].[Dim_Product_Pricelist]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Product_Pricelist](
	[Price_ID] [int] IDENTITY(1,1) NOT NULL,
	[Price_List_No] [varchar](50) NULL,
	[Price_List_Name] [varchar](100) NULL,
	[Sale_ORG_Name] [varchar](100) NULL,
	[SKU_ID] [varchar](50) NULL,
	[Sale_Unit] [varchar](50) NULL,
	[SKU_Price] [decimal](18, 9) NULL,
	[Base_Unit] [varchar](50) NULL,
	[SKU_Base_Price] [decimal](18, 9) NULL,
	[Effective_Date] [datetime] NULL,
	[Expiry_Date] [datetime] NULL,
	[Is_Current] [bit] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Price_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Product_Pricelist] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Product_Pricelist] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
