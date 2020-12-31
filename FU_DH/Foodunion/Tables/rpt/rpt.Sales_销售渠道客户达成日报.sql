USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[Sales_销售渠道客户达成日报](
	[Monthkey] [int] NOT NULL,
	[Channel] [varchar](100) NOT NULL,
	[Customer] [varchar](100) NOT NULL,
	[Sales] [varchar](100) NULL,
	[Data_Up_to] [varchar](100) NULL,
	[Is_UTD] [bit] NULL,
	[Row_Attr] [varchar](100) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Monthkey] ASC,
	[Channel] ASC,
	[Customer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
