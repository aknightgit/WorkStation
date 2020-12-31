USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_DC2Box](
	[DateKey] [bigint] NOT NULL,
	[Store_ID] [nvarchar](50) NOT NULL,
	[SKU_ID] [nvarchar](20) NOT NULL,
	[SKU_Code] [nvarchar](20) NOT NULL,
	[SKU_Name] [nvarchar](200) NULL,
	[Send_NUM] [int] NULL,
	[Prod_Date] [date] NULL,
	[Order_Date] [datetime] NOT NULL,
	[Dealer_Code] [nvarchar](200) NULL,
	[Dealer_Name] [nvarchar](200) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_DC2Box] PRIMARY KEY CLUSTERED 
(
	[Store_ID] ASC,
	[SKU_ID] ASC,
	[SKU_Code] ASC,
	[Order_Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
