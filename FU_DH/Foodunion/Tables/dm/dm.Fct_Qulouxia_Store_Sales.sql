USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_Store_Sales](
	[DateKey] [bigint] NOT NULL,
	[Store_ID] [nvarchar](50) NOT NULL,
	[Store_Name] [nvarchar](50) NOT NULL,
	[SKU_ID] [nvarchar](50) NULL,
	[SKU_Code] [nvarchar](50) NOT NULL,
	[SKU_Name] [nvarchar](500) NULL,
	[Member_Sales] [float] NULL,
	[Non_Member_Sales] [float] NULL,
	[Coupon_Sales] [float] NULL,
	[Total_Sales] [float] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_Store_Sales] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC,
	[Store_ID] ASC,
	[Store_Name] ASC,
	[SKU_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
