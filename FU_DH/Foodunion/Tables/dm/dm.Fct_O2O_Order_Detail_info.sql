USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_O2O_Order_Detail_info](
	[Order_ID] [varchar](64) NOT NULL,
	[Sub_Order] [varchar](255) NOT NULL,
	[Product_ID] [varchar](64) NULL,
	[Product_SKU_ID] [nvarchar](50) NULL,
	[Product_Name] [varchar](128) NULL,
	[is_gift] [tinyint] NULL,
	[SeqID] [bigint] NOT NULL,
	[SKU_ID] [nvarchar](4000) NULL,
	[SKU_Name_CN] [nvarchar](200) NULL,
	[QTY] [int] NULL,
	[Unit_Price] [decimal](18, 2) NULL,
	[Total_Price] [decimal](11, 2) NULL,
	[Unit_Weight_g] [decimal](15, 3) NULL,
	[Scale] [varchar](200) NULL,
	[SubscriptionType] [varchar](200) NULL,
	[pcs_cnt] [int] NULL,
	[delivery_cnt] [int] NULL,
	[Buyer_Messages] [varchar](256) NULL,
	[SKU_Desc] [varchar](255) NULL,
	[payment] [decimal](20, 10) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](1) NOT NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](1) NOT NULL,
 CONSTRAINT [PK_Fct_O2O_Order_Detail_info] PRIMARY KEY CLUSTERED 
(
	[Order_ID] ASC,
	[Sub_Order] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
