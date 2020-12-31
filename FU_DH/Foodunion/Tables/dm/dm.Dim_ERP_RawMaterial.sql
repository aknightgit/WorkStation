USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_ERP_RawMaterial](
	[SKU_ID] [varchar](50) NOT NULL,
	[SKU_Name] [varchar](200) NULL,
	[SKU_Name_EN] [varchar](200) NULL,
	[Group_Name] [varchar](50) NULL,
	[UseOrg] [varchar](100) NULL,
	[CreateOrg] [varchar](100) NULL,
	[CGLB1] [varchar](50) NULL,
	[Category] [varchar](100) NULL,
	[LifeTime] [varchar](50) NULL,
	[Unit_Cost] [decimal](19, 10) NULL,
	[IsActive] [smallint] NULL,
	[Create_Time] [datetime] NOT NULL,
	[Create_By] [nvarchar](100) NULL,
	[Update_Time] [datetime] NOT NULL,
	[Update_By] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[SKU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Dim_ERP_RawMaterial_n] UNIQUE NONCLUSTERED 
(
	[SKU_ID] ASC,
	[Category] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
