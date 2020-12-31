USE [Foodunion]
GO
DROP TABLE [dm].[Fct_Youzan_Recon]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Youzan_Recon](
	[Recon_Date] [varchar](100) NULL,
	[Recon_DateKey] [varchar](8) NULL,
	[Order_No] [varchar](100) NULL,
	[pay_type_str] [varchar](255) NULL,
	[Order_Amount] [decimal](18, 2) NULL,
	[shipping_amount] [decimal](18, 2) NULL,
	[Order_Pay_Amount] [decimal](18, 2) NULL,
	[Order_Create_DateKey] [varchar](8) NULL,
	[Pay_Datekey] [varchar](8) NULL,
	[Recon_Type] [varchar](100) NULL,
	[Serial_No] [varchar](100) NULL,
	[Income_Amount] [decimal](20, 10) NULL,
	[Pay_Amount] [decimal](20, 10) NULL,
	[Balance_Amount] [decimal](20, 10) NULL,
	[Recon_Channel] [varchar](100) NULL,
	[Remarks] [varchar](100) NULL,
	[Amount] [decimal](20, 10) NULL,
	[Period] [varchar](100) NULL,
	[Order_Seq] [bigint] NULL,
	[cycle] [tinyint] NOT NULL,
	[Cycle_Times] [varchar](64) NULL,
	[Recon_Total_Amount] [decimal](10, 2) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](128) NULL,
	[Distribution_Amount] [decimal](20, 10) NULL,
	[Shipping_OneTime_Amount] [decimal](20, 10) NULL,
	[Order_Refund_Amount] [decimal](20, 10) NULL,
	[Order_Name] [nvarchar](512) NULL,
	[Recon_ID] [int] NULL,
	[Consign_Store] [nvarchar](50) NULL,
	[Remark] [nvarchar](200) NULL,
	[Operator_Name] [nvarchar](50) NULL
) ON [PRIMARY]
GO
