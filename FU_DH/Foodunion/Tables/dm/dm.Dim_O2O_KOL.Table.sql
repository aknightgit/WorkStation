USE [Foodunion]
GO
ALTER TABLE [dm].[Dim_O2O_KOL] DROP CONSTRAINT [DF__Dim_O2O_K__Updat__0DF9F0CA]
GO
ALTER TABLE [dm].[Dim_O2O_KOL] DROP CONSTRAINT [DF__Dim_O2O_K__Creat__0D05CC91]
GO
DROP TABLE [dm].[Dim_O2O_KOL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_O2O_KOL](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[KolName] [varchar](100) NOT NULL,
	[KOL_Employee_ID] [varchar](100) NOT NULL,
	[QRKey] [varchar](100) NOT NULL,
	[Channel] [varchar](100) NULL,
	[Mobile] [varchar](20) NULL,
	[Store] [varchar](100) NULL,
	[Offline_id] [varchar](20) NULL,
	[Province] [varchar](100) NULL,
	[City] [varchar](100) NULL,
	[Area] [varchar](100) NULL,
	[Address] [varchar](500) NULL,
	[is_self_fetch] [bit] NULL,
	[is_store] [bit] NULL,
	[Mobile2] [varchar](20) NULL,
	[lng] [decimal](18, 9) NULL,
	[lat] [decimal](18, 9) NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dm].[Dim_O2O_KOL] ADD  DEFAULT (getdate()) FOR [Create_Time]
GO
ALTER TABLE [dm].[Dim_O2O_KOL] ADD  DEFAULT (getdate()) FOR [Update_Time]
GO
