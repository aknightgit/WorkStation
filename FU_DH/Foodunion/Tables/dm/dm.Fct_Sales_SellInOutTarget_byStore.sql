USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_SellInOutTarget_byStore](
	[Monthkey] [bigint] NOT NULL,
	[SalesPerson] [varchar](100) NULL,
	[Mobile] [varchar](11) NULL,
	[Store_ID] [varchar](100) NOT NULL,
	[Store_Code] [varchar](100) NOT NULL,
	[SellIn_TGT] [decimal](18, 5) NULL,
	[SellOut_TGT] [decimal](18, 5) NULL,
	[SellOut_TGT_A] [decimal](18, 5) NULL,
	[SellOut_TGT_F] [decimal](18, 5) NULL,
	[SellOut_TGTSKU_A] [smallint] NULL,
	[SellOut_TGTSKU_F] [smallint] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Monthkey] ASC,
	[Store_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_Sales_SellInOutTarget_byStore] ADD  CONSTRAINT [df_Fct_Sales_SellInOutTarget_byStore_Create_Time]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_Sales_SellInOutTarget_byStore] ADD  CONSTRAINT [df_Fct_Sales_SellInOutTarget_byStore_Update_Time]  DEFAULT (getdate()) FOR [Update_Time]
GO
