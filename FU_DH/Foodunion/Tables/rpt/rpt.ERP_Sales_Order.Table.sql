USE [Foodunion]
GO
DROP TABLE [rpt].[ERP_Sales_Order]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[ERP_Sales_Order](
	[Datekey] [int] NOT NULL,
	[On_Off_Line] [varchar](100) NULL,
	[Channel] [varchar](100) NULL,
	[Customer_Name] [varchar](200) NULL,
	[Account] [varchar](100) NULL,
	[Handler] [varchar](100) NULL,
	[Channel_Handler] [varchar](100) NULL,
	[SKU_ID] [varchar](100) NULL,
	[Actual_AMT] [decimal](38, 6) NULL,
	[Actual_VOL] [decimal](38, 12) NULL,
	[Active_Order_Amt] [decimal](38, 6) NULL,
	[Open_Order_AMT] [decimal](38, 6) NULL,
	[Active_Order_Vol] [decimal](38, 12) NULL,
	[Open_Order_Vol] [decimal](38, 12) NULL,
	[UPDATE_DTM] [datetime] NOT NULL,
	[Sale_Unit] [varchar](100) NULL,
	[Sale_Unit_QTY] [decimal](38, 12) NULL,
	[BASE_UNIT] [varchar](100) NULL,
	[Base_Unit_QTY] [decimal](38, 12) NULL,
	[Full_Amount] [decimal](38, 12) NULL,
	[Close_Status] [varchar](100) NULL
) ON [PRIMARY]
GO
