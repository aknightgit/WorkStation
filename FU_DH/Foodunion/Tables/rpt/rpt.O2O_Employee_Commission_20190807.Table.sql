USE [Foodunion]
GO
DROP TABLE [rpt].[O2O_Employee_Commission_20190807]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[O2O_Employee_Commission_20190807](
	[Monthkey] [int] NULL,
	[Employee_id] [varchar](64) NOT NULL,
	[Employee_Name] [varchar](64) NULL,
	[Order_Count] [int] NOT NULL,
	[Operate_Order_Cnt] [int] NOT NULL,
	[Commission_Amount] [decimal](38, 3) NOT NULL,
	[Order_Amount] [decimal](38, 3) NULL,
	[Shipping_Amount] [decimal](38, 3) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
