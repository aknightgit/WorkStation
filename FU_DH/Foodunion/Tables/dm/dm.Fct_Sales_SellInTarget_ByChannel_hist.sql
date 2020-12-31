USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_SellInTarget_ByChannel_hist](
	[CID] [int] NOT NULL,
	[ID] [int] NOT NULL,
	[Datekey] [varchar](100) NOT NULL,
	[Team] [nvarchar](200) NOT NULL,
	[Channel_Category] [nvarchar](100) NOT NULL,
	[Customer_Name] [nvarchar](100) NOT NULL,
	[Channel_Name_Display] [nvarchar](100) NOT NULL,
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
	[UPDATE_DTM] [datetime] NOT NULL,
 CONSTRAINT [PK_Fct_Sales_SellInTarget_ByChannel_hist] PRIMARY KEY CLUSTERED 
(
	[Datekey] ASC,
	[Team] ASC,
	[Channel_Category] ASC,
	[Customer_Name] ASC,
	[Channel_Name_Display] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
