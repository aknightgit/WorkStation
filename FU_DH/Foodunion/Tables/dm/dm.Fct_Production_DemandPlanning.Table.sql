USE [Foodunion]
GO
DROP TABLE [dm].[Fct_Production_DemandPlanning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Production_DemandPlanning](
	[Year] [varchar](50) NULL,
	[Month] [varchar](50) NULL,
	[Month_Str] [varchar](50) NULL,
	[Channel] [varchar](50) NULL,
	[SKU_ID] [varchar](50) NULL,
	[SKU_Name] [varchar](256) NULL,
	[Item] [varchar](100) NULL,
	[volume] [decimal](18, 5) NULL,
	[NetWeight] [decimal](18, 5) NULL,
	[Price] [decimal](18, 5) NULL,
	[Value] [decimal](18, 5) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
