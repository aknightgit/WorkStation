USE [Foodunion]
GO
DROP TABLE [dm].[Fct_Sales_SellInTarget_ByChannel_hist]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_SellInTarget_ByChannel_hist](
	[CID] [int] NOT NULL,
	[ID] [int] NOT NULL,
	[Datekey] [int] NULL,
	[Team] [nvarchar](200) NULL,
	[Channel_Category] [nvarchar](100) NULL,
	[Customer_Name] [nvarchar](100) NULL,
	[Channel_Name_Display] [nvarchar](100) NULL,
	[Handler] [nvarchar](100) NULL,
	[Team_Handler] [nvarchar](100) NULL,
	[Target_AMT] [decimal](18, 9) NULL,
	[MT_Target_VOL] [decimal](18, 9) NULL,
	[Actual_AMT] [int] NOT NULL,
	[Actual_VOL] [int] NOT NULL,
	[Active_Order_AMT] [int] NOT NULL,
	[Open_Order_AMT] [int] NOT NULL,
	[Active_Order_Vol] [int] NOT NULL,
	[Open_Order_Vol] [int] NOT NULL,
	[UPDATE_DTM] [datetime] NOT NULL
) ON [PRIMARY]
GO
