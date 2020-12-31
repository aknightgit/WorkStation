USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Dim_Store_Fxxk](
	[Fxxk_ID] [varchar](255) NOT NULL,
	[Store_Code] [varchar](255) NOT NULL,
	[Store_Name] [varchar](255) NULL,
	[Store_Address] [varchar](512) NULL,
	[Channel] [varchar](255) NOT NULL,
	[Channel_Account] [varchar](255) NULL,
	[Store_Type] [varchar](255) NULL,
	[Sales_Region] [varchar](255) NULL,
	[Store_Level] [varchar](255) NULL,
	[Department_ID] [varchar](50) NULL,
	[Department_Name] [varchar](255) NULL,
	[Owner_ID] [varchar](255) NULL,
	[Owner] [varchar](255) NULL,
	[Role] [varchar](255) NULL,
	[Store_CreatedBy] [varchar](255) NULL,
	[Last_Follower] [varchar](255) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [varchar](50) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [varchar](50) NULL,
 CONSTRAINT [pk_Dim_Store_Fxxk] PRIMARY KEY CLUSTERED 
(
	[Store_Code] ASC,
	[Channel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
