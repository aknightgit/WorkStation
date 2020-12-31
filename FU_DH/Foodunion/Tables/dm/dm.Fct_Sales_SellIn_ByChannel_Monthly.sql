USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_SellIn_ByChannel_Monthly](
	[Monthkey] [int] NOT NULL,
	[Datekey] [int] NOT NULL,
	[Customer_ID] [nvarchar](100) NOT NULL,
	[Customer_Name] [nvarchar](100) NULL,
	[Channel_ID] [int] NULL,
	[Channel_Type] [nvarchar](100) NULL,
	[Channel_Name_Short] [nvarchar](100) NULL,
	[Channel_FIN] [nvarchar](100) NULL,
	[SubChannel_FIN] [nvarchar](100) NULL,
	[出库单未税] [decimal](38, 9) NULL,
	[FOC未税] [decimal](38, 9) NULL,
	[调拨单金额] [decimal](38, 9) NULL,
	[退货单未税] [decimal](38, 9) NULL,
	[Net_Sales] [decimal](38, 9) NULL,
	[出库单含税] [decimal](38, 9) NULL,
	[FOC含税] [decimal](38, 9) NULL,
	[退货单含税] [decimal](38, 9) NULL,
	[Net_Sales_wTax] [decimal](18, 2) NULL,
	[出库单非FOC吨数] [decimal](38, 9) NULL,
	[FOC吨数] [decimal](38, 9) NULL,
	[调拨单吨数] [decimal](38, 9) NULL,
	[退货单吨数] [decimal](38, 9) NULL,
	[Create_time] [datetime] NOT NULL,
	[Create_By] [varchar](100) NULL,
	[Update_time] [datetime] NOT NULL,
	[Update_By] [varchar](100) NULL,
 CONSTRAINT [PK_Fct_Sales_SellIn_ByChannel_Monthly_B7CD] PRIMARY KEY CLUSTERED 
(
	[Monthkey] ASC,
	[Datekey] ASC,
	[Customer_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_Sales_SellIn_ByChannel_Monthly] ADD  CONSTRAINT [DF_Fct_Sales_SellIn_ByChannel_Monthly_Create_time]  DEFAULT (getdate()) FOR [Create_time]
GO
ALTER TABLE [dm].[Fct_Sales_SellIn_ByChannel_Monthly] ADD  CONSTRAINT [DF_Fct_Sales_SellIn_ByChannel_Monthly_Update_time]  DEFAULT (getdate()) FOR [Update_time]
GO
