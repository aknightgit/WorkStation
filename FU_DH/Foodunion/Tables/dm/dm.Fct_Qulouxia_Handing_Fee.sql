USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_Handing_Fee](
	[Datekey] [bigint] NOT NULL,
	[SKU_ID] [nvarchar](20) NOT NULL,
	[SKU_Code] [nvarchar](20) NOT NULL,
	[SKU_Name] [nvarchar](200) NULL,
	[Batch_Number] [nvarchar](20) NOT NULL,
	[Unit] [nvarchar](200) NULL,
	[QTY] [float] NULL,
	[Single_Fee] [float] NULL,
	[Total_Fee] [float] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_Handing_Fee] PRIMARY KEY CLUSTERED 
(
	[Datekey] ASC,
	[SKU_ID] ASC,
	[SKU_Code] ASC,
	[Batch_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
