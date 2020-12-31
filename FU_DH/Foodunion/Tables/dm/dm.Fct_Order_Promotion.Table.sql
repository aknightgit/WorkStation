USE [Foodunion]
GO
DROP TABLE [dm].[Fct_Order_Promotion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Order_Promotion](
	[Order_MonthKey] [bigint] NOT NULL,
	[Order_DateKey] [bigint] NOT NULL,
	[Order_ID] [varchar](100) NOT NULL,
	[Transaction_ID] [varchar](100) NOT NULL,
	[Promotion_ID] [varchar](200) NOT NULL,
	[Promotion_Name] [varchar](200) NULL,
	[Promotion_Description] [varchar](200) NULL,
	[Discount_Amount] [decimal](19, 9) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
 CONSTRAINT [PK_Fct_Order_Promotion] PRIMARY KEY CLUSTERED 
(
	[Order_DateKey] ASC,
	[Order_ID] ASC,
	[Promotion_ID] ASC,
	[Transaction_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
