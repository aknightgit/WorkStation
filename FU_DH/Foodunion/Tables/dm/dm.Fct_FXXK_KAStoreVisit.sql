USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_FXXK_KAStoreVisit](
	[ID] [varchar](200) NOT NULL,
	[Datekey] [bigint] NULL,
	[Visit_Date] [date] NULL,
	[Customer] [varchar](200) NULL,
	[SalesPerson] [varchar](200) NULL,
	[SalesPerson_Account] [varchar](200) NULL,
	[Department] [varchar](200) NULL,
	[Device_ID] [varchar](200) NULL,
	[Region] [varchar](200) NULL,
	[Store_ID] [varchar](200) NULL,
	[Store_Code] [varchar](200) NULL,
	[Store_Name] [varchar](200) NULL,
	[Store_Province] [varchar](200) NULL,
	[Store_City] [varchar](200) NULL,
	[Store_Address] [varchar](200) NULL,
	[Checkin_Status] [varchar](20) NULL,
	[Checkin_Time] [datetime] NULL,
	[CheckOut_Time] [datetime] NULL,
	[Duration_Mins] [decimal](18, 0) NULL,
	[Duration_Hrs] [decimal](18, 2) NULL,
	[Longitude] [varchar](200) NULL,
	[Latitude] [varchar](200) NULL,
	[Checkin_Distance] [varchar](200) NULL,
	[Checkin_Type] [varchar](50) NULL,
	[Checkout_Lon] [varchar](50) NULL,
	[Checkout_Lat] [varchar](50) NULL,
	[Finish_Time] [datetime] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK__Fct_FXXK__3214EC27EFB60E94_3037] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
