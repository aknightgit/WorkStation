USE [Foodunion]
GO
DROP TABLE [dm].[Fct_Sales_SellInTarget_ByChannel]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_SellInTarget_ByChannel](
	[MonthKey] [varchar](8) NOT NULL,
	[ERP_Customer_Name] [nvarchar](50) NOT NULL,
	[Account_Display_Name] [nvarchar](50) NULL,
	[Channel_Short_Name] [nvarchar](50) NULL,
	[Channel_Type] [nvarchar](50) NULL,
	[Channel_Category_Name] [nvarchar](50) NULL,
	[Channel_Handler] [nvarchar](50) NULL,
	[Team] [nvarchar](50) NULL,
	[Team_Handler] [nvarchar](50) NULL,
	[Target_Amt_KRMB] [decimal](18, 6) NULL,
	[Target_Vol_MT] [decimal](18, 6) NULL,
	[Category_Target_Amt_KRMB] [decimal](18, 6) NULL,
	[Category_Target_Vol_MT] [decimal](18, 6) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Fct_Sales_SellInTarget_ByChannel] PRIMARY KEY NONCLUSTERED 
(
	[MonthKey] ASC,
	[ERP_Customer_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
