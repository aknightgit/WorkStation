USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_ERP_CustomerMapping](
	[ID] [int] NOT NULL,
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
	[Update_By] [varchar](100) NULL,
 CONSTRAINT [PK_Dim_ERP_CustomerMapping] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Dim_ERP_CustomerMapping] UNIQUE NONCLUSTERED 
(
	[Customer_Name] ASC,
	[Account_Display_Name] ASC,
	[Begin_Date] ASC,
	[End_Date] ASC,
	[Region] ASC,
	[Channel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
