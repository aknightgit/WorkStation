USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Store_Score_Card](
	[Calendar_DT] [nvarchar](8) NOT NULL,
	[Store_ID] [nvarchar](200) NOT NULL,
	[YH_Store_CD] [nvarchar](200) NULL,
	[Sales_AMT] [decimal](38, 6) NULL,
	[Sales_QTY] [decimal](38, 6) NULL,
	[Sales_AMT_LM] [decimal](38, 6) NULL,
	[Sales_QTY_LM] [decimal](38, 6) NULL,
	[Ranking_AMT_NBR] [bigint] NULL,
	[GR_MOM_AMT_PC] [decimal](38, 6) NULL,
	[GR_MOM_Qty_PC] [decimal](38, 6) NULL,
	[Ranking_GR_NBR] [bigint] NULL,
	[YH_Dairy_AMT] [nvarchar](200) NULL,
	[BM_Share_PC] [decimal](38, 6) NULL,
	[Ranking_Share_NBR] [bigint] NULL,
	[SALES_AMT_Score] [numeric](33, 6) NULL,
	[GR_Score] [numeric](33, 6) NULL,
	[Ranking_Share_Score] [numeric](33, 6) NULL,
	[Total_Score] [numeric](33, 6) NULL,
	[Total_Ranking] [bigint] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_YH_Store_Score_Card] PRIMARY KEY CLUSTERED 
(
	[Calendar_DT] ASC,
	[Store_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
