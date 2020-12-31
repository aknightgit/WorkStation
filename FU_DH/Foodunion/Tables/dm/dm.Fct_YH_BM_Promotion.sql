USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_BM_Promotion](
	[Supplier_ID] [nvarchar](255) NULL,
	[Supplier_NM] [nvarchar](255) NULL,
	[SKU_ID] [nvarchar](255) NULL,
	[Bar_CD] [nvarchar](255) NULL,
	[SKU_NM] [nvarchar](200) NOT NULL,
	[Unit] [nvarchar](255) NULL,
	[Big_class_CD] [nvarchar](255) NULL,
	[Big_class_NM] [nvarchar](255) NULL,
	[Mid_Class_CD] [nvarchar](255) NULL,
	[Mid_Class_NM] [nvarchar](255) NULL,
	[Sales_AMT] [decimal](18, 6) NULL,
	[Activity] [nvarchar](255) NULL,
	[Activity_Date] [nvarchar](255) NULL,
	[Region] [nvarchar](255) NULL,
	[Start_Date] [date] NOT NULL,
	[End_Date] [date] NOT NULL,
	[Type] [nvarchar](200) NOT NULL,
	[Promotition] [nvarchar](200) NOT NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_YH_BM_Promotion] PRIMARY KEY CLUSTERED 
(
	[Start_Date] ASC,
	[End_Date] ASC,
	[Promotition] ASC,
	[Type] ASC,
	[SKU_NM] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
