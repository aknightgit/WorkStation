USE [Foodunion]
GO
DROP TABLE [dm].[Dim_ERP_CustomerMapping_20191009]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_ERP_CustomerMapping_20191009](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Customer_ID] [varchar](100) NULL,
	[Customer_Name] [varchar](400) NULL,
	[Account_Display_Name] [varchar](100) NULL,
	[Channel] [varchar](100) NULL,
	[Region] [varchar](100) NULL,
	[Handler] [varchar](100) NULL,
	[Channel_Handler] [varchar](100) NULL,
	[Begin_Date] [date] NOT NULL,
	[End_Date] [date] NOT NULL,
	[Is_Current] [int] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [varchar](100) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](100) NULL
) ON [PRIMARY]
GO
