USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_Stores](
	[Store_ID] [nvarchar](50) NULL,
	[Store_Code] [nvarchar](50) NOT NULL,
	[Store_Name] [nvarchar](500) NULL,
	[Store_Type] [nvarchar](200) NULL,
	[Store_Address] [nvarchar](200) NULL,
	[Store_City] [nvarchar](200) NULL,
	[Number_of_Machines] [nvarchar](200) NULL,
	[Opening_Date] [nvarchar](200) NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_Stores] PRIMARY KEY CLUSTERED 
(
	[Store_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
