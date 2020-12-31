USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_O2O_Order_Delivery](
	[ID] [varchar](64) NOT NULL,
	[Delivery_No] [varchar](64) NULL,
	[Order_No] [varchar](64) NULL,
	[kdtId] [varchar](64) NULL,
	[Delivery_PointId] [varchar](64) NULL,
	[Status] [int] NULL,
	[Dist_Type] [int] NULL,
	[Extend] [varchar](255) NULL,
	[Delivery_CreateTime] [datetime] NULL,
	[Delivery_UpdateTime] [datetime] NULL,
	[Delivery_Fee] [varchar](255) NULL,
	[Delivery_Fee_Real] [varchar](255) NULL,
	[Remark] [varchar](255) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [varchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [varchar](100) NULL,
 CONSTRAINT [PK_Fct_O2O_Order_Delivery] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Fct_O2O_Order_Delivery] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Fct_O2O_Order_Delivery] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
