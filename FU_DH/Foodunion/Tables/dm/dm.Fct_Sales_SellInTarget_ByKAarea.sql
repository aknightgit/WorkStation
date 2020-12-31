USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_SellInTarget_ByKAarea](
	[Monthkey] [int] NOT NULL,
	[KA] [varchar](20) NOT NULL,
	[Area] [nvarchar](50) NOT NULL,
	[Channel_ID] [smallint] NULL,
	[TargetAmt] [decimal](18, 2) NULL,
	[TargetAmt_Ambient] [decimal](18, 2) NULL,
	[TargetAmt_Fresh] [decimal](18, 2) NULL,
	[TargetAmt_KATotal] [decimal](18, 2) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Monthkey] ASC,
	[KA] ASC,
	[Area] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_Sales_SellInTarget_ByKAarea] ADD  CONSTRAINT [df_Fct_Sales_SellInTarget_ByKAarea_Create_Time]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_Sales_SellInTarget_ByKAarea] ADD  CONSTRAINT [df_Fct_Sales_SellInTarget_ByKAarea_Update_Time]  DEFAULT (getdate()) FOR [Update_Time]
GO
