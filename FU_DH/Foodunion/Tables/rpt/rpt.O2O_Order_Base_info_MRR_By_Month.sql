USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [rpt].[O2O_Order_Base_info_MRR_By_Month](
	[TMonth] [varchar](8) NULL,
	[MRR] [decimal](38, 13) NULL,
	[MRR_LM] [decimal](38, 13) NULL,
	[Active_Customer_Count] [int] NULL,
	[Active_Customer_Count_LM] [int] NULL,
	[Expansion_MRR] [decimal](38, 13) NULL,
	[Contraction_MRR] [decimal](38, 13) NULL,
	[New_Customer] [int] NULL,
	[NEW_MRR] [decimal](38, 13) NULL,
	[Lost_Customer] [int] NULL,
	[Lost_MRR] [decimal](38, 13) NULL,
	[New_Over_Last] [decimal](9, 2) NULL,
	[NewMRR_Over_Last] [decimal](9, 2) NULL,
	[Churn_Over_Last] [decimal](9, 2) NULL,
	[ChurnMRR_Over_Last] [decimal](9, 2) NULL,
	[Churn_Rate] [decimal](38, 13) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](50) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](50) NULL
) ON [PRIMARY]
GO
