USE [Foodunion]
GO
DROP TABLE [dm].[Dim_ERP_CustomerMapping_Missing]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_ERP_CustomerMapping_Missing](
	[Monthkey] [int] NOT NULL,
	[Customer_Name] [varchar](100) NOT NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [varchar](100) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](100) NULL
) ON [PRIMARY]
GO
