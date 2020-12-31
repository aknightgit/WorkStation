USE [Foodunion]
GO
ALTER TABLE [dm].[Dim_O2O_Employee] DROP CONSTRAINT [DF__Dim_O2O_E__Updat__5986288B]
GO
ALTER TABLE [dm].[Dim_O2O_Employee] DROP CONSTRAINT [DF__Dim_O2O_E__Creat__58920452]
GO
DROP TABLE [dm].[Dim_O2O_Employee]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_O2O_Employee](
	[Employee_id] [varchar](64) NOT NULL,
	[Employee_name] [varchar](64) NOT NULL,
	[alias] [varchar](32) NULL,
	[english_name] [varchar](64) NULL,
	[employee_no] [varchar](64) NULL,
	[employee_type] [varchar](64) NULL,
	[mobile] [varchar](20) NULL,
	[gender] [varchar](20) NULL,
	[position] [varchar](128) NULL,
	[status] [varchar](20) NULL,
	[scene_qrcode_id] [varchar](64) NULL,
	[wx_work_user_id] [varchar](64) NULL,
	[org_name] [varchar](64) NULL,
	[wx_org_id] [varchar](64) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Employee_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_O2O_Employee] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_O2O_Employee] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
