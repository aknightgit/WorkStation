USE [Foodunion]
GO
ALTER TABLE [dm].[Dim_Product] DROP CONSTRAINT [DF__Dim_Produ__Updat__23B427BF]
GO
ALTER TABLE [dm].[Dim_Product] DROP CONSTRAINT [DF__Dim_Produ__Creat__22C00386]
GO
DROP TABLE [dm].[Dim_Product]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Product](
	[SKU_ID] [varchar](50) NOT NULL,
	[SKU_Name] [varchar](200) NOT NULL,
	[SKU_Name_CN] [nvarchar](200) NOT NULL,
	[Product_Type] [nvarchar](50) NULL,
	[Product_Sort] [nvarchar](50) NULL,
	[Product_Group] [nvarchar](100) NULL,
	[Product_Category] [nvarchar](100) NULL,
	[Product_Category_CN] [nvarchar](100) NULL,
	[Plan_Group] [nvarchar](100) NULL,
	[Bar_Code] [varchar](50) NULL,
	[Unified_Code] [nvarchar](100) NULL,
	[Unified_Name] [varchar](200) NULL,
	[Regulation_Name_CN] [nvarchar](100) NULL,
	[Target] [varchar](50) NULL,
	[Plant] [varchar](20) NULL,
	[Brand_Name] [nvarchar](50) NULL,
	[Brand_Name_CN] [nvarchar](50) NULL,
	[Brand_IP] [nvarchar](50) NULL,
	[Package_Category] [nvarchar](50) NULL,
	[Package] [nvarchar](50) NULL,
	[Sale_Scale] [nvarchar](100) NULL,
	[Sale_Unit_RSP] [decimal](19, 2) NULL,
	[Sale_Unit] [varchar](20) NULL,
	[Sale_Unit_CN] [nvarchar](20) NULL,
	[Sale_Unit_Weight_KG] [decimal](10, 3) NULL,
	[Sale_Unit_Volumn_L] [decimal](10, 3) NULL,
	[Base_Unit] [nvarchar](20) NULL,
	[Base_Unit_CN] [nvarchar](20) NULL,
	[Base_Unit_Weight_KG] [decimal](10, 3) NULL,
	[Base_Unit_Volumn_L] [decimal](10, 3) NULL,
	[Qty_BaseInSale] [smallint] NULL,
	[Qty_SaleInTray] [smallint] NULL,
	[Qty_BaseInTray] [smallint] NULL,
	[Qty_ExtendPcs] [smallint] NULL,
	[Produce_Unit] [varchar](20) NULL,
	[Flavor_Group] [nvarchar](100) NULL,
	[Flavor] [nvarchar](100) NULL,
	[Fat] [varchar](20) NULL,
	[Protein] [varchar](20) NULL,
	[Shelf_Life_D] [varchar](50) NULL,
	[Launch_Date] [datetime] NULL,
	[End_Date] [datetime] NULL,
	[Status] [nvarchar](100) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Dim_Product] PRIMARY KEY CLUSTERED 
(
	[SKU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_Product] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_Product] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
