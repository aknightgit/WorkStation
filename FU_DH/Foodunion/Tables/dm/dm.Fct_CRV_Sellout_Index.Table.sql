USE [Foodunion]
GO
DROP TABLE [dm].[Fct_CRV_Sellout_Index]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_CRV_Sellout_Index](
	[Province] [nvarchar](100) NULL,
	[Sales_AMT] [decimal](20, 3) NULL
) ON [PRIMARY]
GO
