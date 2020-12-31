USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_ERP_Stock_TransferOutEntry](
	[TransID] [varchar](100) NOT NULL,
	[Sequence_ID] [varchar](100) NOT NULL,
	[SKU_ID] [varchar](100) NOT NULL,
	[LOT] [varchar](100) NULL,
	[LOT_Display] [varchar](100) NULL,
	[Source_Stock] [varchar](100) NULL,
	[Dest_Stock] [varchar](100) NULL,
	[Unit] [varchar](100) NULL,
	[QTY] [decimal](18, 9) NULL,
	[Base_Unit] [varchar](100) NULL,
	[Base_Unit_QTY] [decimal](18, 9) NULL,
	[Base_Unit_Price] [decimal](18, 9) NULL,
	[Amount] [decimal](18, 9) NULL,
	[Cost_Price] [decimal](18, 9) NULL,
	[Cost_Amount] [decimal](18, 9) NULL,
	[Produce_Date] [datetime] NULL,
	[Exipry_Date] [datetime] NULL,
	[Source_Stock_Status] [varchar](100) NULL,
	[DEST_Stock_Status] [varchar](100) NULL,
	[Note] [varchar](1024) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[TransID] ASC,
	[Sequence_ID] ASC,
	[SKU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_TransferOutEntry] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_ERP_Stock_TransferOutEntry] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
