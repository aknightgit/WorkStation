USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_DCInventory_Daily](
	[Datekey] [bigint] NOT NULL,
	[SKU_ID] [nvarchar](50) NOT NULL,
	[SKU_Code] [nvarchar](50) NOT NULL,
	[Scale] [nvarchar](50) NULL,
	[Unit] [nvarchar](50) NULL,
	[Produce_Date] [date] NULL,
	[Expiry_Date] [date] NOT NULL,
	[Remain_Days] [int] NULL,
	[Inventory_QTY] [int] NULL,
	[Inbound_QTY] [int] NULL,
	[Outbound_QTY] [int] NULL,
	[NetChange_QTY] [int] NULL,
	[Sale_Days] [int] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_DCInventory_Daily] PRIMARY KEY CLUSTERED 
(
	[Datekey] ASC,
	[SKU_ID] ASC,
	[SKU_Code] ASC,
	[Expiry_Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
