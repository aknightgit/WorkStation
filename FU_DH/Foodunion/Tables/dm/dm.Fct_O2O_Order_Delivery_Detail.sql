USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_O2O_Order_Delivery_Detail](
	[id] [varchar](64) NOT NULL,
	[Delivery_No] [varchar](64) NULL,
	[Order_No] [varchar](255) NULL,
	[kdtId] [varchar](255) NULL,
	[Item_Id] [varchar](255) NULL,
	[Num] [int] NULL,
	[Weight] [int] NULL,
	[Delivery_Status] [int] NULL,
	[Delivery_Status_Desc] [varchar](255) NULL,
	[noNeed_Delivery_Reason] [varchar](255) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](100) NULL,
 CONSTRAINT [PK_Fct_O2O_Order_Delivery_Detail] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_O2O_Order_Delivery_Detail] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_O2O_Order_Delivery_Detail] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
