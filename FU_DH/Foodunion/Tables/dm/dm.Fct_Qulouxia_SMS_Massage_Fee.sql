USE [Foodunion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dm].[Fct_Qulouxia_SMS_Massage_Fee](
	[Datekey] [bigint] NOT NULL,
	[Message_Num] [float] NULL,
	[Comments] [nvarchar](200) NOT NULL,
	[Single_SMS_fee] [float] NULL,
	[Total_Fee] [float] NULL,
	[Create_Time] [datetime] NULL,
	[Create_By] [nvarchar](128) NULL,
	[Update_Time] [datetime] NULL,
	[Update_By] [nvarchar](128) NULL,
 CONSTRAINT [PK_Fct_Qulouxia_SMS_Massage_Fee] PRIMARY KEY CLUSTERED 
(
	[Datekey] ASC,
	[Comments] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
