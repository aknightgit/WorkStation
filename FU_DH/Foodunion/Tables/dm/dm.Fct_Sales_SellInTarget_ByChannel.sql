USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_SellInTarget_ByChannel](
	[MonthKey] [varchar](8) NOT NULL,
	[Channel_ID] [int] NULL,
	[ERP_Customer_Name] [nvarchar](50) NOT NULL,
	[Account_Display_Name] [nvarchar](50) NULL,
	[Channel_Short_Name] [nvarchar](50) NULL,
	[Channel_Type] [nvarchar](50) NULL,
	[Customer_Handler] [nvarchar](50) NULL,
	[Channel_Category_Name] [nvarchar](50) NULL,
	[Channel_Handler] [nvarchar](50) NULL,
	[Team] [nvarchar](50) NULL,
	[Team_Handler] [nvarchar](50) NULL,
	[Target_Amt_KRMB] [decimal](18, 6) NULL,
	[Target_Vol_MT] [decimal](18, 6) NULL,
	[DP_Vol_MT] [decimal](18, 6) NULL,
	[Category_Target_Amt_KRMB] [decimal](18, 6) NULL,
	[Category_Target_Vol_MT] [decimal](18, 6) NULL,
	[Category_DP_Vol_MT] [decimal](18, 6) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL
) ON [PRIMARY]
GO
