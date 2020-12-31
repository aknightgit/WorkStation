USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_Coupon_Verification](
	[DateKey] [bigint] NULL,
	[Coupon_ID] [nvarchar](50) NULL,
	[Coupon_Name] [nvarchar](255) NULL,
	[Coupon_Type] [nvarchar](255) NULL,
	[Promotion_Threshold] [nvarchar](255) NULL,
	[Coupon_AMT] [nvarchar](255) NULL,
	[Delivered_QTY] [int] NULL,
	[Used_QTY] [int] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
