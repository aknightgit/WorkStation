USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_BoxSlot_Charge](
	[DateKey] [bigint] NOT NULL,
	[Slot_Type] [nvarchar](200) NOT NULL,
	[Slot_Charge] [float] NULL,
	[Total_Widths] [float] NULL,
	[Total_Slot_Charge] [float] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_GoodsPassage_Charge] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC,
	[Slot_Type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_Qulouxia_BoxSlot_Charge] ADD  CONSTRAINT [DF_Fct_Qulouxia_GoodsPassage_Charge_Create_Time]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_Qulouxia_BoxSlot_Charge] ADD  CONSTRAINT [DF_Fct_Qulouxia_GoodsPassage_Charge_Update_Time]  DEFAULT (getdate()) FOR [Update_Time]
GO
