USE [Foodunion]
GO
DROP TABLE [dw].[Fct_YH_BM_Promotion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dw].[Fct_YH_BM_Promotion](
	[Supplier_ID] [nvarchar](255) NULL,
	[Supplier_NM] [nvarchar](255) NULL,
	[SKU_ID] [nvarchar](255) NULL,
	[Bar_CD] [nvarchar](255) NULL,
	[SKU_NM] [nvarchar](255) NULL,
	[Unit] [nvarchar](255) NULL,
	[Big_class_CD] [nvarchar](255) NULL,
	[Big_class_NM] [nvarchar](255) NULL,
	[Mid_Class_CD] [nvarchar](255) NULL,
	[Mid_Class_NM] [nvarchar](255) NULL,
	[Sales_AMT] [decimal](18, 6) NULL,
	[Activity] [nvarchar](255) NULL,
	[Activity_Date] [nvarchar](255) NULL,
	[Region] [nvarchar](255) NULL,
	[Start_Date] [date] NULL,
	[End_Date] [date] NULL,
	[Type] [nvarchar](255) NULL,
	[Promotition] [nvarchar](255) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
