USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[Sales_销售达成日报](
	[Date] [date] NOT NULL,
	[Territory] [varchar](100) NOT NULL,
	[Sales] [varchar](100) NOT NULL,
	[Month] [int] NOT NULL,
	[TargetAmount] [decimal](18, 2) NULL,
	[ActualAmount] [decimal](18, 2) NULL,
	[AchPct] [decimal](5, 4) NULL,
	[AchPctStr] [varchar](100) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Date] ASC,
	[Sales] ASC,
	[Month] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [rpt].[Sales_销售达成日报] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
