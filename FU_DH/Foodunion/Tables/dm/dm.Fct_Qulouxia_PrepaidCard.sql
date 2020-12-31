USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_PrepaidCard](
	[DateKey] [bigint] NOT NULL,
	[Card_Order_ID] [nvarchar](200) NOT NULL,
	[Card_ID] [nvarchar](200) NOT NULL,
	[Card_Name] [nvarchar](200) NULL,
	[Booking_Type] [nvarchar](200) NULL,
	[Customer_ID] [nvarchar](200) NULL,
	[Customer_Phone] [nvarchar](200) NULL,
	[Store_ID] [nvarchar](50) NOT NULL,
	[Store_Code] [nvarchar](50) NULL,
	[Store_Name] [nvarchar](500) NULL,
	[SKU_ID] [nvarchar](50) NOT NULL,
	[SKU_Code] [nvarchar](50) NOT NULL,
	[SKU_Name] [nvarchar](500) NULL,
	[Cycle_Num] [int] NULL,
	[Weekly_Pickup_Times] [int] NULL,
	[Pickup_Day] [nvarchar](200) NULL,
	[Pickup_Time_1st] [date] NULL,
	[Pickup_Time_Last] [date] NULL,
	[QTY_Per] [int] NULL,
	[QTY_Total] [int] NULL,
	[Pay_Amount] [decimal](18, 4) NULL,
	[Pay_Type] [nvarchar](200) NULL,
	[Pay_Status] [nvarchar](200) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_PrepaidCard] PRIMARY KEY CLUSTERED 
(
	[Card_Order_ID] ASC,
	[Card_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
