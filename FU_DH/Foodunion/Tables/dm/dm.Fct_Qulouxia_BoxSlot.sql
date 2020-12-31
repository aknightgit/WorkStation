USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_BoxSlot](
	[DateKey] [bigint] NOT NULL,
	[Store_ID] [nvarchar](20) NOT NULL,
	[Store_Code] [nvarchar](20) NULL,
	[Store_Name] [nvarchar](200) NULL,
	[Next_Day_Booking] [nvarchar](20) NULL,
	[SKU_ID] [nvarchar](20) NOT NULL,
	[SKU_Code] [nvarchar](20) NOT NULL,
	[SKU_Name] [nvarchar](200) NULL,
	[Category] [nvarchar](20) NULL,
	[Shelf_Life_D] [int] NOT NULL,
	[Slot_QTY] [int] NULL,
	[Single_Widths] [float] NULL,
	[Total_Widths] [float] NULL,
	[Is_FU] [nvarchar](20) NULL,
	[Slot_Type] [nvarchar](200) NULL,
	[Slot_Charge] [float] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_GoodsPassage] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC,
	[Store_ID] ASC,
	[SKU_ID] ASC,
	[SKU_Code] ASC,
	[Shelf_Life_D] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_Qulouxia_BoxSlot] ADD  CONSTRAINT [DF_Fct_Qulouxia_GoodsPassage_Create_Time]  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_Qulouxia_BoxSlot] ADD  CONSTRAINT [DF_Fct_Qulouxia_GoodsPassage_Update_Time]  DEFAULT (getdate()) FOR [Update_Time]
GO
