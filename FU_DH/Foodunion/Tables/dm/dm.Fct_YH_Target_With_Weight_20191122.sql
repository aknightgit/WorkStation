USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_YH_Target_With_Weight_20191122](
	[period] [nvarchar](255) NOT NULL,
	[Store_ID] [nvarchar](255) NULL,
	[Region] [nvarchar](255) NULL,
	[Store_NM] [nvarchar](255) NULL,
	[Sales_Target] [decimal](29, 17) NULL,
	[Ambient_Sales_Target] [decimal](31, 19) NULL,
	[Fresh_Sales_Target] [decimal](31, 19) NULL,
	[DSR] [nvarchar](255) NULL,
	[Target_With_Weight] [decimal](38, 10) NULL,
	[Target_Ambient_With_Weight] [decimal](38, 10) NULL,
	[Target_Fresh_With_Weight] [decimal](38, 10) NULL,
	[Sales_Forecast_AMT] [decimal](38, 10) NULL,
	[Sales_Forecast_Ambient_AMT] [decimal](38, 10) NULL,
	[Sales_Forecast_Fresh_AMT] [decimal](38, 10) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](128) NULL
) ON [PRIMARY]
GO
