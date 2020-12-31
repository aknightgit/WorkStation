USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[Sales_ArchbySales_Daily_Report](
	[Datekey] [int] NOT NULL,
	[Sales] [varchar](100) NOT NULL,
	[Target_Amt] [decimal](18, 2) NULL,
	[Actual_Amt] [decimal](18, 2) NULL,
	[Achievement] [varchar](100) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Datekey] ASC,
	[Sales] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
