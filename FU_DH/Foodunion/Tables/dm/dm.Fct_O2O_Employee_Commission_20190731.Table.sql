USE [Foodunion]
GO
DROP TABLE [dm].[Fct_O2O_Employee_Commission_20190731]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_O2O_Employee_Commission_20190731](
	[Monthkey] [int] NULL,
	[Employee_id] [varchar](64) NOT NULL,
	[Order_count] [decimal](19, 2) NOT NULL,
	[Commission_amount] [decimal](38, 3) NOT NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
