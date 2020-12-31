USE [Foodunion]
GO
DROP TABLE [dm].[Fct_YH_Sales_KA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Sales_KA](
	[TMonth] [varchar](12) NULL,
	[Product_Sort] [nvarchar](50) NOT NULL,
	[Sales] [decimal](38, 6) NULL,
	[TargetSales] [decimal](38, 6) NULL,
	[Target_Achievement] [decimal](38, 6) NULL
) ON [PRIMARY]
GO
