USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Sales_SellInTarget_20191106](
	[Monthkey] [int] NOT NULL,
	[Channel] [varchar](200) NOT NULL,
	[Region] [varchar](200) NOT NULL,
	[Customer_Name] [varchar](200) NOT NULL,
	[Account_Display_Name] [varchar](200) NOT NULL,
	[Target_Amount] [decimal](18, 9) NULL,
	[Target_Volumn_MT] [decimal](18, 9) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Monthkey] ASC,
	[Channel] ASC,
	[Region] ASC,
	[Customer_Name] ASC,
	[Account_Display_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_Sales_SellInTarget_20191106] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_Sales_SellInTarget_20191106] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
